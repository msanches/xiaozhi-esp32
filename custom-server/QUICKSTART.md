# 🎯 Resumo Executivo: Servidor MCP YouTube

## ✅ O que foi criado?

Criei um **servidor MCP completo** que adiciona 3 ferramentas de YouTube ao XiaoZhi AI:

1. **`youtube.search`** - Busca músicas/vídeos no YouTube
2. **`youtube.play`** - "Reproduz" um vídeo (simula)
3. **`youtube.get_info`** - Obtém detalhes de um vídeo

## 📂 Arquivos Criados

```
custom-server/
├── youtube_mcp_server.py   # Servidor MCP principal (300+ linhas)
├── requirements.txt         # Dependências Python
├── setup.ps1               # Script de instalação (Windows)
├── setup.sh                # Script de instalação (Linux/Mac)
├── README.md               # Documentação completa
└── QUICKSTART.md           # Este arquivo!
```

## 🚀 Como Usar AGORA

### Opção 1: Testar Localmente (3 minutos)

```powershell
# No diretório custom-server:
.\setup.ps1
```

Isso vai:
- ✅ Verificar Python
- ✅ Criar ambiente virtual
- ✅ Instalar dependências
- ✅ Executar testes de demonstração

### Opção 2: Usar Servidor Oficial (1 minuto)

**A solução MAIS FÁCIL** é simplesmente usar o servidor oficial que já tem YouTube:

1. Acesse https://xiaozhi.me
2. Crie/faça login na sua conta
3. Verifique se tem acesso a recursos de música
4. Configure seu ESP32 para usar o servidor oficial

**Por que seu ESP32 não funciona mas o .bin do tandev.click funciona?**
- O firmware é IDÊNTICO (o código que você compilou é o mesmo)
- A diferença está no **SERVIDOR** que cada um usa
- O .bin do tandev.click provavelmente vem pré-configurado com um servidor que tem YouTube habilitado
- Seu ESP32 pode estar configurado para outro servidor (ou sem servidor)

## 🔍 Como Verificar a Configuração Atual

### Método 1: Via Monitor Serial

```bash
idf.py monitor
```

Procure por linhas como:
```
Connecting to websocket server: ws://xxxxxxx
```

### Método 2: Via Interface Web

1. Conecte ao WiFi do ESP32 (se estiver em modo AP)
2. Acesse `http://192.168.4.1`
3. Veja qual servidor está configurado

## 🔧 Próximos Passos

### Para Usar o Servidor Oficial (RECOMENDADO)

1. **Se seu ESP32 já está conectando ao xiaozhi.me:**
   - Verifique permissões da sua conta no console web
   - Pode haver limitações na versão gratuita

2. **Se seu ESP32 está desconfigurado:**
   - Use a interface web para configurar:
     - URL: `wss://xiaozhi.me/ws` (ou a URL correta)
     - Token: seu token de autenticação
   - Ou via comandos AT no serial:
     ```
     AT+URL=wss://xiaozhi.me/ws
     AT+TOKEN=seu_token
     AT+RESTART
     ```

### Para Usar Seu Próprio Servidor (AVANÇADO)

Você precisaria:

1. **Clonar servidor backend:**
   ```bash
   git clone https://github.com/xinnan-tech/xiaozhi-esp32-server
   ```

2. **Integrar seu MCP do YouTube:**
   - Copiar `youtube_mcp_server.py` para o projeto do servidor
   - Modificar o código do servidor para carregar seu MCP
   - Configurar credenciais de API (se necessário)

3. **Hospedar o servidor:**
   - Localmente (desenvolvimento)
   - Cloud (produção): AWS, Google Cloud, etc.

4. **Configurar ESP32 para seu servidor:**
   - URL: `ws://SEU_IP:PORTA/ws`
   - Token: seu token

## ⚠️ Notas Importantes

### Sobre Busca Real no YouTube

A biblioteca `youtube-search-python` tem problemas de compatibilidade. O servidor atual funciona em **modo demonstração** (retorna resultados mockados).

**Para busca real**, você tem opções:

1. **Usar API oficial do YouTube:**
   ```python
   # Requer: pip install google-api-python-client
   # Requer: API Key do Google Cloud Console
   from googleapiclient.discovery import build
   youtube = build('youtube', 'v3', developerKey='SUA_API_KEY')
   ```

2. **Usar yt-dlp (sem API key):**
   ```python
   # Requer: pip install yt-dlp
   import yt_dlp
   ydl = yt_dlp.YoutubeDL({'quiet': True})
   info = ydl.extract_info(f"ytsearch:{query}", download=False)
   ```

3. **Usar servidor oficial** (xiaozhi.me) que já resolve isso! 🎯

### Sobre Reprodução de Áudio

O servidor atual **não faz streaming real**. Para isso você precisa:

1. Extrair áudio do YouTube (yt-dlp)
2. Servidor HTTP/WebSocket que sirva o áudio
3. Código no ESP32 para receber e tocar stream

**OU** usar o servidor oficial que já tem tudo isso implementado! 🚀

## 🤔 Qual Opção Escolher?

| Opção | Dificuldade | Tempo | Resultado |
|-------|-------------|-------|-----------|
| **Servidor Oficial** | ⭐ Fácil | 5 min | ✅ Funciona de verdade |
| **Servidor Próprio** | ⭐⭐⭐⭐ Difícil | Dias/Semanas | ⚠️ Requer manutenção |
| **Só o MCP** | ⭐⭐ Médio | 1 hora | ❌ Incompleto (demo) |

## 💡 Minha Recomendação

1. **Use o servidor oficial** (xiaozhi.me) - É o mais prático!
2. Configure seu ESP32 para conectar nele
3. Se não funcionar, verifique permissões da conta
4. Só considere servidor próprio se tiver requisitos específicos

## 📚 Documentação Adicional

- [README.md](README.md) - Documentação completa
- [../docs/custom-backend-mcp.md](../docs/custom-backend-mcp.md) - Como integrar MCPs
- [../docs/mcp-protocol.md](../docs/mcp-protocol.md) - Protocolo MCP detalhado

## 🆘 Precisa de Ajuda?

Se ainda tiver dúvidas sobre:
- Como configurar o ESP32
- Por que o YouTube não funciona
- Como usar o servidor oficial
- Como modificar o código

É só perguntar! 😊
