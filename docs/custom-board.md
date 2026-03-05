# Guia de Placa Personalizada 

Este guia apresenta como personalizar um novo programa de inicialização de placa para o projeto de robô de conversação por voz com IA Xiaozhi. O Xiaozhi AI suporta mais de 70 tipos de placas de desenvolvimento da série ESP32, com o código de inicialização de cada placa localizado no diretório correspondente.

## Aviso Importante

> **Atenção**: Para placas personalizadas, quando a configuração de IO for diferente da placa original, NUNCA sobrescreva diretamente a configuração da placa original para compilar o firmware. Você DEVE criar um novo tipo de placa, ou diferenciá-la através das configurações de name e definições de macro sdkconfig no arquivo config.json. Use `python scripts/release.py [nome-do-diretório-da-placa]` para compilar e empacotar o firmware.
>
> Se você sobrescrever diretamente a configuração original, durante futuras atualizações OTA, seu firmware personalizado poderá ser substituído pelo firmware padrão da placa original, fazendo com que seu dispositivo não funcione corretamente. Cada placa tem um identificador único e um canal de atualização de firmware correspondente, manter a unicidade do identificador da placa é muito importante.

## Estrutura de Diretórios

A estrutura de diretórios de cada placa geralmente contém os seguintes arquivos:

- `xxx_board.cc` - Código principal de inicialização da placa, implementa a inicialização e funcionalidades relacionadas à placa
- `config.h` - Arquivo de configuração da placa, define o mapeamento de pinos de hardware e outros itens de configuração
- `config.json` - Configuração de compilação, especifica o chip alvo e opções especiais de compilação
- `README.md` - Documento de instruções relacionado à placa de desenvolvimento

## Passos para Personalizar uma Placa

### 1. Criar um Novo Diretório de Placa

Primeiro, crie um novo diretório no diretório `boards/`, o nome deve usar o formato `[marca]-[tipo-de-placa]`, por exemplo `m5stack-tab5`:

```bash
mkdir main/boards/my-custom-board
```

### 2. Criar Arquivos de Configuração

#### config.h

No `config.h` defina todas as configurações de hardware, incluindo:

- Taxa de amostragem de áudio e configuração de pinos I2S
- Endereço do chip de codec de áudio e configuração de pinos I2C
- Configuração de pinos de botões e LEDs
- Parâmetros da tela e configuração de pinos

Exemplo de referência (de lichuang-c3-dev):

```c
#ifndef _BOARD_CONFIG_H_
#define _BOARD_CONFIG_H_

#include <driver/gpio.h>

// Configuração de áudio
#define AUDIO_INPUT_SAMPLE_RATE  24000
#define AUDIO_OUTPUT_SAMPLE_RATE 24000

#define AUDIO_I2S_GPIO_MCLK GPIO_NUM_10
#define AUDIO_I2S_GPIO_WS   GPIO_NUM_12
#define AUDIO_I2S_GPIO_BCLK GPIO_NUM_8
#define AUDIO_I2S_GPIO_DIN  GPIO_NUM_7
#define AUDIO_I2S_GPIO_DOUT GPIO_NUM_11

#define AUDIO_CODEC_PA_PIN       GPIO_NUM_13
#define AUDIO_CODEC_I2C_SDA_PIN  GPIO_NUM_0
#define AUDIO_CODEC_I2C_SCL_PIN  GPIO_NUM_1
#define AUDIO_CODEC_ES8311_ADDR  ES8311_CODEC_DEFAULT_ADDR

// Configuração de botões
#define BOOT_BUTTON_GPIO        GPIO_NUM_9

// Configuração da tela
#define DISPLAY_SPI_SCK_PIN     GPIO_NUM_3
#define DISPLAY_SPI_MOSI_PIN    GPIO_NUM_5
#define DISPLAY_DC_PIN          GPIO_NUM_6
#define DISPLAY_SPI_CS_PIN      GPIO_NUM_4

#define DISPLAY_WIDTH   320
#define DISPLAY_HEIGHT  240
#define DISPLAY_MIRROR_X true
#define DISPLAY_MIRROR_Y false
#define DISPLAY_SWAP_XY true

#define DISPLAY_OFFSET_X  0
#define DISPLAY_OFFSET_Y  0

#define DISPLAY_BACKLIGHT_PIN GPIO_NUM_2
#define DISPLAY_BACKLIGHT_OUTPUT_INVERT true

#endif // _BOARD_CONFIG_H_
```

