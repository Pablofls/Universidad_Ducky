# app.py
# ─────────────────────────────────────────────────────────────────────────────
# Ducky Library API – Flask Backend
# Applies: postgres-best-practices (connection pooling, parameterized queries)
#          api-security-best-practices (JWT auth, input validation, CORS, error sanitization)
# ─────────────────────────────────────────────────────────────────────────────
import os
import re
import functools
import json
from decimal import Decimal
from datetime import datetime, timedelta, timezone

import jwt
import psycopg2
import psycopg2.pool
from psycopg2.extras import RealDictCursor
from werkzeug.security import check_password_hash, generate_password_hash
from flask import Flask, jsonify, request, g
from flask_cors import CORS
from dotenv import load_dotenv

# ── Environment ──────────────────────────────────────────────────────────────
load_dotenv()

JWT_SECRET = os.environ.get('JWT_SECRET', 'dev-secret-change-me')
JWT_EXPIRY_HOURS = int(os.environ.get('JWT_EXPIRY_HOURS', '24'))

app = Flask(__name__)

# ── Custom JSON provider – Decimal → float ───────────────────────────────────
# PostgreSQL NUMERIC columns arrive as Python Decimal objects.  Flask's default
# JSON provider does not handle them, so they serialize as strings ("89.99").
from flask.json.provider import DefaultJSONProvider

class CustomJSONProvider(DefaultJSONProvider):
    def default(self, o):
        if isinstance(o, Decimal):
            return float(o)
        return super().default(o)

app.json_provider_class = CustomJSONProvider
app.json = CustomJSONProvider(app)

# ── CORS – restrict to Flutter dev origins ───────────────────────────────────
# api-security: "Implement CORS properly – Only allow trusted origins"
CORS(app, origins=[
    "http://localhost:*",       # Flutter web  (any port)
    "http://127.0.0.1:*",      # Flutter web  (any port)
    "http://10.0.2.2:*",       # Android emulator → host
], supports_credentials=True)


# ─────────────────────────────────────────────────────────────────────────────
# Database – Connection Pool  (postgres-best-practices: conn-pooling)
# ─────────────────────────────────────────────────────────────────────────────
# "Use connection pooling for all applications – connections are expensive
#  (1-3 MB RAM each). Use a small pool with transaction-mode reuse."
db_pool = psycopg2.pool.ThreadedConnectionPool(
    minconn=2,
    maxconn=10,       # (CPU cores * 2) + spindle_count ≈ 10 for a small app
    host=os.environ['DB_HOST'],
    database=os.environ['DB_NAME'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    sslmode='require',  # Mandatory for Neon
)


def get_db():
    """Get a pooled connection, storing it in Flask's request context."""
    if 'db_conn' not in g:
        g.db_conn = db_pool.getconn()
    return g.db_conn


@app.teardown_appcontext
def return_db(exc):
    """Return the connection to the pool after every request."""
    conn = g.pop('db_conn', None)
    if conn is not None:
        if exc:
            conn.rollback()
        db_pool.putconn(conn)


# ─────────────────────────────────────────────────────────────────────────────
# JWT Auth helpers  (api-security: JWT authentication)
# ─────────────────────────────────────────────────────────────────────────────
def create_token(user_row):
    """Issue a JWT with user id, email, role."""
    payload = {
        'sub':   user_row['id'],
        'email': user_row['email'],
        'role':  user_row['role'],
        'iat':   datetime.now(timezone.utc),
        'exp':   datetime.now(timezone.utc) + timedelta(hours=JWT_EXPIRY_HOURS),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm='HS256')


def token_required(f):
    """Decorator – rejects requests without a valid Bearer token."""
    @functools.wraps(f)
    def wrapper(*args, **kwargs):
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return jsonify({"error": "Access token required"}), 401
        token = auth_header.split(' ', 1)[1]
        try:
            payload = jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
            g.current_user = payload
        except jwt.ExpiredSignatureError:
            return jsonify({"error": "Token expired"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"error": "Invalid token"}), 401
        return f(*args, **kwargs)
    return wrapper


def role_required(*roles):
    """Decorator – restricts access to specific roles."""
    def decorator(f):
        @functools.wraps(f)
        def wrapper(*args, **kwargs):
            if g.current_user.get('role') not in roles:
                return jsonify({"error": "Insufficient permissions"}), 403
            return f(*args, **kwargs)
        return wrapper
    return decorator


# ─────────────────────────────────────────────────────────────────────────────
# Input validation helpers  (api-security: input validation)
# ─────────────────────────────────────────────────────────────────────────────
EMAIL_RE = re.compile(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')


def validate_json(*required_fields):
    """Decorator – ensures request body has the required JSON fields."""
    def decorator(f):
        @functools.wraps(f)
        def wrapper(*args, **kwargs):
            data = request.get_json(silent=True)
            if data is None:
                return jsonify({"error": "Request body must be JSON"}), 400
            missing = [k for k in required_fields if k not in data or data[k] is None]
            if missing:
                return jsonify({"error": f"Missing fields: {', '.join(missing)}"}), 400
            return f(*args, **kwargs)
        return wrapper
    return decorator


# ─────────────────────────────────────────────────────────────────────────────
# Routes
# ─────────────────────────────────────────────────────────────────────────────


# ── Health ───────────────────────────────────────────────────────────────────
@app.route('/', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "message": "Ducky API is running"}), 200


# ── Auth ─────────────────────────────────────────────────────────────────────
@app.route('/api/auth/login', methods=['POST'])
@validate_json('email', 'password')
def login():
    """
    Authenticate a user and return a JWT + user object.
    api-security: generic error message prevents user enumeration.
    """
    data = request.get_json()
    email = data['email'].strip().lower()
    password = data['password']

    if not EMAIL_RE.match(email):
        return jsonify({"error": "Invalid email format"}), 400

    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)

    try:
        # postgres-best-practices: parameterized query, explicit column list
        cur.execute(
            """SELECT id, name, email, role, password_hash
               FROM users
               WHERE email = %s AND is_active = true""",
            (email,)
        )
        user = cur.fetchone()
    finally:
        cur.close()

    # api-security: don't reveal whether the email exists
    if not user or not check_password_hash(user['password_hash'], password):
        return jsonify({"error": "Invalid credentials"}), 401

    token = create_token(user)
    return jsonify({
        "token": token,
        "user": {
            "id":    user['id'],
            "name":  user['name'],
            "email": user['email'],
            "role":  user['role'],
        }
    }), 200


