-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 09, 2024 at 02:17 PM
-- Server version: 8.0.30
-- PHP Version: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `final-mobile`
--

-- --------------------------------------------------------

--
-- Table structure for table `assets`
--

CREATE TABLE `assets` (
  `id` int NOT NULL,
  `asset_name` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `status` enum('Available','Borrowed','Pending','Disable') COLLATE utf8mb4_general_ci DEFAULT 'Available',
  `image` varchar(255) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `assets`
--

INSERT INTO `assets` (`id`, `asset_name`, `status`, `image`) VALUES
(1, 'book01', 'Disable', 'anime-1731142265122-355647945.jpg'),
(2, 'book2', 'Borrowed', '2-1731087736707-265168901.png'),
(3, 'book3', 'Available', '3-1731087749414-263331791.png'),
(4, 'book4', 'Available', '4-1731087761788-756271810.png'),
(5, 'book5', 'Available', '5-1731087777636-583691250.png'),
(6, 'book6', 'Available', '6-1731087789555-92671545.png'),
(7, 'book7', 'Available', '10-1731094300126-773654797.png'),
(8, 'book8', 'Available', 'book01-1731096240156-607717475.jpg'),
(9, 'book9', 'Available', 'book01-1731140429577-984148857.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `borrowing`
--

CREATE TABLE `borrowing` (
  `id` int NOT NULL,
  `asset_id` int NOT NULL,
  `user_id` int NOT NULL,
  `borrow_date` date NOT NULL,
  `return_date` date NOT NULL,
  `status` enum('Pending','Approved','Disapproved') COLLATE utf8mb4_general_ci DEFAULT 'Pending',
  `lender_id` int DEFAULT NULL,
  `returned` enum('True','False') COLLATE utf8mb4_general_ci DEFAULT 'True',
  `staff_name` varchar(30) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `borrowing`
--

INSERT INTO `borrowing` (`id`, `asset_id`, `user_id`, `borrow_date`, `return_date`, `status`, `lender_id`, `returned`, `staff_name`) VALUES
(1, 2, 1, '2024-11-09', '2024-11-20', 'Pending', 2, 'True', NULL),
(2, 2, 1, '2024-11-10', '2024-11-20', 'Disapproved', NULL, 'True', NULL),
(3, 9, 4, '2024-11-10', '2024-11-20', 'Approved', 2, 'True', 'MikeLOL');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `username` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(30) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(260) COLLATE utf8mb4_general_ci NOT NULL,
  `role` enum('Student','Lender','Staff') COLLATE utf8mb4_general_ci DEFAULT 'Student',
  `image` varchar(255) COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `role`, `image`) VALUES
(1, 'Chaloemsak LOL', 'student@gmail.com', '$2b$10$NB8C0Om3HPhaUrW013thGu21SVNuNOt07JufTRWYGrqunymUIOnde', 'Student', 'student.jpg'),
(2, 'bob', 'lender@gmail.com', '$2b$10$c6p273pHlNG4kS/ty1xJDuM2.bweaIhaQULJHbILuz0M0D6y4yRNS', 'Lender', 'lender.jpg'),
(3, 'Chaloemsak', 'staff@gmail.com', '$2b$10$c6p273pHlNG4kS/ty1xJDuM2.bweaIhaQULJHbILuz0M0D6y4yRNS', 'Staff', 'staff.jpg'),
(4, 'student01', 'student01@gmail.com', '$2b$10$10hiojsNchehhInrZ7POm.ebkYOvyYMUmnU5OU2PZbLSFeLRYd1U6', 'Student', 'student.jpg');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `assets`
--
ALTER TABLE `assets`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `borrowing`
--
ALTER TABLE `borrowing`
  ADD PRIMARY KEY (`id`),
  ADD KEY `asset_id` (`asset_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `action_by` (`lender_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `assets`
--
ALTER TABLE `assets`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `borrowing`
--
ALTER TABLE `borrowing`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `borrowing`
--
ALTER TABLE `borrowing`
  ADD CONSTRAINT `borrowing_ibfk_1` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`),
  ADD CONSTRAINT `borrowing_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `borrowing_ibfk_3` FOREIGN KEY (`lender_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