#### config.json

No `config.json` defina a configuração de compilação, este arquivo é usado para compilação automatizada pelo script `scripts/release.py`:

```json
{
    "target": "esp32s3",  // Modelo do chip alvo: esp32, esp32s3, esp32c3, esp32c6, esp32p4 etc
    "builds": [
        {
            "name": "my-custom-board",  // Nome da placa de desenvolvimento, usado para gerar o pacote de firmware
            "sdkconfig_append": [
                // Configuração específica de tamanho de Flash
                "CONFIG_ESPTOOLPY_FLASHSIZE_8MB=y",
                // Configuração específica de tabela de partições
                "CONFIG_PARTITION_TABLE_CUSTOM_FILENAME=\"partitions/v2/8m.csv\""
            ]
        }
    ]
}
```

**Descrição dos itens de configuração:**
- `target`: Modelo do chip alvo, deve corresponder ao hardware
- `name`: Nome do pacote de firmware de saída da compilação, recomenda-se que seja consistente com o nome do diretório
- `sdkconfig_append`: Array de itens de configuração sdkconfig adicionais, serão anexados à configuração padrão

**Configurações sdkconfig_append comumente usadas:**
```json
// Tamanho da Flash
"CONFIG_ESPTOOLPY_FLASHSIZE_4MB=y"   // Flash de 4MB
"CONFIG_ESPTOOLPY_FLASHSIZE_8MB=y"   // Flash de 8MB
"CONFIG_ESPTOOLPY_FLASHSIZE_16MB=y"  // Flash de 16MB

// Tabela de partições
"CONFIG_PARTITION_TABLE_CUSTOM_FILENAME=\"partitions/v2/4m.csv\""  // Tabela de partições de 4MB
"CONFIG_PARTITION_TABLE_CUSTOM_FILENAME=\"partitions/v2/8m.csv\""  // Tabela de partições de 8MB
"CONFIG_PARTITION_TABLE_CUSTOM_FILENAME=\"partitions/v2/16m.csv\"" // Tabela de partições de 16MB

// Configuração de idioma
"CONFIG_LANGUAGE_EN_US=y"  // Inglês
"CONFIG_LANGUAGE_ZH_CN=y"  // Chinês Simplificado

// Configuração de palavra de ativação
"CONFIG_USE_DEVICE_AEC=y"          // Habilitar AEC no dispositivo
"CONFIG_WAKE_WORD_DISABLED=y"      // Desabilitar palavra de ativação
```

### 3. Escrever Código de Inicialização da Placa

Crie um arquivo `my_custom_board.cc`, implementando toda a lógica de inicialização da placa de desenvolvimento.

Uma definição básica de classe de placa de desenvolvimento contém as seguintes partes:

1. **Definição de classe**: Herda de `WifiBoard` ou `Ml307Board`
2. **Funções de inicialização**: Incluindo inicialização de componentes como I2C, tela, botões, IoT etc
3. **Sobrescrita de funções virtuais**: Como `GetAudioCodec()`, `GetDisplay()`, `GetBacklight()` etc
4. **Registro da placa**: Usar a macro `DECLARE_BOARD` para registrar a placa

