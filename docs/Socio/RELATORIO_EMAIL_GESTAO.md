# 📧 Relatório de Implementação — Sistema de E-mail

> **Documento para revisão de sócio** · Versão 1.0 · Março 2026  
> **Objetivo:** Explicar como funciona o módulo de envio de e-mails do CondoGaia, incluindo filtros, modelos salvos, anexos e integração com o serviço de e-mail (Resend via Laravel).

---

## 1. Visão Geral do Módulo

O módulo de **E-mail (Gestão)** permite que o síndico envie comunicações diretas para os moradores por e-mail, diretamente pelo aplicativo. Funciona como uma ferramenta de **circular digital**.

### O que o síndico consegue fazer:

| Funcionalidade | Status | Descrição |
|---|---|---|
| Enviar e-mail para proprietários | ✅ Funcional | Seleciona quem recebe |
| Enviar e-mail para inquilinos | ✅ Funcional | Filtra por tipo de morador |
| Filtrar destinatários por nome/unidade | ✅ Funcional | Busca por texto |
| Selecionar destinatários individualmente | ✅ Funcional | Checkbox por pessoa |
| Selecionar todos de uma vez | ✅ Funcional | Marcar/desmarcar todos |
| Definir assunto e corpo do e-mail | ✅ Funcional | Campos de texto livre |
| Salvar modelos de e-mail | ✅ Funcional | Templates reutilizáveis |
| Carregar modelo salvo | ✅ Funcional | Preenche assunto e corpo |
| Excluir modelo salvo | ✅ Funcional | Remove do banco de dados |
| Anexar arquivo (imagem/PDF) | ✅ Funcional | Até 5MB por anexo |
| Escolher tópico do e-mail | ✅ Funcional | Cobrança, Aviso, Comunicado, etc. |
| Envio real via Resend | ✅ Funcional | Integração com backend Laravel |

---

## 2. Fluxo de Envio de E-mail — Passo a Passo

### 2.1 Fluxo Completo

```
╭──────────────────────────────────────╮
│  1. Síndico abre "E-mail Gestão"    │
╰──────────────┬───────────────────────╯
               │
               ▼
╭──────────────────────────────────────╮
│  2. Sistema carrega todos os        │
│     moradores (proprietários e      │
│     inquilinos) do condomínio       │
╰──────────────┬───────────────────────╯
               │
               ▼
╭──────────────────────────────────────╮
│  3. Síndico escolhe o TÓPICO:       │
│     Cobrança / Aviso / Comunicado   │
╰──────────────┬───────────────────────╯
               │
               ▼
╭──────────────────────────────────────╮
│  4. Filtra os destinatários:        │
│     - Todos / Proprietários /       │
│       Inquilinos                    │
│     - Busca por nome ou unidade     │
╰──────────────┬───────────────────────╯
               │
               ▼
╭──────────────────────────────────────╮
│  5. Marca os destinatários          │
│     (um por um ou "Selecionar       │
│     Todos")                         │
╰──────────────┬───────────────────────╯
               │
               ▼
╭──────────────────────────────────────╮
│  6. (Opcional) Carrega um modelo    │
│     de e-mail salvo anteriormente   │
╰──────────────┬───────────────────────╯
               │
               ▼
╭──────────────────────────────────────╮
│  7. Escreve ou ajusta:              │
│     - Assunto do e-mail             │
│     - Corpo do e-mail               │
│     - (Opcional) Anexa um arquivo   │
╰──────────────┬───────────────────────╯
               │
               ▼
╭──────────────────────────────────────╮
│  8. Clica em "Enviar"               │
│     → O app envia para o Backend    │
│     → Backend envia via Resend      │
│     → Cada morador recebe o e-mail  │
╰──────────────────────────────────────╯
```

---

## 3. Filtros de Destinatários

### 3.1 Filtro por Tipo de Morador

O síndico pode escolher para quem enviar:

| Filtro | Quem aparece na lista |
|---|---|
| **Todos** | Proprietários + Inquilinos |
| **Proprietários** | Apenas donos das unidades |
| **Inquilinos** | Apenas locatários |

### 3.2 Filtro por Texto (Busca)

O síndico pode digitar na barra de busca para procurar por:
- **Nome do morador** (ex: digitar "Maria" mostra todas as Marias)
- **Bloco/Unidade** (ex: digitar "A-101" mostra quem mora na A-101)

### 3.3 Caso Real — Filtrando para enviar cobrança

