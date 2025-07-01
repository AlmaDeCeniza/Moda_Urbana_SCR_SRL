-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 01-07-2025 a las 00:45:43
-- Versión del servidor: 8.4.3
-- Versión de PHP: 8.3.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `scz_srl_db`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteIngresosPorCanal` (IN `p_CanalVenta` VARCHAR(50), IN `p_FechaInicio` DATE, IN `p_FechaFin` DATE)   BEGIN
    SELECT 
        Canal_Venta,
        MONTH(Fecha) AS Mes,
        DAY(Fecha) AS Dia,
        YEAR(Fecha) AS Anio,
        SUM(dp.Cantidad * dp.PrecioUnitario) AS Total_Ingresos
    FROM pedido p
    INNER JOIN detalle_pedido dp ON p.PedidoID = dp.PedidoID
    WHERE 
        (p_CanalVenta IS NULL OR p.Canal_Venta = p_CanalVenta)
        AND (p_FechaInicio IS NULL OR p.Fecha >= p_FechaInicio)
        AND (p_FechaFin IS NULL OR p.Fecha <= p_FechaFin)
    GROUP BY Canal_Venta, YEAR(Fecha), MONTH(Fecha), DAY(Fecha)
    ORDER BY Anio DESC, Mes DESC, Dia DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteStockPorSucursal` (IN `p_SucursalID` INT)   BEGIN
    SELECT 
        pr.Nombre AS Producto,
        vp.Talla,
        vp.Color,
        SUM(i.Cantidad) AS Stock_Total,
        s.Nombre AS Sucursal
    FROM producto pr
    INNER JOIN variante_producto vp ON pr.ProductoID = vp.ProductoID
    INNER JOIN inventario i ON vp.VarianteID = i.VarianteID
    INNER JOIN sucursal s ON i.SucursalID = s.SucursalID
    WHERE 
        (p_SucursalID IS NULL OR i.SucursalID = p_SucursalID)
    GROUP BY pr.Nombre, vp.Talla, vp.Color, s.Nombre
    ORDER BY pr.Nombre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteVentasPorEstado` (IN `p_estado` VARCHAR(20))   BEGIN
    SELECT 
        p.PedidoID,
        CONCAT(c.Nombre) AS Cliente,
        p.Estado,
        p.Fecha,
        p.Metodo_Pago,
        p.Canal_Venta,
        SUM(dp.Cantidad * dp.PrecioUnitario) AS Total_Vendido
    FROM 
        pedido p
    INNER JOIN 
        cliente c ON p.ClienteID = c.ClienteID
    INNER JOIN 
        detalle_pedido dp ON p.PedidoID = dp.PedidoID
    WHERE 
        (p.Estado = p_estado OR p_estado IS NULL)
        AND p.Estado IN ('Pagado', 'En preparación', 'Enviado', 'Entregado', 'Devuelto') -- Filtro adicional
    GROUP BY 
        p.PedidoID, c.Nombre, p.Estado, p.Fecha, p.Metodo_Pago, p.Canal_Venta
    ORDER BY 
        p.Fecha DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteVentasPorSucursalOCanal` (IN `filtro_canal` VARCHAR(30))   BEGIN
    SELECT s.Nombre AS Sucursal,
           p.Canal_Venta AS Canal,
           SUM(dp.Cantidad * dp.PrecioUnitario) AS Total_Ventas
    FROM pedido p
    INNER JOIN sucursal s ON p.SucursalID = s.SucursalID
    INNER JOIN detalle_pedido dp ON p.PedidoID = dp.PedidoID
    WHERE filtro_canal IS NULL OR p.Canal_Venta = filtro_canal
    GROUP BY s.Nombre, p.Canal_Venta
    ORDER BY s.Nombre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteVentasPorVendedor` (IN `p_vendedor_id` INT)   BEGIN
    SELECT 
        v.Nombre AS Vendedor,
        DATE(p.Fecha) AS Fecha,
        SUM(dp.Cantidad * dp.PrecioUnitario) AS Total_Vendido
    FROM 
        pedido p
    INNER JOIN venta vt ON p.PedidoID = vt.PedidoID
    INNER JOIN vendedor v ON vt.VendedorID = v.VendedorID
    INNER JOIN detalle_pedido dp ON p.PedidoID = dp.PedidoID
    WHERE 
        (v.VendedorID = p_vendedor_id OR p_vendedor_id IS NULL)
    GROUP BY 
        v.Nombre, DATE(p.Fecha)
    ORDER BY 
        Fecha DESC, Vendedor;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

CREATE TABLE `categoria` (
  `CategoriaID` int NOT NULL,
  `Nombre` varchar(25) DEFAULT NULL,
  `Descripcion` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `categoria`
--

INSERT INTO `categoria` (`CategoriaID`, `Nombre`, `Descripcion`) VALUES
(1, 'Camisas', 'Camisas de vestir y casuales para hombre y mujer'),
(2, 'Pantalones', 'Jeans, chinos y pantalones de vestir'),
(3, 'Poleras', 'Poleras básicas, estampadas y deportivas'),
(4, 'Chaquetas', 'Chaquetas casuales y abrigos'),
(5, 'Blusas', 'Blusas femeninas de moda'),
(6, 'Shorts', 'Shorts de verano para hombre y mujer'),
(7, 'Vestidos', 'Vestidos formales y casuales'),
(8, 'Faldas', 'Faldas plisadas, lápiz y más'),
(9, 'Ropa deportiva', 'Conjuntos deportivos y sudaderas'),
(10, 'Abrigos', 'Abrigos largos y de lana'),
(11, 'Trajes', 'Sacos y pantalones formales'),
(12, 'Ropa interior', 'Boxers, calzones, sostenes'),
(13, 'Calcetines', 'Medias y calcetines variados'),
(14, 'Accesorios', 'Gorros, bufandas, cinturones'),
(15, 'Ropa de baño', 'Bikinis, trajes de baño enteros'),
(16, 'Zapatos', 'Calzado urbano y deportivo'),
(17, 'Sandalias', 'Calzado fresco para verano'),
(18, 'Botines', 'Calzado cerrado de moda'),
(19, 'Camperas', 'Camperas acolchadas y de cuero'),
(20, 'Overoles', 'Overoles casuales y urbanos'),
(21, 'Pijamas', 'Ropa para dormir cómoda'),
(22, 'Sweaters', 'Suéteres de hilo o algodón'),
(23, 'Chalecos', 'Sin mangas, tejidos o acolchados'),
(24, 'Ropa unisex', 'Estilo neutro para todos'),
(25, 'Ropa ecológica', 'Materiales sostenibles'),
(26, 'Tops', 'Crop tops, halter, y más'),
(27, 'Monos', 'Enterizos casuales y formales'),
(28, 'Joggers', 'Pantalones cómodos y modernos'),
(29, 'Pantalonetas', 'Pantalones cortos deportivos'),
(30, 'Ropa oversize', 'Estilo amplio y moderno');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `ClienteID` int NOT NULL,
  `Nombre` varchar(100) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Telefono` varchar(20) DEFAULT NULL,
  `Canal_Origen` varchar(40) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`ClienteID`, `Nombre`, `Email`, `Telefono`, `Canal_Origen`) VALUES
