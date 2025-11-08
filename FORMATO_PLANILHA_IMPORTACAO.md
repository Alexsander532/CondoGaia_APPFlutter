# 📊 GUIA DE FORMATO DA PLANILHA DE IMPORTAÇÃO

## 🎯 FORMATOS ACEITOS POR CAMPO

### **CPF (Proprietário e Inquilino)**
**Formatos aceitos:**
- `12345678901` ✅ (sem formatação)
- `123.456.789-01` ✅ (com formatação)
- `123-456-789-01` ✅ (com hífen)

**Validações:**
- ✅ Deve ter exatamente 11 dígitos
- ❌ Rejeita CPF com todos dígitos iguais (111.111.111-11)
- ❌ CPF duplicado na mesma planilha
- ❌ CPF já existe no banco de dados

**Exemplo correto:**
```
123.456.789-01  →  app converte para  →  12345678901
```

---

### **CNPJ (Imobiliária)**
**Formatos aceitos:**
- `12345678000190` ✅ (sem formatação)
- `12.345.678/0001-90` ✅ (com formatação)

**Validações:**
- ✅ Deve ter exatamente 14 dígitos
- ❌ Rejeita CNPJ com todos dígitos iguais (11.111.111/1111-11)
- ❌ CNPJ duplicado na mesma planilha

**Exemplo correto:**
```
12.345.678/0001-90  →  app converte para  →  12345678000190
```

---

### **TELEFONE (Proprietário, Inquilino e Imobiliária)**
**Formatos aceitos:**
- `11987654321` ✅ (11 dígitos - com 9)
- `(11) 98765-4321` ✅ (com formatação)
- `1133334444` ✅ (10 dígitos - sem 9)
- `(11) 3333-4444` ✅ (com formatação)
- `11 98765-4321` ✅ (com espaço e hífen)

**Validações:**
- ✅ Deve ter 10 ou 11 dígitos (com ou sem 9)
- ❌ Menos de 10 dígitos
- ❌ Mais de 11 dígitos

**Exemplo correto:**
```
(11) 98765-4321  →  app converte para  →  11987654321
```

---

### **EMAIL (Proprietário, Inquilino e Imobiliária)**
**Formatos aceitos:**
- `joao@gmail.com` ✅
- `maria.silva@empresa.com.br` ✅
- `contato+info@example.co.uk` ✅

**Validações:**
- ✅ Formato padrão: `usuario@dominio.extensao`
- ❌ Sem @: `joaogmail.com`
- ❌ Sem domínio: `joao@.com`
- ❌ Email duplicado na mesma planilha
- ❌ Email já existe no banco de dados
- ✅ Case-insensitive (João@Gmail.COM = joao@gmail.com)

**Exemplo correto:**
```
Maria.Silva@Gmail.Com  →  app converte para  →  maria.silva@gmail.com
```

---

### **FRAÇÃO IDEAL (Unidade)**
**Formatos aceitos:**
- `100` ✅ (número inteiro)
- `100.50` ✅ (com decimal)
- `0,50` ✅ (com vírgula brasileira)
- `1/10` ❌ (frações não são aceitas)

**Validações:**
- ✅ Deve ser número > 0
- ❌ Valores = 0
- ❌ Valores negativos
- ❌ Texto (não número)

**Exemplo correto:**
```
100,50  →  app converte para  →  100.50
```

---

### **BLOCO**
**Formatos aceitos:**
- `A` ✅
- `Bloco A` ✅
- `A1` ✅
- `Vazio` ✅ (será convertido para "A" automaticamente)

**Validações:**
- ✅ Qualquer texto
- ✅ Se vazio, usa "A" por padrão
- ✅ Se bloco não existir, cria automaticamente

**Exemplo correto:**
```
Vazio  →  app converte para  →  A
Bloco B  →  app converte para  →  B
```

---

### **UNIDADE**
**Formatos aceitos:**
- `101` ✅
- `101A` ✅
- `Apt. 101` ✅
- `Sala 102` ✅

**Validações:**
- ✅ Qualquer texto
- ❌ Campo vazio (obrigatório)

---

### **NOME (Proprietário e Inquilino)**
**Formatos aceitos:**
- `João Silva` ✅
- `JOÃO DA SILVA` ✅
- `joão silva` ✅
- `Maria-Clara Santos` ✅

**Validações:**
- ✅ Qualquer texto
- ❌ Campo vazio (obrigatório)
- ✅ Mínimo 3 caracteres recomendado

---

### **IMOBILIÁRIA**
**Formatos aceitos:**
- Campo vazio ✅ (opcional)
- `Imobiliária XYZ` ✅
- `123.456.789/0001-90` ✅ (CNPJ)

---

## 🚨 EXEMPLOS DE ERROS E O QUE MOSTRA NO RELATÓRIO

### **ERRO 1: CPF Inválido**
```
Planilha linha 5: CPF "123.456.789-0A" (contém letra)

RELATÓRIO MOSTRA:
❌ Linha 5: CPF "123.456.789-0A" inválido - CPF deve conter apenas números (11 dígitos)
```

