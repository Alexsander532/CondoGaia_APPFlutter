# Como Funciona o Boleto no CondoGaia

**Para:** Síndicos, Proprietários e Inquilinos  
**Data:** 23/03/2026  
**Versão:** 2.0

---

## 1. Conceito Fundamental: Geração Mensal Obrigatória

### O Síndico PRECISA gerar os boletos todo mês.

Diferente de sistemas que geram automaticamente, no CondoGaia o processo é **manual e intencional**. O síndico é o responsável por gerar os boletos de cobrança a cada mês.

### Por que é assim?

- **Controle total:** O síndico tem a responsabilidade de conferir e autorizar cada geração de boletos
- **Transparência:** Toda geração de boleto é uma ação consciente e deliberada
- **Flexibilidade:** Permite ajustar rateios extras mês a mês antes de gerar

### Exemplo prático:

```
📅 CALENDÁRIO DE GERAÇÃO DE BOLETOS

┌──────────────────────────────────────────────────────────────────────┐
│ Mês         │ Ação do Síndico                                       │
├──────────────────────────────────────────────────────────────────────┤
│ Maio/2026   │ No dia 1 (ou início) de Maio, o síndico entra no     │
│             │ sistema e GERA todos os boletos de Maio               │
├──────────────────────────────────────────────────────────────────────┤
│ Junho/2026  │ No dia 1 (ou início) de Junho, o síndico entra no    │
│             │ sistema e GERA todos os boletos de Junho              │
├──────────────────────────────────────────────────────────────────────┤
│ Julho/2026  │ No dia 1 (ou início) de Julho, o síndico entra no    │
│             │ sistema e GERA todos os boletos de Julho              │
├──────────────────────────────────────────────────────────────────────┤
│ ...         │ E assim por diante, TODO mês.                         │
└──────────────────────────────────────────────────────────────────────┘
```

> **⚠️ IMPORTANTE:** Não existe modo automático. O síndico deve entrar no sistema todo mês e gerar os boletos manualmente. Se ele esquecer, os moradores não receberão os boletos daquele mês.

---

## 2. Composição do Valor do Boleto

O valor do boleto é composto por **dois componentes distintos e independentes**:

### 2.1. Cota Condominial (FIXA)

A cota condominial é um **valor fixo**, definido previamente, que **não muda** de mês para mês (a menos que o condomínio decida alterá-la formalmente).

```
┌──────────────────────────────────────────────────────────────────────┐
│                    COTA CONDOMINIAL (FIXA)                           │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   • É um VALOR FIXO pré-definido                                     │
│   • NÃO depende das despesas do mês                                  │
│   • NÃO é calculada dividindo despesas por unidades                  │
│   • Permanece o MESMO valor todos os meses                           │
│   • Só muda com decisão formal do condomínio                         │
│                                                                      │
│   Exemplo:                                                           │
│   ┌──────────────────────────────────────────────────────────┐      │
│   │ Cota Condominial definida: R$ 450,00                     │      │
│   │                                                          │      │
│   │ Maio/2026  → R$ 450,00                                   │      │
│   │ Junho/2026 → R$ 450,00                                   │      │
│   │ Julho/2026 → R$ 450,00                                   │      │
│   │ ...        → R$ 450,00 (mesma coisa todo mês)            │      │
│   └──────────────────────────────────────────────────────────┘      │
│                                                                      │
│   ℹ️ A forma como a cota fixa será definida no sistema será          │
│      detalhada em documentação futura.                               │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### 2.2. Rateio (OPCIONAL e SEPARADO)

O rateio é um **valor adicional**, separado da cota condominial, que pode ser adicionado quando necessário. Ele NÃO faz parte da cota fixa.

```
┌──────────────────────────────────────────────────────────────────────┐
│                    RATEIO (OPCIONAL / SEPARADO)                       │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   • É um valor EXTRA, SEPARADO da cota condominial                   │
│   • Pode ou não existir em um mês                                    │
│   • Serve para cobrir gastos extraordinários ou específicos          │
│   • É adicionado AO LADO da cota, nunca DENTRO dela                 │
│   • Cada mês pode ter um rateio diferente (ou nenhum)                │
│                                                                      │
│   Exemplos de quando usar rateio:                                    │
│   ├─ Pintura da fachada                                              │
│   ├─ Conserto do elevador                                            │
│   ├─ Conta de água excedente                                         │
│   ├─ Manutenção emergencial                                         │
│   └─ Qualquer despesa extra não coberta pela cota fixa              │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### 2.3. Resumo da Composição

