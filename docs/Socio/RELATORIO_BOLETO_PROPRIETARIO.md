# 📄 Relatório de Implementação — Boleto do Proprietário (Visão do Morador)

> **Documento para revisão de sócio** · Versão 1.0 · Março 2026  
> **Objetivo:** Explicar como funciona a tela de boletos na perspectiva do proprietário/inquilino — o que ele vê, o que ele pode fazer, como funcionam as ações (copiar código, compartilhar, ver PDF) e como os dados são buscados do sistema.

---

## 1. Visão Geral do Módulo

O módulo de **Boleto do Proprietário** é a tela que o **morador** (proprietário ou inquilino) usa para ver e gerenciar seus próprios boletos. Diferente do módulo do síndico (que gera boletos para todos), aqui o morador vê **apenas os seus boletos**.

### O que o morador consegue fazer:

| Funcionalidade | Status | Descrição |
|---|---|---|
| Ver lista de boletos em aberto | ✅ Funcional | Filtro "Vencido/A Vencer" |
| Ver lista de boletos pagos | ✅ Funcional | Filtro "Pago" |
| Copiar código de barras | ✅ Funcional | Copia para a área de transferência |
| Ver PDF do boleto | ✅ Funcional | Abre no navegador/leitor de PDF |
| Compartilhar boleto | ✅ Funcional | Share nativo (WhatsApp, etc.) com PDF |
| Ver composição do boleto | ✅ Funcional | Detalhamento: taxa, fundo, água, etc. |
| Ver demonstrativo financeiro | ✅ Funcional | Resumo mensal de valores, pagos e em aberto |
| Ver leituras de consumo | ✅ Funcional | Leituras de água/gás vinculadas ao boleto |
| Atualizar tela (pull-to-refresh) | ✅ Funcional | Puxa para baixo para recarregar |
| Sincronizar boleto com Asaas | ✅ Funcional | Se o código não existe, busca no Asaas |
| Skeleton loading | ✅ Funcional | Animação de carregamento bonita |
| Estado vazio | ✅ Funcional | Mensagem amigável quando sem boletos |

---

## 2. O que o Morador Vê na Tela

### 2.1 Estrutura da Tela

```
╭──────────────────────────────────────╮
│  🔙  Logo CondoGaia    🔔  🎧       │  ← Cabeçalho
│  Home/Gestão/Boleto      🔄         │  ← Breadcrumb + Atualizar
├──────────────────────────────────────┤
│                                      │
│  [ Vencido/A Vencer ▼ ]             │  ← Filtro (Dropdown)
│                                      │
│  ╭────────────────────────────────╮  │
│  │  📄 Boleto Mensal — 03/2026   │  │  ← Card do Boleto
│  │  Venc: 10/03/2026             │  │
│  │  Valor: R$ 550,00             │  │
│  │  Status: A Vencer 🔵          │  │
│  │  [Copiar] [Ver] [Compartilhar]│  │  ← Botões de ação
│  ╰────────────────────────────────╯  │
│                                      │
│  ╭────────────────────────────────╮  │
│  │  📄 Boleto Mensal — 02/2026   │  │  ← Outro boleto
│  │  Venc: 10/02/2026             │  │
│  │  Valor: R$ 550,00             │  │
│  │  Status: Vencido 🔴           │  │
│  ╰────────────────────────────────╯  │
│                                      │
│  ═══════════════════════════════════ │
│  DEMONSTRATIVO FINANCEIRO            │  ← Seletor de mês/ano
│  ← 03/2026 →                        │
│  ═══════════════════════════════════ │
│                                      │
│  ▶ Composição do Boleto             │  ← Seção expansível
│  ▶ Leituras de Consumo              │  ← Seção expansível
│  ▶ Balancete Online                 │  ← Seção expansível
│                                      │
╰──────────────────────────────────────╯
```

---

## 3. Filtro de Boletos

O morador pode alternar entre dois filtros:

| Filtro | O que mostra | Quando usar |
|---|---|---|
| **Vencido/A Vencer** | Boletos que ainda não foram pagos (em aberto, atrasados, a vencer) | Ver o que precisa pagar |
| **Pago** | Boletos que já foram pagos | Consultar histórico de pagamento |

> **Caso Real:** O morador João quer ver quanto tem para pagar este mês. Ele seleciona "Vencido/A Vencer" e vê 2 boletos: um de R$ 550 (taxa mensal de março) e um de R$ 85 (consumo de água avulso).

> **Caso Real 2:** A moradora Ana quer conferir se o pagamento de fevereiro foi registrado. Ela seleciona "Pago" e vê o boleto de fevereiro com status verde "Pago".

---

## 4. Card do Boleto — Informações Exibidas

Cada boleto aparece como um **card** com as seguintes informações:

| Informação | Exemplo |
|---|---|
| **Tipo** | Mensal / Avulso / Acordo |
| **Referência** | 03/2026 |
| **BL/Unidade** | A-101 |
| **Data de Vencimento** | 10/03/2026 |
| **Valor** | R$ 550,00 |
| **Status** | A Vencer 🔵 / Vencido 🔴 / Pago 🟢 |

---

## 5. Ações do Boleto — O que o Morador Pode Fazer

### 5.1 📋 Copiar Código de Barras

**O que faz:** Copia a linha digitável do boleto para a área de transferência do celular. O morador cola no app do banco para pagar.

**Fluxo inteligente:**

```
╭────────────────────────────────────────╮
│  Morador clica em "Copiar Código"      │
╰────────────────┬───────────────────────╯
                 │
                 ▼
╭────────────────────────────────────────╮
│  O código existe no banco de dados?    │
├────────┬───────────────────────────────┤
│  SIM   │        NÃO                    │
╰────┬───╯        │                      │
     │             ▼                      │
     │   ╭─────────────────────────────╮ │
     │   │ O boleto tem ID do Asaas?   │ │
     │   ├───────┬─────────────────────┤ │
     │   │  SIM  │       NÃO           │ │
     │   ╰───┬───╯       │             │ │
     │       │            ▼             │ │
     │       │   ╭──────────────────╮   │ │
     │       │   │ Registra boleto  │   │ │
     │       │   │ no Asaas via     │   │ │
     │       │   │ Backend Laravel  │   │ │
     │       │   ╰────────┬─────────╯   │ │
     │       │            │             │ │
     │       ▼            ▼             │ │
     │   ╭─────────────────────────────╮ │
     │   │ Busca linha digitável       │ │
     │   │ via API do Asaas            │ │
     │   ╰────────────┬────────────────╯ │
     │                │                   │
     ▼                ▼                   │
╭────────────────────────────────────────╮
│  ✅ Código copiado! Mensagem de        │
│  sucesso aparece na tela               │
╰────────────────────────────────────────╯
```

**Caso Real:**

> **Morador João quer pagar o boleto pelo app do Nubank:**
> 1. Abre o CondoGaia → Boletos
> 2. Encontra o boleto de R$ 550 (março/2026)
> 3. Clica em **"Copiar Código"**
> 4. 📋 Mensagem: _"Código copiado com sucesso!"_
> 5. Abre o Nubank → Pagar → Cola o código
> 6. Paga o boleto

> **Se o código não estava salvo no sistema:**
> 1. Clica em "Copiar Código"
> 2. Aparece loading (buscando no Asaas...)
> 3. O sistema registra o boleto no Asaas
> 4. Busca a linha digitável
> 5. 📋 Mensagem: _"Código sincronizado e copiado!"_

### 5.2 👁️ Ver Boleto (PDF)

**O que faz:** Abre o PDF do boleto no navegador ou app de PDF do celular. O morador pode imprimir ou salvar.

**Fluxo:**
1. Morador clica em "Ver Boleto"
2. O sistema verifica se existe URL do PDF (`bankSlipUrl`)
3. Se existe → abre o link no navegador externo
4. Se não existe → mostra erro: _"PDF do boleto não disponível"_

