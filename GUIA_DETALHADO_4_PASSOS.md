# 📚 GUIA DETALHADO - 4 PASSOS DE IMPLEMENTAÇÃO

---

## ✅ PASSO 1: MODIFICAR O BANCO DE DADOS

### O QUE FAZER:

Adicionar 3 novas colunas na tabela `autorizados_inquilino` para armazenar o tipo de seleção e os dias.

### COMANDO SQL:

```sql
-- 1. Adicionar coluna de tipo de seleção
ALTER TABLE autorizados_inquilino 
ADD COLUMN tipo_selecao_dias VARCHAR(20) 
DEFAULT 'dias_semana' 
CHECK (tipo_selecao_dias IN ('dias_semana', 'dias_especificos'));

-- 2. Adicionar coluna para dias da semana (JSON)
ALTER TABLE autorizados_inquilino 
ADD COLUMN dias_semana JSONB 
DEFAULT '["MON", "TUE", "WED", "THU", "FRI"]';

-- 3. Adicionar coluna para dias específicos (JSON)
ALTER TABLE autorizados_inquilino 
ADD COLUMN dias_especificos JSONB 
DEFAULT '[]';
```

### EXPLICAÇÃO:

- **`tipo_selecao_dias`**: Armazena qual modo está ativo
  - `'dias_semana'` = Usuário selecionou dias da semana (SEG, TER, etc)
  - `'dias_especificos'` = Usuário selecionou datas específicas

- **`dias_semana`**: Array JSON com abreviações de dias
  - Exemplo: `["MON", "TUE", "WED", "THU", "FRI"]`
  - Possíveis valores: MON, TUE, WED, THU, FRI, SAT, SUN

- **`dias_especificos`**: Array JSON com datas em formato ISO
  - Exemplo: `["2025-01-15", "2025-01-20", "2025-02-05"]`
  - Formato: YYYY-MM-DD

### ESTRUTURA FINAL NO BANCO:

```
ANTES (sem essas colunas):
┌─────────────────────────────────────┐
│ autorizados_inquilino               │
├─────────────────────────────────────┤
│ id                                  │
│ nome                                │
│ cpf                                 │
│ unidade_id                          │
│ horario_inicio    (ex: 08:00)       │
│ horario_fim       (ex: 18:00)       │
└─────────────────────────────────────┘

DEPOIS (com as novas colunas):
┌─────────────────────────────────────────────────────┐
│ autorizados_inquilino                               │
├─────────────────────────────────────────────────────┤
│ id                                                  │
│ nome                                                │
│ cpf                                                 │
│ unidade_id                                          │
│ horario_inicio         (ex: 08:00)                 │
│ horario_fim            (ex: 18:00)                 │
│ tipo_selecao_dias      (NEW) ← 'dias_semana'       │
│ dias_semana            (NEW) ← ['MON','TUE',...]   │
│ dias_especificos       (NEW) ← ['2025-01-15',...]  │
└─────────────────────────────────────────────────────┘
```

### EXEMPLOS DE REGISTROS:

**Registro 1 - Modo Dias da Semana:**
```json
{
  "id": "auth-001",
  "nome": "João Silva",
  "cpf": "123.456.789-00",
  "unidade_id": "unit-123",
  "horario_inicio": "08:00",
  "horario_fim": "18:00",
  "tipo_selecao_dias": "dias_semana",
  "dias_semana": ["MON", "TUE", "WED", "THU", "FRI"],
  "dias_especificos": []
}
```

**Registro 2 - Modo Dias Específicos:**
```json
{
  "id": "auth-002",
  "nome": "Maria Santos",
  "cpf": "987.654.321-00",
  "unidade_id": "unit-456",
  "horario_inicio": "09:00",
  "horario_fim": "17:00",
  "tipo_selecao_dias": "dias_especificos",
  "dias_semana": [],
  "dias_especificos": ["2025-01-15", "2025-01-20", "2025-02-05"]
}
```

