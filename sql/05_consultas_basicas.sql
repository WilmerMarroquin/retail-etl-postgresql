-- =============================================================================
-- Archivo: 05_consultas_basicas.sql
-- Objetivo: Practicar consultas SQL fundamentales sobre una sola tabla
-- Descripción: Filtrado, ordenamiento, agregaciones y funciones básicas
-- =============================================================================

SET search_path TO core;

-- 1. Listar todos los productos ordenados por precio de mayor a menor.

SELECT * FROM producto ORDER BY precio_unitario;

-- 2. Obtener los nombres y correos de todos los clientes de la ciudad de 'Bogotá'.

SELECT nombre, ciudad FROM cliente WHERE ciudad = 'Bogotá';

-- 3. Contar cuántas tiendas tiene Sodimac en total.

SELECT COUNT(*) FROM tienda;

-- 4. Listar las 5 ventas más recientes (solo tabla order_venta).

SELECT * FROM order_venta ORDER BY fecha DESC LIMIT 5;

-- 5. Calcular el precio promedio de todos los productos en el catálogo.

SELECT AVG(precio_unitario) AS precio_promedio FROM producto;
SELECT (SUM(precio_unitario)/COUNT(*)) AS precio_promedio FROM producto;

-- 6. Listar los vendedores cuyo nombre comience con la letra 'A'.
-- Tip: Usa el operador LIKE 'A%'.

SELECT * FROM vendedor WHERE nombre LIKE 'A%';

-- 7. Obtener todas las ventas realizadas con el método de pago 'Cash'.

SELECT * FROM order_venta WHERE tipo_pago = 'Cash';

-- 8. Encontrar el producto más caro del inventario (solo el valor del precio).

SELECT precio_unitario FROM producto ORDER BY precio_unitario DESC LIMIT 1;

-- 9. Listar los IDs de los clientes que han comprado más de 3 unidades en una sola transacción.

SELECT cliente_id FROM order_venta WHERE cantidad > 3;

-- 10. Contar cuántas categorías diferentes existen en la tabla categoria.

select distinct COUNT(*) FROM categoria;