```
┌──────────────────────────────────────────────────────────────────────┐
│              COMO O VALOR DO BOLETO É FORMADO                        │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   VALOR DO BOLETO = COTA FIXA + RATEIO (se houver)                  │
│                                                                      │
│   ─────────────────────────────────────────────────────────────      │
│                                                                      │
│   Cenário 1: Mês SEM rateio                                         │
│   ┌──────────────────────────────────────────────────────┐          │
│   │  Cota Condominial:    R$ 450,00                      │          │
│   │  Rateio:              R$   0,00  (não há)            │          │
│   │  ──────────────────────────────────────               │          │
│   │  TOTAL DO BOLETO:     R$ 450,00                      │          │
│   └──────────────────────────────────────────────────────┘          │
│                                                                      │
│   Cenário 2: Mês COM rateio                                          │
│   ┌──────────────────────────────────────────────────────┐          │
│   │  Cota Condominial:    R$ 450,00                      │          │
│   │  Rateio (pintura):    R$ 200,00                      │          │
│   │  ──────────────────────────────────────               │          │
│   │  TOTAL DO BOLETO:     R$ 650,00                      │          │
│   └──────────────────────────────────────────────────────┘          │
│                                                                      │
│   ⚠️ A cota SEMPRE é R$ 450,00.                                     │
│      O rateio é que faz o valor do boleto variar.                    │
│      São ITENS SEPARADOS na composição do boleto.                    │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 3. Fluxo Mensal do Síndico

### O que o Síndico faz todo mês:

```
┌──────────────────────────────────────────────────────────────────────┐
│                    FLUXO MENSAL DO SÍNDICO                           │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   INÍCIO DO MÊS (geralmente dia 1 a 5)                              │
│   │                                                                  │
│   ▼                                                                  │
│   ┌──────────────────────┐                                          │
│   │ 1. VERIFICAR se há   │  → Há algum rateio extra este mês?      │
│   │    RATEIO no mês     │  → Pintura? Manutenção? Conta extra?    │
│   └──────────┬───────────┘                                          │
│              │                                                       │
│              ▼                                                       │
│   ┌──────────────────────┐                                          │
│   │ 2. GERAR COBRANÇA    │  → Entra em "Gestão de Boletos"         │
│   │    MENSAL            │  → A Cota Fixa já vem preenchida        │
│   │                      │  → Adiciona rateio, se houver           │
│   │                      │  → Define data de vencimento            │
│   └──────────┬───────────┘  → Clica em GERAR                       │
│              │                                                       │
│              ▼                                                       │
│   ┌──────────────────────┐                                          │
│   │ 3. PRONTO!           │  → Boletos criados para todas unidades  │
│   │                      │  → Enviados por email aos moradores     │
│   │                      │  → Registrados no ASAAS (banco)         │
│   └──────────────────────┘                                          │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Tela que o Síndico vê ao gerar:

```
┌─────────────────────────────────────────────────────────────┐
│           GERAR COBRANÇA MENSAL                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Mês de Referência: Maio/2026                                │
│ Data de Vencimento: [  10  ] / [ 05 ] / [ 2026 ]           │
│                                                             │
│ ─────────────────────────────────────────────────────────  │
│ COMPOSIÇÃO DO VALOR:                                        │
│ ─────────────────────────────────────────────────────────  │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ COTA CONDOMINIAL (fixa):   R$ 450,00    🔒 (pré-definida)││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ RATEIO EXTRA (opcional):                                ││
│ │                                                         ││
│ │ ☐ Adicionar rateio este mês                             ││
│ │                                                         ││
│ │   Descrição: [ Pintura da fachada          ]            ││
│ │   Valor:     R$ [  200,00  ]                            ││
│ │                                                         ││
│ │   [+ Adicionar outro rateio]                            ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ ─────────────────────────────────────────────────────────  │
│ VALOR TOTAL POR UNIDADE:   R$   650,00                     │
│   ├─ Cota Condominial:    R$   450,00                      │
│   └─ Rateio (pintura):    R$   200,00                      │
│ ─────────────────────────────────────────────────────────  │
│                                                             │
│ ☑ Enviar para Registro (gera código de barras)             │
│ ☑ Enviar por E-mail para os moradores                      │
│                                                             │
│ Unidades: [Todas] ou [Selecionar específicas]              │
│                                                             │
│           [CANCELAR]    [GERAR COBRANÇA]                   │
└─────────────────────────────────────────────────────────────┘
```