# ── Users ────────────────────────────────────────────────────────────────────
@app.route('/api/users', methods=['GET'])
@token_required
@role_required('administrator', 'librarian')
def get_users():
    """List all users. Supports optional ?q= search and ?role= filter."""
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)

    search = request.args.get('q', '').strip()
    role_filter = request.args.get('role', '').strip()

    # Build query dynamically but safely with parameterized values
    clauses = []
    params = []

    if search:
        clauses.append("(name ILIKE %s OR email ILIKE %s)")
        params.extend([f'%{search}%', f'%{search}%'])
    if role_filter:
        clauses.append("role = %s")
        params.append(role_filter)

    where = f"WHERE {' AND '.join(clauses)}" if clauses else ""

    try:
        # postgres-best-practices: explicit columns, never SELECT *
        cur.execute(
            f"""SELECT id, name, email, role, phone, is_active, created_at
                FROM users {where}
                ORDER BY created_at DESC""",
            params
        )
        users = cur.fetchall()

        # Convert datetime to ISO strings for JSON
        for u in users:
            u['created_at'] = u['created_at'].isoformat() if u.get('created_at') else None

        return jsonify(users), 200
    except Exception:
        # api-security: sanitize error messages – don't leak internals
        return jsonify({"error": "Failed to fetch users"}), 500
    finally:
        cur.close()


@app.route('/api/users/<string:user_id>', methods=['GET'])
@token_required
def get_user(user_id):
    """Get a single user by ID."""
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)

    try:
        cur.execute(
            """SELECT id, name, email, role, phone, is_active, created_at
               FROM users WHERE id = %s""",
            (user_id,)
        )
        user = cur.fetchone()
        if not user:
            return jsonify({"error": "User not found"}), 404

        user['created_at'] = user['created_at'].isoformat() if user.get('created_at') else None
        return jsonify(user), 200
    except Exception:
        return jsonify({"error": "Failed to fetch user"}), 500
    finally:
        cur.close()


