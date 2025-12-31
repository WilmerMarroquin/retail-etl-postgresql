# 📊 Retail ETL - Sistema de Ventas

Proyecto ETL completo que simula el sistema de ventas de una cadena de tiendas retail. Implementa un pipeline desde la generación de datos sintéticos hasta el análisis de negocio mediante SQL avanzado.

## 📝 Descripción del Proyecto

Este proyecto demuestra un flujo ETL (Extract, Transform, Load) completo en PostgreSQL:

1. **Generación de datos sintéticos** → 20,000 registros de ventas realistas con Faker
2. **Carga en staging** → Importación del CSV en tabla temporal
3. **Inspección de calidad** → Validación de datos crudos
4. **Normalización** → Migración a modelo relacional (3FN)
5. **Análisis SQL** → Consultas básicas, JOINs y Business Intelligence

### 🎯 Conceptos Aplicados

- ✅ Separación de esquemas (`staging` vs `core`)
- ✅ Normalización de bases de datos (hasta 3FN)
- ✅ Integridad referencial con Foreign Keys
- ✅ Consultas con múltiples JOINs
- ✅ Agregaciones y análisis de negocio
- ✅ Window Functions y CTEs

---

## 🗂️ Modelo de Datos

### Esquema Staging (Temporal)
```
staging.raw_sales
└── Tabla plana con todos los campos como TEXT
```

### Esquema Core (Normalizado - 3FN)

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  categoria  │────<│   producto   │     │   cliente   │
└─────────────┘     └──────────────┘     └─────────────┘
                           │                     │
                           │                     │
                           ▼                     ▼
                    ┌──────────────────────────────────┐
                    │        order_venta (HECHOS)      │
                    └──────────────────────────────────┘
                           │                     
                           ▼                     
                    ┌─────────────┐     ┌─────────────┐
                    │  vendedor   │────<│   tienda    │
                    └─────────────┘     └─────────────┘
```

**Tablas principales:**
- `categoria` - Catálogo de categorías de productos
- `producto` - Catálogo maestro con SKU y precios
- `cliente` - Base de clientes (CRM)
- `tienda` - Puntos de venta físicos
- `vendedor` - Empleados asignados a tiendas
- `order_venta` - Tabla de hechos con transacciones

---

## 🚀 Guía de Inicio Rápido

### Requisitos Previos

- Docker y Docker Compose instalados
- 2GB de espacio en disco
- Puerto 5432 disponible (o configurar otro en `.env`)

### Paso 1: Configurar Variables de Entorno

Crea un archivo `.env` en el directorio del proyecto:

```env
# PostgreSQL Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=tu_password_seguro_aqui
POSTGRES_DB=retail_db
POSTGRES_PORT=5432
```

> ⚠️ **Importante:** Este archivo contiene credenciales y **NO** debe subirse a Git.

### Paso 2: Iniciar PostgreSQL

```bash
# Levantar contenedor de PostgreSQL
docker-compose up -d

# Verificar que esté corriendo
docker ps | grep retail_pg_db
```

### Paso 3: Generar Datos Sintéticos

Utilizamos un contenedor temporal de Python con `Faker` (sin instalar nada en tu máquina):

```bash
docker run --rm \
  -v "$(pwd):/app" \
  -w /app \
  python:3.11-slim \
  sh -c "pip install faker && python scripts/generar_datos.py"
```

**Salida esperada:**
```
✅ Dataset de Ingeniería de Datos generado: 20000 filas.
```

Esto creará el archivo `data/raw_sales_data.csv` con ~20,000 registros.

### Paso 4: Ejecutar Pipeline ETL

Conectarse a PostgreSQL y ejecutar los scripts en orden:

```bash
# Acceder al contenedor
docker exec -it retail_pg_db psql -U postgres -d retail_db
```

Dentro de `psql`:

```sql
-- 1. Crear tabla de staging
\i /sql/01_staging.sql

-- 2. Cargar CSV (bulk load)
COPY staging.raw_sales FROM '/data/raw_sales_data.csv' DELIMITER ',' CSV HEADER;

-- 3. Inspeccionar datos crudos
\i /sql/02_inspeccion.sql

-- 4. Crear modelo normalizado
\i /sql/03_normalizacion.sql

-- 5. Migrar datos de staging a core
\i /sql/04_carga_datos.sql

