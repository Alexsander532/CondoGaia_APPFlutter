# 🧪 Testes do Módulo de Leitura

Este documento contém cenários de teste, casos de uso reais e instruções para validação do módulo de Leitura de Consumo.

---

## 📋 Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Cenários de Uso Real](#cenários-de-uso-real)
3. [Casos de Teste - Aba Cadastrar](#casos-de-teste---aba-cadastrar)
4. [Casos de Teste - Aba Configurar](#casos-de-teste---aba-configurar)
5. [Testes de Integração](#testes-de-integração)
6. [Checklist de Aprovação](#checklist-de-aprovação)
7. [Bugs Conhecidos](#bugs-conhecidos)

---

## 📌 Pré-requisitos

Antes de iniciar os testes, certifique-se de que:

- [ ] O app está rodando (`flutter run`)
- [ ] Você está logado como **Representante**
- [ ] Possui um condomínio com pelo menos 5 unidades cadastradas
- [ ] Tem acesso à internet (para sincronização com Supabase)

### Dados de Teste Sugeridos

| Condomínio | Blocos | Unidades por Bloco |
|------------|--------|-------------------|
| Residencial Teste | A, B | 4 unidades cada (101-104, 201-204) |

---

## 🏢 Cenários de Uso Real

### Cenário 1: Condomínio Pequeno (Cobrança Simples)

**Contexto:** Condomínio residencial com 20 unidades, sem faixas de consumo.

**Configuração:**
- Tipo: Água
- Valor base: R$ 10,00 por M³
- Sem faixas configuradas
- Cobrança: Junto com taxa de condomínio

**Leituras do Mês:**

| Unidade | Leit. Anterior | Leit. Atual | Consumo | Valor Esperado |
|---------|----------------|-------------|---------|----------------|
| A-101 | 100.000 | 108.500 | 8.500 M³ | R$ 85,00 |
| A-102 | 250.000 | 252.000 | 2.000 M³ | R$ 20,00 |
| A-103 | 180.000 | 195.000 | 15.000 M³ | R$ 150,00 |
| A-104 | 320.000 | 320.000 | 0.000 M³ | R$ 0,00 |
| B-201 | 45.000 | 50.500 | 5.500 M³ | R$ 55,00 |

**Total esperado:** R$ 310,00

---

### Cenário 2: Condomínio Médio (Com Faixas Progressivas)

**Contexto:** Condomínio comercial que cobra por faixas para incentivar economia.

**Configuração:**
- Tipo: Água
- Faixa 1: 0 a 10 M³ = R$ 5,00/M³
- Faixa 2: 10 a 20 M³ = R$ 8,00/M³
- Faixa 3: 20 a 50 M³ = R$ 12,00/M³
- Valor base (acima de 50 M³): R$ 15,00/M³
- Cobrança: Avulso

**Leituras do Mês:**

| Unidade | Consumo | Cálculo Detalhado | Valor Esperado |
|---------|---------|-------------------|----------------|
| Sala 01 | 5 M³ | 5 × R$5 = R$25 | R$ 25,00 |
| Sala 02 | 15 M³ | (10×R$5) + (5×R$8) = R$50 + R$40 | R$ 90,00 |
| Sala 03 | 25 M³ | (10×R$5) + (10×R$8) + (5×R$12) = R$50 + R$80 + R$60 | R$ 190,00 |
| Sala 04 | 60 M³ | (10×R$5) + (10×R$8) + (30×R$12) + (10×R$15) | R$ 640,00 |
| Sala 05 | 0 M³ | Sem consumo | R$ 0,00 |

**Total esperado:** R$ 945,00

---

### Cenário 3: Leitura de Gás

**Contexto:** Condomínio com gás encanado.

**Configuração:**
- Tipo: Gás
- Unidade de medida: M³
- Valor base: R$ 25,00 por M³
- Sem faixas
- Cobrança: Junto com taxa de condomínio

**Leituras do Mês:**

| Unidade | Leit. Anterior | Leit. Atual | Consumo | Valor Esperado |
|---------|----------------|-------------|---------|----------------|
| Apt 101 | 50.000 | 52.500 | 2.500 M³ | R$ 62,50 |
| Apt 102 | 30.000 | 31.800 | 1.800 M³ | R$ 45,00 |
| Apt 201 | 80.000 | 80.000 | 0.000 M³ | R$ 0,00 |
| Apt 202 | 15.000 | 18.200 | 3.200 M³ | R$ 80,00 |

**Total esperado:** R$ 187,50

---

### Cenário 4: Múltiplos Tipos de Leitura

**Contexto:** Condomínio que controla água E gás separadamente.

**Teste:** Verificar que as configurações e leituras são independentes por tipo.

**Ações:**
1. Configurar Água com valor R$ 10,00/M³
2. Configurar Gás com valor R$ 25,00/M³
3. Registrar leitura de Água para Apt 101: 10 M³ → Espera R$ 100,00
4. Registrar leitura de Gás para Apt 101: 2 M³ → Espera R$ 50,00
5. Alternar entre tipos e verificar que valores estão corretos

---

### Cenário 5: Erro de Leitura (Valor Menor que Anterior)

**Contexto:** Leiturista digita valor incorreto menor que a leitura anterior.

**Dados:**
- Leitura anterior: 150.000 M³
- Leitura atual digitada: 140.000 M³ (ERRO!)

**Comportamento esperado:**
- Sistema deve exibir mensagem de erro: "Leitura atual não pode ser menor que a anterior"
- A leitura NÃO deve ser salva
- O campo deve permitir correção

---

### Cenário 6: Anexar Foto do Medidor

**Contexto:** Leiturista tira foto como comprovante.

**Ações:**
1. Selecionar unidade na tabela
2. Digitar leitura (ex: 125.500)
3. Clicar em "Anexar foto"
4. Selecionar/tirar foto
5. Verificar que ícone muda para ✓
6. Clicar em "Gravar"
7. Verificar que leitura foi salva com sucesso

---

## ✅ Casos de Teste - Aba Cadastrar

### CT-001: Carregamento Inicial

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar que a tela carrega corretamente |
| **Passos** | 1. Acessar módulo Leitura |
| **Resultado Esperado** | Tabela carrega com todas as unidades do condomínio |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-002: Filtro por Tipo (Água/Gás)

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar que filtro de tipo funciona |
| **Passos** | 1. Selecionar "Água" no dropdown<br>2. Verificar dados<br>3. Selecionar "Gás"<br>4. Verificar dados |
| **Resultado Esperado** | Tabela recarrega com dados do tipo selecionado |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-003: Pesquisa por Unidade/Bloco

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar que pesquisa filtra corretamente |
| **Passos** | 1. Digitar "101" no campo pesquisar<br>2. Verificar filtro<br>3. Digitar "Bloco A"<br>4. Verificar filtro |
| **Resultado Esperado** | Tabela mostra apenas unidades que correspondem à pesquisa |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-004: Registrar Nova Leitura

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar registro de nova leitura |
| **Passos** | 1. Clicar em uma linha da tabela<br>2. Digitar valor no campo M³<br>3. Clicar em "Gravar" |
| **Resultado Esperado** | Leitura salva, tabela atualizada com consumo e valor calculados |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-005: Cálculo Automático de Consumo

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar cálculo correto do consumo |
| **Dados** | Leit. Anterior: 100.000, Leit. Atual: 115.500 |
| **Resultado Esperado** | Consumo = 15.500 M³ |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-006: Cálculo Automático de Valor (Simples)

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar cálculo correto do valor sem faixas |
| **Dados** | Valor base: R$ 10,00/M³, Consumo: 8.500 M³ |
| **Resultado Esperado** | Valor = R$ 85,00 |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-007: Cálculo Automático de Valor (Com Faixas)

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar cálculo correto do valor com faixas progressivas |
| **Dados** | Faixa 1: 0-10M³=R$5, Faixa 2: 10-20M³=R$8, Consumo: 15 M³ |
| **Resultado Esperado** | Valor = (10×R$5) + (5×R$8) = R$ 90,00 |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-008: Validação Leitura Menor que Anterior

| Item | Descrição |
|------|-----------|
| **Objetivo** | Sistema deve rejeitar leitura menor que anterior |
| **Passos** | 1. Selecionar unidade com leit. anterior = 100<br>2. Digitar 95 no campo M³<br>3. Clicar Gravar |
| **Resultado Esperado** | Erro exibido, leitura NÃO salva |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-009: Selecionar Múltiplas Leituras

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar seleção múltipla com checkboxes |
| **Passos** | 1. Marcar checkbox de 3 unidades<br>2. Verificar que estão selecionadas |
| **Resultado Esperado** | Checkboxes marcados, unidades prontas para ação em lote |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-010: Excluir Leituras Selecionadas

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar exclusão de leituras |
| **Passos** | 1. Registrar 2 leituras<br>2. Marcar checkboxes<br>3. Clicar "Excluir" |
| **Resultado Esperado** | Leituras removidas, tabela atualizada |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-011: Editar Leitura Existente

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar edição de leitura já registrada |
| **Passos** | 1. Registrar leitura<br>2. Selecionar checkbox<br>3. Clicar "Editar"<br>4. Alterar valor<br>5. Gravar |
| **Resultado Esperado** | Leitura atualizada com novo valor |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-012: Botão Refresh (Recarregar)

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar que botão refresh recarrega dados |
| **Passos** | 1. Clicar no ícone 🔄 no AppBar |
| **Resultado Esperado** | SnackBar "Recarregando dados...", tabela atualizada |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-013: Totalizadores (Qtnd e Total)

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar cálculo dos totalizadores |
| **Passos** | 1. Registrar 3 leituras com valores<br>2. Verificar rodapé |
| **Resultado Esperado** | Qtnd = 3, Total = soma dos valores |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-014: Anexar Foto do Medidor

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar anexo de foto |
| **Passos** | 1. Clicar "Anexar foto"<br>2. Selecionar imagem<br>3. Gravar leitura |
| **Resultado Esperado** | Ícone muda para ✓, foto salva junto com leitura |
| **Status** | ☐ Passou ☐ Falhou |

---

## ⚙️ Casos de Teste - Aba Configurar

### CT-101: Carregar Configuração Existente

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar carregamento de configuração salva |
| **Passos** | 1. Acessar aba Configurar<br>2. Selecionar tipo existente |
| **Resultado Esperado** | Campos preenchidos com valores salvos |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-102: Salvar Nova Configuração

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar salvamento de nova configuração |
| **Passos** | 1. Preencher valor base<br>2. Clicar Gravar |
| **Resultado Esperado** | SnackBar "Configuração gravada!", dados persistidos |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-103: Configurar Faixas de Valor

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar configuração de faixas progressivas |
| **Passos** | 1. Preencher Faixa 1: 0 a 10 = R$ 5<br>2. Preencher Faixa 2: 10 a 20 = R$ 8<br>3. Gravar |
| **Resultado Esperado** | Faixas salvas corretamente |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-104: Alterar Unidade de Medida

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar alteração de unidade |
| **Passos** | 1. Selecionar "KG" no dropdown<br>2. Gravar |
| **Resultado Esperado** | Unidade alterada para KG |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-105: Adicionar Novo Tipo

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar adição de novo tipo de leitura |
| **Passos** | 1. Clicar no ícone ✏️ ao lado do Tipo<br>2. Digitar "Energia"<br>3. Salvar |
| **Resultado Esperado** | Novo tipo adicionado ao dropdown |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-106: Tipo de Cobrança

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar seleção do tipo de cobrança |
| **Passos** | 1. Selecionar "Junto com Taxa"<br>2. Gravar<br>3. Selecionar "Avulso"<br>4. Gravar |
| **Resultado Esperado** | Opção salva corretamente |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-107: Botão Recarregar Configuração

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar recarregamento de configuração |
| **Passos** | 1. Clicar em "Recarregar" |
| **Resultado Esperado** | SnackBar exibido, configuração recarregada |
| **Status** | ☐ Passou ☐ Falhou |

---

### CT-108: Atualização Automática na Aba Cadastrar

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar que salvar configuração atualiza aba Cadastrar |
| **Passos** | 1. Na aba Configurar, alterar valor base<br>2. Gravar<br>3. Ir para aba Cadastrar<br>4. Verificar campo "Valor base/config" |
| **Resultado Esperado** | Valor atualizado automaticamente |
| **Status** | ☐ Passou ☐ Falhou |

---

## 🔗 Testes de Integração

### TI-001: Fluxo Completo de Leitura

| Item | Descrição |
|------|-----------|
| **Objetivo** | Testar fluxo completo do início ao fim |
| **Passos** | 1. Configurar valores na aba Configurar<br>2. Gravar<br>3. Ir para aba Cadastrar<br>4. Registrar leituras para 5 unidades<br>5. Verificar cálculos<br>6. Excluir uma leitura<br>7. Editar outra leitura<br>8. Verificar totais |
| **Resultado Esperado** | Todos os passos funcionam corretamente |
| **Status** | ☐ Passou ☐ Falhou |

---

### TI-002: Consistência entre Água e Gás

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar independência entre tipos |
| **Passos** | 1. Configurar Água: R$ 10/M³<br>2. Configurar Gás: R$ 25/M³<br>3. Registrar leitura de Água<br>4. Registrar leitura de Gás<br>5. Alternar entre tipos |
| **Resultado Esperado** | Configurações e leituras independentes por tipo |
| **Status** | ☐ Passou ☐ Falhou |

---

### TI-003: Persistência de Dados

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar que dados persistem após sair e entrar |
| **Passos** | 1. Registrar leituras<br>2. Sair da tela<br>3. Voltar para a tela<br>4. Verificar dados |
| **Resultado Esperado** | Dados mantidos corretamente |
| **Status** | ☐ Passou ☐ Falhou |

---

### TI-004: Cache e Refresh

| Item | Descrição |
|------|-----------|
| **Objetivo** | Verificar funcionamento do cache |
| **Passos** | 1. Carregar tela (dados do servidor)<br>2. Desconectar internet<br>3. Clicar refresh<br>4. Verificar comportamento |
| **Resultado Esperado** | Cache utilizado quando offline |
| **Status** | ☐ Passou ☐ Falhou |

---

## ☑️ Checklist de Aprovação

### Funcionalidades Essenciais

- [ ] Carrega lista de unidades corretamente
- [ ] Registra novas leituras
- [ ] Calcula consumo automaticamente
- [ ] Calcula valor sem faixas
- [ ] Calcula valor COM faixas progressivas
- [ ] Valida leitura menor que anterior
- [ ] Exclui leituras selecionadas
- [ ] Edita leituras existentes
- [ ] Anexa foto do medidor
- [ ] Salva configuração de valores
- [ ] Salva faixas de consumo
- [ ] Alterna entre Água/Gás corretamente
- [ ] Pesquisa por unidade/bloco funciona
- [ ] Botão refresh recarrega dados
- [ ] Totalizadores calculam corretamente

### Interface do Usuário

- [ ] Tela carrega sem erros visuais
- [ ] Tabs "Cadastrar" e "Configurar" funcionam
- [ ] Dropdown de tipo funciona
- [ ] Campo de pesquisa funciona
- [ ] Tabela exibe dados corretamente
- [ ] SnackBars de feedback aparecem
- [ ] Loading indicators funcionam
- [ ] Botões têm feedback visual

### Performance

- [ ] Tela carrega em menos de 3 segundos
- [ ] Gravação leva menos de 2 segundos
- [ ] Refresh funciona rapidamente
- [ ] Sem travamentos ou lag

### Tratamento de Erros

- [ ] Erro de conexão exibe mensagem apropriada
- [ ] Erro de validação exibe mensagem clara
- [ ] App não crasha em nenhum cenário

---

## 🐛 Bugs Conhecidos

| ID | Descrição | Status | Prioridade |
|----|-----------|--------|------------|
| BUG-001 | (Reservado para bugs encontrados) | - | - |
| BUG-002 | (Reservado para bugs encontrados) | - | - |
| BUG-003 | (Reservado para bugs encontrados) | - | - |

---

## 📝 Notas dos Testes

### Ambiente de Teste

| Item | Valor |
|------|-------|
| **Data do Teste** | ____/____/________ |
| **Testador** | __________________ |
| **Versão do App** | __________________ |
| **Dispositivo** | __________________ |
| **Navegador/OS** | __________________ |

### Observações Gerais

```
(Espaço para anotações durante os testes)




```

### Aprovação Final

| Item | Decisão |
|------|---------|
| **Resultado Geral** | ☐ APROVADO ☐ REPROVADO ☐ APROVADO COM RESSALVAS |
| **Assinatura** | __________________ |
| **Data** | ____/____/________ |

---

## 🔄 Histórico de Versões

| Versão | Data | Alterações |
|--------|------|------------|
| 1.0 | 07/02/2026 | Documento criado |
