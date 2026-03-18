# Documentação da Feature: Acordo do Representante

**Data de Criação:** 16 de março de 2026  
**Horário de Criação:** 01:30 
**Versão:** 1.0  

---

## 1. Visão Geral
A feature de **Acordo do Representante** tem como objetivo fornecer uma interface e um fluxo de dados estruturado para que representantes (legais ou comerciais) possam registrar, acompanhar e gerenciar acordos financeiros referentes a **boletos atrasados** (que já passaram da data de validade e não foram pagos).

O foco principal é possibilitar o parcelamento de débitos (ex: dividir um boleto vencido de R$ 100,00 em 5 parcelas de R$ 20,00) de maneira flexível, sem perder o registro histórico da dívida original.

---

## 2. Casos de Uso
1. **Listagem e Gestão**: O sistema dispõe de separadores (`Pesquisar`, `Negociar`, `Histórico`) para facilitar o fluxo.
2. **Registro e Negociação**: Selecionar um ou mais boletos em atraso na listagem e convertê-los em um novo acordo de parcelamento, marcando o débito anterior.
3. **Cancelamento de Acordos**: Função com modal (popup) específico para cancelar um parcelamento vigente. Ele apresenta um sumário exato do que já foi pago, do que está ativo e do que está a vencer.
4. **Exportação e Comunicação**: Ações em lote (via checkbox) na lista para gerar PDF, visualizar e engatilhar envio de e-mails de cobrança/acordo.

---

## 3. Estrutura de Dados Sugerida (Database)
A estrutura base necessita manter relações sólidas entre a dívida original e o novo parcelamento:

- **Tabela:** `representante_acordos`
  - `id` (UUID, Primary Key)
  - `boleto_original_id` (UUID, Foreign Key - Referência à cobrança original que foi desmembrada)
  - `unidade_id` / `bloco_id` (Identificação do condômino)
  - `status` (Enum: 'ATIVO', 'PAGO', 'CANCELADO')
  - `documento_url` (String - Link para storage de anexo do acordo)
  - `data_criacao` e `created_at` / `updated_at` (Timestamps)
 
- **Tabela Relacional (Parcelas de Acordo):** `boletos_acordo` (ou a mesma tabela de recibos com um campo `acordo_id`)
  - `id` (UUID)
  - `acordo_id` (Referência ao Acordo pai)
  - `valor` (Decimal - ex: R$ 20,00)
  - `vencimento` (Date)
  - `status` (Enum: 'A VENCER', 'PAGO', 'ATIVO(Vencido)')

---

## 4. Requisitos de Interface (UI/UX - Flutter)

### 4.1. Tela de Pesquisa e Gestão (Home/Gestão/Acordo)
A tela é dividida pelas guias **Pesquisar**, **Negociar** e **Histórico**.
- **Filtros (Seção Pesquisar):**
  - **Mês de Vencimento e Intervalo (De - Até)**.
  - **Tipo de Emissão:** Todos, Avulso, Mensal, Acordo.
  - **Situação:** Todos, Ativo(Vencido), A vencer, Ativo / A vencer, Cancelado, Pago, Cancelado acordo.
- **Tabela ou Listagem:**
  - Colunas: Bloco/Unidade (`BL/UNID`), Parcela (`PAR` - Ex: 2/5), Mês/Ano, Data de Venc., Valor, Tipo, Situação, Anexo.
  - Controles de seleção (Checkboxes) para ações em lote e somatório de Qtnd. e Total R$ das seleções.
- **Botões de Ação na Listagem:** Gerar PDF, Visualizar, Email e Share.  
- **Botão Principal:** Formatos de botões de negociação em destaque ("NEGOCIAR").

### 4.2. Tela de Negociação (Aba Negociar)
Esta guia é o motor da criação do acordo. O processo exige estipular os parâmetros da dívida, realizar a simulação e, em seguida, validar o "Resultado Final" para a configuração e emissão dos boletos.

**1. Parametrização do Acordo e Encargos:**
- **Configuração Geral:** Definição da `Venc. 1º Parcela` e do `Nº de Parcelas`.
- **Taxas Base:** Campos para preenchimento de valores (em R$) independentes para `Juros (Ex: 1%)`, `Multa (Ex: 2%)` e `Índice de Correção (Ex: IGPM)`.
- **Outros Acréscimos (Seção Expansível):**
  - Dropdown com tipos de acréscimo: ex: *Taxa Adm. Cobrança* e *Honorários Advocatícios*.
  - Alternativa de valor: Opção de aplicar o acréscimo em Valor Real (`R$`) ou Porcentagem (`%`).
  - *Regra de Interface:* Caso seja selecionada a "Porcentagem (%)", o sistema deve obrigatoriamente habilitar o checkbox **"Sobre Juros/Multa"**.
- **Entrada (Pagamento Antecipado Opcional):**
  - Controle de ativação via checkbox de `Entrada`.
  - Habilita os campos: `Valor R$` e `Data` de pagamento da entrada.
  - Exibição dinâmica do saldo remanescente abaixo do campo de valor (`Restante: R$`).
- **Ação:** Botão macro `Simular`, estruturando a projeção na tela abaixo.

