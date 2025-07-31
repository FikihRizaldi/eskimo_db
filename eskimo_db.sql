-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 31, 2025 at 03:27 PM
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

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CekStokProdukMenipis` ()   BEGIN
    -- Deklarasi variabel untuk cursor
    DECLARE done INT DEFAULT FALSE;
    DECLARE nama_produk VARCHAR(100);
    DECLARE sisa_stok INT;

    -- Deklarasi cursor untuk mengambil produk dengan stok < 20
    DECLARE cur_produk CURSOR FOR 
        SELECT name, stock FROM products WHERE stock < 20 ORDER BY stock ASC LIMIT 5;

    -- Deklarasi handler jika cursor tidak menemukan data lagi
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Membuat tabel temporer untuk menampung hasil
    DROP TEMPORARY TABLE IF EXISTS temp_rekomendasi_restock;
    CREATE TEMPORARY TABLE temp_rekomendasi_restock (
        nama_produk VARCHAR(100),
        sisa_stok INT
    );

    -- Membuka cursor
    OPEN cur_produk;

    -- Looping untuk mengambil data dari cursor
    read_loop: LOOP
        FETCH cur_produk INTO nama_produk, sisa_stok;
        IF done THEN
            LEAVE read_loop;
        END IF;
        INSERT INTO temp_rekomendasi_restock VALUES (nama_produk, sisa_stok);
    END LOOP;

    -- Menutup cursor
    CLOSE cur_produk;

    -- Menampilkan hasil dari tabel temporer
    SELECT * FROM temp_rekomendasi_restock;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ProsesPesananBaru` (IN `p_customer_id` INT, IN `p_product_id` INT, IN `p_quantity` INT, OUT `p_status` VARCHAR(255))   BEGIN
    DECLARE stok_tersedia INT;

    -- Mengambil stok produk saat ini
    SELECT stock INTO stok_tersedia FROM products WHERE id = p_product_id;

    -- Control Flow (IF Statement) untuk mengecek ketersediaan stok
    IF stok_tersedia IS NULL THEN
        SET p_status = 'Gagal: Produk tidak ditemukan.';
    ELSEIF stok_tersedia >= p_quantity THEN
        -- Logika untuk mengurangi stok dan membuat pesanan
        UPDATE products SET stock = stock - p_quantity WHERE id = p_product_id;
        -- (Di aplikasi nyata, di sini akan ada INSERT ke tabel orders dan order_details)
        SET p_status = CONCAT('Sukses: Pesanan untuk produk ID ', p_product_id, ' berhasil dibuat.');
    ELSE
        SET p_status = CONCAT('Gagal: Stok tidak mencukupi. Sisa stok: ', stok_tersedia);
    END IF;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `HitungTotalPelanggan` () RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM customers;
    RETURN total;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `HitungTotalStokDuaProduk` (`id_produk_1` INT, `id_produk_2` INT) RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE total_stok INT;
    SELECT SUM(stock) INTO total_stok FROM products 
    WHERE id IN (id_produk_1, id_produk_2);
    RETURN IFNULL(total_stok, 0);
END$$

DELIMITER ;

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
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `name`, `email`, `phone`, `address`) VALUES
(1, 'Toko Kelontong Pak Eko', 'eko.jaya@email.com', '085711223344', 'Jl. Mawar No. 10, Yogyakarta'),
(2, 'Restoran Sedap Malam', 'manager@sedapmalam.com', '081299887766', 'Jl. Sudirman Kav. 5, Jakarta'),
(3, 'Cafe Senja', 'purchase@cafesenja.id', '087855664433', 'Jl. Dago Atas No. 99, Bandung'),
(4, 'Hotel Bintang Lima', 'fb@bintanglima-hotel.com', '082144556677', 'Jl. Legian No. 1, Bali');

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

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `customer_id`, `order_date`, `status`) VALUES
(1, 1, '2025-07-20', 'delivered'),
(2, 2, '2025-07-21', 'processed'),
(3, 1, '2025-07-22', 'pending'),
(4, 1, '2025-07-31', 'pending');

--
-- Triggers `orders`
--
DELIMITER $$
CREATE TRIGGER `trg_before_order_insert` BEFORE INSERT ON `orders` FOR EACH ROW BEGIN
    -- Menggunakan NEW untuk memodifikasi baris yang akan dimasukkan
    SET NEW.order_date = CURDATE();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `order_details`
--

