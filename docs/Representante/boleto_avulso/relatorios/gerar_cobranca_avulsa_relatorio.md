# Relatório de Definição — Gerar Cobrança Avulsa / Despesa Extraordinária

**Data:** 14/03/2026
**Responsável:** Equipe de Desenvolvimento
**Feature:** Cobrança Avulsa / Despesa Extraordinária (Representante)

---

## 1. Visão Geral

A funcionalidade **Gerar Cobrança Avulsa / Despesa Extraordinária** é parte do módulo do Representante (Síndico/Administrador) e permite o lançamento de cobranças específicas (como consumo de água, gás, multas, aluguéis de espaços, etc.) aos moradores. Ela será acessada através do botão de adição (`+` cinza) no canto superior direito da tela de Gestão de Boletos do Representante.

A tela será composta por duas abas (Tabs) principais: **Pesquisar** e **Cadastrar**.

## 2. Abas e Componentes de UI

### 2.1 Aba "Cadastrar"
Focada na criação e envio de novas cobranças.

**Formulário de Cadastro:**
- **Conta Contábil (Dropdown):** Seleção do tipo de cobrança (ex: Água, Gás, Salão de Festa, Multa, etc.), com opção de adicionar novas contas (`+`).
- **Pesquisar unidade/bloco ou nome (Input de busca):** Permite direcionar a cobrança a todos os moradores (padrão) ou a moradores/unidades específicos.
- **Mês/Ano (Seletor):** Identifica a competência da cobrança (padrão: mês atual).
- **Descrição (Input de texto):** Detalhamento da cobrança.
- **Cobrar (Dropdown):** Define como o morador será cobrado. Opções:
  1. `Junto a Taxa Cond.` (Adiciona na composição do boleto mensal do condomínio)
  2. `Boleto Avulso` (Gera um boleto separado)
- **Dia (Input numérico):** Define o dia de vencimento.
- **Valor por Unid. R$ (Input monetário):** Valor cobrado por unidade selecionada.
- **Recorrente (Checkbox):** Se marcado, abre os campos "Qntd. de Meses", "Início (mês/ano)" e "Fim (mês/ano)".
- **Upload de anexo:** Campos para inserir "Link" ou "Anexar foto" (upload de imagem/arquivo de comprovante, como conta de água/gás).
- **Botões Ação (Renderizados condicionalmente):**
  - `Gerar Composição` (Para a opção "Junto a Taxa Cond.")
  - `Gerar Boleto` (Exibido apenas na opção "Boleto Avulso"), com os checkboxes auxiliares "Enviar para Registro" e "Disparar por E-Mail" (Integração ASAAS).

**Tabela de Composição / Prévia:**
Exibe uma prévia das unidades afetadas com colunas: *Checkbox, NOME, BL/UND, DATA VENC, VALOR, CONTA CONT., COBRAR, DESCRICAO*. 
- **Rodapé:** Botão `Excluir` (para itens selecionados), e totais (`Qtidade` e `Total R$`).

### 2.2 Aba "Pesquisar"
Focada na visualização, filtro e gestão de cobranças extras já geradas.

**Filtros de Pesquisa:**
- **Conta Contábil (Dropdown)**
- **Busca por unidade/bloco/nome**
- **Seletor de Mês/Ano**
- **Botão `Pesquisar`**

**Tabela de Resultados:**
Exibe os registros encontrados. Colunas: *Checkbox, NOME, BL/UND, DATA VENC, VALOR, CONTA CONT., STATUS (Ex: Pago, Pendente), DESCRICAO, e ícone de visualização/anexo*.
- **Rodapé:** Botão `Excluir` para remoção em lote, totalizadores "Qtidade" e "Total R$".

## 3. Arquitetura e Integrações Necessárias

**1. Supabase (Backend/Database):**
- Tabela de Lançamentos (ex: `cobrancas_avulsas` ou relacional parecida) para armazenar os lançamentos antes de virarem boletos consolidados ou para boletos avulsos diretos.
- Tabela de referências/Enum no banco para gerir o `Plano de contas` (Conta contábil).
- `Supabase Storage (Bucket)` para armazenar o upload das fotos anexadas (ex: fotos do relógio do gás do morador).

**2. Integradores (ASAAS, Serviços):**
- Caso a opção defina `Boleto Avulso`, "Gerar Boleto" precisará comunicar com o backend ou de forma autônoma emitir charge POST via API do Asaas e receber o link.
- Se for `Junto a Taxa Cond.`, os valores ficam atrelados à unidade/mês_ano formando um demonstrativo, aguardando o rateio da Gestão de Boletos.

**3. Gerenciamento de Estado (BLoC/Cubit):**
- Estruturação do estado em base a formulários iterativos (exibindo/recolhendo campos como *Recorrente* dependendo da seleção).
- Gestão reativa da lista de "prévia" antes do envio real, calculando em tela os totais.