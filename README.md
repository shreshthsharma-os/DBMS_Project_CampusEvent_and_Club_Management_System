# Campus Event & Club Management System

A relational database (MySQL/MariaDB) for managing college clubs and the events they run — memberships, event scheduling, registrations, attendance, budgets, and feedback — with the rules enforced by the database itself, not just application code.

**Live project site:** https://shreshthsharma-os.github.io/DBMS_Project_CampusEvent_and_Club_Management_System/
**Course:** Database Management Systems (CSE3001) · **Faculty:** Vijendra Singh Bramhe · VIT Bhopal University

## Team

| Name | Registration No. |
|---|---|
| Shreshth Sharma | 25BCE11231 |
| Aryan Singh Patel | 25BCE11138 |
| Krish Salaria | 25BCE11158 |
| Harshvardhan Swami | 25BCE111__ |

## What This Project Is

Clubs typically track events across spreadsheets, Google Forms, and chat groups. That leads to predictable problems: venues get double-booked, students register twice for the same event, nobody has an accurate attendance record, and event spending isn't checked against the approved budget until it's too late.

This project replaces that with a single normalized database where those problems are prevented by the schema itself — a duplicate registration is rejected, an over-budget expense is rejected, and an over-capacity venue booking is rejected, all at the point of insertion.

## What's in This Repo