-- 6. Verificar carga
SELECT COUNT(*) FROM core.order_venta;  -- Debe retornar ~20000
```

---

## 📚 Scripts SQL - Guía de Uso

### 01_staging.sql
**Objetivo:** Crear esquema temporal y tabla plana para ingesta de CSV

```sql
CREATE SCHEMA staging;
CREATE TABLE staging.raw_sales (...);
```

Todos los campos son `TEXT` para evitar errores de tipo durante la carga masiva.

---

### 02_inspeccion.sql
**Objetivo:** Validar calidad de datos antes de normalizar

**12 validaciones incluidas:**
- Conteo total de registros
- Cardinalidad por columna
- Detección de valores NULL
- Duplicados en IDs de orden
- Validación de emails (@)
- Espacios en blanco
- Rangos de precios (min/max/promedio)
- Validación de cantidades
- Distribución de fechas
- Análisis de métodos de pago
- Top 5 ciudades con más ventas
- Muestra aleatoria de datos

---

### 03_normalizacion.sql
**Objetivo:** Diseñar modelo relacional en 3FN

Crea 6 tablas normalizadas:
1. `categoria` - Elimina redundancia transitiva
2. `producto` - Catálogo maestro con FK a categoría
3. `cliente` - Centraliza datos de compradores
4. `tienda` - Puntos de venta
5. `vendedor` - Relación N:1 con tienda
6. `order_venta` - Tabla de hechos con todas las FK

**Características clave:**
- Primary Keys con `SERIAL`
- Foreign Keys con `REFERENCES`
- Constraints `UNIQUE` y `NOT NULL`
- Indexación automática en PKs

---

### 04_carga_datos.sql
**Objetivo:** Migrar datos de `staging` a `core`

**Orden de carga (respeta dependencias):**
```sql
-- Dimensiones sin FK
INSERT INTO categoria ...
INSERT INTO cliente ...
INSERT INTO tienda ...

-- Dimensiones con FK
INSERT INTO producto ...    -- Requiere categoria
INSERT INTO vendedor ...    -- Requiere tienda

-- Tabla de hechos
INSERT INTO order_venta ... -- Requiere todas las anteriores
```

Usa `JOIN` para resolver las claves foráneas desde los campos originales del CSV.

---

### 05_consultas_basicas.sql
**Objetivo:** Practicar SQL sobre una sola tabla

**Conceptos cubiertos:**
- `SELECT`, `WHERE`, `ORDER BY`
- Funciones agregadas: `COUNT()`, `AVG()`, `SUM()`
- Operadores: `LIKE`, `BETWEEN`, `IN`
- `LIMIT` y `DISTINCT`

**Ejemplo:**
```sql
-- Top 5 productos más caros
SELECT nombre, precio_unitario 
FROM producto 
ORDER BY precio_unitario DESC 
LIMIT 5;
```

---

### 06_consultas_join.sql
**Objetivo:** Relacionar múltiples tablas

**Tipos de JOIN practicados:**
- `INNER JOIN` - Registros coincidentes
- `LEFT JOIN` - Incluir registros sin match
- Múltiples JOINs en cascada

**Ejemplo:**
```sql
-- Ventas con datos completos del cliente y producto
SELECT 
    ov.factura,
    ov.fecha,
    c.nombre AS cliente,
    p.nombre AS producto,
    ov.cantidad,
    ov.precio_venta
FROM order_venta ov
JOIN cliente c ON ov.cliente_id = c.cliente_id
JOIN producto p ON ov.producto_id = p.producto_id;
```

---

### 07_analisis_negocio.sql
**Objetivo:** Responder preguntas de negocio con SQL avanzado

**Análisis incluidos:**

1. **Top ventas por tienda**
   ```sql
   SELECT t.nombre, SUM(ov.cantidad * ov.precio_venta) AS total_ventas
   FROM order_venta ov
   JOIN vendedor v ON ov.vendedor_id = v.vendedor_id
   JOIN tienda t ON v.tienda_id = t.tienda_id
   GROUP BY t.nombre
   ORDER BY total_ventas DESC;
   ```

2. **Top 5 clientes VIP**
3. **Rendimiento por vendedor**
4. **Ticket promedio por ciudad**
5. **Ventas por categoría**
6. **Análisis de métodos de pago**
7. **Productos sin ventas** (usando `LEFT JOIN`)
8. **Filtros con `HAVING`**
9. **Análisis de precios por categoría**
10. **Tendencias temporales**

---

### 08_vistas_reportes.sql
**Objetivo:** Crear vistas para simplificar consultas complejas recurrentes

**Vistas incluidas:**

```sql
-- Vista maestra con todas las dimensiones unidas
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
    ov.tipo_pago
FROM order_venta ov
JOIN cliente c ON ov.cliente_id = c.cliente_id
JOIN vendedor v ON ov.vendedor_id = v.vendedor_id
JOIN tienda t ON v.tienda_id = t.tienda_id
JOIN producto p ON ov.producto_id = p.producto_id
JOIN categoria ca ON p.categoria_id = ca.categoria_id;
```

**Beneficios:**
- Consultas simplificadas (un solo SELECT en lugar de múltiples JOINs)
- Reportes rápidos sin repetir código
- Capa de abstracción para análisis de negocio

---

## 🧪 Verificación del Pipeline

Después de ejecutar todos los scripts, verifica la integridad:

```sql
-- 1. Contar registros en cada tabla
SELECT 'categoria' AS tabla, COUNT(*) FROM core.categoria
UNION ALL
SELECT 'producto', COUNT(*) FROM core.producto
UNION ALL
SELECT 'cliente', COUNT(*) FROM core.cliente
UNION ALL
SELECT 'tienda', COUNT(*) FROM core.tienda
UNION ALL
SELECT 'vendedor', COUNT(*) FROM core.vendedor
UNION ALL
SELECT 'order_venta', COUNT(*) FROM core.order_venta;

