-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: campus_event_club_db
-- ------------------------------------------------------
-- Server version	8.0.46
--
-- WARNING: This dump drops and recreates the project tables. It will delete
-- existing project data in campus_event_club_db before inserting the sample rows.

CREATE DATABASE IF NOT EXISTS campus_event_club_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE campus_event_club_db;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance` (
  `event_id` int NOT NULL,
  `student_id` int NOT NULL,
  `attendance_status` enum('Not Marked','Present','Absent') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Not Marked',
  `checked_in_at` datetime DEFAULT NULL,
  PRIMARY KEY (`event_id`,`student_id`),
  CONSTRAINT `fk_attendance_registration` FOREIGN KEY (`event_id`, `student_id`) REFERENCES `event_registration` (`event_id`, `student_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_attendance_checkin` CHECK (((`checked_in_at` is null) or (`attendance_status` = _cp850'Present')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
INSERT INTO `attendance` VALUES (1,1,'Not Marked',NULL),(1,2,'Not Marked',NULL),(1,3,'Not Marked',NULL),(2,1,'Not Marked',NULL),(2,3,'Not Marked',NULL),(2,4,'Not Marked',NULL),(3,2,'Not Marked',NULL),(3,5,'Not Marked',NULL),(4,1,'Not Marked',NULL),(4,3,'Not Marked',NULL),(4,6,'Not Marked',NULL),(5,1,'Not Marked',NULL),(5,6,'Not Marked',NULL),(6,2,'Not Marked',NULL),(6,5,'Not Marked',NULL),(8,1,'Not Marked',NULL),(8,3,'Not Marked',NULL),(8,4,'Not Marked',NULL),(8,5,'Not Marked',NULL);
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `club`
--

DROP TABLE IF EXISTS `club`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `club` (
  `club_id` int NOT NULL AUTO_INCREMENT,
  `club_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `founded_on` date DEFAULT NULL,
  `coordinator_faculty_id` int NOT NULL,
  PRIMARY KEY (`club_id`),
  UNIQUE KEY `club_name` (`club_name`),
  KEY `fk_club_coordinator` (`coordinator_faculty_id`),
  CONSTRAINT `fk_club_coordinator` FOREIGN KEY (`coordinator_faculty_id`) REFERENCES `faculty` (`faculty_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `club`
--

LOCK TABLES `club` WRITE;
/*!40000 ALTER TABLE `club` DISABLE KEYS */;
INSERT INTO `club` VALUES (1,'Tech Innovators','Student-led technology and maker community','2018-08-15',1),(2,'Cultural Collective','Performing arts, music, and campus culture','2016-09-01',3),(3,'Green Campus Forum','Sustainability and environmental action','2020-01-20',2);
/*!40000 ALTER TABLE `club` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `club_membership`
--

DROP TABLE IF EXISTS `club_membership`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `club_membership` (
  `student_id` int NOT NULL,
  `club_id` int NOT NULL,
  `member_role` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Member',
  `joined_on` date NOT NULL,
  PRIMARY KEY (`student_id`,`club_id`),
  KEY `fk_membership_club` (`club_id`),
  CONSTRAINT `fk_membership_club` FOREIGN KEY (`club_id`) REFERENCES `club` (`club_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_membership_student` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `club_membership`
--

LOCK TABLES `club_membership` WRITE;
/*!40000 ALTER TABLE `club_membership` DISABLE KEYS */;
INSERT INTO `club_membership` VALUES (1,1,'President','2025-08-10'),(2,1,'Treasurer','2025-08-12'),(2,2,'Volunteer','2025-09-01'),(3,1,'Member','2025-08-15'),(3,3,'Member','2025-09-02'),(4,1,'Member','2025-08-16'),(5,2,'President','2025-08-20'),(6,3,'Coordinator','2025-08-18');
/*!40000 ALTER TABLE `club_membership` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `department`
--

DROP TABLE IF EXISTS `department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `department` (
  `department_id` int NOT NULL AUTO_INCREMENT,
  `department_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `building` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`department_id`),
  UNIQUE KEY `department_name` (`department_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `department`
--

LOCK TABLES `department` WRITE;
/*!40000 ALTER TABLE `department` DISABLE KEYS */;
INSERT INTO `department` VALUES (1,'Computer Science and Engineering','Academic Block A'),(2,'Electrical and Electronics Engineering','Academic Block B'),(3,'Humanities and Social Sciences','Academic Block C');
/*!40000 ALTER TABLE `department` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event`
--

DROP TABLE IF EXISTS `event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event` (
  `event_id` int NOT NULL AUTO_INCREMENT,
  `club_id` int NOT NULL,
  `venue_id` int NOT NULL,
  `event_name` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `start_at` datetime NOT NULL,
  `end_at` datetime NOT NULL,
  `capacity` int NOT NULL,
  `budget_limit` decimal(12,2) NOT NULL DEFAULT '0.00',
  `approval_status` enum('Draft','Pending','Approved','Cancelled','Completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `fun_fact` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`event_id`),
  KEY `fk_event_club` (`club_id`),
  KEY `fk_event_venue` (`venue_id`),
  CONSTRAINT `fk_event_club` FOREIGN KEY (`club_id`) REFERENCES `club` (`club_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_event_venue` FOREIGN KEY (`venue_id`) REFERENCES `venue` (`venue_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_event_budget` CHECK ((`budget_limit` >= 0.00)),
  CONSTRAINT `chk_event_capacity` CHECK ((`capacity` > 0)),
  CONSTRAINT `chk_event_time` CHECK ((`end_at` > `start_at`))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event`
--

LOCK TABLES `event` WRITE;
/*!40000 ALTER TABLE `event` DISABLE KEYS */;
INSERT INTO `event` VALUES (1,1,2,'Build-a-thon Workshop','Hands-on prototyping for student teams','2026-10-14 15:19:01','2026-10-14 18:19:01',60,18000.00,'Approved','The first official hackathon was held by OpenBSD in 1999!'),(2,1,1,'Campus Robotics Showcase','Demonstrations of student robotics projects','2026-10-21 15:19:01','2026-10-21 20:19:01',300,45000.00,'Approved','Robotics algorithms are heavily based on insect navigation techniques.'),(3,2,1,'Monsoon Music Evening','An evening of student music performances','2026-10-28 15:19:01','2026-10-28 19:19:01',350,32000.00,'Approved','Music actually stimulates the same brain areas as food and other rewards.'),(4,3,3,'Campus Clean-up Drive','Volunteer-led clean-up and waste segregation drive','2026-11-04 15:19:01','2026-11-04 18:19:01',250,12000.00,'Approved',NULL),(5,1,2,'Intro to Embedded Systems','A practical session on microcontrollers','2026-11-11 15:19:01','2026-11-11 17:19:01',70,9000.00,'Approved',NULL),(6,2,3,'Inter-College Folk Festival','Folk music and dance performances','2026-11-18 15:19:01','2026-11-18 21:19:01',450,60000.00,'Approved',NULL),(7,3,2,'Repair Cafe','Bring small household items for repair and reuse','2026-11-25 15:19:01','2026-11-25 19:19:01',65,7500.00,'Pending',NULL),(8,1,3,'Annual Innovation Expo','Student project exhibits and demonstrations','2026-12-09 15:19:01','2026-12-09 22:19:01',400,85000.00,'Approved',NULL);
/*!40000 ALTER TABLE `event` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_event_capacity_before_insert` BEFORE INSERT ON `event` FOR EACH ROW BEGIN
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

    SET v_conflict_event = NULL;

    IF v_conflict_event IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Venue already has an event in this time range';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_event_capacity_before_update` BEFORE UPDATE ON `event` FOR EACH ROW BEGIN
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

    SET v_conflict_event = NULL;

    IF v_conflict_event IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Venue already has an event in this time range';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_event_budget_before_update` BEFORE UPDATE ON `event` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `event_registration`
--

DROP TABLE IF EXISTS `event_registration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_registration` (
  `event_id` int NOT NULL,
  `student_id` int NOT NULL,
  `registered_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`event_id`,`student_id`),
  KEY `fk_registration_student` (`student_id`),
  CONSTRAINT `fk_registration_event` FOREIGN KEY (`event_id`) REFERENCES `event` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_registration_student` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_registration`
--

LOCK TABLES `event_registration` WRITE;
/*!40000 ALTER TABLE `event_registration` DISABLE KEYS */;
INSERT INTO `event_registration` VALUES (1,1,'2026-10-07 15:19:01'),(1,2,'2026-10-07 15:19:01'),(1,3,'2026-10-07 15:19:01'),(2,1,'2026-10-07 15:19:01'),(2,3,'2026-10-07 15:27:09'),(2,4,'2026-10-07 15:19:01'),(3,2,'2026-10-07 15:19:01'),(3,5,'2026-10-07 15:19:01'),(4,1,'2026-10-07 15:33:13'),(4,3,'2026-10-07 15:19:01'),(4,6,'2026-10-07 15:19:01'),(5,1,'2026-10-07 15:19:01'),(5,6,'2026-10-07 15:19:01'),(6,2,'2026-10-07 15:19:01'),(6,5,'2026-10-07 15:19:01'),(8,1,'2026-10-07 15:19:01'),(8,3,'2026-10-07 15:19:01'),(8,4,'2026-10-07 15:19:01'),(8,5,'2026-10-07 15:19:01');
/*!40000 ALTER TABLE `event_registration` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_registration_before_insert` BEFORE INSERT ON `event_registration` FOR EACH ROW BEGIN
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

    SET v_registered = 0;

    IF v_registered >= v_capacity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Event capacity has been reached';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_registration_after_insert` AFTER INSERT ON `event_registration` FOR EACH ROW BEGIN
    INSERT INTO Attendance (event_id, student_id, attendance_status)
    VALUES (NEW.event_id, NEW.student_id, 'Not Marked');
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_registration_before_update` BEFORE UPDATE ON `event_registration` FOR EACH ROW BEGIN
    IF NEW.event_id <> OLD.event_id OR NEW.student_id <> OLD.student_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Registration key columns are immutable';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `expense`
--

DROP TABLE IF EXISTS `expense`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `expense` (
  `expense_id` int NOT NULL AUTO_INCREMENT,
  `event_id` int NOT NULL,
  `expense_date` date NOT NULL,
  `category` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  PRIMARY KEY (`expense_id`),
  KEY `fk_expense_event` (`event_id`),
  CONSTRAINT `fk_expense_event` FOREIGN KEY (`event_id`) REFERENCES `event` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_expense_amount` CHECK ((`amount` > 0.00))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expense`
--

LOCK TABLES `expense` WRITE;
/*!40000 ALTER TABLE `expense` DISABLE KEYS */;
INSERT INTO `expense` VALUES (1,1,'2026-10-07','Materials','Prototype components and workshop kits',4200.00),(2,1,'2026-10-07','Refreshments','Water and snacks for participants',1800.00),(3,2,'2026-10-07','Equipment','Display and demonstration equipment rental',12500.00),(4,3,'2026-10-07','Production','Sound and lighting rental',14800.00),(5,4,'2026-10-07','Supplies','Gloves, bags, and sorting materials',2350.00),(6,6,'2026-10-07','Production','Stage and audio equipment',21800.00),(7,8,'2026-10-07','Logistics','Exhibit tables and signage',16750.00);
/*!40000 ALTER TABLE `expense` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_expense_before_insert` BEFORE INSERT ON `expense` FOR EACH ROW BEGIN
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

    SET v_spent = 0;

    IF v_spent + NEW.amount > v_budget THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Expense would exceed the event budget';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_expense_before_update` BEFORE UPDATE ON `expense` FOR EACH ROW BEGIN
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

    SET v_spent = 0;

    IF v_spent + NEW.amount > v_budget THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Updated expense would exceed the event budget';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `faculty`
--

DROP TABLE IF EXISTS `faculty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `faculty` (
  `faculty_id` int NOT NULL AUTO_INCREMENT,
  `faculty_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL,
  `department_id` int NOT NULL,
  PRIMARY KEY (`faculty_id`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_faculty_department` (`department_id`),
  CONSTRAINT `fk_faculty_department` FOREIGN KEY (`department_id`) REFERENCES `department` (`department_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faculty`
--

LOCK TABLES `faculty` WRITE;
/*!40000 ALTER TABLE `faculty` DISABLE KEYS */;
INSERT INTO `faculty` VALUES (1,'Dr. Meera Nair','meera.nair@example.edu',1),(2,'Prof. Arvind Menon','arvind.menon@example.edu',2),(3,'Dr. Kavita Rao','kavita.rao@example.edu',3);
/*!40000 ALTER TABLE `faculty` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback` (
  `feedback_id` int NOT NULL AUTO_INCREMENT,
  `event_id` int NOT NULL,
  `student_id` int NOT NULL,
  `rating` tinyint NOT NULL,
  `comments` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `submitted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`feedback_id`),
  UNIQUE KEY `uq_feedback_event_student` (`event_id`,`student_id`),
  CONSTRAINT `fk_feedback_registration` FOREIGN KEY (`event_id`, `student_id`) REFERENCES `event_registration` (`event_id`, `student_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_feedback_rating` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback`
--

LOCK TABLES `feedback` WRITE;
/*!40000 ALTER TABLE `feedback` DISABLE KEYS */;
INSERT INTO `feedback` VALUES (1,1,1,5,'Well-organized and useful hands-on activities.','2026-10-07 15:19:02'),(2,1,2,4,'Good workshop; more time for the final build would help.','2026-10-07 15:19:02'),(3,3,5,5,'A welcoming evening with a great mix of performances.','2026-10-07 15:19:02'),(4,4,6,4,'Clear volunteer coordination and a visible campus impact.','2026-10-07 15:19:02');
/*!40000 ALTER TABLE `feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student`
--

DROP TABLE IF EXISTS `student`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student` (
  `student_id` int NOT NULL AUTO_INCREMENT,
  `registration_no` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL,
  `department_id` int NOT NULL,
  `enrollment_year` year NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'pbkdf2:sha256:600000$dummy$dummy',
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `registration_no` (`registration_no`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_student_department` (`department_id`),
  CONSTRAINT `fk_student_department` FOREIGN KEY (`department_id`) REFERENCES `department` (`department_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student`
--

LOCK TABLES `student` WRITE;
/*!40000 ALTER TABLE `student` DISABLE KEYS */;
INSERT INTO `student` VALUES (1,'25BCE11231','Aarav','Sharma','aarav.sharma@example.edu',1,2025,'scrypt:32768:8:1$6ZcnrtFQi2936rEm$af2b58999147168ac06ec380f96458bec306fe847f2b820d3843c8d12bb5978b7ea3eb1e3989cee3f4804581c18696d4b6193a37df354ecde3a55e96b1600211'),(2,'25BCE11138','Isha','Patel','isha.patel@example.edu',1,2025,'scrypt:32768:8:1$6ZcnrtFQi2936rEm$af2b58999147168ac06ec380f96458bec306fe847f2b820d3843c8d12bb5978b7ea3eb1e3989cee3f4804581c18696d4b6193a37df354ecde3a55e96b1600211'),(3,'24BEE11042','Rohan','Kumar','rohan.kumar@example.edu',2,2024,'scrypt:32768:8:1$6ZcnrtFQi2936rEm$af2b58999147168ac06ec380f96458bec306fe847f2b820d3843c8d12bb5978b7ea3eb1e3989cee3f4804581c18696d4b6193a37df354ecde3a55e96b1600211'),(4,'24BCE10987','Ananya','Singh','ananya.singh@example.edu',1,2024,'scrypt:32768:8:1$6ZcnrtFQi2936rEm$af2b58999147168ac06ec380f96458bec306fe847f2b820d3843c8d12bb5978b7ea3eb1e3989cee3f4804581c18696d4b6193a37df354ecde3a55e96b1600211'),(5,'23BHS10451','Kabir','Joshi','kabir.joshi@example.edu',3,2023,'scrypt:32768:8:1$6ZcnrtFQi2936rEm$af2b58999147168ac06ec380f96458bec306fe847f2b820d3843c8d12bb5978b7ea3eb1e3989cee3f4804581c18696d4b6193a37df354ecde3a55e96b1600211'),(6,'25BEE11209','Mira','Desai','mira.desai@example.edu',2,2025,'scrypt:32768:8:1$6ZcnrtFQi2936rEm$af2b58999147168ac06ec380f96458bec306fe847f2b820d3843c8d12bb5978b7ea3eb1e3989cee3f4804581c18696d4b6193a37df354ecde3a55e96b1600211');
/*!40000 ALTER TABLE `student` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venue`
--

DROP TABLE IF EXISTS `venue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venue` (
  `venue_id` int NOT NULL AUTO_INCREMENT,
  `venue_name` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `building` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `venue_capacity` int NOT NULL,
  PRIMARY KEY (`venue_id`),
  UNIQUE KEY `venue_name` (`venue_name`),
  CONSTRAINT `chk_venue_capacity` CHECK ((`venue_capacity` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venue`
--

LOCK TABLES `venue` WRITE;
/*!40000 ALTER TABLE `venue` DISABLE KEYS */;
INSERT INTO `venue` VALUES (1,'Central Auditorium','Student Activity Centre',400),(2,'Innovation Lab','Academic Block A',80),(3,'Green Amphitheatre','East Campus Lawn',500);
/*!40000 ALTER TABLE `venue` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_venue_capacity_before_update` BEFORE UPDATE ON `venue` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `vw_upcoming_events`
--

DROP TABLE IF EXISTS `vw_upcoming_events`;
/*!50001 DROP VIEW IF EXISTS `vw_upcoming_events`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_upcoming_events` AS SELECT
 1 AS `event_id`,
 1 AS `event_name`,
 1 AS `start_at`,
 1 AS `end_at`,
 1 AS `club_name`,
 1 AS `venue_name`,
 1 AS `venue_building`,
 1 AS `capacity`,
 1 AS `registered_count`,
 1 AS `seats_remaining`,
 1 AS `fun_fact`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'campus_event_club_db'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_register_for_event` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `sp_register_for_event`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vw_upcoming_events`
--

/*!50001 DROP VIEW IF EXISTS `vw_upcoming_events`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 SQL SECURITY DEFINER */
/*!50001 VIEW `vw_upcoming_events` AS select `e`.`event_id` AS `event_id`,`e`.`event_name` AS `event_name`,`e`.`start_at` AS `start_at`,`e`.`end_at` AS `end_at`,`c`.`club_name` AS `club_name`,`v`.`venue_name` AS `venue_name`,`v`.`building` AS `venue_building`,`e`.`capacity` AS `capacity`,count(`r`.`student_id`) AS `registered_count`,(`e`.`capacity` - count(`r`.`student_id`)) AS `seats_remaining`,`e`.`fun_fact` AS `fun_fact` from (((`event` `e` join `club` `c` on((`c`.`club_id` = `e`.`club_id`))) join `venue` `v` on((`v`.`venue_id` = `e`.`venue_id`))) left join `event_registration` `r` on((`r`.`event_id` = `e`.`event_id`))) where (`e`.`approval_status` = 'Approved') group by `e`.`event_id`,`e`.`event_name`,`e`.`start_at`,`e`.`end_at`,`c`.`club_name`,`v`.`venue_name`,`v`.`building`,`e`.`capacity`,`e`.`fun_fact` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-07 15:50:56

-- Keep the app's event feed limited to approved events that have not started.
CREATE OR REPLACE VIEW vw_upcoming_events AS
SELECT e.event_id,
       e.event_name,
       e.start_at,
       e.end_at,
       c.club_name,
       v.venue_name,
       v.building AS venue_building,
       e.capacity,
       COUNT(r.student_id) AS registered_count,
       e.capacity - COUNT(r.student_id) AS seats_remaining,
       e.fun_fact
  FROM `event` AS e
  JOIN club AS c ON c.club_id = e.club_id
  JOIN venue AS v ON v.venue_id = e.venue_id
  LEFT JOIN event_registration AS r ON r.event_id = e.event_id
 WHERE e.approval_status = 'Approved'
   AND e.start_at >= CURRENT_TIMESTAMP
 GROUP BY e.event_id, e.event_name, e.start_at, e.end_at,
          c.club_name, v.venue_name, v.building, e.capacity, e.fun_fact;
