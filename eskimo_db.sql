-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 31, 2025 at 01:19 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.1.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `eskimo_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `customers`
--
DELIMITER $$
CREATE TRIGGER `trg_update_customer_count_after_delete` AFTER DELETE ON `customers` FOR EACH ROW BEGIN
    DECLARE total_customers INT;
    SELECT COUNT(*) INTO total_customers FROM customers;
    UPDATE tbl_konten_layanan SET statistik_data = total_customers WHERE nama_data = 'Pelanggan Tetap';
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_update_customer_count_after_insert` AFTER INSERT ON `customers` FOR EACH ROW BEGIN
    DECLARE total_customers INT;
    SELECT COUNT(*) INTO total_customers FROM customers;
    UPDATE tbl_konten_layanan SET statistik_data = total_customers WHERE nama_data = 'Pelanggan Tetap';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `order_date` date NOT NULL,
  `status` enum('pending','processed','delivered','canceled') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_details`
--

CREATE TABLE `order_details` (
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `supplier_id` int(11) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `supplier_id`, `name`, `price`, `stock`) VALUES
(2, 5, 'Es Balok Premium #1', 18963.00, 198),
(3, 1, 'Es Balok Premium #2', 67582.00, 111),
(4, 3, 'Ice Cube Kiloan #3', 54606.00, 60),
(5, 4, 'Dry Ice Super #4', 23684.00, 108),
(6, 2, 'Es Balok Kemasan #5', 10433.00, 73),
(7, 1, 'Ice Cube Super #6', 66243.00, 133),
(8, 5, 'Es Kristal Kiloan #7', 29995.00, 38),
(9, 2, 'Es Serut Ekonomis #8', 13263.00, 197),
(10, 1, 'Es Balok Kiloan #9', 68745.00, 97),
(11, 2, 'Es Balok Kemasan #10', 64922.00, 116),
(12, 2, 'Es Kristal Ekonomis #11', 67547.00, 155),
(13, 4, 'Dry Ice Premium #12', 95286.00, 53),
(14, 1, 'Es Serut Kiloan #13', 47190.00, 47),
(15, 3, 'Es Serut Ekonomis #14', 66282.00, 130),
(16, 4, 'Es Serut Premium #15', 60723.00, 105),
(17, 1, 'Ice Cube Kiloan #16', 46831.00, 112),
(18, 1, 'Es Balok Kiloan #17', 39133.00, 41),
(19, 3, 'Es Serut Premium #18', 77146.00, 113),
(20, 1, 'Es Kristal Premium #19', 34578.00, 26),
(21, 2, 'Es Kristal Premium #20', 14079.00, 29),
(22, 3, 'Ice Cube Kemasan #21', 93890.00, 115),
(23, 3, 'Dry Ice Kiloan #22', 60138.00, 45),
(24, 2, 'Ice Cube Premium #23', 11383.00, 158),
(25, 4, 'Es Serut Ekonomis #24', 80354.00, 193),
(26, 4, 'Es Kristal Super #25', 87088.00, 175),
(27, 2, 'Es Balok Premium #26', 55048.00, 174),
(28, 3, 'Ice Cube Ekonomis #27', 61755.00, 176),
(29, 5, 'Ice Cube Premium #28', 78179.00, 42),
(30, 1, 'Es Balok Kemasan #29', 83978.00, 70),
(31, 3, 'Es Serut Premium #30', 99214.00, 139),
(32, 5, 'Es Serut Super #31', 13748.00, 196),
(33, 2, 'Ice Cube Ekonomis #32', 92679.00, 179),
(34, 5, 'Es Serut Premium #33', 54034.00, 22),
(35, 1, 'Ice Cube Super #34', 70020.00, 82),
(36, 1, 'Ice Cube Ekonomis #35', 45130.00, 171),
(37, 5, 'Dry Ice Ekonomis #36', 75537.00, 165),
(38, 4, 'Es Balok Ekonomis #37', 24198.00, 101),
(39, 2, 'Es Balok Kemasan #38', 57497.00, 196),
(40, 4, 'Es Balok Ekonomis #39', 45266.00, 29),
(41, 5, 'Es Balok Kemasan #40', 27401.00, 150),
(42, 1, 'Ice Cube Ekonomis #41', 66807.00, 59),
(43, 2, 'Es Kristal Kiloan #42', 35439.00, 78),
(44, 1, 'Es Kristal Kiloan #43', 80255.00, 164),
(45, 3, 'Es Balok Ekonomis #44', 28726.00, 106),
(46, 2, 'Dry Ice Super #45', 15739.00, 158),
(47, 2, 'Es Kristal Ekonomis #46', 60627.00, 151),
(48, 3, 'Dry Ice Ekonomis #47', 64302.00, 15),
(49, 3, 'Es Kristal Ekonomis #48', 72443.00, 171),
(50, 3, 'Es Serut Super #49', 14344.00, 56),
(51, 3, 'Es Serut Kemasan #50', 97942.00, 53),
(52, 1, 'Es Serut Super #51', 21883.00, 141),
(53, 1, 'Es Kristal Ekonomis #52', 80262.00, 31),
(54, 3, 'Es Serut Kiloan #53', 81958.00, 117),
(55, 1, 'Ice Cube Kemasan #54', 71607.00, 37),
(56, 2, 'Es Kristal Ekonomis #55', 95702.00, 158),
(57, 5, 'Es Serut Super #56', 26463.00, 132),
(58, 1, 'Es Kristal Kemasan #57', 97433.00, 84),
(59, 3, 'Es Balok Kiloan #58', 58653.00, 24),
(60, 1, 'Es Balok Super #59', 88875.00, 130),
(61, 3, 'Es Kristal Kemasan #60', 19505.00, 158),
(62, 1, 'Dry Ice Kemasan #61', 13628.00, 144),
(63, 2, 'Es Kristal Premium #62', 64494.00, 186),
(64, 5, 'Ice Cube Kemasan #63', 47249.00, 66),
(65, 4, 'Es Balok Ekonomis #64', 23124.00, 154),
(66, 2, 'Ice Cube Kiloan #65', 34986.00, 87),
(67, 4, 'Es Kristal Kemasan #66', 59822.00, 54),
(68, 1, 'Ice Cube Kiloan #67', 84901.00, 157),
(69, 5, 'Es Serut Kemasan #68', 52065.00, 75),
(70, 1, 'Es Balok Kemasan #69', 71871.00, 63),
(71, 3, 'Dry Ice Premium #70', 99909.00, 62),
(72, 4, 'Es Balok Super #71', 15545.00, 68),
(73, 2, 'Es Kristal Super #72', 33958.00, 54),
(74, 4, 'Es Serut Kiloan #73', 25242.00, 193),
(75, 3, 'Es Balok Kemasan #74', 86133.00, 149),
(76, 2, 'Es Balok Kemasan #75', 51410.00, 56),
(77, 4, 'Ice Cube Kemasan #76', 27697.00, 178),
(78, 5, 'Ice Cube Kiloan #77', 23463.00, 184),
(79, 1, 'Es Kristal Kemasan #78', 96469.00, 114),
(80, 5, 'Es Balok Kemasan #79', 34346.00, 51),
(81, 5, 'Ice Cube Premium #80', 44438.00, 194),
(82, 4, 'Es Balok Ekonomis #81', 58221.00, 147),
(83, 4, 'Dry Ice Ekonomis #82', 76392.00, 181),
(84, 2, 'Dry Ice Kiloan #83', 97703.00, 82),
(85, 5, 'Es Serut Kiloan #84', 37138.00, 113),
(86, 2, 'Es Kristal Premium #85', 40954.00, 28),
(87, 1, 'Es Serut Super #86', 66127.00, 172),
(88, 2, 'Es Balok Kiloan #87', 85285.00, 89),
(89, 5, 'Es Balok Premium #88', 28401.00, 181),
(90, 2, 'Es Serut Kemasan #89', 55547.00, 89),
(91, 1, 'Ice Cube Premium #90', 12076.00, 51),
(92, 4, 'Es Kristal Premium #91', 58001.00, 194),
(93, 3, 'Es Balok Kiloan #92', 49862.00, 154),
(94, 5, 'Ice Cube Ekonomis #93', 41558.00, 44),
(95, 2, 'Es Balok Kemasan #94', 20757.00, 109),
(96, 5, 'Es Balok Premium #95', 33853.00, 123),
(97, 2, 'Ice Cube Super #96', 69972.00, 142),
(98, 1, 'Ice Cube Kiloan #97', 29557.00, 153),
(99, 1, 'Es Kristal Ekonomis #98', 52553.00, 64),
(100, 1, 'Es Serut Kiloan #99', 90553.00, 45),
(101, 5, 'Es Kristal Kiloan #100', 98104.00, 92),
(102, 5, 'Ice Cube Super #101', 21140.00, 27),
(103, 1, 'Es Kristal Kemasan #102', 37047.00, 115),
(104, 2, 'Es Balok Premium #103', 19812.00, 145),
(105, 2, 'Ice Cube Super #104', 97623.00, 101),
(106, 4, 'Es Kristal Kemasan #105', 40899.00, 99),
(107, 4, 'Es Kristal Ekonomis #106', 13069.00, 145),
(108, 1, 'Es Balok Ekonomis #107', 85147.00, 67),
(109, 1, 'Es Serut Kemasan #108', 71547.00, 187),
(110, 1, 'Es Kristal Ekonomis #109', 88377.00, 20),
(111, 4, 'Dry Ice Kiloan #110', 42878.00, 60),
(112, 2, 'Es Balok Kiloan #111', 69146.00, 183),
(113, 4, 'Es Balok Ekonomis #112', 79300.00, 32),
(114, 1, 'Dry Ice Premium #113', 54622.00, 113),
(115, 2, 'Dry Ice Kemasan #114', 27996.00, 100),
(116, 4, 'Es Serut Kiloan #115', 46155.00, 171),
(117, 1, 'Dry Ice Kiloan #116', 94885.00, 113),
(118, 3, 'Es Balok Kiloan #117', 25622.00, 155),
(119, 5, 'Ice Cube Kiloan #118', 61972.00, 117),
(120, 2, 'Es Balok Super #119', 71879.00, 173),
(121, 2, 'Es Balok Premium #120', 73768.00, 11),
(122, 2, 'Ice Cube Kemasan #121', 63234.00, 41),
(123, 1, 'Dry Ice Ekonomis #122', 66288.00, 147),
(124, 3, 'Dry Ice Kiloan #123', 86928.00, 85),
(125, 2, 'Dry Ice Kemasan #124', 74074.00, 134),
(126, 3, 'Dry Ice Kiloan #125', 56085.00, 140),
(127, 3, 'Es Kristal Ekonomis #126', 40083.00, 12),
(128, 2, 'Dry Ice Kemasan #127', 30949.00, 66),
(129, 3, 'Es Serut Premium #128', 81927.00, 67),
(130, 3, 'Ice Cube Super #129', 15382.00, 117),
(131, 5, 'Ice Cube Super #130', 68484.00, 33),
(132, 5, 'Es Balok Kemasan #131', 86440.00, 134),
(133, 5, 'Es Serut Super #132', 54005.00, 16),
(134, 5, 'Ice Cube Ekonomis #133', 87520.00, 22),
(135, 3, 'Ice Cube Super #134', 67437.00, 100),
(136, 5, 'Es Kristal Premium #135', 99423.00, 135),
(137, 4, 'Ice Cube Kiloan #136', 55666.00, 50),
(138, 1, 'Ice Cube Super #137', 81519.00, 63),
(139, 4, 'Es Balok Premium #138', 73313.00, 104),
(140, 2, 'Dry Ice Ekonomis #139', 60883.00, 92),
(141, 2, 'Es Serut Ekonomis #140', 23300.00, 106),
(142, 2, 'Ice Cube Ekonomis #141', 56518.00, 105),
(143, 3, 'Es Balok Ekonomis #142', 52265.00, 115),
(144, 5, 'Dry Ice Premium #143', 54434.00, 37),
(145, 4, 'Es Serut Ekonomis #144', 23544.00, 145),
(146, 4, 'Es Serut Premium #145', 47855.00, 60),
(147, 3, 'Es Kristal Ekonomis #146', 47483.00, 16),
(148, 1, 'Es Serut Super #147', 98363.00, 195),
(149, 5, 'Es Kristal Super #148', 41937.00, 174),
(150, 4, 'Es Serut Premium #149', 66025.00, 194),
(151, 4, 'Dry Ice Ekonomis #150', 46338.00, 56),
(152, 1, 'Es Serut Kemasan #151', 81457.00, 17),
(153, 4, 'Ice Cube Ekonomis #152', 66688.00, 35),
(154, 4, 'Dry Ice Kemasan #153', 78476.00, 98),
(155, 5, 'Dry Ice Ekonomis #154', 44726.00, 16),
(156, 1, 'Ice Cube Ekonomis #155', 31543.00, 192),
(157, 4, 'Dry Ice Kemasan #156', 19696.00, 130),
(158, 3, 'Es Serut Premium #157', 76152.00, 199),
(159, 2, 'Es Balok Kiloan #158', 16897.00, 89),
(160, 4, 'Ice Cube Premium #159', 67021.00, 199),
(161, 5, 'Es Balok Kiloan #160', 26291.00, 133),
(162, 2, 'Ice Cube Kiloan #161', 16690.00, 118),
(163, 2, 'Es Kristal Premium #162', 97444.00, 41),
(164, 2, 'Dry Ice Premium #163', 40432.00, 65),
(165, 2, 'Es Kristal Premium #164', 56815.00, 70),
(166, 1, 'Ice Cube Premium #165', 15416.00, 21),
(167, 5, 'Dry Ice Super #166', 45323.00, 167),
(168, 3, 'Es Balok Super #167', 83411.00, 21),
(169, 2, 'Es Serut Ekonomis #168', 49917.00, 169),
(170, 4, 'Es Kristal Premium #169', 13409.00, 141),
(171, 2, 'Es Kristal Kemasan #170', 49893.00, 108),
(172, 4, 'Es Serut Premium #171', 51931.00, 153),
(173, 5, 'Es Balok Ekonomis #172', 67484.00, 185),
(174, 4, 'Dry Ice Ekonomis #173', 43884.00, 130),
(175, 5, 'Es Serut Kiloan #174', 37289.00, 34),
(176, 3, 'Es Kristal Ekonomis #175', 42322.00, 53),
(177, 2, 'Es Serut Premium #176', 86017.00, 105),
(178, 2, 'Es Kristal Kemasan #177', 44842.00, 161),
(179, 5, 'Ice Cube Premium #178', 21113.00, 72),
(180, 1, 'Es Kristal Kemasan #179', 88786.00, 46),
(181, 5, 'Ice Cube Kiloan #180', 15030.00, 56),
(182, 4, 'Es Balok Kiloan #181', 12514.00, 153),
(183, 4, 'Dry Ice Premium #182', 84691.00, 135),
(184, 1, 'Es Serut Kemasan #183', 21957.00, 116),
(185, 3, 'Es Serut Kiloan #184', 94077.00, 174),
(186, 2, 'Es Kristal Kiloan #185', 62829.00, 125),
(187, 1, 'Es Serut Kemasan #186', 93955.00, 192),
(188, 5, 'Es Balok Kemasan #187', 14022.00, 178),
(189, 1, 'Ice Cube Kiloan #188', 91039.00, 158),
(190, 2, 'Es Balok Kiloan #189', 29741.00, 34),
(191, 1, 'Dry Ice Kiloan #190', 39198.00, 17),
(192, 1, 'Es Balok Super #191', 55454.00, 96),
(193, 4, 'Es Kristal Premium #192', 84729.00, 78),
(194, 1, 'Es Kristal Kemasan #193', 68374.00, 13),
(195, 5, 'Dry Ice Kiloan #194', 24843.00, 167),
(196, 5, 'Es Kristal Super #195', 52852.00, 18),
(197, 2, 'Ice Cube Ekonomis #196', 70507.00, 51),
(198, 1, 'Es Balok Kiloan #197', 24080.00, 169),
(199, 1, 'Es Kristal Super #198', 30391.00, 67),
(200, 4, 'Es Kristal Super #199', 89918.00, 157),
(201, 1, 'Es Serut Premium #200', 73867.00, 120),
(202, 4, 'Ice Cube Ekonomis #201', 15531.00, 82),
(203, 5, 'Es Kristal Ekonomis #202', 91043.00, 110),
(204, 3, 'Ice Cube Kemasan #203', 77856.00, 157),
(205, 1, 'Es Kristal Ekonomis #204', 41987.00, 183),
(206, 3, 'Ice Cube Premium #205', 89927.00, 147),
(207, 1, 'Es Kristal Premium #206', 86236.00, 181),
(208, 5, 'Dry Ice Kiloan #207', 43277.00, 19),
(209, 3, 'Es Kristal Kiloan #208', 96096.00, 161),
(210, 2, 'Es Balok Kemasan #209', 95066.00, 101),
(211, 2, 'Es Balok Kemasan #210', 37213.00, 139),
(212, 2, 'Ice Cube Kiloan #211', 84815.00, 139),
(213, 1, 'Dry Ice Ekonomis #212', 65138.00, 94),
(214, 4, 'Ice Cube Premium #213', 80055.00, 116),
(215, 3, 'Dry Ice Kemasan #214', 46799.00, 106),
(216, 2, 'Es Kristal Kemasan #215', 65373.00, 50),
(217, 4, 'Es Balok Kemasan #216', 38179.00, 32),
(218, 4, 'Es Kristal Kemasan #217', 11766.00, 134),
(219, 1, 'Es Balok Super #218', 28905.00, 60),
(220, 1, 'Ice Cube Ekonomis #219', 65175.00, 94),
(221, 2, 'Ice Cube Super #220', 64667.00, 34),
(222, 1, 'Es Kristal Kemasan #221', 77150.00, 31),
(223, 5, 'Es Serut Ekonomis #222', 40318.00, 200),
(224, 2, 'Es Balok Premium #223', 79905.00, 189),
(225, 3, 'Es Serut Premium #224', 43639.00, 95),
(226, 1, 'Ice Cube Kiloan #225', 48706.00, 171),
(227, 1, 'Ice Cube Premium #226', 15936.00, 168),
(228, 2, 'Es Balok Premium #227', 75382.00, 28),
(229, 4, 'Ice Cube Kiloan #228', 51949.00, 43),
(230, 5, 'Dry Ice Super #229', 49037.00, 161),
(231, 2, 'Es Balok Premium #230', 45075.00, 73),
(232, 2, 'Es Balok Kemasan #231', 13108.00, 40),
(233, 5, 'Es Kristal Ekonomis #232', 72394.00, 89),
(234, 3, 'Dry Ice Kiloan #233', 58768.00, 18),
(235, 5, 'Es Kristal Super #234', 69654.00, 200),
(236, 3, 'Es Kristal Premium #235', 49941.00, 41),
(237, 4, 'Ice Cube Ekonomis #236', 24562.00, 149),
(238, 2, 'Es Serut Premium #237', 81195.00, 76),
(239, 2, 'Dry Ice Premium #238', 74276.00, 90),
(240, 3, 'Es Kristal Kemasan #239', 39902.00, 13),
(241, 2, 'Es Balok Super #240', 69165.00, 11),
(242, 2, 'Es Balok Kemasan #241', 68975.00, 18),
(243, 2, 'Dry Ice Premium #242', 22647.00, 68),
(244, 2, 'Dry Ice Ekonomis #243', 23583.00, 14),
(245, 1, 'Es Kristal Premium #244', 91235.00, 98),
(246, 5, 'Es Balok Kemasan #245', 87230.00, 105),
(247, 2, 'Es Balok Super #246', 90978.00, 19),
(248, 2, 'Es Balok Premium #247', 14200.00, 174),
(249, 1, 'Es Serut Ekonomis #248', 23418.00, 86),
(250, 2, 'Es Balok Kemasan #249', 10504.00, 167),
(251, 1, 'Es Balok Ekonomis #250', 82947.00, 133),
(252, 1, 'Es Serut Premium #251', 93031.00, 114),
(253, 4, 'Dry Ice Kemasan #252', 87144.00, 118),
(254, 1, 'Es Serut Kemasan #253', 55782.00, 137),
(255, 3, 'Es Kristal Kiloan #254', 30121.00, 123),
(256, 3, 'Es Balok Super #255', 70768.00, 88),
(257, 2, 'Ice Cube Premium #256', 19310.00, 146),
(258, 3, 'Dry Ice Kemasan #257', 88035.00, 136),
(259, 3, 'Es Kristal Kemasan #258', 95569.00, 120),
(260, 1, 'Ice Cube Premium #259', 78206.00, 133),
(261, 2, 'Ice Cube Ekonomis #260', 25567.00, 76),
(262, 1, 'Ice Cube Kemasan #261', 97322.00, 182),
(263, 3, 'Dry Ice Kemasan #262', 10791.00, 36),
(264, 1, 'Es Serut Kemasan #263', 77142.00, 142),
(265, 3, 'Es Serut Super #264', 62754.00, 95),
(266, 2, 'Ice Cube Kiloan #265', 36984.00, 177),
(267, 3, 'Es Kristal Kemasan #266', 33021.00, 17),
(268, 4, 'Es Kristal Kiloan #267', 28699.00, 59),
(269, 3, 'Es Kristal Premium #268', 42185.00, 22),
(270, 1, 'Es Balok Ekonomis #269', 73734.00, 178),
(271, 2, 'Es Balok Kiloan #270', 73633.00, 195),
(272, 5, 'Es Kristal Premium #271', 17914.00, 47),
(273, 3, 'Es Serut Premium #272', 39405.00, 36),
(274, 1, 'Ice Cube Kemasan #273', 92729.00, 183),
(275, 1, 'Dry Ice Super #274', 90405.00, 195),
(276, 2, 'Es Serut Kemasan #275', 65750.00, 192),
(277, 5, 'Dry Ice Ekonomis #276', 30365.00, 149),
(278, 2, 'Es Balok Ekonomis #277', 98536.00, 156),
(279, 4, 'Es Balok Kemasan #278', 10529.00, 187),
(280, 5, 'Es Balok Ekonomis #279', 25999.00, 72),
(281, 5, 'Es Serut Kiloan #280', 47389.00, 32),
(282, 5, 'Dry Ice Premium #281', 48132.00, 138),
(283, 3, 'Dry Ice Ekonomis #282', 31227.00, 103),
(284, 1, 'Es Serut Super #283', 48824.00, 107),
(285, 5, 'Es Kristal Premium #284', 85358.00, 107),
(286, 2, 'Es Balok Super #285', 98884.00, 66),
(287, 4, 'Ice Cube Kiloan #286', 94673.00, 109),
(288, 1, 'Es Kristal Premium #287', 41736.00, 121),
(289, 5, 'Es Kristal Kiloan #288', 22229.00, 20),
(290, 4, 'Dry Ice Ekonomis #289', 74242.00, 153),
(291, 2, 'Dry Ice Premium #290', 88485.00, 93),
(292, 4, 'Ice Cube Premium #291', 78539.00, 157),
(293, 4, 'Es Serut Premium #292', 10012.00, 159),
(294, 3, 'Es Kristal Kemasan #293', 68485.00, 197),
(295, 4, 'Ice Cube Premium #294', 72114.00, 137),
(296, 5, 'Es Kristal Premium #295', 92556.00, 125),
(297, 2, 'Es Kristal Ekonomis #296', 42923.00, 141),
(298, 4, 'Es Kristal Kemasan #297', 47391.00, 180),
(299, 2, 'Dry Ice Ekonomis #298', 57493.00, 117),
(300, 5, 'Es Balok Premium #299', 10547.00, 43),
(301, 3, 'Ice Cube Super #300', 52623.00, 194),
(302, 5, 'Dry Ice Kemasan #301', 38810.00, 136),
(303, 2, 'Ice Cube Kemasan #302', 23418.00, 84),
(304, 1, 'Es Balok Super #303', 97076.00, 76),
(305, 4, 'Ice Cube Ekonomis #304', 25776.00, 32),
(306, 2, 'Es Balok Kiloan #305', 35357.00, 77),
(307, 1, 'Es Serut Ekonomis #306', 10471.00, 189),
(308, 3, 'Es Balok Super #307', 20228.00, 30),
(309, 4, 'Ice Cube Premium #308', 23968.00, 81),
(310, 1, 'Es Serut Kiloan #309', 98978.00, 20),
(311, 4, 'Dry Ice Super #310', 16529.00, 17),
(312, 4, 'Es Kristal Premium #311', 64730.00, 168),
(313, 1, 'Dry Ice Super #312', 45035.00, 154),
(314, 4, 'Es Balok Premium #313', 22913.00, 52),
(315, 2, 'Es Serut Premium #314', 42212.00, 162),
(316, 2, 'Es Balok Premium #315', 41937.00, 102),
(317, 5, 'Dry Ice Premium #316', 25441.00, 56),
(318, 1, 'Es Serut Ekonomis #317', 17768.00, 136),
(319, 4, 'Es Serut Premium #318', 58553.00, 46),
(320, 3, 'Dry Ice Premium #319', 63642.00, 198),
(321, 4, 'Es Kristal Premium #320', 61489.00, 32),
(322, 2, 'Es Kristal Premium #321', 29280.00, 106),
(323, 4, 'Es Serut Premium #322', 58333.00, 65),
(324, 2, 'Es Balok Kemasan #323', 98429.00, 126),
(325, 1, 'Es Serut Premium #324', 59032.00, 171),
(326, 3, 'Dry Ice Kiloan #325', 17325.00, 96),
(327, 4, 'Ice Cube Super #326', 63003.00, 187),
(328, 4, 'Dry Ice Ekonomis #327', 71674.00, 79),
(329, 5, 'Ice Cube Kiloan #328', 33419.00, 179),
(330, 3, 'Dry Ice Kiloan #329', 58690.00, 195),
(331, 3, 'Es Serut Ekonomis #330', 47669.00, 45),
(332, 4, 'Ice Cube Kiloan #331', 17106.00, 31),
(333, 5, 'Es Kristal Premium #332', 12725.00, 30),
(334, 1, 'Es Kristal Super #333', 72768.00, 190),
(335, 4, 'Es Balok Premium #334', 38220.00, 193),
(336, 2, 'Es Serut Kemasan #335', 86915.00, 13),
(337, 2, 'Es Kristal Kiloan #336', 61700.00, 20),
(338, 3, 'Es Balok Kiloan #337', 81090.00, 60),
(339, 4, 'Es Balok Premium #338', 82240.00, 132),
(340, 1, 'Ice Cube Premium #339', 96933.00, 84),
(341, 4, 'Ice Cube Kemasan #340', 11946.00, 135),
(342, 3, 'Es Kristal Premium #341', 53254.00, 26),
(343, 4, 'Dry Ice Kiloan #342', 33043.00, 200),
(344, 1, 'Es Serut Ekonomis #343', 72026.00, 52),
(345, 4, 'Ice Cube Ekonomis #344', 74127.00, 140),
(346, 1, 'Ice Cube Premium #345', 69410.00, 37),
(347, 4, 'Es Kristal Kemasan #346', 37165.00, 189),
(348, 5, 'Es Serut Premium #347', 36139.00, 79),
(349, 1, 'Es Kristal Premium #348', 62346.00, 27),
(350, 4, 'Es Serut Kiloan #349', 65607.00, 94),
(351, 4, 'Dry Ice Premium #350', 33649.00, 33),
(352, 1, 'Es Serut Ekonomis #351', 71137.00, 72),
(353, 3, 'Ice Cube Ekonomis #352', 88403.00, 37),
(354, 3, 'Es Balok Super #353', 17594.00, 81),
(355, 3, 'Es Serut Ekonomis #354', 99580.00, 14),
(356, 4, 'Es Kristal Ekonomis #355', 28633.00, 29),
(357, 5, 'Ice Cube Ekonomis #356', 34523.00, 176),
(358, 1, 'Es Balok Kemasan #357', 61623.00, 100),
(359, 2, 'Es Balok Kiloan #358', 35022.00, 189),
(360, 4, 'Es Balok Ekonomis #359', 42813.00, 158),
(361, 3, 'Es Balok Premium #360', 10477.00, 40),
(362, 2, 'Es Kristal Super #361', 47029.00, 73),
(363, 2, 'Es Kristal Super #362', 66919.00, 197),
(364, 5, 'Es Kristal Super #363', 72315.00, 149),
(365, 5, 'Es Kristal Kemasan #364', 83139.00, 36),
(366, 5, 'Es Balok Premium #365', 27736.00, 31),
(367, 5, 'Es Serut Kiloan #366', 46120.00, 32),
(368, 4, 'Ice Cube Super #367', 64427.00, 186),
(369, 3, 'Dry Ice Ekonomis #368', 59027.00, 151),
(370, 1, 'Es Kristal Kemasan #369', 19410.00, 157),
(371, 5, 'Es Serut Kiloan #370', 59838.00, 125),
(372, 1, 'Es Balok Kemasan #371', 69851.00, 68),
(373, 5, 'Es Kristal Kemasan #372', 29346.00, 190),
(374, 1, 'Dry Ice Ekonomis #373', 20124.00, 12),
(375, 1, 'Es Balok Premium #374', 84446.00, 43),
(376, 2, 'Es Kristal Super #375', 48115.00, 176),
(377, 1, 'Dry Ice Kiloan #376', 31937.00, 29),
(378, 3, 'Es Serut Premium #377', 85336.00, 192),
(379, 5, 'Ice Cube Premium #378', 15075.00, 82),
(380, 1, 'Es Kristal Super #379', 46855.00, 38),
(381, 1, 'Es Kristal Kiloan #380', 69010.00, 80),
(382, 3, 'Ice Cube Kiloan #381', 74853.00, 186),
(383, 3, 'Es Balok Super #382', 63465.00, 196),
(384, 1, 'Es Kristal Super #383', 73601.00, 20),
(385, 2, 'Ice Cube Super #384', 34751.00, 25),
(386, 5, 'Ice Cube Premium #385', 72774.00, 12),
(387, 4, 'Es Serut Super #386', 73355.00, 141),
(388, 4, 'Ice Cube Kiloan #387', 36513.00, 131),
(389, 1, 'Ice Cube Ekonomis #388', 18576.00, 115),
(390, 5, 'Ice Cube Kiloan #389', 10522.00, 177),
(391, 5, 'Es Kristal Kiloan #390', 87534.00, 193),
(392, 3, 'Ice Cube Ekonomis #391', 63449.00, 164),
(393, 5, 'Es Balok Kemasan #392', 39686.00, 198),
(394, 2, 'Es Kristal Premium #393', 55139.00, 199),
(395, 3, 'Es Serut Premium #394', 63544.00, 130),
(396, 3, 'Ice Cube Premium #395', 96905.00, 54),
(397, 2, 'Es Serut Super #396', 94402.00, 158),
(398, 3, 'Es Serut Premium #397', 56414.00, 113),
(399, 5, 'Es Kristal Kemasan #398', 39013.00, 142),
(400, 3, 'Es Kristal Kemasan #399', 59263.00, 120),
(401, 2, 'Dry Ice Super #400', 38111.00, 132),
(402, 1, 'Ice Cube Super #401', 15205.00, 98),
(403, 5, 'Es Kristal Super #402', 98575.00, 64),
(404, 4, 'Ice Cube Kiloan #403', 48729.00, 133),
(405, 5, 'Es Serut Kemasan #404', 81145.00, 98),
(406, 1, 'Es Kristal Super #405', 63270.00, 112),
(407, 5, 'Es Balok Super #406', 33749.00, 163),
(408, 3, 'Es Kristal Kemasan #407', 56316.00, 162),
(409, 4, 'Dry Ice Kiloan #408', 17697.00, 193),
(410, 2, 'Es Balok Premium #409', 94687.00, 121),
(411, 1, 'Es Kristal Kemasan #410', 54069.00, 126),
(412, 3, 'Es Serut Super #411', 45576.00, 44),
(413, 3, 'Dry Ice Kemasan #412', 90469.00, 183),
(414, 1, 'Es Balok Premium #413', 41253.00, 154),
(415, 3, 'Dry Ice Ekonomis #414', 95415.00, 75),
(416, 4, 'Ice Cube Premium #415', 66365.00, 79),
(417, 3, 'Es Kristal Kiloan #416', 85934.00, 186),
(418, 3, 'Ice Cube Kiloan #417', 83774.00, 134),
(419, 3, 'Es Kristal Super #418', 50223.00, 143),
(420, 4, 'Es Serut Super #419', 86880.00, 168),
(421, 4, 'Dry Ice Super #420', 21006.00, 68),
(422, 2, 'Dry Ice Super #421', 57198.00, 69),
(423, 4, 'Es Kristal Kemasan #422', 35131.00, 194),
(424, 5, 'Ice Cube Kiloan #423', 38372.00, 84),
(425, 2, 'Es Kristal Ekonomis #424', 23570.00, 13),
(426, 2, 'Es Balok Kiloan #425', 21370.00, 154),
(427, 2, 'Dry Ice Premium #426', 14694.00, 19),
(428, 2, 'Dry Ice Premium #427', 95049.00, 76),
(429, 5, 'Dry Ice Kiloan #428', 76058.00, 35),
(430, 2, 'Es Serut Super #429', 64660.00, 176),
(431, 3, 'Es Kristal Ekonomis #430', 75615.00, 190),
(432, 3, 'Ice Cube Kiloan #431', 89314.00, 185),
(433, 4, 'Es Kristal Super #432', 65649.00, 153),
(434, 1, 'Es Kristal Ekonomis #433', 77500.00, 182),
(435, 1, 'Es Serut Kemasan #434', 10364.00, 149),
(436, 1, 'Dry Ice Kemasan #435', 52016.00, 128),
(437, 1, 'Es Balok Ekonomis #436', 67320.00, 19),
(438, 2, 'Es Serut Kiloan #437', 98551.00, 182),
(439, 3, 'Dry Ice Premium #438', 78631.00, 81),
(440, 4, 'Es Kristal Super #439', 99818.00, 174),
(441, 2, 'Es Kristal Kiloan #440', 51127.00, 43),
(442, 1, 'Dry Ice Premium #441', 43540.00, 65),
(443, 5, 'Es Kristal Kemasan #442', 16686.00, 67),
(444, 5, 'Ice Cube Super #443', 92059.00, 29),
(445, 4, 'Ice Cube Kemasan #444', 21998.00, 111),
(446, 3, 'Dry Ice Super #445', 89651.00, 85),
(447, 5, 'Es Serut Kemasan #446', 76135.00, 39),
(448, 1, 'Dry Ice Kemasan #447', 61960.00, 66),
(449, 1, 'Ice Cube Ekonomis #448', 67738.00, 186),
(450, 3, 'Es Balok Kiloan #449', 83804.00, 153),
(451, 1, 'Dry Ice Premium #450', 80114.00, 156),
(452, 4, 'Ice Cube Kemasan #451', 27859.00, 30),
(453, 4, 'Ice Cube Premium #452', 69547.00, 193),
(454, 5, 'Es Balok Kiloan #453', 20629.00, 165),
(455, 1, 'Es Kristal Premium #454', 54207.00, 74),
(456, 2, 'Es Kristal Ekonomis #455', 20273.00, 95),
(457, 4, 'Es Kristal Kemasan #456', 16465.00, 72),
(458, 4, 'Es Serut Super #457', 28687.00, 31),
(459, 1, 'Dry Ice Ekonomis #458', 78502.00, 155),
(460, 4, 'Es Balok Super #459', 24540.00, 108),
(461, 3, 'Es Kristal Super #460', 71826.00, 81),
(462, 5, 'Es Balok Kiloan #461', 11670.00, 177),
(463, 1, 'Dry Ice Ekonomis #462', 86203.00, 156),
(464, 4, 'Dry Ice Super #463', 25506.00, 37),
(465, 2, 'Ice Cube Premium #464', 47068.00, 120),
(466, 1, 'Ice Cube Kiloan #465', 74497.00, 134),
(467, 2, 'Es Kristal Premium #466', 31327.00, 32),
(468, 5, 'Ice Cube Kemasan #467', 28276.00, 87),
(469, 2, 'Es Kristal Premium #468', 77464.00, 147),
(470, 3, 'Dry Ice Kiloan #469', 40482.00, 180),
(471, 5, 'Es Kristal Kiloan #470', 72954.00, 106),
(472, 5, 'Es Serut Premium #471', 22074.00, 90),
(473, 5, 'Es Balok Kiloan #472', 86906.00, 184),
(474, 4, 'Es Balok Super #473', 72806.00, 107),
(475, 3, 'Es Kristal Super #474', 94647.00, 10),
(476, 1, 'Ice Cube Kemasan #475', 21684.00, 180),
(477, 5, 'Dry Ice Super #476', 62758.00, 66),
(478, 1, 'Ice Cube Kiloan #477', 15957.00, 134),
(479, 1, 'Dry Ice Kiloan #478', 73803.00, 176),
(480, 2, 'Dry Ice Ekonomis #479', 76438.00, 22),
(481, 5, 'Ice Cube Ekonomis #480', 24202.00, 196),
(482, 4, 'Dry Ice Super #481', 16768.00, 27),
(483, 2, 'Es Serut Kemasan #482', 39032.00, 157),
(484, 5, 'Es Balok Ekonomis #483', 20905.00, 23),
(485, 2, 'Ice Cube Kemasan #484', 30860.00, 62),
(486, 1, 'Es Balok Premium #485', 40327.00, 36),
(487, 3, 'Dry Ice Kiloan #486', 64718.00, 95),
(488, 3, 'Es Balok Kemasan #487', 78685.00, 116),
(489, 2, 'Es Kristal Kiloan #488', 54417.00, 15),
(490, 4, 'Es Kristal Kiloan #489', 79041.00, 56),
(491, 5, 'Es Kristal Kiloan #490', 33111.00, 62),
(492, 4, 'Es Balok Kemasan #491', 24796.00, 116),
(493, 5, 'Es Serut Premium #492', 67390.00, 115),
(494, 1, 'Es Balok Kemasan #493', 55787.00, 117),
(495, 2, 'Es Kristal Premium #494', 74025.00, 145),
(496, 1, 'Es Balok Super #495', 52125.00, 103),
(497, 3, 'Es Balok Super #496', 53426.00, 110),
(498, 4, 'Es Serut Super #497', 36393.00, 152),
(499, 3, 'Ice Cube Ekonomis #498', 97902.00, 16),
(500, 2, 'Es Serut Ekonomis #499', 37649.00, 52),
(501, 5, 'Ice Cube Kemasan #500', 91545.00, 49),
(502, 2, 'Ice Cube Super #501', 86753.00, 198),
(503, 5, 'Es Serut Ekonomis #502', 77275.00, 147),
(504, 3, 'Dry Ice Premium #503', 41926.00, 32),
(505, 2, 'Es Balok Super #504', 22104.00, 139),
(506, 2, 'Ice Cube Kemasan #505', 41684.00, 123),
(507, 4, 'Es Balok Super #506', 43869.00, 82),
(508, 2, 'Es Serut Kemasan #507', 84448.00, 126),
(509, 5, 'Ice Cube Kiloan #508', 76968.00, 15),
(510, 1, 'Es Serut Kiloan #509', 64355.00, 73),
(511, 1, 'Dry Ice Premium #510', 85865.00, 29),
(512, 1, 'Es Serut Ekonomis #511', 90088.00, 167),
(513, 4, 'Es Serut Super #512', 65018.00, 119),
(514, 5, 'Es Balok Kiloan #513', 46782.00, 89),
(515, 1, 'Es Balok Ekonomis #514', 90970.00, 63),
(516, 2, 'Es Serut Premium #515', 26193.00, 104),
(517, 5, 'Es Serut Premium #516', 59408.00, 21),
(518, 5, 'Dry Ice Ekonomis #517', 14163.00, 54),
(519, 3, 'Es Kristal Super #518', 31624.00, 29),
(520, 4, 'Dry Ice Ekonomis #519', 39827.00, 129),
(521, 1, 'Es Kristal Ekonomis #520', 88678.00, 24),
(522, 2, 'Es Serut Super #521', 35358.00, 149),
(523, 4, 'Es Kristal Ekonomis #522', 37706.00, 73),
(524, 3, 'Es Balok Kiloan #523', 70543.00, 166),
(525, 4, 'Es Balok Super #524', 79583.00, 178),
(526, 4, 'Ice Cube Super #525', 48196.00, 144),
(527, 1, 'Es Kristal Premium #526', 82324.00, 39),
(528, 5, 'Es Kristal Ekonomis #527', 61066.00, 57),
(529, 4, 'Dry Ice Premium #528', 16629.00, 106),
(530, 4, 'Dry Ice Super #529', 71760.00, 108),
(531, 3, 'Es Balok Super #530', 10603.00, 63),
(532, 3, 'Es Serut Kiloan #531', 84461.00, 10),
(533, 5, 'Es Serut Kemasan #532', 84507.00, 88),
(534, 2, 'Es Balok Kemasan #533', 94635.00, 69),
(535, 3, 'Es Balok Kemasan #534', 89691.00, 76),
(536, 4, 'Dry Ice Kiloan #535', 59168.00, 66),
(537, 1, 'Es Balok Kemasan #536', 77767.00, 176),
(538, 5, 'Es Kristal Kiloan #537', 30079.00, 65),
(539, 5, 'Ice Cube Kemasan #538', 74264.00, 24),
(540, 3, 'Es Kristal Premium #539', 24728.00, 153),
(541, 1, 'Es Serut Premium #540', 46619.00, 50),
(542, 2, 'Dry Ice Kemasan #541', 43940.00, 125),
(543, 1, 'Es Balok Super #542', 30032.00, 191),
(544, 5, 'Es Balok Super #543', 82463.00, 59),
(545, 2, 'Dry Ice Kiloan #544', 75566.00, 62),
(546, 3, 'Es Serut Ekonomis #545', 89143.00, 174),
(547, 3, 'Es Balok Premium #546', 32012.00, 154),
(548, 1, 'Ice Cube Kemasan #547', 31531.00, 153),
(549, 2, 'Es Serut Kemasan #548', 72384.00, 21),
(550, 1, 'Dry Ice Kiloan #549', 51601.00, 30),
(551, 2, 'Es Serut Premium #550', 33433.00, 76),
(552, 3, 'Es Kristal Ekonomis #551', 16431.00, 17),
(553, 3, 'Dry Ice Ekonomis #552', 70532.00, 144),
(554, 5, 'Ice Cube Premium #553', 21247.00, 174),
(555, 3, 'Dry Ice Ekonomis #554', 47560.00, 188),
(556, 3, 'Dry Ice Kemasan #555', 22342.00, 44),
(557, 4, 'Ice Cube Kemasan #556', 23211.00, 121),
(558, 5, 'Es Balok Kemasan #557', 50525.00, 131),
(559, 3, 'Dry Ice Super #558', 89321.00, 172),
(560, 3, 'Es Balok Premium #559', 64800.00, 13),
(561, 1, 'Es Balok Ekonomis #560', 53807.00, 28),
(562, 4, 'Es Serut Premium #561', 72428.00, 39),
(563, 4, 'Ice Cube Super #562', 38187.00, 63),
(564, 5, 'Dry Ice Super #563', 18488.00, 66),
(565, 2, 'Ice Cube Ekonomis #564', 20332.00, 90),
(566, 5, 'Es Kristal Ekonomis #565', 98762.00, 23),
(567, 1, 'Ice Cube Premium #566', 77530.00, 136),
(568, 4, 'Es Kristal Ekonomis #567', 95194.00, 70),
(569, 1, 'Es Balok Premium #568', 66642.00, 68),
(570, 3, 'Dry Ice Kemasan #569', 54096.00, 113),
(571, 5, 'Es Kristal Ekonomis #570', 54380.00, 71),
(572, 1, 'Dry Ice Ekonomis #571', 74517.00, 117),
(573, 1, 'Es Kristal Ekonomis #572', 12887.00, 121),
(574, 2, 'Es Balok Premium #573', 53913.00, 64),
(575, 4, 'Dry Ice Kemasan #574', 97839.00, 35),
(576, 1, 'Es Balok Ekonomis #575', 43802.00, 12),
(577, 4, 'Es Kristal Premium #576', 92959.00, 69),
(578, 1, 'Dry Ice Kiloan #577', 65947.00, 179),
(579, 3, 'Es Serut Ekonomis #578', 94933.00, 158),
(580, 4, 'Es Kristal Kiloan #579', 60440.00, 19),
(581, 1, 'Es Kristal Super #580', 34109.00, 52),
(582, 2, 'Dry Ice Premium #581', 83092.00, 77),
(583, 3, 'Es Serut Kemasan #582', 71742.00, 135),
(584, 5, 'Es Balok Super #583', 92084.00, 79),
(585, 1, 'Es Serut Super #584', 95179.00, 172),
(586, 5, 'Ice Cube Kiloan #585', 44021.00, 66),
(587, 3, 'Es Serut Ekonomis #586', 35551.00, 24),
(588, 4, 'Es Serut Ekonomis #587', 73433.00, 173),
(589, 4, 'Es Kristal Kiloan #588', 93790.00, 33),
(590, 2, 'Ice Cube Ekonomis #589', 88434.00, 95),
(591, 1, 'Es Serut Super #590', 53525.00, 59),
(592, 3, 'Dry Ice Super #591', 70082.00, 185),
(593, 2, 'Ice Cube Ekonomis #592', 38634.00, 100),
(594, 4, 'Es Kristal Super #593', 47394.00, 75),
(595, 3, 'Ice Cube Super #594', 20324.00, 47),
(596, 2, 'Es Kristal Ekonomis #595', 46443.00, 121),
(597, 5, 'Es Balok Kiloan #596', 54673.00, 182),
(598, 1, 'Ice Cube Super #597', 80662.00, 119),
(599, 2, 'Es Kristal Kemasan #598', 85151.00, 138),
(600, 1, 'Es Serut Premium #599', 67760.00, 175),
(601, 4, 'Ice Cube Kiloan #600', 76140.00, 43),
(602, 3, 'Ice Cube Premium #601', 15616.00, 20),
(603, 2, 'Es Kristal Premium #602', 40637.00, 42),
(604, 2, 'Es Balok Ekonomis #603', 99218.00, 169),
(605, 5, 'Es Serut Super #604', 24207.00, 59),
(606, 1, 'Es Balok Ekonomis #605', 34959.00, 118),
(607, 5, 'Ice Cube Super #606', 18321.00, 128),
(608, 4, 'Dry Ice Kemasan #607', 93747.00, 164),
(609, 5, 'Es Serut Kemasan #608', 90687.00, 198),
(610, 4, 'Ice Cube Kemasan #609', 78638.00, 83),
(611, 2, 'Ice Cube Super #610', 17365.00, 131),
(612, 2, 'Ice Cube Super #611', 85034.00, 154),
(613, 3, 'Es Kristal Premium #612', 19716.00, 53),
(614, 3, 'Es Kristal Kiloan #613', 65541.00, 81),
(615, 5, 'Es Balok Super #614', 81366.00, 115),
(616, 1, 'Es Balok Kiloan #615', 96199.00, 165),
(617, 2, 'Dry Ice Premium #616', 30015.00, 23),
(618, 2, 'Es Serut Kemasan #617', 93860.00, 43),
(619, 4, 'Es Balok Kiloan #618', 39297.00, 63),
(620, 3, 'Es Serut Ekonomis #619', 95118.00, 50),
(621, 4, 'Es Balok Kemasan #620', 35970.00, 60),
(622, 2, 'Es Serut Kiloan #621', 99925.00, 157),
(623, 1, 'Es Serut Super #622', 13486.00, 145),
(624, 2, 'Ice Cube Premium #623', 22823.00, 190),
(625, 5, 'Dry Ice Kemasan #624', 60768.00, 107),
(626, 1, 'Es Kristal Premium #625', 41174.00, 59),
(627, 5, 'Es Kristal Premium #626', 33561.00, 49),
(628, 3, 'Es Balok Kiloan #627', 67712.00, 115),
(629, 4, 'Es Serut Ekonomis #628', 85643.00, 87),
(630, 2, 'Ice Cube Premium #629', 83759.00, 183),
(631, 1, 'Ice Cube Super #630', 69020.00, 51),
(632, 3, 'Es Balok Premium #631', 89486.00, 152),
(633, 5, 'Es Serut Kiloan #632', 43012.00, 189),
(634, 1, 'Es Serut Premium #633', 15901.00, 78),
(635, 4, 'Es Balok Ekonomis #634', 74119.00, 153),
(636, 3, 'Es Balok Ekonomis #635', 52994.00, 115),
(637, 3, 'Es Serut Super #636', 61472.00, 27),
(638, 4, 'Dry Ice Kemasan #637', 52614.00, 106),
(639, 3, 'Es Balok Kiloan #638', 35365.00, 53),
(640, 4, 'Es Kristal Kemasan #639', 49354.00, 135),
(641, 2, 'Es Balok Super #640', 16121.00, 87),
(642, 5, 'Dry Ice Kiloan #641', 46264.00, 94),
(643, 5, 'Ice Cube Kiloan #642', 64481.00, 90),
(644, 4, 'Es Serut Kemasan #643', 96307.00, 108),
(645, 3, 'Dry Ice Ekonomis #644', 95905.00, 25),
(646, 5, 'Dry Ice Kemasan #645', 26218.00, 196),
(647, 3, 'Es Balok Kemasan #646', 43293.00, 134),
(648, 5, 'Ice Cube Kiloan #647', 13599.00, 147),
(649, 1, 'Es Balok Kiloan #648', 47732.00, 178),
(650, 5, 'Es Kristal Kiloan #649', 54922.00, 51),
(651, 2, 'Es Serut Super #650', 31036.00, 195),
(652, 3, 'Es Balok Kemasan #651', 79247.00, 71),
(653, 4, 'Dry Ice Super #652', 73825.00, 61),
(654, 2, 'Dry Ice Kemasan #653', 10040.00, 111),
(655, 2, 'Dry Ice Kemasan #654', 27886.00, 176),
(656, 2, 'Es Serut Ekonomis #655', 44329.00, 189),
(657, 3, 'Es Serut Premium #656', 70968.00, 162),
(658, 4, 'Es Kristal Kiloan #657', 61728.00, 180),
(659, 3, 'Es Kristal Super #658', 14227.00, 75),
(660, 4, 'Ice Cube Premium #659', 21928.00, 105),
(661, 1, 'Es Balok Premium #660', 76398.00, 70),
(662, 1, 'Dry Ice Premium #661', 54576.00, 33),
(663, 4, 'Es Serut Premium #662', 45662.00, 69),
(664, 3, 'Ice Cube Ekonomis #663', 86600.00, 129),
(665, 4, 'Es Balok Super #664', 53361.00, 37),
(666, 1, 'Dry Ice Kiloan #665', 92249.00, 105),
(667, 5, 'Ice Cube Ekonomis #666', 13570.00, 27),
(668, 3, 'Es Balok Kemasan #667', 77701.00, 155),
(669, 2, 'Es Kristal Ekonomis #668', 93621.00, 152),
(670, 5, 'Es Serut Super #669', 21071.00, 49),
(671, 1, 'Es Balok Ekonomis #670', 83646.00, 106),
(672, 2, 'Ice Cube Premium #671', 34108.00, 131),
(673, 3, 'Ice Cube Ekonomis #672', 71324.00, 98),
(674, 4, 'Ice Cube Ekonomis #673', 18236.00, 170),
(675, 5, 'Dry Ice Premium #674', 42502.00, 40),
(676, 2, 'Es Serut Premium #675', 79006.00, 105),
(677, 1, 'Es Kristal Super #676', 35833.00, 121),
(678, 3, 'Es Serut Kemasan #677', 96680.00, 188),
(679, 2, 'Es Serut Kiloan #678', 13206.00, 136),
(680, 3, 'Ice Cube Kiloan #679', 41615.00, 41),
(681, 4, 'Dry Ice Ekonomis #680', 31799.00, 52),
(682, 5, 'Es Balok Ekonomis #681', 19804.00, 71),
(683, 2, 'Es Balok Kemasan #682', 88712.00, 61),
(684, 1, 'Dry Ice Kemasan #683', 54622.00, 75),
(685, 4, 'Es Serut Kiloan #684', 67685.00, 130),
(686, 2, 'Es Balok Kemasan #685', 14113.00, 193),
(687, 5, 'Es Balok Super #686', 91354.00, 79),
(688, 5, 'Dry Ice Super #687', 34989.00, 125),
(689, 5, 'Es Kristal Kiloan #688', 82706.00, 12),
(690, 3, 'Es Balok Ekonomis #689', 70920.00, 126),
(691, 1, 'Ice Cube Premium #690', 30074.00, 103),
(692, 1, 'Es Kristal Kemasan #691', 69054.00, 118),
(693, 4, 'Ice Cube Ekonomis #692', 10734.00, 125),
(694, 5, 'Es Serut Ekonomis #693', 24055.00, 152),
(695, 4, 'Es Serut Super #694', 90144.00, 156),
(696, 2, 'Dry Ice Kemasan #695', 29981.00, 199),
(697, 3, 'Dry Ice Ekonomis #696', 39572.00, 127),
(698, 4, 'Es Balok Super #697', 69577.00, 195),
(699, 3, 'Es Balok Kemasan #698', 29865.00, 98),
(700, 1, 'Es Balok Kemasan #699', 18930.00, 127),
(701, 1, 'Es Serut Kemasan #700', 45467.00, 122),
(702, 2, 'Es Kristal Super #701', 78518.00, 160),
(703, 4, 'Es Serut Ekonomis #702', 86109.00, 151),
(704, 4, 'Dry Ice Kemasan #703', 45474.00, 33),
(705, 4, 'Es Balok Ekonomis #704', 39067.00, 149),
(706, 2, 'Ice Cube Kemasan #705', 20881.00, 89),
(707, 2, 'Ice Cube Premium #706', 18700.00, 32),
(708, 1, 'Es Balok Super #707', 96088.00, 160),
(709, 3, 'Dry Ice Kiloan #708', 12897.00, 45),
(710, 2, 'Es Balok Ekonomis #709', 51365.00, 164),
(711, 5, 'Es Kristal Ekonomis #710', 16742.00, 89),
(712, 1, 'Ice Cube Kiloan #711', 60089.00, 192),
(713, 1, 'Es Serut Kiloan #712', 73219.00, 47),
(714, 2, 'Ice Cube Kemasan #713', 76643.00, 105),
(715, 2, 'Es Kristal Ekonomis #714', 77906.00, 39),
(716, 1, 'Es Serut Ekonomis #715', 88880.00, 88),
(717, 4, 'Dry Ice Ekonomis #716', 65762.00, 150),
(718, 1, 'Ice Cube Kiloan #717', 29013.00, 92),
(719, 5, 'Es Serut Kemasan #718', 34029.00, 95),
(720, 5, 'Dry Ice Ekonomis #719', 85575.00, 122),
(721, 4, 'Es Balok Kiloan #720', 43526.00, 161),
(722, 4, 'Es Serut Kiloan #721', 87090.00, 29),
(723, 4, 'Es Serut Premium #722', 60008.00, 36),
(724, 4, 'Es Balok Premium #723', 41270.00, 188),
(725, 1, 'Dry Ice Super #724', 58363.00, 36),
(726, 5, 'Es Balok Premium #725', 41722.00, 115),
(727, 4, 'Es Kristal Kemasan #726', 40334.00, 99),
(728, 3, 'Es Balok Super #727', 95183.00, 65),
(729, 3, 'Es Serut Premium #728', 58075.00, 58),
(730, 3, 'Dry Ice Premium #729', 38495.00, 190),
(731, 2, 'Dry Ice Kiloan #730', 39929.00, 150),
(732, 5, 'Es Serut Premium #731', 63537.00, 12),
(733, 3, 'Es Serut Ekonomis #732', 42758.00, 24),
(734, 4, 'Es Balok Kiloan #733', 18272.00, 49),
(735, 1, 'Es Serut Kiloan #734', 64490.00, 18),
(736, 4, 'Ice Cube Premium #735', 84203.00, 98),
(737, 4, 'Es Balok Premium #736', 46257.00, 70),
(738, 2, 'Es Serut Super #737', 86856.00, 165),
(739, 4, 'Es Balok Super #738', 83609.00, 190),
(740, 4, 'Es Kristal Ekonomis #739', 43719.00, 27),
(741, 5, 'Es Kristal Premium #740', 90129.00, 53),
(742, 1, 'Es Kristal Kemasan #741', 85488.00, 119),
(743, 4, 'Es Serut Kemasan #742', 80094.00, 70),
(744, 5, 'Es Serut Kiloan #743', 81445.00, 118),
(745, 5, 'Es Balok Premium #744', 34053.00, 17),
(746, 1, 'Es Kristal Kemasan #745', 52994.00, 176),
(747, 1, 'Es Balok Premium #746', 93309.00, 61),
(748, 5, 'Ice Cube Ekonomis #747', 17340.00, 30),
(749, 4, 'Es Balok Kiloan #748', 51824.00, 56),
(750, 1, 'Dry Ice Kiloan #749', 60885.00, 64),
(751, 4, 'Es Balok Kemasan #750', 10734.00, 194),
(752, 4, 'Dry Ice Premium #751', 84195.00, 116),
(753, 4, 'Es Balok Kiloan #752', 69397.00, 98),
(754, 2, 'Es Kristal Kiloan #753', 53733.00, 35),
(755, 4, 'Es Balok Ekonomis #754', 23635.00, 59),
(756, 4, 'Es Balok Kiloan #755', 24454.00, 167),
(757, 1, 'Dry Ice Kiloan #756', 34072.00, 164),
(758, 3, 'Es Balok Premium #757', 63694.00, 25),
(759, 4, 'Dry Ice Super #758', 36642.00, 46),
(760, 3, 'Es Kristal Kemasan #759', 59948.00, 141),
(761, 4, 'Ice Cube Premium #760', 96480.00, 20),
(762, 4, 'Ice Cube Premium #761', 36184.00, 60),
(763, 5, 'Es Serut Ekonomis #762', 47412.00, 183),
(764, 2, 'Es Balok Ekonomis #763', 30163.00, 35),
(765, 5, 'Es Kristal Super #764', 22936.00, 82),
(766, 2, 'Es Balok Premium #765', 80849.00, 105),
(767, 2, 'Dry Ice Ekonomis #766', 93778.00, 27),
(768, 2, 'Es Serut Premium #767', 98038.00, 130),
(769, 1, 'Ice Cube Ekonomis #768', 76473.00, 183),
(770, 2, 'Es Kristal Super #769', 22120.00, 106),
(771, 3, 'Ice Cube Kemasan #770', 52170.00, 110),
(772, 1, 'Ice Cube Ekonomis #771', 39861.00, 77),
(773, 4, 'Dry Ice Ekonomis #772', 85236.00, 71),
(774, 5, 'Dry Ice Ekonomis #773', 29862.00, 60),
(775, 3, 'Ice Cube Premium #774', 14105.00, 200),
(776, 3, 'Dry Ice Super #775', 47050.00, 61),
(777, 3, 'Es Serut Kemasan #776', 36498.00, 64),
(778, 2, 'Dry Ice Kemasan #777', 17879.00, 13),
(779, 4, 'Dry Ice Kemasan #778', 30479.00, 27),
(780, 5, 'Es Serut Kemasan #779', 51978.00, 21),
(781, 5, 'Es Kristal Premium #780', 65399.00, 24),
(782, 3, 'Ice Cube Kemasan #781', 17353.00, 136),
(783, 1, 'Es Serut Ekonomis #782', 83528.00, 34),
(784, 4, 'Es Kristal Super #783', 58535.00, 14),
(785, 1, 'Dry Ice Kemasan #784', 78201.00, 21),
(786, 1, 'Es Serut Kiloan #785', 44051.00, 29),
(787, 4, 'Ice Cube Premium #786', 59169.00, 94),
(788, 3, 'Ice Cube Kiloan #787', 30666.00, 133),
(789, 1, 'Es Kristal Premium #788', 93543.00, 82),
(790, 2, 'Es Balok Super #789', 80784.00, 184),
(791, 5, 'Es Serut Ekonomis #790', 19975.00, 79),
(792, 5, 'Dry Ice Super #791', 80915.00, 153),
(793, 4, 'Es Balok Premium #792', 67996.00, 197),
(794, 2, 'Es Serut Kemasan #793', 96570.00, 51),
(795, 1, 'Es Balok Kiloan #794', 98876.00, 116),
(796, 1, 'Es Kristal Super #795', 96429.00, 164),
(797, 4, 'Dry Ice Ekonomis #796', 46992.00, 160),
(798, 3, 'Dry Ice Ekonomis #797', 46359.00, 118),
(799, 1, 'Es Balok Premium #798', 88223.00, 138),
(800, 4, 'Ice Cube Super #799', 12244.00, 177),
(801, 2, 'Es Serut Kemasan #800', 66333.00, 61),
(802, 4, 'Dry Ice Premium #801', 46097.00, 114),
(803, 3, 'Dry Ice Kemasan #802', 71805.00, 34),
(804, 2, 'Es Serut Super #803', 15347.00, 35),
(805, 5, 'Dry Ice Kemasan #804', 59069.00, 25),
(806, 2, 'Es Serut Super #805', 26532.00, 177),
(807, 4, 'Es Balok Kiloan #806', 38342.00, 157),
(808, 3, 'Es Kristal Kiloan #807', 12694.00, 178),
(809, 4, 'Es Balok Premium #808', 29223.00, 151),
(810, 4, 'Ice Cube Premium #809', 14147.00, 133),
(811, 2, 'Es Serut Kiloan #810', 71927.00, 186),
(812, 4, 'Es Balok Ekonomis #811', 11273.00, 99),
(813, 3, 'Es Balok Kemasan #812', 45240.00, 96),
(814, 2, 'Es Kristal Kemasan #813', 14326.00, 27),
(815, 4, 'Es Balok Premium #814', 78123.00, 46),
(816, 3, 'Es Kristal Kemasan #815', 59128.00, 79),
(817, 1, 'Es Serut Super #816', 97834.00, 29),
(818, 2, 'Ice Cube Ekonomis #817', 54064.00, 112),
(819, 4, 'Ice Cube Premium #818', 28949.00, 75),
(820, 4, 'Dry Ice Premium #819', 10724.00, 165),
(821, 2, 'Es Balok Kemasan #820', 79722.00, 52),
(822, 5, 'Es Kristal Ekonomis #821', 97080.00, 152),
(823, 3, 'Es Balok Kemasan #822', 50572.00, 140),
(824, 1, 'Dry Ice Kiloan #823', 58374.00, 91),
(825, 2, 'Es Serut Premium #824', 54385.00, 50),
(826, 5, 'Es Serut Super #825', 93825.00, 123),
(827, 1, 'Dry Ice Ekonomis #826', 78972.00, 14),
(828, 1, 'Es Kristal Kiloan #827', 42642.00, 171),
(829, 1, 'Ice Cube Kemasan #828', 81146.00, 54),
(830, 4, 'Ice Cube Premium #829', 56321.00, 106),
(831, 1, 'Dry Ice Premium #830', 61944.00, 143),
(832, 4, 'Es Balok Ekonomis #831', 20037.00, 75),
(833, 3, 'Es Kristal Ekonomis #832', 12722.00, 36),
(834, 2, 'Ice Cube Premium #833', 22496.00, 83),
(835, 1, 'Es Kristal Premium #834', 25657.00, 61),
(836, 1, 'Es Serut Premium #835', 60628.00, 172),
(837, 2, 'Es Balok Kemasan #836', 19762.00, 41),
(838, 3, 'Es Balok Kiloan #837', 96687.00, 132),
(839, 2, 'Es Kristal Kiloan #838', 84288.00, 86),
(840, 4, 'Es Serut Premium #839', 47680.00, 73),
(841, 4, 'Es Serut Ekonomis #840', 44451.00, 34),
(842, 3, 'Dry Ice Super #841', 69351.00, 102),
(843, 5, 'Es Serut Super #842', 30520.00, 177),
(844, 2, 'Es Kristal Kemasan #843', 71685.00, 93),
(845, 1, 'Es Serut Kiloan #844', 91102.00, 191),
(846, 2, 'Dry Ice Kemasan #845', 46963.00, 133),
(847, 5, 'Ice Cube Kiloan #846', 73464.00, 78),
(848, 3, 'Ice Cube Super #847', 19924.00, 25),
(849, 4, 'Es Balok Premium #848', 65294.00, 105),
(850, 2, 'Es Serut Kiloan #849', 39437.00, 191),
(851, 3, 'Ice Cube Ekonomis #850', 84744.00, 177),
(852, 5, 'Dry Ice Premium #851', 91495.00, 129),
(853, 4, 'Ice Cube Ekonomis #852', 67953.00, 67),
(854, 4, 'Es Kristal Ekonomis #853', 40977.00, 173),
(855, 1, 'Ice Cube Kiloan #854', 82402.00, 15),
(856, 5, 'Ice Cube Ekonomis #855', 65013.00, 181),
(857, 3, 'Es Kristal Premium #856', 87213.00, 12),
(858, 2, 'Es Kristal Kiloan #857', 33666.00, 51),
(859, 5, 'Es Balok Ekonomis #858', 90029.00, 22),
(860, 5, 'Es Serut Super #859', 43396.00, 106),
(861, 5, 'Dry Ice Ekonomis #860', 24035.00, 25),
(862, 1, 'Es Serut Super #861', 86304.00, 40),
(863, 1, 'Es Balok Kemasan #862', 74533.00, 79),
(864, 3, 'Ice Cube Kiloan #863', 59178.00, 49),
(865, 5, 'Es Balok Kiloan #864', 56456.00, 22),
(866, 1, 'Es Kristal Kiloan #865', 33050.00, 171),
(867, 5, 'Es Balok Super #866', 83532.00, 161),
(868, 4, 'Dry Ice Super #867', 15406.00, 193),
(869, 2, 'Es Kristal Ekonomis #868', 57148.00, 107),
(870, 1, 'Es Balok Ekonomis #869', 55429.00, 125),
(871, 1, 'Es Kristal Premium #870', 54694.00, 22),
(872, 2, 'Es Serut Premium #871', 87323.00, 37),
(873, 3, 'Es Serut Super #872', 76321.00, 90),
(874, 5, 'Ice Cube Ekonomis #873', 99362.00, 104),
(875, 1, 'Es Balok Kiloan #874', 23764.00, 90),
(876, 5, 'Es Kristal Premium #875', 90458.00, 53),
(877, 2, 'Es Balok Super #876', 32334.00, 83),
(878, 3, 'Ice Cube Kemasan #877', 29940.00, 83),
(879, 4, 'Es Serut Kiloan #878', 53276.00, 76),
(880, 1, 'Dry Ice Super #879', 91165.00, 22),
(881, 2, 'Es Kristal Kiloan #880', 19635.00, 15),
(882, 3, 'Ice Cube Kemasan #881', 24207.00, 192),
(883, 1, 'Dry Ice Ekonomis #882', 45638.00, 75),
(884, 2, 'Es Kristal Ekonomis #883', 70350.00, 40),
(885, 2, 'Es Serut Kemasan #884', 45448.00, 125),
(886, 4, 'Ice Cube Ekonomis #885', 80384.00, 179),
(887, 1, 'Es Serut Super #886', 18027.00, 85),
(888, 5, 'Ice Cube Premium #887', 42403.00, 193),
(889, 5, 'Es Balok Ekonomis #888', 65960.00, 91),
(890, 2, 'Es Kristal Super #889', 54270.00, 79),
(891, 2, 'Es Serut Ekonomis #890', 39909.00, 14),
(892, 1, 'Es Serut Kiloan #891', 43189.00, 58),
(893, 4, 'Dry Ice Kemasan #892', 42881.00, 27),
(894, 2, 'Dry Ice Premium #893', 57835.00, 93),
(895, 4, 'Dry Ice Kiloan #894', 11547.00, 86),
(896, 4, 'Es Balok Super #895', 95032.00, 108),
(897, 4, 'Es Balok Super #896', 63191.00, 33),
(898, 1, 'Es Serut Super #897', 10737.00, 142),
(899, 2, 'Es Kristal Super #898', 67352.00, 168),
(900, 5, 'Dry Ice Ekonomis #899', 83142.00, 114),
(901, 3, 'Ice Cube Premium #900', 25180.00, 152),
(902, 1, 'Es Kristal Premium #901', 16071.00, 43),
(903, 1, 'Es Serut Kiloan #902', 75368.00, 96),
(904, 2, 'Ice Cube Kiloan #903', 66188.00, 68),
(905, 1, 'Es Balok Kemasan #904', 37624.00, 163),
(906, 3, 'Ice Cube Super #905', 90193.00, 127),
(907, 4, 'Dry Ice Ekonomis #906', 92193.00, 135),
(908, 2, 'Dry Ice Kiloan #907', 39374.00, 79),
(909, 4, 'Es Serut Kemasan #908', 53939.00, 196),
(910, 5, 'Es Balok Premium #909', 97687.00, 136),
(911, 3, 'Es Kristal Premium #910', 82010.00, 16),
(912, 4, 'Dry Ice Premium #911', 38903.00, 187),
(913, 4, 'Es Kristal Super #912', 16054.00, 46),
(914, 2, 'Es Balok Kiloan #913', 59723.00, 181),
(915, 3, 'Dry Ice Super #914', 93838.00, 126),
(916, 3, 'Ice Cube Premium #915', 38787.00, 168),
(917, 1, 'Es Serut Kemasan #916', 64687.00, 179),
(918, 1, 'Es Serut Kiloan #917', 82821.00, 54),
(919, 1, 'Ice Cube Premium #918', 83185.00, 138),
(920, 4, 'Es Kristal Ekonomis #919', 15421.00, 67),
(921, 5, 'Dry Ice Kemasan #920', 68093.00, 111),
(922, 3, 'Ice Cube Premium #921', 93930.00, 125),
(923, 5, 'Es Balok Kiloan #922', 51444.00, 142),
(924, 2, 'Ice Cube Super #923', 66530.00, 191),
(925, 3, 'Dry Ice Kiloan #924', 88126.00, 25),
(926, 5, 'Ice Cube Kemasan #925', 87784.00, 68),
(927, 4, 'Ice Cube Premium #926', 63329.00, 156),
(928, 4, 'Es Balok Ekonomis #927', 76373.00, 96),
(929, 5, 'Es Kristal Ekonomis #928', 56621.00, 39),
(930, 1, 'Ice Cube Ekonomis #929', 63001.00, 105),
(931, 1, 'Dry Ice Ekonomis #930', 44782.00, 134),
(932, 4, 'Dry Ice Kiloan #931', 71371.00, 107),
(933, 3, 'Es Kristal Ekonomis #932', 59151.00, 43),
(934, 4, 'Es Balok Kiloan #933', 96779.00, 160),
(935, 1, 'Ice Cube Ekonomis #934', 61967.00, 135),
(936, 3, 'Es Balok Premium #935', 66910.00, 10),
(937, 3, 'Dry Ice Ekonomis #936', 70164.00, 66),
(938, 2, 'Es Balok Kemasan #937', 52580.00, 189),
(939, 3, 'Es Serut Premium #938', 14141.00, 167),
(940, 3, 'Es Serut Ekonomis #939', 87826.00, 133),
(941, 3, 'Ice Cube Super #940', 49367.00, 142),
(942, 2, 'Es Balok Kiloan #941', 56332.00, 148),
(943, 1, 'Dry Ice Kemasan #942', 82840.00, 59),
(944, 4, 'Dry Ice Kemasan #943', 92352.00, 61),
(945, 5, 'Es Kristal Kiloan #944', 95856.00, 115),
(946, 3, 'Es Serut Ekonomis #945', 11096.00, 142),
(947, 4, 'Dry Ice Premium #946', 80134.00, 162),
(948, 1, 'Dry Ice Super #947', 10219.00, 123),
(949, 4, 'Es Kristal Premium #948', 56618.00, 190),
(950, 2, 'Ice Cube Premium #949', 20545.00, 144),
(951, 1, 'Ice Cube Premium #950', 23202.00, 179),
(952, 4, 'Es Balok Super #951', 46555.00, 110),
(953, 2, 'Es Serut Premium #952', 12345.00, 101),
(954, 2, 'Es Kristal Super #953', 17597.00, 189),
(955, 5, 'Dry Ice Super #954', 50662.00, 47),
(956, 4, 'Es Serut Premium #955', 71871.00, 155),
(957, 3, 'Ice Cube Ekonomis #956', 30503.00, 187),
(958, 1, 'Es Kristal Ekonomis #957', 87956.00, 91),
(959, 4, 'Es Kristal Ekonomis #958', 24876.00, 84),
(960, 5, 'Es Kristal Super #959', 98111.00, 180),
(961, 1, 'Ice Cube Super #960', 99517.00, 167),
(962, 5, 'Es Kristal Kemasan #961', 46286.00, 43),
(963, 1, 'Es Serut Kiloan #962', 56534.00, 15),
(964, 3, 'Dry Ice Ekonomis #963', 25764.00, 133),
(965, 5, 'Ice Cube Kemasan #964', 46208.00, 71),
(966, 1, 'Es Serut Super #965', 79395.00, 190),
(967, 3, 'Dry Ice Kiloan #966', 49397.00, 198),
(968, 4, 'Es Kristal Ekonomis #967', 20887.00, 59),
(969, 4, 'Dry Ice Super #968', 58215.00, 173),
(970, 3, 'Ice Cube Kiloan #969', 81827.00, 166),
(971, 2, 'Es Serut Kiloan #970', 16616.00, 169),
(972, 5, 'Es Serut Premium #971', 14159.00, 115),
(973, 4, 'Es Kristal Premium #972', 22763.00, 75),
(974, 3, 'Dry Ice Kemasan #973', 84188.00, 160),
(975, 4, 'Es Balok Kiloan #974', 48316.00, 191),
(976, 1, 'Es Balok Ekonomis #975', 32433.00, 13),
(977, 5, 'Es Balok Super #976', 53399.00, 128),
(978, 4, 'Es Kristal Ekonomis #977', 52796.00, 79),
(979, 4, 'Es Serut Kemasan #978', 79158.00, 181),
(980, 1, 'Es Balok Kemasan #979', 98669.00, 44),
(981, 5, 'Es Kristal Premium #980', 41640.00, 64),
(982, 4, 'Ice Cube Kemasan #981', 20000.00, 140),
(983, 1, 'Es Kristal Kiloan #982', 79882.00, 33),
(984, 1, 'Es Serut Kemasan #983', 53303.00, 125),
(985, 5, 'Es Balok Kiloan #984', 28532.00, 114),
(986, 4, 'Ice Cube Super #985', 64847.00, 69),
(987, 1, 'Es Balok Kemasan #986', 75497.00, 199),
(988, 5, 'Ice Cube Premium #987', 72204.00, 60),
(989, 2, 'Es Balok Premium #988', 28409.00, 106),
(990, 4, 'Es Serut Ekonomis #989', 73528.00, 76),
(991, 1, 'Es Serut Kemasan #990', 28545.00, 128),
(992, 5, 'Es Serut Ekonomis #991', 91092.00, 60),
(993, 2, 'Es Kristal Kemasan #992', 16225.00, 140),
(994, 5, 'Ice Cube Kiloan #993', 91487.00, 91),
(995, 3, 'Ice Cube Premium #994', 44243.00, 64),
(996, 1, 'Es Serut Ekonomis #995', 74824.00, 124),
(997, 3, 'Ice Cube Kiloan #996', 69841.00, 65),
(998, 5, 'Ice Cube Ekonomis #997', 37155.00, 40),
(999, 2, 'Dry Ice Kemasan #998', 82127.00, 176),
(1000, 1, 'Es Balok Super #999', 62225.00, 17),
(1001, 3, 'Es Kristal Ekonomis #1000', 48490.00, 156);

--
-- Triggers `products`
--
DELIMITER $$
CREATE TRIGGER `trg_update_product_count_after_delete` AFTER DELETE ON `products` FOR EACH ROW BEGIN
    DECLARE total_products INT;
    SELECT COUNT(*) INTO total_products FROM products;
    UPDATE tbl_konten_layanan SET statistik_data = total_products WHERE nama_data = 'Total Produk';
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_update_product_count_after_insert` AFTER INSERT ON `products` FOR EACH ROW BEGIN
    DECLARE total_products INT;
    SELECT COUNT(*) INTO total_products FROM products;
    UPDATE tbl_konten_layanan SET statistik_data = total_products WHERE nama_data = 'Total Produk';
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`id`, `name`, `phone`, `address`) VALUES
(1, 'PT Pemasok Jaya', '081234567890', 'Jl. Industri No. 1, Jakarta'),
(2, 'CV Sumber Makmur', '081234567891', 'Jl. Logistik No. 2, Surabaya'),
(3, 'UD Mitra Sejahtera', '081234567892', 'Jl. Dagang No. 3, Bandung'),
(4, 'Toko Bahan Pokok Sentosa', '081234567893', 'Jl. Niaga No. 4, Medan'),
(5, 'Agen Distribusi Cepat', '081234567894', 'Jl. Gudang No. 5, Semarang');