> **Cenário:** O síndico quer enviar um aviso de cobrança APENAS para proprietários do Bloco A.
>
> **Passo a passo:**
> 1. Seleciona o filtro **"Proprietários"**
> 2. Digita **"A"** na barra de busca
> 3. O sistema filtra e mostra apenas os proprietários do Bloco A
> 4. Clica em **"Selecionar Todos"** → marca todos os resultados filtrados
> 5. Escreve o assunto: _"Aviso de Vencimento — Bloco A"_
> 6. Escreve o corpo do e-mail com as informações
> 7. Clica em **"Enviar"**
>
> **Resultado:** Somente os proprietários do Bloco A recebem o e-mail.

---

## 4. Sistema de Modelos (Templates)

### 4.1 O que são modelos?

Modelos são **e-mails prontos** que o síndico pode salvar para reutilizar. Isso economiza tempo quando a mesma mensagem precisa ser enviada todo mês (ex: lembrete de pagamento).

### 4.2 Como salvar um modelo

1. O síndico escreve o e-mail normalmente (assunto + corpo)
2. Clica em **"Salvar como Modelo"**
3. Dá um **título** ao modelo (ex: "Lembrete Mensal de Pagamento")
4. O modelo fica salvo e vinculado ao **tópico** selecionado

### 4.3 Como usar um modelo salvo

1. O síndico seleciona o **tópico** (ex: "Cobrança")
2. O sistema carrega os modelos salvos daquele tópico
3. O síndico clica no modelo desejado
4. O **assunto** e o **corpo** são preenchidos automaticamente
5. O síndico pode editar antes de enviar se quiser

### 4.4 Caso Real — Modelo para cobrança mensal

> **Salvando o modelo:**
> - Tópico: Cobrança
> - Título: "Cobrança Mensal — Lembrete"
> - Assunto: "Lembrete de Pagamento — Condomínio Residencial Pinheiros"
> - Corpo: "Prezado(a) morador(a), lembramos que o boleto condominial vence no dia 10. Caso já tenha efetuado o pagamento, desconsidere este aviso."
>
> **Usando o modelo no mês seguinte:**
> 1. Abre E-mail Gestão
> 2. Seleciona tópico "Cobrança"
> 3. Clica no modelo "Cobrança Mensal — Lembrete"
> 4. Assunto e corpo são preenchidos automaticamente
> 5. Seleciona todos os moradores
> 6. Envia

### 4.5 Organização de Modelos por Tópico

Os modelos ficam **organizados por tópico**, então:

- Modelos de "Cobrança" só aparecem quando o tópico "Cobrança" está selecionado
- Modelos de "Aviso" só aparecem quando "Aviso" está selecionado
- Isso evita bagunça e facilita encontrar o modelo certo

---

## 5. Tópicos Disponíveis

O síndico pode escolher o tópico do e-mail para contextualizá-lo:

| Tópico | Quando usar | Exemplo de e-mail |
|---|---|---|
| **Cobrança** | Lembretes de pagamento, avisos de inadimplência | "Seu boleto vence dia 10" |
| **Aviso** | Comunicados gerais, manutenções | "Manutenção no elevador dia 20" |
| **Comunicado** | Comunicações formais, assembleias | "Convocação para assembleia" |
| **Geral** | Qualquer outro assunto | "Feliz Natal a todos os moradores!" |

---

## 6. Anexos

### 6.1 Regras de Anexo

| Regra | Detalhe |
|---|---|
| **Tamanho máximo** | 5 MB por arquivo |
| **Tipos aceitos** | Imagens (JPG, PNG) e documentos (PDF) |
| **Quantidade** | 1 anexo por e-mail |
| **Validação** | O sistema verifica o tamanho ANTES de enviar |

### 6.2 Caso Real — Enviando ata de assembleia

> **Cenário:** O síndico quer enviar a ata da última assembleia para todos os moradores.
>
> 1. Tópico: "Comunicado"
> 2. Seleciona "Todos" como destinatários
> 3. Assunto: "Ata da Assembleia — 15/03/2026"
> 4. Corpo: "Segue em anexo a ata da assembleia realizada em 15/03/2026."
> 5. Anexa o arquivo **ata_assembleia_marco.pdf** (2.3 MB ✅)
> 6. Envia
>
> **Resultado:** Todos os moradores recebem o e-mail com o PDF da ata anexado.

> **Erro esperado:** Se o síndico tentar anexar um arquivo de 7 MB, o sistema exibe: _"Arquivo muito grande: 7.0MB. Máximo permitido: 5MB."_ e **não anexa o arquivo**.

---

