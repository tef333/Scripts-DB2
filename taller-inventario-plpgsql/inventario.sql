-- Parte 1 - Modelo de Datos
-- Elimina la tabla 'productos' si existe
DROP TABLE IF EXISTS productos; 

-- Crea la tabla 'productos'
CREATE TABLE productos ( 

    id_producto SERIAL PRIMARY KEY, -- Crea un id único

    nombre VARCHAR(50) NOT NULL, -- Nombre obligatorio del producto

    precio NUMERIC(10,2) CHECK (precio > 0), -- Precio mayor a 0 

    stock INT CHECK (stock >= 0) -- Stock igual o mayor a 0

);

-- Inserta datos en la tabla 
INSERT INTO productos (nombre, precio, stock) VALUES

('Teclado mecánico', 150000.00, 20),

('Mouse inalámbrico', 45000.00, 5),

('Monitor 24 pulgadas', 620000.00, 0);


-- Parte 2 - Función 1: Consultar Stock
-- Crea o reemplaza la función consultar_stock
CREATE OR REPLACE FUNCTION consultar_stock(p_id_producto INT)

-- Devuelve un número entero
RETURNS INT AS $$

-- Declara una variable para guardar stock
DECLARE

    v_stock INT;

BEGIN

		-- Busca el stock del producto con el ID 
    SELECT stock INTO v_stock

    FROM productos

    WHERE id_producto = p_id_producto;
		
		-- Verifica que el producto exista
    IF v_stock IS NULL THEN

				-- Muestra mensaje de error indicando que el producto no existe
        RAISE EXCEPTION 'El producto con id % no existe.', p_id_producto;

    END IF;

		-- Devuelve la cantidad de stock
    RETURN v_stock;

END;

$$ LANGUAGE plpgsql;


-- Parte 3 – Función 2: Validar Disponibilidad
-- Crea o reemplaza la función validar_disponibilidad
CREATE OR REPLACE FUNCTION validar_disponibilidad(p_id_producto INT, p_cantidad INT)

-- Devuelve TRUE o FALSE 
RETURNS BOOLEAN AS $$

-- Variable para guardar el stock
DECLARE

    v_stock INT;

BEGIN

		-- Verifica que la cantidad sea válida
    IF p_cantidad <= 0 THEN

        RAISE EXCEPTION 'La cantidad solicitada debe ser mayor a cero.';

    END IF;

		-- Busca el stock del producto
    SELECT stock INTO v_stock

    FROM productos

    WHERE id_producto = p_id_producto;

		-- Verifica que el producto exista
    IF v_stock IS NULL THEN

				-- Muestra mensaje de error indicando que el producto no existe
        RAISE EXCEPTION 'El producto con id % no existe.', p_id_producto;

    END IF;

		-- Verifica que haya suficiente stock
    IF v_stock < p_cantidad THEN

				-- Muestra mensaje de error indicando que no hay suficiente stock
        RAISE EXCEPTION 'Stock insuficiente. Disponible: %, solicitado: %.', v_stock, p_cantidad;

    END IF;

		-- Si todo está bien devuelve TRUE 
    RETURN TRUE;

END;

$$ LANGUAGE plpgsql;


-- Parte 4 – Procedimiento: Descontar Inventario
-- Crea o reemplaza el procedimiento descontar_inventario
CREATE OR REPLACE PROCEDURE descontar_inventario(p_id_producto INT, p_cantidad INT)

LANGUAGE plpgsql

AS $$

-- Variable para saber si hay disponibilidad
DECLARE

    v_es_valido BOOLEAN;

BEGIN
	
		-- Verifica si hay suficiente stock
    v_es_valido := validar_disponibilidad(p_id_producto, p_cantidad);

		-- Si hay disponibilidad, descuenta la cantidad del stock
    IF v_es_valido THEN

        UPDATE productos

        SET stock = stock - p_cantidad

        WHERE id_producto = p_id_producto;

				-- Muestra mensaje indicando que la venta fue exitosa
        RAISE NOTICE 'Venta exitosa: se descontaron % unidades del producto %.', p_cantidad, p_id_producto;

    END IF;

-- Maneja cualquier error que ocurra en la operación
EXCEPTION

    WHEN OTHERS THEN

        RAISE NOTICE 'No se pudo completar la operación: %', SQLERRM;

END;

$$;

-- Pruebas Realizadas
-- Estado inicial del inventario: 
SELECT * FROM productos;

-- Caso 1 — Exitoso (stock suficiente)
-- CALL descontar_inventario(1, 5);
-- Muestra el mensaje del caso exitoso
SELECT 'CASO 1: EXITOSO' AS info;

-- Descuenta 5 unidades del producto con id 1
CALL descontar_inventario(1, 5);

-- Muestra los datos actualizados del producto con id 1
SELECT * 
FROM productos 
WHERE id_producto = 1;


-- Caso 2 — Stock insuficiente
-- CALL descontar_inventario(2, 100);
-- Muestra el mensaje del caso con stock insuficiente
SELECT 'CASO 2: STOCK INSUFICIENTE' AS info;

-- Intenta descontar 100 unidades del producto con id 2
CALL descontar_inventario(2, 100);

-- Consulta el producto para comprobar que el stock no haya cambiado
SELECT * 
FROM productos 
WHERE id_producto = 2;


-- Caso 3 — Producto inexistente
-- Muestra el mensaje del caso con un producto inexistente
SELECT 'CASO 3: PRODUCTO INEXISTENTE' AS info;

-- Intenta descontar 1 unidad de un producto con id 999
CALL descontar_inventario(999, 1);