-- --------------------------------------------------------

--
-- Table structure for table `supplier_profiles`
--

CREATE TABLE `supplier_profiles` (
  `supplier_id` int(11) NOT NULL,
  `npwp` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `contact_person` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_anggota`
--

CREATE TABLE `tbl_anggota` (
  `id` int(11) NOT NULL,
  `nim` varchar(50) NOT NULL,
  `nama_anggota` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_anggota`
--

INSERT INTO `tbl_anggota` (`id`, `nim`, `nama_anggota`) VALUES
(5, '23.11.5743', 'Muhammad Tegar Revolusi Seto'),
(6, '23.11.5724', 'Muhamad Fikih Rizaldi'),
(7, '23.11.5717', 'Ridho Akbar'),
(8, '23.11.5728', 'Daffa Akmal Ayom Pamungkas'),
(9, '23.11.5725', 'Raid Althaf Wilian'),
(10, '23.11.5733', 'Redomas Baegy Hardianathan');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_kontak`
--

CREATE TABLE `tbl_kontak` (
  `alamat` text DEFAULT NULL,
  `email` text DEFAULT NULL,
  `telfon` text DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_konten_beranda`
--

CREATE TABLE `tbl_konten_beranda` (
  `id` int(11) NOT NULL,
  `text_section` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_konten_layanan`
--

CREATE TABLE `tbl_konten_layanan` (
  `id` int(11) NOT NULL,
  `nama_data` varchar(50) NOT NULL DEFAULT '',
  `statistik_data` varchar(50) NOT NULL DEFAULT '0',
  `detail_data` varchar(50) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_konten_layanan`
--

INSERT INTO `tbl_konten_layanan` (`id`, `nama_data`, `statistik_data`, `detail_data`) VALUES
(1, 'Produksi Perhari', '250', 'Ton'),
(2, 'Total Produk', '1000', 'Jenis'),
(3, 'Pelanggan Tetap', '0', '+'),
(4, 'Total Supplier', '0', 'Partner');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_prioritas`
--

CREATE TABLE `tbl_prioritas` (
  `gambar 1` varchar(255) DEFAULT NULL,
  `gambar 2` varchar(255) DEFAULT NULL,
  `gambar 3` varchar(255) DEFAULT NULL,
  `prioritas` text DEFAULT NULL,
  `kotak 1` text DEFAULT NULL,
  `kotak 2` text DEFAULT NULL,
  `kotak 3` text DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_tentang`
--

CREATE TABLE `tbl_tentang` (
  `judul` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `phone` (`phone`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `order_details`
--
ALTER TABLE `order_details`
  ADD PRIMARY KEY (`order_id`,`product_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `supplier_id` (`supplier_id`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `phone` (`phone`);

--
-- Indexes for table `supplier_profiles`
--
ALTER TABLE `supplier_profiles`
  ADD PRIMARY KEY (`supplier_id`),
  ADD UNIQUE KEY `npwp` (`npwp`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `tbl_anggota`
--
ALTER TABLE `tbl_anggota`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_konten_beranda`
--
ALTER TABLE `tbl_konten_beranda`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_konten_layanan`
--
ALTER TABLE `tbl_konten_layanan`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1002;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tbl_anggota`
--
ALTER TABLE `tbl_anggota`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `tbl_konten_beranda`
--
ALTER TABLE `tbl_konten_beranda`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_konten_layanan`
--
ALTER TABLE `tbl_konten_layanan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `order_details_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_details_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `supplier_profiles`
--
ALTER TABLE `supplier_profiles`
  ADD CONSTRAINT `supplier_profiles_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
