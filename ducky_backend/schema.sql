-- ═══════════════════════════════════════════════════════════════════════════════
-- Ducky Library – PostgreSQL Schema
-- Generated from: models.dart + auth_provider.dart + openapi.yaml
-- Target: Neon Postgres (sslmode=require)
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- 0. Extensions
-- ─────────────────────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- trigram indexes for ILIKE search

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. Custom ENUM types  (mirror Dart enums exactly)
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TYPE user_role       AS ENUM ('administrator', 'librarian', 'student', 'professor');
CREATE TYPE copy_status     AS ENUM ('available', 'borrowed', 'reserved', 'internal', 'damaged', 'lost');
CREATE TYPE loan_status     AS ENUM ('active', 'overdue', 'returned');
CREATE TYPE fine_status     AS ENUM ('pending', 'paid');
CREATE TYPE purchase_status AS ENUM ('pending', 'approved', 'rejected', 'purchased');

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. Tables
-- ─────────────────────────────────────────────────────────────────────────────

-- ── users ───────────────────────────────────────────────────────────────────
-- Source: AppUser + AuthUser (auth_provider.dart)
-- Note: password_hash is only in the DB, never in the Dart model.
CREATE TABLE users (
    id             TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    name           TEXT        NOT NULL,
    email          TEXT        NOT NULL,
    role           user_role   NOT NULL DEFAULT 'student',
    phone          TEXT,                              -- nullable in Dart
    is_active      BOOLEAN     NOT NULL DEFAULT true,
    password_hash  TEXT        NOT NULL,              -- werkzeug hash (app.py)
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- Constraints
    CONSTRAINT users_email_unique UNIQUE (email)
);

-- schema-partial-indexes: fast lookup on active users for login
CREATE INDEX idx_users_email_active ON users (email) WHERE is_active = true;
-- query-missing-indexes: role filter used in GET /api/users?role=
CREATE INDEX idx_users_role ON users (role);


-- ── books ───────────────────────────────────────────────────────────────────
-- Source: Book model  (isbn is the natural PK, same as Dart + OpenAPI)
CREATE TABLE books (
    isbn             TEXT PRIMARY KEY,
    title            TEXT           NOT NULL,
    author           TEXT           NOT NULL,
    publisher        TEXT           NOT NULL,
    year             INTEGER        NOT NULL,
    topic            TEXT           NOT NULL,
    section          TEXT           NOT NULL,
    price            NUMERIC(10,2)  NOT NULL CHECK (price >= 0),
    description      TEXT,                            -- nullable in Dart
    image_url        TEXT,                            -- nullable in Dart
    total_copies     INTEGER        NOT NULL DEFAULT 0 CHECK (total_copies >= 0),
    available_copies INTEGER        NOT NULL DEFAULT 0 CHECK (available_copies >= 0)
);

-- query-missing-indexes: filters used by GET /api/books?topic=&section=
CREATE INDEX idx_books_topic   ON books (topic);
CREATE INDEX idx_books_section ON books (section);
-- query-missing-indexes: ILIKE search on title/author
CREATE INDEX idx_books_title_trgm  ON books USING gin (title  gin_trgm_ops);
CREATE INDEX idx_books_author_trgm ON books USING gin (author gin_trgm_ops);


-- ── copies ──────────────────────────────────────────────────────────────────
-- Source: BookCopy model
-- Note: `book_title` in Dart model is denormalized — we get it via JOIN.
CREATE TABLE copies (
    id               TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    isbn             TEXT        NOT NULL REFERENCES books(isbn) ON DELETE CASCADE,
    status           copy_status NOT NULL DEFAULT 'available',
    location         TEXT        NOT NULL,
    condition        TEXT        NOT NULL,
    notes            TEXT,                            -- nullable in Dart
    acquisition_date DATE        NOT NULL DEFAULT CURRENT_DATE
);

CREATE INDEX idx_copies_isbn   ON copies (isbn);
CREATE INDEX idx_copies_status ON copies (status);


-- ── loans ───────────────────────────────────────────────────────────────────
-- Source: Loan model
-- Denormalized fields in Dart: user_name, book_title, book_isbn, book_price
-- → resolved via JOINs (see views below)
CREATE TABLE loans (
    id             TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id        TEXT        NOT NULL REFERENCES users(id),
    copy_id        TEXT        NOT NULL REFERENCES copies(id),
    loan_date      TIMESTAMPTZ NOT NULL DEFAULT now(),
    due_date       TIMESTAMPTZ NOT NULL,
    return_date    TIMESTAMPTZ,                       -- nullable in Dart
    status         loan_status NOT NULL DEFAULT 'active',
    fine           NUMERIC(10,2),                     -- nullable in Dart
    renewal_count  INTEGER     NOT NULL DEFAULT 0 CHECK (renewal_count >= 0)
);

CREATE INDEX idx_loans_user_id ON loans (user_id);
CREATE INDEX idx_loans_copy_id ON loans (copy_id);
-- schema-partial-indexes: dashboard counts active/overdue loans frequently
CREATE INDEX idx_loans_status_active  ON loans (status) WHERE status = 'active';
CREATE INDEX idx_loans_status_overdue ON loans (status) WHERE status = 'overdue';


-- ── fines ───────────────────────────────────────────────────────────────────
-- Source: Fine model
-- Denormalized fields in Dart: user_name, book_title → resolved via JOINs
CREATE TABLE fines (
    id           TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id      TEXT        NOT NULL REFERENCES users(id),
    loan_id      TEXT        NOT NULL REFERENCES loans(id),
    days_overdue INTEGER     NOT NULL CHECK (days_overdue >= 0),
    amount       NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    status       fine_status NOT NULL DEFAULT 'pending',
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    paid_at      TIMESTAMPTZ                          -- nullable in Dart
);

