-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 13-03-2024 a las 22:45:23
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `camilas`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_usuario` (IN `_id` INT, IN `_nombre` VARCHAR(250), IN `_documento_identidad` VARCHAR(50), IN `_numero_documento` VARCHAR(50), IN `_direccion` VARCHAR(250), IN `_telefono` INT, IN `_cargo` VARCHAR(50), IN `_correo` VARCHAR(250), IN `_contrasenia` VARCHAR(250))   BEGIN
	DECLARE usuario_exist INT;
    SELECT COUNT(*) INTO usuario_exist FROM usuario WHERE id = _id;
	IF(_id is NOT NULL AND usuario_exist > 0)THEN
    	IF(_nombre is NOT NULL) THEN
        	UPDATE usuario SET nombre = _nombre WHERE id = _id;
        END IF;
        IF(_documento_identidad is NOT NULL) THEN
        	UPDATE usuario SET documento_identidad = _documento_identidad WHERE id = _id;
        END IF;
        IF(_numero_documento is NOT NULL) THEN
        	UPDATE usuario SET numero_documento = _numero_documento WHERE id = _id;
        END IF;
        IF(_direccion is NOT NULL) THEN
        	UPDATE usuario SET direccion = _direccion WHERE id = _id;
        END IF;
        IF(_telefono is NOT NULL) THEN
        	IF(LENGTH(_telefono) <> 9)THEN
    			SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = 'La cantidad de digitos del telefono es incorrecta';
    		ELSE
            	UPDATE usuario SET telefono = _telefono WHERE id = _id;
   			END IF;
        END IF;
        IF(_cargo is NOT NULL) THEN
        	UPDATE usuario SET cargo = _cargo WHERE id = _id;
        END IF;
        IF(_correo is NOT NULL) THEN
        	UPDATE usuario SET correo = _correo WHERE id = _id;
        END IF;
        IF(_contrasenia is NOT NULL) THEN
        	UPDATE usuario SET contrasenia = AES_ENCRYPT(_contrasenia,'camilas') WHERE id = _id;
        END IF;
        SELECT id,nombre,documento_identidad,numero_documento,telefono,correo,direccion,cargo FROM usuario WHERE id = _id; 

    ELSE
    	SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'No proporciono un id valido';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `agregar_sucursal` (IN `_nombre` VARCHAR(250), IN `_direccion` VARCHAR(250), IN `_contacto` INT)   BEGIN
	DECLARE _generate_codigo VARCHAR(10);
	IF(LENGTH(_contacto) <> 9)THEN
    	SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = 'La cantidad de digitos del contacto es incorrecta';
    ELSE
    	SET _generate_codigo = CONCAT(SUBSTRING(_nombre, FLOOR(RAND() * LENGTH(_nombre)+1),3),
                                      FLOOR(RAND() * 10),
                                      SUBSTRING(_direccion,FLOOR(RAND() * LENGTH(_direccion)+1),3),
                                     FLOOR(RAND()* 10));
    	INSERT INTO sucursal(nombre,direccion,contacto,codigo) VALUES (_nombre,_direccion,_contacto,_generate_codigo);
        SELECT id,nombre,direccion,contacto FROM sucursal WHERE nombre = _nombre;
   	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `agregar_usuario` (IN `_nombre` VARCHAR(250), IN `_documento_identidad` VARCHAR(50), IN `_numero_documento` VARCHAR(50), IN `_direccion` VARCHAR(250), IN `_telefono` INT, IN `_cargo` VARCHAR(50), IN `_correo` VARCHAR(250), IN `_contrasenia` VARCHAR(250))   BEGIN
	IF(LENGTH(_telefono) <> 9)THEN
    	SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = 'La cantidad de digitos del telefono es incorrecta';
    ELSE
    	INSERT INTO usuario (nombre,documento_identidad,numero_documento,direccion,telefono,cargo,correo,contrasenia) VALUES (_nombre,_documento_identidad,_numero_documento,_direccion,_telefono,_cargo,_correo,AES_ENCRYPT(_contrasenia,'camilas'));
        SELECT id,nombre,documento_identidad,numero_documento,telefono,correo,direccion,cargo FROM usuario WHERE correo = _correo;
   	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `agregar_usuario_sucursal` (IN `_id_usuario` INT, IN `_id_sucursal` INT, IN `_hora_entrada` TIME, IN `_hora_salida` TIME)   BEGIN
    INSERT INTO `usuario-sucursal`(usuario_id,sucursal_id,hora_entrada,hora_salida) VALUES (_id_usuario,_id_sucursal,_hora_entrada,_hora_salida);
    SELECT usuario_id,sucursal_id,hora_entrada,hora_salida FROM `usuario-sucursal` WHERE usuario_id = _id_usuario AND sucursal_id = _id_sucursal;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cambiar_contrasenia` (IN `_id` INT, IN `_nueva_contrasenia` VARCHAR(250))   BEGIN
	DECLARE comprobar_solicitante INT;
	SELECT COUNT(*) INTO comprobar_solicitante FROM usuario WHERE id = _id;

	IF(comprobar_solicitante > 0)THEN
    	IF(LENGTH(_nueva_contrasenia) > 2)THEN
    		UPDATE usuario SET contrasenia = AES_ENCRYPT(_nueva_contrasenia,'camilas') WHERE id = _id;
            SELECT id,nombre,documento_identidad,numero_documento,telefono,correo,direccion,cargo FROM usuario WHERE id = _id;
        ELSE
        	SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'Proporcione una contraseña validad';
        END IF;
    ELSE
    	SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_usuario` (IN `_id_solicitante` INT, IN `_id_perjudicado` INT)   BEGIN
	DECLARE comprobar_solicitante,comprobar_perjudicado VARCHAR(50);
	SELECT cargo INTO comprobar_solicitante FROM usuario WHERE id = _id_solicitante;
	SELECT cargo INTO comprobar_perjudicado FROM usuario WHERE id = _id_perjudicado;
	IF(comprobar_solicitante <> 'administrador')THEN
    	SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'Usted no tiene los permisos necesarios';
    ELSE
    	IF(comprobar_perjudicado <> 'superadministrador')THEN
        	DELETE FROM usuario WHERE id = _id_perjudicado;
            SELECT id,nombre,documento_identidad,numero_documento,telefono,correo,direccion,cargo FROM usuario WHERE id = _id_solicitante;
        ELSE
        	SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'Usted no tiene los permisos necesarios';
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_sucursales` ()   BEGIN
	SELECT * from sucursal;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_usuarios` ()   BEGIN
	SELECT id,nombre,documento_identidad,numero_documento,direccion,telefono,cargo,correo FROM usuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `mostrar_codigo_sucursal` (IN `_id_sucursal` INT)   BEGIN
    DECLARE _sucursal_exist INT;
    SELECT COUNT(*) INTO _sucursal_exist FROM sucursal WHERE id = _id_sucursal;
    IF(_sucursal_exist > 0)THEN
    	SELECT codigo FROM sucursal WHERE id = _id_sucursal;
    ELSE
    	SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'La sucursal solicitada no existe';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `restore_password` (IN `_correo` VARCHAR(250), IN `_password` VARCHAR(250))   BEGIN
	DECLARE comprobar_solicitante INT;
	SELECT COUNT(*) INTO comprobar_solicitante FROM usuario WHERE correo = _correo;

	IF(comprobar_solicitante > 0)THEN
    	IF(LENGTH(_password) > 2)THEN
    		UPDATE usuario SET contrasenia = AES_ENCRYPT(_password,'camilas') WHERE correo = _correo;
            SELECT * from usuario WHERE correo =_correo;
        ELSE
        	SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'Proporcione una contraseña valida';
        END IF;
    ELSE
    	SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `verificar_identidad` (IN `_correo` VARCHAR(250), IN `_contrasenia` VARCHAR(250), IN `_codigo_sucursal` VARCHAR(250))   BEGIN
	DECLARE correo_count,contrasenia_count,_id_usuario,_id_sucursal,usuario_sucursal_exist INT;
    SELECT COUNT(*) INTO correo_count FROM usuario WHERE correo = _correo;
    IF(correo_count > 0)THEN
    	SELECT COUNT(*) INTO contrasenia_count FROM usuario WHERE correo =_correo AND AES_DECRYPT(contrasenia,'camilas') = _contrasenia;
    	IF(contrasenia_count > 0)THEN
        	SELECT id INTO _id_usuario FROM usuario WHERE correo =_correo AND AES_DECRYPT(contrasenia,'camilas') = _contrasenia;
            IF(_id_usuario > 0) THEN
            	SELECT id INTO _id_sucursal FROM sucursal WHERE codigo = _codigo_sucursal;
                IF(_id_sucursal > 0)THEN
                	SELECT COUNT(*) INTO usuario_sucursal_exist FROM `usuario-sucursal` WHERE sucursal_id = _id_sucursal AND usuario_id = _id_usuario;
                	IF(usuario_sucursal_exist > 0) THEN
                		SELECT id,nombre,documento_identidad,numero_documento,telefono,correo,direccion,cargo FROM usuario WHERE correo =_correo AND AES_DECRYPT(contrasenia,'camilas') = _contrasenia;
                	ELSE
                		SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'La sucursal no corresponde a su usuario';
                	END IF;
                ELSE
                	SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'El codigo de la sucursal no existe';
                END IF;
            END IF;
    	ELSE
        	SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'La contraseña es incorrecta';
        END IF;
    ELSE
    	SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'El correo no existe o no esta registrado';
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

CREATE TABLE `categoria` (
  `id` int(11) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `descripcion` varchar(250) NOT NULL,
  `abreviatura` char(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `id` int(11) NOT NULL,
  `nombre` varchar(250) NOT NULL,
  `documento_identidad` varchar(50) NOT NULL,
  `numero_documento` varchar(50) NOT NULL,
  `telefono` int(11) NOT NULL,
  `correo` varchar(250) NOT NULL,
  `direccion` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compra`
