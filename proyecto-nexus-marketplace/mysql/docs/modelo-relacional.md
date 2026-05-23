# Modelo relacional MySQL - Nexus Marketplace

## Motor

MySQL 8.x.

## Base de datos

```sql
marketplace
```

## Tablas principales

El modelo relacional de Nexus Marketplace administra la informacion estructurada y transaccional del sistema:

- `usuario`: credenciales y rol general.
- `cliente`: informacion detallada de clientes.
- `administrador`: informacion detallada de administradores.
- `categoria`: categorias del catalogo.
- `producto`: productos publicados.
- `inventario`: existencias por producto.
- `carrito`: carrito de compras.
- `item_carrito`: productos agregados al carrito.
- `pedido`: ordenes realizadas por clientes.
- `detalle_pedido`: detalle de productos vendidos.
- `pago`: informacion de pago.
- `envio`: informacion de entrega.

## Scripts incluidos

```text
data/01_datos_iniciales_marketplace.sql
reports/01_reportes_nexus_marketplace.sql
```

## Relacion con MongoDB

MySQL almacena la informacion estructurada y transaccional. MongoDB almacena informacion flexible del catalogo, como resenas, comentarios y especificaciones tecnicas variables.

Esta separacion permite usar cada motor segun el tipo de dato:

- MySQL para integridad referencial, pagos, pedidos e inventario.
- MongoDB para datos semiestructurados que pueden cambiar entre categorias de producto.

