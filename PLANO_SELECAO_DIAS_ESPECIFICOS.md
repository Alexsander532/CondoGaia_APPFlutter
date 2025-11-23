# 🗓️ Plano: Sistema de Seleção de Dias - Autorizado Inquilino/Proprietário

## 📋 Visão Geral

Implementar um sistema **mutuamente exclusivo** para seleção de dias de permissão:
- **Modo 1:** Dias da semana (DOM, SEG, TER, etc) - com checkboxes
- **Modo 2:** Dias específicos - com calendário interativo

---

## 🏗️ ARQUITETURA

### 1. ESTRUTURA DE DADOS NO BANCO

#### Tabela: `autorizados_inquilino`

**Campos a adicionar/modificar:**

```sql
-- Tipo de seleção de dias
ALTER TABLE autorizados_inquilino ADD COLUMN tipo_selecao_dias VARCHAR(20) 
  DEFAULT 'dias_semana' 
  CHECK (tipo_selecao_dias IN ('dias_semana', 'dias_especificos'));

-- Dias da semana (JSON array com abreviações)
ALTER TABLE autorizados_inquilino ADD COLUMN dias_semana JSONB 
  DEFAULT '["MON", "TUE", "WED", "THU", "FRI"]';

-- Dias específicos (JSON array com datas ISO)
ALTER TABLE autorizados_inquilino ADD COLUMN dias_especificos JSONB 
  DEFAULT '[]';

-- Horários (já existem, mas destacar)
-- horario_inicio: TIME (ex: 08:00)
-- horario_fim: TIME (ex: 18:00)
```

**Exemplo de dados salvos:**

```json
// Modo: Dias da semana
{
  "id": "auth-123",
  "nome": "João Silva",
  "tipo_selecao_dias": "dias_semana",
  "dias_semana": ["MON", "TUE", "WED", "THU", "FRI"],
  "dias_especificos": [],
  "horario_inicio": "08:00",
  "horario_fim": "18:00"
}

// Modo: Dias específicos
{
  "id": "auth-456",
  "nome": "Maria Santos",
  "tipo_selecao_dias": "dias_especificos",
  "dias_semana": [],
  "dias_especificos": ["2025-01-15", "2025-01-20", "2025-02-05"],
  "horario_inicio": "09:00",
  "horario_fim": "17:00"
}
```

---

## 🎨 ESTRUTURA DE UI

```
┌─────────────────────────────────────────────┐
│         PERMISSÕES                          │
├─────────────────────────────────────────────┤
│                                             │
│  ○ Permissão em qualquer dia e horário      │
│                                             │
│  ⦿ Permissão em dias e horários determinado│
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  Horários permitida a entrada:      │   │
│  │  Início: [08:00 ↓]  Fim: [18:00 ↓]  │   │
│  │                                     │   │
│  │  Tipo de seleção de dias:           │   │
│  │  ⦿ Dias da semana                   │   │
│  │  ○ Dia(s) específico(s)             │   │
│  │                                     │   │
│  │  ┌───────────────────────────────┐  │   │
│  │  │ Dias da Semana:               │  │   │
│  │  │ ☑ DOM  ☑ SEG  ☐ TER  ☑ QUA   │  │   │
│  │  │ ☑ QUI  ☑ SEX  ☐ SAB          │  │   │
│  │  └───────────────────────────────┘  │   │
│  │                                     │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │  Ou selecione data(s) específica(s): │ │
│  │  [📅 Abrir Calendário]               │ │
│  │                                       │ │
│  │  Datas selecionadas:                 │ │
│  │  • 15 de janeiro de 2025             │ │
│  │  • 20 de janeiro de 2025             │ │
│  │  • 05 de fevereiro de 2025           │ │
│  │                                       │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │          [Salvar]                   │   │
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 💾 ESTADO DA APLICAÇÃO (State Variables)

```dart
// No StatefulBuilder do modal
String _tipoSelecaoDias = 'dias_semana'; // ou 'dias_especificos'

// Dias da semana selecionados
List<String> _diasSemanasSelecionados = ['MON', 'TUE', 'WED', 'THU', 'FRI'];

// Dias específicos selecionados
List<DateTime> _diasEspecificosSelecionados = [];

// Horários
TimeOfDay _horaInicio = TimeOfDay(hour: 8, minute: 0);
TimeOfDay _horaFim = TimeOfDay(hour: 18, minute: 0);

// Mapping para exibição
Map<String, String> _nomesDiasSemana = {
  'MON': 'SEG',
  'TUE': 'TER',
  'WED': 'QUA',
  'THU': 'QUI',
  'FRI': 'SEX',
  'SAT': 'SAB',
  'SUN': 'DOM',
};
```

---

## 🎯 FLUXO DE INTERAÇÃO

### Cenário 1: Usuário seleciona "Dias da Semana"

```
1. Clica no radio "Dias da semana"
   ↓
2. Sistema atualiza: _tipoSelecaoDias = 'dias_semana'
   ↓
