# Tela: Gerar Cobrança Avulsa / Despesa Extraordinária

## Visão Geral

Esta tela permite que o **síndico** gere cobranças avulsas ou despesas extraordinárias para unidades específicas do condomínio.

- Localização: `Home > Gestão > Boleto > Gerar Cobrança Avulsa / Desp. Extraord.`
- A tela é dividida em **duas abas**: **Pesquisar** e **Cadastrar**
- A aba ativa é destacada com sublinhado azul e texto em azul (`#185FA5`)
- A aba inativa tem texto em cinza secundário

---

## Estrutura global da tela

```
┌─────────────────────────────┐
│ Status bar (hora + ícones)  │
│ Header (logo + breadcrumb)  │
│ Tabs: [Pesquisar] [Cadastrar]│
├─────────────────────────────┤
│                             │
│   Conteúdo da aba ativa     │
│                             │
├─────────────────────────────┤
│ Rodapé fixo (total + ações) │
└─────────────────────────────┘
```

---

## Aba 1: Pesquisar

### Objetivo
Listar, filtrar e gerenciar cobranças avulsas já cadastradas.

### Layout da aba

```
┌─────────────────────────────────────────┐
│ [Conta Contábil ▾]                      │
│ [Buscar unidade/bloco/nome            🔍]│
│ ← Mês/Ano →              [Pesquisar]    │
├─────────────────────────────────────────┤
│ ☐ NOME | BL/UNID | VENC | VALOR | CONTA | STATUS | DESC │
│ ☑ José da Silva | B/102 | 10/08/2022 | R$111 | Gás | Pago │
│ ☐ José da Silva | B/102 | 10/08/2022 | R$111 | Gás | Pago │
│ ☐ ...                                   │
├─────────────────────────────────────────┤
│ [Excluir]           Qtd.: X  Total: R$  │
└─────────────────────────────────────────┘
```

### Filtros

| Campo | Tipo | Valor padrão | Comportamento |
|---|---|---|---|
| Conta Contábil | Dropdown | "Todos" | Opções: Todos, Taxa Condominal, Multa por Infração, Advertência, Controle/Tags, Manutenção/Serviços, Salão de Festa/Churrasqueira, Água, Gás, Sinistro |
| Buscar unidade/bloco ou nome | Campo de texto com ícone de lupa | Vazio | Filtra a lista em tempo real |
| Mês/Ano | Seletor com setas ← → | Mês atual | Navega mês a mês. Formato: MM/AAAA |
| Botão Pesquisar | Botão primário azul | — | Dispara a busca com os filtros preenchidos |

### Lista de resultados

- Cabeçalho fixo com colunas: `☐ | NOME | BL/UNID | DATA VENC | VALOR | CONTA CONT. | STATUS | DESCRIÇÃO`
- Cada linha tem um **checkbox** de seleção à esquerda
- Linhas selecionadas ficam com fundo azul claro (`#E6F1FB`)
- O checkbox global no cabeçalho seleciona/deseleciona todos

### Ações disponíveis na aba Pesquisar

| Ação | Como acessa | Comportamento |
|---|---|---|
| Excluir | Botão "Excluir" no rodapé, ativo quando há seleção | Abre modal de confirmação antes de excluir. Após confirmação, remove os registros e atualiza a lista. |
| Reenviar boleto por e-mail | *(a definir — provavelmente ação inline na linha ou botão no rodapé)* | Reenvia o boleto para o e-mail do proprietário |
| Editar | *(a definir)* | Permite editar valor ou descrição de uma cobrança |
| Ver detalhes | *(a definir)* | Exibe os detalhes completos do registro |

### Rodapé da aba Pesquisar

- Fixo na base da tela
- Exibe em tempo real: `Qtidade: X` e `Total: R$ XXX,XX` com base nas linhas selecionadas
- Botão **Excluir** em vermelho à esquerda, ativo apenas quando há pelo menos 1 linha selecionada

---

## Aba 2: Cadastrar

