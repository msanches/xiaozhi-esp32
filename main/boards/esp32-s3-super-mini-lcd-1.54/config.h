// Configuração de pinos para ESP32-S3 Super Mini com LCD IPS 1.54"
// Baseado no diagrama de ligação fornecido

#define DISPLAY_BACKLIGHT_PIN GPIO_NUM_5   // Pino do backlight (ou 3.3V/5V direto)
#define DISPLAY_MOSI_PIN      GPIO_NUM_11  // GPIO 11 - MOSI/SDA
#define DISPLAY_CLK_PIN       GPIO_NUM_12  // GPIO 12 - SCK/SCL
#define DISPLAY_DC_PIN        GPIO_NUM_7   // GPIO 7 - DC/RS
#define DISPLAY_RST_PIN       GPIO_NUM_6   // GPIO 6 - RST/RES
#define DISPLAY_CS_PIN        GPIO_NUM_10  // GPIO 10 - CS

// Configuração para LCD IPS 1.54" ST7789 240x240
#ifdef CONFIG_LCD_ST7789_240X240
#define LCD_TYPE_ST7789_SERIAL
#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240
#define DISPLAY_MIRROR_X false
#define DISPLAY_MIRROR_Y false
#define DISPLAY_SWAP_XY false
#define DISPLAY_INVERT_COLOR    true
#define DISPLAY_RGB_ORDER  LCD_RGB_ELEMENT_ORDER_RGB
#define DISPLAY_OFFSET_X  0
#define DISPLAY_OFFSET_Y  0
#define DISPLAY_BACKLIGHT_OUTPUT_INVERT false
#define DISPLAY_SPI_MODE 0
#endif

// Configuração para GC9A01 (se for o caso)
#ifdef CONFIG_LCD_GC9A01_240X240
#define LCD_TYPE_GC9A01_SERIAL
#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240
#define DISPLAY_MIRROR_X true
#define DISPLAY_MIRROR_Y false
#define DISPLAY_SWAP_XY false
#define DISPLAY_INVERT_COLOR    true
#define DISPLAY_RGB_ORDER  LCD_RGB_ELEMENT_ORDER_BGR
#define DISPLAY_OFFSET_X  0
#define DISPLAY_OFFSET_Y  0
#define DISPLAY_BACKLIGHT_OUTPUT_INVERT false
#define DISPLAY_SPI_MODE 0
#endif

// Configuração customizada (caso precise ajustar)
#ifdef CONFIG_LCD_CUSTOM
#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240
#define DISPLAY_MIRROR_X false
#define DISPLAY_MIRROR_Y false
#define DISPLAY_SWAP_XY false
#define DISPLAY_INVERT_COLOR    true
#define DISPLAY_RGB_ORDER  LCD_RGB_ELEMENT_ORDER_RGB
#define DISPLAY_OFFSET_X  0
#define DISPLAY_OFFSET_Y  0
#define DISPLAY_BACKLIGHT_OUTPUT_INVERT false
#define DISPLAY_SPI_MODE 0
#endif