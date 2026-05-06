# seed.py – Populate the Ducky Library database with realistic sample data.
# Run once:  python seed.py
# Re-run is safe — uses ON CONFLICT DO NOTHING for all inserts.
import os
import psycopg2
from datetime import datetime, timedelta
from werkzeug.security import generate_password_hash
from dotenv import load_dotenv

load_dotenv()

conn = psycopg2.connect(
    host=os.environ['DB_HOST'],
    database=os.environ['DB_NAME'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    sslmode='require',
)
cur = conn.cursor()

# ═══════════════════════════════════════════════════════════════════════════════
# 1. USERS
# ═══════════════════════════════════════════════════════════════════════════════
users = [
    ('admin-001', 'Director Admin',      'admin@ducky.edu',           'administrator', generate_password_hash('admin'),     '5551000001'),
    ('admin-002', 'Sub Director',         'subadmin@ducky.edu',       'administrator', generate_password_hash('admin'),     '5551000002'),
    ('lib-001',   'Elena Vargas',         'e.vargas@ducky.edu',       'librarian',     generate_password_hash('biblio'),    '5552000001'),
    ('lib-002',   'Marco Reyes',          'm.reyes@ducky.edu',        'librarian',     generate_password_hash('biblio'),    '5552000002'),
    ('stu-001',   'Carlos Hernandez',     'carlos.hernandez@ducky.edu','student',      generate_password_hash('alumno'),    '5553000001'),
    ('stu-002',   'Ana Martinez',         'ana.martinez@ducky.edu',   'student',       generate_password_hash('alumno'),    '5553000002'),
    ('stu-003',   'Pedro Ramirez',        'pedro.ramirez@ducky.edu',  'student',       generate_password_hash('alumno'),    '5553000003'),
    ('stu-004',   'Maria Lopez',          'maria.lopez@ducky.edu',    'student',       generate_password_hash('alumno'),    '5553000004'),
    ('stu-005',   'Jorge Diaz',           'jorge.diaz@ducky.edu',     'student',       generate_password_hash('alumno'),    '5553000005'),
    ('pro-001',   'Dr. Sofia Torres',     's.torres@ducky.edu',       'professor',     generate_password_hash('profesor'),  '5554000001'),
    ('pro-002',   'Dr. Luis Morales',     'l.morales@ducky.edu',      'professor',     generate_password_hash('profesor'),  '5554000002'),
]

for uid, name, email, role, pw_hash, phone in users:
    cur.execute(
        """INSERT INTO users (id, name, email, role, password_hash, phone)
           VALUES (%s, %s, %s, %s, %s, %s)
           ON CONFLICT (id) DO NOTHING""",
        (uid, name, email, role, pw_hash, phone),
    )
print(f"  [OK] Seeded {len(users)} users")

# ═══════════════════════════════════════════════════════════════════════════════
# 2. BOOKS
# ═══════════════════════════════════════════════════════════════════════════════
books = [
    # (isbn, title, author, publisher, year, topic, section, price, description, total_copies, available_copies)
    ('978-0-13-468599-1', 'Operating System Concepts', 'Abraham Silberschatz', 'Wiley', 2018, 'Sistemas Operativos', 'Computacion', 89.99,
     'Texto clasico para cursos de sistemas operativos, cubriendo procesos, hilos, sincronizacion, memoria y almacenamiento.', 5, 3),
    ('978-0-13-277227-2', 'Modern Operating Systems', 'Andrew S. Tanenbaum', 'Pearson', 2014, 'Sistemas Operativos', 'Computacion', 79.50,
     'Enfoque moderno a sistemas operativos con ejemplos en Linux y Windows.', 4, 2),
    ('978-0-32-157351-3', 'Computer Networking: A Top-Down Approach', 'James Kurose', 'Pearson', 2016, 'Redes', 'Computacion', 95.00,
     'Libro referente para cursos de redes con enfoque top-down.', 3, 1),
    ('978-0-59-651798-4', 'JavaScript: The Good Parts', 'Douglas Crockford', 'OReilly', 2008, 'Programacion', 'Computacion', 29.99,
     'Guia concisa sobre las mejores caracteristicas de JavaScript.', 6, 5),
    ('978-0-20-161622-4', 'The Pragmatic Programmer', 'David Thomas', 'Addison-Wesley', 2019, 'Ingenieria de Software', 'Computacion', 49.95,
     'Consejos practicos para el desarrollo de software profesional.', 4, 3),
    ('978-0-13-235088-4', 'Clean Code', 'Robert C. Martin', 'Prentice Hall', 2008, 'Ingenieria de Software', 'Computacion', 39.99,
     'Principios y patrones para escribir codigo limpio y mantenible.', 5, 4),
    ('978-0-59-651797-7', 'Learning Python', 'Mark Lutz', 'OReilly', 2013, 'Programacion', 'Computacion', 59.99,
     'Guia completa para aprender Python desde cero.', 3, 2),
    ('978-0-26-203384-8', 'Introduction to Algorithms', 'Thomas H. Cormen', 'MIT Press', 2009, 'Algoritmos', 'Computacion', 85.00,
     'El libro de referencia para el estudio de algoritmos y estructuras de datos.', 4, 2),
    ('978-0-13-468588-5', 'Database System Concepts', 'Abraham Silberschatz', 'McGraw-Hill', 2019, 'Bases de Datos', 'Computacion', 74.50,
     'Fundamentos de sistemas de bases de datos relacionales y NoSQL.', 3, 1),
    ('978-0-32-112521-7', 'Domain-Driven Design', 'Eric Evans', 'Addison-Wesley', 2003, 'Ingenieria de Software', 'Computacion', 54.99,
     'Diseno de software complejo guiado por el dominio del negocio.', 2, 1),
    ('978-0-13-211099-5', 'Computer Organization and Design', 'David A. Patterson', 'Morgan Kaufmann', 2013, 'Arquitectura', 'Computacion', 72.00,
     'Hardware/software interface con enfoque ARM y RISC-V.', 3, 2),
    ('978-1-49-195016-0', 'Designing Data-Intensive Applications', 'Martin Kleppmann', 'OReilly', 2017, 'Bases de Datos', 'Computacion', 44.99,
     'Principios para disenar sistemas de datos escalables y confiables.', 2, 1),
]

for isbn, title, author, publisher, year, topic, section, price, desc, total, avail in books:
    cur.execute(
        """INSERT INTO books (isbn, title, author, publisher, year, topic, section, price, description, total_copies, available_copies)
           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
           ON CONFLICT (isbn) DO NOTHING""",
        (isbn, title, author, publisher, year, topic, section, price, desc, total, avail),
    )
print(f"  [OK] Seeded {len(books)} books")

# ═══════════════════════════════════════════════════════════════════════════════
# 3. COPIES
# ═══════════════════════════════════════════════════════════════════════════════
copies = [
    # (id, isbn, status, location, condition)
    ('C001', '978-0-13-468599-1', 'available',  'Estante A, Repisa 1', 'Buena'),
    ('C002', '978-0-13-468599-1', 'borrowed',   'Estante A, Repisa 1', 'Buena'),
    ('C003', '978-0-13-468599-1', 'available',   'Estante A, Repisa 2', 'Regular'),
    ('C004', '978-0-13-468599-1', 'available',  'Bodega Central',      'Nueva'),
    ('C005', '978-0-13-468599-1', 'borrowed',   'Estante A, Repisa 1', 'Buena'),
    ('C006', '978-0-13-277227-2', 'available',  'Estante A, Repisa 3', 'Buena'),
    ('C007', '978-0-13-277227-2', 'borrowed',   'Estante A, Repisa 3', 'Regular'),
    ('C008', '978-0-13-277227-2', 'available',  'Estante A, Repisa 3', 'Buena'),
    ('C009', '978-0-13-277227-2', 'reserved',   'Estante A, Repisa 4', 'Nueva'),
    ('C010', '978-0-32-157351-3', 'available',  'Estante B, Repisa 1', 'Buena'),
    ('C011', '978-0-32-157351-3', 'borrowed',   'Estante B, Repisa 1', 'Regular'),
    ('C012', '978-0-32-157351-3', 'borrowed',   'Estante B, Repisa 2', 'Buena'),
    ('C013', '978-0-59-651798-4', 'available',  'Estante C, Repisa 1', 'Buena'),
    ('C014', '978-0-59-651798-4', 'available',  'Estante C, Repisa 1', 'Buena'),
    ('C015', '978-0-59-651798-4', 'available',  'Estante C, Repisa 2', 'Nueva'),
    ('C016', '978-0-59-651798-4', 'available',  'Estante C, Repisa 2', 'Regular'),
    ('C017', '978-0-59-651798-4', 'available',  'Bodega Central',      'Buena'),
    ('C018', '978-0-59-651798-4', 'borrowed',   'Estante C, Repisa 1', 'Buena'),
    ('C019', '978-0-20-161622-4', 'available',  'Estante D, Repisa 1', 'Buena'),
    ('C020', '978-0-20-161622-4', 'available',  'Estante D, Repisa 1', 'Nueva'),
    ('C021', '978-0-20-161622-4', 'available',  'Estante D, Repisa 2', 'Buena'),
    ('C022', '978-0-20-161622-4', 'borrowed',   'Estante D, Repisa 2', 'Regular'),
    ('C023', '978-0-13-235088-4', 'available',  'Estante E, Repisa 1', 'Buena'),
    ('C024', '978-0-13-235088-4', 'available',  'Estante E, Repisa 1', 'Nueva'),
    ('C025', '978-0-13-235088-4', 'available',  'Estante E, Repisa 2', 'Buena'),
    ('C026', '978-0-13-235088-4', 'available',  'Estante E, Repisa 2', 'Buena'),
    ('C027', '978-0-13-235088-4', 'borrowed',   'Estante E, Repisa 3', 'Regular'),
    ('C028', '978-0-59-651797-7', 'available',  'Estante F, Repisa 1', 'Buena'),
    ('C029', '978-0-59-651797-7', 'available',  'Estante F, Repisa 1', 'Nueva'),
    ('C030', '978-0-59-651797-7', 'borrowed',   'Estante F, Repisa 2', 'Buena'),
    ('C031', '978-0-26-203384-8', 'available',  'Estante G, Repisa 1', 'Buena'),
    ('C032', '978-0-26-203384-8', 'borrowed',   'Estante G, Repisa 1', 'Regular'),
    ('C033', '978-0-26-203384-8', 'available',  'Estante G, Repisa 2', 'Buena'),
    ('C034', '978-0-26-203384-8', 'reserved',   'Estante G, Repisa 2', 'Nueva'),
    ('C035', '978-0-13-468588-5', 'available',  'Estante H, Repisa 1', 'Buena'),
    ('C036', '978-0-13-468588-5', 'borrowed',   'Estante H, Repisa 1', 'Regular'),
    ('C037', '978-0-13-468588-5', 'borrowed',   'Estante H, Repisa 2', 'Buena'),
    ('C038', '978-0-32-112521-7', 'available',  'Estante I, Repisa 1', 'Buena'),
    ('C039', '978-0-32-112521-7', 'borrowed',   'Estante I, Repisa 1', 'Regular'),
    ('C040', '978-0-13-211099-5', 'available',  'Estante J, Repisa 1', 'Buena'),
    ('C041', '978-0-13-211099-5', 'available',  'Estante J, Repisa 1', 'Nueva'),
    ('C042', '978-0-13-211099-5', 'borrowed',   'Estante J, Repisa 2', 'Buena'),
    ('C043', '978-1-49-195016-0', 'available',  'Estante K, Repisa 1', 'Buena'),
    ('C044', '978-1-49-195016-0', 'borrowed',   'Estante K, Repisa 1', 'Regular'),
]

for cid, isbn, status, location, condition in copies:
    cur.execute(
        """INSERT INTO copies (id, isbn, status, location, condition)
           VALUES (%s, %s, %s, %s, %s)
           ON CONFLICT (id) DO NOTHING""",
        (cid, isbn, status, location, condition),
    )
print(f"  [OK] Seeded {len(copies)} copies")

# ═══════════════════════════════════════════════════════════════════════════════
# 4. LOANS
# ═══════════════════════════════════════════════════════════════════════════════
now = datetime.now()
loans = [
    # (id, user_id, copy_id, loan_date, due_date, return_date, status, fine, renewal_count)
    ('LOAN-001', 'stu-001', 'C002', now - timedelta(days=5),  now + timedelta(days=9),  None,                       'active',   None, 0),
    ('LOAN-002', 'stu-002', 'C005', now - timedelta(days=10), now + timedelta(days=4),  None,                       'active',   None, 0),
    ('LOAN-003', 'stu-003', 'C007', now - timedelta(days=18), now - timedelta(days=4),  None,                       'overdue',  40.0, 0),
    ('LOAN-004', 'stu-004', 'C011', now - timedelta(days=7),  now + timedelta(days=7),  None,                       'active',   None, 0),
    ('LOAN-005', 'stu-005', 'C012', now - timedelta(days=20), now - timedelta(days=6),  None,                       'overdue',  60.0, 0),
    ('LOAN-006', 'pro-001', 'C018', now - timedelta(days=3),  now + timedelta(days=11), None,                       'active',   None, 0),
    ('LOAN-007', 'pro-002', 'C022', now - timedelta(days=12), now + timedelta(days=2),  None,                       'active',   None, 1),
    ('LOAN-008', 'stu-001', 'C027', now - timedelta(days=6),  now + timedelta(days=8),  None,                       'active',   None, 0),
    ('LOAN-009', 'stu-002', 'C030', now - timedelta(days=25), now - timedelta(days=11), now - timedelta(days=8),    'returned', 30.0, 0),
    ('LOAN-010', 'stu-003', 'C032', now - timedelta(days=4),  now + timedelta(days=10), None,                       'active',   None, 0),
    ('LOAN-011', 'pro-001', 'C036', now - timedelta(days=15), now - timedelta(days=1),  None,                       'overdue',  10.0, 0),
    ('LOAN-012', 'stu-004', 'C037', now - timedelta(days=8),  now + timedelta(days=6),  None,                       'active',   None, 0),
    ('LOAN-013', 'stu-005', 'C039', now - timedelta(days=30), now - timedelta(days=16), now - timedelta(days=14),   'returned', None, 0),
    ('LOAN-014', 'pro-002', 'C042', now - timedelta(days=2),  now + timedelta(days=12), None,                       'active',   None, 0),
    ('LOAN-015', 'stu-001', 'C044', now - timedelta(days=9),  now + timedelta(days=5),  None,                       'active',   None, 0),
]

for lid, uid, cid, ld, dd, rd, status, fine, rc in loans:
    cur.execute(
        """INSERT INTO loans (id, user_id, copy_id, loan_date, due_date, return_date, status, fine, renewal_count)
           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
           ON CONFLICT (id) DO NOTHING""",
        (lid, uid, cid, ld, dd, rd, status, fine, rc),
    )
print(f"  [OK] Seeded {len(loans)} loans")

# ═══════════════════════════════════════════════════════════════════════════════
# 5. FINES
# ═══════════════════════════════════════════════════════════════════════════════
fines = [
    # (id, user_id, loan_id, days_overdue, amount, status, created_at, paid_at)
    ('FINE-001', 'stu-003', 'LOAN-003', 4,  40.0,  'pending', now - timedelta(days=4),  None),
    ('FINE-002', 'stu-005', 'LOAN-005', 6,  60.0,  'pending', now - timedelta(days=6),  None),
    ('FINE-003', 'stu-002', 'LOAN-009', 3,  30.0,  'paid',    now - timedelta(days=11), now - timedelta(days=8)),
    ('FINE-004', 'pro-001', 'LOAN-011', 1,  10.0,  'pending', now - timedelta(days=1),  None),
]

for fid, uid, lid, days, amount, status, created, paid in fines:
    cur.execute(
        """INSERT INTO fines (id, user_id, loan_id, days_overdue, amount, status, created_at, paid_at)
           VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
           ON CONFLICT (id) DO NOTHING""",
        (fid, uid, lid, days, amount, status, created, paid),
    )
print(f"  [OK] Seeded {len(fines)} fines")

# ═══════════════════════════════════════════════════════════════════════════════
# 6. WAITLIST
# ═══════════════════════════════════════════════════════════════════════════════
waitlist = [
    # (id, book_isbn, user_id, position)
    ('WL-001', '978-0-32-157351-3', 'stu-004', 1),
    ('WL-002', '978-0-32-157351-3', 'stu-005', 2),
    ('WL-003', '978-0-13-468588-5', 'stu-001', 1),
    ('WL-004', '978-0-32-112521-7', 'pro-002', 1),
    ('WL-005', '978-1-49-195016-0', 'stu-003', 1),
]

for wid, isbn, uid, pos in waitlist:
    cur.execute(
        """INSERT INTO waitlist (id, book_isbn, user_id, position)
           VALUES (%s, %s, %s, %s)
           ON CONFLICT (id) DO NOTHING""",
        (wid, isbn, uid, pos),
    )
print(f"  [OK] Seeded {len(waitlist)} waitlist entries")

# ═══════════════════════════════════════════════════════════════════════════════
# 7. PURCHASE REQUESTS
# ═══════════════════════════════════════════════════════════════════════════════
purchases = [
    # (id, isbn, book_title, author, requested_by, quantity, unit_price, justification, status, reviewed_by, review_notes)
    ('PUR-001', '978-0-13-468599-1', 'Operating System Concepts',        'Abraham Silberschatz', 'lib-001', 3, 89.99, 'Alta demanda en cursos de SO - lista de espera con 5 alumnos.',                   'approved',   'admin-001', 'Aprobado - presupuesto disponible'),
    ('PUR-002', '978-0-59-651798-4', 'JavaScript: The Good Parts',        'Douglas Crockford',   'lib-002', 2, 29.99, 'Reposicion de ejemplares danados en el semestre anterior.',                        'pending',    None,        None),
    ('PUR-003', '978-0-99-999999-9', 'Artificial Intelligence: A Modern Approach', 'Stuart Russell', 'pro-001', 4, 120.00, 'Nuevo curso de IA requiere material de referencia para laboratorio.',     'pending',    None,        None),
    ('PUR-004', '978-0-13-277227-2', 'Modern Operating Systems',          'Andrew S. Tanenbaum',  'lib-001', 2, 79.50, 'Complementar acervo para el parcial 3 de SO.',                                    'rejected',   'admin-001', 'Presupuesto agotado para este trimestre'),
    ('PUR-005', '978-0-26-203384-8', 'Introduction to Algorithms',        'Thomas H. Cormen',    'pro-002', 3, 85.00, 'Curso avanzado de algoritmos necesita mas copias para practicas.',                 'purchased',  'admin-001', 'Compra realizada - lote recibido el 15/04'),
]

for pid, isbn, title, author, req_by, qty, price, just, status, rev_by, rev_notes in purchases:
    cur.execute(
        """INSERT INTO purchase_requests (id, isbn, book_title, author, requested_by, quantity, unit_price, justification, status, reviewed_by, review_notes)
           VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
           ON CONFLICT (id) DO NOTHING""",
        (pid, isbn, title, author, req_by, qty, price, just, status, rev_by, rev_notes),
    )
print(f"  [OK] Seeded {len(purchases)} purchase requests")

# ═══════════════════════════════════════════════════════════════════════════════
conn.commit()
cur.close()
conn.close()
print("\n[DONE] Full seed complete.")
