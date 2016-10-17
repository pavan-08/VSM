-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Oct 17, 2016 at 11:56 PM
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
(1, 'Tata Steel', '', 0.80000001, 0.50000000, 188.30, 376.46, 372.61, 372.61),
(2, 'L&T', '', 0.30000001, 0.50000000, 914.45, 914.48, 914.48, 914.48),
(3, 'HDFC', '', 0.30000001, 0.40000004, 404.34, 744.97, 692.76, 692.76),
(4, 'Infosys', '', 0.10000000, 0.89999998, 147.19, 277.27, 147.19, 147.19),
(5, 'Apple', '', 0.20000000, 0.07000000, 142.23, 147.76, 142.26, 147.76),
(6, 'Reliance Infrastructure', '', 0.70000005, 0.33000001, 821.37, 1155.57, 1140.41, 1140.41),
(7, 'ACC', '', 0.61000001, 0.99999976, 1176.66, 1325.83, 1292.14, 1292.14),
(8, 'Bharti Airtel', '', 0.30000001, 0.30000001, 676.19, 877.59, 852.91, 852.91),
(9, 'Bharat Heavy Electric Ltd', '', 0.30000001, 0.08000000, 209.62, 209.62, 209.62, 209.62),
(10, 'Cipla', '', 0.39999995, 0.50000000, 224.97, 449.94, 423.06, 423.06),
(11, 'Google', '', 0.08000000, 0.00000000, 707.41, 711.71, 711.71, 707.41),
(12, 'HDFC Bank', '', 0.10000002, 0.20000005, 538.22, 577.54, 573.18, 573.18),
(13, 'Hero MotorCorp', '', 0.20000000, 0.89899999, 777.58, 1035.53, 989.90, 989.90),
(14, 'Hindustan Unilever', '', 0.20000002, 0.40000010, 401.34, 700.73, 682.52, 682.52),
(15, 'DLF', '', 0.60000002, 0.40000001, 1478.80, 1752.98, 1750.99, 1750.99),
(16, 'Amazon', '', 0.79999983, 0.29999983, 221.68, 443.58, 438.80, 438.80),
(17, 'Jindal Steel and P', '', 0.08000000, 0.08000000, 373.45, 373.45, 373.45, 373.45),
(18, 'ITC Ltd', '', 0.60000044, 0.20000000, 115.22, 230.44, 228.25, 228.25),
(19, 'State Bank of India', '', 0.69999999, 0.29999995, 285.98, 494.28, 451.58, 451.58),
(20, 'NTPC', '', 0.39999998, 0.39999995, 103.26, 206.52, 200.24, 200.24),
(21, 'ICICI Bank', '', 0.40000001, 0.90000010, 598.07, 768.29, 757.19, 757.19),
(22, 'ONGC Ltd', '', 0.09999994, 0.20000005, 284.47, 568.94, 562.49, 562.49),
(23, 'Reliance Communications', '', 0.29999998, 0.30000001, 1740.57, 1841.64, 1827.59, 1827.59),
(24, 'Reliance Industries', '', 0.50000000, 0.00000007, 1031.62, 1091.56, 1091.56, 1091.56),
(25, 'Maruti Suzuki', '', 0.10000002, 0.09999998, 981.69, 1375.26, 1237.31, 1237.31),
(26, 'Facebook', '', 0.99000007, 0.80000001, 124.42, 248.84, 223.41, 223.41),
(27, 'Flipkart', '', 0.99000007, 0.50000000, 2.50, 48.00, 47.42, 47.42),
(28, 'Alibaba', '', 0.89999998, 0.50000000, 99.99, 199.98, 164.95, 164.95),
(29, 'Twitter', '', 0.39999998, 0.01000000, 212.36, 310.20, 309.67, 309.67),
(30, 'Microsoft', '', 0.40000001, 0.00000000, 315.35, 315.35, 315.35, 315.35),
(31, 'Walmart', '', 0.30000001, 0.10000000, 105.00, 194.34, 105.00, 105.00),
(32, 'Stratton Oakmont', '', 0.30000001, 0.11000001, 20.23, 100.99, 73.00, 73.00);

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
(2, 11, 'Google Pixel launch delayed', -4.30);

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
(1, 372.61, '2016-10-17 21:29:40');

-- --------------------------------------------------------

--
-- Table structure for table `licensekeys`
--

CREATE TABLE `licensekeys` (
  `id` varchar(255) CHARACTER SET utf8 NOT NULL,
  `uid` int(11) NOT NULL,
  `verified` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
(2, 1000, 12, 1, 371.46, '2016-10-17 19:29:40'),
(3, 10, 12, 2, 914.45, '2016-10-17 19:32:04'),
(4, 5, 12, 3, 692.76, '2016-10-17 19:33:18'),
(5, 100, 12, 27, 47.32, '2016-10-17 19:34:04'),
(6, 100, 1, 2, 914.45, '2016-10-17 19:48:18'),
(8, 100, 1, 1, 372.26, '2016-10-17 21:28:11');

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
(1, 'Pavan', 'Chhatpar', 'pavan08', '81dc9bdb52d04dc20036dbd8313ed055', 'pavanchhatpar@gmail.com', 411236.38, 'M', '1996-11-08', 0),
(2, 'Prashant', 'Dombale', 'drashantpombale', '827ccb0eea8a706c4c34a16891f84e7b', 'prashant.dombale@ves.ac.in', 500000.00, 'm', '1996-07-26', 0),
(12, 'Pavan', 'Chhatpar', 'pavan008', '81dc9bdb52d04dc20036dbd8313ed055', 'pavan.chhatpar@ves.ac.in', 111199.70, 'm', '1996-11-08', 0),
(13, 'Pavan', 'Chhatpar', 'p1', '217b5919c5d9b4a96944a3fdb8a619ed', 'pavan@ves.ac.in', 500000.00, 'm', '1996-11-08', 0);

-- --------------------------------------------------------

--
-- Table structure for table `watchlist`
--

CREATE TABLE `watchlist` (
  `uid` int(11) NOT NULL,
  `cid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
-- Indexes for table `watchlist`
--
ALTER TABLE `watchlist`
  ADD KEY `watch_user_fk` (`uid`),
  ADD KEY `watch_company_fk` (`cid`);

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
  MODIFY `eid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `tid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `uid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
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

--
-- Constraints for table `watchlist`
--
ALTER TABLE `watchlist`
  ADD CONSTRAINT `watch_company_fk` FOREIGN KEY (`cid`) REFERENCES `company` (`cid`),
  ADD CONSTRAINT `watch_user_fk` FOREIGN KEY (`uid`) REFERENCES `user` (`uid`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