```cpp
#include "wifi_board.h"
#include "codecs/es8311_audio_codec.h"
#include "display/lcd_display.h"
#include "application.h"
#include "button.h"
#include "config.h"
#include "mcp_server.h"

#include <esp_log.h>
#include <driver/i2c_master.h>
#include <driver/spi_common.h>

#define TAG "MyCustomBoard"

class MyCustomBoard : public WifiBoard {
private:
    i2c_master_bus_handle_t codec_i2c_bus_;
    Button boot_button_;
    LcdDisplay* display_;

    // Inicialização I2C
    void InitializeI2c() {
        i2c_master_bus_config_t i2c_bus_cfg = {
            .i2c_port = I2C_NUM_0,
            .sda_io_num = AUDIO_CODEC_I2C_SDA_PIN,
            .scl_io_num = AUDIO_CODEC_I2C_SCL_PIN,
            .clk_source = I2C_CLK_SRC_DEFAULT,
            .glitch_ignore_cnt = 7,
            .intr_priority = 0,
            .trans_queue_depth = 0,
            .flags = {
                .enable_internal_pullup = 1,
            },
        };
        ESP_ERROR_CHECK(i2c_new_master_bus(&i2c_bus_cfg, &codec_i2c_bus_));
    }

    // Inicialização SPI (para tela)
    void InitializeSpi() {
        spi_bus_config_t buscfg = {};
        buscfg.mosi_io_num = DISPLAY_SPI_MOSI_PIN;
        buscfg.miso_io_num = GPIO_NUM_NC;
        buscfg.sclk_io_num = DISPLAY_SPI_SCK_PIN;
        buscfg.quadwp_io_num = GPIO_NUM_NC;
        buscfg.quadhd_io_num = GPIO_NUM_NC;
        buscfg.max_transfer_sz = DISPLAY_WIDTH * DISPLAY_HEIGHT * sizeof(uint16_t);
        ESP_ERROR_CHECK(spi_bus_initialize(SPI2_HOST, &buscfg, SPI_DMA_CH_AUTO));
    }

    // Inicialização de botões
    void InitializeButtons() {
        boot_button_.OnClick([this]() {
            auto& app = Application::GetInstance();
            if (app.GetDeviceState() == kDeviceStateStarting) {
                EnterWifiConfigMode();
                return;
            }
            app.ToggleChatState();
        });
    }

    // Inicialização da tela (exemplo com ST7789)
    void InitializeDisplay() {
        esp_lcd_panel_io_handle_t panel_io = nullptr;
        esp_lcd_panel_handle_t panel = nullptr;
        
        esp_lcd_panel_io_spi_config_t io_config = {};
        io_config.cs_gpio_num = DISPLAY_SPI_CS_PIN;
        io_config.dc_gpio_num = DISPLAY_DC_PIN;
        io_config.spi_mode = 2;
        io_config.pclk_hz = 80 * 1000 * 1000;
        io_config.trans_queue_depth = 10;
        io_config.lcd_cmd_bits = 8;
        io_config.lcd_param_bits = 8;
        ESP_ERROR_CHECK(esp_lcd_new_panel_io_spi(SPI2_HOST, &io_config, &panel_io));

        esp_lcd_panel_dev_config_t panel_config = {};
        panel_config.reset_gpio_num = GPIO_NUM_NC;
        panel_config.rgb_ele_order = LCD_RGB_ELEMENT_ORDER_RGB;
        panel_config.bits_per_pixel = 16;
        ESP_ERROR_CHECK(esp_lcd_new_panel_st7789(panel_io, &panel_config, &panel));
        
        esp_lcd_panel_reset(panel);
        esp_lcd_panel_init(panel);
        esp_lcd_panel_invert_color(panel, true);
        esp_lcd_panel_swap_xy(panel, DISPLAY_SWAP_XY);
        esp_lcd_panel_mirror(panel, DISPLAY_MIRROR_X, DISPLAY_MIRROR_Y);
        
        // Criar objeto de tela
        display_ = new SpiLcdDisplay(panel_io, panel,
                                    DISPLAY_WIDTH, DISPLAY_HEIGHT, 
                                    DISPLAY_OFFSET_X, DISPLAY_OFFSET_Y, 
                                    DISPLAY_MIRROR_X, DISPLAY_MIRROR_Y, DISPLAY_SWAP_XY);
    }

    // Inicialização de MCP Tools
    void InitializeTools() {
        // Consulte a documentação MCP
    }

public:
    // Construtor
    MyCustomBoard() : boot_button_(BOOT_BUTTON_GPIO) {
        InitializeI2c();
        InitializeSpi();
        InitializeDisplay();
        InitializeButtons();
        InitializeTools();
        GetBacklight()->SetBrightness(100);
    }

    // Obter codec de áudio
    virtual AudioCodec* GetAudioCodec() override {
        static Es8311AudioCodec audio_codec(
            codec_i2c_bus_, 
            I2C_NUM_0, 
            AUDIO_INPUT_SAMPLE_RATE, 
            AUDIO_OUTPUT_SAMPLE_RATE,
            AUDIO_I2S_GPIO_MCLK, 
            AUDIO_I2S_GPIO_BCLK, 
            AUDIO_I2S_GPIO_WS, 
            AUDIO_I2S_GPIO_DOUT, 
            AUDIO_I2S_GPIO_DIN,
            AUDIO_CODEC_PA_PIN, 
            AUDIO_CODEC_ES8311_ADDR);
        return &audio_codec;
    }

    // Obter tela
    virtual Display* GetDisplay() override {
        return display_;
    }
    
    // Obter controle de backlight
    virtual Backlight* GetBacklight() override {
        static PwmBacklight backlight(DISPLAY_BACKLIGHT_PIN, DISPLAY_BACKLIGHT_OUTPUT_INVERT);
        return &backlight;
    }
};

// Registrar placa de desenvolvimento
DECLARE_BOARD(MyCustomBoard);
```

