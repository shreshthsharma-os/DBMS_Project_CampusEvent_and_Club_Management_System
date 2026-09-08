# Campus Event & Club Management System

A relational database project (MySQL/MariaDB) that models the full lifecycle of college club activities and campus events — club membership, event scheduling, registrations, attendance, budgets/expenses, and feedback — with integrity enforced at the database layer through constraints, triggers, views, functions, and stored procedures.

Built as a DBMS project (Database Management Systems, CSE3001) by *Team Members*:
*1)SHRESHTH SHARMA* (25BCE11231)
*2)ARYAN SINGH PATEL* (25BCE11138)
*3)KRISH SALARIA* (25BCE11158)
*4)HARSHVARDHAN SWAMI* (25BCE111__)

---

## 📌 Overview

Most college clubs track events across spreadsheets and chat groups — leading to double-booked venues, duplicate registrations, and no real record of attendance, spend, or feedback. This project centralizes that workflow into a single normalized MySQL database that:

- Tracks **clubs**, their **faculty coordinators**, and **student memberships** (with roles)
- Schedules **events** against **venues**, with budget ceilings
- Handles **student registrations**, **attendance**, and **post-event feedback**
- Tracks **itemized expenses** per event and blocks overspending automatically
- Demonstrates core DBMS concepts end-to-end: ER modeling, normalization, joins, subqueries, views, indexes, stored procedures, functions, and triggers

## 📁 Repository Contents

| File | Description |
|---|---|
| `Campus_Event_Club_Management_System_Report.docx` | Full project report — objectives, scope, ER diagram, data dictionary, normalization writeup, and annotated implementation highlights |
| `campus_event_club_management.sql` | Complete, runnable MySQL script — schema (DDL), sample data (DML), views, triggers, functions, a stored procedure, and 15 demonstration queries |
| `README.md` | This file |

## 🗂️ Database Schema

The system is modeled around **11 tables**:

| Table | Purpose |
|---|---|
| `DEPARTMENT` | Academic departments |
| `STUDENT` | Student records, linked to a department |
| `FACULTY` | Faculty members, linked to a department |
| `CLUB` | Clubs, each with one faculty coordinator |
| `CLUB_MEMBERSHIP` | Junction table — Student ↔ Club (many-to-many), with role and join date |
| `VENUE` | Bookable venues with a seating capacity |
| `EVENT` | Events, each tied to one club and one venue |
| `EVENT_REGISTRATION` | Junction table — Student ↔ Event (many-to-many) |
| `ATTENDANCE` | 1:1 with a registration — actual check-in outcome |
| `EXPENSE` | Itemized spend per event, validated against the event's budget |
| `FEEDBACK` | Student ratings/comments per event |

**Relationships at a glance:**
- Department → Student, Faculty (1:M)
- Faculty → Club (1:M, coordinator)
- Student ↔ Club (M:N via `CLUB_MEMBERSHIP`)
- Club → Event (1:M) · Venue → Event (1:M)
- Student ↔ Event (M:N via `EVENT_REGISTRATION`)
- Event_Registration → Attendance (1:1)
- Event → Expense, Feedback (1:M)

The full ER diagram and column-level data dictionary are in the report.

The schema is normalized to **Third Normal Form (3NF)** — no repeated groups, no partial dependencies, and no transitive dependencies (e.g. a student's department name is never duplicated into `STUDENT`; it's looked up via `dept_id`).

## ⚙️ Database Objects

Beyond the base tables, the script includes:

- **Views**
  - `vw_upcoming_events` — approved/proposed events with club and venue details
  - `vw_club_expenditure` — total spend per club across all its events
- **Stored Procedure**
  - `sp_register_for_event(event_id, student_id)` — registers a student for an event inside a transaction, rejecting duplicate registrations and venue-capacity overflow, with rollback on failure
- **Function**
  - `fn_club_event_count(club_id)` — returns the number of events a club has organized
- **Triggers**
  - `trg_expense_budget_check` — blocks any expense that would push an event's spending past its allocated budget
  - `trg_create_attendance_row` — auto-creates a blank attendance record whenever a student registers for an event
- **Indexes** on frequently filtered/joined columns (`event_date`, `club_id`, etc.)

## 🚀 Getting Started

**Requirements:** MySQL 8.0+ or MariaDB 10.5+

```bash
# 1. Log in to your MySQL/MariaDB server
mysql -u root -p

# 2. Run the script (creates the database, tables, sample data, and objects)
SOURCE campus_event_club_management.sql;
```

Or from the command line directly:

```bash
mysql -u root -p < campus_event_club_management.sql
```

This creates a database named `campus_event_club_db`, fully populated with sample departments, students, faculty, clubs, venues, events, registrations, expenses, and feedback — ready to query immediately.

### Try it out

```sql
USE campus_event_club_db;

-- See all upcoming events with club & venue info
SELECT * FROM vw_upcoming_events;

-- Rank clubs by membership size
SELECT club_name, COUNT(*) AS members
FROM CLUB_MEMBERSHIP
JOIN CLUB USING (club_id)
GROUP BY club_name
ORDER BY members DESC;

-- Register a student for an event (transaction-safe)
CALL sp_register_for_event(2, 8);
```

The script has been tested end-to-end on MariaDB with no errors, including a verified check that the budget trigger correctly rejects an over-budget expense insert.

## 🔮 Possible Extensions

- A web front-end (React/Angular) with a REST API layer over this schema
- Role-based access (student / club admin / faculty coordinator / university admin)
- QR-code based attendance check-in
- Automated email/SMS notifications on registration and approval
- A reporting dashboard for club performance and budget utilization

Course: Database Management Systems (CSE3001)

TEACHER - VIJENDRA SINGH BRAMHE
