-- Campus Event & Club Management System
-- Target: MySQL 8.0+ or MariaDB 10.5+
-- Creates a fresh campus_event_club_db schema and inserts reproducible sample data.
-- This script intentionally does not drop an existing schema or its data.

CREATE DATABASE IF NOT EXISTS campus_event_club_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE campus_event_club_db;

CREATE TABLE Department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    building VARCHAR(100)
) ENGINE = InnoDB;

CREATE TABLE Student (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    registration_no VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE,
    department_id INT NOT NULL,
    enrollment_year YEAR NOT NULL,
    CONSTRAINT fk_student_department
        FOREIGN KEY (department_id) REFERENCES Department (department_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE Faculty (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_name VARCHAR(120) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE,
    department_id INT NOT NULL,
    CONSTRAINT fk_faculty_department
        FOREIGN KEY (department_id) REFERENCES Department (department_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE Club (
    club_id INT AUTO_INCREMENT PRIMARY KEY,
    club_name VARCHAR(120) NOT NULL UNIQUE,
    description TEXT,
    founded_on DATE,
    coordinator_faculty_id INT NOT NULL,
    CONSTRAINT fk_club_coordinator
        FOREIGN KEY (coordinator_faculty_id) REFERENCES Faculty (faculty_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE CLUB_MEMBERSHIP (
    student_id INT NOT NULL,
    club_id INT NOT NULL,
    member_role VARCHAR(40) NOT NULL DEFAULT 'Member',
    joined_on DATE NOT NULL,
    PRIMARY KEY (student_id, club_id),
    CONSTRAINT fk_membership_student
        FOREIGN KEY (student_id) REFERENCES Student (student_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_membership_club
        FOREIGN KEY (club_id) REFERENCES Club (club_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE Venue (
    venue_id INT AUTO_INCREMENT PRIMARY KEY,
    venue_name VARCHAR(120) NOT NULL UNIQUE,
    building VARCHAR(100) NOT NULL,
    venue_capacity INT NOT NULL,
    CONSTRAINT chk_venue_capacity CHECK (venue_capacity > 0)
) ENGINE = InnoDB;

CREATE TABLE `Event` (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    club_id INT NOT NULL,
    venue_id INT NOT NULL,
    event_name VARCHAR(160) NOT NULL,
    description TEXT,
    start_at DATETIME NOT NULL,
    end_at DATETIME NOT NULL,
    capacity INT NOT NULL,
    budget_limit DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    approval_status ENUM('Draft', 'Pending', 'Approved', 'Cancelled', 'Completed')
        NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_event_club
        FOREIGN KEY (club_id) REFERENCES Club (club_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_event_venue
        FOREIGN KEY (venue_id) REFERENCES Venue (venue_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_event_time CHECK (end_at > start_at),
    CONSTRAINT chk_event_capacity CHECK (capacity > 0),
    CONSTRAINT chk_event_budget CHECK (budget_limit >= 0.00)
) ENGINE = InnoDB;

CREATE TABLE EVENT_REGISTRATION (
    event_id INT NOT NULL,
    student_id INT NOT NULL,
    registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id, student_id),
    CONSTRAINT fk_registration_event
        FOREIGN KEY (event_id) REFERENCES `Event` (event_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_registration_student
        FOREIGN KEY (student_id) REFERENCES Student (student_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE Attendance (
    event_id INT NOT NULL,
    student_id INT NOT NULL,
    attendance_status ENUM('Not Marked', 'Present', 'Absent') NOT NULL DEFAULT 'Not Marked',
    checked_in_at DATETIME NULL,
    PRIMARY KEY (event_id, student_id),
    CONSTRAINT fk_attendance_registration
        FOREIGN KEY (event_id, student_id)
        REFERENCES EVENT_REGISTRATION (event_id, student_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_attendance_checkin CHECK (
        checked_in_at IS NULL OR attendance_status = 'Present'
    )
) ENGINE = InnoDB;

CREATE TABLE Expense (
    expense_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    expense_date DATE NOT NULL,
    category VARCHAR(80) NOT NULL,
    description VARCHAR(255) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    CONSTRAINT fk_expense_event
        FOREIGN KEY (event_id) REFERENCES `Event` (event_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_expense_amount CHECK (amount > 0.00)
) ENGINE = InnoDB;

CREATE TABLE Feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    student_id INT NOT NULL,
    rating TINYINT NOT NULL,
    comments VARCHAR(1000),
    submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_feedback_event_student UNIQUE (event_id, student_id),
    CONSTRAINT fk_feedback_registration
        FOREIGN KEY (event_id, student_id)
        REFERENCES EVENT_REGISTRATION (event_id, student_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_feedback_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE = InnoDB;

DELIMITER //

CREATE TRIGGER trg_venue_capacity_before_update
BEFORE UPDATE ON Venue
FOR EACH ROW
BEGIN
    DECLARE v_conflict_event INT DEFAULT NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_conflict_event = NULL;

    SELECT event_id
      INTO v_conflict_event
      FROM `Event`
     WHERE venue_id = OLD.venue_id
       AND capacity > NEW.venue_capacity
     LIMIT 1
     FOR UPDATE;

    IF v_conflict_event IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Venue capacity cannot be below a scheduled event capacity';
    END IF;
END//

CREATE TRIGGER trg_event_capacity_before_insert
BEFORE INSERT ON `Event`
FOR EACH ROW
BEGIN
    DECLARE v_venue_capacity INT DEFAULT NULL;
    DECLARE v_conflict_event INT DEFAULT NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_venue_capacity = NULL;

    SELECT venue_capacity
      INTO v_venue_capacity
      FROM Venue
     WHERE venue_id = NEW.venue_id
     FOR UPDATE;

    IF v_venue_capacity IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Event venue does not exist';
    END IF;
    IF NEW.capacity > v_venue_capacity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Event capacity cannot exceed venue capacity';
    END IF;

    SELECT event_id
      INTO v_conflict_event
      FROM `Event`
     WHERE venue_id = NEW.venue_id
       AND start_at < NEW.end_at
       AND end_at > NEW.start_at
     LIMIT 1
     FOR UPDATE;

    IF v_conflict_event IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Venue already has an event in this time range';
    END IF;
END//

CREATE TRIGGER trg_event_capacity_before_update
BEFORE UPDATE ON `Event`
FOR EACH ROW
BEGIN
    DECLARE v_venue_capacity INT DEFAULT NULL;
    DECLARE v_conflict_event INT DEFAULT NULL;
    DECLARE v_registered INT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_venue_capacity = NULL;

    SELECT venue_capacity
      INTO v_venue_capacity
      FROM Venue
     WHERE venue_id = NEW.venue_id
     FOR UPDATE;

    IF v_venue_capacity IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Event venue does not exist';
    END IF;
    IF NEW.capacity > v_venue_capacity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Event capacity cannot exceed venue capacity';
    END IF;

    SELECT COUNT(*)
      INTO v_registered
      FROM EVENT_REGISTRATION
     WHERE event_id = OLD.event_id
     FOR UPDATE;

    IF v_registered > NEW.capacity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Event capacity cannot be lower than existing registrations';
    END IF;

    SELECT event_id
      INTO v_conflict_event
      FROM `Event`
     WHERE venue_id = NEW.venue_id
       AND event_id <> OLD.event_id
       AND start_at < NEW.end_at
       AND end_at > NEW.start_at
     LIMIT 1
     FOR UPDATE;

    IF v_conflict_event IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Venue already has an event in this time range';
    END IF;
END//

CREATE TRIGGER trg_event_budget_before_update
BEFORE UPDATE ON `Event`
FOR EACH ROW
BEGIN
    DECLARE v_expenses DECIMAL(14, 2) DEFAULT 0.00;

    IF NEW.budget_limit < OLD.budget_limit THEN
        SELECT COALESCE(SUM(amount), 0.00)
          INTO v_expenses
          FROM Expense
         WHERE event_id = OLD.event_id
         FOR UPDATE;

        IF v_expenses > NEW.budget_limit THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'New event budget is below recorded expenses';
        END IF;
    END IF;
END//

CREATE TRIGGER trg_registration_before_insert
BEFORE INSERT ON EVENT_REGISTRATION
FOR EACH ROW
BEGIN
    DECLARE v_capacity INT DEFAULT NULL;
    DECLARE v_status VARCHAR(20) DEFAULT NULL;
    DECLARE v_registered INT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_capacity = NULL;

    SELECT capacity, approval_status
      INTO v_capacity, v_status
      FROM `Event`
     WHERE event_id = NEW.event_id
     FOR UPDATE;

    IF v_capacity IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Event does not exist';
    END IF;
    IF v_status <> 'Approved' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Registration is allowed only for approved events';
    END IF;

    SELECT COUNT(*)
      INTO v_registered
      FROM EVENT_REGISTRATION
     WHERE event_id = NEW.event_id
     FOR UPDATE;

    IF v_registered >= v_capacity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Event capacity has been reached';
    END IF;
END//

CREATE TRIGGER trg_registration_after_insert
AFTER INSERT ON EVENT_REGISTRATION
FOR EACH ROW
BEGIN
    INSERT INTO Attendance (event_id, student_id, attendance_status)
    VALUES (NEW.event_id, NEW.student_id, 'Not Marked');
END//

CREATE TRIGGER trg_registration_before_update
BEFORE UPDATE ON EVENT_REGISTRATION
FOR EACH ROW
BEGIN
    IF NEW.event_id <> OLD.event_id OR NEW.student_id <> OLD.student_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Registration key columns are immutable';
    END IF;
END//

CREATE TRIGGER trg_expense_before_insert
BEFORE INSERT ON Expense
FOR EACH ROW
BEGIN
    DECLARE v_budget DECIMAL(12, 2) DEFAULT NULL;
    DECLARE v_spent DECIMAL(14, 2) DEFAULT 0.00;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_budget = NULL;

    SELECT budget_limit
      INTO v_budget
      FROM `Event`
     WHERE event_id = NEW.event_id
     FOR UPDATE;

    IF v_budget IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Expense event does not exist';
    END IF;

    SELECT COALESCE(SUM(amount), 0.00)
      INTO v_spent
      FROM Expense
     WHERE event_id = NEW.event_id
     FOR UPDATE;

    IF v_spent + NEW.amount > v_budget THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Expense would exceed the event budget';
    END IF;
END//

CREATE TRIGGER trg_expense_before_update
BEFORE UPDATE ON Expense
FOR EACH ROW
BEGIN
    DECLARE v_budget DECIMAL(12, 2) DEFAULT NULL;
    DECLARE v_spent DECIMAL(14, 2) DEFAULT 0.00;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_budget = NULL;

    SELECT budget_limit
      INTO v_budget
      FROM `Event`
     WHERE event_id = NEW.event_id
     FOR UPDATE;

    IF v_budget IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Expense event does not exist';
    END IF;

    SELECT COALESCE(SUM(amount), 0.00)
      INTO v_spent
      FROM Expense
     WHERE event_id = NEW.event_id
       AND expense_id <> OLD.expense_id
     FOR UPDATE;

    IF v_spent + NEW.amount > v_budget THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Updated expense would exceed the event budget';
    END IF;
END//

CREATE PROCEDURE sp_register_for_event(
    IN p_student_id INT,
    IN p_event_id INT
)
BEGIN
    DECLARE v_capacity INT DEFAULT NULL;
    DECLARE v_status VARCHAR(20) DEFAULT NULL;
    DECLARE v_registered INT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_capacity = NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT capacity, approval_status
      INTO v_capacity, v_status
      FROM `Event`
     WHERE event_id = p_event_id
     FOR UPDATE;

    IF v_capacity IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Event does not exist';
    END IF;
    IF v_status <> 'Approved' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Registration is allowed only for approved events';
    END IF;

    SELECT COUNT(*)
      INTO v_registered
      FROM EVENT_REGISTRATION
     WHERE event_id = p_event_id
     FOR UPDATE;

    IF v_registered >= v_capacity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Event capacity has been reached';
    END IF;

    INSERT INTO EVENT_REGISTRATION (event_id, student_id)
    VALUES (p_event_id, p_student_id);

    COMMIT;
END//

CREATE VIEW vw_upcoming_events AS
SELECT e.event_id,
       e.event_name,
       e.start_at,
       e.end_at,
       c.club_name,
       v.venue_name,
       v.building AS venue_building,
       e.capacity,
       COUNT(r.student_id) AS registered_count,
       e.capacity - COUNT(r.student_id) AS seats_remaining
  FROM `Event` AS e
  JOIN Club AS c ON c.club_id = e.club_id
  JOIN Venue AS v ON v.venue_id = e.venue_id
  LEFT JOIN EVENT_REGISTRATION AS r ON r.event_id = e.event_id
 WHERE e.approval_status = 'Approved'
   AND e.start_at >= CURRENT_TIMESTAMP
 GROUP BY e.event_id, e.event_name, e.start_at, e.end_at,
          c.club_name, v.venue_name, v.building, e.capacity//

DELIMITER ;

INSERT INTO Department (department_id, department_name, building) VALUES
    (1, 'Computer Science and Engineering', 'Academic Block A'),
    (2, 'Electrical and Electronics Engineering', 'Academic Block B'),
    (3, 'Humanities and Social Sciences', 'Academic Block C');

INSERT INTO Faculty (faculty_id, faculty_name, email, department_id) VALUES
    (1, 'Dr. Meera Nair', 'meera.nair@example.edu', 1),
    (2, 'Prof. Arvind Menon', 'arvind.menon@example.edu', 2),
    (3, 'Dr. Kavita Rao', 'kavita.rao@example.edu', 3);

INSERT INTO Student
    (student_id, registration_no, first_name, last_name, email, department_id, enrollment_year)
VALUES
    (1, '25BCE11231', 'Aarav', 'Sharma', 'aarav.sharma@example.edu', 1, 2025),
    (2, '25BCE11138', 'Isha', 'Patel', 'isha.patel@example.edu', 1, 2025),
    (3, '24BEE11042', 'Rohan', 'Kumar', 'rohan.kumar@example.edu', 2, 2024),
    (4, '24BCE10987', 'Ananya', 'Singh', 'ananya.singh@example.edu', 1, 2024),
    (5, '23BHS10451', 'Kabir', 'Joshi', 'kabir.joshi@example.edu', 3, 2023),
    (6, '25BEE11209', 'Mira', 'Desai', 'mira.desai@example.edu', 2, 2025);

INSERT INTO Club
    (club_id, club_name, description, founded_on, coordinator_faculty_id)
VALUES
    (1, 'Tech Innovators', 'Student-led technology and maker community', '2018-08-15', 1),
    (2, 'Cultural Collective', 'Performing arts, music, and campus culture', '2016-09-01', 3),
    (3, 'Green Campus Forum', 'Sustainability and environmental action', '2020-01-20', 2);

INSERT INTO CLUB_MEMBERSHIP (student_id, club_id, member_role, joined_on) VALUES
    (1, 1, 'President', '2025-08-10'),
    (2, 1, 'Treasurer', '2025-08-12'),
    (3, 1, 'Member', '2025-08-15'),
    (4, 1, 'Member', '2025-08-16'),
    (2, 2, 'Volunteer', '2025-09-01'),
    (5, 2, 'President', '2025-08-20'),
    (6, 3, 'Coordinator', '2025-08-18'),
    (3, 3, 'Member', '2025-09-02');

INSERT INTO Venue (venue_id, venue_name, building, venue_capacity) VALUES
    (1, 'Central Auditorium', 'Student Activity Centre', 400),
    (2, 'Innovation Lab', 'Academic Block A', 80),
    (3, 'Green Amphitheatre', 'East Campus Lawn', 500);

INSERT INTO `Event`
    (event_id, club_id, venue_id, event_name, description, start_at, end_at,
     capacity, budget_limit, approval_status)
VALUES
    (1, 1, 2, 'Build-a-thon Workshop', 'Hands-on prototyping for student teams',
     DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 7 DAY), DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 7 DAY) + INTERVAL 3 HOUR,
     60, 18000.00, 'Approved'),
    (2, 1, 1, 'Campus Robotics Showcase', 'Demonstrations of student robotics projects',
     DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 14 DAY), DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 14 DAY) + INTERVAL 5 HOUR,
     300, 45000.00, 'Approved'),
    (3, 2, 1, 'Monsoon Music Evening', 'An evening of student music performances',
     DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 21 DAY), DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 21 DAY) + INTERVAL 4 HOUR,
     350, 32000.00, 'Approved'),
    (4, 3, 3, 'Campus Clean-up Drive', 'Volunteer-led clean-up and waste segregation drive',
     DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 28 DAY), DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 28 DAY) + INTERVAL 3 HOUR,
     250, 12000.00, 'Approved'),
    (5, 1, 2, 'Intro to Embedded Systems', 'A practical session on microcontrollers',
     DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 35 DAY), DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 35 DAY) + INTERVAL 2 HOUR,
     70, 9000.00, 'Approved'),
    (6, 2, 3, 'Inter-College Folk Festival', 'Folk music and dance performances',
     DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 42 DAY), DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 42 DAY) + INTERVAL 6 HOUR,
     450, 60000.00, 'Approved'),
    (7, 3, 2, 'Repair Cafe', 'Bring small household items for repair and reuse',
     DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 49 DAY), DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 49 DAY) + INTERVAL 4 HOUR,
     65, 7500.00, 'Pending'),
    (8, 1, 3, 'Annual Innovation Expo', 'Student project exhibits and demonstrations',
     DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 63 DAY), DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 63 DAY) + INTERVAL 7 HOUR,
     400, 85000.00, 'Approved');