--

CREATE TABLE `compra` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `proveedor_id` int(11) NOT NULL,
  `tipo_comprobante` varchar(100) NOT NULL,
  `serie_comprobante` varchar(25) NOT NULL,
  `numero_comprobante` varchar(25) NOT NULL,
  `fecha` datetime NOT NULL,
  `precio_total` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle-compra`
--

CREATE TABLE `detalle-compra` (
  `compra_id` int(11) NOT NULL,
  `producto_id` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_compra` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle-venta`
--

CREATE TABLE `detalle-venta` (
  `venta_id` int(11) NOT NULL,
  `producto_id` int(11) NOT NULL,
  `precio_venta` float NOT NULL,
  `cantidad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `precio_unitario_referencial` float NOT NULL,
  `categoria_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `id` int(11) NOT NULL,
  `nombre` varchar(250) NOT NULL,
  `documento_identidad` varchar(50) NOT NULL,
  `numero_documento` varchar(50) NOT NULL,
  `telefono` int(11) NOT NULL,
  `correo` varchar(250) NOT NULL,
  `direccion` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sucursal`
--

CREATE TABLE `sucursal` (
  `id` int(11) NOT NULL,
  `nombre` varchar(200) NOT NULL,
  `direccion` varchar(250) NOT NULL,
  `contacto` int(11) NOT NULL,
  `codigo` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `sucursal`
--

INSERT INTO `sucursal` (`id`, `nombre`, `direccion`, `contacto`, `codigo`) VALUES
(1, 'Camilas Principal', 'Ovalo Marcavalle costado de supernova', 999999999, 'camilas'),
(2, 'Almacen', 'Curipata mz lt', 999999999, ''),
(3, 'Camilas Secundario', 'Local secundario AV.1', 999999999, 'L?W_?)Na?? ?Ul'),
(4, 'Camilas Tercero', 'Local secundario AV.2', 999999999, 'eo'),
(5, 'Camilas Cuarto', 'Local secundario AV.3', 999999999, ' Cuoca'),
(6, 'Camilas Quinto', 'Local secundario AV.4', 999999999, 'O4al 6');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id` int(11) NOT NULL,
  `nombre` varchar(250) NOT NULL,
  `documento_identidad` varchar(50) NOT NULL,
  `numero_documento` varchar(50) NOT NULL,
  `telefono` int(11) NOT NULL,
  `correo` varchar(200) NOT NULL,
  `direccion` varchar(200) NOT NULL,
  `cargo` varchar(50) NOT NULL,
  `contrasenia` blob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id`, `nombre`, `documento_identidad`, `numero_documento`, `telefono`, `correo`, `direccion`, `cargo`, `contrasenia`) VALUES