### O que acontece ao clicar em GERAR:

1. **Sistema cria 1 boleto para cada unidade**
2. **Envia para o ASAAS** (gateway bancário)
3. **Recebe código de barras e linha digitável**
4. **Salva tudo no banco de dados**
5. **Envia por email** (se marcado)

---

## 4. Diferença entre Cota Fixa e Rateio

É fundamental entender que **cota condominial** e **rateio** são conceitos completamente separados:

| Aspecto | Cota Condominial | Rateio |
|---------|------------------|--------|
| **Tipo** | Valor FIXO | Valor VARIÁVEL |
| **Frequência** | Todo mês, sempre | Somente quando necessário |
| **Valor** | Sempre o mesmo | Muda conforme a necessidade |
| **Definição** | Definida previamente pelo condomínio | Definida pelo síndico mês a mês |
| **Obrigatoriedade** | SEMPRE presente no boleto | OPCIONAL |
| **Alteração** | Só com decisão formal do condomínio | Síndico decide a cada mês |
| **Exemplos** | R$ 450,00 fixos | R$ 200,00 (pintura), R$ 80,00 (conserto) |

### Visualização da separação:

```
┌──────────────────────────────────────────────────────────────────────┐
│         BOLETO DA UNIDADE A/101 - MAIO/2026                          │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──── BLOCO 1: COTA CONDOMINIAL ────────────────────────────────┐  │
│  │                                                                │  │
│  │  Cota Condominial (fixa):           R$ 450,00                 │  │
│  │                                                                │  │
│  │  ℹ️ Este valor é fixo e definido pelo condomínio.              │  │
│  │     Não muda de mês para mês.                                 │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌──── BLOCO 2: RATEIO(S) EXTRA(S) ─────────────────────────────┐  │
│  │                                                                │  │
│  │  Rateio - Pintura da fachada:       R$ 200,00                 │  │
│  │                                                                │  │
│  │  ℹ️ Este valor é extra e pode variar de mês para mês.          │  │
│  │     Pode não existir em alguns meses.                         │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ═══════════════════════════════════════════════════════════════════  │
│  TOTAL:                                R$ 650,00                    │
│  ═══════════════════════════════════════════════════════════════════  │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 5. O que o Proprietário/Inquilino Vê

### Tela do Morador:

```
┌─────────────────────────────────────────────────────────────┐
│ 📄 MEUS BOLETOS                                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ [A Vencer] [Pagos] [Todos]  ← Filtros                       │
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ 📄 BOLETO - Maio/2026                                  ││
│ │                                                         ││
│ │ Unidade: A/101                                          ││
│ │ Vencimento: 10/05/2026                                  ││
│ │ Status: ⚪ A Vencer                                     ││
│ │                                                         ││
│ │ VALOR: R$ 650,00                                        ││
│ │                                                         ││
│ │ ▼ Ver Composição                                        ││
│ │   ├─ Cota Condominial (fixa).... R$ 450,00             ││
│ │   └─ Rateio (pintura fachada)... R$ 200,00             ││
│ │                                                         ││
│ │ [📋 COPIAR CÓDIGO] [📄 VER PDF] [📤 COMPARTILHAR]      ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ 📄 BOLETO - Abril/2026                                 ││
│ │ Status: ✅ PAGO em 08/04/2026                           ││
│ │ VALOR: R$ 450,00 (apenas cota, sem rateio)              ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Ações que o Morador Pode Fazer:

| Ação | O que faz |
|------|-----------|
| **Copiar Código** | Copia a linha digitável para pagar no app do banco |
| **Ver PDF** | Abre o boleto em PDF para imprimir |
| **Compartilhar** | Envia o PDF por WhatsApp, email, etc |
| **Ver Composição** | Mostra a separação entre cota fixa e rateio(s) |

---

## 6. Resumo: Quem Faz O Quê?

```
┌──────────────────────────────────────────────────────────────────────┐
│                    DIVISÃO DE RESPONSABILIDADES                       │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌──── SÍNDICO ─────────────────────────────────────────────────┐  │
│   │                                                               │  │
│   │ • Gera os boletos TODO MÊS (obrigatório, manual)             │  │
│   │ • Verifica se há rateio extra no mês                         │  │
│   │ • Adiciona rateio(s) quando necessário                       │  │
│   │ • Define a data de vencimento                                │  │
│   │ • Dá baixa quando alguém paga em dinheiro                    │  │
│   │ • Faz acordos de pagamento                                   │  │
│   │ • Gera boletos avulsos (cobranças extras individuais)        │  │
│   │                                                               │  │
│   │ ⚠️ A cota condominial é fixa e já vem preenchida.            │  │
│   │    O síndico NÃO precisa calcular o valor da cota.           │  │
│   └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
│   ┌──── PROPRIETÁRIO / INQUILINO ────────────────────────────────┐  │
│   │                                                               │  │
│   │ • Visualiza seus boletos                                     │  │
│   │ • Copia o código de barras                                   │  │
│   │ • Baixa o PDF do boleto                                      │  │
│   │ • Compartilha o boleto                                       │  │
│   │ • Vê a composição do valor (cota + rateio separados)         │  │
│   │ • Vê o demonstrativo financeiro                              │  │
│   └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
│   ┌──── SISTEMA ─────────────────────────────────────────────────┐  │
│   │                                                               │  │
│   │ • Registra os boletos no ASAAS (gateway bancário)            │  │
│   │ • Gera código de barras e linha digitável                    │  │
│   │ • Envia os boletos por email                                 │  │
│   │ • Atualiza status quando pago (webhook automático)           │  │
│   │ • Calcula juros e multas por atraso                          │  │
│   │ • Mantém a cota fixa pré-cadastrada                          │  │
│   └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 7. Fluxo Visual Simplificado

```
                    INÍCIO DO MÊS
                         │
                         ▼
    ┌─────────────────────────────────────┐
    │  Síndico ENTRA no sistema           │
    │  (todo mês, obrigatório)            │
    └──────────────┬──────────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────────┐
    │  Verifica se há RATEIO extra        │
    │  (pintura, conserto, etc.)          │
    └──────────────┬──────────────────────┘
                   │
          ┌────────┴────────┐
          ▼                 ▼
    ┌──────────┐      ┌──────────┐
    │ SEM      │      │ COM      │
    │ rateio   │      │ rateio   │
    └─────┬────┘      └─────┬────┘
          │                 │
          │   ┌─────────────┘
          ▼   ▼
    ┌─────────────────────────────────────┐
    │  Síndico GERA A COBRANÇA MENSAL     │
    │  • Cota fixa: já preenchida (ex: R$ 450) │
    │  • Rateio: adiciona se houver       │
    │  • Define vencimento                │
    └──────────────┬──────────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────────┐
    │  SISTEMA cria os boletos            │
    │  e envia por email                  │
    └──────────────┬──────────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────────┐
    │  MORADOR recebe email               │
    │  e paga pelo app do banco           │
    └──────────────┬──────────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────────┐
    │  SISTEMA atualiza status = PAGO     │
    │  (automático via ASAAS webhook)     │
    └─────────────────────────────────────┘
                         │
                         ▼
                    FIM DO MÊS
