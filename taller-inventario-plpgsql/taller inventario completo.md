# Taller PL/pgSQL TechStore

Estefania Paredes Castañeda

# Introducción

### ¿Qué es PL/pgSQL?

Es un lenguaje de programación procedimental para PostgreSQL. A diferencia del SQL normal, que solo permite hacer consultas y operaciones de una sola sentencia, PL/pgSQL lo que permite es escribir bloques de código con variables, condicionales como IF, ciclos, manejo de errores con EXCEPTION y en general una lógica de negocio completa dentro de la base de datos, en forma de funciones y procedimientos.

### Diferencia entre Función y Procedimiento

Para entender de forma clara la diferencia entre estos dos conceptos se presenta a continuación una tabla comparativa de sus características:

|  | **Función (FUNCTION)** | **Procedimiento (PROCEDURE)** |
| --- | --- | --- |
| **Se ejecuta con** | SELECT | CALL |
| **Debe retornar algo** | Sí, con RETURN | No es obligatorio |
| **Puede modificar datos (INSERT/UPDATE)** | Se puede, pero no es su propósito principal | Es su propósito |
| **Control transaccional propio (COMMIT interno)** | No | Sí, desde PostgreSQL 11+ |
| **Uso general** | Calcular o consultar algo | Ejecutar una operación de negocio (por ejemplo una venta) |

En este taller se usan dos funciones (consultar stock y validar disponibilidad, que devuelven un valor) y un procedimiento (descontar inventario, que ejecuta una acción sobre la tabla).

# Desarrollo Técnico

## Parte 1 - Modelo de Datos

```sql
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
```

Explicación del bloque: El SERIAL PRIMARY KEY hace que cada producto tenga un ID único que se genera automáticamente. Los CHECK sirven para validar los datos, por ejemplo, que el precio sea mayor a 0 y que el stock no sea negativo. Si no se cumple alguna de estas condiciones, PostgreSQL no permite guardar o modificar el dato.

### **Respuestas de análisis (Parte 1):**

1. **¿Por qué el precio tiene restricción CHECK?** 
Porque no tendría sentido tener un precio en 0 y menos en negativo. Lo que hace la restricción es que obliga a que cualquier precio que se ingrese sea mayor a 0 para evitar cualquier error.
2. **¿Por qué el stock no puede ser negativo?** 
 Por simple logica física no pueden existir unidades negativas de un producto, es decir, tener por ejemplo menos cinco unidades. Si eso se permite significaría que se vendieron más productos de los que habían en bodega, esto sería un error de consistencia con el inventario que realmente existe y el que estuviera registrado en la base de datos.
3. **¿Qué problema empresarial se evita con estas restricciones?** 
Se está evitando que el sistema por algún error humano al registrar manualmente, deje la base de datos con alguna inconsistencia, como por ejemplo: vender un producto que no existe, generar reportes financieros incorrectos con precios que no son validos, etc.

## Parte 2 - Función 1: Consultar Stock

```sql
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
```

**Explicación del bloque:** Esta función sirve para consultar cuánto stock tiene un producto a partir de su ID. Primero busca el producto y guarda su stock en una variable. Si no encuentra el producto, muestra un mensaje de error; si lo encuentra, devuelve la cantidad de unidades disponibles.

### **Respuestas de análisis (Parte 2):**

1. **¿Qué hace SELECT INTO?** 
Lo que hace es ejecutar una consulta normal y en vez de devolver el resultado como tabla, lo guarda en una variable que se declara en el bloque DECLARE, que en este caso es v_stock.
2. **¿Qué sucede cuando no se encuentra el producto?** 
Si no se encuentra el producto, es decir que el WHERE no encontró ninguna fila, el SELECT INTO no va a lanzar error automáticamente sino que deja la variable nula. Es por eso que se utiliza la excepción IF v_stock IS NULL THEN RAISE EXCEPTION precisamente para controlar este problema con un mensaje al usuario, para no seguir con un dato vacío.

## Parte 3 – Función 2: Validar Disponibilidad

```sql
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
```

## **Respuestas de análisis (Parte 3):**

