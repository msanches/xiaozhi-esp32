#!/usr/bin/env pwsh
# Script Interativo - Assistente de Configuração YouTube para XiaoZhi AI

Write-Host @"

╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║     🎵  XiaoZhi AI - Assistente YouTube  🎵              ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

Write-Host "Este assistente vai te ajudar a configurar o YouTube no seu XiaoZhi!`n" -ForegroundColor Yellow

# Pergunta 1: Qual é o objetivo?
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "`n[PERGUNTA 1] O que você quer fazer?`n" -ForegroundColor White
Write-Host "  1. Fazer o YouTube funcionar AGORA (mais fácil)" -ForegroundColor Green
Write-Host "  2. Verificar por que não está funcionando (diagnóstico)" -ForegroundColor Yellow
Write-Host "  3. Criar meu próprio servidor (avançado)" -ForegroundColor Red
Write-Host "  4. Apenas testar o servidor MCP (desenvolvimento)" -ForegroundColor Blue
Write-Host ""

$choice = Read-Host "Digite o número da opção"

switch ($choice) {
    "1" {
        Write-Host "`n" + "═" * 60 -ForegroundColor Cyan
        Write-Host "✅ SOLUÇÃO RECOMENDADA: Usar Servidor Oficial" -ForegroundColor Green
        Write-Host "═" * 60 -ForegroundColor Cyan
        
        Write-Host @"

O servidor oficial em https://xiaozhi.me já tem tudo funcionando!

📋 PASSO A PASSO:

1️⃣  Criar conta no xiaozhi.me
   └─ Acesse: https://xiaozhi.me
   └─ Registre-se ou faça login

2️⃣  Anotar suas credenciais
   └─ URL: wss://xiaozhi.me/ws (geralmente)
   └─ Token: copie do console web

3️⃣  Configurar o ESP32

   MÉTODO A: Interface Web (mais fácil)
   ┌────────────────────────────────────────┐
   │ 1. Conecte ao WiFi "XiaoZhi-XXXX"      │
   │ 2. Abra: http://192.168.4.1            │
   │ 3. Configure WiFi + URL + Token        │
   │ 4. Salvar                              │
   └────────────────────────────────────────┘

   MÉTODO B: Monitor Serial
   ┌────────────────────────────────────────┐
   │ idf.py monitor                         │
   │                                        │
   │ Digite:                                │
   │ AT+URL=wss://xiaozhi.me/ws            │
   │ AT+TOKEN=seu_token                    │
   │ AT+RESTART                            │
   └────────────────────────────────────────┘

4️⃣  Testar
   └─ Diga "Olá XiaoZhi"
   └─ Peça "Procure músicas do Coldplay"
   └─ Deve funcionar! 🎉

"@

        Write-Host "Deseja abrir o site xiaozhi.me agora? (S/N): " -NoNewline -ForegroundColor Yellow
        $openSite = Read-Host
        if ($openSite -eq "S" -or $openSite -eq "s") {
            Start-Process "https://xiaozhi.me"
            Write-Host "`n✅ Abrindo xiaozhi.me no navegador..." -ForegroundColor Green
        }
    }
    
    "2" {
        Write-Host "`n" + "═" * 60 -ForegroundColor Cyan
        Write-Host "🔍 DIAGNÓSTICO: Verificar Configuração Atual" -ForegroundColor Yellow
        Write-Host "═" * 60 -ForegroundColor Cyan
        
        Write-Host @"

Vou ajudar você a descobrir qual servidor seu ESP32 está usando.

📋 OPÇÕES:

1️⃣  Usar script automático (requer pyserial)
   └─ python check_esp32_config.py

2️⃣  Verificar manualmente no Monitor Serial
   └─ idf.py monitor
   └─ Procure por: "Connecting to websocket server: ..."

"@

        Write-Host "`nQual opção você prefere?`n" -ForegroundColor White
        Write-Host "  1. Script automático" -ForegroundColor Green
        Write-Host "  2. Monitor serial manual" -ForegroundColor Yellow
        Write-Host ""
        
        $diagChoice = Read-Host "Digite o número"
        
        if ($diagChoice -eq "1") {
            Write-Host "`nVerificando dependências..." -ForegroundColor Yellow
            
            # Verificar se pyserial está instalado
            $pyserialInstalled = python -c "import serial; print('ok')" 2>$null
            
            if ($pyserialInstalled -eq "ok") {
                Write-Host "✅ pyserial instalado`n" -ForegroundColor Green
                Write-Host "Executando script de diagnóstico...`n" -ForegroundColor Cyan
                python check_esp32_config.py
            } else {
                Write-Host "⚠️  pyserial não instalado`n" -ForegroundColor Red
                Write-Host "Instalando pyserial..." -ForegroundColor Yellow
                python -m pip install pyserial
                Write-Host "`n✅ Instalado! Executando script...`n" -ForegroundColor Green
                python check_esp32_config.py
            }
        } else {
            Write-Host "`n📝 Instruções para monitor serial:`n" -ForegroundColor Cyan
            Write-Host "1. Execute: idf.py monitor" -ForegroundColor White
            Write-Host "2. Pressione RESET no ESP32" -ForegroundColor White
            Write-Host "3. Procure por linhas como:" -ForegroundColor White
            Write-Host "   'Connecting to websocket server: ws://...'" -ForegroundColor Gray
            Write-Host "`n4. Anote a URL que aparece" -ForegroundColor White
            Write-Host "`n5. Se for xiaozhi.me → verifique permissões da conta" -ForegroundColor Yellow
            Write-Host "   Se for outro servidor → reconfigure para xiaozhi.me" -ForegroundColor Yellow
        }
    }
    
    "3" {
        Write-Host "`n" + "═" * 60 -ForegroundColor Cyan
        Write-Host "⚠️  AVANÇADO: Criar Servidor Próprio" -ForegroundColor Red
        Write-Host "═" * 60 -ForegroundColor Cyan
        
        Write-Host @"

🚨 ATENÇÃO: Esta é a opção mais difícil!

Você precisará:
  ✅ Conhecimento avançado de Python/Node.js
  ✅ Experiência com servidores web
  ✅ Tempo (dias/semanas de desenvolvimento)
  ✅ Servidor para hospedar (cloud ou local)
  ✅ APIs do YouTube/Google

📚 O que está incluso:
  ✅ Servidor MCP básico (youtube_mcp_server.py)
  ✅ 3 ferramentas: search, play, get_info
  ✅ Modo demonstração funcionando
  ⚠️  Busca real requer API Key do Google
  ⚠️  Streaming requer infraestrutura adicional

"@

        Write-Host "Tem certeza que quer continuar? (S/N): " -NoNewline -ForegroundColor Yellow
        $continue = Read-Host
        
        if ($continue -eq "S" -or $continue -eq "s") {
            Write-Host "`n📖 Leia primeiro:`n" -ForegroundColor Cyan
            Write-Host "  - LEIA-ME.md (guia completo em português)" -ForegroundColor White
            Write-Host "  - README.md (documentação técnica)" -ForegroundColor White
            Write-Host "  - QUICKSTART.md (guia rápido)" -ForegroundColor White
            
            Write-Host "`n🚀 Para começar:`n" -ForegroundColor Cyan
            Write-Host "  1. Execute: .\setup.ps1" -ForegroundColor White
            Write-Host "  2. Teste: python youtube_mcp_server.py --test" -ForegroundColor White
            Write-Host "  3. Leia docs/custom-backend-mcp.md para integração" -ForegroundColor White
            
            Write-Host "`n" + "─" * 60 -ForegroundColor Gray
            Write-Host "⚠️  RECOMENDAÇÃO: A menos que você tenha um motivo específico," -ForegroundColor Yellow
            Write-Host "   é muito mais fácil usar o servidor oficial (Opção 1)!" -ForegroundColor Yellow
            Write-Host "─" * 60 -ForegroundColor Gray
        } else {
            Write-Host "`n✅ Boa decisão! Recomendo usar o servidor oficial (Opção 1)" -ForegroundColor Green
        }
    }
    
    "4" {
        Write-Host "`n" + "═" * 60 -ForegroundColor Cyan
        Write-Host "🧪 TESTE: Servidor MCP de Demonstração" -ForegroundColor Blue
        Write-Host "═" * 60 -ForegroundColor Cyan
        
        Write-Host @"

Vou executar o servidor MCP em modo de teste.

Isso vai:
  ✅ Listar as 3 ferramentas disponíveis
  ✅ Simular busca no YouTube
  ✅ Simular reprodução de música

⚠️ NOTA: É apenas demonstração! Não vai reproduzir música de verdade.

"@

        Write-Host "Pressione Enter para continuar..." -ForegroundColor Yellow
        Read-Host
        
        Write-Host "`nVerificando dependências...`n" -ForegroundColor Cyan
        
        # Verificar youtube-search-python
        $pkgInstalled = python -c "import youtube_search_python; print('ok')" 2>$null
        
        if ($pkgInstalled -ne "ok") {
            Write-Host "📦 Instalando dependências..." -ForegroundColor Yellow
            python -m pip install -q youtube-search-python
        }
        
        Write-Host "🚀 Executando servidor de teste...`n" -ForegroundColor Green
        Write-Host "═" * 60 -ForegroundColor Gray
        
        python youtube_mcp_server.py --test
        
        Write-Host "`n" + "═" * 60 -ForegroundColor Gray
        Write-Host "`n✅ Teste concluído!`n" -ForegroundColor Green
        Write-Host "💡 Para usar em produção, você precisa:" -ForegroundColor Yellow
        Write-Host "   1. Integrar com servidor principal do XiaoZhi" -ForegroundColor White
        Write-Host "   2. Configurar API do YouTube (para busca real)" -ForegroundColor White
        Write-Host "   3. Adicionar streaming de áudio" -ForegroundColor White
        Write-Host "`n   OU usar o servidor oficial que já tem tudo isso! 😉" -ForegroundColor Cyan
    }
    
    default {
        Write-Host "`n❌ Opção inválida!" -ForegroundColor Red
        Write-Host "Execute o script novamente e escolha 1, 2, 3 ou 4." -ForegroundColor Yellow
    }
}

Write-Host "`n" + "═" * 60 -ForegroundColor Cyan
Write-Host "📚 Documentação Completa:" -ForegroundColor White
Write-Host "   - LEIA-ME.md (português, detalhado)" -ForegroundColor Gray
Write-Host "   - QUICKSTART.md (guia rápido)" -ForegroundColor Gray
Write-Host "   - README.md (inglês, técnico)" -ForegroundColor Gray
Write-Host "═" * 60 -ForegroundColor Cyan

Write-Host "`nℹ️  Precisa de mais ajuda? Leia LEIA-ME.md`n" -ForegroundColor Yellow