### 4. Adicionar Configuração do Sistema de Build

#### Adicionar opção de placa no Kconfig.projbuild

Abra o arquivo `main/Kconfig.projbuild`, na parte `choice BOARD_TYPE` adicione o novo item de configuração de placa:

```kconfig
choice BOARD_TYPE
    prompt "Board Type"
    default BOARD_TYPE_BREAD_COMPACT_WIFI
    help
        Board type. Tipo de placa de desenvolvimento
    
    # ... outras opções de placa ...
    
    config BOARD_TYPE_MY_CUSTOM_BOARD
        bool "My Custom Board (Minha placa personalizada)"
        depends on IDF_TARGET_ESP32S3  # Modifique de acordo com seu chip alvo
endchoice
```

**Observações:**
- `BOARD_TYPE_MY_CUSTOM_BOARD` é o nome do item de configuração, deve estar todo em maiúsculas, usando sublinhados como separadores
- `depends on` especifica o tipo de chip alvo (como `IDF_TARGET_ESP32S3`, `IDF_TARGET_ESP32C3` etc)
- O texto de descrição pode usar chinês e inglês

#### Adicionar configuração de placa no CMakeLists.txt

Abra o arquivo `main/CMakeLists.txt`, na parte de julgamento de tipo de placa adicione a nova configuração:

```cmake
# Na cadeia elseif adicione a configuração de sua placa
elseif(CONFIG_BOARD_TYPE_MY_CUSTOM_BOARD)
    set(BOARD_TYPE "my-custom-board")  # Consistente com o nome do diretório
    set(BUILTIN_TEXT_FONT font_puhui_basic_20_4)  # Escolha a fonte apropriada baseado no tamanho da tela
    set(BUILTIN_ICON_FONT font_awesome_20_4)
    set(DEFAULT_EMOJI_COLLECTION twemoji_64)  # Opcional, se precisar exibir emojis
endif()
```

**Explicação da configuração de fontes e emojis:**

Escolha o tamanho de fonte apropriado baseado na resolução da tela:
- Tela pequena (128x64 OLED): `font_puhui_basic_14_1` / `font_awesome_14_1`
- Tela média-pequena (240x240): `font_puhui_basic_16_4` / `font_awesome_16_4`
- Tela média (240x320): `font_puhui_basic_20_4` / `font_awesome_20_4`
- Tela grande (480x320+): `font_puhui_basic_30_4` / `font_awesome_30_4`