1. **¿Por qué es mejor validar antes de actualizar?** 
Como buena práctica siempre se busca validar los datos antes de actualizar para que no se cometa ningún error. En este caso si se intentara descontar stock sin validar antes, el CHECK (stock >= 0) , regla de la tabla, rechazaría la operación hasta que se llegara al UPDATE, en ese momento lo que recibiría el usuario sería en vez de un mensaje de advertencia un error genérico como: ERROR: new row for relation "productos" violates check constraint "productos_stock_check” cosa que no sería clara para la persona que está manejando el sistema. Por eso validar antes es anticipar el problema, dar un mensaje que el usuario entienda, en este caso hasta se le especifíca cuánto solicitó y cuánto hay disponible: RAISE EXCEPTION 'Stock insuficiente. Disponible: %, solicitado: %.' y evitar que el UPDATE se intente con algún problema. 
2. **¿Qué pasaría si no existiera esta función?** 
Si no existiera la función sería un procedimiento obligado a repetir toda la lógica de validación cada vez que el usuario quisiera descontar un producto del inventario, o peor aún, no validar nada y depender totalmente del CHECK de la tabla, lo que traería como consecuencia el ya mencionado error genérico de la base de datos el cual sería poco claro de entender para el usuario, además si a futuro se quisieran agregar otras formas de descontar stock aumentaría el riesgo de tener inconsistencias si no pasa por esta validación.

## Parte 4 – Procedimiento: Descontar Inventario

```sql
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
```

**Explicación del bloque:** Este procedimiento sirve para descontar productos del inventario cuando se realiza una venta. Primero verifica que el producto exista y que tenga suficiente stock. Si todo está bien, resta la cantidad solicitada del inventario y muestra un mensaje de venta exitosa. Si ocurre algún error, muestra un mensaje indicando que la operación no se pudo realizar.

### **Respuestas de análisis (Parte 4):**

1. **¿Por qué este proceso se implementa como procedimiento y no como función?** 
Porque como se había explicado anteriormente, el objetivo del procedimiento no es calcular ni devolver un valor para usarlo en otra parte del código, sino ejecutar una acción sobre los datos, en este caso modificar el stock, y confirmar el resultado con un mensaje. Además los procedimientos también agrupan varias operaciones, como validar actualizar y notificar, manejan su propio control en transacciones, más una función está pensada para devolver un resultado a partir de los datos de entrada.
2. **¿Qué ocurre si falla después de iniciar la operación?** 
Si validar_disponibilidad lanza una excepción como por ejemplo stock insuficiente o producto inexistente, hay un salto inmediato al bloque de EXCEPTION WHEN OTHERS THEN y el UPDATE no llega a ejecutarse porque está en el condicional IF v_es_valido THEN. Esto significa que no puede aplicarse ningún cambio sin validar antes, o se valida y se actualiza o simplemente no se actualiza nada.
3. **¿Se mantiene la consistencia del inventario?** 
Si, ya que la validación ocurre antes del UPDATE, entonces cualquier error lo que hace es interrumpir el flujo antes de llegar a tocar la tabla, el stock que está registrado en la base de datos siempre va a realizar una operación válida, no puede quedar a medias o con valores negativos, combina la validación en la función y el CHECK propio de la tabla para que no suceda algún problema.

# Pruebas Realizadas

## Estado inicial del inventario:

!Captura de pantalla 2026-09-06 192642.png

## Caso 1 — Exitoso (stock suficiente)

CALL descontar_inventario(1, 5);

```sql
-- Muestra el mensaje del caso exitoso
SELECT 'CASO 1: EXITOSO' AS info;

-- Descuenta 5 unidades del producto con id 1
CALL descontar_inventario(1, 5);

-- Muestra los datos actualizados del producto con id 1
SELECT * 
FROM productos 
WHERE id_producto = 1;
```

!Captura de pantalla 2026-09-06 205026.png

!Captura de pantalla 2026-09-06 205005.png

- **¿Qué ocurrió?** 
Se descontaron 5 unidades del producto con id 1, en este caso, el teclado mecánico.
- **¿Qué mensaje mostró el sistema?** 
Venta exitosa: se descontaron 5 unidades del producto 1.
- **¿Se modificó la base de datos?** 
Sí, el stock del producto con id 1 pasó de 20 a 15.

## Caso 2 — Stock insuficiente

CALL descontar_inventario(2, 100);

```sql
-- Muestra el mensaje del caso con stock insuficiente
SELECT 'CASO 2: STOCK INSUFICIENTE' AS info;

-- Intenta descontar 100 unidades del producto con id 2
CALL descontar_inventario(2, 100);

-- Consulta el producto para comprobar que el stock no haya cambiado
SELECT * 
FROM productos 
WHERE id_producto = 2;
```

