#!/bin/bash
# =============================================================================
# Retail ETL - Quick Start Script
# Automatiza el setup inicial del proyecto
# =============================================================================

set -e  # Exit on error

echo "🚀 Iniciando Retail ETL Setup..."
echo ""

# 1. Verificar Docker
echo "✓ Verificando Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no instalado. Por favor instala Docker primero."
    exit 1
fi

# 2. Crear .env si no existe
echo "✓ Configurando variables de entorno..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "  ℹ️  Archivo .env creado desde .env.example"
    echo "  ⚠️  Edita .env con tus credenciales si es necesario"
fi

# 3. Levantar PostgreSQL
echo "✓ Iniciando PostgreSQL en Docker..."
docker-compose up -d
echo "  ✅ PostgreSQL está corriendo"

# 4. Generar datos sintéticos
echo "✓ Generando datos sintéticos (20,000 registros)..."
docker run --rm \
  -v "$(pwd):/app" \
  -w /app \
  python:3.11-slim \
  sh -c "pip install faker -q && python scripts/generar_datos.py" 2>/dev/null || \
  echo "  ⚠️  Error en generación de datos (verifica scripts/generar_datos.py)"

# 5. Resumen
echo ""
echo "=========================================="
echo "✅ Setup completado"
echo "=========================================="
echo ""
echo "🔗 Conexión a la BD:"
echo "   docker exec -it retail_pg_db psql -U postgres -d retail_db"
echo ""
echo "📝 Próximos pasos:"
echo "   1. Abre psql (comando anterior)"
echo "   2. Ejecuta los scripts en orden:"
echo "      \\i /sql/01_staging.sql"
echo "      COPY staging.raw_sales FROM '/data/raw_sales_data.csv' DELIMITER ',' CSV HEADER;"
echo "      \\i /sql/02_inspeccion.sql"
echo "      \\i /sql/03_normalizacion.sql"
echo "      \\i /sql/04_carga_datos.sql"
echo ""
echo "🆘 Ayuda:"
echo "   - Ver logs: docker logs retail_pg_db"
echo "   - Detener: docker-compose down"
echo "   - Reiniciar: docker-compose restart"
echo ""