# ── Books ────────────────────────────────────────────────────────────────────
@app.route('/api/books', methods=['GET'])
@token_required
def get_books():
    """List all books. Supports ?q=, ?topic=, ?section= filters."""
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)

    search = request.args.get('q', '').strip()
    topic = request.args.get('topic', '').strip()
    section = request.args.get('section', '').strip()

    clauses = []
    params = []

    if search:
        clauses.append("(title ILIKE %s OR author ILIKE %s OR isbn ILIKE %s)")
        params.extend([f'%{search}%'] * 3)
    if topic:
        clauses.append("topic = %s")
        params.append(topic)
    if section:
        clauses.append("section = %s")
        params.append(section)

    where = f"WHERE {' AND '.join(clauses)}" if clauses else ""

    try:
        cur.execute(
            f"""SELECT isbn, title, author, publisher, year, topic, section,
                       price, description, image_url, total_copies, available_copies
                FROM books {where}
                ORDER BY title""",
            params
        )
        return jsonify(cur.fetchall()), 200
    except Exception:
        return jsonify({"error": "Failed to fetch books"}), 500
    finally:
        cur.close()


@app.route('/api/books/search', methods=['GET'])
def search_books_public():
    """Student-facing book search – no auth required."""
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)

    search = request.args.get('q', '').strip()
    topic = request.args.get('topic', '').strip()

    clauses = []
    params = []

    if search:
        clauses.append("(title ILIKE %s OR author ILIKE %s)")
        params.extend([f'%{search}%'] * 2)
    if topic:
        clauses.append("topic = %s")
        params.append(topic)

    where = f"WHERE {' AND '.join(clauses)}" if clauses else ""

    try:
        cur.execute(
            f"""SELECT isbn, title, author, publisher, year, topic, section,
                       price, description, image_url, total_copies, available_copies
                FROM books {where}
                ORDER BY title""",
            params
        )
        books = cur.fetchall()
        return jsonify({"books": books, "total": len(books)}), 200
    except Exception:
        return jsonify({"error": "Failed to search books"}), 500
    finally:
        cur.close()


@app.route('/api/books/<string:isbn>', methods=['GET'])
@token_required
def get_book(isbn):
    """Get a single book by ISBN."""
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)

    try:
        cur.execute(
            """SELECT isbn, title, author, publisher, year, topic, section,
                      price, description, image_url, total_copies, available_copies
               FROM books WHERE isbn = %s""",
            (isbn,)
        )
        book = cur.fetchone()
        if not book:
            return jsonify({"error": "Book not found"}), 404
        return jsonify(book), 200
    except Exception:
        return jsonify({"error": "Failed to fetch book"}), 500
    finally:
        cur.close()


# ── Dashboard ────────────────────────────────────────────────────────────────
@app.route('/api/dashboard', methods=['GET'])
@token_required
@role_required('administrator', 'librarian')
def get_dashboard():
    """Aggregate stats for the admin dashboard."""
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)

    try:
        cur.execute("""
            SELECT
                (SELECT count(*) FROM books)::int                                     AS total_books,
                (SELECT count(*) FROM copies)::int                                    AS total_copies,
                (SELECT count(*) FROM loans WHERE status = 'active')::int             AS active_loans,
                (SELECT count(*) FROM loans WHERE status = 'overdue')::int            AS overdue_books
        """)
        stats = cur.fetchone()

        # Loan trend: loans created per day over the last 7 days
        cur.execute("""
            SELECT d::date AS day, COALESCE(cnt, 0)::int AS count
            FROM generate_series(
                CURRENT_DATE - INTERVAL '6 days', CURRENT_DATE, '1 day'
            ) AS d
            LEFT JOIN (
                SELECT loan_date::date AS ld, count(*)::int AS cnt
                FROM loans
                WHERE loan_date >= CURRENT_DATE - INTERVAL '6 days'
                GROUP BY ld
            ) sub ON sub.ld = d::date
            ORDER BY d
        """)
        trend = [{'day': r['day'].isoformat(), 'count': r['count']} for r in cur.fetchall()]

        # Topic distribution: number of books per topic
        cur.execute("""
            SELECT topic, count(*)::int AS count
            FROM books
            GROUP BY topic
            ORDER BY count DESC
        """)
        topics = [{'topic': r['topic'], 'count': r['count']} for r in cur.fetchall()]

        stats['loan_trend'] = trend
        stats['topic_distribution'] = topics

        return jsonify(stats), 200
    except Exception:
        return jsonify({"error": "Failed to fetch dashboard stats"}), 500
    finally:
        cur.close()


