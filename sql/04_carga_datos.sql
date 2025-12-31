-- =============================================================================
-- Archivo: 04_carga_datos.sql
-- Objetivo: Migrar los datos desde staging hacia las tablas normalizadas
-- Descripción: Población de dimensiones y tabla de hechos con validaciones
-- =============================================================================

SET search_path TO core, staging;

-- 1. Limpiar para re-intentar (Opcional, pero recomendado)
TRUNCATE categoria, cliente, tienda, producto, vendedor, order_venta CASCADE;

-- 1.1 CATEGORIA
INSERT INTO categoria (nombre)
SELECT DISTINCT category FROM raw_sales;

-- 1.2 CLIENTE
INSERT INTO cliente (nombre, email, ciudad)
SELECT DISTINCT customer_name, customer_email, customer_city FROM raw_sales;

-- 1.3 TIENDA (Usamos DISTINCT en el par Nombre+Ciudad)
INSERT INTO tienda (nombre, ciudad)
SELECT DISTINCT store_name, store_city FROM raw_sales;

-- 2.1 PRODUCTO
-- Agrupar por product_id y tomar el precio más común (MODE) o el MAX como precio de lista
INSERT INTO producto (sku, nombre, precio_unitario, categoria_id)
SELECT 
    rs.product_id,
    MAX(rs.product_name) as product_name,  -- Tomar uno (todos deberían ser iguales)
    MAX(rs.unit_price::NUMERIC) as unit_price,  -- Precio de lista (el más alto)
    MAX(c.categoria_id) as categoria_id
FROM staging.raw_sales rs
JOIN core.categoria c ON rs.category = c.nombre
GROUP BY rs.product_id;

-- 2.2 VENDEDOR (CORREGIDO: Join por nombre Y ciudad)
INSERT INTO vendedor (nombre, email, tienda_id)
SELECT DISTINCT
    rs.seller_name,
    rs.seller_email,
    t.tienda_id
FROM staging.raw_sales rs
JOIN core.tienda t ON rs.store_name = t.nombre AND rs.store_city = t.ciudad; -- Cruce exacto

-- 3.1 ORDER_VENTA (CORREGIDO: Alias y llaves)
INSERT INTO order_venta (factura, fecha, cliente_id, vendedor_id, producto_id, cantidad, precio_venta, tipo_pago)
SELECT
    rs.order_id,
    rs.order_date::DATE,
    c.cliente_id,
    v.vendedor_id,
    p.producto_id,
    rs.quantity::INT,
    rs.unit_price::NUMERIC,
    rs.payment_type
FROM staging.raw_sales rs
JOIN core.cliente c ON rs.customer_email = c.email -- Antes tenías un alias 't' equivocado
JOIN core.vendedor v ON rs.seller_email = v.email
JOIN core.producto p ON rs.product_id = p.sku;