-- 2. Verificar integridad referencial
SELECT COUNT(*) FROM core.order_venta ov
LEFT JOIN core.cliente c ON ov.cliente_id = c.cliente_id
WHERE c.cliente_id IS NULL;
-- Debe retornar 0
```

---

## 🗃️ Estructura del Proyecto

```
01_Retail_ETL/
├── README.md                 # Este archivo
├── docker-compose.yml        # Configuración de PostgreSQL
├── .env                      # Credenciales (NO incluido en Git)
├── .env.example              # Plantilla de configuración
├── data/
│   └── raw_sales_data.csv    # Generado localmente (NO incluido en Git)
├── scripts/
│   └── generar_datos.py      # Generador de datos sintéticos
└── sql/
    ├── 01_staging.sql        # Creación de tabla temporal
    ├── 02_inspeccion.sql     # Validación de calidad
    ├── 03_normalizacion.sql  # Modelo relacional 3FN
    ├── 04_carga_datos.sql    # Migración staging → core
    ├── 05_consultas_basicas.sql   # SQL nivel 1
    ├── 06_consultas_join.sql      # SQL nivel 2
    ├── 07_analisis_negocio.sql    # SQL nivel 3
    └── 08_vistas_reportes.sql     # Vistas para reportes
```

---

## 🛠️ Comandos Útiles

```bash
# Ver logs del contenedor
docker logs retail_pg_db

# Reiniciar base de datos
docker-compose restart

# Detener servicios
docker-compose down

# Detener y eliminar volúmenes (DESTRUYE DATOS)
docker-compose down -v

# Backup de la base de datos
docker exec retail_pg_db pg_dump -U postgres retail_db > backup.sql

# Restaurar backup
docker exec -i retail_pg_db psql -U postgres retail_db < backup.sql
```

---

## 📊 Datos de Ejemplo

El script `generar_datos.py` crea ventas **realistas** con:

- **20,000 transacciones** con lógica de negocio
- **~100 productos** con nombres específicos (Taladro Premium, Cemento Portland, etc.)
- **10 categorías** reales: Herramientas, Construcción, Pintura, Eléctricos, Plomería, etc.
- **~1,200 clientes** en ciudades colombianas
- **30 tiendas** tipo "Sodimac" en 10 ciudades
- **150 vendedores** asignados a tiendas específicas
- **Precios coherentes** por categoría + descuentos ocasionales (15%)
- **Fechas:** Últimos 2 años
- **Métodos de pago:** Tarjeta Crédito (35%), Débito (25%), Efectivo (15%), otros
- **Lógica:** Clientes compran preferentemente en tiendas de su ciudad (80%)

---

## 🎓 Objetivos de Aprendizaje

Al completar este proyecto habrás practicado:

- ✅ Diseño de esquemas relacionales
- ✅ Normalización de bases de datos (1FN → 3FN)
- ✅ Uso de constraints y llaves foráneas
- ✅ Importación masiva de datos (COPY)
- ✅ Consultas SQL de diferentes niveles
- ✅ Agregaciones y funciones de ventana
- ✅ Análisis de negocio con SQL
- ✅ Uso de Docker para desarrollo local

---

## 🐛 Troubleshooting

### Error: "Permission denied" al generar datos
```bash
# Dar permisos al directorio data
chmod -R 777 data/
```

### Error: "Port 5432 already in use"
Edita el `.env` y cambia `POSTGRES_PORT` a otro valor (ej: 5433).

### Error: "COPY command failed"
Verifica que el archivo CSV exista:
```bash
ls -lh data/raw_sales_data.csv
```

### La carga a `order_venta` falla
Asegúrate de ejecutar los scripts en orden. Las FK requieren que las dimensiones ya existan.

### ❌ Error: `No such file or directory` al ejecutar `\i`
Si intentas ejecutar un script y Postgres dice que no existe, pero tú lo ves en tu carpeta:
1. **Verifica la ruta interna:** Recuerda que dentro de Docker las rutas son las del contenedor. Usa siempre `/sql/nombre_archivo.sql`.
2. **Sincronización de Volúmenes:** Si acabas de crear el archivo o modificar el `docker-compose.yml`, los volúmenes pueden "marearse". Ejecuta el "reinicio de fuerza bruta":
```bash
docker-compose down && docker-compose up -d
```

---

## 📖 Recursos Adicionales

- [PostgreSQL COPY Documentation](https://www.postgresql.org/docs/current/sql-copy.html)
- [Normalization Guide](https://www.postgresql.org/docs/current/ddl-constraints.html)
- [Faker Documentation](https://faker.readthedocs.io/)

---

## 👤 Autor

**Wilmer Marroquín**  
8vo Semestre - Ingeniería Informática

---

## 📅 Última Actualización

Diciembre 2025

---

## 📋 Checklist de Preparación para GitHub

- ✅ Normalización de comentarios en todos los scripts SQL
- ✅ Encabezados consistentes en todos los archivos
- ✅ README.md completo con documentación
- ✅ .env.example como plantilla de configuración
- ✅ .gitignore configurado para excluir datos sensibles