3. Exibe checkboxes para: DOM, SEG, TER, QUA, QUI, SEX, SAB
   ↓
4. Esconde calendário (se estava aberto)
   ↓
5. Limpa _diasEspecificosSelecionados = []
   ↓
6. Usuário marca checkboxes (ex: SEG, TER, QUA, QUI, SEX)
   ↓
7. Clica em "Salvar"
   ↓
8. Valida e salva:
   {
     tipo_selecao_dias: 'dias_semana',
     dias_semana: ['MON', 'TUE', 'WED', 'THU', 'FRI'],
     dias_especificos: [],
     horario_inicio: '08:00',
     horario_fim: '18:00'
   }
```

### Cenário 2: Usuário seleciona "Dias Específicos"

```
1. Clica no radio "Dia(s) específico(s)"
   ↓
2. Sistema atualiza: _tipoSelecaoDias = 'dias_especificos'
   ↓
3. Esconde checkboxes de dias da semana
   ↓
4. Limpa _diasSemanasSelecionados = []
   ↓
5. Exibe botão "Abrir Calendário"
   ↓
6. Usuário clica em "Abrir Calendário"
   ↓
7. Abre Table Calendar (mês atual como padrão)
   ↓
8. Usuário clica em datas:
   - 15 de janeiro (marcado)
   - 20 de janeiro (marcado)
   - 05 de fevereiro (marcado)
   ↓
9. Datas aparecem abaixo: "15 jan, 20 jan, 05 fev"
   ↓
10. Usuário clica "Confirmar" no calendário
    ↓
11. Calendário fecha, datas ficam salvas em _diasEspecificosSelecionados
    ↓
12. Clica em "Salvar" no modal
    ↓
13. Valida e salva:
    {
      tipo_selecao_dias: 'dias_especificos',
      dias_semana: [],
      dias_especificos: ['2025-01-15', '2025-01-20', '2025-02-05'],
      horario_inicio: '09:00',
      horario_fim: '17:00'
    }
```

### Cenário 3: Alternar entre os dois modos

```
1. Usuário estava em "Dias da semana" com SEG-SEX selecionados
   ↓
2. Muda para "Dias específicos"
   ↓
3. Sistema:
   - Limpa _diasSemanasSelecionados
   - Mostra calendário vazio
   ↓
4. Usuário muda de novo para "Dias da semana"
   ↓
5. Sistema:
   - Limpa _diasEspecificosSelecionados
   - Mostra checkboxes (sem nada selecionado - estado reset)