# ── Users CRUD ───────────────────────────────────────────────────────────────
@app.route('/api/users', methods=['POST'])
@token_required
@role_required('administrator')
@validate_json('name', 'email', 'role', 'password')
def create_user():
    data = request.get_json()
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        cur.execute(
            """INSERT INTO users (name, email, role, phone, password_hash)
               VALUES (%s, %s, %s, %s, %s)
               RETURNING id, name, email, role, phone, is_active, created_at""",
            (data['name'], data['email'].strip().lower(), data['role'],
             data.get('phone'), generate_password_hash(data['password']))
        )
        user = cur.fetchone()
        conn.commit()
        user['created_at'] = user['created_at'].isoformat()
        return jsonify(user), 201
    except psycopg2.errors.UniqueViolation:
        conn.rollback()
        return jsonify({"error": "Email already exists"}), 400
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to create user"}), 500
    finally:
        cur.close()


@app.route('/api/users/<string:user_id>', methods=['PUT'])
@token_required
@role_required('administrator')
@validate_json('name', 'email', 'role')
def update_user(user_id):
    data = request.get_json()
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        cur.execute(
            """UPDATE users SET name=%s, email=%s, role=%s, phone=%s
               WHERE id=%s
               RETURNING id, name, email, role, phone, is_active, created_at""",
            (data['name'], data['email'].strip().lower(), data['role'],
             data.get('phone'), user_id)
        )
        user = cur.fetchone()
        if not user:
            return jsonify({"error": "User not found"}), 404
        conn.commit()
        user['created_at'] = user['created_at'].isoformat()
        return jsonify(user), 200
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to update user"}), 500
    finally:
        cur.close()


@app.route('/api/users/<string:user_id>', methods=['DELETE'])
@token_required
@role_required('administrator')
def delete_user(user_id):
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("UPDATE users SET is_active = false WHERE id = %s", (user_id,))
        conn.commit()
        return jsonify({"message": "User deactivated"}), 200
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to deactivate user"}), 500
    finally:
        cur.close()


# ── Books CRUD ───────────────────────────────────────────────────────────────
@app.route('/api/books', methods=['POST'])
@token_required
@role_required('administrator', 'librarian')
@validate_json('isbn', 'title', 'author', 'publisher', 'year', 'topic', 'section', 'price')
def create_book():
    data = request.get_json()
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        cur.execute(
            """INSERT INTO books (isbn,title,author,publisher,year,topic,section,price,description,image_url)
               VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
               RETURNING isbn,title,author,publisher,year,topic,section,price,description,image_url,total_copies,available_copies""",
            (data['isbn'], data['title'], data['author'], data['publisher'],
             data['year'], data['topic'], data['section'], data['price'],
             data.get('description'), data.get('image_url'))
        )
        book = cur.fetchone()
        conn.commit()
        return jsonify(book), 201
    except psycopg2.errors.UniqueViolation:
        conn.rollback()
        return jsonify({"error": "Book with this ISBN already exists"}), 400
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to create book"}), 500
    finally:
        cur.close()


@app.route('/api/books/<string:isbn>', methods=['PUT'])
@token_required
@role_required('administrator', 'librarian')
def update_book(isbn):
    data = request.get_json()
    if not data:
        return jsonify({"error": "Request body must be JSON"}), 400
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        fields, vals = [], []
        for col in ('title','author','publisher','year','topic','section','price','description','image_url'):
            if col in data:
                fields.append(f"{col} = %s")
                vals.append(data[col])
        if not fields:
            return jsonify({"error": "No fields to update"}), 400
        vals.append(isbn)
        cur.execute(
            f"""UPDATE books SET {', '.join(fields)} WHERE isbn = %s
                RETURNING isbn,title,author,publisher,year,topic,section,price,description,image_url,total_copies,available_copies""",
            vals
        )
        book = cur.fetchone()
        if not book:
            return jsonify({"error": "Book not found"}), 404
        conn.commit()
        return jsonify(book), 200
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to update book"}), 500
    finally:
        cur.close()


@app.route('/api/books/<string:isbn>', methods=['DELETE'])
@token_required
@role_required('administrator', 'librarian')
def delete_book(isbn):
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("DELETE FROM books WHERE isbn = %s", (isbn,))
        conn.commit()
        return jsonify({"message": "Book deleted"}), 200
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to delete book"}), 500
    finally:
        cur.close()


