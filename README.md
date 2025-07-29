#  Análisis ClassicModels - Python & PostgreSQL

Proyecto de análisis de datos usando Python, pandas, PostgreSQL y Docker para el dataset ClassicModels.
##  Configuración Rápida

### Prerrequisitos

-  [Docker](https://docs.docker.com/get-docker/) y Docker Compose
-  [Miniconda/Anaconda](https://docs.conda.io/en/latest/miniconda.html)
-  Git

### Instalación

```bash
# 1. Clonar repositorio
git clone https://github.com/tuusuario/classicmodels-analysis.git
cd classicmodels-analysis

# 2. Ejecutar setup completo
./setup.sh

# 3. Iniciar análisis
./start_analysis.sh
```

##  Estructura del Proyecto

```
classicmodels-analysis/
├──  README.md                     # Este archivo
├──  setup.sh                        # Script de configuración
├──  start_analysis.sh               # Script de inicio rápido
├──  docker-compose.yml              # Configuración Docker
├──  .env                            # Template de configuración
├── classicmodels-env.yml            # Ambiente conda
├──  notebooks/
│   ├──Python_dataAnalytics_rrg.ipynb # Análisis
├──  funciones/
│   ├── funcionesPrueba.py           # Funciones reutilizables
├── data/
│   └── classicmodels.sql            # Dataset SQL
└──python_dataAnalytics.yml          # Ambiente conda
```

##  Ambiente Python

El proyecto usa un ambiente conda minimalista con:

- **Python 3.9**
- **pandas** - Manipulación de datos
- **numpy** - Computación numérica  
- **jupyter/jupyterlab** - Notebooks interactivos
- **psycopg2** - Conector PostgreSQL
- **sqlalchemy** - ORM y conexiones DB
- **matplotlib/seaborn** - Visualización básica

##  Servicios Docker

- **PostgreSQL 15** - Base de datos principal

##  Análisis Realizados

### 1. Análisis Exploratorio
- Estructura de datos y relaciones
- Calidad de datos y valores faltantes
- Estadísticas descriptivas

### 2. Análisis de Ventas 2005
- Top 10 clientes por ventas brutas
- Top 10 productos más vendidos

### 3. Análisis de Clientes
- Clientes activos vs inactivos
- Reportes de actividad

##  Comandos Útiles

```bash
# Gestión del ambiente
conda activate classicmodels         # Activar ambiente
conda deactivate                     # Desactivar ambiente

# Gestión Docker
docker-compose up -d                 # Iniciar servicios
docker-compose down                  # Parar servicios
docker-compose logs -f postgres      # Ver logs PostgreSQL

# Conexión directa a PostgreSQL
psql -h localhost -p 5432 -U postgres -d classicmodels

# Jupyter Lab
jupyter lab                          # Desde ambiente activado
```

##  Funciones Principales

### `funciones.py`

- `leer_tabla(tabla, engine)` - Leer tablas desde PostgreSQL
- `filtrar_por_fechas()` - Filtrado temporal de DataFrames
- `generar_reporte_pivot()` - Reportes agrupados
- `escribir_tabla_bd()` - Escribir DataFrames a PostgreSQL

##  Seguridad

- ✅ Archivo `.env` en `.gitignore`
- ✅ Credenciales nunca en el código
- ✅ Template `.env.example` para nuevos usuarios
- ✅ Validación de credenciales por defecto


## 🐛 Troubleshooting

### Docker no inicia
```bash
# Verificar Docker
docker --version
docker-compose --version

# Limpiar containers
docker-compose down -v
docker system prune -f
```

### Conda no funciona
```bash
# Reinicializar conda
conda init bash
source ~/.bashrc

# Recrear ambiente
conda env remove -n classicmodels
./setup.sh
```

### PostgreSQL no conecta
```bash
# Verificar status
docker-compose ps

# Revisar logs
docker-compose logs postgres

# Verificar puerto
netstat -tulnp | grep 5432
```

## Próximos Pasos

- [ ] Análisis de series temporales
- [ ] Modelos predictivos de ventas
- [ ] Dashboard interactivo con Streamlit
- [ ] Automatización con Apache Airflow

##  Contribuir

1. Fork del proyecto
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Añadir nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

---

**📧 Contacto:** reinierrg.2020@gmail.com 
