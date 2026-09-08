-- ============================================================
-- Sesión Martes: JOIN y Subconsultas — Bases de Datos 2
-- Setup: esquema de tablas + datos de práctica (Neon)
-- ============================================================

-- Si necesitas repetir el setup desde cero, corre esto primero:
-- DROP TABLE IF EXISTS detalle_pedidos, pedidos, clientes, productos, categorias CASCADE;

CREATE TABLE categorias (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL
);

CREATE TABLE productos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  precio NUMERIC(10,2) NOT NULL,
  stock INT NOT NULL,
  categoria_id INT REFERENCES categorias(id)
);

CREATE TABLE clientes (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  email VARCHAR(100),
  ciudad VARCHAR(50)
);

CREATE TABLE pedidos (
  id SERIAL PRIMARY KEY,
  cliente_id INT REFERENCES clientes(id),
  fecha DATE NOT NULL,
  total NUMERIC(10,2) NOT NULL
);

CREATE TABLE detalle_pedidos (
  id SERIAL PRIMARY KEY,
  pedido_id INT REFERENCES pedidos(id),
  producto_id INT REFERENCES productos(id),
  cantidad INT NOT NULL,
  precio_unitario NUMERIC(10,2) NOT NULL
);


-- ============================================================
-- Carga de datos de práctica
-- 6 categorías, 16 productos, 12 clientes, 20 pedidos, 31 detalles
-- ============================================================

INSERT INTO categorias (nombre) VALUES
('Electrónica'),('Ropa'),('Hogar'),('Deportes'),('Libros'),('Juguetes');

INSERT INTO productos (nombre, precio, stock, categoria_id) VALUES
('Laptop Lenovo', 2200000, 8, 1),
('Mouse Inalámbrico', 45000, 50, 1),
('Teclado Mecánico', 180000, 20, 1),
('Audífonos Bluetooth', 120000, 35, 1),
('Camiseta Básica', 35000, 100, 2),
('Pantalón Jean', 90000, 60, 2),
('Chaqueta Impermeable', 150000, 15, 2),
('Gorra Deportiva', 25000, 80, 2),
('Juego de Sábanas', 70000, 25, 3),
('Lámpara de Mesa', 55000, 18, 3),
('Set de Ollas', 220000, 10, 3),
('Balón de Fútbol', 60000, 40, 4),
('Tenis Running', 210000, 22, 4),
('Mancuernas 5kg', 80000, 12, 4),
('Bicicleta Urbana', 950000, 5, 4),
('Cien Años de Soledad', 45000, 30, 5);

INSERT INTO clientes (nombre, apellido, email, ciudad) VALUES
('Ana','Torres','ana.torres@email.com','Bogotá'),
('Luis','Ramírez','luis.ramirez@email.com','Medellín'),
('Marta','Gómez','marta.gomez@email.com','Cali'),
('Carlos','Pérez','carlos.perez@email.com','Bogotá'),
('Diana','Ríos','diana.rios@email.com','Barranquilla'),
('Jorge','Salazar','jorge.salazar@email.com','Medellín'),
('Paula','Castro','paula.castro@email.com','Cali'),
('Andrés','Rojas','andres.rojas@email.com','Bogotá'),
('Camila','Vargas','camila.vargas@email.com','Bucaramanga'),
('Felipe','Moreno','felipe.moreno@email.com','Medellín'),
('Sofía','Herrera','sofia.herrera@email.com','Bogotá'),
('Miguel Ángel','Suárez','miguel.suarez@email.com','Cali');

INSERT INTO pedidos (cliente_id, fecha, total) VALUES
(1,'2025-01-05',250000),(1,'2025-02-10',90000),(2,'2025-01-12',420000),
(3,'2025-01-20',60000),(4,'2025-02-01',310000),(4,'2025-03-15',45000),
(5,'2025-01-08',180000),(6,'2025-02-18',310000),(7,'2025-01-25',70000),
(7,'2025-03-02',120000),(8,'2025-02-22',200000),(10,'2025-01-30',55000),
(10,'2025-02-14',80000),(11,'2025-03-05',210000),(3,'2025-03-10',35000),
(2,'2025-03-20',150000),(5,'2025-02-25',45000),(6,'2025-03-01',60000),
(1,'2025-03-22',120000),(8,'2025-01-15',25000);

INSERT INTO detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(1,3,1,180000),(1,2,1,45000),(2,5,2,35000),(2,8,1,25000),
(3,13,2,210000),(4,12,1,60000),(5,7,1,150000),(5,6,1,90000),
(5,8,2,25000),(6,16,1,45000),(7,3,1,180000),(8,14,2,80000),
(8,7,1,150000),(9,5,1,35000),(9,16,1,45000),(10,4,1,120000),
(10,2,2,45000),(11,13,1,210000),(12,9,1,70000),(13,10,1,55000),
(13,8,1,25000),(14,6,1,90000),(14,4,1,120000),(15,16,1,45000),
(16,7,1,150000),(17,5,3,35000),(18,12,1,60000),(18,8,1,25000),
(19,13,1,210000),(20,2,1,45000),(20,16,1,45000);

-- Verificación: SELECT COUNT(*) FROM productos; debe devolver 16
