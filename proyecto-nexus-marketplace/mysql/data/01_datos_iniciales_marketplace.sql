-- ============================================================
-- NEXUS MARKETPLACE - DATOS INICIALES MYSQL
-- Base de Datos II | Universidad El Bosque
-- Motor: MySQL 8.x | Base de datos: marketplace
--
-- Modelo:
-- usuario, cliente, administrador, categoria, producto,
-- inventario, carrito, item_carrito, pedido, detalle_pedido,
-- pago, envio
-- ============================================================

USE marketplace;

-- =========================
-- USUARIOS
-- =========================
INSERT INTO usuario (correo_electronico, nombre, contrasena, rol) VALUES
('carlos.martinez@gmail.com', 'Carlos Martinez', 'pass1234', 'cliente'),
('laura.gomez@gmail.com', 'Laura Gomez', 'pass1234', 'cliente'),
('andres.lopez@gmail.com', 'Andres Lopez', 'pass1234', 'cliente'),
('maria.rodriguez@gmail.com', 'Maria Rodriguez', 'pass1234', 'cliente'),
('juan.perez@gmail.com', 'Juan Perez', 'pass1234', 'cliente'),
('sofia.hernandez@gmail.com', 'Sofia Hernandez', 'pass1234', 'cliente'),
('daniel.torres@gmail.com', 'Daniel Torres', 'pass1234', 'cliente'),
('valentina.diaz@gmail.com', 'Valentina Diaz', 'pass1234', 'cliente'),
('felipe.castro@gmail.com', 'Felipe Castro', 'pass1234', 'cliente'),
('admin1@marketplace.com', 'Roberto Sanchez', 'admin1234', 'administrador'),
('admin2@marketplace.com', 'Diana Vargas', 'admin1234', 'administrador'),
('eparedesca@unbosque.edu.co', 'Estefania Paredes', '1234', 'administrador');

-- =========================
-- ADMINISTRADORES
-- =========================
INSERT INTO administrador (cedula, correo_electronico, nombre, apellido, telefono, estado) VALUES
(11111111, 'admin1@marketplace.com', 'Roberto', 'Sanchez', '3101234567', 'activo'),
(22222222, 'admin2@marketplace.com', 'Diana', 'Vargas', '3207654321', 'activo'),
(33333333, 'eparedesca@unbosque.edu.co', 'Estefania', 'Paredes', '3159876543', 'activo');

-- =========================
-- CLIENTES
-- =========================
INSERT INTO cliente (cedula, correo_electronico, nombre, apellido, direccion, ciudad, telefono) VALUES
(1001234567, 'carlos.martinez@gmail.com', 'Carlos', 'Martinez', 'Calle 45 # 12-30', 'Bogota', '3112345678'),
(1002345678, 'laura.gomez@gmail.com', 'Laura', 'Gomez', 'Carrera 80 # 34-50', 'Medellin', '3123456789'),
(1003456789, 'andres.lopez@gmail.com', 'Andres', 'Lopez', 'Avenida 6 # 20-10', 'Cali', '3134567890'),
(1004567890, 'maria.rodriguez@gmail.com', 'Maria', 'Rodriguez', 'Calle 72 # 5-45', 'Barranquilla', '3145678901'),
(1005678901, 'juan.perez@gmail.com', 'Juan', 'Perez', 'Carrera 15 # 90-20', 'Bogota', '3156789012'),
(1006789012, 'sofia.hernandez@gmail.com', 'Sofia', 'Hernandez', 'Calle 10 # 3-15', 'Cartagena', '3167890123'),
(1007890123, 'daniel.torres@gmail.com', 'Daniel', 'Torres', 'Avenida El Poblado # 1-50', 'Medellin', '3178901234'),
(1008901234, 'valentina.diaz@gmail.com', 'Valentina', 'Diaz', 'Carrera 100 # 16-80', 'Cali', '3189012345'),
(1009012345, 'felipe.castro@gmail.com', 'Felipe', 'Castro', 'Calle 93 # 19-55', 'Bogota', '3190123456');