---

## ✅ PASSO 2: IMPLEMENTAR UI NO MODAL

### O QUE FAZER:

Modificar o modal "Adicionar Autorizado" para incluir:
1. Radio buttons para escolher tipo de seleção
2. UI condicional (mostrar/esconder conforme seleção)
3. Checkboxes para dias da semana
4. Botão para abrir calendário

### ARQUIVO A MODIFICAR:

`lib/screens/portaria_inquilino_screen.dart` (linha ~1386 no método `_showAdicionarAutorizadoModal`)

### ESTRUTURA DO CÓDIGO:

```dart
// NO TOPO DA CLASSE (adicionar variáveis de estado)
String _tipoSelecaoDias = 'dias_semana'; // Modo atual
List<String> _diasSemanasSelecionados = ['MON', 'TUE', 'WED', 'THU', 'FRI']; // Dias semana selecionados
List<DateTime> _diasEspecificosSelecionados = []; // Datas específicas selecionadas

// Mapa para nomes dos dias
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

### ONDE INSERIR:

No método `_showAdicionarAutorizadoModal`, **DEPOIS da seção "Horários permitida a entrada"** e **ANTES da seção "Permissões"**, adicionar:

```dart
// ===== NOVO CÓDIGO =====
// Seção: Tipo de Seleção de Dias
_buildSectionTitle('Tipo de Seleção de Dias'),
const SizedBox(height: 12),

// Radio 1: Dias da semana
RadioListTile<String>(
  title: const Text('Dias da semana (repetidos semanalmente)'),
  value: 'dias_semana',
  groupValue: _tipoSelecaoDias,
  onChanged: (value) {
    setModalState(() {
      _tipoSelecaoDias = value!;
      // Limpar seleção de dias específicos
      _diasEspecificosSelecionados.clear();
    });
  },
  activeColor: const Color(0xFF4A90E2),
),

// Radio 2: Dias específicos
RadioListTile<String>(
  title: const Text('Dia(s) específico(s)'),
  value: 'dias_especificos',
  groupValue: _tipoSelecaoDias,
  onChanged: (value) {
    setModalState(() {
      _tipoSelecaoDias = value!;
      // Limpar seleção de dias da semana
      _diasSemanasSelecionados.clear();
    });
  },
  activeColor: const Color(0xFF4A90E2),
),

const SizedBox(height: 20),

// Seção CONDICIONAL: Dias da semana (só mostra se modo = 'dias_semana')
if (_tipoSelecaoDias == 'dias_semana')
  _buildDiasSemanaUI(setModalState),

// Seção CONDICIONAL: Dias específicos (só mostra se modo = 'dias_especificos')
if (_tipoSelecaoDias == 'dias_especificos')
  _buildDiasEspecificosUI(setModalState),

const SizedBox(height: 20),
// ===== FIM DO NOVO CÓDIGO =====
```

### VISUAL ESPERADO:

```
┌─────────────────────────────────────────┐
│ Tipo de Seleção de Dias                 │
├─────────────────────────────────────────┤
│                                         │
│ ⦿ Dias da semana (repetidos semanalmente)
│                                         │
│ ○ Dia(s) específico(s)                  │
│                                         │
└─────────────────────────────────────────┘
```

---

## ✅ PASSO 3: ADICIONAR LÓGICA DE EXCLUSÃO MÚTUA

### O QUE FAZER:

Garantir que:
- ✅ Quando usuário clica em um radio, o outro é deseleccionado automaticamente
- ✅ Dados do modo não selecionado são limpos
- ✅ UI muda dinamicamente (mostra/esconde seções)

### CÓDIGO JÁ ESTÁ NO PASSO 2!

No código do Passo 2, observe os `onChanged`:

```dart
// Radio 1: Dias da semana
onChanged: (value) {
  setModalState(() {
    _tipoSelecaoDias = value!;              // ← Muda o modo
    _diasEspecificosSelecionados.clear();   // ← Limpa dados do outro
  });
}

