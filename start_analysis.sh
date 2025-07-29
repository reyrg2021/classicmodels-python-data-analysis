#!/bin/bash
echo "🚀 Iniciando entorno de análisis..."
conda activate python_dataAnalytics
echo "Ambiente conda activado"
echo " Iniciando Jupyter Lab..."
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