---

### **ERRO 2: Email Inválido**
```
Planilha linha 8: Email "joao@gmail"

RELATÓRIO MOSTRA:
❌ Linha 8: Email "joao@gmail" inválido - Formato correto: usuario@dominio.com
```

---

### **ERRO 3: Telefone com Poucos Dígitos**
```
Planilha linha 12: Telefone "1133" (4 dígitos)

RELATÓRIO MOSTRA:
❌ Linha 12: Telefone "1133" inválido - Deve ter 10 ou 11 dígitos (ex: 11987654321)
```

---

### **ERRO 4: Fração Ideal Inválida**
```
Planilha linha 3: Fração "abc"

RELATÓRIO MOSTRA:
❌ Linha 3: Fração ideal "abc" inválida - Deve ser um número positivo (ex: 100.50)
```

---

### **ERRO 5: CPF Duplicado na Planilha**
```
Planilha linha 5 e 15: CPF "123.456.789-01" repetido

RELATÓRIO MOSTRA:
❌ Linha 15: CPF "123.456.789-01" duplicado - Este CPF já existe na linha 5 desta importação
```

---

### **ERRO 6: CPF Duplicado no Banco**
```
Planilha linha 7: CPF "987.654.321-00" (já existe no BD)

RELATÓRIO MOSTRA:
❌ Linha 7: CPF "987.654.321-00" já existe no sistema - Este proprietário já foi cadastrado anteriormente
```

---

### **ERRO 7: Campo Obrigatório Vazio**
```
Planilha linha 10: Proprietário Nome vazio

RELATÓRIO MOSTRA:
❌ Linha 10: Nome do proprietário é obrigatório
❌ Linha 10: Email do proprietário é obrigatório
```

---

### **ERRO 8: Unidade Vazia**
```
Planilha linha 6: Unidade vazia

RELATÓRIO MOSTRA:
❌ Linha 6: Número da unidade é obrigatório
```

---

### **ERRO 9: Múltiplos Erros na Mesma Linha**
```
Planilha linha 4:
- CPF: "123" (inválido)
- Email: "joao@" (inválido)
- Telefone: "11" (inválido)

RELATÓRIO MOSTRA:
❌ Linha 4: CPF "123" inválido - Deve conter 11 dígitos
❌ Linha 4: Email "joao@" inválido - Formato correto: usuario@dominio.com
❌ Linha 4: Telefone "11" inválido - Deve ter 10 ou 11 dígitos
```

---

## 📋 EXEMPLO DE PLANILHA VÁLIDA

| bloco | unidade | fracao_ideal | proprietario_nome_completo | proprietario_cpf | proprietario_cel | proprietario_email | inquilino_nome_completo | inquilino_cpf | inquilino_cel | inquilino_email | nome_imobiliaria | cnpj_imobiliaria | cel_imobiliaria | email_imobiliaria |
|-------|---------|--------------|---------------------------|------------------|------------------|-------------------|------------------------|---------------|---------------|-----------------|------------------|------------------|-----------------|-------------------|
| A | 101 | 100.00 | João Silva | 123.456.789-01 | (11) 98765-4321 | joao@gmail.com | Maria Silva | 987.654.321-00 | (11) 98765-4322 | maria@gmail.com | XYZ Imóveis | 12.345.678/0001-90 | (11) 3333-3333 | contato@xyz.com |
| A | 102 | 100.00 | Pedro Costa | 111.222.333-44 | 11987654321 | pedro@email.com | | | | | ABC Imóveis | 98.765.432/0001-11 | (11) 9999-9999 | contato@abc.com |
| B | 201 | 150.00 | Ana Santos | 222.333.444-55 | (21) 98765-4321 | ana@email.com | Carlos Mendes | 333.444.555-66 | 21987654321 | carlos@email.com | XYZ Imóveis | 12.345.678/0001-90 | (11) 3333-3333 | contato@xyz.com |
| (vazio) | 301 | 120.00 | Lucia Oliveira | 444.555.666-77 | 1140004444 | lucia@email.com | | | | | | | | |

---

## 🔄 CONVERSÕES AUTOMÁTICAS

| Campo | Entrada | Saída |
|-------|---------|-------|
| CPF | `123.456.789-01` | `12345678901` |
| CNPJ | `12.345.678/0001-90` | `12345678000190` |
| Telefone | `(11) 98765-4321` | `11987654321` |
| Email | `JOAO@GMAIL.COM` | `joao@gmail.com` |
| Fração | `100,50` | `100.50` |
| Bloco | (vazio) | `A` |
| Bloco | `bloco a` | `A` |
| Nome | `  joão  silva  ` | `João Silva` |

---

## ✅ VALIDAÇÕES POR TIPO DE USUÁRIO

### **Proprietário (Sempre Obrigatório)**
- ✅ Nome completo
- ✅ CPF
- ✅ Email
- ✅ Telefone

