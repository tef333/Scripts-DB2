-- ============================================================
-- Autor: Estefania Paredes Castañeda
-- Fecha: 07-08-2026
-- Descripción: Actividad 1 BD2 "Tienda Online" SCHEMA SQL
-- ============================================================

-- ============================================================
-- EJERCICIO 1: DISEÑO DE BASE DE DATOS
-- CREACIÓN DE TABLAS
-- ============================================================

CREATE TABLE categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL
);


CREATE TABLE productos (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    categoria_id INT NOT NULL,

    CONSTRAINT fk_productos_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES categorias(categoria_id)
);


CREATE TABLE clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    ciudad VARCHAR(50)
);


CREATE TABLE pedidos (
    pedido_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    fecha_pedido DATE NOT NULL,
    total DECIMAL(10,2),

    CONSTRAINT fk_pedidos_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(cliente_id)
);


CREATE TABLE detalle_pedidos (
    detalle_id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_detalle_pedido
        FOREIGN KEY (pedido_id)
        REFERENCES pedidos(pedido_id),

    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos(producto_id)
);


-- ============================================================
-- INSERTAR CATEGORÍAS
-- ============================================================

INSERT INTO categorias (nombre_categoria)
VALUES
('Electrónica'),
('Ropa'),
('Hogar'),
('Deportes'),
('Libros');


-- ============================================================
-- INSERTAR PRODUCTOS
-- ============================================================

INSERT INTO productos
(nombre_producto, precio, stock, categoria_id)
VALUES
('Laptop HP', 850.00, 15, 1),
('Mouse Inalámbrico', 25.50, 50, 1),
('Teclado Mecánico', 75.00, 30, 1),
('Monitor Samsung 24"', 180.00, 20, 1),
('Auriculares Sony', 95.00, 40, 1),

('Camiseta Nike', 35.00, 100, 2),
('Pantalón Adidas', 55.00, 80, 2),
('Zapatos Deportivos', 120.00, 45, 2),
('Chaqueta Columbia', 150.00, 25, 2),

('Licuadora', 45.00, 35, 3),
('Aspiradora', 120.00, 18, 3),
('Cafetera', 65.00, 28, 3),
('Microondas', 180.00, 12, 3),

('Balón de Fútbol', 30.00, 60, 4),
('Raqueta de Tenis', 85.00, 22, 4),
('Bicicleta Montaña', 450.00, 8, 4),
('Pesas 10kg', 40.00, 35, 4),

('Libro SQL Avanzado', 28.00, 50, 5),
('Libro Python Básico', 32.00, 45, 5),

('Tablet Samsung', 280.00, 15, 1);


-- ============================================================
-- INSERTAR CLIENTES
-- ============================================================

INSERT INTO clientes
(nombre, apellido, email, ciudad)
VALUES
('Juan', 'Pérez', 'juan.perez@email.com', 'Bogotá'),
('María', 'González', 'maria.gonzalez@email.com', 'Medellín'),
('Carlos', 'Rodríguez', 'carlos.rodriguez@email.com', 'Cali'),
('Ana', 'Martínez', 'ana.martinez@email.com', 'Bogotá'),
('Luis', 'López', 'luis.lopez@email.com', 'Barranquilla'),
('Carmen', 'Fernández', 'carmen.fernandez@email.com', 'Cali'),
('Miguel', 'Sánchez', 'miguel.sanchez@email.com', 'Medellín'),
('Laura', 'Ramírez', 'laura.ramirez@email.com', 'Bogotá'),
('Pedro', 'Torres', 'pedro.torres@email.com', 'Cartagena'),
('Isabel', 'Morales', 'isabel.morales@email.com', 'Cali');


-- ============================================================
-- INSERTAR PEDIDOS
-- ============================================================

INSERT INTO pedidos
(cliente_id, fecha_pedido, total)
VALUES
(1, '2025-01-10', 920.50),
(2, '2025-01-12', 90.00),
(3, '2025-01-14', 285.00),
(1, '2025-01-15', 155.00),
(4, '2025-01-16', 245.00),
(5, '2025-01-17', 850.00),
(6, '2025-01-18', 340.00),
(2, '2025-01-19', 215.00),
(7, '2025-01-20', 130.00),
(8, '2025-01-21', 565.00),
(3, '2025-01-22', 95.00),
(9, '2025-01-23', 450.00),
(10, '2025-01-24', 290.00),
(4, '2025-01-25', 180.00),
(5, '2025-01-26', 75.00);


-- ============================================================
-- INSERTAR DETALLE DE PEDIDOS
-- ============================================================

INSERT INTO detalle_pedidos
(pedido_id, producto_id, cantidad, precio_unitario)
VALUES

-- Pedido 1
(1, 1, 1, 850.00),
(1, 2, 2, 25.50),
(1, 18, 1, 28.00),

-- Pedido 2
(2, 6, 2, 35.00),
(2, 14, 1, 30.00),

-- Pedido 3
(3, 11, 1, 120.00),
(3, 12, 2, 65.00),
(3, 6, 1, 35.00),

-- Pedido 4
(4, 7, 1, 55.00),
(4, 10, 2, 45.00),
(4, 18, 1, 28.00),

-- Pedido 5
(5, 4, 1, 180.00),
(5, 12, 1, 65.00),

-- Pedido 6
(6, 1, 1, 850.00),

-- Pedido 7
(7, 13, 1, 180.00),
(7, 10, 2, 45.00),
(7, 2, 2, 25.50),

-- Pedido 8
(8, 8, 1, 120.00),
(8, 5, 1, 95.00),

-- Pedido 9
(9, 15, 1, 85.00),
(9, 6, 1, 35.00),
(9, 18, 1, 28.00),

-- Pedido 10
(10, 16, 1, 450.00),
(10, 17, 2, 40.00),
(10, 6, 1, 35.00),

-- Pedido 11
(11, 5, 1, 95.00),

-- Pedido 12
(12, 16, 1, 450.00),

-- Pedido 13
(13, 20, 1, 280.00),
(13, 18, 1, 28.00),

-- Pedido 14
(14, 4, 1, 180.00),

-- Pedido 15
(15, 3, 1, 75.00);
