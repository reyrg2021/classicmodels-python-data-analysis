#!/bin/bash
# setup.sh - Configuración completa de entorno Data Science

set -e  # Salir si hay errores

echo "Configurando entorno completo de Data Science..."

# ============================================================================
# VERIFICACIONES PREVIAS
# ============================================================================

echo "Verificando dependencias..."

# Verificar que Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker no está corriendo. Inicia Docker primero."
    exit 1
fi

# Verificar que conda está instalado
if ! command -v conda &> /dev/null; then
    echo "Error: Conda no está instalado. Instala Miniconda/Anaconda primero."
    echo "Descarga desde: https://docs.conda.io/en/latest/miniconda.html"
    exit 1
fi

# Verificar que existe docker-compose.yml
if [ ! -f "docker-compose.yml" ]; then
    echo " Error: No se encontró docker-compose.yml"
    exit 1
fi

echo "Dependencias verificadas"

# ============================================================================
# CONFIGURACIÓN DE ARCHIVOS
# ============================================================================

# Verificar que existe archivo .env
if [ ! -f ".env" ]; then
    echo " Advertencia: No se encontró archivo .env"
    echo "Creando archivo .env básico..."
    cat > .env << EOF
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secure_password_123
POSTGRES_DB=classicmodels
POSTGRES_PORT=5432
POSTGRES_SHARED_BUFFERS=256MB
POSTGRES_EFFECTIVE_CACHE_SIZE=1GB
EOF
    echo "Archivo .env creado"
fi

# Crear environment.yml para conda si no existe
if [ ! -f "python_dataAnalytics.yml" ]; then
    echo "Creando archivo de ambiente conda..."
    cat > python_dataAnalytics.yml << EOF
name: python_dataAnalytics
channels:
  - conda-forge
  - defaults
dependencies:
  - python=3.9
  - numpy
  - pandas
  - jupyter
  - psycopg2
  - sqlalchemy
  - matplotlib
  - seaborn
  - pip
  - pip:
    - jupyterlab
prefix: /opt/conda/envs/python_dataAnalytics
EOF
    echo " Archivo python_dataAnalytics.yml creado"
fi

# ============================================================================
# CONFIGURACIÓN DE AMBIENTE CONDA
# ============================================================================

echo "Configurando ambiente Python..."

# Verificar si el ambiente ya existe
if conda env list | grep -q "python_dataAnalytics"; then
    echo " El ambiente 'python_dataAnalytics' ya existe"
    read -p "¿Deseas recrearlo? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "  Eliminando ambiente existente..."
        conda env remove -n python_dataAnalytics -y
    else
        echo " Usando ambiente existente"
    fi
fi

# Crear ambiente desde archivo yml
if ! conda env list | grep -q "python_dataAnalytics"; then
    echo " Creando ambiente conda desde python_dataAnalytics.yml..."
    conda env create -f python_dataAnalytics.yml
    echo " Ambiente conda creado exitosamente"
fi

# Verificar ambiente
echo " Verificando ambiente conda..."
if conda run -n python_dataAnalytics python -c "import pandas, numpy, psycopg2, sqlalchemy; print(' Paquetes esenciales OK')"; then
    echo " Ambiente conda verificado"
else
    echo " Error en la verificación del ambiente conda"
    exit 1
fi

# ============================================================================
# CONFIGURACIÓN DE DOCKER
# ============================================================================

echo " Configurando servicios Docker..."

# Limpiar contenedores anteriores si existen
echo " Limpiando contenedores anteriores..."
docker-compose down -v 2>/dev/null || true

# Levantar servicios
echo " Levantando servicios..."
docker-compose up -d

# ============================================================================
# VERIFICACIÓN DE POSTGRESQL
# ============================================================================

# Función para verificar si PostgreSQL está listo
wait_for_postgres() {
    echo " Esperando a que PostgreSQL esté listo..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
            echo " PostgreSQL está listo!"
            return 0
        fi
        
        echo " Intento $attempt/$max_attempts - Esperando PostgreSQL..."
        sleep 2
        ((attempt++))
    done
    
    echo " Error: PostgreSQL no respondió después de $max_attempts intentos"
    return 1
}

# Esperar a que PostgreSQL esté listo
if wait_for_postgres; then
    # Verificar que todo funciona
    echo " Verificando conexiones..."
    docker-compose exec postgres psql -U postgres -c "\l"
    
    echo ""
    echo " ¡Entorno completamente configurado!"
    echo ""
    echo " INFORMACIÓN DE CONEXIÓN:"
    echo "    PostgreSQL: psql -h localhost -p 5432 -U postgres -d python_dataAnalytics"
    echo "    Ambiente conda: conda activate python_dataAnalytics"
    echo "    Jupyter Lab: conda activate python_dataAnalytics && jupyter lab"
    echo ""
    echo " COMANDOS ÚTILES:"
    echo "    Gestión Docker: docker-compose logs -f postgres"
    echo "    Reiniciar servicios: docker-compose restart"
    echo "    Parar servicios: docker-compose down"
    echo ""
    echo " PARA EMPEZAR:"
    echo "   1. conda activate python_dataAnalytics"
    echo "   2. jupyter lab"
    echo "   3. ¡Comenzar a analizar datos!"
    
    # Crear script de inicio rápido
    cat > start_analysis.sh << 'EOF'
#!/bin/bash
echo "🚀 Iniciando entorno de análisis..."
conda activate python_dataAnalytics
echo "Ambiente conda activado"
echo " Iniciando Jupyter Lab..."
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
EOF
    
    chmod +x start_analysis.sh
    echo " Script de inicio rápido creado: ./start_analysis.sh"
    
else
    echo " Error en la configuración"
    exit 1
fi