### **Inquilino (Opcional)**
- ⭕ Se informar, todos os campos são obrigatórios:
  - ✅ Nome completo
  - ✅ CPF
  - ✅ Email
  - ✅ Telefone
- ⭕ Se deixar em branco, a unidade será apenas do proprietário

### **Imobiliária (Opcional)**
- ⭕ Se informar o nome, todos os campos são obrigatórios:
  - ✅ Nome
  - ✅ CNPJ
  - ✅ Email
  - ✅ Telefone

---

## 📌 RESUMO DO FLUXO DE VALIDAÇÃO

```
1️⃣ LEITURA
   ├─ Lê arquivo Excel/ODS
   └─ Extrai dados das colunas

2️⃣ LIMPEZA
   ├─ Remove espaços extras
   ├─ Converte para lowercase (emails)
   └─ Remove caracteres especiais (CPF, CNPJ, telefone)

3️⃣ VALIDAÇÃO
   ├─ Formato válido?
   ├─ Campo obrigatório preenchido?
   ├─ Duplicado na planilha?
   └─ Existe no banco de dados?

4️⃣ PREVIEW
   ├─ Lista erros encontrados
   ├─ Mostra quantas linhas válidas
   └─ Mostra quantas linhas com erro

5️⃣ CONFIRMAÇÃO
   ├─ User revisa os erros
   └─ Clica "Confirmar" ou "Cancelar"

6️⃣ INSERÇÃO
   ├─ Cria proprietários
   ├─ Cria inquilinos
   └─ Cria imobiliárias

7️⃣ RELATÓRIO FINAL
   ├─ ✅ Sucesso: X proprietários, Y inquilinos
   └─ ❌ Erros: lista detalhada
```

---

## 🎨 MOCKUP DO RELATÓRIO NO APP

```
╔═══════════════════════════════════════════════════════════════╗
║         PREVIEW - VALIDAÇÃO DE PLANILHA                      ║
╚═══════════════════════════════════════════════════════════════╝

📊 RESUMO:
   Total de linhas: 25
   ✅ Válidas: 22
   ❌ Com erro: 3

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

❌ ERROS ENCONTRADOS:

❌ Linha 5: CPF "123" inválido
   → CPF deve conter 11 dígitos (ex: 123.456.789-01)

❌ Linha 8: Email "joao@gmail" inválido
   → Formato correto: usuario@dominio.com

❌ Linha 12: CPF "987.654.321-00" duplicado
   → Este CPF já existe em outra linha desta importação
   → Primeira ocorrência: Linha 3

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DADOS QUE SERÃO CRIADOS:

   👤 Proprietários: 22
   🏠 Inquilinos: 18
   🏢 Imobiliárias: 5
   🏘️ Blocos: 3 (A, B, C)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ ATENÇÃO:
   As 3 linhas com erro não serão importadas.
   Apenas as 22 linhas válidas serão inseridas no sistema.

   [VOLTAR]  [CONFIRMAR IMPORTAÇÃO]
```

---

## 🔐 SENHAS GERADAS

Ao importar com sucesso, as senhas geradas aparecerão assim:

```
╔═══════════════════════════════════════════════════════════════╗
║         RESULTADO FINAL - IMPORTAÇÃO CONCLUÍDA               ║
╚═══════════════════════════════════════════════════════════════╝

✅ IMPORTAÇÃO REALIZADA COM SUCESSO!

📊 RESUMO:
   ✅ Proprietários criados: 22
   ✅ Inquilinos criados: 18
   ✅ Imobiliárias criadas: 5

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔐 SENHAS GERADAS (salve em local seguro):

PROPRIETÁRIOS:
   João Silva (CPF: 123.456.789-01)
   Email: joao@gmail.com
   Senha: CG2024Qx7#Kp9

   Pedro Costa (CPF: 111.222.333-44)
   Email: pedro@email.com
   Senha: CG2024Ab3@Lm5

   ... (mais 20 proprietários)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INQUILINOS:
   Maria Silva (CPF: 987.654.321-00)
   Email: maria@gmail.com
   Senha: CG2024Yx8#Mn4

   Carlos Mendes (CPF: 333.444.555-66)
   Email: carlos@email.com
   Senha: CG2024Wz2@Bc6

   ... (mais 16 inquilinos)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 EXPORTAR SENHAS [COPIAR]  [DOWNLOAD PDF]  [FECHAR]
```

---

## 📌 CHECKLIST ANTES DE IMPORTAR

- ✅ Arquivo está em formato Excel (.xlsx) ou ODS
- ✅ Primeira linha contém os nomes das colunas corretos
- ✅ Não há linhas em branco no meio dos dados
- ✅ CPFs estão preenchidos (obrigatório para proprietário)
- ✅ Emails estão preenchidos (obrigatório para proprietário)
- ✅ Telefones estão preenchidos (obrigatório para proprietário)
- ✅ Não há CPFs duplicados
- ✅ Não há emails duplicados
- ✅ Unidades existem ou serão criadas automaticamente
- ✅ Blocos vazios usarão "A" por padrão