-- =========================
-- CATEGORIAS
-- =========================
INSERT INTO categoria (nombre_categoria, descripcion) VALUES
('Computadores', 'Laptops, PCs de escritorio y todo en uno para trabajo y estudio'),
('Televisores', 'Smart TVs, OLED y QLED de las mejores marcas'),
('Gaming', 'Consolas, videojuegos y accesorios para gamers'),
('Accesorios', 'Fundas, cables, cargadores y perifericos para tus dispositivos'),
('Smart Watch', 'Relojes inteligentes con monitoreo de salud y conectividad');

-- =========================
-- PRODUCTOS
-- Nota: se asume que Celulares es id_categoria = 1.
-- Ajustar id_categoria si la base local tiene otros identificadores.
-- =========================
INSERT INTO producto (codigo, id_categoria, nombre, descripcion, precio) VALUES
('SAM-S24', 1, 'Samsung Galaxy S24', 'Smartphone Samsung Galaxy S24 256GB, camara de 50MP', 3500000),
('XIA-14', 1, 'Xiaomi 14', 'Smartphone Xiaomi 14 512GB, pantalla AMOLED 120Hz', 2800000),
('MAC-AIR', 2, 'MacBook Air M3', 'Laptop Apple MacBook Air con chip M3, 16GB RAM, 512GB SSD', 7200000),
('DEL-XPS', 2, 'Dell XPS 15', 'Laptop Dell XPS 15 Intel Core i7, 32GB RAM, 1TB SSD', 6500000),
('SAM-TV65', 3, 'Samsung QLED 65"', 'Smart TV Samsung QLED 65 pulgadas 4K con Tizen OS', 4800000),
('SON-PS5', 4, 'PlayStation 5', 'Consola Sony PlayStation 5 825GB con control DualSense', 3200000),
('APL-WATCH', 6, 'Apple Watch Series 9', 'Smartwatch Apple Watch Series 9 GPS 45mm aluminio', 1900000),
('SAM-WATCH', 6, 'Samsung Galaxy Watch 6', 'Smartwatch Samsung Galaxy Watch 6 44mm con monitoreo de salud', 1200000),
('ACC-AIRPODS', 5, 'AirPods Pro 2', 'Audifonos inalambricos Apple AirPods Pro 2da generacion con ANC', 1100000);

-- =========================
-- INVENTARIO
-- =========================
INSERT INTO inventario (codigo_producto, cantidad) VALUES
('SAM-S24', 25),
('XIA-14', 30),
('MAC-AIR', 15),
('DEL-XPS', 12),
('SAM-TV65', 10),
('SON-PS5', 20),
('APL-WATCH', 18),
('SAM-WATCH', 22),
('ACC-AIRPODS', 35);

-- =========================
-- CONTRASENAS HASHEDAS
-- =========================
UPDATE usuario SET contrasena = 'scrypt:32768:8:1$OosrUSRKLJe1HW7O$1bbc22eaeb1e2edac2d60676e242dc78a73ed0582cd4a575083375f61a17dd3ed4fb34a431622d97744df45bb3a8e686070dad3fe1e3f1e2d2da4c997482446b'
WHERE correo_electronico IN (
    'andres.lopez@gmail.com',
    'carlos.martinez@gmail.com',
    'daniel.torres@gmail.com',
    'felipe.castro@gmail.com',
    'juan.perez@gmail.com',
    'laura.gomez@gmail.com',
    'maria.rodriguez@gmail.com',
    'sofia.hernandez@gmail.com',
    'valentina.diaz@gmail.com'
);

UPDATE usuario SET contrasena = 'scrypt:32768:8:1$MVRrihBlmo3d9FhV$b2a946f93e4ec69653625bcf5729dfb7e09a91d353903dccfddc77e2840ad85de77f1213be6e914b246d30ce2fdb9b2719c62b8686bb7bf901ddbf1b45ec3f87'
WHERE correo_electronico IN (
    'admin1@marketplace.com',
    'admin2@marketplace.com'
);

UPDATE usuario SET contrasena = 'scrypt:32768:8:1$eu4eE0CKkWvl8TPx$a8756402d3b53437860edafdff1fb73991f558cba444ccb2d0551f8ad1c1f5a1b1158d6314eabc6b19d4e30fdd148abd019abb9e13cfe5231789cfca7ac7c533'
WHERE correo_electronico = 'eparedesca@unbosque.edu.co';

