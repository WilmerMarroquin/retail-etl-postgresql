-- =============================================================================
-- Archivo: 06_consultas_join.sql
-- Objetivo: Practicar relaciones entre tablas usando JOINs
-- Descripción: Consultas con INNER, LEFT y RIGHT JOIN entre dimensiones y hechos
-- =============================================================================

SET search_path TO core, staging;

-- 1. Ventas con nombre de Cliente
-- Objetivo: Mostrar factura, fecha y el nombre del cliente que hizo la compra.
-- Tip: Debes unir 'order_venta' con 'cliente' usando 'id_cliente'.

SELECT ov.factura, ov.fecha, cl.nombre
FROM order_venta AS ov
JOIN cliente AS cl ON ov.cliente_id = cl.cliente_id
ORDER BY ov.fecha DESC;

-- 2. Productos y su Categoría
-- Objetivo: Listar todos los productos (nombre y precio) junto al nombre de su categoría.
-- Tip: Une 'producto' con 'categoria' usando 'categoria_id'.

SELECT pr.nombre, pr.precio_unitario, ct.nombre
FROM producto AS pr
JOIN categoria AS ct ON pr.categoria_id = ct.categoria_id
ORDER BY ct.nombre ASC;

-- 3. Ventas por Vendedor
-- Objetivo: Mostrar el número de factura y el nombre completo del vendedor que la realizó.
-- Tip: Une 'order_venta' con 'vendedor' usando 'id_vendedor'.

SELECT v.nombre AS vendedor, ov.factura
FROM vendedor AS v
JOIN order_venta AS ov ON v.vendedor_id = ov.vendedor_id
ORDER BY v.nombre ASC;

-- 4. ¿En qué tienda se vendió? (Doble JOIN)
-- Objetivo: Listar la factura y el nombre de la TIENDA donde se realizó la venta.
-- Tip: 'order_venta' no tiene tienda_id. Debes saltar:
--      order_venta -> vendedor (por id_vendedor)
--      luego vendedor -> tienda (por tienda_id).

SELECT t.nombre AS tienda, ov.factura
FROM tienda AS t
JOIN vendedor AS v ON t.tienda_id = v.tienda_id
JOIN order_venta AS ov ON v.vendedor_id = ov.vendedor_id
ORDER BY t.nombre ASC;

-- 5. Catálogo Maestro Detallado
-- Objetivo: SKU, nombre del producto, nombre de la categoría y el precio base.

SELECT pr.sku AS SKU, pr.nombre AS "nombre producto", ct.nombre AS categoria, pr.precio_unitario AS "precio base"
FROM producto AS pr
JOIN categoria AS ct ON pr.categoria_id = ct.categoria_id
ORDER BY categoria ASC;

-- 6. Clientes y sus métodos de pago
-- Objetivo: Nombre del cliente y qué método de pago usó (tipo_pago).

SELECT DISTINCT cl.nombre AS cliente, ov.tipo_pago
FROM cliente AS cl
JOIN order_venta AS ov ON ov.cliente_id = cl.cliente_id
ORDER BY cl.nombre;

-- 7. Ubicación de ventas
-- Objetivo: Número de factura y la CIUDAD de la tienda donde se vendió.
-- Tip: Similar al punto 4, necesitas llegar hasta la tabla 'tienda'.

SELECT t.ciudad AS tienda, ov.factura
FROM tienda AS t
JOIN vendedor AS v ON t.tienda_id = v.tienda_id
JOIN order_venta AS ov ON v.vendedor_id = ov.vendedor_id
ORDER BY t.ciudad ASC;

-- 8. Detalle de productos vendidos
-- Objetivo: Listar la factura y el nombre del producto vendido en esa transacción.

SELECT ov.factura, pr.nombre
FROM order_venta AS ov
JOIN producto AS pr ON ov.producto_id = pr.producto_id
ORDER BY ov.factura ASC;

-- 9. Vendedores y sus ciudades
-- Objetivo: Nombre del vendedor y la ciudad de la tienda a la que pertenece.

SELECT v.nombre, t.ciudad
FROM vendedor v
JOIN tienda t ON v.tienda_id = t.tienda_id
ORDER BY t.ciudad ASC;

-- 10. Listado de Clientes y sus Ciudades
-- Objetivo: Muestra la factura, el nombre del cliente y la ciudad DONDE VIVE el cliente.
-- (No confundir con la ciudad de la tienda).

SELECT ov.factura, c.nombre, c.ciudad
FROM order_venta ov
JOIN cliente c ON ov.cliente_id = c.cliente_id
ORDER BY c.ciudad ASC;