```

---

## 🔧 IMPLEMENTAÇÃO TÉCNICA

### Passo 1: Adicionar Packages

```bash
flutter pub add table_calendar    # Para calendário interativo
# ou
flutter pub add flutter_calendar  # Alternativa mais leve
```

### Passo 2: Estrutura do Widget

```dart
StatefulBuilder(
  builder: (context, setModalState) {
    return Column(
      children: [
        // 1. Radio buttons para tipo de seleção
        _buildTipoSelecaoDias(setModalState),
        
        // 2. Seção de horários (compartilhado)
        _buildHorariosPermissao(),
        
        // 3. Seção de dias da semana (condicional)
        if (_tipoSelecaoDias == 'dias_semana')
          _buildDiasSemana(setModalState),
        
        // 4. Seção de dias específicos (condicional)
        if (_tipoSelecaoDias == 'dias_especificos')
          _buildDiasEspecificos(setModalState),
        
        // 5. Botão salvar
        _buildBotaoSalvar(),
      ],
    );
  },
)
```

### Passo 3: Função para Dias da Semana

```dart
Widget _buildDiasSemana(StateSetter setModalState) {
  final dias = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB'];
  final diasCodigo = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Dias da Semana'),
      Wrap(
        children: List.generate(dias.length, (index) {
          final dia = dias[index];
          final codigo = diasCodigo[index];
          
          return Checkbox(
            value: _diasSemanasSelecionados.contains(codigo),
            onChanged: (value) {
              setModalState(() {
                if (value!) {
                  _diasSemanasSelecionados.add(codigo);
                } else {
                  _diasSemanasSelecionados.remove(codigo);
                }
              });
            },
            label: Text(dia),
          );
        }),
      ),
    ],
  );
}
```

### Passo 4: Função para Dias Específicos

```dart
Widget _buildDiasEspecificos(StateSetter setModalState) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Dias Específicos'),
      ElevatedButton.icon(
        icon: Icon(Icons.calendar_today),
        label: Text('Abrir Calendário'),
        onPressed: () => _abrirCalendario(setModalState),
      ),
      if (_diasEspecificosSelecionados.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datas selecionadas:'),
            ..._diasEspecificosSelecionados.map((data) {
              return Text(
                '• ${data.day} de ${_nomesMes[data.month]} de ${data.year}',
              );
            }),
          ],
        ),
    ],
  );
}
```

### Passo 5: Função para Abrir Calendário

```dart
Future<void> _abrirCalendario(StateSetter setModalState) async {
  // Usar table_calendar ou outro widget
  // Abrir em mês atual
  // Permitir multi-seleção
  // Ao confirmar, atualizar _diasEspecificosSelecionados
  
  final result = await showDialog<List<DateTime>>(
    context: context,
    builder: (context) {
      return CalendarioSeletor(
        inicial: _diasEspecificosSelecionados,
        mesInicial: DateTime.now(),
      );
    },
  );
  
  if (result != null) {
    setModalState(() {
      _diasEspecificosSelecionados = result;
    });
  }
}
```

### Passo 6: Validação ao Salvar

```dart
bool _validarPermissoes() {
  // Validar tipo selecionado
  if (_tipoSelecaoDias.isEmpty) {
    _mostrarErro('Selecione um tipo de dia');
    return false;
  }
  
  // Validar dias selecionados
  if (_tipoSelecaoDias == 'dias_semana') {
    if (_diasSemanasSelecionados.isEmpty) {
      _mostrarErro('Selecione pelo menos um dia da semana');
      return false;
    }
  } else if (_tipoSelecaoDias == 'dias_especificos') {
    if (_diasEspecificosSelecionados.isEmpty) {
      _mostrarErro('Selecione pelo menos uma data específica');
      return false;
    }
  }
  
  // Validar horários
  if (_horaInicio.hour >= _horaFim.hour) {
    _mostrarErro('Horário de início deve ser anterior ao fim');
    return false;
  }
  
  return true;
}
```

### Passo 7: Salvamento

```dart
Future<void> _salvarAutorizado() async {
  if (!_validarPermissoes()) return;
  
  final dados = {
    'nome': _nomeController.text,
    'cpf': _cpfController.text,
    'tipo_selecao_dias': _tipoSelecaoDias,
    'dias_semana': _tipoSelecaoDias == 'dias_semana' 
      ? _diasSemanasSelecionados 
      : [],
    'dias_especificos': _tipoSelecaoDias == 'dias_especificos'
      ? _diasEspecificosSelecionados
          .map((d) => d.toIso8601String().split('T')[0])
          .toList()
      : [],
    'horario_inicio': '${_horaInicio.hour}:${_horaInicio.minute}',
    'horario_fim': '${_horaFim.hour}:${_horaFim.minute}',
  };
  
  await AutorizadoInquilinoService.create(dados);
}
```

---

## 🔄 EDIÇÃO DE AUTORIZADO EXISTENTE

Ao abrir modal para editar autorizado:

```dart
void _preencherCamposParaEdicao(AutorizadoInquilino autorizado) {
  _nomeController.text = autorizado.nome;
  _cpfController.text = autorizado.cpf;
  
  // Carregar tipo de seleção
  _tipoSelecaoDias = autorizado.tipoSelecaoDias ?? 'dias_semana';
  
  // Carregar dias da semana
  if (autorizado.diasSemana != null) {
    _diasSemanasSelecionados = List.from(autorizado.diasSemana);
  }
  
  // Carregar dias específicos
  if (autorizado.diasEspecificos != null) {
    _diasEspecificosSelecionados = autorizado.diasEspecificos
        .map((dateStr) => DateTime.parse(dateStr))
        .toList();
  }
  
  // Carregar horários
  // ... (código para parser de horário)
}
```

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

- [ ] Adicionar/modificar colunas no banco de dados
- [ ] Criar widgets para dias da semana
- [ ] Integrar package de calendário
- [ ] Criar widget para seleção de dias específicos
- [ ] Implementar lógica de exclusão mútua (radio buttons)
- [ ] Adicionar validações
- [ ] Modificar método de salvamento
- [ ] Testar seleção de dias da semana
- [ ] Testar seleção de dias específicos
- [ ] Testar alternância entre os dois modos
- [ ] Testar edição de autorizado existente
- [ ] Testar em web e mobile
- [ ] Tratar casos edge (datas no passado, etc)

---

## 📝 MODELO DE DADOS (Dart Class)

```dart
class AutorizadoInquilino {
  final String id;
  final String nome;
  final String cpf;
  final String tipoSelecaoDias; // 'dias_semana' ou 'dias_especificos'
  final List<String> diasSemana; // ['MON', 'TUE', ...]
  final List<String> diasEspecificos; // ['2025-01-15', ...]
  final String horarioInicio; // '08:00'
  final String horarioFim; // '18:00'
  
  AutorizadoInquilino({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.tipoSelecaoDias,
    required this.diasSemana,
    required this.diasEspecificos,
    required this.horarioInicio,
    required this.horarioFim,
  });
}
```

---

## 🎯 CONCLUSÃO

Este plano oferece:

✅ **Exclusão Mútua:** Não é possível selecionar ambos os modos simultaneamente
✅ **UX Clara:** Fluxo intuitivo com radio buttons e calendário
✅ **Flexibilidade:** Suporta ambos os casos de uso
✅ **Validação:** Garante dados válidos antes de salvar
✅ **Persistência:** Dados salvos corretamente no banco
✅ **Edição:** Permite editar autorizados existentes mantendo dados

