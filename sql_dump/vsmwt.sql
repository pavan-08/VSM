-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Oct 25, 2016 at 06:30 PM
-- Server version: 10.1.16-MariaDB
-- PHP Version: 7.0.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `vsmwt`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `buy_shares` (IN `coid` INT, IN `usid` INT, IN `num` INT)  MODIFIES SQL DATA
BEGIN
	DECLARE u_money FLOAT(15,2);
    DECLARE b_factor FLOAT(10,8);
    DECLARE c_price FLOAT(10,2);
    DECLARE c_high FLOAT(10,2);
    DECLARE amount FLOAT(15,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @e = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @e;
    END;
    DECLARE EXIT HANDLER FOR SQLSTATE '45000'
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @e = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @e;
    END;
    START TRANSACTION;
       SELECT `money` INTO u_money FROM `user` WHERE `uid`=usid;
       SELECT `current_price`, `day_high`, `buy_factor` INTO c_price, c_high, b_factor FROM `company` WHERE `cid`=coid;
       SET amount = c_price * num;
       IF amount > u_money THEN
    		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT="Not enough balance.";
       END IF;
       SET u_money = u_money - amount;
       UPDATE `user` SET `money`=u_money WHERE `uid`=usid;
       INSERT INTO `transactions`(`bought_at`, `cid`, `count`, `uid`) VALUES(c_price, coid, num, usid);
       SET c_price = c_price + (num * b_factor * 0.001);
       IF c_price > c_high THEN
       		SET c_high = c_price;
       END IF;
       UPDATE `company` SET `current_price`=c_price, `day_high`=c_high WHERE `cid`=coid;
       INSERT INTO `graph`(`cid`, `share_value`) VALUES (coid, c_price);
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `check_premium` (IN `usid` INT)  NO SQL
BEGIN
	DECLARE prem INT;
    DECLARE ver INT;
    DECLARE c INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @e = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @e;
    END;
    DECLARE EXIT HANDLER FOR SQLSTATE '45000'
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @e = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @e;
    END;
	START TRANSACTION;
    	SELECT `premium` INTO prem FROM `user` WHERE `uid`=usid;
        IF prem = 1 THEN
        	SELECT COUNT(*), `verified` INTO c, ver FROM `licensekeys` WHERE `uid`=usid;
            IF c !=1 OR ver != 1 OR ver = NULL THEN
            	UPDATE `licensekeys` SET `uid`=1, `verified`=0 WHERE `uid`=usid;
                UPDATE `user` SET `premium`=0 WHERE `uid`=usid;
            END IF;
        END IF;
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `event_maker` (IN `msg` LONGTEXT, IN `coid` INT, IN `val` FLOAT(10,2))  NO SQL
BEGIN
	DECLARE c_price FLOAT(10,2);
    DECLARE c_high FLOAT(10,2);
    DECLARE c_low FLOAT(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @e = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @e;
    END;
    DECLARE EXIT HANDLER FOR SQLSTATE '45000'
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @e = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @e;
    END;
    START TRANSACTION;
    	SELECT `current_price`, `day_high`, `day_low` INTO c_price, c_high, c_low FROM `company` WHERE `cid`=coid;
        SET c_price = c_price + val;
        IF c_price < 0 THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT="Cant take market value below 0.";
        END IF;
        IF c_price < c_low THEN
        	SET c_low = c_price;
        END IF;
        IF c_price > c_high THEN
        	SET c_high = c_price;
        END IF;
        UPDATE `company` SET `current_price`=c_price, `day_high`=c_high, `day_low`=c_low WHERE `cid`=coid;
        INSERT INTO `events`(`cid`, `message`, `value_difference`) VALUES(coid, msg, val);
        INSERT INTO `graph`(`cid`, `share_value`) VALUES(coid, c_price);
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `go_premium_user` (IN `usid` INT, IN `lkey` VARCHAR(255))  NO SQL
BEGIN
	DECLARE prem INT;
    DECLARE ver INT;
    DECLARE c INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @e = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @e;
    END;
    DECLARE EXIT HANDLER FOR SQLSTATE '45000'
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @e = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @e;
    END;
	START TRANSACTION;
    	SELECT `premium` INTO prem FROM `user` WHERE `uid`=usid;
        IF prem = 0 THEN
        	SELECT COUNT(*), `verified` INTO c, ver FROM `licensekeys` WHERE `id`=lkey;
        	IF ver = 0 AND c = 1 THEN
            	UPDATE `licensekeys` SET `uid`=usid, `verified`=1 WHERE `id`=lkey;
                UPDATE `user` SET `premium`=1 WHERE `uid`=usid;
            ELSE
            	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT="Duplicate license key.";
            END IF;
        END IF;
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `opening_bell` ()  MODIFIES SQL DATA
BEGIN
   UPDATE `company` SET `opening_price`=`current_price` WHERE 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sell_shares` (IN `t_id` INT, IN `usid` INT, IN `num` INT)  MODIFIES SQL DATA
BEGIN
	DECLARE u_money FLOAT(15,2);
    DECLARE s_factor FLOAT(10,8);
    DECLARE coid INT;
    DECLARE c_price FLOAT(10,2);
    DECLARE c_low FLOAT(10,2);
    DECLARE amount FLOAT(15,2);
   	DECLARE ns INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @e = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @e;
    END;
    DECLARE EXIT HANDLER FOR SQLSTATE '45000'
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @e = MESSAGE_TEXT;
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @e;
    END;
    START TRANSACTION;
       SELECT `money` INTO u_money FROM `user` WHERE `uid`=usid;
       SELECT `cid`, `count` INTO coid, ns FROM `transactions` WHERE `uid`=usid AND `tid`=t_id;
       SELECT `current_price`, `day_low`, `sell_factor` INTO c_price, c_low, s_factor FROM `company` WHERE `cid`=coid;
       IF num > ns THEN
    		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT="Not enough shares.";
       END IF;
       SET amount = c_price * ns;
       SET u_money = u_money + amount;
       IF ns > num THEN
       		SET ns = ns - num;
       		UPDATE `transactions` SET `count`=ns WHERE `tid`=t_id;
       ELSE 
       		DELETE FROM `transactions` WHERE `tid`=t_id;
       END IF;
       UPDATE `user` SET `money`=u_money WHERE `uid`=usid;
       SET c_price = c_price - (num * s_factor * 0.001);
       IF c_price < c_low THEN
       		SET c_low = c_price;
       END IF;
       UPDATE `company` SET `current_price`=c_price, `day_low`=c_low WHERE `cid`=coid;
       INSERT INTO `graph`(`cid`, `share_value`) VALUES (coid, c_price);
    COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `company`
--

CREATE TABLE `company` (
  `cid` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `logo` varchar(255) NOT NULL,
  `buy_factor` float(10,8) NOT NULL,
  `sell_factor` float(10,8) NOT NULL,
  `day_low` float(10,2) NOT NULL,
  `day_high` float(10,2) NOT NULL,
  `opening_price` float(10,2) NOT NULL,
  `current_price` float(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `company`
--

INSERT INTO `company` (`cid`, `name`, `logo`, `buy_factor`, `sell_factor`, `day_low`, `day_high`, `opening_price`, `current_price`) VALUES
(1, 'Tata Steel', '', 0.80000001, 0.50000000, 188.30, 376.92, 372.61, 376.67),
(2, 'L&T', '', 0.30000001, 0.50000000, 914.34, 914.59, 914.34, 914.38),
(3, 'HDFC', '', 0.30000001, 0.40000004, 404.34, 744.97, 692.76, 692.82),
(4, 'Infosys', '', 0.10000000, 0.89999998, 147.04, 277.27, 147.19, 147.04),
(5, 'Apple', '', 0.20000000, 0.07000000, 142.23, 147.76, 144.72, 144.92),
(6, 'Reliance Infrastructure', '', 0.70000005, 0.33000001, 821.37, 1155.57, 1140.41, 1140.45),
(7, 'ACC', '', 0.61000001, 0.99999976, 1176.66, 1325.83, 1292.14, 1292.18),
(8, 'Bharti Airtel', '', 0.30000001, 0.30000001, 676.19, 877.59, 852.91, 842.43),
(9, 'Bharat Heavy Electric Ltd', '', 0.30000001, 0.08000000, 209.62, 209.63, 209.62, 209.63),
(10, 'Cipla', '', 0.39999995, 0.50000000, 224.97, 449.94, 423.06, 423.05),
(11, 'Google', '', 0.08000000, 0.00000000, 707.41, 711.71, 707.42, 707.42),
(12, 'HDFC Bank', '', 0.10000002, 0.20000005, 538.22, 577.54, 573.18, 573.18),
(13, 'Hero MotorCorp', '', 0.20000000, 0.89899999, 777.58, 1035.53, 989.90, 989.88),
(14, 'Hindustan Unilever', '', 0.20000002, 0.40000010, 401.34, 700.73, 682.52, 682.51),
(15, 'DLF', '', 0.60000002, 0.40000001, 1478.80, 1752.98, 1750.99, 1750.99),
(16, 'Amazon', '', 0.79999983, 0.29999983, 221.68, 443.58, 438.80, 438.80),
(17, 'Jindal Steel and P', '', 0.08000000, 0.08000000, 373.45, 373.45, 373.45, 373.45),
(18, 'ITC Ltd', '', 0.60000044, 0.20000000, 115.22, 230.44, 228.25, 229.05),
(19, 'State Bank of India', '', 0.69999999, 0.29999995, 285.98, 494.28, 451.58, 451.66),
(20, 'NTPC', '', 0.39999998, 0.39999995, 103.26, 206.52, 200.24, 200.44),
(21, 'ICICI Bank', '', 0.40000001, 0.90000010, 598.07, 768.29, 757.19, 757.13),
(22, 'ONGC Ltd', '', 0.09999994, 0.20000005, 284.47, 568.94, 562.49, 562.49),
(23, 'Reliance Communications', '', 0.29999998, 0.30000001, 1740.57, 1841.64, 1827.59, 1827.59),
(24, 'Reliance Industries', '', 0.50000000, 0.00000007, 1031.62, 1091.57, 1091.56, 1091.57),
(25, 'Maruti Suzuki', '', 0.10000002, 0.09999998, 981.69, 1375.26, 1237.31, 1237.31),
(26, 'Facebook', '', 0.99000007, 0.80000001, 124.42, 248.84, 223.41, 224.09),
(27, 'Flipkart', '', 0.99000007, 0.50000000, 2.50, 51.86, 50.92, 51.36),
(28, 'Alibaba', '', 0.89999998, 0.50000000, 99.99, 199.98, 164.95, 164.96),
(29, 'Twitter', '', 0.39999998, 0.10000000, 212.36, 310.20, 309.67, 309.67),
(30, 'Microsoft', '', 0.40000001, 0.15000001, 315.35, 315.83, 315.35, 315.80),
(31, 'Walmart', '', 0.30000001, 0.10000000, 105.00, 194.34, 105.00, 105.02),
(32, 'Stratton Oakmont', '', 0.30000001, 0.11000001, 20.23, 100.99, 73.39, 73.58);

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `eid` int(11) NOT NULL,
  `cid` int(11) NOT NULL,
  `message` longtext NOT NULL,
  `value_difference` float(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`eid`, `cid`, `message`, `value_difference`) VALUES
(1, 5, 'Apple iPhone sales high', 5.50),
(2, 11, 'Google Pixel launch delayed', -4.30),
(3, 5, 'Apple sales go low, iPhone 7 rolled back', -3.04),
(4, 27, 'Flipkart Diwali sales, start off with a bang!', 3.45),
(5, 8, 'Jio gives tough competition to Airtel', -10.50),
(6, 1, 'Tata steel bought reliance', 2.00),
(7, 1, 'Tata steel gives out a lot of diwali bonus', 1.50);

-- --------------------------------------------------------

--
-- Table structure for table `graph`
--

CREATE TABLE `graph` (
  `cid` int(11) NOT NULL,
  `share_value` float(10,2) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `graph`
--

INSERT INTO `graph` (`cid`, `share_value`, `timestamp`) VALUES
(5, 142.27, '2016-10-17 21:10:59'),
(1, 372.26, '2016-10-17 21:23:55'),
(5, 142.26, '2016-10-17 21:24:18'),
(1, 373.06, '2016-10-17 21:28:11'),
(1, 373.06, '2016-10-17 21:29:08'),
(1, 373.06, '2016-10-17 21:29:20'),
(1, 372.61, '2016-10-17 21:29:40'),
(32, 73.30, '2016-10-18 02:53:29'),
(2, 914.48, '2016-10-18 03:04:03'),
(32, 73.25, '2016-10-18 03:13:41'),
(1, 372.62, '2016-10-18 08:39:22'),
(1, 372.62, '2016-10-18 08:40:03'),
(1, 372.62, '2016-10-18 08:40:14'),
(27, 47.52, '2016-10-19 04:54:41'),
(5, 144.72, '2016-10-19 05:04:55'),
(2, 914.48, '2016-10-19 05:07:26'),
(2, 914.51, '2016-10-19 11:00:22'),
(27, 47.47, '2016-10-19 11:01:11'),
(1, 372.63, '2016-10-19 12:19:14'),
(1, 372.63, '2016-10-19 12:19:50'),
(1, 372.63, '2016-10-19 12:20:19'),
(27, 50.92, '2016-10-19 15:35:02'),
(1, 372.71, '2016-10-19 16:16:15'),
(32, 73.55, '2016-10-19 16:17:04'),
(32, 73.52, '2016-10-19 16:18:11'),
(2, 914.46, '2016-10-20 06:32:01'),
(1, 372.66, '2016-10-20 06:32:26'),
(32, 73.50, '2016-10-20 06:32:34'),
(1, 372.61, '2016-10-20 06:32:49'),
(32, 73.39, '2016-10-20 06:32:57'),
(3, 692.76, '2016-10-20 07:20:52'),
(2, 914.49, '2016-10-20 14:53:10'),
(2, 914.44, '2016-10-20 14:53:35'),
(2, 914.59, '2016-10-20 14:55:06'),
(2, 914.54, '2016-10-20 14:55:34'),
(2, 914.34, '2016-10-20 14:55:49'),
(11, 707.42, '2016-10-20 15:04:05'),
(11, 707.42, '2016-10-20 15:06:35'),
(4, 147.20, '2016-10-20 15:06:51'),
(6, 1140.48, '2016-10-20 15:07:01'),
(7, 1292.15, '2016-10-20 15:07:09'),
(8, 852.94, '2016-10-20 15:07:25'),
(6, 1140.46, '2016-10-20 15:07:40'),
(31, 105.03, '2016-10-20 15:07:59'),
(30, 315.75, '2016-10-20 15:08:09'),
(29, 309.67, '2016-10-20 15:08:23'),
(28, 164.96, '2016-10-20 15:08:32'),
(25, 1237.31, '2016-10-20 15:08:44'),
(30, 315.75, '2016-10-20 15:09:01'),
(24, 1091.57, '2016-10-20 15:09:32'),
(22, 562.49, '2016-10-20 15:09:44'),
(23, 1827.59, '2016-10-20 15:09:57'),
(19, 451.65, '2016-10-20 15:10:04'),
(32, 73.69, '2016-10-20 15:10:18'),
(32, 73.58, '2016-10-20 15:10:31'),
(19, 451.72, '2016-10-20 15:10:47'),
(17, 373.45, '2016-10-20 15:10:55'),
(16, 438.80, '2016-10-20 15:11:00'),
(15, 1750.99, '2016-10-20 15:11:07'),
(14, 682.52, '2016-10-20 15:11:15'),
(13, 989.90, '2016-10-20 15:11:21'),
(12, 573.18, '2016-10-20 15:11:26'),
(10, 423.10, '2016-10-20 15:11:36'),
(9, 209.63, '2016-10-20 15:11:46'),
(8, 852.96, '2016-10-20 15:11:54'),
(3, 692.76, '2016-10-20 15:12:09'),
(4, 147.11, '2016-10-20 15:12:20'),
(7, 1292.14, '2016-10-20 15:12:31'),
(6, 1140.44, '2016-10-20 15:12:47'),
(3, 692.76, '2016-10-20 15:12:53'),
(31, 105.02, '2016-10-20 15:13:00'),
(8, 852.93, '2016-10-20 15:13:06'),
(29, 309.67, '2016-10-20 15:13:12'),
(28, 164.96, '2016-10-20 15:13:19'),
(25, 1237.31, '2016-10-20 15:13:25'),
(22, 562.49, '2016-10-20 15:13:33'),
(24, 1091.57, '2016-10-20 15:13:39'),
(23, 1827.59, '2016-10-20 15:13:48'),
(19, 451.69, '2016-10-20 15:14:02'),
(19, 451.66, '2016-10-20 15:14:08'),
(17, 373.45, '2016-10-20 15:14:14'),
(16, 438.80, '2016-10-20 15:14:20'),
(15, 1750.99, '2016-10-20 15:14:25'),
(14, 682.51, '2016-10-20 15:14:32'),
(13, 989.88, '2016-10-20 15:14:41'),
(9, 209.63, '2016-10-20 15:14:51'),
(10, 423.05, '2016-10-20 15:14:58'),
(12, 573.18, '2016-10-20 15:15:04'),
(30, 315.83, '2016-10-20 15:17:14'),
(30, 315.80, '2016-10-20 15:17:39'),
(4, 147.12, '2016-10-20 15:18:10'),
(18, 229.45, '2016-10-20 15:21:52'),
(18, 229.05, '2016-10-20 15:22:15'),
(26, 224.40, '2016-10-20 15:23:48'),
(26, 224.89, '2016-10-20 15:23:55'),
(21, 757.23, '2016-10-20 15:24:09'),
(20, 200.32, '2016-10-20 15:24:17'),
(20, 200.28, '2016-10-20 15:24:33'),
(20, 200.48, '2016-10-20 15:24:47'),
(20, 200.44, '2016-10-20 15:25:00'),
(26, 224.09, '2016-10-20 15:25:09'),
(21, 757.18, '2016-10-20 15:25:32'),
(21, 757.22, '2016-10-20 15:25:48'),
(21, 757.13, '2016-10-20 15:26:10'),
(27, 50.87, '2016-10-20 18:34:00'),
(1, 372.11, '2016-10-20 18:34:24'),
(3, 692.76, '2016-10-20 18:34:48'),
(2, 914.34, '2016-10-20 18:34:59'),
(1, 372.91, '2016-10-20 18:38:48'),
(1, 372.41, '2016-10-20 18:39:06'),
(1, 373.37, '2016-10-20 18:39:35'),
(1, 372.77, '2016-10-20 18:39:45'),
(27, 51.86, '2016-10-20 18:40:23'),
(8, 842.43, '2016-10-21 09:41:53'),
(1, 372.85, '2016-10-21 09:45:15'),
(1, 372.83, '2016-10-21 09:45:35'),
(27, 51.36, '2016-10-23 17:34:23'),
(7, 1292.20, '2016-10-24 04:39:05'),
(3, 692.79, '2016-10-24 04:39:24'),
(7, 1292.18, '2016-10-24 04:39:50'),
(1, 374.83, '2016-10-24 04:41:59'),
(2, 914.37, '2016-10-24 06:09:11'),
(3, 692.82, '2016-10-24 06:11:04'),
(5, 144.92, '2016-10-24 06:11:11'),
(6, 1140.45, '2016-10-24 06:11:26'),
(9, 209.63, '2016-10-24 06:11:38'),
(4, 147.12, '2016-10-24 06:11:57'),
(4, 147.12, '2016-10-24 06:12:19'),
(4, 147.13, '2016-10-24 06:12:28'),
(4, 147.04, '2016-10-24 06:12:42'),
(2, 914.38, '2016-10-24 08:21:16'),
(1, 375.23, '2016-10-24 08:24:13'),
(1, 374.98, '2016-10-24 08:25:24'),
(1, 376.48, '2016-10-24 08:25:33'),
(1, 376.88, '2016-10-24 08:26:08'),
(1, 376.92, '2016-10-24 08:27:20'),
(1, 376.92, '2016-10-24 08:27:38'),
(1, 376.67, '2016-10-24 08:30:05');

-- --------------------------------------------------------

--
-- Table structure for table `licensekeys`
--

CREATE TABLE `licensekeys` (
  `id` varchar(255) CHARACTER SET utf8 NOT NULL,
  `uid` int(11) NOT NULL DEFAULT '1',
  `verified` int(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `licensekeys`
--

INSERT INTO `licensekeys` (`id`, `uid`, `verified`) VALUES
('00F0827D4A', 2, 1),
('02D9E12E34', 12, 1),
('04F0AFEEC5', 1, 0),
('07E11DEF49', 16, 1),
('09A2944623', 15, 1),
('0CD949D599', 1, 0),
('0E56977116', 1, 0),
('0E651059FD', 1, 0),
('106EF30846', 1, 0),
('18D2299FF5', 1, 0),
('1918DB7BEA', 1, 0),
('1EFB313401', 1, 0),
('22A09F87B2', 1, 0),
('260342F6BF', 1, 0),
('26AA3D991D', 1, 0),
('2BE3B4AB70', 1, 0),
('2C07B61D7C', 1, 0),
('2D9A06E254', 1, 0),
('32099C2382', 1, 0),
('3939C65BCD', 1, 0),
('3D956DBE44', 1, 0),
('3DCD73EB3D', 1, 0),
('3E48B2CA06', 1, 0),
('407F90791A', 1, 0),
('45321FB01C', 1, 0),
('497E67115F', 1, 0),
('4B8E4E65CA', 1, 0),
('4C1FE2F170', 1, 0),
('4C4F7E9B0F', 1, 0),
('4EFCD27C75', 1, 0),
('54F2866300', 1, 0),
('5A79889C50', 1, 0),
('6085F33456', 1, 0),
('60CCDFC348', 1, 0),
('64DDA749C8', 1, 0),
('6C218154BA', 1, 0),
('6C8FA1D2D1', 1, 0),
('6E8C43B842', 1, 0),
('71437AEE18', 1, 0),
('743F5AA9E7', 1, 0),
('7D44DA7726', 1, 0),
('7D62269F1A', 1, 0),
('7F7C25B531', 1, 0),
('7FC407AF6A', 1, 0),
('800231DF3F', 1, 0),
('80F47811C4', 1, 0),
('87038ED867', 1, 0),
('876A36A84C', 1, 0),
('8846367245', 1, 0),
('8A38995206', 1, 0),
('8B6F52CA00', 1, 0),
('8C9835A675', 1, 0),
('8D52AA52EE', 1, 0),
('952518FBA6', 1, 0),
('9BB8E66971', 1, 0),
('9E9D00F929', 1, 0),
('9FBF18BEDD', 1, 0),
('A0EE97930A', 1, 0),
('A2A25CD845', 1, 0),
('A33A21B98C', 1, 0),
('A4B26C5315', 1, 0),
('A7E5C29253', 1, 0),
('ADA8FF3BBB', 1, 0),
('ADCD1EC291', 1, 0),
('B6D07DAFBB', 1, 0),
('BA74D58B1A', 1, 0),
('BB791EB7D0', 1, 0),
('BD8E622D3D', 1, 0),
('C07D749A8B', 1, 0),
('C12967F678', 1, 0),
('C1539DDBA4', 1, 0),
('C357FD112C', 1, 0),
('C422FFA9D3', 1, 0),
('C42357BCB1', 1, 0),
('C509B11CB8', 1, 0),
('C59867C0CF', 1, 0),
('C8F0C21A27', 1, 0),
('C9D2DDDFCC', 1, 0),
('CD144D574C', 1, 0),
('CD90BBF07E', 1, 0),
('D08929AA75', 1, 0),
('D56DD5F5F7', 1, 0),
('D8E989CE63', 1, 0),
('DD551601BA', 1, 0),
('DE99E51E4D', 1, 0),
('E38A999F72', 1, 0),
('E3C60E99E4', 1, 0),
('E7BC958133', 1, 0),
('EA571B9A3A', 1, 0),
('EC535762DE', 1, 0),
('EE4A6BF0C4', 1, 0),
('F08DB7A949', 1, 0),
('F1D71B8ED8', 1, 0),
('F7579F51D4', 1, 0),
('F7DFB354DD', 1, 0),
('F9FCED776E', 1, 0),
('FABA36CF82', 1, 0),
('FAF488A7A4', 1, 0),
('FE4E94EFAF', 1, 0),
('FECB03D50E', 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `tid` int(11) NOT NULL,
  `count` int(11) NOT NULL,
  `uid` int(11) NOT NULL,
  `cid` int(11) NOT NULL,
  `bought_at` float(10,2) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`tid`, `count`, `uid`, `cid`, `bought_at`, `timestamp`) VALUES
(10, 10, 1, 2, 914.48, '2016-10-18 03:04:03'),
(12, 10, 1, 2, 914.48, '2016-10-19 05:07:26'),
(13, 100, 1, 2, 914.48, '2016-10-19 11:00:22'),
(44, 80, 1, 8, 852.94, '2016-10-20 15:11:54'),
(46, 100, 1, 4, 147.11, '2016-10-20 15:18:10'),
(49, 500, 1, 26, 224.40, '2016-10-20 15:23:55'),
(50, 50, 1, 21, 757.19, '2016-10-20 15:24:08'),
(52, 500, 1, 20, 200.28, '2016-10-20 15:24:47'),
(56, 50, 14, 1, 372.77, '2016-10-21 09:45:15'),
(57, 80, 15, 7, 1292.14, '2016-10-24 04:39:05'),
(58, 100, 15, 3, 692.76, '2016-10-24 04:39:24'),
(59, 100, 12, 2, 914.34, '2016-10-24 06:09:11'),
(60, 100, 14, 3, 692.79, '2016-10-24 06:11:04'),
(61, 1000, 14, 5, 144.72, '2016-10-24 06:11:11'),
(62, 10, 14, 6, 1140.44, '2016-10-24 06:11:26'),
(63, 10, 14, 9, 209.63, '2016-10-24 06:11:38'),
(64, 5, 14, 4, 147.12, '2016-10-24 06:11:57'),
(66, 50, 16, 2, 914.37, '2016-10-24 08:21:16'),
(69, 40, 16, 1, 376.88, '2016-10-24 08:27:20');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `uid` int(11) NOT NULL,
  `fname` varchar(100) NOT NULL,
  `lname` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) CHARACTER SET utf8 NOT NULL,
  `money` float(15,2) NOT NULL DEFAULT '500000.00',
  `gender` varchar(1) NOT NULL,
  `DOB` date NOT NULL,
  `premium` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`uid`, `fname`, `lname`, `username`, `password`, `email`, `money`, `gender`, `DOB`, `premium`) VALUES
(1, 'Pavan', 'Chhatpar', 'admin', '81dc9bdb52d04dc20036dbd8313ed055', 'pavanchhatpar@gmail.com', 640301.31, 'M', '1996-11-08', 0),
(2, 'Prashant', 'Dombale', 'drashantpombale', '827ccb0eea8a706c4c34a16891f84e7b', 'prashant.dombale@ves.ac.in', 500000.00, 'm', '1996-07-26', 1),
(12, 'Pavan', 'Chhatpar', 'pavan008', '81dc9bdb52d04dc20036dbd8313ed055', 'pavan.chhatpar@ves.ac.in', 413016.91, 'm', '1996-11-08', 1),
(13, 'Pavan', 'Chhatpar', 'p1', '217b5919c5d9b4a96944a3fdb8a619ed', 'pavan@ves.ac.in', 500000.00, 'm', '1996-11-08', 0),
(14, 'Hacker', 'Hacker', 'hacker', '64ae1a7bac6c82e5092e17707e780522', 'hacker@hacker.com', 272509.28, 'm', '1996-11-08', 0),
(15, 'sashwin', 'adnani', 'sashwin', '254c680440f389b090507fe9f04ff2c2', 'sashwin.adnani@ves.ac.in', 430730.00, 'm', '1997-03-09', 1),
(16, 'Juhi', 'Bhagtani', 'jsb', 'dc942d84ef6ada86e2ae8ba3d1898ba7', 'juhi.bhagtani@ves.ac.in', 454283.50, 'f', '1997-01-10', 1),
(17, 'Prashant', 'Dombale', 'ddaddawd', '70b4269b412a8af42b1f7b0d26eceff2', 'prashant.dombale@gmail.com', 500000.00, 'm', '2016-10-22', 0),
(22, 'hardik', 'patil', 'kirito', '7f75006581f3342295d496b61d6b0e9c', 'hadik.patil@ves.ac.in', 500420.09, 'm', '2014-05-18', 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `company`
--
ALTER TABLE `company`
  ADD PRIMARY KEY (`cid`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`eid`),
  ADD KEY `events_comp_fk` (`cid`);

--
-- Indexes for table `graph`
--
ALTER TABLE `graph`
  ADD KEY `graph_company_fk` (`cid`);

--
-- Indexes for table `licensekeys`
--
ALTER TABLE `licensekeys`
  ADD PRIMARY KEY (`id`),
  ADD KEY `licen_user_fk` (`uid`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`tid`),
  ADD KEY `transaction_user_fk` (`uid`),
  ADD KEY `transaction_company_fk` (`cid`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`uid`),
  ADD UNIQUE KEY `user_uniq` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `company`
--
ALTER TABLE `company`
  MODIFY `cid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;
--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `eid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `tid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;
--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `uid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `events`
--
ALTER TABLE `events`
  ADD CONSTRAINT `events_comp_fk` FOREIGN KEY (`cid`) REFERENCES `company` (`cid`);

--
-- Constraints for table `graph`
--
ALTER TABLE `graph`
  ADD CONSTRAINT `graph_company_fk` FOREIGN KEY (`cid`) REFERENCES `company` (`cid`);

--
-- Constraints for table `licensekeys`
--
ALTER TABLE `licensekeys`
  ADD CONSTRAINT `licen_user_fk` FOREIGN KEY (`uid`) REFERENCES `user` (`uid`);

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transaction_company_fk` FOREIGN KEY (`cid`) REFERENCES `company` (`cid`),
  ADD CONSTRAINT `transaction_user_fk` FOREIGN KEY (`uid`) REFERENCES `user` (`uid`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
