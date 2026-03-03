# Script para build com configuração 4MB
$ErrorActionPreference = "Stop"

# Configurar ambiente ESP-IDF
$env:IDF_PATH = "D:\Espressif\frameworks\esp-idf-v5.5.3"
$env:IDF_TOOLS_PATH = "D:\Espressif"

# Executar export.ps1 para configurar ambiente
& "D:\Espressif\frameworks\esp-idf-v5.5.3\export.ps1"

# Ir para diretório do projeto
cd D:\xiaozhi-esp32

# Executar build
idf.py build