### Objetivo
Criar uma nova cobrança avulsa ou despesa extraordinária para unidades selecionadas manualmente, com valores individuais por unidade.

### Fluxo geral do usuário

O cadastro segue **3 etapas em sequência visual na mesma tela**, de cima para baixo. Não são steps colapsáveis nem abas — todo o conteúdo é visível de uma vez, com rolagem vertical.

```
Etapa 1 → Classificação (o que é e quando)
    ↓
Etapa 2 → Forma de cobrança (como vai cobrar)
    ↓
Etapa 3 → Selecionar unidades e definir valores individuais
    ↓
Botão de ação (Gerar Composição  ou  Gerar Boleto)
```

---

### Layout completo da aba Cadastrar

```
┌─────────────────────────────────────────┐
│                                         │
│  1 — CLASSIFICAÇÃO                      │
│  ─────────────────────────────────────  │
│  [Conta Contábil ▾      ] [Mês/Ano ▾]  │
│  [Descrição da cobrança...           ]  │
│                                         │
│  2 — FORMA DE COBRANÇA                  │
│  ─────────────────────────────────────  │
│  [Junto à Taxa Cond. | Boleto Avulso]   │  ← toggle segmentado
│                                         │
│  (se Boleto Avulso)                     │
│  Dia de vencimento: [__]                │
│                                         │
│  Recorrente:  [Não] [Sim]               │
│                                         │
│  (se Recorrente = Sim)                  │
│  ┌─────────────────────────────────┐    │
│  │ Início      Fim      Qtd. Meses │    │
│  │ [08/2024] [12/2024]    [  5   ] │    │
│  └─────────────────────────────────┘    │
│                                         │
│  3 — SELECIONAR UNIDADES E VALORES      │
│  ─────────────────────────────────────  │
│  [Buscar unidade, bloco ou nome...  🔍] │
│                                         │
│        Unidade   Proprietário  Valor R$ │
│  ☑     B / 102   José S.      [111,00] │  ← selecionada, valor editável
│  ☐     C / 102   Maria S.     [______] │  ← não selecionada, valor bloqueado
│  ☐     A / 201   Carlos M.    [______] │
│                                         │
│  [        Gerar Composição           ]  │  ← se Junto à Taxa Cond.
│     ou                                  │
│  [           Gerar Boleto            ]  │  ← se Boleto Avulso
│  ☐ Enviar para Registro                 │
│  ☐ Disparar por E-Mail                  │
│                                         │
├─────────────────────────────────────────┤
│ Selecionadas: X unid. · R$ XXX,XX  [Excluir] │
└─────────────────────────────────────────┘
```

---

### Separadores entre etapas

- Entre cada etapa: linha divisória horizontal `0.5px solid var(--color-border-tertiary)`, com `margin: 10px 0`
- Label da etapa: texto 10px, peso 500, cinza secundário, caixa alta, espaçamento de letra leve
  - Exemplos: `1 — CLASSIFICAÇÃO`, `2 — FORMA DE COBRANÇA`, `3 — SELECIONAR UNIDADES E VALORES`

---

### Etapa 1 — Classificação

#### Campo: Conta Contábil

- Tipo: Dropdown
- Obrigatório: Sim
- Opções: Todos, Taxa Condominal, Multa por Infração (Constar no relatório), Advertência (Constar no relatório), Controle/Tags, Manutenção/Serviços, Salão de Festa/Churrasqueira, Água, Gás, Sinistro
- Valor padrão: a definir (possivelmente o último usado ou configurável pelo condomínio)
- Layout: ocupa **~60% da largura** da linha, à esquerda, na mesma linha que Mês/Ano
- Estilo: fundo branco, borda `0.5px solid var(--color-border-tertiary)`, border-radius 6px, padding 6px 8px, font-size 12px

#### Campo: Mês/Ano

- Tipo: Dropdown ou seletor de mês/ano
- Obrigatório: Sim
- Valor padrão: mês atual
- Layout: ocupa **~40% da largura** da linha, à direita de Conta Contábil
- Mesmo estilo visual do campo Conta Contábil