(1, 'María Fernanda López', 'mfernanda.lopez@gmail.com', '75000001', 'Facebook'),
(2, 'Carlos Eduardo Rojas', 'carlos.e.rojas@hotmail.com', '75000002', 'Instagram'),
(3, 'Lucía Vargas', 'lucia.vargas@yahoo.com', '75000003', 'Recomendación'),
(4, 'José Antonio Pérez', 'jose.perez@gmail.com', '75000004', 'Whatsapp'),
(5, 'Gabriela Mendoza', 'gabymendoza@hotmail.com', '75000005', 'Página Web'),
(6, 'Alejandro Gutiérrez', 'ale.gutierrez@gmail.com', '75000006', 'Facebook'),
(7, 'Tatiana Salinas', 'tatiana.salinas@yahoo.com', '75000007', 'Instagram'),
(8, 'Mauricio López', 'mauricio.lopez@gmail.com', '75000008', 'Whatsapp'),
(9, 'Paola Camacho', 'paola.camacho@hotmail.com', '75000009', 'Recomendación'),
(10, 'Javier Quispe', 'javier.quispe@gmail.com', '75000010', 'Facebook'),
(11, 'Brenda Chávez', 'brenda.chavez@hotmail.com', '75000011', 'Instagram'),
(12, 'Oscar Romero', 'oscar.romero@gmail.com', '75000012', 'Whatsapp'),
(13, 'Vanessa Aguilar', 'vanessa.aguilar@yahoo.com', '75000013', 'Recomendación'),
(14, 'Miguel Ángel Pérez', 'miguel.perez@gmail.com', '75000014', 'Facebook'),
(15, 'Diana Suárez', 'diana.suarez@hotmail.com', '75000015', 'Instagram'),
(16, 'Sergio Condori', 'sergio.condori@gmail.com', '75000016', 'Whatsapp'),
(17, 'Roxana Flores', 'roxana.flores@yahoo.com', '75000017', 'Recomendación'),
(18, 'Andrés Soria', 'andres.soria@gmail.com', '75000018', 'Facebook'),
(19, 'Lorena Mamani', 'lorena.mamani@hotmail.com', '75000019', 'Instagram'),
(20, 'Héctor Arce', 'hector.arce@gmail.com', '75000020', 'Página Web'),
(21, 'Cecilia Vaca', 'ceci.vaca@gmail.com', '75000021', 'Whatsapp'),
(22, 'Luis Fernando Peña', 'luis.pena@hotmail.com', '75000022', 'Facebook'),
(23, 'Marisol Escobar', 'marisol.escobar@gmail.com', '75000023', 'Instagram'),
(24, 'Henry Colque', 'henry.colque@yahoo.com', '75000024', 'Recomendación'),
(25, 'Denisse Torrico', 'denisse.torrico@gmail.com', '75000025', 'Facebook'),
(26, 'Kevin Ramírez', 'kevin.ramirez@hotmail.com', '75000026', 'Instagram'),
(27, 'Ana Beltrán', 'ana.beltran@gmail.com', '75000027', 'Whatsapp'),
(28, 'Rodrigo Vargas', 'rodrigo.vargas@yahoo.com', '75000028', 'Recomendación'),
(29, 'Stefany Calle', 'stefany.calle@gmail.com', '75000029', 'Facebook'),
(30, 'Nelson Tapia', 'nelson.tapia@hotmail.com', '75000030', 'Instagram');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `coleccion`
--

