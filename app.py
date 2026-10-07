from flask import Flask, render_template, jsonify, request, session
import mysql.connector
from mysql.connector import Error
from werkzeug.security import check_password_hash, generate_password_hash
import os

app = Flask(__name__)
app.secret_key = os.environ.get("FLASK_SECRET_KEY")
if not app.secret_key:
    raise RuntimeError("Set FLASK_SECRET_KEY to a random value before starting the app.")
app.config.update(
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE="Lax",
    SESSION_COOKIE_SECURE=os.environ.get("FLASK_COOKIE_SECURE") == "1",
)

DB_CONFIG = {
    "host": os.environ.get("DB_HOST", "localhost"),
    "port": int(os.environ.get("DB_PORT", "3306")),
    "database": os.environ.get("DB_NAME", "campus_event_club_db"),
    "user": os.environ.get("DB_USER", "root"),
    "password": os.environ.get("DB_PASSWORD", ""),
}

def get_db_connection():
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

# --- AUTH ROUTES ---
@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return jsonify({"error": "A JSON object is required"}), 400
    email = data.get('email')
    password = data.get('password')
    if not isinstance(email, str) or not isinstance(password, str) or not email or not password:
        return jsonify({"error": "Email and password are required"}), 400

    conn = get_db_connection()
    if not conn: return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT student_id, password_hash, first_name FROM student WHERE email = %s", (email,))
        user = cursor.fetchone()

        if user and user["password_hash"] and check_password_hash(user["password_hash"], password):
            session.clear()
            session['student_id'] = user['student_id']
            session['first_name'] = user['first_name']
            return jsonify({"message": f"Welcome back, {user['first_name']}!"})
        else:
            return jsonify({"error": "Invalid email or password"}), 401
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

@app.route('/api/logout', methods=['POST'])
def logout():
    session.clear()
    return jsonify({"message": "Logged out successfully"})

@app.route('/api/me', methods=['GET'])
def me():
    if 'student_id' not in session:
        return jsonify({"authenticated": False})
    return jsonify({
        "authenticated": True,
        "student_id": session['student_id'],
        "first_name": session['first_name']
    })

# --- EVENT ROUTES ---
@app.route('/api/events', methods=['GET'])
def get_events():
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM vw_upcoming_events")
        events = cursor.fetchall()

        # If user is logged in, attach their registration status
        registered_events = []
        if 'student_id' in session:
            cursor.execute("SELECT event_id FROM event_registration WHERE student_id = %s", (session['student_id'],))
            registered_events = [row['event_id'] for row in cursor.fetchall()]

        for event in events:
            event['is_registered'] = event['event_id'] in registered_events

        return jsonify(events)
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

@app.route('/api/register', methods=['POST'])
def register_for_event():
    if 'student_id' not in session:
        return jsonify({"error": "You must be logged in to register"}), 401

    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return jsonify({"error": "A JSON object is required"}), 400
    try:
        event_id = int(data.get("event_id"))
    except (TypeError, ValueError):
        return jsonify({"error": "A valid event_id is required"}), 400
    student_id = session['student_id']

    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.callproc('sp_register_for_event', [student_id, event_id])
        conn.commit()
        return jsonify({"message": "Successfully registered for the event!"})
    except Error as e:
        conn.rollback()
        error_msg = str(e)
        if "Duplicate entry" in error_msg:
            error_msg = "You are already registered for this event!"
        return jsonify({"error": error_msg}), 400
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

@app.route('/api/cancel', methods=['POST'])
def cancel_registration():
    if 'student_id' not in session:
        return jsonify({"error": "You must be logged in"}), 401

    data = request.get_json(silent=True)
    if not isinstance(data, dict):
        return jsonify({"error": "A JSON object is required"}), 400
    try:
        event_id = int(data.get("event_id"))
    except (TypeError, ValueError):
        return jsonify({"error": "A valid event_id is required"}), 400
    student_id = session['student_id']

    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500
    cursor = None
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM event_registration WHERE event_id = %s AND student_id = %s", (event_id, student_id))
        conn.commit()
        return jsonify({"message": "Registration cancelled."})
    except Error as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 400
    finally:
        if conn and conn.is_connected():
            if cursor:
                cursor.close()
            conn.close()

# --- PROFILE ROUTES ---
@app.route('/api/profile', methods=['GET', 'POST'])
def profile():
    if 'student_id' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    student_id = session['student_id']
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500
    cursor = None
    try:
        cursor = conn.cursor(dictionary=True)

        if request.method == 'POST':
            data = request.get_json(silent=True)
            if not isinstance(data, dict):
                return jsonify({"error": "A JSON object is required"}), 400
            first_name = data.get("first_name")
            last_name = data.get("last_name")
            new_password = data.get("new_password")
            if not isinstance(first_name, str) or not first_name.strip():
                return jsonify({"error": "First name is required"}), 400
            if not isinstance(last_name, str) or not last_name.strip():
                return jsonify({"error": "Last name is required"}), 400
            if new_password is not None and not isinstance(new_password, str):
                return jsonify({"error": "New password must be text"}), 400

            first_name = first_name.strip()
            last_name = last_name.strip()
            if new_password:
                cursor.execute("UPDATE student SET first_name=%s, last_name=%s, password_hash=%s WHERE student_id=%s",
                               (first_name, last_name, generate_password_hash(new_password), student_id))
            else:
                cursor.execute("UPDATE student SET first_name=%s, last_name=%s WHERE student_id=%s",
                               (first_name, last_name, student_id))
            conn.commit()
            session['first_name'] = first_name
            return jsonify({"message": "Profile updated successfully"})

        cursor.execute("""
            SELECT s.first_name, s.last_name, s.email, d.department_name
            FROM student s
            JOIN department d ON s.department_id = d.department_id
            WHERE s.student_id = %s
        """, (student_id,))
        user_info = cursor.fetchone()

        cursor.execute("""
            SELECT e.event_id, e.event_name, e.start_at, e.end_at, e.fun_fact, v.venue_name, c.club_name,
                   IF(e.start_at > NOW(), 'Upcoming', IF(e.end_at < NOW(), 'Completed', 'Ongoing')) as status
            FROM event_registration er
            JOIN `event` e ON er.event_id = e.event_id
            JOIN venue v ON e.venue_id = v.venue_id
            JOIN club c ON e.club_id = c.club_id
            WHERE er.student_id = %s
            ORDER BY e.start_at DESC
        """, (student_id,))
        registrations = cursor.fetchall()

        cursor.execute("""
            SELECT c.club_name, cm.member_role as role
            FROM club_membership cm
            JOIN club c ON cm.club_id = c.club_id
            WHERE cm.student_id = %s
        """, (student_id,))
        clubs = cursor.fetchall()

        return jsonify({
            "user": user_info,
            "registrations": registrations,
            "clubs": clubs,
            "stats": {
                "events_registered": len(registrations),
                "events_attended": sum(1 for r in registrations if r['status'] == 'Completed'),
                "clubs_joined": len(clubs)
            }
        })
    finally:
        if conn and conn.is_connected():
            if cursor:
                cursor.close()
            conn.close()

# --- TEMPLATE ROUTES ---
@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=os.environ.get("FLASK_DEBUG") == "1", port=int(os.environ.get("PORT", "5000")))
