# BluFi - Provisionamento de Rede (Integrado com esp-wifi-connect)

Este documento explica como habilitar e usar o BluFi (provisionamento de Wi-Fi via BLE) no firmware Xiaozhi, combinando com o componente integrado `esp-wifi-connect` para completar a conexão e armazenamento de Wi-Fi. Para a descrição oficial do protocolo BluFi, consulte a [documentação da Espressif](https://docs.espressif.com/projects/esp-idf/zh_CN/stable/esp32/api-guides/ble/blufi.html).

## Pré-requisitos

- É necessário um chip com suporte a BLE e configuração de firmware adequada.
- No `idf.py menuconfig`, habilite `WiFi Configuration Method -> Esp Blufi` (`CONFIG_USE_ESP_BLUFI_WIFI_PROVISIONING=y`). Se você deseja usar BluFi, deve desabilitar a opção Hotspot no mesmo menu, caso contrário o modo de provisionamento Hotspot será usado por padrão.

- Mantenha a inicialização padrão do NVS e do loop de eventos (já tratado no `app_main` do projeto).
- CONFIG_BT_BLUEDROID_ENABLED e CONFIG_BT_NIMBLE_ENABLED são mutuamente exclusivos, não podem ser habilitados simultaneamente.

## Fluxo de Trabalho

1) O smartphone conecta ao dispositivo via BluFi (como o aplicativo oficial EspBlufi ou cliente personalizado), envia o SSID/senha do Wi-Fi. O smartphone pode obter a lista de redes WiFi detectadas pelo dispositivo através do protocolo blufi.
2) No lado do dispositivo, as credenciais são gravadas no `SsidManager` (armazenadas no NVS, parte do componente `esp-wifi-connect`) no evento `ESP_BLUFI_EVENT_REQ_CONNECT_TO_AP`.
3) Em seguida, o `WifiStation` é iniciado para escanear e conectar; o status é retornado via BluFi.
4) Após o provisionamento bem-sucedido, o dispositivo se conecta automaticamente à nova rede Wi-Fi; em caso de falha, retorna o status de erro.

## Passos de Utilização

1. Configuração: No menuconfig, habilite `Esp Blufi`. Compile e grave o firmware.
2. Iniciar provisionamento: O dispositivo entra automaticamente no modo de provisionamento na primeira inicialização quando não há Wi-Fi salvo.
3. Operação no smartphone: Abra o aplicativo EspBlufi (ou outro cliente BluFi), pesquise e conecte ao dispositivo, escolha se deseja usar criptografia, insira o SSID/senha do Wi-Fi conforme solicitado e envie.
4. Observe o resultado:
    - Sucesso: BluFi reporta conexão bem-sucedida, dispositivo conecta automaticamente ao Wi-Fi.
    - Falha: BluFi retorna status de falha, pode reenviar ou verificar o roteador.

## Observações Importantes

- O provisionamento BluFi não pode ser habilitado simultaneamente com o provisionamento via hotspot. Se o provisionamento via hotspot já estiver ativo, ele será usado por padrão. No menuconfig, mantenha apenas um método de provisionamento.
- Para testes múltiplos, recomenda-se limpar ou sobrescrever o SSID armazenado (namespace `wifi`), evitando interferência de configurações antigas.
- Se usar um cliente BluFi personalizado, é necessário seguir o formato de frame do protocolo oficial, consulte o link da documentação oficial acima.
- A documentação oficial fornece o endereço de download do aplicativo EspBlufi.
- Devido a mudanças na interface blufi do IDF 5.5.2, o nome do Bluetooth após compilação na versão 5.5.2 é "Xiaozhi-Blufi", enquanto na versão 5.5.1 é "BLUFI_DEVICE".
