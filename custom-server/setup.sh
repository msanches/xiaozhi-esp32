#!/bin/bash
# Script de Instalação e Teste do Servidor MCP YouTube
# Execute: chmod +x setup.sh && ./setup.sh

echo "🎵 Configurando Servidor MCP YouTube para XiaoZhi AI"
echo "============================================================"

# Verificar Python
echo -e "\n[1/4] Verificando instalação do Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "  ✅ $PYTHON_VERSION"
else
    echo "  ❌ Python 3 não encontrado!"
    echo "  Instale com: sudo apt install python3 python3-venv python3-pip"
    exit 1
fi

# Criar ambiente virtual
echo -e "\n[2/4] Criando ambiente virtual..."
if [ -d "venv" ]; then
    echo "  ℹ️  Ambiente virtual já existe"
else
    python3 -m venv venv
    echo "  ✅ Ambiente virtual criado"
fi

# Ativar ambiente virtual e instalar dependências
echo -e "\n[3/4] Instalando dependências..."
source venv/bin/activate
pip install --quiet --upgrade pip
pip install --quiet -r requirements.txt
echo "  ✅ Dependências instaladas"

# Executar testes
echo -e "\n[4/4] Executando testes..."
echo "============================================================"
python3 youtube_mcp_server.py --test

echo -e "\n============================================================"
echo "✅ Instalação concluída com sucesso!"
echo -e "\nPróximos passos:"
echo "  1. Integrar este servidor com o servidor principal do XiaoZhi"
echo "  2. Ou usar o servidor oficial em https://xiaozhi.me"
echo "  3. Configurar o ESP32 para usar o servidor"
echo -e "\nPara mais informações, leia: README.md"
