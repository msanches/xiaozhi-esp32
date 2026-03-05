# Guia de Estilo de Código

## Ferramenta de Formatação de Código

Este projeto utiliza a ferramenta clang-format para unificar o estilo de código. Já fornecemos o arquivo de configuração `.clang-format` no diretório raiz do projeto, que é baseado no Guia de Estilo C++ do Google com algumas personalizações.

### Instalação do clang-format

Antes de usar, certifique-se de ter instalado a ferramenta clang-format:

- **Windows**:
  ```powershell
  winget install LLVM
  # Ou usando Chocolatey
  choco install llvm
  ```

- **Linux**:
  ```bash
  sudo apt install clang-format  # Ubuntu/Debian
  sudo dnf install clang-tools-extra  # Fedora
  ```

- **macOS**:
  ```bash
  brew install clang-format
  ```

### Como Usar

1. **Formatar um único arquivo**:
   ```bash
   clang-format -i path/to/your/file.cpp
   ```

2. **Formatar o projeto inteiro**:
   ```bash
   # Execute no diretório raiz do projeto
   find main -iname *.h -o -iname *.cc | xargs clang-format -i
   ```

3. **Verificar formatação antes de fazer commit**:
   ```bash
   # Verificar se o formato do arquivo está conforme as regras (não modifica o arquivo)
   clang-format --dry-run -Werror path/to/your/file.cpp
   ```

### Integração com IDE

- **Visual Studio Code**:
  1. Instale a extensão C/C++
  2. Nas configurações, habilite `C_Cpp.formatting` como `clang-format`
  3. Você pode configurar a formatação automática ao salvar: `editor.formatOnSave: true`

- **CLion**:
  1. Nas configurações, selecione `Editor > Code Style > C/C++`
  2. Configure `Formatter` como `clang-format`
  3. Escolha usar o arquivo de configuração `.clang-format` do projeto

### Principais Regras de Formatação

- Indentação usando 4 espaços
- Largura de linha limitada a 100 caracteres
- Chaves no estilo Attach (na mesma linha da instrução de controle)
- Símbolos de ponteiro e referência alinhados à esquerda
- Ordenação automática de inclusões de arquivos de cabeçalho
- Modificadores de acesso de classe indentados em -4 espaços

### Observações Importantes

1. Certifique-se de que o código foi formatado antes de fazer commit
2. Não ajuste manualmente o alinhamento de código já formatado
3. Se não quiser que um trecho de código seja formatado, você pode envolvê-lo com os seguintes comentários:
   ```cpp
   // clang-format off
   // seu código
   // clang-format on
   ```

### Perguntas Frequentes

1. **Falha na formatação**:
   - Verifique se a versão do clang-format não é muito antiga
   - Confirme que a codificação do arquivo é UTF-8
   - Valide se a sintaxe do arquivo .clang-format está correta

2. **Formato não corresponde ao esperado**:
   - Verifique se está usando a configuração .clang-format do diretório raiz do projeto
   - Confirme que não há outros arquivos .clang-format em outros locais sendo priorizados

Se tiver alguma dúvida ou sugestão, sinta-se à vontade para abrir uma issue ou pull request.