# Scripts DB2

Repositorio academico para Bases de Datos 2.

Contiene dos bloques separados:

- `proyecto-nexus-marketplace/`: proyecto final Nexus Marketplace, con MySQL como base relacional y MongoDB como base NoSQL.
- `ejercicios-oracle/`: ejercicios independientes de Oracle SQL y PL/SQL desarrollados durante el curso.

## Estructura

```text
Scripts-DB2/
|-- proyecto-nexus-marketplace/
|   |-- mysql/
|   |   |-- data/
|   |   |-- reports/
|   |   `-- docs/
|   `-- mongodb/
|       |-- scripts/
|       `-- docs/
`-- ejercicios-oracle/
    |-- 01_consultas_sql/
    |-- 02_plsql_anonimos/
    |-- 03_procedimientos/
    |-- 04_triggers_excepciones/
    `-- 05_taller_final/
```

## Proyecto Nexus Marketplace

Nexus Marketplace utiliza dos motores:

- **MySQL 8.x** para datos relacionales y transaccionales: usuarios, clientes, administradores, categorias, productos, inventario, carritos, pedidos, pagos y envios.
- **MongoDB** para datos flexibles o semiestructurados: resenas, valoraciones, comentarios, especificaciones tecnicas variables y caracteristicas adicionales.

### MySQL

Archivos principales:

```text
proyecto-nexus-marketplace/mysql/data/01_datos_iniciales_marketplace.sql
proyecto-nexus-marketplace/mysql/reports/01_reportes_nexus_marketplace.sql
proyecto-nexus-marketplace/mysql/docs/modelo-relacional.md
```

Los reportes SQL incluyen:

- Ventas totales por cliente.
- Productos mas vendidos.
- Estado actual del inventario.
- Ingresos mensuales.
- Ventas por metodo de pago.
- Ventas por categoria.
- Distribucion geografica de clientes y ventas.
- Resumen ejecutivo de indicadores generales.

### MongoDB

Archivos principales:

```text
proyecto-nexus-marketplace/mongodb/scripts/01_setup.mongodb.js
proyecto-nexus-marketplace/mongodb/scripts/02_crud.mongodb.js
proyecto-nexus-marketplace/mongodb/scripts/03_consultas_complejas.mongodb.js
proyecto-nexus-marketplace/mongodb/scripts/04_agregaciones.mongodb.js
proyecto-nexus-marketplace/mongodb/docs/diseno-documental.md
```

La base NoSQL se llama:

```text
nexus_marketplace_nosql
```

Incluye:

- Diseno documental.
- Patron de Atributo.
- Patron de Subconjunto.
- Operaciones CRUD.
- Consultas complejas.
- Agregaciones.

## Ejercicios Oracle

Los ejercicios Oracle estan separados del proyecto Nexus Marketplace.

Incluyen:

- Consultas SQL sobre esquema HR.
- Bloques anonimos PL/SQL.
- Procedimientos almacenados.
- Triggers y excepciones.
- Taller final con enfoque ACID.

