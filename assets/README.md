# Assets do CondoGaia App

Esta pasta contém todos os recursos visuais (imagens, ícones, etc.) organizados por tela do aplicativo.

## Estrutura de Pastas

```
assets/
└── images/
    ├── login/              # Imagens específicas da tela de login
    ├── cadastro_representante/ # Imagens da tela de cadastro de representante
    ├── home/               # Imagens da tela inicial/home
    └── common/             # Imagens compartilhadas entre várias telas
```

## Como Usar

### Adicionando Imagens
1. Coloque as imagens na pasta correspondente à tela onde serão usadas
2. Para imagens usadas em múltiplas telas, use a pasta `common/`
3. Use nomes descritivos para os arquivos (ex: `logo.png`, `background.jpg`)

### Usando no Código Flutter
```dart
// Exemplo de uso de uma imagem
Image.asset('assets/images/login/logo.png')

// Para imagens comuns
Image.asset('assets/images/common/icon.png')
```

## Formatos Recomendados
- **PNG**: Para imagens com transparência
- **JPG**: Para fotos e imagens sem transparência
- **SVG**: Para ícones vetoriais (requer dependência flutter_svg)

## Resolução
- Forneça imagens em diferentes resoluções para melhor qualidade:
  - `image.png` (1x)
  - `2.0x/image.png` (2x)
  - `3.0x/image.png` (3x)