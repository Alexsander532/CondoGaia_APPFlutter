# 🧪 GUIA DE TESTE - IMPORTAÇÃO COMPLETA

## 📋 Pré-requisitos

1. ✅ App Flutter compilando sem erros
2. ✅ Supabase conectado e funcionando
3. ✅ Planilha de teste preparada (veja formato abaixo)

---

## 📊 Formato da Planilha de Teste

### Colunas Esperadas (em ordem)
```
1. numero (string)        - Exemplo: "101"
2. bloco (string)         - Exemplo: "A" ou vazio (default "A")
3. fracao_ideal (string)  - Exemplo: "0.5" ou "0,5"
4. tipo_unidade (string)  - Exemplo: "Apartamento"
5. nome_prop (string)     - Nome do proprietário
6. cpf_cnpj_prop (string) - CPF (11 dígitos) ou CNPJ (14)
7. email_prop (string)    - Email do proprietário
8. telefone_prop (string) - Telefone (opcional)
9. celular_prop (string)  - Celular (opcional)
10. tem_inquilino (string) - "Sim" ou "Não"
11. nome_inq (string)     - Nome inquilino (se tem_inquilino="Sim")
12. cpf_cnpj_inq (string) - CPF inquilino (se tem_inquilino="Sim")
13. email_inq (string)    - Email inquilino (se tem_inquilino="Sim")
14. isentos_* (string)    - "Sim" ou "Não" para cada isento (colunas 14+)
```

### Exemplo de Dados de Teste

| numero | bloco | fracao_ideal | tipo_unidade | nome_prop | cpf_cnpj_prop | email_prop | celular_prop | tem_inquilino | nome_inq | cpf_cnpj_inq | email_inq |
|--------|-------|--------------|--------------|-----------|---------------|-----------|-------------|---------------|----------|-------------|-----------|
| 101 | A | 0.5 | Apartamento | João Silva | 12345678901 | joao@email.com | 11987654321 | Não | | | |
| 102 | A | 0.5 | Apartamento | Maria Santos | 98765432101 | maria@email.com | 11912345678 | Sim | Pedro Santos | 12312312312 | pedro@email.com |
| 103 | A | 0.5 | Apartamento | Carlos Costa | 45645645645 | carlos@email.com | 11945645645 | Não | | | |

---

## 🚀 Passos para Testar

### Passo 1: Preparar Planilha
1. Abra o Excel/Calc
2. Crie planilha com dados de teste (use exemplo acima)
3. Salve como `.xlsx` ou `.ods` em `assets/` ou temporário

### Passo 2: Acessar Modal
```dart
// No seu widget, chame:
showDialog(
  context: context,
  builder: (context) => ImportacaoModalWidget(
    condominioId: 'seu-condominio-id',
    condominioNome: 'Condomínio Teste',
    cpfsExistentes: {},  // Set vazio para teste
    emailsExistentes: {}, // Set vazio para teste
  ),
);
```

### Passo 3: Seguir Passos do Modal

#### 🔵 Passo 1 - Seleção de Arquivo
- Clique em "Selecionar Arquivo"
- Escolha a planilha de teste
- Avança automaticamente para Passo 2

#### 🔵 Passo 2 - Validação
- Vê preview dos dados
- Conta linhas válidas: deve mostrar "3 válidas, 0 com erro"
- Logs mostram validações executadas
- Botão "Prosseguir" ativado

#### 🔵 Passo 3 - Confirmação
- Revisa dados: proprietários, inquilinos, blocos
- Clica em "Prosseguir"
- Automático: avança para Passo 4

#### 🔵 Passo 4 - Execução (não visível)
- Validação completa
- Mapeamento de dados
- Inserção no Supabase
- Automático: avança para Passo 5

#### 🔵 Passo 5 - Resultado Final
Esperado ver:
```
✅ Importação Concluída

✅ Com Sucesso:  3
❌ Com Erro:     0
⏱️  Tempo Total:  ~5s

🔐 Senhas Temporárias Geradas:

Linha 1:
  Proprietário: Abc123Xy

Linha 2:
  Proprietário: Def456Qw
  Inquilino: Ghi789Mn

Linha 3:
  Proprietário: Jkl012Op

📋 Logs Detalhados:
[mostra todo processo]
```

---

## ✅ Validações a Confirmar

### 1. Dados Inseridos Corretamente
```sql
-- No Supabase SQL Editor:
SELECT * FROM unidades WHERE numero IN ('101', '102', '103');
SELECT * FROM proprietarios WHERE email LIKE '%@email.com%';
SELECT * FROM inquilinos WHERE cpf_cnpj = '12312312312';
```

Deve retornar:
- ✅ 3 unidades com números 101, 102, 103
- ✅ 3 proprietários com emails corretos
- ✅ 1 inquilino (Pedro Santos)
- ✅ Todas senhas não-nulas (8 caracteres)

### 2. Validações de Unicidade
Tente importar a mesma planilha novamente:
- ✅ Deve mostrar erro de duplicata
- ✅ Linha 1 erro: "Unidade já existe"
- ✅ Outras linhas processadas normalmente (update/skip)

### 3. Validações de CPF/Email
Crie linha com dados inválidos:

| numero | bloco | fracao_ideal | tipo_unidade | nome_prop | cpf_cnpj_prop | email_prop |
|--------|-------|--------------|--------------|-----------|---------------|-----------|
| 999 | A | 0.5 | Apartamento | Teste | 12345 | email-invalido | 

Resultado esperado:
- ✅ Passo 2 mostra erro: "CPF inválido (5 dígitos)"
- ✅ Passo 2 mostra erro: "Email inválido"
- ✅ Linha não processada

### 4. Senhas Geradas
Cada senha deve ter:
- ✅ Exatamente 8 caracteres
- ✅ Apenas letras e números
- ✅ Sem caracteres especiais
- ✅ Diferentes para cada linha

---

## 🐛 Troubleshooting

### Problema: "Arquivo não selecionado"
- Solução: Clique em "Selecionar Arquivo" e escolha arquivo válido

### Problema: "Sem linhas válidas para importar"
- Solução: Verifique formato da planilha, todas as colunas obrigatórias preenchidas

### Problema: "Erro ao validar" com muitos detalhes
- Solução: Verifique:
  - CPF/CNPJ formato
  - Email válido (tem @)
  - Fração ideal entre 0 e 1
  - Sem campos obrigatórios vazios

### Problema: "Linhas com sucesso: 0"
- Solução:
  1. Verifique logs detalhados em Passo 5
  2. Procure por linhas em vermelha
  3. Leia mensagem de erro específica
  4. Corrija dados e tente novamente

### Problema: Modal travado/não avança
- Solução:
  1. Abra console do Flutter (F12)
  2. Procure por exceptions
  3. Verifique conexão com Supabase
  4. Teste com menos linhas (1-2 dados)

---

## 📝 Logs Esperados

Durante Passo 2 (Validação):
```
📁 Arquivo selecionado: planilha.xlsx
🔄 Iniciando parsing...
📋 Total de linhas: 3
✅ Linha 1: Válida
✅ Linha 2: Válida
✅ Linha 3: Válida
✅ Validação concluída! 3 linhas válidas
```

Durante Passo 4/5 (Execução):
```
╔════════════════════════════════════════╗
║   INICIANDO IMPORTAÇÃO PARA SUPABASE   ║
╚════════════════════════════════════════╝

📋 ETAPA 1: VALIDAÇÃO
✅ VALIDAÇÃO CONCLUÍDA
   Total: 3 linhas
   ✅ Válidas: 3
   ❌ Com erro: 0

📝 ETAPA 2: MAPEAMENTO
✅ Linha 1: Mapeada com sucesso
✅ Linha 2: Mapeada com sucesso
✅ Linha 3: Mapeada com sucesso
✅ MAPEAMENTO CONCLUÍDO: 3 linhas mapeadas

💾 ETAPA 3: INSERÇÃO NO SUPABASE
✅ Linha 1: Sucesso
✅ Linha 2: Sucesso
✅ Linha 3: Sucesso

╔════════════════════════════════════════╗
║        RESUMO DA IMPORTAÇÃO            ║
╚════════════════════════════════════════╝

✅ Linhas com sucesso: 3
❌ Linhas com erro: 0
📊 Total: 3 linhas
⏱️  Tempo total: 5s

🔐 SENHAS TEMPORÁRIAS GERADAS:

Linha 1:
  📱 Proprietário: Abc123Xy

Linha 2:
  📱 Proprietário: Def456Qw
  👤 Inquilino: Ghi789Mn

Linha 3:
  📱 Proprietário: Jkl012Op
```

---

## 🎯 Casos de Teste Recomendados

### Teste 1: Happy Path (Tudo OK)
- 3 linhas válidas
- Sem duplicatas
- Sem inquilinos
- Resultado esperado: 3 sucessos, 0 erros

### Teste 2: Com Inquilinos
- 2 linhas com inquilinos
- 1 sem inquilino
- Resultado esperado: 3 sucessos, 2 inquilinos inseridos

### Teste 3: Com Erros
- 1 CPF inválido
- 1 Email duplicado (testar depois)
- 1 válido
- Resultado esperado: 1 sucesso, 2 erros

### Teste 4: Validações Específicas
- Fração ideal inválida (>1 ou <0)
- Bloco vazio (deve defaultar A)
- Tipo unidade inválido
- Resultado esperado: erros específicos

---

## 📊 Dados de Teste Completo

Use este arquivo como referência:

**assets/planilha_teste_importacao.ods** (copie/adapte):

```
Linha 1: João Silva, CPF 11111111111, joao@test.com, Apt 101, sem inquilino
Linha 2: Maria Santos, CPF 22222222222, maria@test.com, Apt 102, com inquilino Pedro
Linha 3: Carlos Costa, CPF 33333333333, carlos@test.com, Apt 103, sem inquilino
```

---

## ✨ Próximos Passos Após Teste

Se tudo passou ✅:
1. Testar com dados reais do condomínio
2. Testar com 50+ linhas para performance
3. Testar com caracteres especiais nos nomes
4. Testar error recovery e retry

Se algo falhou ❌:
1. Leia logs detalhados
2. Abra DevTools (F12) para exceptions
3. Verifique dados de entrada
4. Crie issue com logs anexados

---

**Última atualização: 2025-11-09**
**Pronto para teste!**
