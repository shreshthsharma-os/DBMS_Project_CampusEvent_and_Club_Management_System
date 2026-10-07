-- Run after campus_event_club_management.sql in MySQL 8.0+ / MariaDB 10.5+.
-- Successful fixture DML runs inside a transaction and is rolled back. The
-- procedure test uses the seeded (student 2, event 8) pair because the
-- procedure manages and commits its own transaction; that enrollment is
-- removed immediately after its attendance row is verified.
USE campus_event_club_db;

DROP PROCEDURE IF EXISTS sp_test_expect_sqlstate;
DROP PROCEDURE IF EXISTS sp_test_assert;

DELIMITER //

CREATE PROCEDURE sp_test_assert(IN p_condition BOOLEAN, IN p_message VARCHAR(255))
BEGIN
    IF p_condition IS NULL OR p_condition = FALSE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;
END//

DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_test_expect_sqlstate(
    IN p_statement TEXT,
    IN p_expected_state CHAR(5)
)
BEGIN
    DECLARE v_actual_state CHAR(5) DEFAULT '00000';
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            GET DIAGNOSTICS CONDITION 1 v_actual_state = RETURNED_SQLSTATE;
        SET @constraint_test_statement = p_statement;
        PREPARE constraint_test_stmt FROM @constraint_test_statement;
        EXECUTE constraint_test_stmt;
        DEALLOCATE PREPARE constraint_test_stmt;
    END;
    IF v_actual_state = '00000' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Expected statement rejection, but statement succeeded';
    END IF;
    IF v_actual_state <> p_expected_state THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Statement failed with an unexpected SQLSTATE';
    END IF;
END//
DELIMITER ;

-- Procedure test: it commits internally, so use the known-free seeded pair.
SELECT COUNT(*) = 0 INTO @test_precondition
  FROM event_registration
 WHERE event_id = 8 AND student_id = 2;
CALL sp_test_assert(
    @test_precondition,
    'Precondition failed: student 2 must not already be registered for event 8'
);
CALL sp_register_for_event(2, 8);
SELECT COUNT(*) = 1 INTO @test_attendance
  FROM attendance
 WHERE event_id = 8 AND student_id = 2
   AND attendance_status = 'Not Marked';
CALL sp_test_assert(
    @test_attendance,
    'Procedure registration did not create its attendance row'
);
DELETE FROM event_registration WHERE event_id = 8 AND student_id = 2;

START TRANSACTION;

-- Small approved fixtures let the checks exercise capacity and budget exactly.
INSERT INTO `event`
    (event_id, club_id, venue_id, event_name, start_at, end_at, capacity,
     budget_limit, approval_status)
VALUES
    (900001, 1, 3, 'Constraint test capacity fixture',
     DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 90 DAY),
     DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 90 DAY) + INTERVAL 2 HOUR,
     2, 100.00, 'Approved'),
    (900002, 1, 3, 'Constraint test budget fixture',
     DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 91 DAY),
     DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 91 DAY) + INTERVAL 2 HOUR,
     5, 10.00, 'Approved');

-- Expected failure (SQLSTATE 45000): scheduled event capacity cannot exceed venue capacity.
CALL sp_test_expect_sqlstate(
    'INSERT INTO `event` (club_id, venue_id, event_name, start_at, end_at, capacity, budget_limit, approval_status) VALUES (1, 3, ''Oversized venue test'', DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 92 DAY), DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 92 DAY) + INTERVAL 2 HOUR, 501, 10.00, ''Approved'')',
    '45000'
);

-- Expected failure (SQLSTATE 45000): two events cannot overlap at one venue.
CALL sp_test_expect_sqlstate(
    'INSERT INTO `event` (club_id, venue_id, event_name, start_at, end_at, capacity, budget_limit, approval_status) VALUES (1, 3, ''Overlapping venue test'', DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 90 DAY), DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 90 DAY) + INTERVAL 1 HOUR, 100, 10.00, ''Approved'')',
    '45000'
);

-- Expected success: registration creates one attendance row in the same transaction.
INSERT INTO event_registration (event_id, student_id) VALUES (900001, 1);
INSERT INTO event_registration (event_id, student_id) VALUES (900001, 2);
SELECT COUNT(*) = 1 INTO @test_fixture_attendance
  FROM attendance
 WHERE event_id = 900001 AND student_id = 1
   AND attendance_status = 'Not Marked';
CALL sp_test_assert(
    @test_fixture_attendance,
    'Registration did not automatically create an attendance row'
);

-- Expected failure (SQLSTATE 45000): capacity cannot be reduced below two existing registrations.
CALL sp_test_expect_sqlstate(
    'UPDATE `event` SET capacity = 1 WHERE event_id = 900001',
    '45000'
);

-- Expected failure (SQLSTATE 45000): a third registration exceeds capacity 2.
CALL sp_test_expect_sqlstate(
    'INSERT INTO event_registration (event_id, student_id) VALUES (900001, 3)',
    '45000'
);

-- Expected success: exactly the budget ceiling is allowed.
INSERT INTO expense (event_id, expense_date, category, description, amount)
VALUES (900002, CURRENT_DATE, 'Test', 'At-budget test expense', 10.00);

-- Expected failure (SQLSTATE 45000): cumulative expenses cannot exceed budget.
CALL sp_test_expect_sqlstate(
    'INSERT INTO expense (event_id, expense_date, category, description, amount) VALUES (900002, CURRENT_DATE, ''Test'', ''Over-budget test expense'', 0.01)',
    '45000'
);

-- Expected failure (SQLSTATE 45000): an event budget cannot be lowered below spend.
CALL sp_test_expect_sqlstate(
    'UPDATE `event` SET budget_limit = 9.99 WHERE event_id = 900002',
    '45000'
);

ROLLBACK;
DROP PROCEDURE sp_test_expect_sqlstate;
DROP PROCEDURE sp_test_assert;

SELECT 'PASS: procedure registration, attendance creation, capacity/venue guards, and budget guards' AS result;