**2. Resultado Final e Ferramentas de Emissão:**
- **Tabela de Simulação (Resultado Final):** 
  - Estrutura de dados linha a linha (com checkboxes para seleção) abordando: `BL/UNID`, `PARCELA` (ex: 1/5), `MÊS/ANO`, `DATA VENC`, `VALOR`, `JUROS`, `MULTA`, `ÍNDICE`, `OUT. ACRESC` e `TOTAL`. 
  - Controles gerenciais acima da tabela: Botões de `Editar` e `Excluir` em lote para cenários específicos, com cômputo dinâmico de `Total: R$`.
- **Documentação Opcional e Anexos:** 
  - Acesso para gerar/submeter o `Termo C.D.` (Termo de Confissão de Dívida).
  - Componente para upload visual `Anexar foto` (útil para adicionar provas de negociação passadas, comprovantes etc.).
- **Texto Boleto do Acordo:** Campo de edição livre, permitindo que o representante preencha o descritivo de instruções ou diretrizes legais que será estampado nos boletos gerados ao condômino.
- **Setor de Emissão:**
  - **Customização de Layout:** Parâmetros de UI (Radio buttons) para escolher a exibição em `Layout Padrão` ou `Carnê`.
  - **Ações Pré-Emissão:** Funcionalidades de `Gerar PDF`, `Visualizar`, disparar via `Email` e ícone de compartilhamento nativo.
  - **Ação Definidora:** Botão principal e em destaque **`Gerar Boletos`**.
  - **Automações Integradas:** Dois checkboxes finais (`Enviar para Registro` e `Disparar por E-Mail`) para que a plataforma distribua automaticamente o acordo via sistema e formalize junto à administradora bancária.

### 4.3. Tela de Histórico (Aba Histórico)
Esta aba serve como um CRM (Customer Relationship Management) básico para o controle de cobrança extrajudicial, mantendo uma linha do tempo dos contatos feitos e dos feedbacks do condômino.
- **Entrada de Novo Histórico:** 
  - Campo de texto longo (`Texto:`) onde o representante pode redigir ou editar notas e ocorrências de contato (ex: promessas de pagamento, retornos telefônicos, acordos verbais prévios).
  - *Regra de Inserção:* Ao registrar a anotação, as informações complementares (`Data` e `Hora`) deverão ser inseridas **automaticamente** pelo sistema.
- **Tabela de Acompanhamento:** 
  - Colunas: `BL/UNID`, `DATA`, `HORA` e `DESCRICAO`.
  - Apresenta de forma cronológica as observações salvas, mantendo o histórico de tratativas.
- **Indicadores Visuais e Regras Auxiliares:**
  - Presença de um **ícone de balança (Ação Judicial):** Se a unidade possuir ação judicial em curso, este ícone deverá ser apresentado de forma destacada, funcionando como um alerta para o operador em todas as guias.
  - O filtro de pesquisa global da barra superior deve conseguir apontar o Bloco/Unidade e o Nome quando o usuário digitar a referência.

### 4.4. Popup de "Cancelar Acordo"
O usuário acessa uma interface de cancelamento onde há o resumo das antigas parcelas do atual acordo.
- Dados principais no topo: Bloco/Unidade e Nome do Responsável.
- Tabela interna ilustrando o detalhe de cada parcela: Data, Valor, Situação (Pago, Ativo, A Vencer).
- Somatórios obrigatórios na UI para clareza operacional/comercial:
  - `TOTAL PAGAS R$`
  - `TOTAL ATIVAS R$`
  - `TOTAL A VENCER R$`
- Um botão de confirmação explícito e em destaque: `CANCELAR ACORDO`.

---

## 5. Regras de Negócio

1. **Gestão do Histórico e Inativação (NUNCA Deletar):**
   - Quando um boleto original (ex: R$ 100) é usado para gerar um acordo dividido, a cobrança raiz original muda de status para `INATIVO` (ou "NEGOCIADO").
   - **Extrema Importância**: Nunca se exclui o débito "pai" do banco de dados. Isso garante que, se o acordo for desfeito (cancelado) posteriormente, o sistema seja capaz de rastrear, recuperar a conta raiz, e descontar o que já foi liquidado pelo acordo.
   
2. **Proibição de "Acordo de Acordo":**
   - É terminantemente **proibido** fazer uma re-negociação de um boleto que *já* é em si a parcela de um acordo vigente.
   - Regra de trava no APP: *“Para renegociar uma dívida sob acordo, é necessário primeiro cancelar o acordo atual antes de firmar o novo acordo.”*

3. **Cálculo de Desfazimento (Desconto na dívida original):**
   - Em caso de cancelamento onde houve pagamento parcial, o abatimento deverá ser tratado de forma contábil justa. Ex: Uma dívida de R$ 100 gerou parcelas de R$ 20. Se 2 forem pagas (R$ 40) e o cenário for cancelado a seguir, os relatórios "Total Pagas" orientarão a plataforma na geração do saldo remanescente na conta da unidade ajustado ao valor atualizado.

4. **Taxonomia de Situações:**
   - A Situação "Cancelado acordo" deve ser diferenciada categoricamente de um "Cancelado" corriqueiro (erro de base).
   - Imprescindível indicar claramente a "Parcela" (ex:`2/5`) na UI listada para não confundir o inquilino/representante sobre onde o usuário se encontra na jornada do pagamento daquele Acordo.

---

## 6. Próximos Passos (V2)
- Assinatura digital nativa embarcada na plataforma.
- Notificações (Push e E-mail) para a contraparte informando sobre as negociações pendentes.
- Automações de cálculo de multas/juros ao reintegrar um Acordo Cancelado à base de INATIVOS originais.