// Radio 2: Dias específicos
onChanged: (value) {
  setModalState(() {
    _tipoSelecaoDias = value!;              // ← Muda o modo
    _diasSemanasSelecionados.clear();       // ← Limpa dados do outro
  });
}
```

### FLUXO DE FUNCIONAMENTO:

```
ESTADO INICIAL:
_tipoSelecaoDias = 'dias_semana'
_diasSemanasSelecionados = ['MON', 'TUE', 'WED', 'THU', 'FRI']
_diasEspecificosSelecionados = []

┌─ Usuário clica em "Dia(s) específico(s)"
│
▼ Executar onChanged()
│
├─ setModalState(() { ... })
│  ├─ _tipoSelecaoDias = 'dias_especificos'  ← Novo modo
│  └─ _diasSemanasSelecionados.clear()       ← Limpa dados antigos
│
▼ Widget reconstruído
│
├─ if (_tipoSelecaoDias == 'dias_semana')    ← FALSE, não renderiza
├─ if (_tipoSelecaoDias == 'dias_especificos') ← TRUE, renderiza calendário
│
▼ Tela atualizada
UI mostra calendário em vez de checkboxes
```

### COMPORTAMENTO VISUAL:

```
ANTES (modo dias_semana selecionado):
┌─────────────────────────────────────────┐
│ ⦿ Dias da semana                        │
│ ○ Dia(s) específico(s)                  │
├─────────────────────────────────────────┤
│ Dias da Semana:                         │
│ ☑ DOM  ☑ SEG  ☑ TER  ☑ QUA             │
│ ☑ QUI  ☑ SEX  ☐ SAB                    │
└─────────────────────────────────────────┘

DEPOIS (usuário clica em "Dia(s) específico(s)"):
┌─────────────────────────────────────────┐
│ ○ Dias da semana                        │
│ ⦿ Dia(s) específico(s)                  │
├─────────────────────────────────────────┤
│ [📅 Abrir Calendário]                   │
│                                         │
│ Datas selecionadas:                     │
│ (nenhuma ainda)                         │
└─────────────────────────────────────────┘
```

---

## ✅ PASSO 4: IMPLEMENTAR CALENDÁRIO E SALVAMENTO

### O QUE FAZER:

1. Instalar package de calendário
2. Criar funções auxiliares para UI
3. Modificar método de salvamento
4. Adicionar validações

### 4.1 INSTALAR PACKAGE

No terminal, rodar:
```bash
flutter pub add table_calendar
```

### 4.2 CRIAR FUNÇÕES AUXILIARES

Adicionar essas funções **antes do fechamento da classe** em `portaria_inquilino_screen.dart`:

#### Função para renderizar Dias da Semana:

```dart
/// Widget para seleção de dias da semana
Widget _buildDiasSemanaUI(StateSetter setModalState) {
  final dias = ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB'];
  final diasCodigo = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionTitle('Dias da Semana'),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: List.generate(dias.length, (index) {
          final dia = dias[index];
          final codigo = diasCodigo[index];
          final isSelected = _diasSemanasSelecionados.contains(codigo);
          
          return FilterChip(
            label: Text(dia),
            selected: isSelected,
            onSelected: (selected) {
              setModalState(() {
                if (selected) {
                  _diasSemanasSelecionados.add(codigo);
                } else {
                  _diasSemanasSelecionados.remove(codigo);
                }
              });
            },
            backgroundColor: Colors.grey[200],
            selectedColor: const Color(0xFF4A90E2),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          );
        }),
      ),
      const SizedBox(height: 8),
      Text(
        'Selecionados: ${_diasSemanasSelecionados.length} dia(s)',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
    ],
  );
}
```

#### Função para renderizar Dias Específicos:

```dart
/// Widget para seleção de dias específicos
Widget _buildDiasEspecificosUI(StateSetter setModalState) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionTitle('Dias Específicos'),
      const SizedBox(height: 12),
      
      ElevatedButton.icon(
        icon: const Icon(Icons.calendar_today),
        label: const Text('Abrir Calendário'),
        onPressed: () => _abrirCalendario(setModalState),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
        ),
      ),
      
      const SizedBox(height: 16),
      
      // Exibir datas selecionadas
      if (_diasEspecificosSelecionados.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datas selecionadas (${_diasEspecificosSelecionados.length}):',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _diasEspecificosSelecionados
                    .map((data) {
                      final formatted = '${data.day.toString().padLeft(2, '0')}/'
                          '${data.month.toString().padLeft(2, '0')}/'
                          '${data.year}';
                      
                      return Chip(
                        label: Text(formatted),
                        onDeleted: () {
                          setModalState(() {
                            _diasEspecificosSelecionados.remove(data);
                          });
                        },
                        backgroundColor: const Color(0xFF4A90E2),
                        labelStyle: const TextStyle(color: Colors.white),
                      );
                    })
                    .toList(),
              ),
            ),
          ],
        )
      else
        Text(
          'Nenhuma data selecionada',
          style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
        ),
    ],
  );
}
```

#### Função para abrir Calendário:

```dart
/// Abre o calendário para seleção de datas
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