# ── Copies ───────────────────────────────────────────────────────────────────
@app.route('/api/copies', methods=['GET'])
@token_required
def get_copies():
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    isbn_filter = request.args.get('isbn', '').strip()
    status_filter = request.args.get('status', '').strip()
    clauses, params = [], []
    if isbn_filter:
        clauses.append("isbn = %s"); params.append(isbn_filter)
    if status_filter:
        clauses.append("status = %s"); params.append(status_filter)
    where = f"WHERE {' AND '.join(clauses)}" if clauses else ""
    try:
        cur.execute(f"SELECT * FROM v_copies {where} ORDER BY id", params)
        rows = cur.fetchall()
        for r in rows:
            if r.get('acquisition_date'):
                r['acquisition_date'] = r['acquisition_date'].isoformat()
        return jsonify(rows), 200
    except Exception:
        return jsonify({"error": "Failed to fetch copies"}), 500
    finally:
        cur.close()


@app.route('/api/copies', methods=['POST'])
@token_required
@role_required('administrator', 'librarian')
@validate_json('isbn', 'location', 'condition')
def create_copy():
    data = request.get_json()
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        cur.execute(
            """INSERT INTO copies (isbn, location, condition, notes)
               VALUES (%s,%s,%s,%s) RETURNING id""",
            (data['isbn'], data['location'], data['condition'], data.get('notes'))
        )
        copy_id = cur.fetchone()['id']
        # Update book counts
        cur.execute(
            "UPDATE books SET total_copies = total_copies+1, available_copies = available_copies+1 WHERE isbn = %s",
            (data['isbn'],)
        )
        conn.commit()
        cur.execute("SELECT * FROM v_copies WHERE id = %s", (copy_id,))
        row = cur.fetchone()
        if row.get('acquisition_date'):
            row['acquisition_date'] = row['acquisition_date'].isoformat()
        return jsonify(row), 201
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to create copy"}), 500
    finally:
        cur.close()


@app.route('/api/copies/<string:copy_id>', methods=['GET'])
@token_required
def get_copy(copy_id):
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        cur.execute("SELECT * FROM v_copies WHERE id = %s", (copy_id,))
        row = cur.fetchone()
        if not row:
            return jsonify({"error": "Copy not found"}), 404
        if row.get('acquisition_date'):
            row['acquisition_date'] = row['acquisition_date'].isoformat()
        return jsonify(row), 200
    except Exception:
        return jsonify({"error": "Failed to fetch copy"}), 500
    finally:
        cur.close()


# ── Loans ────────────────────────────────────────────────────────────────────
@app.route('/api/loans', methods=['GET'])
@token_required
def get_loans():
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    status_filter = request.args.get('status', '').strip()
    user_filter = request.args.get('user_id', '').strip()
    clauses, params = [], []
    if status_filter:
        clauses.append("status = %s"); params.append(status_filter)
    if user_filter:
        clauses.append("user_id = %s"); params.append(user_filter)
    where = f"WHERE {' AND '.join(clauses)}" if clauses else ""
    try:
        cur.execute(f"SELECT * FROM v_loans {where} ORDER BY loan_date DESC", params)
        rows = cur.fetchall()
        for r in rows:
            for col in ('loan_date','due_date','return_date'):
                if r.get(col):
                    r[col] = r[col].isoformat()
        return jsonify(rows), 200
    except Exception:
        return jsonify({"error": "Failed to fetch loans"}), 500
    finally:
        cur.close()


@app.route('/api/loans', methods=['POST'])
@token_required
@role_required('administrator', 'librarian')
@validate_json('user_id', 'copy_id')
def create_loan():
    data = request.get_json()
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        due = data.get('due_date')
        if not due:
            due = (datetime.now(timezone.utc) + timedelta(days=14)).isoformat()
        cur.execute(
            """INSERT INTO loans (user_id, copy_id, due_date)
               VALUES (%s,%s,%s) RETURNING id""",
            (data['user_id'], data['copy_id'], due)
        )
        loan_id = cur.fetchone()['id']
        cur.execute("UPDATE copies SET status='borrowed' WHERE id=%s", (data['copy_id'],))
        cur.execute(
            "UPDATE books SET available_copies = available_copies-1 WHERE isbn = (SELECT isbn FROM copies WHERE id=%s)",
            (data['copy_id'],)
        )
        conn.commit()
        cur.execute("SELECT * FROM v_loans WHERE id = %s", (loan_id,))
        row = cur.fetchone()
        for col in ('loan_date','due_date','return_date'):
            if row.get(col):
                row[col] = row[col].isoformat()
        return jsonify(row), 201
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to create loan"}), 500
    finally:
        cur.close()