!Captura de pantalla 2026-09-06 205058.png

!Captura de pantalla 2026-09-06 204316.png

- **¿Qué ocurrió?** 
Se intentaron descontar 100 unidades del producto con id 2: mouse inalámbrico, que solo tiene 5 disponibles.
- **¿Qué mensaje mostró el sistema?** 
No se pudo completar la operación: Stock insuficiente. Disponible: 5, solicitado: 100.
- **¿Se modificó la base de datos?** 
No, el stock del producto 2 se mantuvo en 5.

## Caso 3 — Producto inexistente

```sql
-- Muestra el mensaje del caso con un producto inexistente
SELECT 'CASO 3: PRODUCTO INEXISTENTE' AS info;

-- Intenta descontar 1 unidad de un producto con id 999
CALL descontar_inventario(999, 1);
```

!Captura de pantalla 2026-09-06 205128.png

!Captura de pantalla 2026-09-06 204601.png

- **¿Qué ocurrió?** 
Se intentó descontar stock de un id de producto que no existe en la tabla.
- **¿Qué mensaje mostró el sistema?** 
No se pudo completar la operación: El producto con id 999 no existe.
- **¿Se modificó la base de datos?** 
No, no hubo ningún cambio porque no se llegó a ejecutar el UPDATE.

# Análisis

Al principio creo que lo más importante es aprender a reconocer bien la diferencia entre RAISE EXCEPTION y RAISE NOTICE ya que ambos sirven para mostrar un mensaje, pero RAISE EXCEPTION lo que hace es detener toda la ejecución del bloque, por eso la usé en las funciones, por otro lado RAISE NOTICE lo que hace es informar pero el código sigue corriendo, por eso la usé dentro del EXCEPTION WHEN OTHERS del procedimiento, para avisar qué pasaba de manera controlada con un mensaje claro de leer para el usuario y no un error genérico que no se entendiera facilmente. 
Claramente los errores que más se me presentaron fueron de sintaxis al correrlo en el editor de Neon, cosas como escribir mal el nombre de una variable o tal vez olvidar cerrar el bloque, inmediatamente me presentaba el error genérico en pantalla y tenía que hacer una retroalimentación de lo que había escrito para encontrar el error y poder corregirlo.
Otra cosa que fue escencial de entender y cuesta al principio en este taller es que la validación: validar_disponibilidad estaba separa del procedimiento: descontar_inventario en vez de meterlo todo en un solo bloque. Cuando se pone en práctica se entiende que tiene sentido porque la función de validación puede reutilizarse en otras partes, ahorrando el trabajo de repetir lógica, además de que es mucho más fácil identificar en qué parte de todo el proceso algo falló, si el error viene de la validación o de la actualización.  
También aprendí que este motor de base de datos PostgreSQL protege datos en dos niveles distintos, en primer lugar con las restricciones que tiene directamente en la tabla, es decir el CHECK, y segundo con las validaciones que escribí posteriormente en las funciones. Esto ayuda a entender que en este tema de bases de datos la misma base debe tener sus propias reglas en el tema de seguridad y se debe ser muy cuidadoso con eso ya que afecta a todo el sistema.

# Conclusiones

Gracias a los ejercicios realizados pude, primero entender de manera más clara los conceptos de función y procedimiento en PostgreSQL a través de la práctica, de intento y error hasta lograr las consultas correctas, y no es solo el escribir consultas sino también como ingeniera usar esto como una herramienta para mover parte de la lógica de negocio a la base de datos. Es muy importante poner esto en práctica porque tal vez se tiene una idea equivocada de que las validaciones de un sistema deben resolverse en otras partes del mismo, pero al familiarizarse con este tema uno termina dandose cuenta de la importancia que es el manejo de excepciones desde la capa de base de datos.
Para terminar, el patrón que manejé de validar siempre antes de actualizar es algo que a partir de ahora puedo aplicar a cualquier sistema y más si se van a manejar datos sensibles, ya que permite que se ejecuten operaciones completas y si se presenta algún error, lo mostrará al usuario de una manera comprensible para cualquier persona y no un mensaje de error genérico que para alguien no familiarizado con el tema resulta muy díficil de entender. 
Me llevo este taller como un gran aprendizaje para mis futuros proyectos, siempre buscando aplicar nuevas técnicas y conocimientos para realizar soluciones completas en el campo de la ingeniería.
