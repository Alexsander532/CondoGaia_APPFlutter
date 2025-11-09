# 🔧 BACKEND: Guia de Implementação Passo a Passo

## 📋 Fases de Implementação

Vamos implementar **4 fases** consecutivas:

### Fase 1: Validações ✅ (REVISAR EXISTENTES)
### Fase 2: Mapeamento (ImportacaoRow → Maps DB) 
### Fase 3: Inserção no Supabase (Respeitar ordem)
### Fase 4: Orquestração Completa (Validar → Mapear → Inserir)

---

## 🎯 FASE 1: VALIDAÇÕES

### Validações já existentes no ImportacaoService:
✅ CPF do proprietário válido
✅ Email do proprietário válido
✅ CPF/Email únicos na planilha
✅ CPF/Email únicos no banco

### Validações que PRECISAM ser adicionadas:
- [ ] Validar **Fração Ideal** (0 < valor ≤ 1.0)
- [ ] Validar **Unidade** (não pode estar vazia)
- [ ] Validar CPF inquilino ≠ CPF proprietário
- [ ] Validar CNPJ imobiliária (se informada)
- [ ] Validar telefones (formato)

---

## 🗺️ FASE 2: MAPEAMENTO

### Método esperado:

```dart
/// Mapeia uma ImportacaoRow validada para estrutura de inserção DB
static Map<String, dynamic> mapearParaInsercao(
  ImportacaoRow row, {
  required String condominioId,
}) {
  // 1. UNIDADE
  // 2. PROPRIETARIO (gerar senha)
  // 3. INQUILINO (opcional, gerar senha)
  // 4. IMOBILIARIA (opcional)
  
  return {
    'unidade': {...},
    'proprietario': {...},
    'inquilino': {...},
    'imobiliaria': {...},
  };
}
```

---

## 💾 FASE 3: INSERÇÃO NO SUPABASE

### Ordem OBRIGATÓRIA:

```
1. UNIDADE
   └─ Buscar se existe (numero + condominio_id)
   └─ Se não existe, criar
   └─ Retornar unidade_id

2. PROPRIETARIO
   └─ Usar unidade_id da etapa 1
   └─ Inserir com senha temporária
   └─ Retornar proprietario_id

3. INQUILINO (se houver)
   └─ Usar unidade_id da etapa 1
   └─ Inserir com senha temporária
   └─ Retornar inquilino_id

4. IMOBILIARIA (se houver)
   └─ Inserir sem relação com unidade
   └─ Retornar imobiliaria_id
```

### Métodos esperados:

```dart
// Buscar ou criar unidade
Future<String> _buscarOuCriarUnidade(
  Map<String, dynamic> dadosUnidade,
  String condominioId,
)

// Inserir proprietário
Future<String> _inserirProprietario(
  Map<String, dynamic> dadosProprietario,
)

// Inserir inquilino
Future<String> _inserirInquilino(
  Map<String, dynamic> dadosInquilino,
)

// Inserir imobiliária
Future<String> _inserirImobiliaria(
  Map<String, dynamic> dadosImobiliaria,
)
```

---

## 🎭 FASE 4: ORQUESTRAÇÃO

### Método master:

```dart
Future<ResultadoImportacao> executarImportacao(
  List<ImportacaoRow> rowsValidadas,
  String condominioId,
) async {
  final resultados = [];
  final senhas = [];
  
  for (final row in rowsValidadas) {
    try {
      // 1. Mapear
      final dados = mapearParaInsercao(row, condominioId: condominioId);
      
      // 2. Inserir em ordem
      final unidadeId = await _buscarOuCriarUnidade(dados['unidade'], condominioId);
      final propId = await _inserirProprietario({...dados['proprietario'], 'unidade_id': unidadeId});
      
      // 3. Se houver inquilino
      if (dados['inquilino'] != null) {
        final inqId = await _inserirInquilino({...dados['inquilino'], 'unidade_id': unidadeId});
      }
      
      // 4. Se houver imobiliária
      if (dados['imobiliaria'] != null) {
        await _inserirImobiliaria(dados['imobiliaria']);
      }
      
      // 5. Registrar sucesso + senhas
      resultados.add({
        'linha': row.linhaNumero,
        'status': 'sucesso',
        'senhas': gerouSenhas,
      });
      
    } catch (e) {
      // Registrar erro SEM parar o processamento
      resultados.add({
        'linha': row.linhaNumero,
        'status': 'erro',
        'mensagem': e.toString(),
      });
    }
  }
  
  return ResultadoImportacao(resultados);
}
```

---

## 🔐 GERAÇÃO DE SENHAS

### Função helper:

```dart
String gerarSenhaTemporaria() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
  final random = Random.secure();
  return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
}
```

---

## 📊 ESTRUTURA DE DADOS ESPERADA

### Resultado final:

```dart
{
  'linhaNumero': 3,
  'unidade': {
    'id': 'uuid-novo-ou-existente',
    'numero': '101',
    'bloco': 'A',
    'fracao_ideal': 0.050000,
  },
  'proprietario': {
    'condominio_id': 'uuid-condominio',
    'unidade_id': 'uuid-unidade',
    'nome': 'Nilza Almeida de Araujo',
    'cpf_cnpj': '01710482109',
    'email': 'nilza326@gmail.com',
    'celular': '11987654321',
    'senha_acesso': 'K7x2pQmL',  // GERADA
    'ativo': true,
  },
  'inquilino': null, // ou com dados
  'imobiliaria': null, // ou com dados
}
```

---

## 🛡️ TRATAMENTO DE ERROS

### Por linha:
- Se unidade falhar → parar essa linha, próxima
- Se proprietário falhar → não inserir inquilino/imob dessa linha
- Registrar erro com mensagem clara
- **Continuar processando outras linhas**

### Mensagens esperadas:
```
Linha 3: Falha ao criar unidade - [erro do DB]
Linha 4: Falha ao inserir proprietário - Email já existe
Linha 5: Sucesso!
```

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

- [ ] **Fase 1**: Validações adicionadas
- [ ] **Fase 2**: Método mapearParaInsercao() criado
- [ ] **Fase 3**: Funções de inserção Supabase implementadas
- [ ] **Fase 4**: Orquestração completa funciona
- [ ] **Testes**: Testar com 3-4 linhas de exemplo
- [ ] **Feedback**: Usuário recebe resultado detalhado

---

## 🚀 Próximo Passo

Vamos começar pela **Fase 1: Revisar e adicionar validações faltantes** no ImportacaoService.

Quer que eu comece?