@app.route('/api/loans/<string:loan_id>', methods=['GET'])
@token_required
def get_loan(loan_id):
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        cur.execute("SELECT * FROM v_loans WHERE id = %s", (loan_id,))
        row = cur.fetchone()
        if not row:
            return jsonify({"error": "Loan not found"}), 404
        for col in ('loan_date','due_date','return_date'):
            if row.get(col):
                row[col] = row[col].isoformat()
        return jsonify(row), 200
    except Exception:
        return jsonify({"error": "Failed to fetch loan"}), 500
    finally:
        cur.close()


@app.route('/api/loans/<string:loan_id>/return', methods=['POST'])
@token_required
@role_required('administrator', 'librarian')
def return_loan(loan_id):
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        now = datetime.now(timezone.utc)
        cur.execute("SELECT id, copy_id, due_date, status FROM loans WHERE id=%s", (loan_id,))
        loan = cur.fetchone()
        if not loan:
            return jsonify({"error": "Loan not found"}), 404
        if loan['status'] == 'returned':
            return jsonify({"error": "Already returned"}), 400

        cur.execute(
            "UPDATE loans SET status='returned', return_date=%s WHERE id=%s",
            (now, loan_id)
        )
        cur.execute("UPDATE copies SET status='available' WHERE id=%s", (loan['copy_id'],))
        cur.execute(
            "UPDATE books SET available_copies=available_copies+1 WHERE isbn=(SELECT isbn FROM copies WHERE id=%s)",
            (loan['copy_id'],)
        )

        fine_row = None
        if now > loan['due_date']:
            days = (now - loan['due_date']).days
            amount = days * 10.0
            cur.execute(
                """INSERT INTO fines (user_id, loan_id, days_overdue, amount)
                   VALUES ((SELECT user_id FROM loans WHERE id=%s), %s, %s, %s)
                   RETURNING id""",
                (loan_id, loan_id, days, amount)
            )
            fine_id = cur.fetchone()['id']
            cur.execute("UPDATE loans SET fine=%s WHERE id=%s", (amount, loan_id))
            conn.commit()
            cur.execute("SELECT * FROM v_fines WHERE id=%s", (fine_id,))
            fine_row = cur.fetchone()
            for c in ('created_at','paid_at'):
                if fine_row.get(c):
                    fine_row[c] = fine_row[c].isoformat()
        else:
            conn.commit()

        cur.execute("SELECT * FROM v_loans WHERE id=%s", (loan_id,))
        loan_row = cur.fetchone()
        for c in ('loan_date','due_date','return_date'):
            if loan_row.get(c):
                loan_row[c] = loan_row[c].isoformat()

        return jsonify({"loan": loan_row, "fine": fine_row}), 200
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to return loan"}), 500
    finally:
        cur.close()


@app.route('/api/loans/<string:loan_id>/renew', methods=['POST'])
@token_required
def renew_loan(loan_id):
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        cur.execute("SELECT id, status, renewal_count, due_date FROM loans WHERE id=%s", (loan_id,))
        loan = cur.fetchone()
        if not loan:
            return jsonify({"error": "Loan not found"}), 404
        if loan['status'] != 'active':
            return jsonify({"error": "Only active loans can be renewed"}), 400
        if loan['renewal_count'] >= 2:
            return jsonify({"error": "Max renewals reached"}), 400
        new_due = loan['due_date'] + timedelta(days=14)
        cur.execute(
            "UPDATE loans SET due_date=%s, renewal_count=renewal_count+1 WHERE id=%s",
            (new_due, loan_id)
        )
        conn.commit()
        cur.execute("SELECT * FROM v_loans WHERE id=%s", (loan_id,))
        row = cur.fetchone()
        for c in ('loan_date','due_date','return_date'):
            if row.get(c):
                row[c] = row[c].isoformat()
        return jsonify(row), 200
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to renew loan"}), 500
    finally:
        cur.close()