#### Campo: Descrição

- Tipo: Campo de texto livre, linha única (pode expandir para multilinha conforme o conteúdo)
- Obrigatório: Sim
- Placeholder: `"Descrição da cobrança..."`
- Layout: largura total (100%), abaixo da linha Conta Contábil + Mês/Ano
- Esta descrição aparecerá no boleto ou na composição mensal do proprietário
- Mesmo estilo visual dos outros campos

---

### Etapa 2 — Forma de cobrança

#### Toggle de modalidade

- Componente: **toggle segmentado** — dois botões lado a lado sem espaço entre eles, dentro de um container com borda
- Opções: `Junto à Taxa Cond.` | `Boleto Avulso`
- Apenas **uma opção pode estar ativa ao mesmo tempo**
- Opção ativa: fundo azul `#185FA5`, texto branco, font-weight 500
- Opção inativa: fundo branco, texto cinza secundário
- Container: border `0.5px solid var(--color-border-tertiary)`, border-radius 6px, overflow hidden
- Largura: 100% da linha
- Font-size: 11–12px

#### Campo condicional — Dia de vencimento

- **Visível apenas quando "Boleto Avulso" está ativo**
- **Oculto (removido do layout) quando "Junto à Taxa Cond." está ativo**
- Tipo: Campo numérico
- Label: `"Dia de vencimento"` acima do campo, ou inline à esquerda
- Representa o dia do mês em que o boleto vencerá (ex: 10)
- Largura: ~80px (campo curto, não precisa de largura total)

#### Toggle de recorrência

- Layout: label `"Recorrente"` à esquerda + dois botões `Não` | `Sim` compactos alinhados à direita, na mesma linha
- Botões: mesma lógica do toggle de modalidade, mas menores (padding 4px 8px)
- Padrão: `Não` ativo

#### Bloco condicional de recorrência

- **Visível apenas quando "Recorrente = Sim"**
- **Oculto (removido do layout) quando "Recorrente = Não"**
- Quando some, o espaço é recolhido — não deixa lacuna visual
- Visual: container com fundo cinza claro `var(--color-background-secondary)`, border-radius 6px, padding 6px 8px

Estrutura interna do bloco:

```
┌──────────────────────────────────────┐
│  Início          Fim       Qtd. Meses│
│  [08/2024]    [12/2024]      [  5  ] │
└──────────────────────────────────────┘
```

- **Início**: seletor de mês/ano. Label `"Início"` em 10px cinza acima do valor. Badge com fundo azul claro `#E6F1FB`, texto azul `#185FA5`, border-radius 4px.
- **Fim**: seletor de mês/ano. Label `"Fim"` em 10px cinza acima do valor. Mesmo estilo do Início.
- **Qtd. de Meses**: calculado automaticamente com base em Início e Fim (a definir se também é editável manualmente). Label `"Qtd. Meses"` em 10px cinza acima do valor. Badge com fundo âmbar claro `#FAEEDA`, texto âmbar escuro `#854F0B`, border-radius 4px.
- Os três ficam em **uma única linha horizontal**, dividindo o espaço igualmente

---

### Etapa 3 — Selecionar unidades e valores

Esta etapa é a mais importante e representa a maior mudança em relação ao layout original. O valor por unidade é definido **inline na tabela**, e não em um campo global no formulário.

#### Campo de busca de unidades

- Tipo: Campo de texto com ícone de lupa à direita
- Placeholder: `"Buscar unidade, bloco ou nome..."`
- Filtra a tabela de unidades abaixo em tempo real
- Largura: 100%
- Estilo: mesmo padrão dos outros campos (fundo branco, borda, border-radius 6px)

#### Tabela de unidades

Lista todas as unidades do condomínio (filtradas pela busca). O síndico seleciona quais receberão a cobrança e define o valor de cada uma diretamente na linha.

**Estrutura de colunas:**