> **Caso Real:** A moradora Ana precisa levar o boleto impresso no banco para pagamento. Ela clica em "Ver Boleto", o PDF abre no Chrome, ela imprime na impressora de casa.

### 5.3 📤 Compartilhar Boleto

**O que faz:** Usa o compartilhamento nativo do celular (WhatsApp, Telegram, E-mail, etc.) para enviar o boleto.

**O que é compartilhado:**

```
📄 Boleto CondoGaia
━━━━━━━━━━━━━━━━━━━━
🏢 Unidade: A-101
📅 Vencimento: 10/03/2026
💰 Valor: R$ 550,00
━━━━━━━━━━━━━━━━━━━━
23793.38128 60000.000003 00000.000403 1 85270000055000
━━━━━━━━━━━━━━━━━━━━
CondoGaia - Gestão Condominial
```

**Se o PDF estiver disponível:**
- O sistema **baixa o PDF**, salva temporariamente e compartilha o **arquivo PDF** junto com o texto

**Se o PDF não estiver disponível:**
- Compartilha apenas o **texto** com o código de barras

> **Caso Real:** O proprietário José precisa que sua esposa pague o boleto. Ele clica em "Compartilhar" e envia pelo WhatsApp. A esposa recebe o PDF do boleto e o código de barras.

---

## 6. Composição do Boleto — Detalhamento

Quando o morador expande um boleto, ele pode ver do que é composto o valor:

| Componente | O que é | Exemplo |
|---|---|---|
| **Cota Condominial** | Taxa básica do condomínio | R$ 450,00 |
| **Fundo de Reserva** | Percentual guardado para emergências | R$ 45,00 |
| **Rateio Água** | Consumo de água da unidade | R$ 85,00 |
| **Multa Infração** | Se o morador recebeu multa | R$ 0,00 |
| **Controle** | Taxa administrativa | R$ 0,00 |
| **Desconto** | Desconto aplicado (se houver) | -R$ 30,00 |
| **Valor Total** | Soma de tudo | **R$ 550,00** |

> **Caso Real:** O morador vê que seu boleto custa R$ 550 e quer saber o porquê. Ele expande e vê:
> - Cota: R$ 450 (o básico)
> - Fundo: R$ 45 (10% sobre a cota)
> - Água: R$ 85 (consumo de 15m³ no mês)
> - Desconto: -R$ 30 (desconto garantidora)
> - **Total: R$ 550,00**

---

## 7. Demonstrativo Financeiro

O demonstrativo mostra um **resumo mensal** da situação financeira do morador:

| Informação | Exemplo |
|---|---|
| **Período** | Março/2026 |
| **Total de boletos no mês** | 2 |
| **Valor total** | R$ 635,00 |
| **Total pago** | R$ 85,00 (boleto avulso de água) |
| **Total em aberto** | R$ 550,00 (boleto mensal) |
| **Boletos pagos** | 1 |
| **Boletos em aberto** | 1 |

O morador pode navegar entre meses usando as setas **← →** para ver meses anteriores e futuros.

---

## 8. Seções Expansíveis

Abaixo do demonstrativo, há 3 seções que o morador pode expandir:

### 8.1 Composição do Boleto
- Mostra o detalhamento do boleto selecionado (taxa, fundo, água, etc.)
- Só aparece quando um boleto está expandido

### 8.2 Leituras de Consumo
- Mostra as leituras de água/gás da unidade no mês selecionado
- O morador pode verificar se o consumo registrado está correto

### 8.3 Balancete Online
- Mostra o balancete geral do condomínio para o mês
- Transparência: o morador pode ver as receitas e despesas do condomínio

---

## 9. Estados da Tela

### 9.1 Loading (Carregamento)
Enquanto os dados carregam, o morador vê **skeletons animados** (retângulos cinza pulsantes) no lugar dos cards de boleto. Isso dá uma sensação de velocidade e profissionalismo.

### 9.2 Estado Vazio
Se não há boletos para o filtro selecionado:

