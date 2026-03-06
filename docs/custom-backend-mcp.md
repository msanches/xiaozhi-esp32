# Como Adicionar Servidores MCP Externos ao Backend

Este guia explica como criar um backend customizado que integra múltiplos servidores MCP, incluindo o ESP32 e servidores externos como YouTube Music.

## Arquitetura Proposta

```
┌─────────────────────────────────────────────────┐
│          Backend Customizado (Node.js/Python)   │
│                                                  │
│  ┌──────────────────────────────────────────┐   │
│  │     Cliente MCP Agregador                │   │
│  │  • Descobre ferramentas de todos MCP    │   │
│  │  • Agrega em uma lista unificada        │   │
│  │  • Roteia chamadas para servidor certo  │   │
│  └──────┬────────────────────┬──────────────┘   │
│         │                    │                   │
└─────────┼────────────────────┼───────────────────┘
          │                    │
          v                    v
  ┌───────────────┐    ┌──────────────────┐
  │   ESP32       │    │  Servidor MCP    │
  │  (Servidor    │    │   YouTube        │
  │    MCP)       │    │  (seu servidor)  │
  └───────────────┘    └──────────────────┘
  Ferramentas:         Ferramentas:
  • lamp.turn_on       • youtube.search
  • set_volume         • youtube.play
                       • youtube.pause
```

## Passo 1: Criar Servidor MCP para YouTube

### Python (usando mcp package oficial)

```python
# youtube_mcp_server.py
import asyncio
from mcp.server import Server, NotificationOptions
from mcp.server.models import InitializationOptions
import mcp.server.stdio
import mcp.types as types
from youtube_search import YoutubeSearch  # pip install youtube-search

# Criar servidor MCP
server = Server("youtube-music")

@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    """Lista ferramentas disponíveis"""
    return [
        types.Tool(
            name="youtube.search",
            description="Search for music videos on YouTube",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Search query (e.g., 'Bohemian Rhapsody Queen')"
                    },
                    "max_results": {
                        "type": "integer",
                        "description": "Maximum number of results",
                        "default": 5
                    }
                },
                "required": ["query"]
            }
        ),
        types.Tool(
            name="youtube.play",
            description="Play a YouTube video by URL",
            inputSchema={
                "type": "object",
                "properties": {
                    "url": {
                        "type": "string",
                        "description": "YouTube video URL"
                    }
                },
                "required": ["url"]
            }
        )
    ]

@server.call_tool()
async def handle_call_tool(
    name: str, arguments: dict | None
) -> list[types.TextContent]:
    """Executa ferramenta"""
    
    if name == "youtube.search":
        query = arguments.get("query")
        max_results = arguments.get("max_results", 5)
        
        results = YoutubeSearch(query, max_results=max_results).to_dict()
        
        response = "🎵 Resultados do YouTube:\n\n"
        for i, video in enumerate(results, 1):
            response += f"{i}. {video['title']}\n"
            response += f"   Canal: {video['channel']}\n"
            response += f"   URL: https://youtube.com{video['url_suffix']}\n\n"
        
        return [types.TextContent(type="text", text=response)]
    
    elif name == "youtube.play":
        url = arguments.get("url")
        # Aqui você integraria com um player real
        # Por exemplo, enviar comando para ESP32 via MQTT
        return [types.TextContent(
            type="text",
            text=f"▶️ Tocando: {url}"
        )]
    
    raise ValueError(f"Unknown tool: {name}")

async def main():
    # Executar servidor via stdio
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="youtube-music",
                server_version="0.1.0",
                capabilities=server.get_capabilities(
                    notification_options=NotificationOptions(),
                    experimental_capabilities={},
                )
            )
        )

if __name__ == "__main__":
    asyncio.run(main())
```

### Instalação de Dependências

```bash
pip install mcp youtube-search
```

### Testar o Servidor MCP

```bash
# Executar servidor
python youtube_mcp_server.py

# Em outro terminal, testar com Claude Desktop ou MCP Inspector
```

## Passo 2: Criar Backend Agregador

### Node.js (TypeScript)