| Coluna | Largura | Conteúdo |
|---|---|---|
| Checkbox | ~20px fixo | Caixa de seleção da unidade |
| Unidade | `1fr` (flexível) | Bloco e número (ex: `B / 102`) |
| Proprietário | ~60px fixo | Nome abreviado (ex: `José S.`) em `var(--color-text-secondary)` |
| Valor (R$) | ~64px fixo | Campo de input numérico editável, alinhado à direita |

**Grid CSS:** `grid-template-columns: 20px 1fr 60px 64px`

**Cabeçalho da tabela:**
- Fundo transparente
- Separado do corpo por linha divisória inferior `0.5px solid var(--color-border-tertiary)`
- Font-size: 10px, font-weight 500, cor cinza secundário
- Colunas: `(vazio) | Unidade | Proprietário | Valor (R$)`

**Linhas da tabela — estados:**

Estado **não selecionado** (padrão):
- Fundo: transparente
- Checkbox: borda `0.5px solid var(--color-border-secondary)`, fundo branco, vazio
- Campo de valor: fundo `var(--color-background-secondary)`, borda cinza, placeholder `"0,00"` em cinza, **não editável** (desabilitado)
- Separado da próxima linha por `0.5px solid var(--color-border-tertiary)` na base

Estado **selecionado** (checkbox marcado):
- Fundo: azul claro `#E6F1FB`, border-radius 4px, padding horizontal 4px
- Checkbox: fundo azul `#185FA5`, borda azul, ícone de check branco (`✓`)
- Campo de valor: fundo `var(--color-background-secondary)`, borda `0.5px solid var(--color-border-secondary)`, **editável**, cursor posicionado para digitação
- Ao marcar o checkbox, o campo de valor é ativado automaticamente e recebe foco

**Comportamento de seleção:**
- Ao **marcar** o checkbox: linha fica azul, campo de valor é ativado e recebe foco imediato para digitação
- Ao **desmarcar** o checkbox: valor é apagado, campo volta a ser desabilitado, fundo volta ao transparente
- Cada unidade tem seu próprio valor — não existe um valor global compartilhado entre todas

---

### Botão de ação principal

O botão muda conforme a modalidade selecionada na Etapa 2. Apenas **um** dos dois botões é exibido por vez.

#### Quando "Junto à Taxa Cond." está ativo:

```
[           Gerar Composição           ]
```

- Fundo: azul `#185FA5`
- Texto: branco, font-size 12–13px, font-weight 500
- Largura: 100%
- Border-radius: 6px
- Padding: 10px vertical
- Sem checkboxes adicionais abaixo

#### Quando "Boleto Avulso" está ativo:

```
[             Gerar Boleto             ]
☐ Enviar para Registro    ☐ Disparar por E-Mail
```

- Botão com mesma estilização do "Gerar Composição"
- Abaixo do botão, dois checkboxes em linha horizontal:
  - `☐ Enviar para Registro` — registra o boleto na instituição financeira
  - `☐ Disparar por E-Mail` — envia o boleto gerado por e-mail ao proprietário
- Checkboxes lado a lado, separados por espaço, font-size 12px, cor `var(--color-text-secondary)`

#### Feedback após ação

Ao clicar em qualquer botão de ação:
- **Sucesso**: exibe banner ou toast com fundo verde e mensagem de confirmação na tela
- **Erro**: exibe banner ou toast com fundo vermelho e descrição do problema
- **Não redireciona** para outra tela — o feedback é inline

---

### Rodapé fixo da aba Cadastrar

Fixo na base da tela, separado do conteúdo por linha divisória superior `0.5px solid var(--color-border-tertiary)`.

```
┌──────────────────────────────────────────┐
│ Selecionadas                  [Excluir]  │
│ X unid. · R$ XXX,XX                      │
└──────────────────────────────────────────┘
```

- **À esquerda:**
  - Linha 1: label `"Selecionadas"` em font-size 11px, cor `var(--color-text-secondary)`
  - Linha 2: valor `"X unid. · R$ XXX,XX"` em font-size 12px, font-weight 500, cor `var(--color-text-primary)`
