# Instruções de Uso do Protocolo MCP para Controle IoT

> Este documento apresenta como implementar controle IoT de dispositivos ESP32 baseado no protocolo MCP. Para o fluxo detalhado do protocolo, consulte [`mcp-protocol.md`](./mcp-protocol.md).

## Introdução

MCP (Model Context Protocol) é o protocolo de nova geração recomendado para controle IoT, que descobre e invoca "ferramentas" (Tools) entre backend e dispositivo através do formato padrão JSON-RPC 2.0, implementando controle flexível de dispositivos.

## Fluxo de Uso Típico

1. Após iniciar, o dispositivo estabelece conexão com o backend através do protocolo básico (como WebSocket/MQTT).
2. O backend inicializa a sessão através do método `initialize` do protocolo MCP.
3. O backend obtém todas as ferramentas (funcionalidades) suportadas pelo dispositivo e suas descrições de parâmetros através de `tools/list`.
4. O backend invoca ferramentas específicas através de `tools/call`, realizando o controle do dispositivo.

Para formato detalhado do protocolo e interação, veja [`mcp-protocol.md`](./mcp-protocol.md).

## Descrição do Método de Registro de Ferramentas no Dispositivo

O dispositivo registra "ferramentas" que podem ser invocadas pelo backend através do método `McpServer::AddTool`. Sua assinatura de função comumente usada é a seguinte:

```cpp
void AddTool(
    const std::string& name,           // Nome da ferramenta, recomenda-se único e hierárquico, como self.dog.forward
    const std::string& description,    // Descrição da ferramenta, explicação concisa da funcionalidade para facilitar compreensão do modelo
    const PropertyList& properties,    // Lista de parâmetros de entrada (pode estar vazia), tipos suportados: booleano, inteiro, string
    std::function<ReturnValue(const PropertyList&)> callback // Implementação do callback quando a ferramenta é invocada
);
```
- name: Identificador único da ferramenta, recomenda-se estilo de nomenclatura "módulo.funcionalidade".
- description: Descrição em linguagem natural, facilita compreensão de IA/usuário.
- properties: Lista de parâmetros, tipos suportados são booleano, inteiro, string, pode especificar intervalo e valor padrão.
- callback: Lógica de execução real quando recebe requisição de invocação, valor de retorno pode ser bool/int/string.

## Exemplo Típico de Registro (usando ESP-Hi como exemplo)

```cpp
void InitializeTools() {
    auto& mcp_server = McpServer::GetInstance();
    // Exemplo 1: Sem parâmetros, controla robô para avançar
    mcp_server.AddTool("self.dog.forward", "Robô move para frente", PropertyList(), [this](const PropertyList&) -> ReturnValue {
        servo_dog_ctrl_send(DOG_STATE_FORWARD, NULL);
        return true;
    });
    // Exemplo 2: Com parâmetros, define cor RGB da luz
    mcp_server.AddTool("self.light.set_rgb", "Define cor RGB", PropertyList({
        Property("r", kPropertyTypeInteger, 0, 255),
        Property("g", kPropertyTypeInteger, 0, 255),
        Property("b", kPropertyTypeInteger, 0, 255)
    }), [this](const PropertyList& properties) -> ReturnValue {
        int r = properties["r"].value<int>();
        int g = properties["g"].value<int>();
        int b = properties["b"].value<int>();
        led_on_ = true;
        SetLedColor(r, g, b);
        return true;
    });
}
```

## Exemplos Comuns de Invocação de Ferramenta JSON-RPC

### 1. Obter lista de ferramentas
```json
{
  "jsonrpc": "2.0",
  "method": "tools/list",
  "params": { "cursor": "" },
  "id": 1
}
```

### 2. Controlar chassi para avançar
```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "self.chassis.go_forward",
    "arguments": {}
  },
  "id": 2
}
```

### 3. Alternar modo de iluminação
```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "self.chassis.switch_light_mode",
    "arguments": { "light_mode": 3 }
  },
  "id": 3
}
```

### 4. Inverter câmera
```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "self.camera.set_camera_flipped",
    "arguments": {}
  },
  "id": 4
}
```

## Observações
- Nome da ferramenta, parâmetros e valor de retorno devem estar de acordo com o registro `AddTool` no lado do dispositivo.
- Recomenda-se que todos os novos projetos adotem uniformemente o protocolo MCP para controle IoT.
- Para protocolo detalhado e uso avançado, consulte [`mcp-protocol.md`](./mcp-protocol.md). 