-- =============================================================================
-- Archivo: 07_analisis_negocio.sql
-- Objetivo: Responder preguntas de negocio con SQL avanzado
-- Descripción: Agregaciones, window functions, HAVING y análisis complejos
-- =============================================================================

SET search_path TO core;

-- 1. Total de ventas (dinero) por cada tienda, de mayor a menor.
-- Tip: SUM(cantidad * precio_venta)

SELECT t.nombre, SUM(ov.precio_venta * ov.cantidad) AS Total_Venta
FROM order_venta AS ov
JOIN vendedor AS v ON v.vendedor_id = ov.vendedor_id
JOIN tienda AS t ON t.tienda_id = v.tienda_id
GROUP BY t.nombre
ORDER BY Total_Venta DESC;

-- 2. El Top 5 de clientes que más dinero han gastado en Sodimac.

SELECT c.nombre, SUM(ov.precio_venta * ov.cantidad) AS Total_Venta
FROM order_venta AS ov
JOIN cliente AS c ON c.cliente_id = ov.cliente_id
GROUP BY c.nombre
ORDER BY Total_Venta DESC
LIMIT 5;

-- 3. ¿Cuántas ventas ha realizado cada vendedor? (Nombre del vendedor y conteo)

SELECT v.nombre, COUNT(ov.venta_id) AS ventas
FROM order_venta AS ov
JOIN vendedor AS v ON v.vendedor_id = ov.vendedor_id
GROUP BY v.nombre
ORDER BY ventas DESC;

-- 4. Ticket promedio por ciudad de la tienda.
-- (¿En qué ciudad la gente gasta más por cada compra?)

SELECT t.nombre, ROUND(AVG(precio_venta * cantidad),2) AS venta_promedio
FROM order_venta AS ov
JOIN vendedor AS v ON v.vendedor_id = ov.vendedor_id
JOIN tienda AS t ON t.tienda_id = v.tienda_id
GROUP BY t.nombre
ORDER BY AVG(precio_venta * cantidad) DESC
LIMIT 5;

-- 5. Ventas totales por categoría de producto.

SELECT ca.nombre, COUNT(venta_id) AS Cantidad_Pedidos, SUM(cantidad) AS Suma_Productos, SUM(cantidad * precio_venta) AS Venta_Total
FROM order_venta AS ov
JOIN producto AS pr ON pr.producto_id = ov.producto_id
JOIN categoria AS ca ON ca.categoria_id = pr.categoria_id
GROUP BY ca.nombre
ORDER BY Cantidad_Pedidos DESC;

-- 6. Ranking de métodos de pago: ¿Cuál es el más usado y cuánto dinero recauda cada uno?

SELECT 
    ROW_NUMBER() OVER (ORDER BY SUM(precio_venta * cantidad) DESC) AS ranking,
    tipo_pago, 
    SUM(precio_venta * cantidad) AS dinero_recaudado,
    COUNT(*) AS cantidad_transacciones
FROM order_venta AS ov
GROUP BY tipo_pago
ORDER BY dinero_recaudado DESC;

-- 7. Los "Invisibles": ¿Hay algún producto que NO haya tenido ni una sola venta?
-- Tip: Usa un LEFT JOIN entre producto y order_venta y busca donde la venta sea NULL.

SELECT pr.nombre
FROM producto AS pr
LEFT JOIN order_venta AS ov
ON pr.producto_id = ov.producto_id
WHERE ov.venta_id IS NULL;

-- 8. El filtro del Gerente: Listar las tiendas que hayan vendido más de 100 millones en total.
-- Tip: Aquí es donde usas HAVING después del GROUP BY.

SELECT t.nombre AS tienda, SUM(ov.precio_venta * ov.cantidad) AS Total_Venta
FROM order_venta AS ov
JOIN vendedor AS v ON v.vendedor_id = ov.vendedor_id
JOIN tienda AS t ON t.tienda_id = v.tienda_id
GROUP BY t.nombre
HAVING SUM(ov.precio_venta * ov.cantidad) > 100000000
ORDER BY Total_Venta DESC;

-- 9. Rendimiento por categoría: ¿Cuál es el precio promedio de los productos vendidos en cada categoría?

SELECT 
    ca.nombre, 
    COUNT(venta_id) AS Cantidad_Pedidos, 
    SUM(cantidad) AS Suma_Productos, 
    SUM(cantidad * precio_venta) AS Venta_Total,
    ROUND(AVG(precio_venta), 2) AS Precio_Promedio
FROM order_venta AS ov
JOIN producto AS pr ON pr.producto_id = ov.producto_id
JOIN categoria AS ca ON ca.categoria_id = pr.categoria_id
GROUP BY ca.nombre
ORDER BY Venta_Total DESC;

-- 10. Análisis temporal: ¿Cuántas ventas se hicieron por cada tipo de pago en el último mes registrado?

SELECT tipo_pago, COUNT(*) 
FROM order_venta AS ov
WHERE fecha >=
    (SELECT MAX(fecha) - INTERVAl '1 month' FROM order_venta)
GROUP  BY tipo_pago;