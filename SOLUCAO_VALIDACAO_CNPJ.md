# ✅ Solução: Validação de CNPJ na Criação de Imobiliária

## 🔴 Problema Identificado

Ao tentar salvar uma imobiliária, o sistema retornava erro:
```
PostgrestException(message: new row for relation "imobiliarias" 
violates check constraint "chk_imobiliarias_cnpj_valido", code: 23514)
```

**Causa:** O CNPJ estava sendo enviado sem validação do formato correto.

O banco de dados tem um constraint `chk_imobiliarias_cnpj_valido` que valida o CNPJ usando a função `validar_cpf_cnpj()`. Este constraint rejeita CNPJs inválidos.

---

## ✅ Solução Implementada

### 1. **Adicionar Import do Formatters**
No arquivo `detalhes_unidade_screen.dart`, foi adicionado:
```dart
import '../utils/formatters.dart';
```

### 2. **Adicionar Validação de CNPJ em `_salvarImobiliaria()`**
Antes de tentar criar a imobiliária, agora o sistema valida:

```dart
// Validar formato do CNPJ
if (!Formatters.isValidCNPJ(_imobiliariaCnpjController.text.trim())) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('CNPJ inválido. Verifique se o número está correto.'),
      backgroundColor: Colors.orange,
    ),
  );
  setState(() {
    _isLoadingImobiliaria = false;
  });
  return;
}
```

### 3. **Como a Validação Funciona**

A função `Formatters.isValidCNPJ()` em `lib/utils/formatters.dart`:
- Remove formatação (mantém apenas dígitos)
- Verifica se tem exatamente **14 dígitos**
- Verifica se não são todos dígitos iguais
- Valida os dígitos verificadores usando o algoritmo oficial

**Formato aceito:**
- `11222333000181` ✅ (14 dígitos sem formatação)
- `11.222.333/0001-81` ✅ (14 dígitos com formatação)
- `55555555555` ❌ (11 dígitos - CPF, não CNPJ)
- `2222222222222222222` ❌ (19 dígitos, inválido)

---

## 🧪 Como Testar

1. **Teste com CNPJ Inválido:**
   - Tente preencher o campo CNPJ com `55555555555` (CPF ou números repetidos)
   - Clique em "SALVAR IMOBILIÁRIA"
   - **Resultado esperado:** Mensagem de erro "CNPJ inválido..."

2. **Teste com CNPJ Válido:**
   - Preencha com um CNPJ válido (exemplo: `11222333000181`)
   - Clique em "SALVAR IMOBILIÁRIA"
   - **Resultado esperado:** Imobiliária criada com sucesso!

3. **Teste com CNPJ Formatado:**
   - Preencha com formato brasileiro (exemplo: `11.222.333/0001-81`)
   - A função remove a formatação automaticamente
   - **Resultado esperado:** Validação passa e imobiliária é criada

---

## 📋 Fluxo Completo Atualizado

```
User preenche Nome, CNPJ, Telefone, etc.
    ↓
User clica "SALVAR IMOBILIÁRIA"
    ↓
Sistema valida Nome (obrigatório) ✓
    ↓
Sistema valida CNPJ (obrigatório + formato) ✓
    ↓
Se válido: Cria imobiliária no banco de dados
    ↓
Se tem foto: Faz upload para storage
    ↓
Atualiza registro com foto_url
    ↓
Exibe mensagem de sucesso
```

---

## 🔧 Código Modificado

**Arquivo:** `lib/screens/detalhes_unidade_screen.dart`

**Linha 12:** Adicionado import
```dart
import '../utils/formatters.dart';
```

**Linhas 518-530:** Adicionada validação de CNPJ
```dart
// Validar formato do CNPJ
if (!Formatters.isValidCNPJ(_imobiliariaCnpjController.text.trim())) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('CNPJ inválido. Verifique se o número está correto.'),
      backgroundColor: Colors.orange,
    ),
  );
  setState(() {
    _isLoadingImobiliaria = false;
  });
  return;
}
```

---

## 📝 Próximos Passos

1. **Testar com CNPJ válido** para confirmar que a criação funciona
2. **Adicionar coluna `foto_url`** na tabela `imobiliarias` do Supabase (SQL):
   ```sql
   ALTER TABLE imobiliarias ADD COLUMN foto_url TEXT NULL;
   ```
3. **Testar upload de foto** após criação da imobiliária

---

## ✅ Status

- ✅ Validação de CNPJ implementada
- ✅ Mensagem de erro clara ao usuário
- ✅ Sem erros de compilação
- ⏳ Aguardando teste com CNPJ válido