(1, 'Gerson Paul Ventura Hurtado', 'DNI', '72909224', 962715543, 'admin@camilas.com', 'Urb.Curipata Mz.8 Lt.9 Zn.A', 'administrador', 0x64acdeab28fd5a69c2fec668b5afe202),
(2, 'Paul', 'DNI', '77843234', 962715543, 'cajero@camilas.com', 'Urb.Curipata Mz.8 Lt.9 Zn.A', 'cajero', 0xd019700ca9f8405e7901afd619bfd8a6),
(3, 'Jorge Prueba', 'DNI', '12345678', 962715543, 'contador@camilas.com', 'Las Pruebas Av,Nuevo', 'contador', 0x5a2d293b7aeb7becfef39dcb3f2b11c8),
(6, 'Api prueba', 'DNI', '72909224', 123456789, 'apiprueba@camilas.com', 'Api prueba', 'Api prueba', 0x1ecdf80d1627f1c3dabf9c1e43b6c5a3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario-sucursal`
--

CREATE TABLE `usuario-sucursal` (
  `usuario_id` int(11) NOT NULL,
  `sucursal_id` int(11) NOT NULL,
  `hora_entrada` time NOT NULL,
  `hora_salida` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario-sucursal`
--

INSERT INTO `usuario-sucursal` (`usuario_id`, `sucursal_id`, `hora_entrada`, `hora_salida`) VALUES
(1, 1, '08:30:00', '18:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta`
--

CREATE TABLE `venta` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `sucursal_id` int(11) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `tipo_comprobante` varchar(100) NOT NULL,
  `serie_comprobante` varchar(25) NOT NULL,
  `numero_comprobante` varchar(25) NOT NULL,
  `fecha` datetime NOT NULL,
  `precio_total` float NOT NULL,
  `estado` tinyint(1) NOT NULL,
  `estado_sunat` tinyint(1) NOT NULL,
  `serie_comprobante_sunat` varchar(25) NOT NULL,
  `numero_comprobante_sunat` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `compra`
--
ALTER TABLE `compra`
  ADD PRIMARY KEY (`id`),
  ADD KEY `compra-usuario` (`usuario_id`),
  ADD KEY `compra-proveedor` (`proveedor_id`);

--
-- Indices de la tabla `detalle-compra`
--
ALTER TABLE `detalle-compra`
  ADD KEY `detalle-compra-compra` (`compra_id`),
  ADD KEY `detalle-compra-producto` (`producto_id`);

--
-- Indices de la tabla `detalle-venta`
--
ALTER TABLE `detalle-venta`
  ADD KEY `detalle-venta-venta` (`venta_id`),
  ADD KEY `detalle-venta-producto` (`producto_id`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`id`),
  ADD KEY `producto-categoria` (`categoria_id`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UNIQUE` (`nombre`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UNIQUE` (`correo`);

--
-- Indices de la tabla `usuario-sucursal`
--
ALTER TABLE `usuario-sucursal`
  ADD KEY `usuario-sucursal-usuario` (`usuario_id`),
  ADD KEY `usuario-sucursal-sucursal` (`sucursal_id`);

--
-- Indices de la tabla `venta`
--
ALTER TABLE `venta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `venta-usuario` (`usuario_id`),
  ADD KEY `venta-sucursal` (`sucursal_id`),
  ADD KEY `venta-cliente` (`cliente_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categoria`
--
ALTER TABLE `categoria`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `compra`
--
ALTER TABLE `compra`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `sucursal`
--
ALTER TABLE `sucursal`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `venta`
--
ALTER TABLE `venta`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `compra`
--
ALTER TABLE `compra`
  ADD CONSTRAINT `compra-proveedor` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `compra-usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalle-compra`
--
ALTER TABLE `detalle-compra`
  ADD CONSTRAINT `detalle-compra-compra` FOREIGN KEY (`compra_id`) REFERENCES `compra` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle-compra-producto` FOREIGN KEY (`producto_id`) REFERENCES `producto` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalle-venta`
--
ALTER TABLE `detalle-venta`
  ADD CONSTRAINT `detalle-venta-producto` FOREIGN KEY (`producto_id`) REFERENCES `producto` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle-venta-venta` FOREIGN KEY (`venta_id`) REFERENCES `venta` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `producto-categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categoria` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuario-sucursal`
--
ALTER TABLE `usuario-sucursal`
  ADD CONSTRAINT `usuario-sucursal-sucursal` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursal` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `usuario-sucursal-usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `venta-cliente` FOREIGN KEY (`cliente_id`) REFERENCES `cliente` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `venta-sucursal` FOREIGN KEY (`sucursal_id`) REFERENCES `sucursal` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `venta-usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
