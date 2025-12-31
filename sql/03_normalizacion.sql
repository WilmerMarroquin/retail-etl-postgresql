-- =============================================================================
-- Archivo: 03_normalizacion.sql
-- Objetivo: Diseñar el modelo de datos relacional normalizado (3FN)
-- Descripción: Creación de 6 tablas normalizadas con sus relaciones y constraints
-- =============================================================================

-- 1. Aislamiento de Entornos
-- Creamos el esquema 'core' para proteger los datos procesados de los crudos
CREATE SCHEMA IF NOT EXISTS core;
SET search_path TO core, staging;

-- 2. TABLA: CATEGORIA
-- Nivel de normalización: Elimina redundancia transitiva de productos
DROP TABLE IF EXISTS categoria CASCADE;
CREATE TABLE categoria (
    categoria_id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL -- UK para evitar duplicados en el catálogo
);

-- 3. TABLA: PRODUCTO
-- Almacena el catálogo maestro. El SKU permite trazabilidad con sistemas externos
DROP TABLE IF EXISTS producto CASCADE;
CREATE TABLE producto (
    producto_id SERIAL PRIMARY KEY,
    sku TEXT UNIQUE NOT NULL,       -- El 'product_id' original del CSV
    nombre TEXT NOT NULL,
    precio_unitario NUMERIC NOT NULL, -- Precio de lista (referencial)
    categoria_id INT REFERENCES categoria(categoria_id)
);

-- 4. TABLA: CLIENTE
-- Centraliza la información de compradores para análisis de recurrencia (CRM)
DROP TABLE IF EXISTS cliente CASCADE;
CREATE TABLE cliente (
    cliente_id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,     -- El email actúa como llave natural de negocio
    ciudad TEXT NOT NULL
);

-- 5. TABLA: TIENDA
-- Representa los puntos físicos de venta de Sodimac
DROP TABLE IF EXISTS tienda CASCADE;
CREATE TABLE tienda (
    tienda_id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    ciudad TEXT NOT NULL
);

-- 6. TABLA: VENDEDOR
-- Relación 1:N con Tienda. Un vendedor pertenece a una única sucursal
DROP TABLE IF EXISTS vendedor CASCADE;
CREATE TABLE vendedor (
    vendedor_id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    tienda_id INT REFERENCES tienda(tienda_id)
);

-- 7. TABLA DE HECHOS: ORDER_VENTA
-- Registra la transacción final. Une todas las dimensiones anteriores
DROP TABLE IF EXISTS order_venta CASCADE;
CREATE TABLE order_venta (
    venta_id SERIAL PRIMARY KEY,
    factura TEXT UNIQUE NOT NULL,    -- El 'order_id' del CSV (ORD-XXXXXX)
    fecha DATE NOT NULL,            -- Solo fecha (YYYY-MM-DD) para eficiencia
    cliente_id INT REFERENCES cliente(cliente_id),
    vendedor_id INT REFERENCES vendedor(vendedor_id),
    producto_id INT REFERENCES producto(producto_id),
    cantidad INT NOT NULL,
    precio_venta NUMERIC NOT NULL,   -- PRECIO HISTÓRICO: El valor real pagado
    tipo_pago TEXT NOT NULL
);