/// Constrói o dialog do calendário
Widget _buildCalendarioDialog() {
  DateTime selectedDate = DateTime.now();
  List<DateTime> selectedDates = List.from(_diasEspecificosSelecionados);
  
  return StatefulBuilder(
    builder: (context, setState) {
      return AlertDialog(
        title: const Text('Selecionar Datas'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mês/Ano
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    '${selectedDate.month}/${selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Grid de dias
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                  ),
                  itemCount: _getDiasDoMes(selectedDate),
                  itemBuilder: (context, index) {
                    final dia = index + 1;
                    final data = DateTime(selectedDate.year, selectedDate.month, dia);
                    final isSelected = selectedDates.any((d) =>
                        d.year == data.year &&
                        d.month == data.month &&
                        d.day == data.day);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedDates.removeWhere((d) =>
                                d.year == data.year &&
                                d.month == data.month &&
                                d.day == data.day);
                          } else {
                            selectedDates.add(data);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4A90E2)
                              : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            dia.toString(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Datas selecionadas
                if (selectedDates.isNotEmpty)
                  Text(
                    '${selectedDates.length} data(s) selecionada(s)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedDates),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      );
    },
  );
}

/// Retorna número de dias do mês
int _getDiasDoMes(DateTime data) {
  if (data.month == 12) {
    return 31;
  }
  return DateTime(data.year, data.month + 1, 0).day;
}
```

### 4.3 MODIFICAR MÉTODO DE SALVAMENTO

No método `_adicionarAutorizado()` ou `_salvarAutorizado()`, adicionar validação e preparar dados:

```dart
/// Valida dados de permissões
bool _validarPermissoes() {
  // Validar tipo selecionado
  if (_tipoSelecaoDias.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selecione um tipo de dia')),
    );
    return false;
  }
  
  // Validar dias selecionados
  if (_tipoSelecaoDias == 'dias_semana') {
    if (_diasSemanasSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um dia da semana')),
      );
      return false;
    }
  } else if (_tipoSelecaoDias == 'dias_especificos') {
    if (_diasEspecificosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos uma data')),
      );
      return false;
    }
  }
  
  return true;
}

