# 🔧 FASE 3: INSERÇÃO NO SUPABASE - IMPLEMENTADO ✅

## 📝 O que foi feito

Implementado o arquivo `ImportacaoInsercaoService` com funções para inserir dados no Supabase respeitando a ordem correta.

---

## 📂 Novo Arquivo

**`lib/services/importacao_insercao_service.dart`**

Contém:
- Classe `ResultadoInsercao` - Para retornar sucesso/erro
- Classe `ImportacaoInsercaoService` - Com métodos de inserção

---

## 🎯 Métodos Implementados

### 1️⃣ `buscarOuCriarUnidade()`

```dart
static Future<ResultadoInsercao> buscarOuCriarUnidade(
  Map<String, dynamic> dadosUnidade,
)
```

**O que faz:**
1. Tenta buscar unidade existente (numero + condominio_id)
2. Se encontrar → retorna seu ID
3. Se não encontrar → cria nova e retorna ID

**Entrada:**
```dart
{
  'numero': '101',
  'bloco': 'A',
  'fracao_ideal': 0.050000,
  'condominio_id': 'uuid-condominio',
  'tipo_unidade': 'A',
  'ativo': true,
  // ... mais campos
}
```

**Saída:**
```dart
ResultadoInsercao(
  sucesso: true,
  id: 'uuid-unidade-novo-ou-existente',
  linhaNumero: 3,
)
```

---

### 2️⃣ `inserirProprietario()`

```dart
static Future<ResultadoInsercao> inserirProprietario(
  Map<String, dynamic> dadosProprietario,
  String unidadeId,
)
```

**O que faz:**
1. Recebe dados do proprietário + unidade_id
2. Insere na tabela proprietarios
3. Retorna ID do proprietário inserido

**Entrada:**
```dart
{
  'condominio_id': 'uuid-condominio',
  'nome': 'Nilza Almeida de Araujo',
  'cpf_cnpj': '01710482109',
  'email': 'nilza326@gmail.com',
  'celular': '11987654321',
  'senha_acesso': 'K7x2pQmL',
  'ativo': true,
  // ... mais campos
},
unidadeId: 'uuid-unidade'
```

**Saída:**
```dart
ResultadoInsercao(
  sucesso: true,
  id: 'uuid-proprietario',
  linhaNumero: 3,
)
```

---

### 3️⃣ `inserirInquilino()` (OPCIONAL)

```dart
static Future<ResultadoInsercao?> inserirInquilino(
  Map<String, dynamic>? dadosInquilino,
  String unidadeId,
)
```

**O que faz:**
1. Se `dadosInquilino` é null → retorna null
2. Se tem dados → insere na tabela inquilinos
3. Retorna ID do inquilino inserido

**Entrada:**
```dart
{
  'condominio_id': 'uuid-condominio',
  'nome': 'João Silva',
  'cpf_cnpj': '98765432100',
  'email': 'joao@email.com',
  'senha_acesso': 'Tp9vRsWx',
  'receber_boleto_email': true,
  'controle_locacao': true,
  // ...
},
unidadeId: 'uuid-unidade'
```

**Saída:**
```dart
ResultadoInsercao(  // ou null se não havia dados
  sucesso: true,
  id: 'uuid-inquilino',
  linhaNumero: 3,
)
```

---

### 4️⃣ `inserirImobiliaria()` (OPCIONAL)

```dart
static Future<ResultadoInsercao?> inserirImobiliaria(
  Map<String, dynamic>? dadosImobiliaria,
)
```

**O que faz:**
1. Se `dadosImobiliaria` é null → retorna null
2. Tenta buscar imobiliária existente (cnpj + condominio_id)
3. Se encontrar → retorna seu ID
4. Se não encontrar → cria nova e retorna ID

**Entrada:**
```dart
{
  'condominio_id': 'uuid-condominio',
  'nome': 'Imobiliária XYZ',
  'cnpj': '12345678000195',
  'email': 'contato@imobiliaria.com',
  'celular': '1133334444',
  'telefone': null,
  'ativo': true,
},
```

**Saída:**
```dart
ResultadoInsercao(  // ou null se não havia dados
  sucesso: true,
  id: 'uuid-imobiliaria-novo-ou-existente',
  linhaNumero: 3,
)
```

---

### 5️⃣ `processarLinhaCompleta()` (ORQUESTRAÇÃO)

```dart
static Future<Map<String, dynamic>> processarLinhaCompleta(
  Map<String, dynamic> dadosLinhaFormatada,
)
```

