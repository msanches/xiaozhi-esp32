# Servidor MCP Customizado com YouTube 🎵

Este servidor adiciona suporte a busca e reprodução de músicas do YouTube para o XiaoZhi AI.

## 🚀 Instalação Rápida

### Windows (PowerShell)

```powershell
# 1. Criar ambiente virtual
cd custom-server
python -m venv venv

# 2. Ativar ambiente virtual
.\venv\Scripts\Activate.ps1

# 3. Instalar dependências
pip install -r requirements.txt
```

### Linux/Mac

```bash
# 1. Criar ambiente virtual
cd custom-server
python3 -m venv venv

# 2. Ativar ambiente virtual
source venv/bin/activate

# 3. Instalar dependências
pip install -r requirements.txt
```

## 🧪 Testando o Servidor

Execute o servidor em modo de teste:

```bash
python youtube_mcp_server.py --test
```

Você verá:
- ✅ Lista de ferramentas disponíveis
- ✅ Teste de busca no YouTube
- ✅ Teste de "reprodução"

## 📡 Integrando com o ESP32

### Opção 1: Usar servidor oficial modificado

O servidor MCP do YouTube precisa ser integrado com o servidor principal do XiaoZhi. Existem dois projetos open source que você pode usar:

**Servidor Python:**
```bash
git clone https://github.com/xinnan-tech/xiaozhi-esp32-server
cd xiaozhi-esp32-server

# Copiar seu servidor MCP
cp ../xiaozhi-esp32/custom-server/youtube_mcp_server.py ./mcp_servers/

# Seguir instruções do README para configurar
```

**Servidor Java:**
```bash
git clone https://github.com/joey-zhou/xiaozhi-esp32-server-java
# Seguir instruções de integração
```

### Opção 2: Usar o servidor oficial xiaozhi.me

O servidor em https://xiaozhi.me já tem suporte a YouTube Music. Você só precisa:

1. Criar conta em https://xiaozhi.me
2. Configurar seu ESP32 para conectar ao servidor oficial
3. Verificar se sua conta tem acesso a recursos de música

## 🔧 Configurando o ESP32

Depois que o servidor estiver rodando, configure o ESP32:

### Via Interface Web (mais fácil)

1. Conecte-se ao WiFi do ESP32 (modo AP)
2. Acesse `http://192.168.4.1`
3. Configure:
   - **SSID WiFi**: sua rede
   - **Senha WiFi**: sua senha
   - **URL do Servidor**: `ws://SEU_IP:SEU_PORTO/ws`
   - **Token**: seu token de autenticação

### Via Monitor Serial

1. Abra o Monitor Serial (115200 baud)
2. Envie comandos AT:
```
AT+URL=ws://192.168.1.100:8080/ws
AT+TOKEN=seu_token_aqui
AT+RESTART
```

## 📋 Ferramentas Disponíveis

### `youtube.search`
Busca vídeos/músicas no YouTube

**Parâmetros:**
- `query` (string, obrigatório): termo de busca
- `max_results` (int, opcional): número de resultados (1-10, padrão: 5)

**Exemplo de uso pela IA:**
```
Usuário: "Procure músicas do Coldplay"
IA: [chama youtube.search com query="Coldplay music"]
```

### `youtube.play`
"Reproduz" um vídeo do YouTube (versão demo)

**Parâmetros:**
- `url` (string, obrigatório): URL do vídeo
- `title` (string, opcional): título do vídeo

**Exemplo:**
```
Usuário: "Toque a primeira música"
IA: [chama youtube.play com url do resultado anterior]
```

### `youtube.get_info`
Obtém informações detalhadas de um vídeo

**Parâmetros:**
- `video_id` (string, obrigatório): ID do vídeo do YouTube

## ⚠️ Limitações Atuais

Este servidor é uma **demonstração**. Para reprodução real de áudio, você precisa adicionar:

1. **Extração de áudio**: usar `yt-dlp` para baixar áudio do YouTube
2. **Streaming de áudio**: servidor HTTP/WebSocket para enviar áudio ao ESP32
3. **Cliente de áudio no ESP32**: código para receber e reproduzir stream

### Exemplo de integração completa:

```python
# Adicionar ao youtube_mcp_server.py
import yt_dlp

async def _youtube_play(self, args: Dict[str, Any]) -> Dict[str, Any]:
    url = args.get("url")
    
    # Extrair áudio
    ydl_opts = {
        'format': 'bestaudio/best',
        'postprocessors': [{
            'key': 'FFmpegExtractAudio',
            'preferredcodec': 'opus',
            'preferredquality': '64',
        }],
    }
    
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(url, download=False)
        audio_url = info['url']
        
        # Enviar URL para ESP32 via WebSocket/MQTT
        await self.send_to_esp32({
            "type": "audio_stream",
            "url": audio_url,
            "title": info['title']
        })
    
    return {"content": [{"type": "text", "text": f"▶️ Tocando: {info['title']}"}]}
```

## 🔗 Recursos Úteis

- **Documentação MCP**: [docs/custom-backend-mcp.md](../docs/custom-backend-mcp.md)
- **Protocolo MCP**: [docs/mcp-protocol.md](../docs/mcp-protocol.md)
- **Servidor Python**: https://github.com/xinnan-tech/xiaozhi-esp32-server
- **Servidor Java**: https://github.com/joey-zhou/xiaozhi-esp32-server-java

## 🐛 Troubleshooting

### Erro: "Módulo 'youtube-search-python' não encontrado"
```bash
pip install youtube-search-python
```

### Erro: "No results found"
- Verifique sua conexão com internet
- Tente outro termo de busca
- O YouTube pode estar bloqueando requisições automatizadas

### ESP32 não conecta ao servidor
- Verifique se o servidor está rodando
- Confirme o IP e porta corretos
- Teste a URL no navegador: `http://SEU_IP:PORTA`
- Veja logs no ESP32: `idf.py monitor`

## 📝 Próximos Passos

1. ✅ Testar o servidor: `python youtube_mcp_server.py --test`
2. 📦 Integrar com servidor principal (Python ou Java)
3. 🔊 Adicionar streaming de áudio real
4. 🔌 Configurar ESP32 para usar seu servidor
5. 🎵 Aproveitar músicas do YouTube!

## 📄 Licença

Este código é fornecido como exemplo educacional. Respeite os Termos de Serviço do YouTube.