# ── Fines ────────────────────────────────────────────────────────────────────
@app.route('/api/fines', methods=['GET'])
@token_required
def get_fines():
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    status_filter = request.args.get('status', '').strip()
    user_filter = request.args.get('user_id', '').strip()
    clauses, params = [], []
    if status_filter:
        clauses.append("status = %s"); params.append(status_filter)
    if user_filter:
        clauses.append("user_id = %s"); params.append(user_filter)
    where = f"WHERE {' AND '.join(clauses)}" if clauses else ""
    try:
        cur.execute(f"SELECT * FROM v_fines {where} ORDER BY created_at DESC", params)
        rows = cur.fetchall()
        for r in rows:
            for c in ('created_at','paid_at'):
                if r.get(c):
                    r[c] = r[c].isoformat()
        return jsonify(rows), 200
    except Exception:
        return jsonify({"error": "Failed to fetch fines"}), 500
    finally:
        cur.close()


@app.route('/api/fines/<string:fine_id>/pay', methods=['POST'])
@token_required
@role_required('administrator', 'librarian')
def pay_fine(fine_id):
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        now = datetime.now(timezone.utc)
        cur.execute(
            "UPDATE fines SET status='paid', paid_at=%s WHERE id=%s AND status='pending' RETURNING id",
            (now, fine_id)
        )
        row = cur.fetchone()
        if not row:
            return jsonify({"error": "Fine not found or already paid"}), 404
        conn.commit()
        cur.execute("SELECT * FROM v_fines WHERE id=%s", (fine_id,))
        fine = cur.fetchone()
        for c in ('created_at','paid_at'):
            if fine.get(c):
                fine[c] = fine[c].isoformat()
        return jsonify(fine), 200
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to pay fine"}), 500
    finally:
        cur.close()


# ── Waitlist ─────────────────────────────────────────────────────────────────
@app.route('/api/waitlist', methods=['GET'])
@token_required
def get_waitlist():
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    isbn_filter = request.args.get('book_isbn', '').strip()
    clauses, params = [], []
    if isbn_filter:
        clauses.append("book_isbn = %s"); params.append(isbn_filter)
    where = f"WHERE {' AND '.join(clauses)}" if clauses else ""
    try:
        cur.execute(f"SELECT * FROM v_waitlist {where} ORDER BY position", params)
        rows = cur.fetchall()
        for r in rows:
            if r.get('request_date'):
                r['request_date'] = r['request_date'].isoformat()
        return jsonify(rows), 200
    except Exception:
        return jsonify({"error": "Failed to fetch waitlist"}), 500
    finally:
        cur.close()


@app.route('/api/waitlist', methods=['POST'])
@token_required
@validate_json('book_isbn', 'user_id')
def create_waitlist():
    data = request.get_json()
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        cur.execute("SELECT COALESCE(MAX(position),0)+1 AS pos FROM waitlist WHERE book_isbn=%s",
                     (data['book_isbn'],))
        pos = cur.fetchone()['pos']
        cur.execute(
            """INSERT INTO waitlist (book_isbn, user_id, position)
               VALUES (%s,%s,%s) RETURNING id""",
            (data['book_isbn'], data['user_id'], pos)
        )
        wid = cur.fetchone()['id']
        conn.commit()
        cur.execute("SELECT * FROM v_waitlist WHERE id=%s", (wid,))
        row = cur.fetchone()
        if row.get('request_date'):
            row['request_date'] = row['request_date'].isoformat()
        return jsonify(row), 201
    except psycopg2.errors.UniqueViolation:
        conn.rollback()
        return jsonify({"error": "User already on waitlist for this book"}), 400
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to add to waitlist"}), 500
    finally:
        cur.close()


@app.route('/api/waitlist/<string:entry_id>', methods=['DELETE'])
@token_required
def delete_waitlist(entry_id):
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("DELETE FROM waitlist WHERE id=%s", (entry_id,))
        conn.commit()
        return jsonify({"message": "Removed from waitlist"}), 200
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to remove from waitlist"}), 500
    finally:
        cur.close()