```typescript
// backend-aggregator.ts
import { WebSocketServer } from 'ws';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { spawn } from 'child_process';

interface McpTool {
  name: string;
  description: string;
  inputSchema: any;
  source: 'esp32' | 'youtube';
}

class BackendAggregator {
  private esp32Connection: WebSocket | null = null;
  private youtubeClient: Client | null = null;
  private aggregatedTools: McpTool[] = [];

  async initialize() {
    // 1. Conectar ao servidor MCP YouTube (local)
    await this.connectYoutubeServer();
    
    // 2. Aguardar conexão WebSocket do ESP32
    await this.startWebSocketServer();
  }

  async connectYoutubeServer() {
    // Spawn processo do servidor MCP YouTube
    const serverProcess = spawn('python', ['youtube_mcp_server.py']);
    
    // Criar transport stdio
    const transport = new StdioClientTransport({
      command: 'python',
      args: ['youtube_mcp_server.py']
    });

    this.youtubeClient = new Client({
      name: 'backend-aggregator',
      version: '1.0.0'
    }, {
      capabilities: {}
    });

    await this.youtubeClient.connect(transport);
    
    // Descobrir ferramentas do YouTube
    const youtubeTools = await this.youtubeClient.listTools();
    youtubeTools.tools.forEach(tool => {
      this.aggregatedTools.push({
        ...tool,
        source: 'youtube'
      });
    });

    console.log(`✅ YouTube MCP: ${youtubeTools.tools.length} ferramentas`);
  }

  async startWebSocketServer() {
    const wss = new WebSocketServer({ port: 8765 });

    wss.on('connection', (ws) => {
      this.esp32Connection = ws;
      console.log('✅ ESP32 conectado');

      ws.on('message', async (data) => {
        const message = JSON.parse(data.toString());
        
        if (message.type === 'hello') {
          // ESP32 enviou hello
          await this.initializeEsp32Session(ws);
        } else if (message.type === 'mcp') {
          // Processar comando MCP
          await this.handleMcpMessage(ws, message);
        }
      });
    });

    console.log('🚀 WebSocket server rodando na porta 8765');
  }

  async initializeEsp32Session(ws: WebSocket) {
    // Enviar initialize para ESP32
    ws.send(JSON.stringify({
      type: 'mcp',
      session_id: 'session-123',
      payload: {
        jsonrpc: '2.0',
        method: 'initialize',
        params: {
          capabilities: {}
        },
        id: 1
      }
    }));

    // Aguardar resposta e então requisitar ferramentas
    // (simplificado - em produção, usar promises)
    setTimeout(async () => {
      await this.discoverEsp32Tools(ws);
    }, 1000);
  }

  async discoverEsp32Tools(ws: WebSocket) {
    ws.send(JSON.stringify({
      type: 'mcp',
      session_id: 'session-123',
      payload: {
        jsonrpc: '2.0',
        method: 'tools/list',
        params: { cursor: '' },
        id: 2
      }
    }));
  }

  async handleMcpMessage(ws: WebSocket, message: any) {
    const payload = message.payload;
    
    // Se for resposta do tools/list do ESP32
    if (payload.id === 2 && payload.result?.tools) {
      payload.result.tools.forEach((tool: any) => {
        this.aggregatedTools.push({
          name: tool.name,
          description: tool.description,
          inputSchema: tool.inputSchema,
          source: 'esp32'
        });
      });
      
      console.log(`✅ ESP32: ${payload.result.tools.length} ferramentas`);
      console.log(`📦 Total agregado: ${this.aggregatedTools.length} ferramentas`);
      
      // Agora exponha para o LLM via sua API
      this.exposeToLLM();
    }
    
    // Se for uma chamada de ferramenta do LLM
    if (payload.method === 'tools/call') {
      await this.routeToolCall(ws, payload);
    }
  }

  async routeToolCall(ws: WebSocket, payload: any) {
    const toolName = payload.params.name;
    const tool = this.aggregatedTools.find(t => t.name === toolName);
    
    if (!tool) {
      // Ferramenta não encontrada
      ws.send(JSON.stringify({
        type: 'mcp',
        payload: {
          jsonrpc: '2.0',
          id: payload.id,
          error: {
            code: -32601,
            message: `Tool not found: ${toolName}`
          }
        }
      }));
      return;
    }

    // Rotear para o servidor correto
    if (tool.source === 'esp32') {
      // Encaminhar para ESP32
      ws.send(JSON.stringify({
        type: 'mcp',
        session_id: 'session-123',
        payload: payload
      }));
    } else if (tool.source === 'youtube') {
      // Executar no servidor YouTube local
      const result = await this.youtubeClient!.callTool({
        name: toolName,
        arguments: payload.params.arguments
      });
      
      // Enviar resposta de volta
      ws.send(JSON.stringify({
        type: 'mcp',
        payload: {
          jsonrpc: '2.0',
          id: payload.id,
          result: {
            content: result.content,
            isError: false
          }
        }
      }));
    }
  }

  exposeToLLM() {
    // Aqui você criaria uma API REST/GraphQL que o Claude/LLM pode usar
    // Exemplo: GET /api/tools -> retorna this.aggregatedTools
    console.log('🎯 Ferramentas prontas para uso:');
    this.aggregatedTools.forEach(tool => {
      console.log(`  - ${tool.name} [${tool.source}]`);
    });
  }
}

// Iniciar
const backend = new BackendAggregator();
backend.initialize();
```

### Instalação

```bash
npm install ws @modelcontextprotocol/sdk
npm install --save-dev @types/ws typescript
```

## Passo 3: Configurar ESP32 para Conectar ao seu Backend

Modifique a URL OTA no ESP32:

```bash
idf.py menuconfig
# Navigate to: Component config → Xiaozhi Configuration
# Set OTA URL to: http://SEU_SERVIDOR:8765/ota
```

Ou edite `sdkconfig`:

```ini
CONFIG_OTA_URL="http://localhost:8765/ota"
```

## Passo 4: Integrar com Claude/LLM

Use a [Claude Desktop MCP](https://modelcontextprotocol.io/quickstart/user) ou crie uma integração customizada:

```json
// claude_desktop_config.json
{
  "mcpServers": {
    "xiaozhi-aggregator": {
      "command": "node",
      "args": ["backend-aggregator.js"]
    }
  }
}
```

## Resumo

1. **ESP32 (firmware atual)**: Continua sendo servidor MCP expondo ferramentas locais
2. **Servidor MCP YouTube**: Novo servidor Python/Node expondo ferramentas de música
3. **Backend Agregador**: Node.js que conecta ambos e expõe ferramentas unificadas
4. **Claude/LLM**: Usa todas ferramentas através do agregador

## Fontes

- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [Documentação MCP xiaozhi-esp32](./mcp-protocol.md)