CREATE TABLE `coleccion` (
  `ColeccionID` int NOT NULL,
  `Nombre` varchar(100) DEFAULT NULL,
  `Temporada` varchar(50) DEFAULT NULL,
  `Fecha_Lanzamiento` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `coleccion`
--

INSERT INTO `coleccion` (`ColeccionID`, `Nombre`, `Temporada`, `Fecha_Lanzamiento`) VALUES
(1, 'Natural Vibes', 'Primavera 2025', '2025-09-01'),
(2, 'Urban Movement', 'Verano 2025', '2025-12-15'),
(3, 'Minimal Winter', 'Invierno 2025', '2025-06-01'),
(4, 'Colors of Autumn', 'Otoño 2025', '2025-03-10'),
(5, 'Fresh Start', 'Primavera 2024', '2024-09-10'),
(6, 'Chic Comfort', 'Invierno 2024', '2024-06-05'),
(7, 'Vintage Mood', 'Otoño 2024', '2024-04-15'),
(8, 'Elegance Light', 'Verano 2024', '2024-12-10'),
(9, 'Active Fit', 'Primavera 2023', '2023-10-01'),
(10, 'Cozy Days', 'Invierno 2023', '2023-07-01'),
(11, 'Pastel Flow', 'Primavera 2022', '2022-09-20'),
(12, 'Wild Nature', 'Otoño 2022', '2022-03-22'),
(13, 'City Life', 'Verano 2022', '2022-12-01'),
(14, 'Night Street', 'Invierno 2022', '2022-06-10'),
(15, 'Safari Style', 'Primavera 2021', '2021-10-15'),
(16, 'Casual Code', 'Otoño 2021', '2021-03-05'),
(17, 'Bold Basics', 'Verano 2021', '2021-11-10'),
(18, 'Nordic Touch', 'Invierno 2021', '2021-06-18'),
(19, 'Retro Cool', 'Primavera 2020', '2020-09-25'),
(20, 'Soft Elegance', 'Otoño 2020', '2020-03-12'),
(21, 'Light Layers', 'Verano 2020', '2020-12-20'),
(22, 'Artisan Vibes', 'Invierno 2020', '2020-06-02'),
(23, 'Island Dreams', 'Primavera 2019', '2019-09-08'),
(24, 'Classic Touch', 'Otoño 2019', '2019-03-18'),
(25, 'Flashback', 'Verano 2019', '2019-12-05'),
(26, 'Nordic Glow', 'Invierno 2019', '2019-06-11'),
(27, 'Floral Essence', 'Primavera 2018', '2018-09-17'),
(28, 'Denim Culture', 'Otoño 2018', '2018-03-09'),
(29, 'Soft Impact', 'Verano 2018', '2018-12-19'),
(30, 'Timeless Fit', 'Invierno 2018', '2018-06-20');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_pedido`
--

CREATE TABLE `detalle_pedido` (
  `DetalleID` int NOT NULL,
  `PedidoID` int DEFAULT NULL,
  `VarianteID` int DEFAULT NULL,
  `Cantidad` int DEFAULT NULL,
  `PrecioUnitario` decimal(10,2) DEFAULT NULL,
  `DescuentoAplicado` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `detalle_pedido`
--

INSERT INTO `detalle_pedido` (`DetalleID`, `PedidoID`, `VarianteID`, `Cantidad`, `PrecioUnitario`, `DescuentoAplicado`) VALUES
(1, 1, 1, 2, 120.00, 10.00),
(2, 2, 2, 1, 180.00, 0.00),
(3, 3, 3, 3, 95.00, 5.00),
(4, 4, 4, 1, 260.00, 0.00),
(5, 5, 5, 2, 130.00, 0.00),
(6, 6, 6, 1, 110.00, 0.00),
(7, 7, 7, 1, 230.00, 15.00),
(8, 8, 8, 2, 150.00, 0.00),
(9, 9, 9, 1, 280.00, 20.00),
(10, 10, 10, 1, 390.00, 30.00),
(11, 11, 11, 3, 350.00, 25.00),
(12, 12, 12, 1, 85.00, 0.00),
(13, 13, 13, 4, 40.00, 5.00),
(14, 14, 14, 2, 75.00, 0.00),
(15, 15, 15, 1, 140.00, 0.00),
(16, 16, 16, 1, 320.00, 10.00),
(17, 17, 17, 2, 130.00, 0.00),
(18, 18, 18, 1, 280.00, 15.00),
(19, 19, 19, 1, 250.00, 0.00),
(20, 20, 20, 3, 230.00, 20.00),
(21, 21, 21, 1, 150.00, 0.00),
(22, 22, 22, 2, 160.00, 0.00),
(23, 23, 23, 1, 145.00, 0.00),
(24, 24, 24, 2, 110.00, 5.00),
(25, 25, 25, 1, 190.00, 10.00),
(26, 26, 26, 3, 120.00, 0.00),
(27, 27, 27, 1, 200.00, 15.00),
(28, 28, 28, 1, 180.00, 0.00),
(29, 29, 29, 2, 130.00, 0.00),
(30, 30, 30, 1, 170.00, 0.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura`
--

CREATE TABLE `factura` (
  `FacturaID` int NOT NULL,
  `PedidoID` int DEFAULT NULL,
  `Numero_Factura` varchar(50) DEFAULT NULL,
  `Fecha_Emision` date DEFAULT NULL,
  `Monto_Total` decimal(10,2) DEFAULT NULL,
  `Estado` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `factura`
--

INSERT INTO `factura` (`FacturaID`, `PedidoID`, `Numero_Factura`, `Fecha_Emision`, `Monto_Total`, `Estado`) VALUES
(1, 1, 'F0001', '2025-06-10', 230.00, 'Pagada'),
(2, 2, 'F0002', '2025-06-11', 180.00, 'Pendiente'),
(3, 3, 'F0003', '2025-06-12', 280.00, 'Pagada'),
(4, 4, 'F0004', '2025-06-13', 260.00, 'Cancelada'),
(5, 5, 'F0005', '2025-06-14', 260.00, 'Pagada'),
(6, 6, 'F0006', '2025-06-15', 110.00, 'Pagada'),
(7, 7, 'F0007', '2025-06-16', 220.00, 'Pendiente'),
(8, 8, 'F0008', '2025-06-17', 300.00, 'Pagada'),
(9, 9, 'F0009', '2025-06-18', 260.00, 'Pagada'),
(10, 10, 'F0010', '2025-06-19', 390.00, 'Pagada'),
(11, 11, 'F0011', '2025-06-20', 1020.00, 'Pagada'),
(12, 12, 'F0012', '2025-06-21', 85.00, 'Pendiente'),
(13, 13, 'F0013', '2025-06-22', 160.00, 'Pagada'),
(14, 14, 'F0014', '2025-06-23', 150.00, 'Pagada'),
(15, 15, 'F0015', '2025-06-24', 140.00, 'Cancelada'),
(16, 16, 'F0016', '2025-06-25', 310.00, 'Pagada'),
(17, 17, 'F0017', '2025-06-26', 260.00, 'Pagada'),
(18, 18, 'F0018', '2025-06-27', 295.00, 'Pagada'),
(19, 19, 'F0019', '2025-06-28', 250.00, 'Pagada'),
(20, 20, 'F0020', '2025-06-29', 400.00, 'Pendiente'),
(21, 21, 'F0021', '2025-06-30', 172.00, 'Pagada'),
(22, 22, 'F0022', '2025-07-01', 320.00, 'Pagada'),
(23, 23, 'F0023', '2025-07-02', 145.00, 'Pagada'),
(24, 24, 'F0024', '2025-07-03', 225.00, 'Pagada'),
(25, 25, 'F0025', '2025-07-04', 280.00, 'Pagada'),
(26, 26, 'F0026', '2025-07-05', 125.00, 'Pagada'),
(27, 27, 'F0027', '2025-07-06', 240.00, 'Pagada'),
(28, 28, 'F0028', '2025-07-07', 180.00, 'Pagada'),
(29, 29, 'F0029', '2025-07-08', 260.00, 'Pendiente'),
(30, 30, 'F0030', '2025-07-09', 170.00, 'Pagada');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventario`
--

CREATE TABLE `inventario` (
  `VarianteID` int NOT NULL,
  `SucursalID` int NOT NULL,
  `Cantidad` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `inventario`
--

INSERT INTO `inventario` (`VarianteID`, `SucursalID`, `Cantidad`) VALUES
(1, 1, 10),
(1, 2, 5),
(1, 3, 8),
(2, 1, 12),
(2, 2, 7),
(2, 3, 9),
(3, 1, 6),
(3, 2, 4),
(3, 3, 5),
(4, 1, 15),
(5, 2, 11),
(6, 3, 13),
(7, 1, 10),
(8, 2, 14),
(9, 3, 9),
(10, 1, 8),
(11, 2, 10),
(12, 3, 7),
(13, 1, 18),
(14, 2, 9),
(15, 3, 6),
(16, 1, 10),
(17, 2, 12),
(18, 3, 11),
(19, 1, 0),
(20, 2, 8),
(21, 3, 9),
(22, 1, 6),
(23, 2, 7),
(24, 3, 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `marca`
--

CREATE TABLE `marca` (
  `MarcaID` int NOT NULL,
  `Nombre` varchar(100) DEFAULT NULL,
  `Origen` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `marca`
--

INSERT INTO `marca` (`MarcaID`, `Nombre`, `Origen`) VALUES
(1, 'Zara', 'España'),
(2, 'H&M', 'Suecia'),
(3, 'Levi’s', 'USA'),
(4, 'Pull&Bear', 'España'),
(5, 'Bershka', 'España'),
(6, 'Uniqlo', 'Japón'),
(7, 'Nike', 'USA'),
(8, 'Adidas', 'Alemania'),
(9, 'Under Armour', 'USA'),
(10, 'Tommy Hilfiger', 'USA'),
(11, 'Lacoste', 'Francia'),
(12, 'Calvin Klein', 'USA'),
(13, 'Guess', 'USA'),
(14, 'Puma', 'Alemania'),
(15, 'Reebok', 'USA'),
(16, 'Mango', 'España'),
(17, 'Forever 21', 'USA'),
(18, 'Stradivarius', 'España'),
(19, 'New Balance', 'USA'),
(20, 'Converse', 'USA'),
(21, 'Columbia', 'USA'),
(22, 'Patagonia', 'USA'),
(23, 'The North Face', 'USA'),
(24, 'Desigual', 'España'),
(25, 'Diesel', 'Italia'),
(26, 'Armani Exchange', 'Italia'),
(27, 'Pepe Jeans', 'UK'),
(28, 'Dockers', 'USA'),
(29, 'Superdry', 'UK'),
(30, 'Skechers', 'USA');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `meta_ventas`
--

CREATE TABLE `meta_ventas` (
  `MetaID` int NOT NULL,
  `VendedorID` int DEFAULT NULL,
  `Mes` tinyint DEFAULT NULL,
  `Año` smallint DEFAULT NULL,
  `MontoMinimo` decimal(10,2) DEFAULT NULL,
  `Porcentaje_Comision_Extra` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `meta_ventas`
--

INSERT INTO `meta_ventas` (`MetaID`, `VendedorID`, `Mes`, `Año`, `MontoMinimo`, `Porcentaje_Comision_Extra`) VALUES
(1, 1, 6, 2025, 3000.00, 1.50),
(2, 2, 6, 2025, 3200.00, 1.75),
(3, 3, 6, 2025, 2800.00, 1.50),
(4, 4, 7, 2025, 3500.00, 2.00),
(5, 5, 7, 2025, 3100.00, 1.80),
(6, 6, 7, 2025, 2900.00, 1.50),
(7, 7, 8, 2025, 3300.00, 1.60),
(8, 8, 8, 2025, 3000.00, 1.75),
(9, 9, 8, 2025, 3100.00, 1.50),
(10, 10, 9, 2025, 3400.00, 1.90),
(11, 11, 9, 2025, 3200.00, 1.70),
(12, 12, 9, 2025, 2800.00, 1.50),
(13, 13, 10, 2025, 3600.00, 2.00),
(14, 14, 10, 2025, 3300.00, 1.80),
(15, 15, 10, 2025, 3100.00, 1.60),
(16, 16, 11, 2025, 3500.00, 1.75),
(17, 17, 11, 2025, 3000.00, 1.50),
(18, 18, 11, 2025, 3200.00, 1.60),
(19, 19, 12, 2025, 3400.00, 1.80),
(20, 20, 12, 2025, 3100.00, 1.50),
(21, 21, 1, 2026, 3300.00, 1.75),
(22, 22, 1, 2026, 3200.00, 1.50),
(23, 23, 1, 2026, 3000.00, 1.60),
(24, 24, 2, 2026, 3500.00, 1.80),
(25, 25, 2, 2026, 3100.00, 1.50),
(26, 26, 2, 2026, 3200.00, 1.60),
(27, 27, 3, 2026, 3400.00, 1.75),
(28, 28, 3, 2026, 3000.00, 1.50),
(29, 29, 3, 2026, 3100.00, 1.60),
(30, 30, 4, 2026, 3300.00, 1.80);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedido`
--

CREATE TABLE `pedido` (
  `PedidoID` int NOT NULL,
  `ClienteID` int DEFAULT NULL,
  `VendedorID` int DEFAULT NULL,
  `SucursalID` int DEFAULT NULL,
  `Fecha` datetime DEFAULT NULL,
  `Estado` varchar(30) DEFAULT NULL,
  `Canal_Venta` varchar(30) DEFAULT NULL,
  `Metodo_Pago` varchar(30) DEFAULT NULL,
  `Fecha_Confirmacion_Pago` datetime DEFAULT NULL,
  `Tipo_Entrega` varchar(30) DEFAULT NULL,
  `Direccion_Envio` text,
  `Costo_Envio` decimal(10,2) DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `pedido`
--

INSERT INTO `pedido` (`PedidoID`, `ClienteID`, `VendedorID`, `SucursalID`, `Fecha`, `Estado`, `Canal_Venta`, `Metodo_Pago`, `Fecha_Confirmacion_Pago`, `Tipo_Entrega`, `Direccion_Envio`, `Costo_Envio`) VALUES
(1, 1, 1, 1, '2025-06-10 10:30:00', 'Pagado', 'Online', 'Tarjeta', '2025-06-10 11:00:00', 'Domicilio', 'Av. Cañoto #145', 20.00),
(2, 2, 2, 1, '2025-06-11 12:15:00', 'En preparacion', 'Tienda', 'Efectivo', NULL, 'Retiro en tienda', NULL, 0.00),
(3, 3, 3, 1, '2025-08-12 14:45:00', 'Enviado', 'Online', 'Tarjeta', '2025-06-12 15:00:00', 'Domicilio', 'Calle Los Claveles #87', 15.00),
(4, 4, 4, 2, '2025-06-13 09:30:00', 'Pagado', 'Online', 'Tarjeta', NULL, 'Domicilio', 'Mall Ventura, Local 23', 25.00),
(5, 5, 5, 2, '2025-06-14 17:20:00', 'Pagado', 'Tienda', 'Efectivo', '2025-06-14 17:30:00', 'Retiro en tienda', NULL, 0.00),
(6, 6, 6, 2, '2025-06-15 13:00:00', 'Entregado', 'Online', 'Tarjeta', '2025-06-15 13:30:00', 'Domicilio', 'Av. Cañoto #200', 18.00),
(7, 7, 7, 3, '2025-06-16 10:10:00', 'Devuelto', 'Tienda', 'Efectivo', NULL, 'Retiro en tienda', NULL, 0.00),
(8, 8, 8, 3, '2025-06-17 11:45:00', 'Pagado', 'Online', 'Tarjeta', '2025-06-17 12:00:00', 'Domicilio', 'Calle Los Claveles #90', 22.00),
(9, 9, 9, 3, '2025-06-18 16:00:00', 'Entregado', 'Online', 'Tarjeta', '2025-06-18 16:30:00', 'Domicilio', 'Mall Ventura, Local 5', 25.00),
(10, 10, 10, 1, '2025-06-19 15:00:00', 'Devuelto', 'Tienda', 'Efectivo', '2025-06-19 15:15:00', '', NULL, 0.00),
(11, 11, 11, 1, '2025-06-20 09:30:00', 'Enviado', 'Online', 'Tarjeta', '2025-06-20 10:00:00', 'Domicilio', 'Av. Cañoto #150', 18.00),
(12, 12, 12, 1, '2025-06-21 13:15:00', 'Pendiente', 'Tienda', 'Efectivo', NULL, 'Retiro en tienda', NULL, 0.00),
(13, 13, 13, 2, '2025-06-22 14:50:00', 'En preparacion', 'Online', 'Tarjeta', '2025-06-22 15:10:00', 'Domicilio', 'Calle Los Claveles #120', 20.00),
(14, 14, 14, 2, '2025-06-23 10:05:00', 'En preparacion', 'Tienda', 'Efectivo', '2025-06-23 10:30:00', 'Retiro en tienda', NULL, 0.00),
(15, 15, 15, 2, '2025-06-24 11:25:00', 'En preparacion', 'Online', 'Tarjeta', NULL, 'Domicilio', 'Mall Ventura, Local 18', 30.00),
(16, 16, 16, 3, '2025-06-25 12:40:00', 'Devuelto', 'Online', 'Tarjeta', '2025-06-25 13:00:00', 'Domicilio', 'Av. Cañoto #170', 18.00),
(17, 17, 17, 3, '2025-06-26 15:35:00', 'Devuelto', 'Tienda', 'Efectivo', '2025-06-26 15:50:00', 'Retiro en tienda', NULL, 0.00),
(18, 18, 18, 3, '2025-06-27 16:45:00', 'Devuelto', 'Online', 'Tarjeta', '2025-06-27 17:10:00', 'Domicilio', 'Calle Los Claveles #140', 20.00),
(19, 19, 19, 1, '2025-06-28 14:15:00', 'Devuelto', 'Tienda', 'Efectivo', '2025-06-28 14:30:00', 'Retiro en tienda', NULL, 0.00),
(20, 20, 20, 1, '2025-06-29 13:10:00', 'Pendiente', 'Online', 'Tarjeta', NULL, 'Domicilio', 'Mall Ventura, Local 21', 25.00),
(21, 21, 21, 1, '2025-06-30 10:20:00', 'Entregado', 'Online', 'Tarjeta', '2025-06-30 10:45:00', 'Domicilio', 'Av. Cañoto #180', 22.00),
(22, 22, 22, 2, '2025-07-01 11:35:00', 'Entregado', 'Redes Sociales', 'Efectivo', '2025-07-01 11:50:00', 'Retiro en tienda', NULL, 0.00),
(23, 23, 23, 2, '2025-08-02 12:50:00', 'Entregado', 'Redes Sociales', 'Tarjeta', '2025-07-02 13:15:00', 'Domicilio', 'Calle Los Claveles #110', 20.00),
(24, 24, 24, 2, '2025-07-03 14:05:00', 'Entregado', 'Redes Sociales', 'Efectivo', '2025-07-03 14:20:00', 'Retiro en tienda', NULL, 0.00),
(25, 25, 25, 3, '2025-05-04 15:15:00', 'Entregado', 'Redes Sociales', 'Tarjeta', '2025-07-04 15:40:00', 'Domicilio', 'Mall Ventura, Local 7', 23.00),
(26, 26, 26, 3, '2025-07-05 16:25:00', 'Entregado', 'Redes Sociales', 'Efectivo', '2025-07-05 16:45:00', 'Retiro en tienda', NULL, 0.00),
(27, 27, 27, 3, '2025-07-06 17:35:00', 'Entregado', 'Redes Sociales', 'Tarjeta', '2025-07-06 18:00:00', 'Domicilio', 'Av. Cañoto #195', 20.00),
(28, 28, 28, 1, '2025-07-07 18:45:00', 'Entregado', 'Redes Sociales', 'Efectivo', '2025-07-07 19:00:00', 'Retiro en tienda', NULL, 0.00),
(29, 29, 29, 1, '2025-07-08 19:55:00', 'Pendiente', 'Redes Sociales', 'Tarjeta', NULL, 'Domicilio', 'Calle Los Claveles #125', 25.00),
(30, 30, 30, 1, '2025-07-09 20:05:00', 'Entregado', 'Redes Sociales', 'Efectivo', '2025-07-09 20:30:00', 'Retiro en tienda', NULL, 0.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `ProductoID` int NOT NULL,
  `Codigo` varchar(50) DEFAULT NULL,
  `Nombre` varchar(100) DEFAULT NULL,
  `Tipo_Prenda` varchar(35) DEFAULT NULL,
  `Precio` decimal(10,2) DEFAULT NULL,
  `CategoriaID` int DEFAULT NULL,
  `MarcaID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`ProductoID`, `Codigo`, `Nombre`, `Tipo_Prenda`, `Precio`, `CategoriaID`, `MarcaID`) VALUES
(1, 'PRD001', 'Camisa casual blanca hombre', 'Camisa', 120.00, 1, 1),
(2, 'PRD002', 'Jean clásico azul', 'Pantalón', 180.00, 2, 3),
(3, 'PRD003', 'Polera deportiva dry-fit', 'Polera', 95.00, 3, 7),
(4, 'PRD004', 'Chaqueta acolchada mujer', 'Chaqueta', 260.00, 4, 5),
(5, 'PRD005', 'Blusa manga larga elegante', 'Blusa', 130.00, 5, 6),
(6, 'PRD006', 'Short denim veraniego', 'Short', 110.00, 6, 2),
(7, 'PRD007', 'Vestido floral largo', 'Vestido', 220.00, 7, 16),
(8, 'PRD008', 'Falda negra plisada', 'Falda', 150.00, 8, 17),
(9, 'PRD009', 'Conjunto deportivo mujer', 'Ropa deportiva', 280.00, 9, 8),
(10, 'PRD010', 'Abrigo largo de lana', 'Abrigo', 390.00, 10, 11),
(11, 'PRD011', 'Saco formal slim fit', 'Traje', 350.00, 11, 10),
(12, 'PRD012', 'Boxers algodón x3', 'Ropa interior', 85.00, 12, 12),
(13, 'PRD013', 'Pack de medias deportivas', 'Calcetines', 40.00, 13, 9),
(14, 'PRD014', 'Cinturón cuero marrón', 'Accesorios', 75.00, 14, 13),
(15, 'PRD015', 'Bikini estampado', 'Ropa de baño', 140.00, 15, 15),
(16, 'PRD016', 'Zapatillas urbanas hombre', 'Zapatos', 320.00, 16, 6),
(17, 'PRD017', 'Sandalias planas mujer', 'Sandalias', 130.00, 17, 18),
(18, 'PRD018', 'Botines cuero negro', 'Botines', 280.00, 18, 30),
(19, 'PRD019', 'Campera jean clásica', 'Camperas', 250.00, 19, 3),
(20, 'PRD020', 'Overol denim mujer', 'Overoles', 230.00, 20, 19),
(21, 'PRD021', 'Pijama algodón rayado', 'Pijamas', 150.00, 21, 4),
(22, 'PRD022', 'Sweater cuello V', 'Sweaters', 160.00, 22, 20),
(23, 'PRD023', 'Chaleco sin mangas', 'Chalecos', 145.00, 23, 28),
(24, 'PRD024', 'Polera unisex oversize', 'Ropa unisex', 110.00, 24, 14),
(25, 'PRD025', 'Camisa ecológica orgánica', 'Ropa ecológica', 190.00, 25, 25),
(26, 'PRD026', 'Top halter estampado', 'Tops', 120.00, 26, 27),
(27, 'PRD027', 'Mono casual corto', 'Monos', 200.00, 27, 26),
(28, 'PRD028', 'Jogger deportivo hombre', 'Joggers', 180.00, 28, 29),
(29, 'PRD029', 'Pantaloneta running', 'Pantalonetas', 130.00, 29, 21),
(30, 'PRD030', 'Camisa oversize urbana', 'Ropa oversize', 170.00, 30, 22);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_coleccion`
--

CREATE TABLE `producto_coleccion` (
  `ProductoID` int NOT NULL,
  `ColeccionID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `producto_coleccion`
--

INSERT INTO `producto_coleccion` (`ProductoID`, `ColeccionID`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20),
(21, 21),
(22, 22),
(23, 23),
(24, 24),
(25, 25),
(26, 26),
(27, 27),
(28, 28),
(29, 29),
(30, 30);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `promocion`
--

CREATE TABLE `promocion` (
  `PromocionID` int NOT NULL,
  `Nombre` varchar(100) DEFAULT NULL,
  `Tipo` varchar(40) DEFAULT NULL,
  `Descuento` decimal(5,2) DEFAULT NULL,
  `Fecha_Inicio` date DEFAULT NULL,
  `Fecha_Fin` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `promocion`
--

INSERT INTO `promocion` (`PromocionID`, `Nombre`, `Tipo`, `Descuento`, `Fecha_Inicio`, `Fecha_Fin`) VALUES
(1, 'Descuento Primavera', 'Estacional', 10.00, '2025-09-01', '2025-09-30'),
(2, 'Oferta Flash', 'Limitada', 15.00, '2025-07-01', '2025-07-03'),
(3, 'Black Friday', 'Evento', 25.00, '2025-11-25', '2025-11-27'),
(4, 'Navidad Urbana', 'Temporada', 20.00, '2025-12-20', '2025-12-31'),
(5, 'Cyber Week', 'Digital', 18.00, '2025-11-01', '2025-11-07'),
(6, 'Liquidación Invierno', 'Remate', 30.00, '2025-06-01', '2025-06-15'),
(7, 'Día del Padre', 'Festividad', 10.00, '2025-03-18', '2025-03-19'),
(8, 'Semana de la Juventud', 'Evento', 12.00, '2025-08-10', '2025-08-17'),
(9, 'Lanzamiento Nueva Línea', 'Colección', 8.00, '2025-10-01', '2025-10-15'),
(10, 'Aniversario SCZ SRL', 'Interna', 20.00, '2025-05-01', '2025-05-10'),
(11, '2x1 Primavera', 'Promoción combinada', 50.00, '2025-09-01', '2025-09-15'),
(12, 'Rebajas Mid Season', 'Temporada', 15.00, '2025-04-01', '2025-04-10'),
(13, 'Día de la Mujer', 'Festividad', 12.00, '2025-03-08', '2025-03-08'),
(14, 'Día del Niño', 'Festividad', 10.00, '2025-04-12', '2025-04-12'),
(15, 'Rebajas Otoño', 'Temporada', 18.00, '2025-03-01', '2025-03-15'),
(16, 'Día del Cliente', 'Especial', 20.00, '2025-10-05', '2025-10-05'),
(17, 'Feria Especial', 'Externa', 22.00, '2025-08-01', '2025-08-05'),
(18, 'Back to School', 'Campaña', 15.00, '2025-01-10', '2025-01-31'),
(19, 'Summer Sale', 'Temporada', 17.00, '2025-12-01', '2025-12-10'),
(20, 'Rebajas Fin de Año', 'Evento', 25.00, '2025-12-26', '2025-12-31'),
(21, 'Promo Halloween', 'Evento', 13.00, '2025-10-30', '2025-10-31'),
(22, 'Rebajas Verano', 'Temporada', 20.00, '2025-12-01', '2025-12-20'),
(23, 'Ofertas Deportivas', 'Segmentada', 15.00, '2025-08-01', '2025-08-15'),
(24, 'Flash Weekend', 'Relámpago', 18.00, '2025-07-12', '2025-07-14'),
(25, 'Compra y Gana', 'Especial', 20.00, '2025-11-05', '2025-11-15'),
(26, 'Semana Eco', 'Sostenible', 10.00, '2025-04-20', '2025-04-25'),
(27, 'Ofertas de Medio Año', 'Temporada', 17.00, '2025-06-15', '2025-06-30'),
(28, 'Colección Flash Sale', 'Colección', 12.00, '2025-10-01', '2025-10-07'),
(29, 'Ropa Casual en Oferta', 'Segmentada', 15.00, '2025-08-10', '2025-08-20'),
(30, 'Precios Locos', 'Interna', 30.00, '2025-07-20', '2025-07-25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `promocion_producto`
--

CREATE TABLE `promocion_producto` (
  `PromocionID` int NOT NULL,
  `ProductoID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `promocion_producto`
--

INSERT INTO `promocion_producto` (`PromocionID`, `ProductoID`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20),
(21, 21),
(22, 22),
(23, 23),
(24, 24),
(25, 25),
(26, 26),
(27, 27),
(28, 28),
(29, 29),
(30, 30);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sucursal`
--

CREATE TABLE `sucursal` (
  `SucursalID` int NOT NULL,
  `Nombre` varchar(100) DEFAULT NULL,
  `Direccion` text,
  `Telefono` varchar(20) DEFAULT NULL,
  `Encargado` varchar(100) DEFAULT NULL,
  `Estado` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `sucursal`
--

INSERT INTO `sucursal` (`SucursalID`, `Nombre`, `Direccion`, `Telefono`, `Encargado`, `Estado`) VALUES
(1, 'Sucursal Central', 'Av. Cañoto #145, Santa Cruz', '700123456', 'Lucía Romero', 'Activa'),
(2, 'Sucursal Equipetrol', 'Calle Los Claveles #87, Equipetrol', '700654321', 'Carlos Méndez', 'Activa'),
(3, 'Sucursal Ventura', 'Mall Ventura, Local 23', '700789012', 'María Fernanda Paz', 'Activa');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `variante_producto`
--

CREATE TABLE `variante_producto` (
  `VarianteID` int NOT NULL,
  `ProductoID` int DEFAULT NULL,
  `Talla` varchar(20) DEFAULT NULL,
  `Color` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `variante_producto`
--

INSERT INTO `variante_producto` (`VarianteID`, `ProductoID`, `Talla`, `Color`) VALUES
(1, 1, 'M', 'Blanco'),
(2, 2, '32', 'Azul Oscuro'),
(3, 3, 'L', 'Negro'),
(4, 4, 'S', 'Rojo'),
(5, 5, 'M', 'Beige'),
(6, 6, 'M', 'Celeste'),
(7, 7, 'L', 'Floral'),
(8, 8, 'S', 'Negro'),
(9, 9, 'M', 'Gris'),
(10, 10, 'L', 'Camel'),
(11, 11, 'M', 'Azul Marino'),
(12, 12, 'L', 'Multicolor'),
(13, 13, 'U', 'Blanco/Negro'),
(14, 14, 'M', 'Marrón'),
(15, 15, 'S', 'Turquesa'),
(16, 16, '42', 'Gris Oscuro'),
(17, 17, '38', 'Beige'),
(18, 18, '40', 'Negro'),
(19, 19, 'M', 'Azul'),
(20, 20, 'S', 'Denim'),
(21, 21, 'L', 'Rayado'),
(22, 22, 'M', 'Verde Oliva'),
(23, 23, 'U', 'Negro'),
(24, 24, 'XL', 'Blanco'),
(25, 25, 'L', 'Verde Bosque'),
(26, 26, 'M', 'Rosa'),
(27, 27, 'S', 'Gris Claro'),
(28, 28, 'L', 'Negro'),
(29, 29, 'M', 'Azul Eléctrico'),
(30, 30, 'XL', 'Mostaza');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vendedor`
--

CREATE TABLE `vendedor` (
  `VendedorID` int NOT NULL,
  `Nombre` varchar(100) DEFAULT NULL,
  `PorcentajeComision` decimal(5,2) DEFAULT NULL,
  `SucursalID` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `vendedor`
--

INSERT INTO `vendedor` (`VendedorID`, `Nombre`, `PorcentajeComision`, `SucursalID`) VALUES
(1, 'Ana Méndez', 5.00, 1),
(2, 'Luis Pérez', 6.00, 1),
(3, 'Claudia Rojas', 5.50, 1),
(4, 'Carlos Sánchez', 7.00, 2),
(5, 'María Gómez', 6.50, 2),
(6, 'Jorge Rivera', 5.00, 2),
(7, 'Sofía Castillo', 5.75, 3),
(8, 'Fernando Molina', 6.25, 3),
(9, 'Verónica Flores', 5.00, 3),
(10, 'Raúl Medina', 7.00, 1),
(11, 'Lorena Torres', 6.50, 1),
(12, 'Héctor Bravo', 5.25, 1),
(13, 'Diana Vargas', 6.00, 2),
(14, 'Ricardo Fuentes', 5.75, 2),
(15, 'Patricia León', 6.00, 2),
(16, 'Eduardo Salinas', 5.00, 3),
(17, 'Sandra Peña', 6.00, 3),
(18, 'Javier Ortiz', 5.50, 3),
(19, 'Lucía Muñoz', 6.25, 1),
(20, 'Pedro Castillo', 7.00, 1),
(21, 'Karen Reyes', 5.75, 1),
(22, 'Mario López', 6.50, 2),
(23, 'Carla Mendoza', 5.00, 2),
(24, 'Alberto Jiménez', 6.00, 2),
(25, 'Natalia Vargas', 5.25, 3),
(26, 'Andrés Morales', 6.00, 3),
(27, 'Jessica Silva', 5.50, 3),
(28, 'Gustavo Herrera', 6.75, 1),
(29, 'Valeria Gómez', 5.00, 1),
(30, 'Hugo Castillo', 6.00, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta`
--

CREATE TABLE `venta` (
  `VentaID` int NOT NULL,
  `PedidoID` int DEFAULT NULL,
  `VendedorID` int DEFAULT NULL,
  `Fecha` datetime DEFAULT NULL,
  `ComisionCalculada` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Volcado de datos para la tabla `venta`
--

INSERT INTO `venta` (`VentaID`, `PedidoID`, `VendedorID`, `Fecha`, `ComisionCalculada`) VALUES
(1, 1, 1, '2025-06-10 11:00:00', 11.50),
(2, 2, 1, '2025-06-11 12:30:00', 10.80),
(3, 3, 3, '2025-06-12 15:00:00', 13.30),
(4, 5, 3, '2025-06-14 17:35:00', 15.60),
(5, 6, 6, '2025-06-15 13:45:00', 5.50),
(6, 8, 1, '2025-06-17 12:15:00', 9.40),
(7, 9, 9, '2025-06-18 16:45:00', 18.20),
(8, 10, 10, '2025-06-19 15:20:00', 27.30),
(9, 11, 11, '2025-06-20 10:15:00', 53.10),
(10, 13, 13, '2025-06-22 15:20:00', 19.20),
(11, 14, 14, '2025-06-23 10:45:00', 9.75),
(12, 16, 16, '2025-06-25 13:05:00', 16.00),
(13, 17, 17, '2025-06-26 16:00:00', 11.70),
(14, 18, 18, '2025-06-27 17:15:00', 14.75),
(15, 19, 19, '2025-06-28 14:45:00', 12.50),
(16, 21, 21, '2025-06-30 11:00:00', 7.50),
(17, 22, 22, '2025-07-01 12:00:00', 9.60),
(18, 23, 23, '2025-07-02 13:30:00', 11.60),
(19, 24, 24, '2025-07-03 14:30:00', 6.60),
(20, 25, 25, '2025-07-04 16:00:00', 12.70),
(21, 26, 26, '2025-07-05 17:00:00', 7.50),
(22, 27, 27, '2025-07-06 18:00:00', 10.80),
(23, 28, 28, '2025-07-07 19:15:00', 9.00),
(24, 30, 30, '2025-07-09 20:40:00', 8.50),
(25, 4, 4, '2025-06-13 10:00:00', 0.00),
(26, 7, 7, '2025-06-16 10:30:00', 0.00),
(27, 12, 12, '2025-06-21 13:30:00', 0.00),
(28, 15, 15, '2025-06-24 11:45:00', 0.00),
(29, 20, 20, '2025-06-29 13:30:00', 0.00),
(30, 29, 29, '2025-07-08 20:15:00', 0.00);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`CategoriaID`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`ClienteID`);

--
-- Indices de la tabla `coleccion`
--
ALTER TABLE `coleccion`
  ADD PRIMARY KEY (`ColeccionID`);

--
-- Indices de la tabla `detalle_pedido`
--
ALTER TABLE `detalle_pedido`
  ADD PRIMARY KEY (`DetalleID`),
  ADD KEY `PedidoID` (`PedidoID`),
  ADD KEY `VarianteID` (`VarianteID`);

--
-- Indices de la tabla `factura`
--
ALTER TABLE `factura`
  ADD PRIMARY KEY (`FacturaID`),
  ADD KEY `PedidoID` (`PedidoID`);

--
-- Indices de la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD PRIMARY KEY (`VarianteID`,`SucursalID`),
  ADD KEY `SucursalID` (`SucursalID`);

--
-- Indices de la tabla `marca`
--
ALTER TABLE `marca`
  ADD PRIMARY KEY (`MarcaID`);

--
-- Indices de la tabla `meta_ventas`
--
ALTER TABLE `meta_ventas`
  ADD PRIMARY KEY (`MetaID`),
  ADD KEY `VendedorID` (`VendedorID`);

--
-- Indices de la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD PRIMARY KEY (`PedidoID`),
  ADD KEY `ClienteID` (`ClienteID`),
  ADD KEY `VendedorID` (`VendedorID`),
  ADD KEY `SucursalID` (`SucursalID`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`ProductoID`),
  ADD UNIQUE KEY `Codigo` (`Codigo`),
  ADD KEY `CategoriaID` (`CategoriaID`),
  ADD KEY `MarcaID` (`MarcaID`);

--
-- Indices de la tabla `producto_coleccion`
--
ALTER TABLE `producto_coleccion`
  ADD PRIMARY KEY (`ProductoID`,`ColeccionID`),
  ADD KEY `ColeccionID` (`ColeccionID`);

--
-- Indices de la tabla `promocion`
--
ALTER TABLE `promocion`
  ADD PRIMARY KEY (`PromocionID`);

--
-- Indices de la tabla `promocion_producto`
--
ALTER TABLE `promocion_producto`
  ADD PRIMARY KEY (`PromocionID`,`ProductoID`),
  ADD KEY `ProductoID` (`ProductoID`);

--
-- Indices de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  ADD PRIMARY KEY (`SucursalID`);

--
-- Indices de la tabla `variante_producto`
--
ALTER TABLE `variante_producto`
  ADD PRIMARY KEY (`VarianteID`),
  ADD KEY `ProductoID` (`ProductoID`);

--
-- Indices de la tabla `vendedor`
--
ALTER TABLE `vendedor`
  ADD PRIMARY KEY (`VendedorID`),
  ADD KEY `SucursalID` (`SucursalID`);

--
-- Indices de la tabla `venta`
--
ALTER TABLE `venta`
  ADD PRIMARY KEY (`VentaID`),
  ADD KEY `PedidoID` (`PedidoID`),
  ADD KEY `VendedorID` (`VendedorID`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categoria`
--
ALTER TABLE `categoria`
  MODIFY `CategoriaID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `ClienteID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `coleccion`
--
ALTER TABLE `coleccion`
  MODIFY `ColeccionID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `detalle_pedido`
--
ALTER TABLE `detalle_pedido`
  MODIFY `DetalleID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `factura`
--
ALTER TABLE `factura`
  MODIFY `FacturaID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `marca`
--
ALTER TABLE `marca`
  MODIFY `MarcaID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `meta_ventas`
--
ALTER TABLE `meta_ventas`
  MODIFY `MetaID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `pedido`
--
ALTER TABLE `pedido`
  MODIFY `PedidoID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `ProductoID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `promocion`
--
ALTER TABLE `promocion`
  MODIFY `PromocionID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  MODIFY `SucursalID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `variante_producto`
--
ALTER TABLE `variante_producto`
  MODIFY `VarianteID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `vendedor`
--
ALTER TABLE `vendedor`
  MODIFY `VendedorID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `venta`
--
ALTER TABLE `venta`
  MODIFY `VentaID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `detalle_pedido`
--
ALTER TABLE `detalle_pedido`
  ADD CONSTRAINT `detalle_pedido_ibfk_1` FOREIGN KEY (`PedidoID`) REFERENCES `pedido` (`PedidoID`),
  ADD CONSTRAINT `detalle_pedido_ibfk_2` FOREIGN KEY (`VarianteID`) REFERENCES `variante_producto` (`VarianteID`);

--
-- Filtros para la tabla `factura`
--
ALTER TABLE `factura`
  ADD CONSTRAINT `factura_ibfk_1` FOREIGN KEY (`PedidoID`) REFERENCES `pedido` (`PedidoID`);

--
-- Filtros para la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD CONSTRAINT `inventario_ibfk_1` FOREIGN KEY (`VarianteID`) REFERENCES `variante_producto` (`VarianteID`),
  ADD CONSTRAINT `inventario_ibfk_2` FOREIGN KEY (`SucursalID`) REFERENCES `sucursal` (`SucursalID`);

--
-- Filtros para la tabla `meta_ventas`
--
ALTER TABLE `meta_ventas`
  ADD CONSTRAINT `meta_ventas_ibfk_1` FOREIGN KEY (`VendedorID`) REFERENCES `vendedor` (`VendedorID`);

--
-- Filtros para la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD CONSTRAINT `pedido_ibfk_1` FOREIGN KEY (`ClienteID`) REFERENCES `cliente` (`ClienteID`),
  ADD CONSTRAINT `pedido_ibfk_2` FOREIGN KEY (`VendedorID`) REFERENCES `vendedor` (`VendedorID`),
  ADD CONSTRAINT `pedido_ibfk_3` FOREIGN KEY (`SucursalID`) REFERENCES `sucursal` (`SucursalID`);

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`CategoriaID`) REFERENCES `categoria` (`CategoriaID`),
  ADD CONSTRAINT `producto_ibfk_2` FOREIGN KEY (`MarcaID`) REFERENCES `marca` (`MarcaID`);

--
-- Filtros para la tabla `producto_coleccion`
--
ALTER TABLE `producto_coleccion`
  ADD CONSTRAINT `producto_coleccion_ibfk_1` FOREIGN KEY (`ProductoID`) REFERENCES `producto` (`ProductoID`),
  ADD CONSTRAINT `producto_coleccion_ibfk_2` FOREIGN KEY (`ColeccionID`) REFERENCES `coleccion` (`ColeccionID`);

--
-- Filtros para la tabla `promocion_producto`
--
ALTER TABLE `promocion_producto`
  ADD CONSTRAINT `promocion_producto_ibfk_1` FOREIGN KEY (`PromocionID`) REFERENCES `promocion` (`PromocionID`),
  ADD CONSTRAINT `promocion_producto_ibfk_2` FOREIGN KEY (`ProductoID`) REFERENCES `producto` (`ProductoID`);

--
-- Filtros para la tabla `variante_producto`
--
ALTER TABLE `variante_producto`
  ADD CONSTRAINT `variante_producto_ibfk_1` FOREIGN KEY (`ProductoID`) REFERENCES `producto` (`ProductoID`);

--
-- Filtros para la tabla `vendedor`
--
ALTER TABLE `vendedor`
  ADD CONSTRAINT `vendedor_ibfk_1` FOREIGN KEY (`SucursalID`) REFERENCES `sucursal` (`SucursalID`);

--
-- Filtros para la tabla `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `venta_ibfk_1` FOREIGN KEY (`PedidoID`) REFERENCES `pedido` (`PedidoID`),
  ADD CONSTRAINT `venta_ibfk_2` FOREIGN KEY (`VendedorID`) REFERENCES `vendedor` (`VendedorID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