| Filtro | Mensagem |
|---|---|
| Vencido/A Vencer | "Não há boletos em aberto para exibir. Tente alterar o filtro para 'Pago'." |
| Pago | "Não há boletos pagos para exibir. Tente alterar o filtro para 'Vencido/A Vencer'." |

### 9.3 Estado de Erro
Se ocorre um erro ao carregar:
- Mensagem vermelha no topo da tela
- Botão "Tentar Novamente" para recarregar

---

## 10. De Onde Vêm os Dados

Os boletos são buscados da tabela `boletos` no **Supabase**, filtrados pelo `sacado` (ID do morador):

| Campo no Banco | O que é | Usado para |
|---|---|---|
| `id` | ID único do boleto | Identificação |
| `sacado` | ID do proprietário/inquilino | Filtrar boletos do morador |
| `condominio_id` | ID do condomínio | Contexto |
| `unidade_id` | ID da unidade | Vincular à unidade |
| `data_vencimento` | Data de vencimento | Exibição no card |
| `valor` | Valor do boleto | Exibição |
| `status` | Ativo/Pago/Cancelado | Filtro e cor |
| `tipo` | Mensal/Avulso/Acordo | Tipo exibido |
| `bank_slip_url` | URL do PDF do boleto | Botão "Ver Boleto" |
| `bar_code` | Código de barras | Botão "Copiar Código" |
| `identification_field` | Linha digitável | Botão "Copiar Código" (prioridade) |
| `invoice_url` | URL da fatura no Asaas | Link alternativo |
| `asaas_payment_id` | ID do pagamento no Asaas | Sincronização |
| `cota_condominial` | Valor da taxa base | Composição |
| `fundo_reserva` | Valor do fundo | Composição |
| `rateio_agua` | Valor do consumo de água | Composição |
| `desconto` | Desconto aplicado | Composição |

---

## 11. Regras de Negócio — Resumo

### ✅ Regras implementadas:

1. **O morador só vê seus próprios boletos** — Filtrado pelo `sacado` (ID do morador logado)
2. **O filtro padrão é "Vencido/A Vencer"** — Mostra primeiro o que precisa pagar
3. **Boletos são ordenados por data de vencimento** — Mais recentes primeiro (decrescente)
4. **O código de barras prioriza `identification_field` sobre `bar_code`** — A linha digitável é mais confiável
5. **Se o código não existe localmente, o sistema sincroniza com o Asaas** — Processo transparente para o morador
6. **Se o boleto não está registrado no Asaas, o sistema registra automaticamente** — Na hora que o morador pedir o código
7. **O compartilhamento tenta enviar o PDF primeiro** — Se falhar, envia só o texto
8. **Pull-to-refresh funciona** — Puxar para baixo recarrega os dados
9. **Mensagens de sucesso e erro são mostradas e limpas automaticamente** — Não ficam "travadas" na tela
10. **A composição do boleto mostra todos os componentes** — Total transparência para o morador

### ⚠️ O que pode ser melhorado no futuro:

1. Notificação push quando um novo boleto é gerado
2. Notificação push quando o vencimento está próximo (lembrete)
3. Pagamento direto pelo app (integração com PIX/cartão via Asaas)
4. Histórico de pagamentos com comprovantes
5. Download do PDF para salvar offline
6. QR Code PIX para pagamento rápido

---

## 12. Resumo para Verificação

**Perguntas para o sócio validar:**

- [ ] As informações exibidas no card do boleto são suficientes?
- [ ] O fluxo de copiar código → pagar no banco está claro para o morador?
- [ ] A composição do boleto mostra todos os componentes necessários?
- [ ] O demonstrativo financeiro mensal é útil como está?
- [ ] O balancete online deve estar visível para todos os moradores?
- [ ] Precisamos de notificação push para lembrar vencimento?
- [ ] Precisamos de pagamento direto pelo app (PIX)?
- [ ] O compartilhamento via WhatsApp atende às necessidades?
- [ ] Falta alguma ação que o morador deveria poder fazer com o boleto?
