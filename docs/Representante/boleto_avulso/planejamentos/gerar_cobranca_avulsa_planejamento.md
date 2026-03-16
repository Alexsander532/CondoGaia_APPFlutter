# Planejamento de Implementação — Gerar Cobrança Avulsa / Despesas Extraordinárias

**Data:** 14/03/2026  
**Estimativa Total:** ~15 a 20 horas de desenvolvimento

---

## 📍 Fase 1: Setup e Navegação Básica (1h)
1. Criar diretório para a nova feature dentro de `Representante_Features` (ex: `cobranca_avulsa`).
2. Criar a tela base `cobranca_avulsa_screen.dart` utilizando `Scaffold`.
3. Adicionar o cabeçalho "Gerar Cobrança Avulsa/ Desp. Extraord." padronizado com o projeto.
4. Na tela de "Gestão de Boletos" do Representante (ponto de origem), localizar a `AppBar` e adicionar à área de `actions` o ícone de botão circular `+`.
5. Fazer a navegação via `Navigator.push` utilizando esta nova rota.

## 📍 Fase 2: Modelagem e Supabase (2h)
1. **Verificar e Criar Tabelas:**
   - Conferir modelo no banco para `cobrancas_avulsas` ou plano de contas associado à unidades.
   - Criar campos faltantes se necessário: *condominio_id, unidade_id, morador_id, conta_contabil, valor, data_vencimento, mes_ref, ano_ref, descricao, tipo_cobranca ('avulso' ou 'junto_taxa'), status, anexo_url*.
2. **Clean Architecture - Estrutura Local:**
   -  Criar `CobrancaAvulsaEntity` (Domain) e `CobrancaAvulsaModel` (Data - fromJson/toJson).
   -  Criar repository (`cobranca_avulsa_repository.dart`) e métodos (DataSource) para enviar um lote ou consultar cobranças.

## 📍 Fase 3: Layout — Estrutura e Tabs (1,5h)
1. Implementar `DefaultTabController` com *length: 2*.
2. As duas guias (Tabs) no header devem se chamar: **Pesquisar** e **Cadastrar**, com a linha espessa (indicator) azul escuro.
3. Configurar a estrutura bloc/Cubit (*CobrancaAvulsaCubit*) e ligar via `BlocProvider` envolvendo o Scaffold principal da tela.

## 📍 Fase 4: Aba "Cadastrar" - Formulário (4h)
1. Criar o Widget `CadastrarCobrancaTab`.
2. **Inputs Padrão:**
   - Dropdown de Conta Contábil + botão IconButton `+` ao lado.
   - Input Search "Pesquisar unidade/bloco ou nome".
   - Input Mês/Ano (utilizando picker simplificado `_ / _`).
   - Input de Descrição e Input de Dia.
   - Input Valor Monetário R$ (fazer regex/máscara).
3. **Inputs Condicionais (Reatividade com Cubit):**
   - Checkbox **Recorrente**: Ao acionar `Sim`, abrir blocos (Qntd. Meses, Inicio _/_, Fim_/_).
   - Dropdown **Cobrar**: Ao escolher "Boleto Avulso", deve exibir o botão `Gerar Boleto` e checkboxes `Enviar para Registro` e `Disparar por E-Mail`. Caso "Junto a Taxa Cond.", mostra botão `Gerar Composição`.
4. **Upload:** Componente file picker / image picker para foto e texto do link, convertendo para Base64 ou enviando para Supabase Storage na Fase 7.

## 📍 Fase 5: Aba "Cadastrar" - Tabela de Prévia (3h)
1. Componente de DataPicker/List local para gerenciar o "Carrinho" de moradores que vão receber as cobranças inseridas (Lote de ações).
2. Criar uma `DataTable` ou `ListView` baseada no mock da tela contendo as colunas: `[NOME, BL/UND, DATA VENC, VALOR, CONTA CONT., COBRAR, DESCRIÇÃO, ÍCONE IMAGEM]`.
3. No rodapé, implementar a somatória (`Total R$`) iterando sobre os valores do *Cubit State* e um botão `Excluir` interagindo com itens checados do lote de envio.

## 📍 Fase 6: Aba "Pesquisar" (Visualização e Filtros) (3,5h)
1. Criar o Widget `PesquisarCobrancaTab`.
2. **Filtros Header:** Reutilizar Dropdown "Conta Contábil", Input text "unidade/nome", e Mês/ano. Integrar botão "Pesquisar".
3. **Respostas da Query (Supabase):** Implementar e mapear a query `SELECT` com *eq, like* e preencher no componente inferior uma `DataTable` idêntica.
4. Adicionar a coluna **Status** (Pago / Pendente).
5. Mesma lógica de rodapé para seleção em lote (checkbox da ponta da tabela) e botão "Excluir" (invocando `.delete()` no Supabase com validações de segurança).

## 📍 Fase 7: Regra de Negócio Asaas e Supabase (3h)
1. Construir fluxo do botão `Gerar Composição`: Inserir rows (linhas de registro) na base de do condomínio assinaladas com flag `junto_taxa`.
2. Construir fluxo do botão `Gerar Boleto` (Avulso): Chamar UseCase que invoca um `Post` na nuvem / backend (ex. PHP Laravel já existente no projeto) para comunicar com a API Asaas.
   - Garantir injeção das meta-flags "dispara email" se habilitadas;
   - Recebido o `bank_slip_url`, efetuar POST na tabela relacional de cobranças extras.
3. Efetuar função de Upload de Storage para quando houver *Anexo*. 

## 📍 Fase 8: Testes e UX Review (2h)
1. Tratamentos visuais (SnackBars) de preenchimento nulo: *Ex: Ao apertar Enviar e n ter selecionado Conta Contábil, piscar de vermelho.*
2. Tratamentos Loading de Processamento da API.
3. Testes end-to-end simulando a criação de 2 multas e garantindo que salvam no banco.

---

**Ordem recomendada de execução:**
Fase 1 ➔ Fase 2 ➔ Fase 3 ➔ Fase 4 ➔ Fase 5 ➔ Fase 6 ➔ Fase 7 ➔ Fase 8