CREATE INDEX idx_fines_user_id ON fines (user_id);
CREATE INDEX idx_fines_loan_id ON fines (loan_id);
-- schema-partial-indexes: pending fines are queried most often
CREATE INDEX idx_fines_pending ON fines (status) WHERE status = 'pending';


-- ── waitlist ────────────────────────────────────────────────────────────────
-- Source: WaitlistEntry model
-- Denormalized fields in Dart: book_title, user_name → resolved via JOINs
CREATE TABLE waitlist (
    id           TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    book_isbn    TEXT    NOT NULL REFERENCES books(isbn) ON DELETE CASCADE,
    user_id      TEXT    NOT NULL REFERENCES users(id),
    request_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    position     INTEGER NOT NULL CHECK (position >= 1),

    -- A user should only be on the waitlist for a given book once
    CONSTRAINT waitlist_user_book_unique UNIQUE (book_isbn, user_id)
);

CREATE INDEX idx_waitlist_isbn    ON waitlist (book_isbn);
CREATE INDEX idx_waitlist_user_id ON waitlist (user_id);


-- ── purchase_requests ───────────────────────────────────────────────────────
-- Source: PurchaseRequest model
-- Note: `total` in Dart is a computed getter (quantity * unit_price),
--       stored as a generated column here for query convenience.
-- Note: `requested_by` and `reviewed_by` are user IDs (FK to users).
CREATE TABLE purchase_requests (
    id            TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    isbn          TEXT            NOT NULL,
    book_title    TEXT            NOT NULL,
    author        TEXT            NOT NULL,
    requested_by  TEXT            NOT NULL REFERENCES users(id),
    quantity      INTEGER         NOT NULL CHECK (quantity > 0),
    unit_price    NUMERIC(10,2)   NOT NULL CHECK (unit_price >= 0),
    total         NUMERIC(10,2)   GENERATED ALWAYS AS (quantity * unit_price) STORED,
    justification TEXT            NOT NULL,
    status        purchase_status NOT NULL DEFAULT 'pending',
    created_at    TIMESTAMPTZ     NOT NULL DEFAULT now(),
    reviewed_by   TEXT            REFERENCES users(id),  -- nullable
    review_notes  TEXT                                     -- nullable
);

CREATE INDEX idx_purchase_requests_status ON purchase_requests (status);


-- ─────────────────────────────────────────────────────────────────────────────
-- 3. Convenience Views
--    These produce the exact JSON shape that the Flutter frontend expects
--    (with denormalized user_name, book_title, etc.)
-- ─────────────────────────────────────────────────────────────────────────────

-- ── v_copies  →  matches BookCopy.fromJson() ────────────────────────────────
CREATE OR REPLACE VIEW v_copies AS
SELECT
    c.id,
    c.isbn,
    b.title           AS book_title,
    c.status::text    AS status,
    c.location,
    c.condition,
    c.notes,
    c.acquisition_date
FROM copies c
JOIN books b ON b.isbn = c.isbn;

-- ── v_loans  →  matches Loan.fromJson() ─────────────────────────────────────
CREATE OR REPLACE VIEW v_loans AS
SELECT
    l.id,
    l.user_id,
    u.name            AS user_name,
    l.copy_id,
    b.title           AS book_title,
    b.isbn            AS book_isbn,
    b.price           AS book_price,
    l.loan_date,
    l.due_date,
    l.return_date,
    l.status::text    AS status,
    l.fine,
    l.renewal_count
FROM loans l
JOIN users  u ON u.id   = l.user_id
JOIN copies c ON c.id   = l.copy_id
JOIN books  b ON b.isbn = c.isbn;

-- ── v_fines  →  matches Fine.fromJson() ─────────────────────────────────────
CREATE OR REPLACE VIEW v_fines AS
SELECT
    f.id,
    f.user_id,
    u.name            AS user_name,
    f.loan_id,
    b.title           AS book_title,
    f.days_overdue,
    f.amount,
    f.status::text    AS status,
    f.created_at,
    f.paid_at
FROM fines f
JOIN users  u ON u.id   = f.user_id
JOIN loans  l ON l.id   = f.loan_id
JOIN copies c ON c.id   = l.copy_id
JOIN books  b ON b.isbn = c.isbn;

-- ── v_waitlist  →  matches WaitlistEntry.fromJson() ─────────────────────────
CREATE OR REPLACE VIEW v_waitlist AS
SELECT
    w.id,
    w.book_isbn,
    b.title           AS book_title,
    w.user_id,
    u.name            AS user_name,
    w.request_date,
    w.position
FROM waitlist w
JOIN books b ON b.isbn = w.book_isbn
JOIN users u ON u.id   = w.user_id;

-- ── v_purchase_requests  →  matches PurchaseRequest.fromJson() ──────────────
CREATE OR REPLACE VIEW v_purchase_requests AS
SELECT
    pr.id,
    pr.isbn,
    pr.book_title,
    pr.author,
    req.name          AS requested_by,
    pr.quantity,
    pr.unit_price,
    pr.total,
    pr.justification,
    pr.status::text   AS status,
    pr.created_at,
    rev.name          AS reviewed_by,
    pr.review_notes
FROM purchase_requests pr
JOIN users req ON req.id = pr.requested_by
LEFT JOIN users rev ON rev.id = pr.reviewed_by;




-- ═══════════════════════════════════════════════════════════════════════════════
-- Done.  Run with:  psql $DATABASE_URL -f schema.sql
-- Or via Neon console SQL editor.
-- ═══════════════════════════════════════════════════════════════════════════════
