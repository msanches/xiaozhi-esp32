# Script de Instalação e Teste do Servidor MCP YouTube
# Execute: .\setup.ps1

Write-Host "🎵 Configurando Servidor MCP YouTube para XiaoZhi AI" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Verificar Python
Write-Host "`n[1/4] Verificando instalação do Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "  ✅ $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Python não encontrado!" -ForegroundColor Red
    Write-Host "  Baixe em: https://www.python.org/downloads/" -ForegroundColor Red
    exit 1
}

# Criar ambiente virtual
Write-Host "`n[2/4] Criando ambiente virtual..." -ForegroundColor Yellow
if (Test-Path "venv") {
    Write-Host "  ℹ️  Ambiente virtual já existe" -ForegroundColor Blue
} else {
    python -m venv venv
    Write-Host "  ✅ Ambiente virtual criado" -ForegroundColor Green
}

# Ativar ambiente virtual e instalar dependências
Write-Host "`n[3/4] Instalando dependências..." -ForegroundColor Yellow
& "venv\Scripts\Activate.ps1"
pip install --quiet --upgrade pip
pip install --quiet -r requirements.txt
Write-Host "  ✅ Dependências instaladas" -ForegroundColor Green

# Executar testes
Write-Host "`n[4/4] Executando testes..." -ForegroundColor Yellow
Write-Host "=" * 60 -ForegroundColor Cyan
python youtube_mcp_server.py --test

Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "✅ Instalação concluída com sucesso!" -ForegroundColor Green
Write-Host "`nPróximos passos:" -ForegroundColor Yellow
Write-Host "  1. Integrar este servidor com o servidor principal do XiaoZhi" -ForegroundColor White
Write-Host "  2. Ou usar o servidor oficial em https://xiaozhi.me" -ForegroundColor White
Write-Host "  3. Configurar o ESP32 para usar o servidor" -ForegroundColor White
Write-Host "`nPara mais informações, leia: README.md" -ForegroundColor Cyan
