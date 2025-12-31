-- =============================================================================
-- Archivo: 08_vistas_reportes.sql
-- Objetivo: Crear vistas para simplificar consultas complejas recurrentes
-- Descripción: Vistas materializadas y reportes predefinidos para análisis
-- =============================================================================

SET search_path TO core;

-- 1. Vista Maestro de Ventas (view_order_details)
-- Objetivo: Una tabla virtual que una TODO (Cliente, Vendedor, Tienda, Producto).
-- Para que el usuario solo haga: SELECT * FROM view_order_details;

CREATE OR REPLACE VIEW view_order_details AS
SELECT 
    ov.factura,
    ov.fecha,
    c.nombre AS cliente,
    v.nombre AS vendedor,
    t.nombre AS tienda,
    p.nombre AS producto,
    ca.nombre AS categoria,
    ov.cantidad,
    ov.precio_venta,
    (ov.cantidad * ov.precio_venta) AS subtotal_venta
FROM order_venta ov
JOIN cliente c ON ov.cliente_id = c.cliente_id
JOIN vendedor v ON ov.vendedor_id = v.vendedor_id
JOIN tienda t ON v.tienda_id = t.tienda_id
JOIN producto p ON ov.producto_id = p.producto_id
JOIN categoria ca ON p.categoria_id = ca.categoria_id;       

-- 2. Vista de Resumen por Tienda (view_store_performance)
-- Objetivo: Mostrar nombre de tienda, ciudad, total vendido y ticket promedio.
-- Útil para ver qué ciudades rinden mejor sin escribir el GROUP BY cada vez.

CREATE OR REPLACE VIEW view_store_performance AS
SELECT
    t.nombre,
    t.ciudad,
    SUM(ov.cantidad * ov.precio_venta) AS total_vendido,
    ROUND(AVG(ov.cantidad * ov.precio_venta),2) AS promedio_ticker
FROM order_venta AS ov
JOIN vendedor AS v ON ov.vendedor_id = v.vendedor_id
JOIN tienda t ON v.tienda_id = t.tienda_id
GROUP BY t.nombre, t.ciudad;

-- 3. Vista de Inventario Crítico (view_low_performance_products)
-- Objetivo: Listar productos que han vendido menos de 5 unidades en total.
-- (Ayuda a toma de decisiones sobre qué productos sacar del catálogo).

CREATE OR REPLACE VIEW view_low_performance_products AS
SELECT 
    p.nombre AS producto,
    p.sku,
    COALESCE(SUM(ov.cantidad), 0) AS unidades_vendidas
FROM producto p
LEFT JOIN order_venta ov ON p.producto_id = ov.producto_id
GROUP BY p.nombre, p.sku
HAVING COALESCE(SUM(ov.cantidad), 0) < 5
ORDER BY unidades_vendidas ASC;

-- 4. Vista de Clientes VIP (view_vip_customers)
-- Objetivo: Clientes que han realizado más de 3 compras o gastado más de 5 millones.

CREATE OR REPLACE VIEW view_vip_customers AS
SELECT 
    c.nombre,
    c.email,
    c.ciudad,
    COUNT(ov.venta_id) AS total_compras,
    SUM(ov.cantidad * ov.precio_venta) AS inversion_total
FROM cliente c
JOIN order_venta ov ON c.cliente_id = ov.cliente_id
GROUP BY c.nombre, c.email, c.ciudad
HAVING COUNT(ov.venta_id) > 3
ORDER BY inversion_total DESC;

-- 5. VISTA MATERIALIZADA: Top 10 Productos Estrella (mview_top_products)
-- Objetivo: Guardar físicamente en disco los productos más vendidos.
-- Tip: Al ser materializada, recuerda que se crea con CREATE MATERIALIZED VIEW.

CREATE MATERIALIZED VIEW mview_top_products AS
SELECT 
    p.nombre,
    ca.nombre AS categoria,
    SUM(ov.cantidad) AS total_unidades,
    SUM(ov.cantidad * ov.precio_venta) AS ingresos_totales
FROM order_venta ov
JOIN producto p ON ov.producto_id = p.producto_id
JOIN categoria ca ON p.categoria_id = ca.categoria_id
GROUP BY p.nombre, ca.nombre
ORDER BY total_unidades DESC
LIMIT 10;