# 🎯 FASE 2: MAPEAMENTO DE DADOS - IMPLEMENTADO ✅

## 📝 O que foi feito

Implementado o método `mapearParaInsercao()` no `ImportacaoService` que transforma uma `ImportacaoRow` validada em estrutura pronta para inserção no Supabase.

---

## 🔧 Método Principal

```dart
static Map<String, dynamic> mapearParaInsercao(
  ImportacaoRow row, {
  required String condominioId,
)
```

### Entrada:
- `ImportacaoRow` validada (sem erros)
- `condominioId` (vem do contexto/usuário logado)

### Saída:
```dart
{
  'linhaNumero': 3,
  'unidade': {
    'numero': '101',
    'bloco': 'A',
    'fracao_ideal': 0.050000,
    'condominio_id': 'uuid-condominio',
    'tipo_unidade': 'A',
    'ativo': true,
    // ... mais campos com defaults
  },
  'proprietario': {
    'condominio_id': 'uuid-condominio',
    'nome': 'Nilza Almeida de Araujo',
    'cpf_cnpj': '01710482109',
    'celular': '11987654321',
    'email': 'nilza326@gmail.com',
    'senha_acesso': 'K7x2pQmL',  // 🔐 GERADA AQUI
    'ativo': true,
    // ... mais campos como null
  },
  'inquilino': {
    'condominio_id': 'uuid-condominio',
    'nome': 'João Silva',
    'cpf_cnpj': '98765432100',
    'celular': '11912345678',
    'email': 'joao@email.com',
    'senha_acesso': 'Tp9vRsWx',  // 🔐 GERADA AQUI
    'receber_boleto_email': true,
    'controle_locacao': true,
    'ativo': true,
    // ... mais campos como null
  },
  'imobiliaria': {
    'condominio_id': 'uuid-condominio',
    'nome': 'Imobiliária XYZ',
    'cnpj': '12345678000195',
    'celular': '1133334444',
    'email': 'contato@imobiliaria.com',
    'telefone': null,
    'ativo': true,
  },
  'senhas': {
    'proprietario': 'K7x2pQmL',
    'inquilino': 'Tp9vRsWx',
  },
}
```

---

## 📊 O que o método faz

### 1️⃣ Limpeza de Dados
- Remove caracteres especiais de CPF/CNPJ
- Converte emails para lowercase
- Remove espaços em branco
- Formata telefones

### 2️⃣ UNIDADE
Mapeia campos:
```
row.bloco         → campos.bloco         (Se vazio → "A")
row.unidade       → campos.numero
row.fracaoIdeal   → campos.fracao_ideal  (parseado de string para double)
```

Adiciona defaults:
- `tipo_unidade`: "A"
- `ativo`: true
- `isencao_nenhum`: true
- `isencao_total`, `isencao_cota`, `isencao_fundo_reserva`: false
- `acao_judicial`, `correios`: false
- `nome_pagador_boleto`: "proprietario"

### 3️⃣ PROPRIETARIO
Mapeia campos:
```
row.proprietarioNomeCompleto  → nome
row.proprietarioCpf           → cpf_cnpj
row.proprietarioCel           → celular
row.proprietarioEmail         → email
```

**🔐 Gera senha temporária** (8 caracteres alfanuméricos)

Adiciona:
- `condominio_id`: vem como parâmetro
- `ativo`: true
- Campos opcionais como null: cep, endereco, numero, complemento, bairro, cidade, estado, telefone, conjuge, multiproprietarios, moradores, foto_perfil

### 4️⃣ INQUILINO (OPCIONAL)
Se `inquilinoNomeCompleto` está preenchido:

Mapeia campos:
```
row.inquilinoNomeCompleto  → nome
row.inquilinoCpf           → cpf_cnpj
row.inquilinoCel           → celular
row.inquilinoEmail         → email
```

**🔐 Gera senha temporária** (8 caracteres alfanuméricos)

Adiciona:
- `condominio_id`: vem como parâmetro
- `receber_boleto_email`: true
- `controle_locacao`: true
- `ativo`: true
- Campos opcionais como null

Se não há dados de inquilino → `'inquilino': null`

### 5️⃣ IMOBILIARIA (OPCIONAL)
Se `nomeImobiliaria` está preenchido:

Mapeia campos:
```
row.nomeImobiliaria   → nome
row.cnpjImobiliaria   → cnpj
row.celImobiliaria    → celular
row.emailImobiliaria  → email
```

Adiciona:
- `condominio_id`: vem como parâmetro
- `telefone`: null
- `ativo`: true

Se não há dados de imobiliária → `'imobiliaria': null`

### 6️⃣ SENHAS
Retorna objeto com as senhas geradas:
```dart
'senhas': {
  'proprietario': 'K7x2pQmL',
  'inquilino': 'Tp9vRsWx',  // null se não houver inquilino
}
```

---

## 🔐 Geração de Senhas

### Função Helper: `_parsearFracaoIdeal()`
```dart
static double? _parsearFracaoIdeal(String? fracao)
```

- Converte string para double
- Suporta vírgula ou ponto como separador decimal
- Valida que está entre 0 e 1.0
- Retorna null se inválido

### Senhas Temporárias
- Geradas usando `GeradorSenha.gerarSimples()`
- 8 caracteres alfanuméricos (A-Z, a-z, 0-9)
- Uma por proprietário
- Uma por inquilino (se houver)

---

## 💡 Exemplo de Uso

```dart
// Em ImportacaoService ou onde for chamar
final row = _rowsValidadas[0]; // ImportacaoRow validada

final dadosParaInserir = ImportacaoService.mapearParaInsercao(
  row,
  condominioId: 'uuid-do-condominio',
);

// Agora temos:
final unidade = dadosParaInserir['unidade'];
final proprietario = dadosParaInserir['proprietario'];
final inquilino = dadosParaInserir['inquilino'];
final imobiliaria = dadosParaInserir['imobiliaria'];
final senhas = dadosParaInserir['senhas'];

// Pronto para inserir no Supabase!
```

---

## ✅ Tratamentos Especiais

### Valores Null/Vazios
- Se `inquilino` vazio → `'inquilino': null`
- Se `imobiliaria` vazio → `'imobiliaria': null`
- Se campo opcional vazio → `null` (não string vazia)

### Bloco Padrão
- Se `bloco` vazio ou null → "A"

### Fração Ideal
- Se vazio → `null`
- Se preenchido mas inválido → `null`
- Se válido → `double` (ex: 0.050000)

### Emails
- Sempre lowercase
- Vazio → `null`

### Telefones
- Apenas dígitos (sem caracteres especiais)
- Vazio → `null`

---

## 📌 Próximo Passo

**Fase 3: Implementar Inserção no Supabase**

Precisamos criar métodos para:
1. Buscar ou criar UNIDADE
2. Inserir PROPRIETARIO
3. Inserir INQUILINO (se houver)
4. Inserir IMOBILIARIA (se houver)

Com respeito à ordem e tratamento de erros por linha.

