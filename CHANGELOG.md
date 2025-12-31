# Changelog

Todas las modificaciones importantes a este proyecto se documentarán en este archivo.

## [1.0.0] - Diciembre 2025

### ✅ Completado

#### Scripts SQL
- ✅ `01_staging.sql` - Tabla temporal para ingesta de datos
- ✅ `02_inspeccion.sql` - Validación y profiling de calidad
- ✅ `03_normalizacion.sql` - Diseño de modelo relacional 3FN
- ✅ `04_carga_datos.sql` - ETL: migración staging → core
- ✅ `05_consultas_basicas.sql` - SQL nivel 1 (SELECT, WHERE, etc.)
- ✅ `06_consultas_join.sql` - SQL nivel 2 (INNER/LEFT/RIGHT JOIN)
- ✅ `07_analisis_negocio.sql` - SQL nivel 3 (BI avanzado)

#### Generación de Datos
- ✅ `generar_datos.py` - Script Python con Faker (20K registros)
- ✅ Soporte para Docker (sin dependencias locales)

#### Documentación
- ✅ `README.md` - Guía completa de 400+ líneas
- ✅ `CONTRIBUTING.md` - Normas de contribución
- ✅ `.env.example` - Plantilla de configuración

#### DevOps
- ✅ `docker-compose.yml` - Levantamiento automático de PostgreSQL
- ✅ `.gitignore` - Exclusión de datos sensibles y archivos temporales

### 🎯 Objetivos Cubiertos

- Normalización de comentarios en todos los scripts
- Consistencia de estructura (encabezados, estilos)
- README con documentación profesional
- Preparación para publicación en GitHub

### 📊 Estadísticas

- **20,000** registros de ventas sintéticos
- **7** scripts SQL (1,000+ líneas de código)
- **1** script de generación de datos
- **4** tablas normalizadas + 2 de dimensión
- **9** análisis de negocio implementados

---

## Versionado

Este proyecto sigue [Semantic Versioning](https://semver.org/).

- **MAJOR**: Cambios en estructura de BD o flujo ETL
- **MINOR**: Nuevos análisis o scripts
- **PATCH**: Correcciones menores