# ── Purchases ────────────────────────────────────────────────────────────────
@app.route('/api/purchases', methods=['GET'])
@token_required
def get_purchases():
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    status_filter = request.args.get('status', '').strip()
    clauses, params = [], []
    if status_filter:
        clauses.append("pr.status::text = %s"); params.append(status_filter)
    where = f"WHERE {' AND '.join(clauses)}" if clauses else ""
    try:
        cur.execute(f"""SELECT pr.id, pr.isbn, pr.book_title, pr.author,
                               req.name AS requested_by, pr.quantity, pr.unit_price,
                               pr.total, pr.justification, pr.status::text AS status,
                               pr.created_at, rev.name AS reviewed_by, pr.review_notes
                        FROM purchase_requests pr
                        JOIN users req ON req.id = pr.requested_by
                        LEFT JOIN users rev ON rev.id = pr.reviewed_by
                        {where} ORDER BY pr.created_at DESC""", params)
        rows = cur.fetchall()
        for r in rows:
            if r.get('created_at'):
                r['created_at'] = r['created_at'].isoformat()
        return jsonify(rows), 200
    except Exception:
        return jsonify({"error": "Failed to fetch purchases"}), 500
    finally:
        cur.close()


@app.route('/api/purchases', methods=['POST'])
@token_required
@validate_json('isbn', 'book_title', 'author', 'quantity', 'unit_price', 'justification')
def create_purchase():
    data = request.get_json()
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        cur.execute(
            """INSERT INTO purchase_requests (isbn,book_title,author,requested_by,quantity,unit_price,justification)
               VALUES (%s,%s,%s,%s,%s,%s,%s) RETURNING id""",
            (data['isbn'], data['book_title'], data['author'],
             g.current_user['sub'], data['quantity'], data['unit_price'], data['justification'])
        )
        pid = cur.fetchone()['id']
        conn.commit()
        cur.execute("SELECT * FROM v_purchase_requests WHERE id=%s", (pid,))
        row = cur.fetchone()
        if row.get('created_at'):
            row['created_at'] = row['created_at'].isoformat()
        return jsonify(row), 201
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to create purchase request"}), 500
    finally:
        cur.close()


@app.route('/api/purchases/<string:purchase_id>', methods=['GET'])
@token_required
def get_purchase(purchase_id):
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        cur.execute("SELECT * FROM v_purchase_requests WHERE id=%s", (purchase_id,))
        row = cur.fetchone()
        if not row:
            return jsonify({"error": "Purchase request not found"}), 404
        if row.get('created_at'):
            row['created_at'] = row['created_at'].isoformat()
        return jsonify(row), 200
    except Exception:
        return jsonify({"error": "Failed to fetch purchase request"}), 500
    finally:
        cur.close()


@app.route('/api/purchases/<string:purchase_id>/review', methods=['POST'])
@token_required
@role_required('administrator')
@validate_json('status', 'review_notes')
def review_purchase(purchase_id):
    data = request.get_json()
    if data['status'] not in ('approved', 'rejected'):
        return jsonify({"error": "Status must be 'approved' or 'rejected'"}), 400
    conn = get_db()
    cur = conn.cursor(cursor_factory=RealDictCursor)
    try:
        cur.execute(
            """UPDATE purchase_requests SET status=%s, reviewed_by=%s, review_notes=%s
               WHERE id=%s AND status='pending' RETURNING id""",
            (data['status'], g.current_user['sub'], data['review_notes'], purchase_id)
        )
        row = cur.fetchone()
        if not row:
            return jsonify({"error": "Purchase request not found or already reviewed"}), 404
        conn.commit()
        cur.execute("SELECT * FROM v_purchase_requests WHERE id=%s", (purchase_id,))
        pr = cur.fetchone()
        if pr.get('created_at'):
            pr['created_at'] = pr['created_at'].isoformat()
        return jsonify(pr), 200
    except Exception:
        conn.rollback()
        return jsonify({"error": "Failed to review purchase request"}), 500
    finally:
        cur.close()


# ─────────────────────────────────────────────────────────────────────────────
# Error handlers  (api-security: sanitize error messages)
# ─────────────────────────────────────────────────────────────────────────────
@app.errorhandler(404)
def not_found(_):
    return jsonify({"error": "Resource not found"}), 404


@app.errorhandler(500)
def server_error(_):
    return jsonify({"error": "Internal server error"}), 500


# ─────────────────────────────────────────────────────────────────────────────
# Entrypoint
# ─────────────────────────────────────────────────────────────────────────────
if __name__ == '__main__':
    app.run(debug=True, port=5000)