/// Prepara dados para salvar
Map<String, dynamic> _prepararDadosPermissoes() {
  List<String> diasEspecificosFormatados = [];
  
  if (_tipoSelecaoDias == 'dias_especificos') {
    diasEspecificosFormatados = _diasEspecificosSelecionados
        .map((d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}')
        .toList();
  }
  
  return {
    'tipo_selecao_dias': _tipoSelecaoDias,
    'dias_semana': _tipoSelecaoDias == 'dias_semana' 
        ? _diasSemanasSelecionados 
        : [],
    'dias_especificos': _tipoSelecaoDias == 'dias_especificos'
        ? diasEspecificosFormatados
        : [],
    'horario_inicio': _horaInicio,
    'horario_fim': _horaFim,
  };
}

/// Modificar método de adição (usar as funções acima)
Future<void> _adicionarAutorizado() async {
  try {
    // Validar
    if (!_validarPermissoes()) return;
    
    // Preparar dados
    final permissoes = _prepararDadosPermissoes();
    
    final dados = {
      'nome': _nomeController.text,
      'cpf': _cpfController.cpf,
      'unidade_id': widget.unidadeId,
      ...permissoes,
    };
    
    // Salvar
    await AutorizadoInquilinoService.insertAutorizado(dados);
    
    // Feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Autorizado adicionado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
      await _carregarAutorizados();
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### 4.4 EDIÇÃO DE AUTORIZADO EXISTENTE

No método `_preencherCamposParaEdicao()`, adicionar:

```dart
void _preencherCamposParaEdicao(AutorizadoInquilino autorizado) {
  _nomeController.text = autorizado.nome;
  _cpfController.text = autorizado.cpf ?? '';
  _parentescoController.text = autorizado.parentesco ?? '';
  
  // NOVO: Carregar tipo de seleção e dias
  _tipoSelecaoDias = autorizado.tipoSelecaoDias ?? 'dias_semana';
  
  if (autorizado.diasSemana != null && autorizado.diasSemana!.isNotEmpty) {
    _diasSemanasSelecionados = List.from(autorizado.diasSemana ?? []);
  }
  
  if (autorizado.diasEspecificos != null && autorizado.diasEspecificos!.isNotEmpty) {
    _diasEspecificosSelecionados = (autorizado.diasEspecificos ?? [])
        .map((dateStr) => DateTime.parse(dateStr))
        .toList();
  }
}
```

---

## 📊 RESUMO VISUAL DOS 4 PASSOS

```
PASSO 1: BANCO DE DADOS
┌──────────────────────────────────┐
│ Adicionar 3 colunas na tabela    │
│ - tipo_selecao_dias              │
│ - dias_semana (JSON)             │
│ - dias_especificos (JSON)        │
└──────────────────────────────────┘
           ↓
PASSO 2: UI DO MODAL
┌──────────────────────────────────┐
│ Adicionar Radio Buttons:         │
│ ⦿ Dias da semana                 │
│ ○ Dias específicos               │
│                                  │
│ Conteúdo condicional (if/else)   │
└──────────────────────────────────┘
           ↓
PASSO 3: LÓGICA EXCLUSIVA
┌──────────────────────────────────┐
│ onChanged() dos radio buttons:    │
│ 1. Muda _tipoSelecaoDias         │
│ 2. Limpa dados do outro modo     │
│ 3. setModalState() atualiza UI   │
└──────────────────────────────────┘
           ↓
PASSO 4: CALENDÁRIO E SALVAMENTO
┌──────────────────────────────────┐
│ 1. Instalar table_calendar       │
│ 2. Criar funções auxiliares      │
│ 3. Validar dados                 │
│ 4. Salvar com formatos corretos  │
└──────────────────────────────────┘
```

---

## ✨ CHECKLIST DE CÓDIGO

Após implementar os 4 passos, você terá:

- [ ] 3 novas colunas no banco (Passo 1)
- [ ] 2 Radio Buttons funcional (Passo 2)
- [ ] Lógica de exclusão mútua (Passo 3)
- [ ] 2 funções de UI (dias_semana + dias_especificos) (Passo 4)
- [ ] 1 calendário funcional (Passo 4)
- [ ] 1 validação de dados (Passo 4)
- [ ] 1 método de preparação de dados (Passo 4)
- [ ] Salvamento funcionando para ambos os modos (Passo 4)
- [ ] Edição de autorizado carregando dados (Passo 4)

**Total: ~300-400 linhas de código novo**