| File | Description |
|---|---|
| `Campus_Event_Club_Management_System_Report.docx` | Full project report: objectives, ER diagram, data dictionary, normalization explanation, implementation notes |
| `campus_event_club_management.sql` | The complete MySQL script — schema, sample data, views, triggers, functions, procedures, and demonstration queries |
| `README.md` | This file |
| [Live site](https://shreshthsharma-os.github.io/DBMS_Project_CampusEvent_and_Club_Management_System/) | A hosted overview page with a project walkthrough and direct downloads for the report, SQL file, and ER diagram |

## Database Schema

The system has **11 tables**, split into two groups:

**Core entities** — the actual things being tracked:
`DEPARTMENT`, `STUDENT`, `FACULTY`, `CLUB`, `VENUE`, `EVENT`, `ATTENDANCE`, `EXPENSE`, `FEEDBACK`

**Junction tables** — resolve the two many-to-many relationships:
- `CLUB_MEMBERSHIP` — connects `STUDENT` ↔ `CLUB` (a student can join many clubs; a club has many students)
- `EVENT_REGISTRATION` — connects `STUDENT` ↔ `EVENT` (a student can register for many events; an event has many registrants)

```mermaid
erDiagram
    DEPARTMENT ||--o{ STUDENT : has
    DEPARTMENT ||--o{ FACULTY : has
    FACULTY ||--o{ CLUB : coordinates
    STUDENT ||--o{ CLUB_MEMBERSHIP : joins
    CLUB ||--o{ CLUB_MEMBERSHIP : has
    CLUB ||--o{ EVENT : organizes
    VENUE ||--o{ EVENT : hosts
    STUDENT ||--o{ EVENT_REGISTRATION : registers
    EVENT ||--o{ EVENT_REGISTRATION : receives
    EVENT_REGISTRATION ||--|| ATTENDANCE : tracks
    EVENT ||--o{ EXPENSE : incurs
    EVENT ||--o{ FEEDBACK : collects
    STUDENT ||--o{ FEEDBACK : gives
```

The full column-level ER diagram is in the report; an editable Mermaid source file is also linked from the live site.

**Normalization:** the schema is in Third Normal Form (3NF) — no column is duplicated across tables, and no attribute depends on anything other than its table's primary key. For example, a student's department name is never stored in the `STUDENT` table directly; only `dept_id` is stored, and the name is looked up from `DEPARTMENT` when needed.

## Database Objects

Beyond the base tables, the script includes:

**Views**
- `vw_upcoming_events` — approved/proposed events with club and venue details
- `vw_club_expenditure` — total spend per club across all its events

**Stored Procedure**
- `sp_register_for_event(event_id, student_id)` — registers a student for an event inside a transaction; rejects duplicate registrations and venue-capacity overflow, with rollback on failure

**Function**
- `fn_club_event_count(club_id)` — returns the number of events a club has organized

**Triggers**
- `trg_expense_budget_check` — rejects any expense that would push an event's total spending past its allocated budget
- `trg_create_attendance_row` — automatically creates a blank attendance record when a student registers for an event

**Indexes** on frequently filtered/joined columns (`event_date`, `club_id`, etc.)

## PL/SQL Concepts (Module 4)

The course's PL/SQL module is written for Oracle syntax. MySQL has an equivalent procedural language (SQL/PSM) that covers the same concepts. Section 6 of the SQL script implements each one against this project's own tables:

| Concept | MySQL Syntax | Implementation |
|---|---|---|
| Variables & control structures | `IF … ELSEIF … ELSE` | `fn_feedback_grade` — grades a rating as Excellent/Good/Average/Needs Improvement |
| Explicit cursors | `DECLARE CURSOR`, `OPEN`/`FETCH`/`CLOSE` | `sp_generate_budget_report` — loops through every event and classifies its spending |
| Exception handling (`NO_DATA_FOUND`) | `DECLARE CONTINUE HANDLER FOR NOT FOUND` | `sp_get_student_email` — returns a clean error instead of failing on an unknown student ID |
| `WHILE` loops | `WHILE … DO … END WHILE` | `fn_working_days_until_event` — counts weekdays remaining before an event |

Run `CALL sp_generate_budget_report();` after loading the script to see this in action — it labels every event as *Under Budget*, *On Track*, *Near Limit*, or *Over Budget*, computed live from the cursor loop.

## Setup

**Requirements:** MySQL 8.0+ or MariaDB 10.5+

```bash
mysql -u root -p < campus_event_club_management.sql
```

This creates a database named `campus_event_club_db`, fully populated with sample departments, students, faculty, clubs, venues, events, registrations, expenses, and feedback.

## Example Queries

```sql
USE campus_event_club_db;

-- Upcoming events with club & venue info
SELECT * FROM vw_upcoming_events;

-- Clubs ranked by membership size
SELECT club_name, COUNT(*) AS members
FROM CLUB_MEMBERSHIP
JOIN CLUB USING (club_id)
GROUP BY club_name
ORDER BY members DESC;

-- Register a student for an event (transaction-safe)
CALL sp_register_for_event(2, 8);
```

The full script has been tested end-to-end on MariaDB with no errors, including a verified check that the budget trigger correctly rejects an over-budget expense.

## Possible Extensions

## Possible Extensions

The current system provides the core database functionality for managing clubs and events. It can be further extended with the following features:

* **Web Front-End** — Develop a responsive web application using React, Angular, or HTML/CSS/JavaScript to provide an easy-to-use interface for students, club coordinators, and faculty.

* **REST API Integration** — Build a backend using Java Spring Boot, Node.js, or Python to connect the database with the web or mobile application.

* **Role-Based Access Control** — Add separate permissions for students, club administrators, faculty coordinators, and university administrators so that each user can access only the required features.

* **QR-Code Attendance** — Generate a unique QR code for each event and allow students to scan it for quick and accurate attendance marking.

* **Online Event Registration** — Allow students to browse upcoming events, register online, cancel registrations, and receive confirmation notifications.

* **Automated Notifications** — Send email or SMS notifications for event registration, event reminders, schedule changes, cancellations, and approval status.

* **Event Approval Workflow** — Introduce a multi-level approval system where events can be submitted by club coordinators and approved by faculty or university administrators.

* **Budget Analytics Dashboard** — Create dashboards showing event budgets, expenses, remaining funds, spending patterns, and club-wise expenditure.

* **Advanced Reporting** — Generate reports for event participation, attendance percentage, club membership, feedback ratings, expenses, and overall club performance.

* **Feedback and Rating Analytics** — Analyze student feedback to identify popular events, average ratings, and areas that need improvement.

* **Venue Availability Management** — Add a calendar-based system that allows administrators to view available venues and prevent scheduling conflicts.

* **Mobile Application** — Develop an Android/iOS application so students can register for events, view schedules, receive notifications, and check their attendance.

* **Audit Logs** — Maintain a history of important database operations such as event creation, registration changes, expense updates, and event approvals for better accountability.

* **Cloud Database Deployment** — Deploy the database on a cloud platform to provide reliable access, scalability, automated backups, and centralized management.

* **Data Backup and Recovery** — Implement scheduled database backups and recovery procedures to protect against accidental data loss.

* **Event Recommendation System** — Use students' previous registrations, club memberships, and interests to recommend relevant upcoming events.

* **Predictive Analytics** — Analyze historical registration and attendance data to estimate expected participation and help clubs plan venues, budgets, and resources more effectively.

