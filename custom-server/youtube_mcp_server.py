#!/usr/bin/env python3
"""
Servidor MCP Customizado com Suporte ao YouTube
Permite ao XiaoZhi AI buscar e reproduzir músicas do YouTube
"""

import asyncio
import json
import logging
from typing import Any, Dict, List
from dataclasses import dataclass
import sys

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

try:
    from youtubesearchpython import VideosSearch
except ImportError:
    logger.error("Módulo 'youtube-search-python' não encontrado!")
    logger.error("Execute: pip install youtube-search-python")
    sys.exit(1)


@dataclass
class Tool:
    """Representação de uma ferramenta MCP"""
    name: str
    description: str
    input_schema: Dict[str, Any]


class YouTubeMCPServer:
    """Servidor MCP que adiciona ferramentas de YouTube"""
    
    def __init__(self):
        self.tools = self._register_tools()
        self.initialized = False
        
    def _register_tools(self) -> List[Tool]:
        """Registra todas as ferramentas disponíveis"""
        return [
            Tool(
                name="youtube.search",
                description="Busca vídeos/músicas no YouTube. Retorna lista com título, canal e URL.",
                input_schema={
                    "type": "object",
                    "properties": {
                        "query": {
                            "type": "string",
                            "description": "Termo de busca (ex: 'Imagine Dragons Believer')"
                        },
                        "max_results": {
                            "type": "integer",
                            "description": "Número máximo de resultados (1-10)",
                            "default": 5,
                            "minimum": 1,
                            "maximum": 10
                        }
                    },
                    "required": ["query"]
                }
            ),
            Tool(
                name="youtube.play",
                description="'Reproduz' um vídeo do YouTube por URL (simula reprodução)",
                input_schema={
                    "type": "object",
                    "properties": {
                        "url": {
                            "type": "string",
                            "description": "URL do vídeo do YouTube"
                        },
                        "title": {
                            "type": "string",
                            "description": "Título do vídeo (opcional)"
                        }
                    },
                    "required": ["url"]
                }
            ),
            Tool(
                name="youtube.get_info",
                description="Obtém informações detalhadas de um vídeo do YouTube",
                input_schema={
                    "type": "object",
                    "properties": {
                        "video_id": {
                            "type": "string",
                            "description": "ID do vídeo do YouTube (ex: dQw4w9WgXcQ)"
                        }
                    },
                    "required": ["video_id"]
                }
            )
        ]
    
    async def handle_initialize(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Responde à requisição de inicialização"""
        self.initialized = True
        logger.info("Servidor MCP inicializado")
        
        return {
            "protocolVersion": "2024-11-05",
            "capabilities": {
                "tools": {}
            },
            "serverInfo": {
                "name": "youtube-mcp-server",
                "version": "1.0.0"
            }
        }
    
    async def handle_tools_list(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Lista todas as ferramentas disponíveis"""
        tools_list = []
        
        for tool in self.tools:
            tools_list.append({
                "name": tool.name,
                "description": tool.description,
                "inputSchema": tool.input_schema
            })
        
        logger.info(f"Listando {len(tools_list)} ferramentas")
        return {"tools": tools_list}
    
    async def handle_tool_call(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Executa uma ferramenta específica"""
        tool_name = params.get("name")
        arguments = params.get("arguments", {})
        
        logger.info(f"Executando ferramenta: {tool_name} com args: {arguments}")
        
        # Roteamento de ferramentas
        if tool_name == "youtube.search":
            return await self._youtube_search(arguments)
        elif tool_name == "youtube.play":
            return await self._youtube_play(arguments)
        elif tool_name == "youtube.get_info":
            return await self._youtube_get_info(arguments)
        else:
            raise ValueError(f"Ferramenta desconhecida: {tool_name}")
    
    async def _youtube_search(self, args: Dict[str, Any]) -> Dict[str, Any]:
        """Busca vídeos no YouTube"""
        query = args.get("query")
        max_results = args.get("max_results", 5)
        
        logger.info(f"Buscando no YouTube: '{query}' (max: {max_results})")
        
        try:
            # Buscar vídeos
            videos_search = VideosSearch(query, limit=max_results)
            results = videos_search.result()
            
            if not results or "result" not in results:
                return {
                    "content": [{
                        "type": "text",
                        "text": f"❌ Nenhum resultado encontrado para: {query}"
                    }]
                }
            
            # Formatar resultados
            response_text = f"🎵 Encontrei {len(results['result'])} resultados para '{query}':\n\n"
            
            for i, video in enumerate(results['result'], 1):
                title = video.get('title', 'Sem título')
                channel = video.get('channel', {}).get('name', 'Desconhecido')
                duration = video.get('duration', 'N/A')
                views = video.get('viewCount', {}).get('short', 'N/A')
                url = video.get('link', '')
                
                response_text += f"{i}. **{title}**\n"
                response_text += f"   📺 Canal: {channel}\n"
                response_text += f"   ⏱️ Duração: {duration}\n"
                response_text += f"   👁️ Views: {views}\n"
                response_text += f"   🔗 URL: {url}\n\n"
            
            return {
                "content": [{
                    "type": "text",
                    "text": response_text
                }]
            }
            
        except Exception as e:
            logger.error(f"Erro ao buscar no YouTube: {e}")
            return {
                "content": [{
                    "type": "text",
                    "text": f"❌ Erro ao buscar: {str(e)}"
                }]
            }
    
    async def _youtube_play(self, args: Dict[str, Any]) -> Dict[str, Any]:
        """'Reproduz' um vídeo (simulação)"""
        url = args.get("url")
        title = args.get("title", "")
        
        # Em um servidor real, aqui você:
        # 1. Extrairia o áudio do YouTube
        # 2. Faria streaming para o ESP32
        # 3. Ou retornaria URL de audio stream
        
        response = f"▶️ Reproduzindo: {title if title else url}\n\n"
        response += "ℹ️ NOTA: Este é um servidor de demonstração.\n"
        response += "Para reprodução real, você precisará integrar:\n"
        response += "- yt-dlp para extrair áudio\n"
        response += "- Servidor de streaming de áudio\n"
        response += "- Cliente de audio no ESP32"
        
        return {
            "content": [{
                "type": "text",
                "text": response
            }]
        }
    
    async def _youtube_get_info(self, args: Dict[str, Any]) -> Dict[str, Any]:
        """Obtém informações de um vídeo"""
        video_id = args.get("video_id")
        url = f"https://www.youtube.com/watch?v={video_id}"
        
        try:
            videos_search = VideosSearch(video_id, limit=1)
            results = videos_search.result()
            
            if not results or not results.get("result"):
                return {
                    "content": [{
                        "type": "text",
                        "text": f"❌ Vídeo não encontrado: {video_id}"
                    }]
                }
            
            video = results["result"][0]
            
            response = f"📹 **{video.get('title')}**\n\n"
            response += f"📺 Canal: {video.get('channel', {}).get('name')}\n"
            response += f"⏱️ Duração: {video.get('duration')}\n"
            response += f"📅 Publicado: {video.get('publishedTime')}\n"
            response += f"👁️ Views: {video.get('viewCount', {}).get('text')}\n"
            response += f"🔗 URL: {video.get('link')}\n"
            
            return {
                "content": [{
                    "type": "text",
                    "text": response
                }]
            }
            
        except Exception as e:
            logger.error(f"Erro ao obter info: {e}")
            return {
                "content": [{
                    "type": "text",
                    "text": f"❌ Erro: {str(e)}"
                }]
            }
    
    async def handle_request(self, request: Dict[str, Any]) -> Dict[str, Any]:
        """Processa uma requisição JSON-RPC"""
        method = request.get("method")
        params = request.get("params", {})
        request_id = request.get("id")
        
        try:
            # Roteamento de métodos
            if method == "initialize":
                result = await self.handle_initialize(params)
            elif method == "tools/list":
                result = await self.handle_tools_list(params)
            elif method == "tools/call":
                result = await self.handle_tool_call(params)
            else:
                raise ValueError(f"Método desconhecido: {method}")
            
            return {
                "jsonrpc": "2.0",
                "id": request_id,
                "result": result
            }
            
        except Exception as e:
            logger.error(f"Erro ao processar requisição: {e}")
            return {
                "jsonrpc": "2.0",
                "id": request_id,
                "error": {
                    "code": -32603,
                    "message": str(e)
                }
            }


async def run_stdio_server():
    """Executa servidor via STDIO (entrada/saída padrão)"""
    server = YouTubeMCPServer()
    logger.info("🚀 Servidor MCP YouTube iniciado (modo STDIO)")
    
    while True:
        try:
            # Ler linha da entrada padrão
            line = await asyncio.get_event_loop().run_in_executor(
                None, sys.stdin.readline
            )
            
            if not line:
                break
            
            line = line.strip()
            if not line:
                continue
            
            # Parse JSON-RPC
            request = json.loads(line)
            logger.debug(f"Request: {request}")
            
            # Processar requisição
            response = await server.handle_request(request)
            logger.debug(f"Response: {response}")
            
            # Enviar resposta
            print(json.dumps(response), flush=True)
            
        except json.JSONDecodeError as e:
            logger.error(f"Erro ao parsear JSON: {e}")
        except Exception as e:
            logger.error(f"Erro inesperado: {e}")
            break
    
    logger.info("Servidor MCP encerrado")


async def run_test_mode():
    """Modo de teste interativo"""
    server = YouTubeMCPServer()
    logger.info("🧪 Servidor MCP YouTube em modo TESTE")
    logger.info("=" * 50)
    
    # Inicializar
    init_response = await server.handle_initialize({})
    logger.info(f"Inicializado: {init_response}")
    
    # Listar ferramentas
    tools_response = await server.handle_tools_list({})
    logger.info(f"\n📋 Ferramentas disponíveis:")
    for tool in tools_response["tools"]:
        logger.info(f"  - {tool['name']}: {tool['description']}")
    
    # Teste 1: Buscar música
    logger.info("\n" + "=" * 50)
    logger.info("🧪 Teste 1: Buscar 'Imagine Dragons Believer'")
    search_result = await server.handle_tool_call({
        "name": "youtube.search",
        "arguments": {
            "query": "Imagine Dragons Believer",
            "max_results": 3
        }
    })
    print("\n" + search_result["content"][0]["text"])
    
    # Teste 2: 'Reproduzir'
    logger.info("\n" + "=" * 50)
    logger.info("🧪 Teste 2: Reproduzir vídeo")
    play_result = await server.handle_tool_call({
        "name": "youtube.play",
        "arguments": {
            "url": "https://www.youtube.com/watch?v=7wtfhZwyrcc",
            "title": "Imagine Dragons - Believer"
        }
    })
    print("\n" + play_result["content"][0]["text"])
    
    logger.info("\n" + "=" * 50)
    logger.info("✅ Testes concluídos!")


def main():
    """Ponto de entrada principal"""
    if len(sys.argv) > 1 and sys.argv[1] == "--test":
        # Modo de teste
        asyncio.run(run_test_mode())
    else:
        # Modo STDIO (produção)
        asyncio.run(run_stdio_server())


if __name__ == "__main__":
    main()
