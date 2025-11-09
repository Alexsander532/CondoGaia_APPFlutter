# 📊 PLANO: Mapeamento Dados Planilha → Banco

## 🎯 Objetivo
Mapear corretamente cada campo da planilha para as colunas das tabelas: **unidades**, **proprietarios**, **inquilinos**, **imobiliarias**.

---

## 📋 MAPEAMENTO DE CAMPOS

### 1️⃣ UNIDADES
```
bloco            → campos.bloco            (Se vazio → "A")
unidade          → campos.numero           (OBRIGATÓRIO)
fracaoIdeal      → campos.fracao_ideal     (0 < valor ≤ 1.0)
```

### 2️⃣ PROPRIETARIOS
```
proprietarioNomeCompleto  → nome         (OBRIGATÓRIO, min 3 chars)
proprietarioCpf           → cpf_cnpj     (OBRIGATÓRIO, único por condominio)
proprietarioCel           → celular      (opcional)
proprietarioEmail         → email        (único por condominio se informado)
                          → senha_acesso (Gerar temporária)
```

### 3️⃣ INQUILINOS (OPCIONAL)
```
inquilinoNomeCompleto  → nome         (Se informado, OBRIGATÓRIO)
inquilinoCpf           → cpf_cnpj     (Se informado, OBRIGATÓRIO + único)
inquilinoCel           → celular      (opcional)
inquilinoEmail         → email        (único por condominio se informado)
                       → senha_acesso (Gerar temporária)
                       → receber_boleto_email (true)
                       → controle_locacao (true)
```

### 4️⃣ IMOBILIARIAS (OPCIONAL)
```
nomeImobiliaria   → nome        (Se informado, OBRIGATÓRIO)
cnpjImobiliaria   → cnpj        (Se informado, OBRIGATÓRIO + único por condominio)
celImobiliaria    → celular     (opcional)
emailImobiliaria  → email       (único por condominio se informado)
```

---

## ✅ VALIDAÇÕES CRÍTICAS

### UNIDADES
- [ ] `numero` não pode ser vazio
- [ ] `fracao_ideal` entre 0 e 1.0 (se informado)
- [ ] Combinação (numero + condominio_id) deve ser única

### PROPRIETARIOS
- [ ] Nome não vazio, mín 3 caracteres
- [ ] CPF válido (passar no check constraint do DB)
- [ ] **CPF único por condominio** ← DEVE VALIDAR ANTES
- [ ] Email válido (RFC 5322) se informado
- [ ] **Email único por condominio** ← DEVE VALIDAR ANTES

### INQUILINOS
- [ ] Nome não vazio, mín 3 caracteres
- [ ] CPF válido (passar no check constraint)
- [ ] **CPF único por condominio** ← DEVE VALIDAR ANTES
- [ ] **CPF DIFERENTE do proprietário** ← IMPORTANTE!
- [ ] Email válido (RFC 5322) se informado
- [ ] **Email único por condominio** ← DEVE VALIDAR ANTES

### IMOBILIARIAS
- [ ] Nome não vazio
- [ ] CNPJ válido (passar no check constraint)
- [ ] **CNPJ único por condominio** ← DEVE VALIDAR ANTES
- [ ] Email válido (RFC 5322) se informado
- [ ] **Email único por condominio** ← DEVE VALIDAR ANTES

---

## 🚀 ORDEM DE INSERÇÃO

**Importante:** Respeitar esta ordem para evitar constraint violations:

```
┌─────────────────────────────────────┐
│ 1. VALIDAR TUDO PRIMEIRO            │
│    (não inserir nada ainda)         │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│ 2. UNIDADES                         │
│    ├─ Verificar se já existe        │
│    ├─ Se sim → reutilizar ID        │
│    └─ Se não → criar                │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│ 3. PROPRIETARIOS                    │
│    ├─ Usar unidade_id da etapa 2   │
│    ├─ Gerar senha temporária        │
│    └─ Inserir                       │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│ 4. INQUILINOS (se houver)           │
│    ├─ Usar unidade_id da etapa 2   │
│    ├─ Gerar senha temporária        │
│    └─ Inserir                       │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│ 5. IMOBILIARIAS (se houver)         │
│    └─ Inserir                       │
└─────────────────────────────────────┘
```

---

## 🛡️ TRATAMENTO DE ERROS

### Se validação falhar em UMA linha:
1. ✅ Marcar linha como COM ERRO
2. ✅ Adicionar mensagem de erro específica
3. ✅ **CONTINUAR processando outras linhas** (não parar tudo!)
4. ✅ No final, mostrar:
   - Total de linhas
   - Quantas passaram
   - Quantas tiveram erro
   - Detalhes de cada erro

### Mensagens de erro esperadas:
```
Linha 3: Unidade não informada
Linha 4: Unidade "101" já existe no condomínio
Linha 5: Proprietário: CPF inválido (01710482100)
Linha 6: Proprietário: CPF "01710482109" já existe no condomínio
Linha 7: Proprietário: Email já existe no condomínio
Linha 8: Inquilino: CPF igual ao proprietário
Linha 9: Fração ideal deve estar entre 0 e 1 (recebido: 1.5)
```

---

## 💾 DADOS APÓS VALIDAÇÃO

Estrutura esperada para cada linha válida:

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
    'nome': 'Nilza Almeida de Araujo',
    'cpf_cnpj': '01710482109',
    'email': 'nilza326@gmail.com',
    'celular': '11987654321',
    'senha_temporaria': 'K7x2pQmL',
  },
  'inquilino': null,  // ou com dados se houver
  'imobiliaria': null,  // ou com dados se houver
}
```

---

## 🔐 SENHAS TEMPORÁRIAS

Gerar aleatória de 8 caracteres:
```
Caracteres: A-Z, a-z, 0-9
Exemplo: K7x2pQmL, Tp9vRsWx, etc
```

**Entregar ao usuário:**
- Prop: K7x2pQmL
- Inq: Jq3bNmLo
- Link para troca de senha no app

---

## 📊 PRÓXIMAS ETAPAS

1. **Implementar validações** no `ImportacaoService`
   - Checar CPF/CNPJ únicos
   - Validar emails
   - Validar telefones

2. **Criar método de mapeamento** 
   - `mapearParaInsercao(ImportacaoRow)`
   - Transformar em dados prontos para DB

3. **Implementar inserção no Supabase**
   - Respectar ordem (unidade → prop → inq → imob)
   - Tratamento de erros por linha
   - Rollback se necessário

4. **Testar com dados reais**
   - Verificar se tudo vai pro DB certo
   - Confirmar validações funcionam
   - Testar mensagens de erro

---

## 📌 CHECKLIST FINAL

- [ ] Mapeamento entendido e documentado
- [ ] Validações implementadas
- [ ] Método de mapeamento criado
- [ ] Inserção no DB implementada
- [ ] Tratamento de erro funcionando
- [ ] Testes realizados
- [ ] Usuário recebe feedback claro