- **À direita:** botão `"Excluir"` em vermelho `#E24B4A`, font-size 12px
  - Ativo apenas quando há pelo menos 1 unidade selecionada
  - Quando inativo, fica em cinza ou oculto
- **Total calculado em tempo real:** soma dos valores preenchidos nas unidades selecionadas
- Fundo: `var(--color-background-primary)`

---

## Tokens de design

| Propriedade | Valor |
|---|---|
| Cor primária (azul) | `#185FA5` |
| Fundo de linha selecionada | `#E6F1FB` |
| Cor de ação destrutiva | `#E24B4A` |
| Cor de badge âmbar (texto) | `#854F0B` |
| Cor de badge âmbar (fundo) | `#FAEEDA` |
| Borda padrão | `0.5px solid var(--color-border-tertiary)` |
| Borda de ênfase | `0.5px solid var(--color-border-secondary)` |
| Border-radius de campo | `6px` |
| Border-radius de card | `12px` |
| Font-size base | `13px` |
| Font-size label de etapa | `10px`, peso 500, caixa alta |
| Font-size cabeçalho de tabela | `10px`, peso 500 |
| Font-size checkbox label | `12px` |
| Cor de texto principal | `var(--color-text-primary)` |
| Cor de texto secundário | `var(--color-text-secondary)` |
| Cor de placeholder | `var(--color-text-tertiary)` |
| Fundo de bloco destacado | `var(--color-background-secondary)` |
| Fundo de surface | `var(--color-background-primary)` |
| Fundo de página | `var(--color-background-tertiary)` |

---

## Regras de visibilidade condicional (resumo completo)

| Elemento | Condição para exibir | Condição para ocultar |
|---|---|---|
| Campo "Dia de vencimento" | Modalidade = "Boleto Avulso" | Modalidade = "Junto à Taxa Cond." |
| Botão "Gerar Boleto" | Modalidade = "Boleto Avulso" | Modalidade = "Junto à Taxa Cond." |
| Checkboxes "Enviar para Registro" e "Disparar por E-Mail" | Modalidade = "Boleto Avulso" | Modalidade = "Junto à Taxa Cond." |
| Botão "Gerar Composição" | Modalidade = "Junto à Taxa Cond." | Modalidade = "Boleto Avulso" |
| Bloco Início / Fim / Qtd. Meses | Recorrente = Sim | Recorrente = Não |
| Campo de valor da linha (editável) | Checkbox da unidade = marcado | Checkbox da unidade = desmarcado |
| Botão "Excluir" no rodapé (ativo) | Pelo menos 1 unidade selecionada | Nenhuma unidade selecionada |

Importante: quando um elemento é ocultado, ele é **removido do layout** (não apenas invisível) para não deixar espaço em branco.

---

## Pontos a Definir

- [ ] Comportamento exato de "Junto à Taxa Cond.": o lançamento vai para o próximo boleto automaticamente ou o síndico escolhe o mês/vencimento?
- [ ] Valor padrão do campo "Conta Contábil" na aba Cadastrar — fixo ou configurável pelo condomínio?
- [ ] O campo "Qtd. de Meses" é calculado automaticamente a partir de Início/Fim ou pode ser editado manualmente?
- [ ] O campo "Link" (presente no layout original) deve ser mantido? Se sim, onde fica no novo layout e qual é sua finalidade.
- [ ] O campo "Anexar foto" deve ser mantido? Se sim, onde fica no novo layout.
- [ ] Campos editáveis e fluxo completo da ação "Editar" na aba Pesquisar.
- [ ] Layout da tela/modal de "Ver detalhes" de uma cobrança.
- [ ] Fluxo de "Reenviar boleto por e-mail" — onde fica o botão, confirmação, e feedback.

---

## Navegação

- Acesso via: `Home > Gestão > Boleto > Gerar Cobrança Avulsa / Desp. Extraord.`
- Botão de voltar (`<`): retorna para `Home/Gestão/Boleto`
- Alternância entre abas: toque direto nos tabs "Pesquisar" e "Cadastrar"
- Não há redirecionamento após gerar cobrança — o feedback é exibido na mesma tela