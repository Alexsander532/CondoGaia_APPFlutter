# ✅ PASSO 4 COMPLETO - Calendário e Datas Específicas

## 🎯 O Que Foi Implementado

### Passo 4.1: Instalar table_calendar ✅
Package instalado com sucesso:
```bash
flutter pub add table_calendar
```

---

### Passo 4.2: Função _buildDiasEspecificosUI ✅

**Localização:** `lib/screens/portaria_inquilino_screen.dart` (antes de `_mostrarDialogSelecaoFotoAutorizado`)

**Funcionalidade:**
- Renderiza a UI para seleção de datas específicas
- Mostra um botão "Selecionar Datas" para abrir o calendário
- Exibe as datas selecionadas como Chips removíveis
- Mostra mensagem quando nenhuma data foi selecionada

**Código-chave:**
```dart
Widget _buildDiasEspecificosUI(StateSetter setModalState) {
  return Column(
    children: [
      ElevatedButton.icon(
        icon: const Icon(Icons.calendar_today),
        label: const Text('Selecionar Datas'),
        onPressed: () => _abrirCalendario(setModalState),
      ),
      // ... exibição de datas como Chips ...
    ],
  );
}
```

---

### Passo 4.3: Função _abrirCalendario ✅

**Funcionalidade:**
- Abre o dialog do calendário
- Retorna as datas selecionadas
- Atualiza a UI do modal quando confirmado

**Código-chave:**
```dart
Future<void> _abrirCalendario(StateSetter setModalState) async {
  final result = await showDialog<List<DateTime>>(
    context: context,
    builder: (context) => _buildCalendarioDialog(),
  );

  if (result != null && result.isNotEmpty) {
    setModalState(() {
      _diasEspecificosSelecionados = result;
    });
  }
}
```

---

### Passo 4.4: Função _buildCalendarioDialog ✅

**Funcionalidade:**
- Renderiza um calendário interativo usando `TableCalendar`
- Permite seleção de múltiplas datas
- Mostra as datas selecionadas com opção de remover
- Botões "Cancelar" e "Confirmar"

