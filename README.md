# Um Chatbot Baseado em MCP

## Introdução

👉 [Humano: Dá uma câmera para a IA vs IA: Descobre instantaneamente que o dono não lava o cabelo há três dias【bilibili】](https://www.bilibili.com/video/BV1bpjgzKEhd/)

👉 [Crie sua namorada IA artesanalmente, guia para iniciantes【bilibili】](https://www.bilibili.com/video/BV1XnmFYLEJN/)

Como uma interface de interação por voz, o chatbot XiaoZhi AI utiliza os recursos de IA de grandes modelos como Qwen / DeepSeek e realiza controle multi-terminal por meio do protocolo MCP.

<img src="docs/mcp-based-graph.jpg" alt="Controle tudo via MCP" width="320">

## Notas da Versão

A versão atual v2 é incompatível com a tabela de partições da v1, portanto não é possível atualizar da v1 para a v2 via OTA. Para detalhes sobre a tabela de partições, consulte [partitions/v2/README.md](partitions/v2/README.md).

Todo hardware que executa a v1 pode ser atualizado para a v2 por meio de gravação manual do firmware.

A versão estável da v1 é 1.9.2. Você pode alternar para a v1 executando `git checkout v1`. O branch v1 será mantido até fevereiro de 2026.

### Recursos Implementados

* Wi-Fi / ML307 Cat.1 4G
* Ativação por voz offline [ESP-SR](https://github.com/espressif/esp-sr)
* Suporte a dois protocolos de comunicação ([WebSocket](docs/websocket.md) ou MQTT+UDP)
* Uso do codec de áudio OPUS
* Interação por voz baseada na arquitetura de streaming ASR + LLM + TTS
* Reconhecimento de locutor, identifica o falante atual [3D Speaker](https://github.com/modelscope/3D-Speaker)
* Tela OLED / LCD, com suporte à exibição de emojis
* Exibição de bateria e gerenciamento de energia
* Suporte multilíngue (chinês, inglês, japonês)
* Suporte às plataformas de chip ESP32-C3, ESP32-S3, ESP32-P4
* MCP no lado do dispositivo para controle de hardware (alto-falante, LED, servo, GPIO etc.)
* MCP no lado da nuvem para expandir as capacidades do modelo (controle de casa inteligente, operação de desktop de PC, busca de conhecimento, e-mail etc.)
* Personalização de palavras de ativação, fontes, emojis e planos de fundo do chat com edição online via web ([Custom Assets Generator](https://github.com/78/xiaozhi-assets-generator))

## Hardware

### Prática DIY em Protoboard

Consulte o tutorial no documento Feishu:

👉 ["Enciclopédia do Chatbot XiaoZhi AI"](https://ccnphfhqs21z.feishu.cn/wiki/F5krwD16viZoF0kKkvDcrZNYnhb?from=from_copylink)

Demonstração em protoboard:

![Demonstração em Protoboard](docs/v1/wiring2.jpg)

### Compatível com 70+ Hardwares Open Source (Lista Parcial)

* LiChuang ESP32-S3 Development Board
* Espressif ESP32-S3-BOX3
* M5Stack CoreS3
* M5Stack AtomS3R + Echo Base
* Magic Button 2.4
* Waveshare ESP32-S3-Touch-AMOLED-1.8
* LILYGO T-Circle-S3
* XiaGe Mini C3
* CuiCan AI Pendant
* WMnologo-Xingzhi-1.54TFT
* SenseCAP Watcher
* ESP-HI Low Cost Robot Dog

## Software

### Gravação de Firmware

Para iniciantes, recomenda-se utilizar o firmware que pode ser gravado sem configurar um ambiente de desenvolvimento.

O firmware conecta-se por padrão ao servidor oficial [xiaozhi.me](https://xiaozhi.me). Usuários individuais podem registrar uma conta para usar gratuitamente o modelo em tempo real Qwen.

👉 [Guia para Iniciantes: Gravação de Firmware](https://ccnphfhqs21z.feishu.cn/wiki/Zpz4wXBtdimBrLk25WdcXzxcnNS)

### Ambiente de Desenvolvimento

* Cursor ou VSCode
* Instalar o plugin ESP-IDF, selecionar versão do SDK 5.4 ou superior
* Linux é melhor que Windows para compilação mais rápida e menos problemas de driver
* Este projeto utiliza o padrão de código Google C++, certifique-se de segui-lo ao enviar código

### Documentação para Desenvolvedores

* [Guia de Placa Personalizada](docs/custom-board.md) – Aprenda a criar placas personalizadas para o XiaoZhi AI
* [Uso do Protocolo MCP para Controle IoT](docs/mcp-usage.md) – Aprenda a controlar dispositivos IoT via protocolo MCP
* [Fluxo de Interação do Protocolo MCP](docs/mcp-protocol.md) – Implementação do protocolo MCP no lado do dispositivo
* [Documento do Protocolo de Comunicação Híbrido MQTT + UDP](docs/mqtt-udp.md)
* [Documento detalhado do protocolo de comunicação WebSocket](docs/websocket.md)

## Configuração de Grandes Modelos

Se você já possui um dispositivo XiaoZhi AI conectado ao servidor oficial, pode acessar o console em [xiaozhi.me](https://xiaozhi.me) para configurar.

👉 [Tutorial em Vídeo de Operação do Backend (Interface Antiga)](https://www.bilibili.com/video/BV1jUCUY2EKM/)

## Projetos Open Source Relacionados

Para implantar o servidor em um computador pessoal, consulte os seguintes projetos open source:

* xinnan-tech/xiaozhi-esp32-server (Servidor Python)
* joey-zhou/xiaozhi-esp32-server-java (Servidor Java)
* AnimeAIChat/xiaozhi-server-go (Servidor Golang)
* hackers365/xiaozhi-esp32-server-golang (Servidor Golang)

Outros projetos cliente que utilizam o protocolo de comunicação XiaoZhi:

* huangjunsen0406/py-xiaozhi (Cliente Python)
* TOM88812/xiaozhi-android-client (Cliente Android)
* 100askTeam/xiaozhi-linux (Cliente Linux da 100ask)
* 78/xiaozhi-sf32 (Firmware para chip Bluetooth da Sichuan)
* QuecPython/solution-xiaozhiAI (Firmware QuecPython da Quectel)

Ferramentas para Recursos Personalizados:

* 78/xiaozhi-assets-generator – Gerador de Recursos Personalizados (palavras de ativação, fontes, emojis, planos de fundo)

## Sobre o Projeto

Este é um projeto open source para ESP32, lançado sob a licença MIT, permitindo que qualquer pessoa o utilize gratuitamente, inclusive para fins comerciais.

Esperamos que este projeto ajude todos a compreender o desenvolvimento de hardware com IA e a aplicar rapidamente modelos de linguagem de grande porte em dispositivos físicos reais.

Se você tiver ideias ou sugestões, sinta-se à vontade para abrir uma Issue ou participar do nosso [Discord](https://discord.gg/bXqgAfRm) ou grupo QQ: 994694848

## Histórico de Stars

<a href="https://star-history.com/#78/xiaozhi-esp32&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=78/xiaozhi-esp32&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=78/xiaozhi-esp32&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=78/xiaozhi-esp32&type=Date" />
 </picture>
</a> 
