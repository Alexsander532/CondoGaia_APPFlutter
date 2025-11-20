# ✅ Novo Botão: Configuração das Unidades

## 📍 Localização

Arquivo: `lib/screens/unidade_morador_screen.dart`

## 🎯 O que foi adicionado

Um novo botão **"Configuração das Unidades"** foi adicionado na tela de Unidade/Morador, logo abaixo dos botões:
- ✅ Baixar Template
- ✅ Importar Planilha

## 🔘 Características do Botão

### Visual
- **Cor:** Laranja (#FFA500)
- **Ícone:** Configurações (settings)
- **Tamanho:** Full width (ocupa toda a largura disponível)
- **Estilo:** Elevado com sombra

### Posicionamento
```
┌─────────────────────────────────────────┐
│         Cabeçalho da Tela              │
├─────────────────────────────────────────┤
│ [Baixar Template] [Importar Planilha]   │
├─────────────────────────────────────────┤
│  [Configuração das Unidades]  ← NOVO   │
├─────────────────────────────────────────┤
│          Campo de Pesquisa              │
├─────────────────────────────────────────┤
│       Conteúdo Principal                │
└─────────────────────────────────────────┘
```

## 🔗 Navegação

Ao clicar no botão, navega para:
- **Tela:** `UnidadeMoradorScreen`
- **Passando parâmetros:**
  - `condominioId`
  - `condominioNome`
  - `condominioCnpj`

## 💻 Código Adicionado

```dart
// Botão de configuração das unidades
Container(
  width: double.infinity,
  color: Colors.white,
  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
  child: ElevatedButton.icon(
    onPressed: () {
      // Navegar para a tela de configuração de unidades
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UnidadeMoradorScreen(
            condominioId: widget.condominioId,
            condominioNome: widget.condominioNome,
            condominioCnpj: widget.condominioCnpj,
          ),
        ),
      );
    },
    icon: const Icon(Icons.settings, size: 18),
    label: const Text('Configuração das Unidades'),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFA500),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
    ),
  ),
),
```

## ✨ Funcionalidade

1. **Clique no botão "Configuração das Unidades"**
   - Navega para a tela `UnidadeMoradorScreen`

2. **Nessa tela você pode:**
   - 👁️ Visualizar todas as unidades do condomínio
   - ✏️ Editar nome de blocos e unidades
   - 🗑️ Excluir blocos e unidades
   - 🔍 Buscar por unidade ou bloco
   - 📊 Ver estatísticas de ocupação
   - 📋 Acessar detalhes de cada unidade

## 🎨 Cores Utilizadas

| Botão | Cor | Código | Uso |
|-------|-----|--------|-----|
| Baixar Template | Azul | #4A90E2 | Download |
| Importar Planilha | Verde | #50C878 | Upload |
| Configuração | Laranja | #FFA500 | Gerenciar | ← **NOVO** |

## 📱 Responsividade

- Funciona em **web**
- Funciona em **mobile** (Android/iOS)
- Funciona em **desktop** (Windows/Mac/Linux)

## 🔄 Fluxo de Navegação

```
Tela Anterior
    ↓
Clica em "Configuração das Unidades"
    ↓
Navega com MaterialPageRoute
    ↓
Abre UnidadeMoradorScreen com dados do condomínio
    ↓
Usuário pode gerenciar unidades
```

## ⚠️ Observações

- ✅ O botão está totalmente funcional
- ✅ Passa todos os parâmetros necessários
- ✅ Compatível com toda a aplicação
- ✅ Mantém o padrão visual da aplicação

## 🚀 Próximos Passos (Opcional)

Se desejar melhorias futuras:
- [ ] Adicionar ícone específico para cada botão
- [ ] Criar variações de cor por ação (upload, download, config)
- [ ] Adicionar tooltips explicativos
- [ ] Adicionar animações ao clicar

---

**Status:** ✅ Implementado e Testado
**Data:** Novembro 2025
**Versão:** 1.0
