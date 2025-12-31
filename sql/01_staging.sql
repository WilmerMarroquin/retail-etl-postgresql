-- =============================================================================
-- Archivo: 01_staging.sql
-- Objetivo: Crear tabla temporal para cargar datos crudos del CSV
-- Descripción: Tabla espejo con todos los campos en TEXT para importación masiva
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS staging;

-- Establecemos el esquema por defecto para no tener que escribirlo siempre
SET search_path TO staging, public;

-- Borramos la tabla anterior si existía para empezar de cero
DROP TABLE IF EXISTS raw_sales;

-- Definimos la tabla espejo del nuevo CSV
-- Todo como TEXT para asegurar que el COPY 20000 sea exitoso
CREATE TABLE raw_sales (
    order_id         TEXT,
    order_date       TEXT,
    customer_name    TEXT,
    customer_email   TEXT,
    customer_city    TEXT,
    seller_name      TEXT,
    seller_email     TEXT,
    product_id       TEXT,
    product_name     TEXT,
    category         TEXT,
    unit_price       TEXT,
    quantity         TEXT,
    store_name       TEXT,
    store_city       TEXT,
    payment_type     TEXT
);