## 7. Integração Técnica — Como o E-mail é Enviado

```
╭─────────────╮     ╭─────────────╮     ╭─────────────╮     ╭──────────────╮
│ App Flutter  │ ──→ │   Backend   │ ──→ │   Resend    │ ──→ │  Caixa do    │
│ (Formulário) │     │  (Laravel)  │     │   (API)     │     │  Morador     │
╰─────────────╯     ╰─────────────╯     ╰─────────────╯     ╰──────────────╯
```

**Fluxo técnico simplificado:**

1. **App Flutter** coleta: destinatários, assunto, corpo, tópico, anexo
2. Envia tudo para o **Backend Laravel** (rota `/resend/gestao/circular`)
3. O **Backend** formata o e-mail usando templates HTML bonitos
4. O **Resend** (serviço de e-mail profissional) envia para cada destinatário
5. O morador recebe na caixa de entrada com o nome do condomínio como remetente

### 7.1 Tipos de Envio no Backend

O backend tem 3 rotas de envio diferentes:

| Rota | Uso | Quando é chamada |
|---|---|---|
| `/resend/gestao/circular` | Circular geral | Envio padrão pelo módulo de e-mail |
| `/resend/gestao/aviso` | Aviso formal | Para comunicações mais formais |
| `/resend/gestao/em-massa` | Envio em massa | Para grandes volumes |

---

## 8. Dados dos Destinatários

O sistema busca os seguintes dados de cada morador para envio:

| Dado | De onde vem | Exemplo |
|---|---|---|
| **Nome** | Tabela `proprietarios` ou `inquilinos` | "Maria da Silva" |
| **E-mail** | Tabela `proprietarios` ou `inquilinos` | "maria@email.com" |
| **Tipo** | "P" (Proprietário) ou "I" (Inquilino) | "P" |
| **Unidade** | Tabela `unidades` (vinculada) | "101 / Bloco A" |

> ⚠️ **Importante:** Se um morador **não tem e-mail cadastrado**, ele aparece na lista mas com e-mail vazio. O sistema aceita a seleção, mas o backend vai ignorar destinatários sem e-mail válido.

---

## 9. Modelos no Banco de Dados

Os modelos de e-mail são salvos na tabela `email_modelos` do Supabase:

| Campo | Exemplo |
|---|---|
| `condominio_id` | ID do condomínio |
| `topico` | "Cobrança" |
| `titulo` | "Lembrete Mensal" |
| `assunto` | "Lembrete de Pagamento" |
| `corpo` | "Prezado morador, seu boleto vence dia 10..." |
| `criado_em` | 2026-03-15 10:30:00 |

---

## 10. Regras de Negócio — Resumo

### ✅ Regras implementadas:

1. **É obrigatório selecionar pelo menos um destinatário** — O botão "Enviar" não funciona sem destinatários selecionados
2. **É obrigatório preencher assunto e corpo** — Validação antes do envio
3. **Anexos são limitados a 5MB** — Validação no lado do app, antes de enviar
4. **Modelos são vinculados ao condomínio e ao tópico** — Cada condomínio tem seus próprios modelos
5. **A lista de destinatários é paginada** — Carrega 10 por vez para performance
6. **"Selecionar Todos" marca apenas os visíveis** — Se há filtro ativo, marca só quem está na lista filtrada
7. **Os modelos são carregados automaticamente ao trocar de tópico** — Ao mudar de "Cobrança" para "Aviso", os modelos daquele tópico são carregados
8. **O envio é feito via backend (não diretamente do app)** — Maior segurança e controle

### ⚠️ O que pode ser melhorado no futuro:

1. Permitir mais de 1 anexo por e-mail
2. Agendamento de envio (enviar em data/hora específica)
3. Relatório de entrega (quais e-mails foram entregues/abertos)
4. Editor de e-mail rico (com formatação: negrito, itálico, cores)
5. Histórico de e-mails enviados (log)

---

## 11. Resumo para Verificação

**Perguntas para o sócio validar:**

- [ ] Os tópicos disponíveis (Cobrança, Aviso, Comunicado, Geral) são suficientes?
- [ ] O limite de 5MB para anexos é adequado?
- [ ] Precisamos de editor de e-mail com formatação rica (negrito, etc.)?
- [ ] Precisamos de agendamento de envio?
- [ ] O nome do remetente no e-mail está correto?
- [ ] Falta algum filtro de destinatário? (ex: filtrar por bloco específico)
- [ ] Precisamos de confirmação de leitura (se o morador abriu o e-mail)?