CREATE TABLE `order_details` (
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_details`
--

INSERT INTO `order_details` (`order_id`, `product_id`, `quantity`) VALUES
(1, 1, 10),
(1, 4, 20),
(2, 3, 5),
(3, 2, 15);

--
-- Triggers `order_details`
--
DELIMITER $$
CREATE TRIGGER `trg_after_order_detail_delete` AFTER DELETE ON `order_details` FOR EACH ROW BEGIN
    -- Menggunakan OLD untuk mendapatkan data yang baru saja dihapus
    UPDATE products 
    SET stock = stock + OLD.quantity 
    WHERE id = OLD.product_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pengiriman`
--

CREATE TABLE `pengiriman` (
  `order_id` int(11) NOT NULL,
  `shipping_company` varchar(100) NOT NULL,
  `tracking_number` varchar(100) NOT NULL
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
(1, 1, 'Es Kristal Kemasan 5kg', 15000.00, 195),
(2, 1, 'Es Kristal Kemasan 10kg', 25000.00, 150),
(3, 2, 'Es Balok Super', 20000.00, 50),
(4, 3, 'Es Serut Halus per kg', 5000.00, 500),
(5, 2, 'Dry Ice Block', 120000.00, 15),
(1002, 1, 'Es Kristal Super #1', 45215.00, 31),
(1003, 1, 'Ice Cube Kemasan #2', 94521.00, 137),
(1004, 2, 'Es Serut Super #3', 32953.00, 78),
(1005, 4, 'Ice Cube Super #4', 74176.00, 149),
(1006, 4, 'Dry Ice Kiloan #5', 23570.00, 158),
(1007, 2, 'Dry Ice Kiloan #6', 64395.00, 85),
(1008, 5, 'Ice Cube Kiloan #7', 69696.00, 82),
(1009, 3, 'Ice Cube Kemasan #8', 54814.00, 89),
(1010, 2, 'Ice Cube Kiloan #9', 94925.00, 12),
(1011, 1, 'Es Balok Kemasan #10', 77101.00, 40),
(1012, 1, 'Dry Ice Premium #11', 92546.00, 104),
(1013, 2, 'Dry Ice Premium #12', 64158.00, 82),
(1014, 4, 'Es Kristal Super #13', 42942.00, 95),
(1015, 1, 'Dry Ice Ekonomis #14', 12181.00, 109),
(1016, 2, 'Ice Cube Super #15', 69331.00, 117),
(1017, 4, 'Es Serut Kiloan #16', 84365.00, 94),
(1018, 1, 'Es Kristal Super #17', 73867.00, 158),
(1019, 3, 'Ice Cube Kemasan #18', 51105.00, 38),
(1020, 5, 'Es Balok Kemasan #19', 70570.00, 78),
(1021, 2, 'Ice Cube Kemasan #20', 57707.00, 16),
(1022, 4, 'Ice Cube Kiloan #21', 80995.00, 134),
(1023, 1, 'Es Balok Ekonomis #22', 86389.00, 101),
(1024, 3, 'Dry Ice Super #23', 66436.00, 171),
(1025, 3, 'Ice Cube Kiloan #24', 73314.00, 159),
(1026, 2, 'Dry Ice Premium #25', 11323.00, 49),
(1027, 4, 'Ice Cube Premium #26', 35032.00, 44),
(1028, 2, 'Dry Ice Super #27', 42243.00, 63),
(1029, 1, 'Ice Cube Kiloan #28', 52259.00, 143),
(1030, 2, 'Dry Ice Ekonomis #29', 60426.00, 38),
(1031, 3, 'Dry Ice Super #30', 14644.00, 170),
(1032, 1, 'Es Kristal Kiloan #31', 44586.00, 18),
(1033, 3, 'Es Balok Super #32', 30663.00, 47),
(1034, 5, 'Ice Cube Kiloan #33', 19184.00, 33),
(1035, 5, 'Es Kristal Kemasan #34', 46292.00, 177),
(1036, 4, 'Dry Ice Super #35', 38862.00, 16),
(1037, 3, 'Ice Cube Kemasan #36', 58284.00, 176),
(1038, 3, 'Es Balok Super #37', 91641.00, 128),
(1039, 4, 'Es Balok Kiloan #38', 62428.00, 12),
(1040, 5, 'Ice Cube Kiloan #39', 98325.00, 52),
(1041, 3, 'Ice Cube Super #40', 78717.00, 124),
(1042, 5, 'Es Serut Ekonomis #41', 54642.00, 19),
(1043, 1, 'Es Balok Super #42', 12342.00, 188),
(1044, 1, 'Dry Ice Super #43', 82997.00, 75),
(1045, 3, 'Es Serut Premium #44', 55362.00, 52),
(1046, 2, 'Dry Ice Ekonomis #45', 56889.00, 41),
(1047, 3, 'Es Balok Ekonomis #46', 79162.00, 58),
(1048, 5, 'Dry Ice Kiloan #47', 58269.00, 50),
(1049, 3, 'Es Balok Kemasan #48', 78476.00, 67),
(1050, 5, 'Es Kristal Ekonomis #49', 66789.00, 35),
(1051, 3, 'Ice Cube Kiloan #50', 97847.00, 119),
(1052, 5, 'Es Balok Kemasan #51', 87377.00, 62),
(1053, 3, 'Ice Cube Premium #52', 59839.00, 87),
(1054, 1, 'Es Balok Kiloan #53', 54164.00, 167),
(1055, 5, 'Es Kristal Premium #54', 88435.00, 48),
(1056, 3, 'Dry Ice Kemasan #55', 51790.00, 76),
(1057, 3, 'Es Kristal Kiloan #56', 47625.00, 10),
(1058, 2, 'Ice Cube Kiloan #57', 50787.00, 180),
(1059, 5, 'Es Kristal Ekonomis #58', 43816.00, 100),
(1060, 4, 'Ice Cube Ekonomis #59', 95880.00, 10),
(1061, 3, 'Dry Ice Super #60', 14693.00, 121),
(1062, 5, 'Es Kristal Kemasan #61', 30617.00, 160),
(1063, 1, 'Es Serut Kemasan #62', 71441.00, 22),
(1064, 5, 'Es Serut Premium #63', 20042.00, 15),
(1065, 2, 'Ice Cube Kiloan #64', 68426.00, 14),
(1066, 1, 'Ice Cube Super #65', 18211.00, 32),
(1067, 4, 'Es Serut Super #66', 46258.00, 139),
(1068, 1, 'Dry Ice Super #67', 73703.00, 164),
(1069, 4, 'Es Balok Super #68', 32530.00, 142),
(1070, 1, 'Es Kristal Premium #69', 95432.00, 118),
(1071, 1, 'Es Serut Premium #70', 69666.00, 34),
(1072, 4, 'Es Serut Premium #71', 34813.00, 128),
(1073, 2, 'Es Balok Kiloan #72', 95441.00, 130),
(1074, 1, 'Es Kristal Super #73', 47772.00, 65),
(1075, 1, 'Es Kristal Kiloan #74', 44396.00, 185),
(1076, 3, 'Ice Cube Super #75', 41932.00, 200),
(1077, 5, 'Es Kristal Super #76', 46706.00, 11),
(1078, 1, 'Es Balok Ekonomis #77', 49027.00, 194),
(1079, 5, 'Es Balok Kiloan #78', 69125.00, 10),
(1080, 5, 'Ice Cube Kiloan #79', 28407.00, 35),
(1081, 5, 'Es Balok Kemasan #80', 68089.00, 99),
(1082, 4, 'Es Kristal Ekonomis #81', 77947.00, 89),
(1083, 2, 'Dry Ice Premium #82', 23079.00, 111),
(1084, 3, 'Es Kristal Premium #83', 18493.00, 73),
(1085, 5, 'Es Serut Super #84', 97324.00, 112),
(1086, 2, 'Dry Ice Ekonomis #85', 72216.00, 193),
(1087, 1, 'Ice Cube Super #86', 22780.00, 119),
(1088, 4, 'Es Balok Super #87', 41662.00, 67),
(1089, 5, 'Es Kristal Kiloan #88', 65669.00, 19),
(1090, 2, 'Ice Cube Kiloan #89', 63505.00, 16),
(1091, 2, 'Es Serut Ekonomis #90', 19861.00, 162),
(1092, 1, 'Es Serut Kiloan #91', 33738.00, 116),
(1093, 4, 'Ice Cube Ekonomis #92', 78094.00, 106),
(1094, 1, 'Es Kristal Super #93', 34889.00, 105),
(1095, 5, 'Dry Ice Super #94', 27926.00, 74),
(1096, 1, 'Dry Ice Super #95', 16384.00, 110),
(1097, 1, 'Es Serut Kemasan #96', 79008.00, 152),
(1098, 3, 'Ice Cube Kiloan #97', 53031.00, 200),
(1099, 3, 'Ice Cube Ekonomis #98', 41861.00, 33),
(1100, 5, 'Es Serut Kemasan #99', 74088.00, 98),
(1101, 5, 'Dry Ice Kiloan #100', 80192.00, 57),
(1102, 1, 'Dry Ice Kemasan #101', 43408.00, 84),
(1103, 2, 'Es Balok Super #102', 64703.00, 67),
(1104, 3, 'Es Kristal Super #103', 78280.00, 116),
(1105, 3, 'Es Kristal Kemasan #104', 59466.00, 100),
(1106, 3, 'Ice Cube Ekonomis #105', 50911.00, 183),
(1107, 4, 'Dry Ice Kemasan #106', 27695.00, 169),
(1108, 1, 'Es Balok Ekonomis #107', 12095.00, 85),
(1109, 4, 'Es Balok Ekonomis #108', 99735.00, 59),
(1110, 2, 'Es Balok Ekonomis #109', 15730.00, 182),
(1111, 4, 'Es Kristal Premium #110', 49817.00, 54),
(1112, 2, 'Es Balok Kiloan #111', 67360.00, 15),
(1113, 3, 'Dry Ice Super #112', 83715.00, 165),
(1114, 5, 'Es Serut Super #113', 64488.00, 161),
(1115, 3, 'Es Kristal Premium #114', 86530.00, 54),
(1116, 3, 'Ice Cube Super #115', 29293.00, 37),
(1117, 2, 'Ice Cube Ekonomis #116', 22545.00, 81),
(1118, 2, 'Dry Ice Kemasan #117', 85146.00, 16),
(1119, 2, 'Es Serut Kiloan #118', 61152.00, 22),
(1120, 5, 'Es Balok Ekonomis #119', 91507.00, 198),
(1121, 4, 'Es Serut Kiloan #120', 14738.00, 40),
(1122, 1, 'Dry Ice Premium #121', 58562.00, 20),
(1123, 5, 'Dry Ice Premium #122', 25265.00, 128),
(1124, 4, 'Ice Cube Ekonomis #123', 24987.00, 165),
(1125, 5, 'Dry Ice Kemasan #124', 41036.00, 56),
(1126, 3, 'Es Kristal Ekonomis #125', 41451.00, 187),
(1127, 5, 'Es Serut Kiloan #126', 88361.00, 107),
(1128, 3, 'Es Serut Super #127', 33740.00, 43),
(1129, 3, 'Es Balok Premium #128', 65329.00, 136),
(1130, 5, 'Es Balok Kiloan #129', 21005.00, 66),
(1131, 5, 'Es Serut Super #130', 83271.00, 190),
(1132, 5, 'Es Balok Super #131', 10231.00, 150),
(1133, 5, 'Es Serut Kemasan #132', 54876.00, 179),
(1134, 4, 'Ice Cube Kemasan #133', 42536.00, 104),
(1135, 4, 'Ice Cube Super #134', 21524.00, 100),
(1136, 3, 'Es Balok Super #135', 55417.00, 86),
(1137, 1, 'Es Balok Premium #136', 24746.00, 176),
(1138, 4, 'Es Balok Premium #137', 26184.00, 114),
(1139, 1, 'Es Balok Kiloan #138', 41762.00, 199),
(1140, 2, 'Es Kristal Premium #139', 92297.00, 31),
(1141, 2, 'Dry Ice Super #140', 14726.00, 153),
(1142, 1, 'Dry Ice Kiloan #141', 39355.00, 49),
(1143, 3, 'Es Balok Kemasan #142', 80967.00, 47),
(1144, 3, 'Es Kristal Kiloan #143', 86960.00, 17),
(1145, 3, 'Es Kristal Premium #144', 78582.00, 11),
(1146, 1, 'Es Serut Kiloan #145', 61131.00, 84),
(1147, 2, 'Es Kristal Premium #146', 93432.00, 23),
(1148, 5, 'Es Serut Ekonomis #147', 71743.00, 41),
(1149, 2, 'Ice Cube Ekonomis #148', 24985.00, 27),
(1150, 2, 'Es Serut Kemasan #149', 87916.00, 24),
(1151, 1, 'Ice Cube Ekonomis #150', 44148.00, 75),
(1152, 5, 'Es Serut Kemasan #151', 11087.00, 163),
(1153, 3, 'Ice Cube Kiloan #152', 12701.00, 39),
(1154, 3, 'Dry Ice Kemasan #153', 45817.00, 50),
(1155, 4, 'Es Serut Kemasan #154', 46861.00, 95),
(1156, 4, 'Es Kristal Kemasan #155', 90287.00, 88),
(1157, 4, 'Es Serut Premium #156', 52402.00, 160),
(1158, 1, 'Es Kristal Super #157', 55712.00, 56),
(1159, 4, 'Es Serut Premium #158', 37863.00, 71),
(1160, 1, 'Ice Cube Ekonomis #159', 80408.00, 102),
(1161, 1, 'Es Serut Ekonomis #160', 68479.00, 189),
(1162, 2, 'Es Balok Ekonomis #161', 26530.00, 110),
(1163, 1, 'Dry Ice Ekonomis #162', 72990.00, 41),
(1164, 5, 'Es Kristal Kiloan #163', 86131.00, 192),
(1165, 1, 'Es Serut Ekonomis #164', 71654.00, 188),
(1166, 4, 'Es Serut Kemasan #165', 49069.00, 159),
(1167, 4, 'Es Serut Kemasan #166', 45443.00, 123),
(1168, 4, 'Es Serut Kemasan #167', 74383.00, 182),
(1169, 2, 'Es Balok Super #168', 81024.00, 74),
(1170, 5, 'Dry Ice Premium #169', 25880.00, 169),
(1171, 2, 'Ice Cube Ekonomis #170', 83520.00, 91),
(1172, 4, 'Es Balok Premium #171', 70629.00, 141),
(1173, 2, 'Es Balok Premium #172', 34981.00, 24),
(1174, 3, 'Es Kristal Ekonomis #173', 23787.00, 196),
(1175, 4, 'Dry Ice Ekonomis #174', 56629.00, 63),
(1176, 3, 'Es Serut Super #175', 50160.00, 137),
(1177, 2, 'Ice Cube Premium #176', 82597.00, 53),
(1178, 3, 'Es Balok Premium #177', 30102.00, 62),
(1179, 4, 'Es Kristal Ekonomis #178', 48398.00, 168),
(1180, 5, 'Es Balok Super #179', 45273.00, 46),
(1181, 5, 'Es Balok Premium #180', 81671.00, 84),
(1182, 1, 'Dry Ice Ekonomis #181', 62430.00, 101),
(1183, 3, 'Dry Ice Kemasan #182', 66917.00, 118),
(1184, 3, 'Es Balok Kemasan #183', 99850.00, 56),
(1185, 2, 'Es Kristal Premium #184', 24755.00, 73),
(1186, 5, 'Es Kristal Kemasan #185', 90700.00, 139),
(1187, 3, 'Dry Ice Ekonomis #186', 58707.00, 41),
(1188, 5, 'Es Kristal Kiloan #187', 54961.00, 127),
(1189, 4, 'Es Serut Kemasan #188', 56252.00, 142),
(1190, 5, 'Es Serut Ekonomis #189', 16393.00, 159),
(1191, 5, 'Dry Ice Kemasan #190', 24330.00, 35),
(1192, 2, 'Es Kristal Ekonomis #191', 11192.00, 42),
(1193, 5, 'Es Serut Kemasan #192', 80156.00, 110),
(1194, 3, 'Es Balok Super #193', 78916.00, 186),
(1195, 3, 'Ice Cube Premium #194', 70798.00, 139),
(1196, 5, 'Ice Cube Super #195', 50864.00, 21),
(1197, 2, 'Es Serut Kiloan #196', 59855.00, 129),
(1198, 3, 'Ice Cube Super #197', 92527.00, 50),
(1199, 3, 'Ice Cube Super #198', 69556.00, 34),
(1200, 5, 'Ice Cube Kiloan #199', 33945.00, 75),
(1201, 4, 'Es Balok Kiloan #200', 29131.00, 22),
(1202, 3, 'Es Kristal Super #201', 79184.00, 27),
(1203, 1, 'Es Serut Kiloan #202', 62700.00, 77),
(1204, 4, 'Es Kristal Premium #203', 43001.00, 130),
(1205, 4, 'Es Balok Kiloan #204', 26443.00, 107),
(1206, 2, 'Es Serut Super #205', 26779.00, 154),
(1207, 4, 'Ice Cube Premium #206', 30041.00, 178),
(1208, 1, 'Dry Ice Kiloan #207', 63862.00, 88),
(1209, 4, 'Es Kristal Super #208', 59166.00, 111),
(1210, 3, 'Dry Ice Kemasan #209', 68512.00, 177),
(1211, 3, 'Dry Ice Super #210', 36681.00, 70),
(1212, 1, 'Dry Ice Super #211', 70149.00, 89),
(1213, 5, 'Ice Cube Super #212', 89607.00, 142),
(1214, 4, 'Es Balok Kiloan #213', 34434.00, 176),
(1215, 4, 'Ice Cube Super #214', 46215.00, 142),
(1216, 1, 'Dry Ice Kemasan #215', 92979.00, 189),
(1217, 1, 'Es Kristal Kiloan #216', 73591.00, 200),
(1218, 5, 'Ice Cube Kiloan #217', 66564.00, 87),
(1219, 2, 'Es Kristal Premium #218', 94386.00, 41),
(1220, 4, 'Es Kristal Premium #219', 26465.00, 97),
(1221, 5, 'Dry Ice Ekonomis #220', 15307.00, 18),
(1222, 1, 'Es Kristal Kiloan #221', 43383.00, 89),
(1223, 5, 'Es Serut Kemasan #222', 26342.00, 172),
(1224, 4, 'Es Serut Kemasan #223', 37412.00, 54),
(1225, 3, 'Es Kristal Premium #224', 21711.00, 126),
(1226, 1, 'Es Serut Kiloan #225', 48948.00, 59),
(1227, 3, 'Es Balok Ekonomis #226', 19326.00, 30),
(1228, 1, 'Es Kristal Super #227', 45440.00, 113),
(1229, 4, 'Dry Ice Premium #228', 85824.00, 128),
(1230, 5, 'Es Kristal Super #229', 96660.00, 30),
(1231, 1, 'Ice Cube Premium #230', 63313.00, 110),
(1232, 5, 'Es Balok Kemasan #231', 82655.00, 96),
(1233, 5, 'Ice Cube Premium #232', 18880.00, 43),
(1234, 1, 'Es Kristal Super #233', 22962.00, 94),
(1235, 4, 'Es Balok Premium #234', 93572.00, 120),
(1236, 4, 'Ice Cube Ekonomis #235', 89477.00, 83),
(1237, 5, 'Es Kristal Kiloan #236', 54754.00, 123),
(1238, 2, 'Es Balok Premium #237', 67689.00, 176),
(1239, 2, 'Es Serut Super #238', 70474.00, 165),
(1240, 4, 'Es Serut Ekonomis #239', 72667.00, 49),
(1241, 1, 'Es Balok Kemasan #240', 92964.00, 189),
(1242, 1, 'Es Balok Super #241', 13308.00, 165),
(1243, 3, 'Es Balok Kemasan #242', 11478.00, 187),
(1244, 4, 'Es Balok Ekonomis #243', 14957.00, 28),
(1245, 2, 'Es Kristal Kemasan #244', 28836.00, 171),
(1246, 3, 'Es Kristal Kiloan #245', 63125.00, 91),
(1247, 2, 'Ice Cube Ekonomis #246', 53953.00, 185),
(1248, 4, 'Es Balok Kemasan #247', 81734.00, 181),
(1249, 5, 'Dry Ice Ekonomis #248', 95534.00, 43),
(1250, 5, 'Es Serut Super #249', 97663.00, 29),
(1251, 5, 'Es Kristal Super #250', 70848.00, 125),
(1252, 3, 'Dry Ice Premium #251', 51327.00, 126),
(1253, 2, 'Es Balok Super #252', 10873.00, 137),
(1254, 3, 'Es Kristal Super #253', 44962.00, 75),
(1255, 3, 'Es Balok Super #254', 35061.00, 199),
(1256, 5, 'Es Serut Ekonomis #255', 34770.00, 98),
(1257, 4, 'Ice Cube Premium #256', 92596.00, 120),
(1258, 4, 'Dry Ice Kiloan #257', 81558.00, 78),
(1259, 3, 'Es Balok Kemasan #258', 34154.00, 121),
(1260, 5, 'Dry Ice Kiloan #259', 34064.00, 179),
(1261, 4, 'Dry Ice Kiloan #260', 13057.00, 184),
(1262, 1, 'Es Balok Premium #261', 64103.00, 163),
(1263, 1, 'Es Kristal Kemasan #262', 68526.00, 81),
(1264, 2, 'Ice Cube Premium #263', 58909.00, 80),
(1265, 2, 'Es Kristal Premium #264', 37049.00, 59),
(1266, 5, 'Es Kristal Kiloan #265', 76811.00, 39),
(1267, 3, 'Es Balok Ekonomis #266', 67893.00, 158),
(1268, 5, 'Es Serut Ekonomis #267', 13592.00, 152),
(1269, 4, 'Es Serut Ekonomis #268', 35682.00, 87),
(1270, 5, 'Es Serut Ekonomis #269', 97778.00, 94),
(1271, 3, 'Dry Ice Premium #270', 65745.00, 112),
(1272, 4, 'Es Kristal Premium #271', 24433.00, 120),
(1273, 5, 'Es Serut Kiloan #272', 96797.00, 108),
(1274, 3, 'Dry Ice Kemasan #273', 62302.00, 196),
(1275, 5, 'Dry Ice Premium #274', 96125.00, 129),
(1276, 1, 'Es Serut Ekonomis #275', 61018.00, 91),
(1277, 4, 'Dry Ice Kemasan #276', 40966.00, 127),
(1278, 5, 'Es Kristal Ekonomis #277', 12752.00, 111),
(1279, 2, 'Es Serut Premium #278', 92202.00, 119),
(1280, 4, 'Es Serut Kemasan #279', 61958.00, 117),
(1281, 4, 'Ice Cube Kemasan #280', 27790.00, 15),
(1282, 4, 'Ice Cube Super #281', 43189.00, 99),
(1283, 5, 'Ice Cube Kemasan #282', 42832.00, 196),
(1284, 2, 'Es Serut Kiloan #283', 46762.00, 73),
(1285, 2, 'Es Balok Ekonomis #284', 58344.00, 169),
(1286, 5, 'Ice Cube Kiloan #285', 46010.00, 190),
(1287, 2, 'Dry Ice Kiloan #286', 20945.00, 175),
(1288, 2, 'Dry Ice Ekonomis #287', 54488.00, 135),
(1289, 5, 'Dry Ice Ekonomis #288', 71096.00, 85),
(1290, 2, 'Dry Ice Kiloan #289', 93157.00, 156),
(1291, 2, 'Dry Ice Ekonomis #290', 90497.00, 34),
(1292, 5, 'Es Kristal Ekonomis #291', 99973.00, 18),
(1293, 4, 'Es Balok Ekonomis #292', 21345.00, 97),
(1294, 5, 'Es Balok Super #293', 37985.00, 105),
(1295, 3, 'Es Kristal Super #294', 50973.00, 149),
(1296, 2, 'Ice Cube Premium #295', 81486.00, 135),
(1297, 3, 'Ice Cube Super #296', 28546.00, 64),
(1298, 2, 'Es Kristal Premium #297', 91990.00, 56),
(1299, 4, 'Es Kristal Super #298', 67090.00, 38),
(1300, 1, 'Es Kristal Ekonomis #299', 49757.00, 158),
(1301, 2, 'Es Balok Ekonomis #300', 65944.00, 168),
(1302, 3, 'Dry Ice Premium #301', 97657.00, 23),
(1303, 1, 'Es Balok Premium #302', 37634.00, 170),
(1304, 3, 'Es Balok Super #303', 93283.00, 115),
(1305, 5, 'Ice Cube Premium #304', 88481.00, 11),
(1306, 5, 'Dry Ice Super #305', 73714.00, 155),
(1307, 5, 'Es Kristal Super #306', 58307.00, 25),
(1308, 5, 'Es Balok Premium #307', 85053.00, 175),
(1309, 4, 'Ice Cube Ekonomis #308', 21353.00, 48),
(1310, 3, 'Es Kristal Ekonomis #309', 10417.00, 109),
(1311, 1, 'Es Kristal Kemasan #310', 26734.00, 16),
(1312, 2, 'Es Kristal Premium #311', 57456.00, 166),
(1313, 5, 'Es Kristal Kiloan #312', 50954.00, 146),
(1314, 5, 'Es Balok Kiloan #313', 87690.00, 53),
(1315, 1, 'Es Kristal Kiloan #314', 17652.00, 126),
(1316, 1, 'Es Serut Premium #315', 14198.00, 45),
(1317, 4, 'Ice Cube Ekonomis #316', 55894.00, 23),
(1318, 4, 'Ice Cube Kiloan #317', 83243.00, 181),
(1319, 3, 'Dry Ice Ekonomis #318', 10377.00, 192),
(1320, 3, 'Es Kristal Kiloan #319', 22004.00, 91),
(1321, 4, 'Es Kristal Kemasan #320', 27406.00, 36),
(1322, 4, 'Es Balok Kiloan #321', 87735.00, 189),
(1323, 1, 'Es Serut Premium #322', 23820.00, 149),
(1324, 2, 'Es Serut Kiloan #323', 24462.00, 61),
(1325, 1, 'Es Balok Ekonomis #324', 29217.00, 33),
(1326, 3, 'Dry Ice Premium #325', 61301.00, 34),
(1327, 2, 'Es Kristal Kiloan #326', 61899.00, 77),
(1328, 4, 'Es Kristal Premium #327', 80044.00, 150),
(1329, 3, 'Es Kristal Ekonomis #328', 44428.00, 170),
(1330, 3, 'Es Balok Premium #329', 95175.00, 116),
(1331, 3, 'Ice Cube Kemasan #330', 34817.00, 58),
(1332, 3, 'Ice Cube Kemasan #331', 30847.00, 150),
(1333, 2, 'Dry Ice Premium #332', 34908.00, 95),
(1334, 3, 'Ice Cube Kiloan #333', 49466.00, 157),
(1335, 4, 'Dry Ice Kemasan #334', 51626.00, 102),
(1336, 5, 'Es Kristal Super #335', 15720.00, 84),
(1337, 1, 'Es Balok Super #336', 52416.00, 58),
(1338, 1, 'Es Kristal Kiloan #337', 53164.00, 124),
(1339, 3, 'Dry Ice Kemasan #338', 68364.00, 32),
(1340, 4, 'Es Serut Kiloan #339', 77067.00, 84),
(1341, 3, 'Ice Cube Kiloan #340', 50985.00, 185),
(1342, 1, 'Dry Ice Premium #341', 62111.00, 14),
(1343, 5, 'Es Kristal Ekonomis #342', 41636.00, 121),
(1344, 1, 'Es Balok Kiloan #343', 32931.00, 147),
(1345, 5, 'Ice Cube Kemasan #344', 80521.00, 135),
(1346, 5, 'Es Serut Kiloan #345', 50345.00, 152),
(1347, 1, 'Es Kristal Kiloan #346', 64400.00, 29),
(1348, 2, 'Es Balok Kiloan #347', 37834.00, 162),
(1349, 5, 'Dry Ice Premium #348', 76130.00, 196),
(1350, 3, 'Es Kristal Premium #349', 90350.00, 64),
(1351, 5, 'Es Serut Super #350', 50106.00, 69),
(1352, 4, 'Es Balok Super #351', 35259.00, 80),
(1353, 4, 'Es Kristal Kemasan #352', 22382.00, 149),
(1354, 4, 'Ice Cube Super #353', 18726.00, 34),
(1355, 1, 'Es Balok Ekonomis #354', 74298.00, 200),
(1356, 1, 'Es Serut Ekonomis #355', 79060.00, 55),
(1357, 4, 'Es Kristal Super #356', 45295.00, 166),
(1358, 1, 'Es Serut Kiloan #357', 67643.00, 174),
(1359, 1, 'Es Serut Super #358', 56354.00, 153),
(1360, 4, 'Es Balok Kemasan #359', 87909.00, 77),
(1361, 2, 'Es Serut Super #360', 27091.00, 116),
(1362, 1, 'Es Kristal Super #361', 57018.00, 123),
(1363, 3, 'Es Serut Super #362', 72767.00, 16),
(1364, 1, 'Dry Ice Ekonomis #363', 94888.00, 91),
(1365, 3, 'Ice Cube Ekonomis #364', 80518.00, 128),
(1366, 3, 'Ice Cube Kiloan #365', 11312.00, 69),
(1367, 3, 'Ice Cube Premium #366', 88758.00, 26),
(1368, 4, 'Es Kristal Kemasan #367', 46020.00, 174),
(1369, 4, 'Dry Ice Super #368', 32900.00, 185),
(1370, 2, 'Es Serut Premium #369', 76770.00, 69),
(1371, 5, 'Es Kristal Premium #370', 66539.00, 162),
(1372, 2, 'Ice Cube Kiloan #371', 21424.00, 172),
(1373, 4, 'Dry Ice Kiloan #372', 39425.00, 35),
(1374, 5, 'Es Serut Super #373', 84456.00, 141),
(1375, 4, 'Es Balok Kemasan #374', 71239.00, 151),
(1376, 5, 'Ice Cube Kiloan #375', 65955.00, 127),
(1377, 4, 'Dry Ice Kiloan #376', 49938.00, 16),
(1378, 5, 'Dry Ice Kiloan #377', 74011.00, 188),
(1379, 4, 'Es Balok Kemasan #378', 98813.00, 168),
(1380, 3, 'Es Serut Kiloan #379', 46955.00, 12),
(1381, 2, 'Dry Ice Ekonomis #380', 29971.00, 24),
(1382, 2, 'Ice Cube Ekonomis #381', 97778.00, 161),
(1383, 3, 'Es Kristal Kemasan #382', 57646.00, 128),
(1384, 3, 'Es Balok Premium #383', 73910.00, 74),
(1385, 1, 'Es Serut Kemasan #384', 14605.00, 127),
(1386, 3, 'Es Kristal Premium #385', 45258.00, 104),
(1387, 3, 'Dry Ice Ekonomis #386', 81147.00, 82),
(1388, 2, 'Dry Ice Premium #387', 62123.00, 161),
(1389, 2, 'Es Balok Kemasan #388', 63406.00, 154),
(1390, 3, 'Ice Cube Super #389', 81008.00, 21),
(1391, 1, 'Dry Ice Kiloan #390', 50792.00, 167),
(1392, 2, 'Es Serut Kiloan #391', 38476.00, 175),
(1393, 3, 'Es Balok Premium #392', 55773.00, 96),
(1394, 4, 'Dry Ice Kemasan #393', 29238.00, 160),
(1395, 5, 'Es Balok Kemasan #394', 19732.00, 95),
(1396, 2, 'Es Serut Kiloan #395', 34392.00, 188),
(1397, 5, 'Es Serut Premium #396', 65780.00, 72),
(1398, 3, 'Es Serut Super #397', 77668.00, 164),
(1399, 2, 'Ice Cube Super #398', 65011.00, 15),
(1400, 1, 'Es Serut Kemasan #399', 67493.00, 95),
(1401, 2, 'Dry Ice Kiloan #400', 13817.00, 47),
(1402, 2, 'Es Kristal Premium #401', 33784.00, 59),
(1403, 3, 'Es Serut Kiloan #402', 63948.00, 154),
(1404, 2, 'Es Kristal Kiloan #403', 19949.00, 142),
(1405, 3, 'Es Serut Premium #404', 76930.00, 120),
(1406, 5, 'Es Kristal Ekonomis #405', 69380.00, 125),
(1407, 4, 'Es Serut Ekonomis #406', 29830.00, 161),
(1408, 5, 'Es Kristal Kiloan #407', 19686.00, 139),
(1409, 5, 'Es Kristal Kiloan #408', 88024.00, 140),
(1410, 3, 'Es Serut Kemasan #409', 23613.00, 124),
(1411, 5, 'Es Balok Kiloan #410', 16143.00, 137),
(1412, 5, 'Es Serut Kiloan #411', 42419.00, 61),
(1413, 4, 'Ice Cube Ekonomis #412', 59276.00, 104),
(1414, 4, 'Ice Cube Premium #413', 84865.00, 142),
(1415, 1, 'Es Balok Super #414', 62707.00, 103),
(1416, 3, 'Es Balok Kemasan #415', 46841.00, 197),
(1417, 2, 'Es Kristal Ekonomis #416', 39416.00, 100),
(1418, 5, 'Es Balok Kemasan #417', 97555.00, 93),
(1419, 1, 'Dry Ice Kiloan #418', 26674.00, 185),
(1420, 1, 'Es Serut Kiloan #419', 93939.00, 76),
(1421, 2, 'Es Kristal Kiloan #420', 81744.00, 34),
(1422, 5, 'Es Kristal Premium #421', 87284.00, 162),
(1423, 1, 'Es Kristal Kemasan #422', 50082.00, 175),
(1424, 4, 'Es Serut Ekonomis #423', 55679.00, 187),
(1425, 1, 'Dry Ice Premium #424', 31555.00, 156),
(1426, 2, 'Ice Cube Premium #425', 41373.00, 80),
(1427, 1, 'Es Serut Kemasan #426', 79932.00, 111),
(1428, 4, 'Ice Cube Premium #427', 51428.00, 102),
(1429, 1, 'Es Serut Kemasan #428', 72411.00, 163),
(1430, 3, 'Es Balok Super #429', 54322.00, 13),
(1431, 3, 'Es Balok Super #430', 36503.00, 121),
(1432, 5, 'Ice Cube Super #431', 14749.00, 192),
(1433, 4, 'Es Serut Super #432', 48103.00, 122),
(1434, 1, 'Es Serut Premium #433', 41966.00, 42),
(1435, 4, 'Es Kristal Ekonomis #434', 39131.00, 56),
(1436, 1, 'Ice Cube Kemasan #435', 32141.00, 140),
(1437, 1, 'Ice Cube Ekonomis #436', 83012.00, 141),
(1438, 5, 'Dry Ice Kemasan #437', 39292.00, 72),
(1439, 3, 'Es Serut Kemasan #438', 29166.00, 108),
(1440, 5, 'Es Serut Kemasan #439', 36882.00, 56),
(1441, 5, 'Ice Cube Ekonomis #440', 66656.00, 177),
(1442, 1, 'Es Kristal Ekonomis #441', 99711.00, 169),
(1443, 2, 'Dry Ice Kemasan #442', 92538.00, 161),
(1444, 1, 'Dry Ice Kemasan #443', 19244.00, 44),
(1445, 3, 'Dry Ice Ekonomis #444', 57978.00, 171),
(1446, 5, 'Es Kristal Ekonomis #445', 66647.00, 64),
(1447, 1, 'Es Balok Kemasan #446', 29363.00, 69),
(1448, 5, 'Es Kristal Ekonomis #447', 53261.00, 193),
(1449, 5, 'Es Balok Kemasan #448', 74603.00, 73),
(1450, 3, 'Es Serut Kiloan #449', 80333.00, 111),
(1451, 5, 'Es Balok Premium #450', 61487.00, 171),
(1452, 5, 'Es Balok Kemasan #451', 29879.00, 12),
(1453, 2, 'Es Kristal Kiloan #452', 98819.00, 64),
(1454, 5, 'Es Kristal Ekonomis #453', 46374.00, 180),
(1455, 4, 'Es Kristal Super #454', 36645.00, 190),
(1456, 3, 'Es Balok Ekonomis #455', 65037.00, 51),
(1457, 3, 'Es Serut Kiloan #456', 81364.00, 27),
(1458, 3, 'Ice Cube Kiloan #457', 93615.00, 172),
(1459, 5, 'Es Serut Super #458', 40747.00, 195),
(1460, 5, 'Dry Ice Kemasan #459', 66084.00, 169),
(1461, 2, 'Ice Cube Kiloan #460', 74034.00, 64),
(1462, 4, 'Es Kristal Kiloan #461', 14293.00, 112),
(1463, 2, 'Es Balok Super #462', 60062.00, 28),
(1464, 4, 'Es Serut Super #463', 17738.00, 17),
(1465, 4, 'Dry Ice Super #464', 56286.00, 29),
(1466, 5, 'Es Serut Premium #465', 47632.00, 132),
(1467, 2, 'Es Balok Super #466', 53965.00, 34),
(1468, 3, 'Es Serut Super #467', 84988.00, 147),
(1469, 5, 'Dry Ice Kiloan #468', 13713.00, 70),
(1470, 4, 'Ice Cube Super #469', 78572.00, 184),
(1471, 4, 'Es Kristal Kiloan #470', 95909.00, 60),
(1472, 2, 'Dry Ice Ekonomis #471', 31629.00, 189),
(1473, 3, 'Es Balok Premium #472', 72269.00, 49),
(1474, 3, 'Es Kristal Kiloan #473', 42599.00, 41),
(1475, 4, 'Es Serut Kiloan #474', 69579.00, 141),
(1476, 2, 'Dry Ice Kiloan #475', 43239.00, 197),
(1477, 3, 'Ice Cube Ekonomis #476', 91827.00, 151),
(1478, 4, 'Ice Cube Kemasan #477', 79168.00, 71),
(1479, 2, 'Es Balok Kiloan #478', 69019.00, 79),
(1480, 4, 'Es Kristal Kemasan #479', 23651.00, 164),
(1481, 5, 'Ice Cube Premium #480', 79427.00, 180),
(1482, 2, 'Es Kristal Premium #481', 82928.00, 142),
(1483, 5, 'Es Balok Kemasan #482', 25658.00, 148),
(1484, 3, 'Es Serut Super #483', 99184.00, 120),
(1485, 2, 'Es Serut Kemasan #484', 84289.00, 32),
(1486, 3, 'Ice Cube Kiloan #485', 52392.00, 46),
(1487, 1, 'Es Kristal Super #486', 89189.00, 81),
(1488, 1, 'Es Serut Kemasan #487', 50814.00, 138),
(1489, 3, 'Es Kristal Super #488', 68701.00, 34),
(1490, 5, 'Es Kristal Super #489', 35633.00, 45),
(1491, 3, 'Es Serut Super #490', 30120.00, 145),
(1492, 2, 'Es Kristal Kemasan #491', 56102.00, 75),
(1493, 5, 'Dry Ice Ekonomis #492', 72383.00, 92),
(1494, 3, 'Es Balok Kiloan #493', 41281.00, 12),
(1495, 2, 'Es Serut Ekonomis #494', 98790.00, 193),
(1496, 1, 'Es Balok Super #495', 19638.00, 18),
(1497, 2, 'Dry Ice Kiloan #496', 58357.00, 14),
(1498, 5, 'Es Balok Ekonomis #497', 97321.00, 155),
(1499, 4, 'Dry Ice Ekonomis #498', 33138.00, 81),
(1500, 5, 'Es Kristal Ekonomis #499', 50571.00, 199),
(1501, 2, 'Dry Ice Ekonomis #500', 66694.00, 70),
(1502, 2, 'Dry Ice Kemasan #501', 46032.00, 118),
(1503, 5, 'Ice Cube Ekonomis #502', 81744.00, 67),
(1504, 1, 'Es Kristal Kiloan #503', 42612.00, 30),
(1505, 1, 'Dry Ice Premium #504', 33628.00, 90),
(1506, 1, 'Ice Cube Ekonomis #505', 48996.00, 152),
(1507, 4, 'Es Serut Super #506', 24945.00, 71),
(1508, 1, 'Es Kristal Super #507', 69499.00, 63),
(1509, 3, 'Dry Ice Ekonomis #508', 59958.00, 104),
(1510, 1, 'Es Kristal Premium #509', 99348.00, 36),
(1511, 1, 'Dry Ice Super #510', 36846.00, 111),
(1512, 4, 'Ice Cube Super #511', 85482.00, 122),
(1513, 1, 'Es Balok Kiloan #512', 80204.00, 51),
(1514, 4, 'Es Serut Premium #513', 71840.00, 146),
(1515, 2, 'Es Kristal Ekonomis #514', 59406.00, 106),
(1516, 5, 'Es Serut Kiloan #515', 16073.00, 159),
(1517, 5, 'Ice Cube Premium #516', 43599.00, 108),
(1518, 5, 'Dry Ice Kiloan #517', 39211.00, 89),
(1519, 4, 'Dry Ice Kiloan #518', 14576.00, 11),
(1520, 4, 'Ice Cube Kemasan #519', 81628.00, 96),
(1521, 3, 'Ice Cube Super #520', 86831.00, 77),
(1522, 2, 'Ice Cube Premium #521', 12224.00, 44),
(1523, 5, 'Dry Ice Super #522', 23161.00, 40),
(1524, 5, 'Es Serut Kiloan #523', 59231.00, 27),
(1525, 5, 'Es Serut Kiloan #524', 15703.00, 83),
(1526, 4, 'Es Serut Super #525', 89666.00, 93),
(1527, 2, 'Es Kristal Ekonomis #526', 99763.00, 10),
(1528, 2, 'Es Balok Kemasan #527', 41979.00, 109),
(1529, 3, 'Es Serut Super #528', 53539.00, 40),
(1530, 5, 'Es Balok Ekonomis #529', 39300.00, 18),
(1531, 1, 'Ice Cube Kiloan #530', 27083.00, 146),
(1532, 4, 'Es Balok Kiloan #531', 36684.00, 62),
(1533, 1, 'Es Serut Kemasan #532', 33137.00, 131),
(1534, 3, 'Es Balok Super #533', 74905.00, 55),
(1535, 2, 'Ice Cube Ekonomis #534', 45740.00, 155),
(1536, 5, 'Dry Ice Super #535', 54565.00, 176),
(1537, 3, 'Ice Cube Premium #536', 70340.00, 45),
(1538, 1, 'Es Balok Kemasan #537', 84344.00, 34),
(1539, 5, 'Es Serut Premium #538', 58000.00, 81),
(1540, 5, 'Es Serut Kiloan #539', 57388.00, 144),
(1541, 1, 'Ice Cube Premium #540', 48928.00, 198),
(1542, 3, 'Es Serut Kiloan #541', 83521.00, 11),
(1543, 3, 'Ice Cube Ekonomis #542', 41591.00, 91),
(1544, 5, 'Es Kristal Premium #543', 97073.00, 99),
(1545, 1, 'Es Kristal Super #544', 17096.00, 114),
(1546, 1, 'Es Kristal Kemasan #545', 34860.00, 183),
(1547, 3, 'Es Kristal Super #546', 22731.00, 173),
(1548, 1, 'Es Kristal Premium #547', 66864.00, 21),
(1549, 1, 'Es Balok Kiloan #548', 55287.00, 108),
(1550, 5, 'Es Balok Premium #549', 98218.00, 191),
(1551, 2, 'Es Balok Kemasan #550', 43376.00, 197),
(1552, 2, 'Ice Cube Super #551', 63132.00, 54),
(1553, 3, 'Dry Ice Premium #552', 11560.00, 184),
(1554, 1, 'Es Kristal Ekonomis #553', 60880.00, 126),
(1555, 5, 'Dry Ice Kiloan #554', 32483.00, 143),
(1556, 5, 'Ice Cube Kiloan #555', 76675.00, 32),
(1557, 5, 'Es Kristal Kiloan #556', 42587.00, 67),
(1558, 2, 'Es Kristal Ekonomis #557', 38840.00, 159),
(1559, 4, 'Es Balok Kemasan #558', 98390.00, 128),
(1560, 5, 'Es Balok Premium #559', 44268.00, 155),
(1561, 3, 'Es Kristal Ekonomis #560', 73381.00, 112),
(1562, 1, 'Es Kristal Kemasan #561', 95191.00, 196),
(1563, 2, 'Es Serut Super #562', 66721.00, 179),
(1564, 4, 'Es Kristal Kiloan #563', 51210.00, 77),
(1565, 5, 'Dry Ice Super #564', 73697.00, 70),
(1566, 3, 'Dry Ice Premium #565', 98262.00, 174),
(1567, 4, 'Es Serut Super #566', 30136.00, 200),
(1568, 1, 'Dry Ice Kiloan #567', 61673.00, 38),
(1569, 2, 'Es Balok Kemasan #568', 27324.00, 114),
(1570, 3, 'Ice Cube Kiloan #569', 97460.00, 169),
(1571, 3, 'Ice Cube Premium #570', 43277.00, 51),
(1572, 2, 'Ice Cube Super #571', 81569.00, 160),
(1573, 4, 'Es Serut Kiloan #572', 31606.00, 66),
(1574, 5, 'Es Kristal Kiloan #573', 70639.00, 64),
(1575, 3, 'Dry Ice Premium #574', 26115.00, 81),
(1576, 4, 'Es Kristal Premium #575', 76221.00, 84),
(1577, 4, 'Es Serut Kiloan #576', 57567.00, 51),
(1578, 4, 'Es Serut Premium #577', 29079.00, 114),
(1579, 1, 'Es Serut Kemasan #578', 37670.00, 200),
(1580, 2, 'Es Serut Kiloan #579', 35969.00, 99),
(1581, 5, 'Es Kristal Kemasan #580', 64229.00, 177),
(1582, 4, 'Es Balok Ekonomis #581', 64410.00, 162),
(1583, 3, 'Es Serut Ekonomis #582', 31084.00, 150),
(1584, 5, 'Es Balok Ekonomis #583', 63468.00, 41),
(1585, 2, 'Es Kristal Kiloan #584', 82089.00, 46),
(1586, 3, 'Es Serut Ekonomis #585', 89302.00, 117),
(1587, 5, 'Ice Cube Kiloan #586', 73571.00, 35),
(1588, 1, 'Es Kristal Super #587', 40016.00, 34),
(1589, 2, 'Es Balok Super #588', 87816.00, 89),
(1590, 2, 'Es Balok Ekonomis #589', 78742.00, 188),
(1591, 3, 'Es Serut Kemasan #590', 17811.00, 11),
(1592, 5, 'Dry Ice Kiloan #591', 64769.00, 111),
(1593, 2, 'Es Serut Premium #592', 55994.00, 39),
(1594, 1, 'Es Serut Ekonomis #593', 52323.00, 120),
(1595, 4, 'Es Balok Ekonomis #594', 27785.00, 26),
(1596, 3, 'Es Balok Kemasan #595', 15541.00, 141),
(1597, 4, 'Dry Ice Super #596', 46618.00, 176),
(1598, 4, 'Ice Cube Premium #597', 20226.00, 24),
(1599, 4, 'Ice Cube Premium #598', 75608.00, 65),
(1600, 1, 'Es Balok Super #599', 68382.00, 67),
(1601, 3, 'Ice Cube Kemasan #600', 72610.00, 172),
(1602, 3, 'Dry Ice Kemasan #601', 32919.00, 166),
(1603, 4, 'Es Kristal Kemasan #602', 67340.00, 47),
(1604, 1, 'Dry Ice Kiloan #603', 64271.00, 75),
(1605, 4, 'Es Serut Premium #604', 17452.00, 31),
(1606, 1, 'Ice Cube Kiloan #605', 38275.00, 116),
(1607, 3, 'Es Balok Kiloan #606', 88702.00, 65),
(1608, 4, 'Dry Ice Kemasan #607', 34226.00, 70),
(1609, 4, 'Es Serut Ekonomis #608', 23202.00, 39),
(1610, 1, 'Es Serut Premium #609', 60448.00, 51),
(1611, 2, 'Dry Ice Kemasan #610', 19904.00, 131),
(1612, 3, 'Dry Ice Premium #611', 38649.00, 51),
(1613, 3, 'Es Kristal Premium #612', 58574.00, 135),
(1614, 5, 'Es Serut Premium #613', 34545.00, 104),
(1615, 5, 'Dry Ice Kiloan #614', 96769.00, 107),
(1616, 4, 'Dry Ice Kemasan #615', 19593.00, 147),
(1617, 4, 'Ice Cube Ekonomis #616', 24423.00, 34),
(1618, 2, 'Es Kristal Super #617', 36935.00, 56),
(1619, 5, 'Dry Ice Premium #618', 17812.00, 35),
(1620, 2, 'Dry Ice Ekonomis #619', 28456.00, 103),
(1621, 5, 'Es Kristal Ekonomis #620', 29637.00, 66),
(1622, 5, 'Dry Ice Kiloan #621', 14641.00, 151),
(1623, 1, 'Ice Cube Super #622', 88618.00, 102),
(1624, 3, 'Dry Ice Premium #623', 18801.00, 130),
(1625, 2, 'Dry Ice Ekonomis #624', 41692.00, 117),
(1626, 3, 'Es Balok Kemasan #625', 82004.00, 177),
(1627, 3, 'Dry Ice Premium #626', 52112.00, 90),
(1628, 4, 'Es Kristal Kiloan #627', 43208.00, 196),
(1629, 1, 'Es Serut Kiloan #628', 92355.00, 82),
(1630, 2, 'Ice Cube Kiloan #629', 41876.00, 97),
(1631, 3, 'Ice Cube Kiloan #630', 92169.00, 91),
(1632, 2, 'Es Serut Super #631', 66317.00, 72),
(1633, 3, 'Es Kristal Super #632', 13058.00, 43),
(1634, 5, 'Ice Cube Super #633', 63564.00, 101),
(1635, 2, 'Es Kristal Super #634', 13922.00, 120),
(1636, 2, 'Ice Cube Premium #635', 59905.00, 14),
(1637, 2, 'Ice Cube Super #636', 53210.00, 135),
(1638, 5, 'Es Serut Ekonomis #637', 85980.00, 28),
(1639, 2, 'Es Balok Premium #638', 50003.00, 162),
(1640, 3, 'Ice Cube Kiloan #639', 34357.00, 158),
(1641, 4, 'Es Balok Kemasan #640', 22850.00, 54),
(1642, 2, 'Ice Cube Premium #641', 34021.00, 99),
(1643, 2, 'Dry Ice Kiloan #642', 35196.00, 71),
(1644, 5, 'Ice Cube Premium #643', 67958.00, 73),
(1645, 4, 'Es Serut Premium #644', 45122.00, 108),
(1646, 2, 'Ice Cube Premium #645', 36472.00, 135),
(1647, 2, 'Es Kristal Premium #646', 58469.00, 199),
(1648, 5, 'Es Kristal Kemasan #647', 37771.00, 128),
(1649, 4, 'Es Kristal Premium #648', 34325.00, 180),
(1650, 1, 'Es Serut Ekonomis #649', 95874.00, 137),
(1651, 3, 'Dry Ice Super #650', 11332.00, 83),
(1652, 2, 'Es Balok Kiloan #651', 48471.00, 166),
(1653, 2, 'Es Balok Super #652', 77533.00, 110),
(1654, 4, 'Es Balok Kiloan #653', 38804.00, 19),
(1655, 3, 'Dry Ice Super #654', 90330.00, 82),
(1656, 2, 'Es Balok Premium #655', 68608.00, 182),
(1657, 5, 'Es Balok Kemasan #656', 20107.00, 116),
(1658, 3, 'Dry Ice Premium #657', 95278.00, 19),
(1659, 1, 'Es Balok Ekonomis #658', 33757.00, 131),
(1660, 1, 'Ice Cube Kemasan #659', 71635.00, 134),
(1661, 1, 'Es Kristal Kemasan #660', 18927.00, 90),
(1662, 2, 'Dry Ice Super #661', 86464.00, 50),
(1663, 2, 'Es Kristal Premium #662', 61184.00, 128),
(1664, 2, 'Es Serut Kemasan #663', 94115.00, 84),
(1665, 2, 'Es Kristal Kemasan #664', 48070.00, 12),
(1666, 4, 'Es Serut Premium #665', 64649.00, 129),
(1667, 5, 'Es Kristal Kemasan #666', 60495.00, 35),
(1668, 1, 'Es Balok Super #667', 76260.00, 120),
(1669, 2, 'Es Balok Kemasan #668', 34499.00, 175),
(1670, 1, 'Es Balok Ekonomis #669', 94607.00, 25),
(1671, 4, 'Es Kristal Kiloan #670', 88690.00, 49),
(1672, 4, 'Es Serut Kemasan #671', 15358.00, 31),
(1673, 4, 'Ice Cube Super #672', 42099.00, 15),
(1674, 3, 'Dry Ice Kemasan #673', 21531.00, 142),
(1675, 2, 'Es Balok Kemasan #674', 62409.00, 170),
(1676, 2, 'Es Kristal Premium #675', 80204.00, 89),
(1677, 4, 'Ice Cube Kiloan #676', 89655.00, 136),
(1678, 4, 'Es Serut Kiloan #677', 82491.00, 110),
(1679, 1, 'Es Kristal Kiloan #678', 61880.00, 174),
(1680, 3, 'Es Serut Super #679', 80601.00, 155),
(1681, 4, 'Es Balok Kemasan #680', 14499.00, 107),
(1682, 2, 'Es Serut Premium #681', 29357.00, 89),
(1683, 3, 'Es Serut Kiloan #682', 86154.00, 180),
(1684, 3, 'Es Serut Ekonomis #683', 93889.00, 110),
(1685, 4, 'Es Balok Ekonomis #684', 71840.00, 135),
(1686, 2, 'Es Serut Kemasan #685', 60225.00, 35),
(1687, 3, 'Es Kristal Premium #686', 70457.00, 151),
(1688, 3, 'Es Balok Premium #687', 14175.00, 61),
(1689, 2, 'Ice Cube Super #688', 42161.00, 81),
(1690, 2, 'Dry Ice Kiloan #689', 56733.00, 188),
(1691, 2, 'Ice Cube Ekonomis #690', 25048.00, 56),
(1692, 3, 'Es Serut Super #691', 26376.00, 49),
(1693, 5, 'Ice Cube Kemasan #692', 96849.00, 37),
(1694, 5, 'Dry Ice Kemasan #693', 66460.00, 128),
(1695, 4, 'Es Balok Kemasan #694', 95842.00, 98),
(1696, 1, 'Es Serut Kemasan #695', 43731.00, 90),
(1697, 1, 'Dry Ice Ekonomis #696', 39547.00, 82),
(1698, 3, 'Dry Ice Super #697', 65761.00, 123),
(1699, 5, 'Dry Ice Super #698', 82058.00, 181),
(1700, 3, 'Ice Cube Kiloan #699', 11231.00, 72),
(1701, 4, 'Es Balok Premium #700', 20352.00, 166),
(1702, 3, 'Es Balok Super #701', 80623.00, 67),
(1703, 2, 'Ice Cube Super #702', 31717.00, 122),
(1704, 3, 'Es Serut Kemasan #703', 79051.00, 23),
(1705, 2, 'Ice Cube Ekonomis #704', 66091.00, 146),
(1706, 2, 'Ice Cube Premium #705', 89069.00, 78),
(1707, 3, 'Es Serut Kiloan #706', 41435.00, 131),
(1708, 3, 'Es Serut Kiloan #707', 33076.00, 105),
(1709, 2, 'Es Serut Ekonomis #708', 39140.00, 91),
(1710, 3, 'Dry Ice Ekonomis #709', 69741.00, 76),
(1711, 3, 'Ice Cube Super #710', 89226.00, 170),
(1712, 2, 'Dry Ice Kemasan #711', 51208.00, 199),
(1713, 5, 'Es Kristal Super #712', 82636.00, 96),
(1714, 4, 'Dry Ice Premium #713', 27424.00, 13),
(1715, 4, 'Es Balok Kiloan #714', 86492.00, 77),
(1716, 3, 'Es Serut Ekonomis #715', 99234.00, 130),
(1717, 1, 'Dry Ice Ekonomis #716', 50326.00, 23),
(1718, 4, 'Dry Ice Kiloan #717', 76354.00, 108),
(1719, 5, 'Es Kristal Ekonomis #718', 88826.00, 145),
(1720, 3, 'Ice Cube Kemasan #719', 90312.00, 64),
(1721, 3, 'Es Balok Premium #720', 15661.00, 44),
(1722, 4, 'Es Serut Kiloan #721', 88256.00, 137),
(1723, 3, 'Es Kristal Premium #722', 62591.00, 10),
(1724, 2, 'Dry Ice Ekonomis #723', 30561.00, 33),
(1725, 5, 'Es Kristal Kiloan #724', 12212.00, 165),
(1726, 3, 'Dry Ice Super #725', 68258.00, 78),
(1727, 4, 'Es Serut Kiloan #726', 20562.00, 74),
(1728, 2, 'Es Balok Ekonomis #727', 30231.00, 94),
(1729, 2, 'Ice Cube Kiloan #728', 99289.00, 191),
(1730, 4, 'Dry Ice Premium #729', 29527.00, 60),
(1731, 2, 'Es Serut Ekonomis #730', 20049.00, 17),
(1732, 2, 'Es Kristal Premium #731', 88678.00, 94),
(1733, 3, 'Es Balok Ekonomis #732', 72078.00, 140),
(1734, 4, 'Es Balok Premium #733', 13024.00, 125),
(1735, 1, 'Ice Cube Super #734', 66002.00, 162),
(1736, 3, 'Es Serut Premium #735', 12028.00, 195),
(1737, 5, 'Es Balok Premium #736', 97595.00, 185),
(1738, 5, 'Es Serut Super #737', 97573.00, 138),
(1739, 3, 'Es Kristal Kiloan #738', 92836.00, 143),
(1740, 5, 'Es Serut Ekonomis #739', 17686.00, 124),
(1741, 1, 'Es Kristal Ekonomis #740', 75537.00, 45),
(1742, 1, 'Ice Cube Ekonomis #741', 79491.00, 15),
(1743, 4, 'Ice Cube Kemasan #742', 56517.00, 176),
(1744, 1, 'Es Balok Ekonomis #743', 79516.00, 175),
(1745, 5, 'Ice Cube Premium #744', 48847.00, 150),
(1746, 4, 'Es Serut Kemasan #745', 72573.00, 52),
(1747, 5, 'Es Kristal Kemasan #746', 94886.00, 30),
(1748, 5, 'Es Kristal Kemasan #747', 54276.00, 171),
(1749, 2, 'Es Serut Super #748', 47177.00, 161),
(1750, 2, 'Es Balok Kiloan #749', 41814.00, 35),
(1751, 5, 'Es Balok Ekonomis #750', 96198.00, 59),
(1752, 5, 'Es Balok Ekonomis #751', 53342.00, 43),
(1753, 3, 'Dry Ice Super #752', 15626.00, 28),
(1754, 2, 'Es Serut Premium #753', 26816.00, 29),
(1755, 3, 'Ice Cube Ekonomis #754', 46998.00, 41),
(1756, 1, 'Ice Cube Kemasan #755', 27045.00, 134),
(1757, 3, 'Es Kristal Premium #756', 71854.00, 59),
(1758, 1, 'Ice Cube Kiloan #757', 66526.00, 84),
(1759, 3, 'Es Kristal Super #758', 65936.00, 82),
(1760, 3, 'Dry Ice Super #759', 16265.00, 167),
(1761, 1, 'Es Balok Kemasan #760', 53710.00, 56),
(1762, 1, 'Es Balok Super #761', 91057.00, 168),
(1763, 5, 'Es Serut Kiloan #762', 50090.00, 117),
(1764, 5, 'Dry Ice Kemasan #763', 14754.00, 131),
(1765, 1, 'Es Balok Kemasan #764', 71022.00, 117),
(1766, 2, 'Ice Cube Kemasan #765', 26437.00, 158),
(1767, 1, 'Ice Cube Ekonomis #766', 71715.00, 45),
(1768, 5, 'Es Kristal Kemasan #767', 22657.00, 72),
(1769, 2, 'Es Balok Premium #768', 57996.00, 192),
(1770, 4, 'Dry Ice Ekonomis #769', 69727.00, 18),
(1771, 4, 'Es Kristal Kemasan #770', 49111.00, 95),
(1772, 4, 'Dry Ice Premium #771', 42341.00, 33),
(1773, 4, 'Es Balok Premium #772', 92984.00, 49),
(1774, 3, 'Es Serut Ekonomis #773', 34284.00, 102),
(1775, 3, 'Dry Ice Premium #774', 13136.00, 164),
(1776, 1, 'Es Balok Super #775', 53400.00, 74),
(1777, 4, 'Ice Cube Kiloan #776', 30346.00, 42),
(1778, 3, 'Ice Cube Super #777', 95465.00, 15),
(1779, 2, 'Dry Ice Ekonomis #778', 39811.00, 133),
(1780, 5, 'Es Serut Kiloan #779', 84399.00, 154),
(1781, 2, 'Es Serut Kemasan #780', 94365.00, 71),
(1782, 2, 'Es Balok Kiloan #781', 31080.00, 160),
(1783, 2, 'Ice Cube Kemasan #782', 52238.00, 16),
(1784, 2, 'Ice Cube Super #783', 60626.00, 171),
(1785, 5, 'Es Balok Ekonomis #784', 51749.00, 11),
(1786, 5, 'Es Serut Ekonomis #785', 39759.00, 84),
(1787, 2, 'Es Serut Super #786', 87816.00, 146),
(1788, 3, 'Es Serut Kiloan #787', 89167.00, 61),
(1789, 5, 'Es Kristal Premium #788', 37567.00, 129),
(1790, 2, 'Es Serut Kemasan #789', 44667.00, 156),
(1791, 2, 'Dry Ice Premium #790', 89768.00, 40),
(1792, 3, 'Es Serut Premium #791', 41167.00, 160),
(1793, 4, 'Ice Cube Kemasan #792', 48349.00, 96),
(1794, 1, 'Es Kristal Ekonomis #793', 15684.00, 111),
(1795, 2, 'Es Balok Ekonomis #794', 16304.00, 20),
(1796, 3, 'Es Serut Kemasan #795', 20395.00, 169),
(1797, 3, 'Es Balok Ekonomis #796', 97883.00, 138),
(1798, 2, 'Es Serut Premium #797', 75961.00, 39),
(1799, 3, 'Es Balok Kiloan #798', 40561.00, 18),
(1800, 4, 'Es Kristal Kiloan #799', 47754.00, 34),
(1801, 4, 'Ice Cube Premium #800', 45261.00, 188),
(1802, 3, 'Es Serut Kemasan #801', 25560.00, 115),
(1803, 4, 'Es Kristal Kiloan #802', 71688.00, 128),
(1804, 3, 'Dry Ice Ekonomis #803', 19965.00, 73),
(1805, 3, 'Es Serut Super #804', 50764.00, 37),
(1806, 1, 'Dry Ice Ekonomis #805', 12550.00, 158),
(1807, 3, 'Es Serut Ekonomis #806', 41190.00, 144),
(1808, 1, 'Dry Ice Premium #807', 50374.00, 186),
(1809, 5, 'Es Balok Kiloan #808', 67103.00, 63),
(1810, 5, 'Ice Cube Kemasan #809', 85471.00, 167),
(1811, 2, 'Es Balok Ekonomis #810', 84349.00, 34),
(1812, 5, 'Es Serut Ekonomis #811', 73409.00, 196),
(1813, 3, 'Es Serut Premium #812', 65248.00, 88),
(1814, 1, 'Es Balok Kemasan #813', 78148.00, 66),
(1815, 4, 'Es Serut Premium #814', 69980.00, 79),
(1816, 2, 'Es Serut Ekonomis #815', 20538.00, 192),
(1817, 3, 'Ice Cube Super #816', 79469.00, 76),
(1818, 3, 'Ice Cube Ekonomis #817', 72765.00, 11),
(1819, 2, 'Es Balok Kiloan #818', 80887.00, 146),
(1820, 1, 'Es Kristal Super #819', 17299.00, 92),
(1821, 5, 'Es Serut Premium #820', 32578.00, 124),
(1822, 5, 'Es Balok Kiloan #821', 51892.00, 75),
(1823, 1, 'Ice Cube Super #822', 15526.00, 26),
(1824, 3, 'Es Serut Kemasan #823', 11188.00, 162),
(1825, 2, 'Es Serut Super #824', 24921.00, 100),
(1826, 3, 'Ice Cube Kemasan #825', 87860.00, 27),
(1827, 3, 'Es Kristal Super #826', 81371.00, 186),
(1828, 4, 'Ice Cube Kiloan #827', 65294.00, 175),
(1829, 1, 'Es Balok Ekonomis #828', 60593.00, 21),
(1830, 3, 'Es Balok Ekonomis #829', 73712.00, 30),
(1831, 3, 'Es Kristal Kiloan #830', 21365.00, 97),
(1832, 3, 'Es Kristal Kemasan #831', 97977.00, 130),
(1833, 2, 'Es Balok Ekonomis #832', 57307.00, 13),
(1834, 2, 'Es Balok Ekonomis #833', 38137.00, 120),
(1835, 2, 'Dry Ice Super #834', 27621.00, 11),
(1836, 5, 'Es Serut Kemasan #835', 74963.00, 138),
(1837, 1, 'Es Serut Premium #836', 86872.00, 149),
(1838, 1, 'Es Serut Kiloan #837', 46684.00, 81),
(1839, 2, 'Dry Ice Kemasan #838', 76394.00, 112),
(1840, 5, 'Es Balok Super #839', 65373.00, 94),
(1841, 3, 'Es Serut Ekonomis #840', 71326.00, 102),
(1842, 5, 'Dry Ice Kemasan #841', 62287.00, 122),
(1843, 2, 'Dry Ice Kemasan #842', 86197.00, 12),
(1844, 3, 'Es Balok Super #843', 35491.00, 35),
(1845, 1, 'Dry Ice Ekonomis #844', 93641.00, 183),
(1846, 3, 'Ice Cube Ekonomis #845', 72152.00, 15),
(1847, 1, 'Es Kristal Kemasan #846', 41609.00, 129),
(1848, 2, 'Dry Ice Ekonomis #847', 87094.00, 172),
(1849, 3, 'Es Kristal Premium #848', 97163.00, 178),
(1850, 3, 'Dry Ice Premium #849', 32458.00, 184),
(1851, 5, 'Es Serut Super #850', 75371.00, 81),
(1852, 4, 'Ice Cube Kemasan #851', 49869.00, 198),
(1853, 3, 'Ice Cube Kiloan #852', 73405.00, 164),
(1854, 3, 'Dry Ice Kiloan #853', 71289.00, 55),
(1855, 5, 'Es Serut Kemasan #854', 19159.00, 195),
(1856, 1, 'Es Kristal Super #855', 37351.00, 104),
(1857, 3, 'Dry Ice Kemasan #856', 80110.00, 64),
(1858, 2, 'Dry Ice Kiloan #857', 63034.00, 18),
(1859, 4, 'Es Serut Ekonomis #858', 26630.00, 140),
(1860, 3, 'Es Serut Kiloan #859', 27377.00, 183),
(1861, 4, 'Dry Ice Ekonomis #860', 59098.00, 42),
(1862, 3, 'Dry Ice Kiloan #861', 62881.00, 137),
(1863, 4, 'Ice Cube Ekonomis #862', 78038.00, 146),
(1864, 3, 'Es Kristal Super #863', 24591.00, 120),
(1865, 1, 'Dry Ice Kiloan #864', 55818.00, 95),
(1866, 3, 'Ice Cube Super #865', 11723.00, 79),
(1867, 4, 'Ice Cube Ekonomis #866', 17008.00, 65),
(1868, 1, 'Dry Ice Kiloan #867', 54932.00, 25),
(1869, 4, 'Es Kristal Premium #868', 86622.00, 118),
(1870, 3, 'Es Serut Super #869', 59209.00, 166),
(1871, 2, 'Es Balok Kiloan #870', 61819.00, 168),
(1872, 5, 'Es Serut Kemasan #871', 69261.00, 173),
(1873, 3, 'Dry Ice Ekonomis #872', 49974.00, 127),
(1874, 5, 'Dry Ice Ekonomis #873', 43568.00, 91),
(1875, 5, 'Es Balok Kiloan #874', 42644.00, 152),
(1876, 3, 'Ice Cube Super #875', 58187.00, 70),
(1877, 1, 'Ice Cube Premium #876', 22048.00, 138),
(1878, 5, 'Ice Cube Kemasan #877', 62071.00, 37),
(1879, 3, 'Dry Ice Ekonomis #878', 50776.00, 151),
(1880, 3, 'Ice Cube Super #879', 41070.00, 69),
(1881, 1, 'Es Balok Premium #880', 54948.00, 175),
(1882, 4, 'Dry Ice Kiloan #881', 13510.00, 28),
(1883, 1, 'Es Kristal Kiloan #882', 25409.00, 136),
(1884, 1, 'Dry Ice Premium #883', 35388.00, 184),
(1885, 2, 'Ice Cube Super #884', 82279.00, 151),
(1886, 1, 'Es Balok Super #885', 53397.00, 64),
(1887, 4, 'Dry Ice Ekonomis #886', 56914.00, 50),
(1888, 3, 'Es Kristal Ekonomis #887', 42600.00, 22),
(1889, 2, 'Ice Cube Kiloan #888', 19754.00, 69),
(1890, 3, 'Es Balok Kiloan #889', 77215.00, 66),
(1891, 5, 'Es Kristal Super #890', 91173.00, 195),
(1892, 1, 'Es Serut Premium #891', 59529.00, 85),
(1893, 1, 'Es Serut Ekonomis #892', 17579.00, 162),
(1894, 4, 'Es Kristal Ekonomis #893', 23030.00, 90),
(1895, 4, 'Ice Cube Kiloan #894', 51898.00, 39),
(1896, 4, 'Dry Ice Kemasan #895', 98256.00, 48),
(1897, 5, 'Es Serut Premium #896', 84527.00, 31),
(1898, 3, 'Es Balok Ekonomis #897', 62464.00, 119),
(1899, 2, 'Dry Ice Ekonomis #898', 46252.00, 116),
(1900, 2, 'Es Balok Super #899', 49803.00, 85),
(1901, 1, 'Ice Cube Kiloan #900', 12983.00, 185),
(1902, 3, 'Dry Ice Super #901', 66597.00, 63),
(1903, 3, 'Es Kristal Premium #902', 98100.00, 95),
(1904, 4, 'Ice Cube Premium #903', 85154.00, 142),
(1905, 1, 'Ice Cube Ekonomis #904', 44631.00, 59),
(1906, 4, 'Es Balok Ekonomis #905', 94981.00, 181),
(1907, 5, 'Es Serut Kiloan #906', 11252.00, 76),
(1908, 1, 'Es Kristal Super #907', 55617.00, 194),
(1909, 5, 'Ice Cube Super #908', 91085.00, 27),
(1910, 3, 'Es Kristal Super #909', 68862.00, 67),
(1911, 5, 'Es Balok Kiloan #910', 94075.00, 60),
(1912, 2, 'Dry Ice Kiloan #911', 28237.00, 161),
(1913, 5, 'Es Serut Ekonomis #912', 99143.00, 191),
(1914, 2, 'Es Kristal Kiloan #913', 44122.00, 43),
(1915, 4, 'Dry Ice Super #914', 11421.00, 69),
(1916, 4, 'Dry Ice Kemasan #915', 73540.00, 106),
(1917, 5, 'Es Serut Premium #916', 80970.00, 171),
(1918, 2, 'Es Serut Kemasan #917', 33073.00, 104),
(1919, 5, 'Es Serut Super #918', 47368.00, 158),
(1920, 3, 'Dry Ice Super #919', 37845.00, 195),
(1921, 1, 'Es Kristal Ekonomis #920', 69233.00, 60),
(1922, 1, 'Dry Ice Premium #921', 89638.00, 126),
(1923, 4, 'Ice Cube Kiloan #922', 52060.00, 46),
(1924, 3, 'Dry Ice Premium #923', 50249.00, 60),
(1925, 2, 'Es Kristal Premium #924', 87920.00, 61),
(1926, 5, 'Ice Cube Ekonomis #925', 93332.00, 114),
(1927, 5, 'Dry Ice Ekonomis #926', 79622.00, 79),
(1928, 1, 'Dry Ice Premium #927', 17877.00, 128),
(1929, 3, 'Dry Ice Kiloan #928', 63825.00, 102),
(1930, 4, 'Es Serut Kemasan #929', 88123.00, 83),
(1931, 3, 'Es Kristal Kemasan #930', 87273.00, 147),
(1932, 1, 'Ice Cube Kemasan #931', 30520.00, 77),
(1933, 2, 'Es Kristal Premium #932', 65692.00, 93),
(1934, 3, 'Es Serut Super #933', 20242.00, 143),
(1935, 2, 'Dry Ice Kemasan #934', 71559.00, 76),
(1936, 2, 'Es Serut Super #935', 86055.00, 102),
(1937, 4, 'Dry Ice Super #936', 21610.00, 188),
(1938, 4, 'Es Kristal Ekonomis #937', 94554.00, 13),
(1939, 5, 'Ice Cube Super #938', 62787.00, 93),
(1940, 2, 'Es Balok Ekonomis #939', 90335.00, 109),
(1941, 5, 'Es Serut Super #940', 98863.00, 107),
(1942, 2, 'Es Kristal Kemasan #941', 53599.00, 80),
(1943, 2, 'Es Kristal Super #942', 40718.00, 96),
(1944, 5, 'Ice Cube Ekonomis #943', 35389.00, 82),
(1945, 1, 'Ice Cube Premium #944', 56709.00, 151),
(1946, 5, 'Dry Ice Kemasan #945', 14905.00, 183),
(1947, 5, 'Es Serut Kemasan #946', 25254.00, 83),
(1948, 4, 'Dry Ice Premium #947', 81914.00, 88),
(1949, 2, 'Es Balok Kemasan #948', 53494.00, 121),
(1950, 3, 'Es Serut Ekonomis #949', 38944.00, 127),
(1951, 5, 'Ice Cube Ekonomis #950', 68163.00, 152),
(1952, 2, 'Dry Ice Kemasan #951', 54434.00, 25),
(1953, 3, 'Es Kristal Kiloan #952', 54861.00, 142),
(1954, 5, 'Es Serut Ekonomis #953', 31973.00, 159),
(1955, 2, 'Es Kristal Ekonomis #954', 44087.00, 167),
(1956, 1, 'Es Balok Premium #955', 89739.00, 166),
(1957, 4, 'Ice Cube Super #956', 63926.00, 152),
(1958, 1, 'Es Serut Ekonomis #957', 58713.00, 166),
(1959, 3, 'Dry Ice Premium #958', 47319.00, 125),
(1960, 3, 'Es Serut Kemasan #959', 65008.00, 191),
(1961, 3, 'Es Serut Premium #960', 60934.00, 102),
(1962, 2, 'Es Serut Kiloan #961', 81033.00, 159),
(1963, 1, 'Ice Cube Kiloan #962', 86598.00, 83),
(1964, 3, 'Dry Ice Ekonomis #963', 32685.00, 24),
(1965, 3, 'Dry Ice Super #964', 36085.00, 152),
(1966, 5, 'Dry Ice Ekonomis #965', 99519.00, 114),
(1967, 3, 'Ice Cube Super #966', 77415.00, 66),
(1968, 3, 'Ice Cube Premium #967', 86085.00, 174),
(1969, 5, 'Ice Cube Super #968', 53167.00, 196),
(1970, 5, 'Es Balok Premium #969', 58619.00, 148),
(1971, 5, 'Es Serut Kiloan #970', 44270.00, 50),
(1972, 4, 'Es Balok Ekonomis #971', 53601.00, 196),
(1973, 2, 'Ice Cube Premium #972', 65854.00, 144),
(1974, 2, 'Ice Cube Kiloan #973', 18055.00, 22),
(1975, 5, 'Dry Ice Ekonomis #974', 82006.00, 41),
(1976, 3, 'Dry Ice Kiloan #975', 16441.00, 94),
(1977, 4, 'Es Serut Super #976', 66780.00, 72),
(1978, 1, 'Dry Ice Kiloan #977', 73218.00, 17),
(1979, 5, 'Ice Cube Super #978', 15129.00, 52),
(1980, 2, 'Es Balok Kiloan #979', 55058.00, 50),
(1981, 5, 'Ice Cube Kemasan #980', 48108.00, 127),
(1982, 2, 'Dry Ice Premium #981', 95710.00, 31),
(1983, 1, 'Es Kristal Kemasan #982', 95839.00, 36),
(1984, 4, 'Ice Cube Ekonomis #983', 49487.00, 72),
(1985, 1, 'Es Serut Kiloan #984', 41299.00, 39),
(1986, 1, 'Dry Ice Super #985', 78285.00, 182),
(1987, 2, 'Ice Cube Premium #986', 38002.00, 199),
(1988, 4, 'Es Kristal Kiloan #987', 45153.00, 196),
(1989, 3, 'Es Balok Premium #988', 47437.00, 126),
(1990, 4, 'Dry Ice Super #989', 55075.00, 33),
(1991, 1, 'Es Kristal Ekonomis #990', 70828.00, 142),
(1992, 1, 'Dry Ice Ekonomis #991', 43309.00, 43),
(1993, 3, 'Ice Cube Kemasan #992', 31458.00, 31),
(1994, 2, 'Es Serut Kiloan #993', 97174.00, 19),
(1995, 5, 'Ice Cube Ekonomis #994', 53221.00, 101),
(1996, 3, 'Es Balok Premium #995', 62924.00, 104),
(1997, 2, 'Es Serut Super #996', 46805.00, 160),
(1998, 1, 'Es Balok Kiloan #997', 92725.00, 70),
(1999, 3, 'Es Kristal Ekonomis #998', 79201.00, 29),
(2000, 5, 'Es Serut Ekonomis #999', 41529.00, 50),
(2001, 4, 'Dry Ice Super #1000', 20058.00, 115),
(2002, 4, 'Produk Baru Sukses', 110000.00, 75);

--
-- Triggers `products`
--
DELIMITER $$
CREATE TRIGGER `trg_before_product_price_update` BEFORE UPDATE ON `products` FOR EACH ROW BEGIN
    -- Control Flow untuk memvalidasi perubahan harga
    -- Trigger hanya berjalan jika harga baru lebih rendah dari harga lama
    IF NEW.price < OLD.price THEN
        -- Memeriksa apakah harga baru kurang dari 50% harga lama
        IF NEW.price < (OLD.price * 0.5) THEN
            -- Jika ya, batalkan operasi UPDATE dan kirim pesan error
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: Harga tidak boleh diturunkan lebih dari 50% dalam satu kali update.';
        END IF;
    END IF;
END
$$
DELIMITER ;
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

--
-- Dumping data for table `supplier_profiles`
--

INSERT INTO `supplier_profiles` (`supplier_id`, `npwp`, `email`, `contact_person`) VALUES
(1, '31.7401.123456.1-123.456', 'kontak@pemasokjaya.com', 'Bapak Budi'),
(2, '31.7402.123456.2-123.457', 'cs@sumbermakmur.co.id', 'Ibu Siti'),
(3, '31.7403.123456.3-123.458', 'admin@mitrasejahtera.net', 'Ahmad');

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
(2, 'Total Produk', '1006', 'Jenis'),
(3, 'Pelanggan Tetap', '4', '+'),
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

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_kontak_pelanggan`
-- (See below for the actual view)
--
CREATE TABLE `view_kontak_pelanggan` (
`name` varchar(100)
,`phone` varchar(20)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_produk_mahal`
-- (See below for the actual view)
--
CREATE TABLE `view_produk_mahal` (
`id` int(11)
,`supplier_id` int(11)
,`name` varchar(100)
,`price` decimal(10,2)
,`stock` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_produk_mahal_stok_banyak`
-- (See below for the actual view)
--
CREATE TABLE `view_produk_mahal_stok_banyak` (
`id` int(11)
,`supplier_id` int(11)
,`name` varchar(100)
,`price` decimal(10,2)
,`stock` int(11)
);

-- --------------------------------------------------------

--
-- Structure for view `view_kontak_pelanggan`
--
DROP TABLE IF EXISTS `view_kontak_pelanggan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_kontak_pelanggan`  AS SELECT `customers`.`name` AS `name`, `customers`.`phone` AS `phone` FROM `customers` ;

-- --------------------------------------------------------

--
-- Structure for view `view_produk_mahal`
--
DROP TABLE IF EXISTS `view_produk_mahal`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_produk_mahal`  AS SELECT `products`.`id` AS `id`, `products`.`supplier_id` AS `supplier_id`, `products`.`name` AS `name`, `products`.`price` AS `price`, `products`.`stock` AS `stock` FROM `products` WHERE `products`.`price` > 100000 ;

-- --------------------------------------------------------

--
-- Structure for view `view_produk_mahal_stok_banyak`
--
DROP TABLE IF EXISTS `view_produk_mahal_stok_banyak`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_produk_mahal_stok_banyak`  AS SELECT `view_produk_mahal`.`id` AS `id`, `view_produk_mahal`.`supplier_id` AS `supplier_id`, `view_produk_mahal`.`name` AS `name`, `view_produk_mahal`.`price` AS `price`, `view_produk_mahal`.`stock` AS `stock` FROM `view_produk_mahal` WHERE `view_produk_mahal`.`stock` > 50WITH LOCALCHECK OPTION  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `phone` (`phone`),
  ADD KEY `idx_customer_name_phone` (`name`,`phone`);

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
-- Indexes for table `pengiriman`
--
ALTER TABLE `pengiriman`
  ADD PRIMARY KEY (`order_id`,`shipping_company`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_supplier_price` (`supplier_id`,`price`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2003;

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
-- Constraints for table `pengiriman`
--
ALTER TABLE `pengiriman`
  ADD CONSTRAINT `pengiriman_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

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