INSERT INTO EVENT_REGISTRATION (event_id, student_id) VALUES
    (1, 1), (1, 2), (1, 3),
    (2, 1), (2, 4),
    (3, 2), (3, 5),
    (4, 3), (4, 6),
    (5, 1), (5, 6),
    (6, 2), (6, 5),
    (8, 1), (8, 3), (8, 4), (8, 5);

INSERT INTO Expense (event_id, expense_date, category, description, amount) VALUES
    (1, CURRENT_DATE, 'Materials', 'Prototype components and workshop kits', 4200.00),
    (1, CURRENT_DATE, 'Refreshments', 'Water and snacks for participants', 1800.00),
    (2, CURRENT_DATE, 'Equipment', 'Display and demonstration equipment rental', 12500.00),
    (3, CURRENT_DATE, 'Production', 'Sound and lighting rental', 14800.00),
    (4, CURRENT_DATE, 'Supplies', 'Gloves, bags, and sorting materials', 2350.00),
    (6, CURRENT_DATE, 'Production', 'Stage and audio equipment', 21800.00),
    (8, CURRENT_DATE, 'Logistics', 'Exhibit tables and signage', 16750.00);

INSERT INTO Feedback (event_id, student_id, rating, comments) VALUES
    (1, 1, 5, 'Well-organized and useful hands-on activities.'),
    (1, 2, 4, 'Good workshop; more time for the final build would help.'),
    (3, 5, 5, 'A welcoming evening with a great mix of performances.'),
    (4, 6, 4, 'Clear volunteer coordination and a visible campus impact.');