**O que faz:**
1. Executa todas as 4 etapas de inserção em ordem
2. Respeita dependências (unidade → prop → inq → imob)
3. Se algo falhar, para e retorna erro
4. Retorna resultado completo com IDs gerados e senhas

**Entrada:**
```dart
{
  'linhaNumero': 3,
  'unidade': {...},
  'proprietario': {...},
  'inquilino': {...},  // ou null
  'imobiliaria': {...},  // ou null
  'senhas': {
    'proprietario': 'K7x2pQmL',
    'inquilino': 'Tp9vRsWx',
  },
}
```

**Saída (sucesso):**
```dart
{
  'linhaNumero': 3,
  'sucesso': true,
  'erro': null,
  'ids': {
    'unidade': 'uuid-unidade',
    'proprietario': 'uuid-proprietario',
    'inquilino': 'uuid-inquilino',  // ou null
    'imobiliaria': 'uuid-imobiliaria',  // ou null
  },
  'senhas': {
    'proprietario': 'K7x2pQmL',
    'inquilino': 'Tp9vRsWx',
  },
}
```

**Saída (erro):**
```dart
{
  'linhaNumero': 3,
  'sucesso': false,
  'erro': 'Erro ao inserir proprietário: Email já existe',
  'senhas': null,
}
```

---

## 🔄 Fluxo de Execução

```
1. UNIDADE
   ├─ Buscar por (numero, condominio_id)
   ├─ Se existe → retorna ID existente
   └─ Se não existe → cria nova
           ↓
2. PROPRIETARIO
   ├─ Usar unidade_id da etapa 1
   └─ Inserir (email, cpf já foram validados)
           ↓
3. INQUILINO (se houver)
   ├─ Usar unidade_id da etapa 1
   └─ Inserir (ou null se não houver)
           ↓
4. IMOBILIARIA (se houver)
   ├─ Buscar por (cnpj, condominio_id)
   ├─ Se existe → retorna ID
   └─ Se não existe → cria nova
           ↓
✅ LINHA COMPLETA COM SUCESSO
   - IDs de tudo inserido
   - Senhas geradas
```

---

## 🛡️ Tratamento de Erros

### Por etapa:
- Se **unidade** falha → para a linha, retorna erro
- Se **proprietário** falha → para a linha, retorna erro
- Se **inquilino** falha → para a linha, retorna erro
- Se **imobiliária** falha → para a linha, retorna erro

### Mensagens de erro claras:
```
Erro ao criar unidade: [mensagem do Supabase]
Erro ao inserir proprietário: Email já existe no sistema
Erro ao inserir inquilino: CPF já existe no sistema
Erro ao inserir imobiliária: CNPJ inválido
```

---

## 💡 Exemplo de Uso Completo

```dart
// 1. Dados já validados e mapeados (vem da Fase 2)
final dadosLinhaFormatada = ImportacaoService.mapearParaInsercao(
  row,
  condominioId: 'uuid-condominio',
);

// 2. Processar linha completa (inserir tudo em ordem)
final resultado = await ImportacaoInsercaoService.processarLinhaCompleta(
  dadosLinhaFormatada,
);

// 3. Verificar resultado
if (resultado['sucesso']) {
  print('✅ Linha processada com sucesso!');
  print('   Unidade: ${resultado['ids']['unidade']}');
  print('   Proprietário: ${resultado['ids']['proprietario']}');
  print('   Inquilino: ${resultado['ids']['inquilino']}');
  print('   Imobiliária: ${resultado['ids']['imobiliaria']}');
  print('   Senhas: ${resultado['senhas']}');
} else {
  print('❌ Erro: ${resultado['erro']}');
}
```

---

## 📊 Classe ResultadoInsercao

```dart
class ResultadoInsercao {
  final bool sucesso;
  final String? id;          // ID do inserido
  final String? erro;        // Mensagem de erro
  final int? linhaNumero;    // Para rastreabilidade

  ResultadoInsercao({
    required this.sucesso,
    this.id,
    this.erro,
    this.linhaNumero,
  });

  @override
  String toString() => sucesso
      ? 'Sucesso: $id'
      : 'Erro (linha $linhaNumero): $erro';
}
```

---

## 🚀 Próximo Passo

**Fase 4: Orquestração Completa**

Vamos criar um método que:
1. Valida todas as linhas (Fase 1 - já existe)
2. Mapeia todas as linhas (Fase 2 - já existe)
3. Insere todas as linhas (Fase 3 - acabamos de fazer)
4. Retorna relatório completo para o usuário

Com isso, o flow completo de importação será funcional!

