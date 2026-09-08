-- ============================================================
-- Sesión Jueves: CTE y Funciones de Ventana — Bases de Datos 2
-- Setup: continúa sobre la misma base del martes (JOIN y Subconsultas)
-- Solo se agrega la tabla 'empleados' para practicar CTE recursivo.
-- ============================================================

CREATE TABLE empleados (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL,
  cargo VARCHAR(60),
  jefe_id INT REFERENCES empleados(id)
);

INSERT INTO empleados (nombre, cargo, jefe_id) VALUES
('Patricia Gómez', 'Gerente General', NULL),
('Andrés Silva', 'Director de Ventas', 1),
('Laura Méndez', 'Directora de Operaciones', 1),
('Carlos Ibán', 'Supervisor de Ventas', 2),
('Diana Ruiz', 'Supervisor de Ventas', 2),
('Felipe Ortiz', 'Vendedor', 4),
('Sofía Peña', 'Vendedora', 4),
('Mateo Rojas', 'Vendedor', 5),
('Camilo Duarte', 'Supervisor de Bodega', 3),
('Valentina Cruz', 'Auxiliar de Bodega', 9);

-- Verificación: SELECT COUNT(*) FROM empleados; debe devolver 10
-- Patricia (id=1) es la única sin jefe — es la raíz del organigrama.