```

---

## 8. Perguntas Frequentes

### P: O síndico PRECISA gerar os boletos todo mês?
**R:** **SIM.** O sistema não gera boletos automaticamente. O síndico deve entrar no sistema no início de cada mês e gerar os boletos para aquele mês. Se esquecer, os moradores não receberão os boletos.

### P: O valor da cota muda todo mês?
**R:** **NÃO.** A cota condominial é um valor fixo. O que pode variar de mês para mês é o rateio extra, que é separado da cota.

### P: Qual a diferença entre cota e rateio?
**R:** A **cota condominial** é o valor fixo que o morador paga todo mês (ex: R$ 450,00). O **rateio** é um valor extra, opcional, que o síndico adiciona quando há despesas extraordinárias (ex: pintura, conserto). São itens separados no boleto.

### P: O síndico precisa calcular o valor da cota?
**R:** **NÃO.** A cota é um valor fixo pré-definido. O síndico não precisa somar despesas e dividir por unidades. Ele apenas adiciona rateios extras se necessário.

### P: Pode ter mais de um rateio no mesmo mês?
**R:** **SIM.** O síndico pode adicionar múltiplos rateios no mesmo boleto (ex: rateio de pintura + rateio de conserto do elevador).

### P: O síndico ESQUECEU de gerar os boletos. E agora?
**R:** Ele pode gerar a qualquer momento, mesmo atrasado. Os moradores recebem por email assim que ele gera.

### P: O morador perdeu o boleto. Pode reenviar?
**R:** Sim! O síndico pode reenviar por email, ou o morador pode acessar pelo app.

### P: O morador pagou em dinheiro na portaria. Como registrar?
**R:** O síndico entra no boleto, clica em "Receber" e registra o pagamento manual.

### P: O morador está devendo 3 meses. Dá para fazer um acordo?
**R:** Sim! O síndico seleciona os 3 boletos e clica em "Agrupar". Vira um único boleto com a soma.

### P: Como será definido o valor fixo da cota?
**R:** A definição do valor fixo da cota será detalhada em documentação futura. Por enquanto, o importante é saber que a cota tem um valor fixo pré-cadastrado no sistema.

---

## 9. Exemplo Mês a Mês

Para ilustrar como funciona ao longo do tempo:

```
┌──────────────────────────────────────────────────────────────────────┐
│                    EXEMPLO: PRIMEIRO SEMESTRE 2026                    │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│ Cota Condominial fixa: R$ 450,00                                     │
│                                                                      │
│ ┌────────────┬─────────────┬──────────────────────┬─────────────┐   │
│ │    Mês     │  Cota (fixa)│  Rateio (se houver)  │    Total    │   │
│ ├────────────┼─────────────┼──────────────────────┼─────────────┤   │
│ │ Janeiro    │  R$ 450,00  │  —                   │  R$ 450,00  │   │
│ │ Fevereiro  │  R$ 450,00  │  —                   │  R$ 450,00  │   │
│ │ Março      │  R$ 450,00  │  R$ 200 (pintura)    │  R$ 650,00  │   │
│ │ Abril      │  R$ 450,00  │  R$ 200 (pintura)    │  R$ 650,00  │   │
│ │ Maio       │  R$ 450,00  │  —                   │  R$ 450,00  │   │
│ │ Junho      │  R$ 450,00  │  R$ 80 (conserto)    │  R$ 530,00  │   │
│ └────────────┴─────────────┴──────────────────────┴─────────────┘   │
│                                                                      │
│ ⚠️ Note: a cota é SEMPRE R$ 450,00.                                 │
│    O que varia é o rateio extra.                                     │
│    Em cada mês, o síndico gerou os boletos manualmente.              │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 10. Conclusão

| Pergunta | Resposta |
|----------|----------|
| Síndico precisa gerar todo mês? | **SIM, obrigatoriamente.** Deve entrar no sistema todo mês e gerar os boletos. |
| O valor da cota muda? | **NÃO.** A cota é fixa. Rateios extras são separados e opcionais. |
| Cota e rateio são a mesma coisa? | **NÃO.** A cota é fixa. O rateio é extra, opcional e separado. |
| Morador precisa pedir o boleto? | **NÃO.** Recebe automaticamente por email quando o síndico gera, e pode ver no app. |
| Quem registra no banco? | **O sistema**, via integração com ASAAS. O síndico não precisa ir ao banco. |
| Como a cota fixa é definida? | Será detalhado em documentação futura. Atualmente é um valor pré-cadastrado. |
