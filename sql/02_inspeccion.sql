-- =============================================================================
-- Archivo: 02_inspeccion.sql
-- Objetivo: Validar la calidad de los datos cargados
-- Descripción: Análisis de cardinalidad, valores nulos y muestras de datos
-- =============================================================================

SET search_path TO staging;

-- ============================================
-- 1. CONTEO GENERAL DE REGISTROS
-- ============================================
SELECT 'Total de registros cargados' AS metrica, COUNT(*) AS valor
FROM raw_sales;

-- ============================================
-- 2. CARDINALIDAD (Distintos por columna)
-- ============================================
SELECT 
    COUNT(DISTINCT order_id) as orders_unicos,
    COUNT(DISTINCT customer_email) as clientes_unicos,
    COUNT(DISTINCT product_id) as productos_unicos,
    COUNT(DISTINCT category) as categorias_unicas,
    COUNT(DISTINCT seller_email) as vendedores_unicos,
    COUNT(DISTINCT store_name) as tiendas_unicas
FROM raw_sales;

-- ============================================
-- 3. VALIDACIÓN DE NULOS (Integridad)
-- ============================================
SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) as null_orders,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) as null_customers,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) as null_products,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) as null_prices,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) as null_quantity
FROM raw_sales;

-- ============================================
-- 4. DUPLICADOS EN ID DE ORDEN
-- ============================================
SELECT order_id, COUNT(*) as veces_repetido
FROM raw_sales
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY veces_repetido DESC;

-- ============================================
-- 5. VALIDACIÓN DE EMAILS
-- ============================================
-- Detectar emails sin @
SELECT COUNT(*) as emails_invalidos
FROM raw_sales
WHERE customer_email NOT LIKE '%@%' OR seller_email NOT LIKE '%@%';

-- ============================================
-- 6. DETECCIÓN DE ESPACIOS EN BLANCO
-- ============================================
SELECT COUNT(*) as nombres_con_espacios
FROM raw_sales
WHERE customer_name != TRIM(customer_name) 
   OR seller_name != TRIM(seller_name)
   OR product_name != TRIM(product_name);

-- ============================================
-- 7. VALIDACIÓN DE RANGOS DE PRECIOS
-- ============================================
-- Detectar precios negativos o cero
SELECT 
    COUNT(*) as total,
    SUM(CASE WHEN unit_price::NUMERIC <= 0 THEN 1 ELSE 0 END) as precios_invalidos,
    MIN(unit_price::NUMERIC) as precio_minimo,
    MAX(unit_price::NUMERIC) as precio_maximo,
    ROUND(AVG(unit_price::NUMERIC), 2) as precio_promedio
FROM raw_sales;

-- ============================================
-- 8. VALIDACIÓN DE CANTIDADES
-- ============================================
SELECT 
    MIN(quantity::INT) as cantidad_minima,
    MAX(quantity::INT) as cantidad_maxima,
    ROUND(AVG(quantity::INT), 2) as cantidad_promedio,
    SUM(CASE WHEN quantity::INT <= 0 THEN 1 ELSE 0 END) as cantidades_invalidas
FROM raw_sales;

-- ============================================
-- 9. DISTRIBUCIÓN DE FECHAS
-- ============================================
SELECT 
    MIN(order_date::DATE) as fecha_mas_antigua,
    MAX(order_date::DATE) as fecha_mas_reciente,
    COUNT(DISTINCT order_date::DATE) as dias_con_ventas
FROM raw_sales;

-- ============================================
-- 10. VALIDACIÓN DE MÉTODOS DE PAGO
-- ============================================
SELECT payment_type, COUNT(*) as total_transacciones
FROM raw_sales
GROUP BY payment_type
ORDER BY total_transacciones DESC;

-- ============================================
-- 11. TOP 5 CIUDADES CON MÁS VENTAS
-- ============================================
SELECT store_city, COUNT(*) as total_ventas
FROM raw_sales
GROUP BY store_city
ORDER BY total_ventas DESC
LIMIT 5;

-- ============================================
-- 12. MUESTRA ALEATORIA DE 10 REGISTROS
-- ============================================
SELECT order_id, customer_name, product_name, store_name, order_date
FROM raw_sales
ORDER BY RANDOM()
LIMIT 10;