Opções de coleção de emojis:
- `twemoji_32` - Emojis 32x32 pixels (tela pequena)
- `twemoji_64` - Emojis 64x64 pixels (tela grande)

### 5. Configuração e Compilação

#### Método 1: Configuração manual usando idf.py

1. **Definir chip alvo** (na primeira configuração ou ao trocar chip):
   ```bash
   # Para ESP32-S3
   idf.py set-target esp32s3
   
   # Para ESP32-C3
   idf.py set-target esp32c3
   
   # Para ESP32
   idf.py set-target esp32
   ```

2. **Limpar configuração antiga**:
   ```bash
   idf.py fullclean
   ```

3. **Entrar no menu de configuração**:
   ```bash
   idf.py menuconfig
   ```
   
   No menu navegue até: `Xiaozhi Assistant` -> `Board Type`, selecione sua placa personalizada.

4. **Compilar e gravar**:
   ```bash
   idf.py build
   idf.py flash monitor
   ```

#### Método 2: Usando o script release.py (recomendado)

Se o diretório de sua placa possui um arquivo `config.json`, você pode usar este script para completar automaticamente a configuração e compilação:

```bash
python scripts/release.py my-custom-board
```

Este script irá automaticamente:
- Ler a configuração `target` do `config.json` e definir o chip alvo
- Aplicar as opções de compilação de `sdkconfig_append`
- Completar a compilação e empacotar o firmware

### 6. Criar README.md

No README.md, explique as características da placa, requisitos de hardware, etapas de compilação e gravação:


## Componentes Comuns de Placas de Desenvolvimento

### 1. Telas

O projeto suporta vários drivers de tela, incluindo:
- ST7789 (SPI)
- ILI9341 (SPI)
- SH8601 (QSPI)
- etc...

### 2. Codecs de Áudio

Codecs suportados incluem:
- ES8311 (comum)
- ES7210 (array de microfones)
- AW88298 (amplificador)
- etc...

### 3. Gerenciamento de Energia

Algumas placas usam chips de gerenciamento de energia:
- AXP2101
- Outros PMICs disponíveis

### 4. Controle de Dispositivos MCP

Você pode adicionar várias ferramentas MCP para que a IA possa usar:
- Speaker (controle de alto-falante)
- Screen (ajuste de brilho da tela)
- Battery (leitura de nível de bateria)
- Light (controle de luz)
- etc...

## Hierarquia de Herança de Classes de Placas

- `Board` - Classe base de nível de placa
  - `WifiBoard` - Placa de desenvolvimento com conexão Wi-Fi
  - `Ml307Board` - Placa de desenvolvimento usando módulo 4G
  - `DualNetworkBoard` - Placa de desenvolvimento com suporte para alternância entre Wi-Fi e rede 4G

## Dicas de Desenvolvimento

1. **Referencie placas similares**: Se sua nova placa tiver similaridades com placas existentes, pode referenciar a implementação existente
2. **Depuração passo a passo**: Implemente primeiro funcionalidades básicas (como display), depois adicione funcionalidades mais complexas (como áudio)
3. **Mapeamento de pinos**: Certifique-se de configurar corretamente todo o mapeamento de pinos no config.h
4. **Verifique compatibilidade de hardware**: Confirme a compatibilidade de todos os chips e drivers

## Possíveis Problemas

1. **Tela não funciona corretamente**: Verifique configuração SPI, configurações de espelhamento e inversão de cor
2. **Sem saída de áudio**: Verifique configuração I2S, pino de habilitação PA e endereço do codec
3. **Não consegue conectar à rede**: Verifique credenciais Wi-Fi e configuração de rede
4. **Não consegue comunicar com o servidor**: Verifique configuração MQTT ou WebSocket

## Materiais de Referência

- Documentação ESP-IDF: https://docs.espressif.com/projects/esp-idf/
- Documentação LVGL: https://docs.lvgl.io/
- Documentação ESP-SR: https://github.com/espressif/esp-sr 