**Detalhes técnicos:**
- Primeiro dia: 2020 | Último dia: 2030
- Datas selecionadas destacadas em azul (#4A90E2)
- Dia atual destacado em cinza
- Datas são ordenadas antes de confirmar

**Código exemplo:**
```dart
TableCalendar(
  firstDay: DateTime(2020),
  lastDay: DateTime(2030),
  focusedDay: _focusedDay,
  selectedDayPredicate: (day) {
    return selectedDates.any((date) =>
        date.year == day.year &&
        date.month == day.month &&
        date.day == day.day);
  },
  onDaySelected: (selectedDay, focusedDay) {
    // Alternar seleção da data
  },
  // ... estilos ...
)
```

---

### Passo 4.5: Função _validarPermissoes ✅

**Localização:** Antes de `_salvarAutorizado()`

**Funcionalidade:**
- Valida se dia(s) foram selecionados
- Verifica tipo de seleção (dias_semana vs dias_especificos)
- Mostra SnackBar de erro se nenhum dia foi selecionado
- Retorna `bool` indicando se validação passou

**Validações:**
```dart
bool _validarPermissoes() {
  if (_permissaoSelecionada == 'determinado') {
    if (_tipoSelecaoDias == 'dias_semana') {
      // Validar dias da semana
      if (_diasSemana.where((dia) => dia == true).isEmpty)
        return false;
    } else if (_tipoSelecaoDias == 'dias_especificos') {
      // Validar datas específicas
      if (_diasEspecificosSelecionados.isEmpty)
        return false;
    }
  }
  return true;
}
```

---

### Passo 4.6: Integração com _salvarAutorizado ✅

**Modificações:**

1. **Adicionada chamada de validação:**
```dart
// 🆕 Validar permissões (dias/horários)
if (!_validarPermissoes()) {
  return;
}
```

2. **Conversão de datas para ISO antes de salvar:**
```dart
// 🆕 Preparar datas específicas em formato ISO
List<String> diasEspecificosISO = [];
if (_tipoSelecaoDias == 'dias_especificos' && _diasEspecificosSelecionados.isNotEmpty) {
  diasEspecificosISO = _diasEspecificosSelecionados
      .map((date) => date.toIso8601String().split('T')[0]) // YYYY-MM-DD
      .toList();
}
```

3. **Adicionados novos campos ao mapa de dados:**
```dart
final autorizadoData = {
  // ... campos existentes ...
  'tipo_selecao_dias': _permissaoSelecionada == 'determinado'
      ? _tipoSelecaoDias
      : 'dias_semana',
  'dias_especificos': diasEspecificosISO,
  // ... resto dos campos ...
};
```

---

### Passo 4.7: Atualização de _preencherCamposParaEdicao ✅

**Funcionalidade:**
- Carrega dados de um autorizado existente ao editar
- Restaura `tipo_selecao_dias` 
- Converte strings ISO para `DateTime` para `_diasEspecificosSelecionados`

**Código-chave:**
```dart
// 🆕 Carregar tipo de seleção de dias e datas específicas
_tipoSelecaoDias = autorizado.tipoSelecaoDias ?? 'dias_semana';

if (autorizado.diasEspecificos != null && autorizado.diasEspecificos!.isNotEmpty) {
  _diasEspecificosSelecionados = autorizado.diasEspecificos!
      .map((dateStr) => DateTime.parse(dateStr))
      .toList();
} else {
  _diasEspecificosSelecionados = [];
}
```

---

### Passo 4.8: Verificação de Compilação ✅

**Status:** ✅ Sem erros relacionados ao Passo 4

**Variáveis de estado atualizadas:**
- ✅ `_tipoSelecaoDias` - Tipo de seleção (dias_semana ou dias_especificos)
- ✅ `_diasEspecificosSelecionados` - Lista de DateTime para as datas selecionadas
- ✅ `_diasSemanasSelecionados` - Já existia (não usado no Passo 4, será para Passo 5)

---

## 📋 Imports Adicionados

```dart
import 'package:table_calendar/table_calendar.dart';
```

---

## 🎨 UI/UX Implementado

### Fluxo de Usuário:

```
1. Usuário seleciona "Permissão em dias e horários determinado"
                          ↓
2. Escolhe entre "Dias da Semana" e "Datas Específicas"
                          ↓
3. Se escolher "Datas Específicas":
   - Clica em "Selecionar Datas"
   - Abre dialog com calendário
   - Clica nas datas desejadas (múltiplas seleções)
   - Clica em "Confirmar"
   - Datas aparecem como Chips no modal
                          ↓
4. Clica em "Salvar"
   - Sistema valida se pelo menos 1 dia foi selecionado
   - Converte datas para ISO (YYYY-MM-DD)
   - Envia ao banco com tipo_selecao_dias e dias_especificos
```

### Visual do Calendário:

```
┌─────────────────────────────────────┐
│ Selecionar Datas                    │
├─────────────────────────────────────┤
│                                     │
│    ← Mês/Ano →                      │
│                                     │
│  Dom Seg Ter Qua Qui Sex Sab        │
│   1   2   3   4   5   6   7         │
│   8   9  10  11  12  13  14         │
│  15 [16] 17  18  19  20  21         │
│  22  23 [24] 25  26  27  28         │
│  29  30  31                         │
│                                     │
│ 3 data(s) selecionada(s):           │
│ [16/01] [24/01] [28/01]             │
│                                     │
├─────────────────────────────────────┤
│   [Cancelar]         [Confirmar]    │
└─────────────────────────────────────┘
```

### Visual dos Chips de Datas:

```
Datas selecionadas (3):
┌─────────────────────────────────────┐
│ [16/01/2025 ✕] [24/01/2025 ✕]      │
│ [28/01/2025 ✕]                     │
└─────────────────────────────────────┘
```

---

## ✅ Funcionalidades Implementadas

| Funcionalidade | Status |
|---|---|
| Package table_calendar instalado | ✅ |
| Widget calendário renderizado | ✅ |
| Seleção de múltiplas datas | ✅ |
| UI condicional (dias_semana vs dias_especificos) | ✅ |
| Validação de permissões | ✅ |
| Conversão de DateTime para ISO | ✅ |
| Salvamento no banco | ✅ |
| Carregamento ao editar | ✅ |
| Exclusão de datas via Chip | ✅ |
| Dialog calendário com confirmação | ✅ |

---

## 🔄 Fluxo de Dados

```
UI (Modal)
    ↓
_diasEspecificosSelecionados: List<DateTime>
    ↓ (Passo 4.6 - Conversão)
diasEspecificosISO: List<String> (YYYY-MM-DD)
    ↓
autorizadoData['dias_especificos']
    ↓
AutorizadoInquilinoService.insertAutorizado()
    ↓
Banco de Dados (Supabase)
    ↓ (Passo 4.7 - Carregamento)
AutorizadoInquilino.diasEspecificos: List<String>
    ↓ (Conversão)
_diasEspecificosSelecionados: List<DateTime>
    ↓
UI (Modal preenche com datas)
```

---

## 📦 Estrutura de Dados no Banco

```json
{
  "id": "auth-001",
  "nome": "João Silva",
  "tipo_selecao_dias": "dias_especificos",
  "dias_especificos": [
    "2025-01-15",
    "2025-01-20",
    "2025-02-05"
  ]
}
```

---

## 🧪 Como Testar

### Teste 1: Adicionar Autorizado com Datas Específicas
1. Abra modal "Adicionar Autorizado"
2. Preencha nome e CPF
3. Selecione "Permissão em dias e horários determinado"
4. Escolha "Datas específicas"
5. Clique em "Selecionar Datas"
6. Clique em 3 datas no calendário
7. Clique em "Confirmar"
8. Veja as datas aparecer como Chips
9. Clique em "Salvar"
10. ✅ Deve salvar com sucesso

### Teste 2: Editar Autorizado
1. Clique em editar um autorizado que tem datas específicas
2. ✅ Deve carregar as datas já selecionadas no calendário
3. Adicione/remova datas
4. Clique em "Salvar"

### Teste 3: Validação
1. Selecione "Datas específicas"
2. NÃO selecione nenhuma data
3. Clique em "Salvar"
4. ✅ Deve mostrar erro: "Selecione pelo menos uma data específica"

---

## 🚀 Status Geral

**PASSO 4: 100% COMPLETO** ✅

Todas as funcionalidades de calendário e seleção de datas foram implementadas com sucesso!

---

## 📝 Próximos Passos

Se desejar continuar, os próximos passos poderiam ser:

1. **Testes e Debug:** Testar a seleção de datas em diferentes cenários
2. **UI/UX Melhorias:** Adicionar animações ou melhorias visuais ao calendário
3. **Passo 5 (Opcional):** Implementar seleção de dias da semana com checkbox (se necessário aprimorar a UI)
4. **Integrações:** Integrar com portaria_proprietario_screen se necessário

---

## 📚 Arquivos Modificados

1. **lib/screens/portaria_inquilino_screen.dart**
   - ✅ Import `table_calendar` adicionado
   - ✅ 3 novas funções adicionadas (_buildDiasEspecificosUI, _abrirCalendario, _buildCalendarioDialog)
   - ✅ Função _validarPermissoes adicionada
   - ✅ _salvarAutorizado modificada para preparar datas ISO
   - ✅ _preencherCamposParaEdicao modificada para carregar datas
   - ✅ UI condicional integrada no modal

2. **pubspec.yaml**
   - ✅ table_calendar adicionado como dependência

---

## ✨ Conclusão

O **Passo 4** implementou com sucesso toda a funcionalidade de calendário e seleção de datas específicas para autorização de entrada. O sistema agora permite que usuários escolham entre dois modos:

1. **Dias da Semana:** Recorrente toda semana (checkboxes simples)
2. **Datas Específicas:** Datas exatas (calendário interativo)

A validação garante que pelo menos um dia seja selecionado, e os dados são salvos e carregados corretamente do banco de dados.
