# Como Funciona o Boleto no CondoGaia

**Para:** Síndicos, Proprietários e Inquilinos  
**Data:** 16/03/2026

---

## 1. A Grande Pergunta: O Síndico Precisa Gerar Boletos Todo Mês?

### Resposta: NÃO necessariamente.

O sistema oferece **duas formas** de trabalho:

| Modo | Como Funciona | Indicado Para |
|------|---------------|---------------|
| **Manual** | Síndico entra todo mês e gera os boletos | Condomínios com valores variáveis |
| **Automático** | Sistema gera sozinho no dia definido | Condomínios com valores fixos |

---

## 2. Modo Manual (Como Funciona Hoje)

### O que o Síndico faz:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    FLUXO MENSAL DO SÍNDICO                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   DIA 1-5 do Mês                                                        │
│   │                                                                     │
│   ▼                                                                     │
│   ┌─────────────────┐                                                   │
│   │ 1. Lançar as    │  → Despesas do mês (conta de luz, água, etc.)    │
│   │    DESPESAS      │  → Manutenções, salários, fornecedores          │
│   └────────┬────────┘                                                   │
│            │                                                            │
│            ▼                                                            │
│   ┌─────────────────┐                                                   │
│   │ 2. Calcular     │  → Soma todas as despesas                        │
│   │    a COTA       │  → Divide pelo número de unidades                │
│   └────────┬────────┘                                                   │
│            │                                                            │
│            ▼                                                            │
│   ┌─────────────────┐                                                   │
│   │ 3. GERAR        │  → Entra em "Gestão de Boletos"                  │
│   │    COBRANÇA     │  → Clica em "Gerar Cobrança Mensal"              │
│   │    MENSAL       │  → Preenche os valores                           │
│   └────────┬────────┘  → Clica em GERAR                                │
│            │                                                            │
│            ▼                                                            │
│   ┌─────────────────┐                                                   │
│   │ 4. PRONTO!      │  → Boletos enviados por email                    │
│   │                 │  → Registrados no banco (ASAAS)                   │
│   └─────────────────┘                                                   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Tela que o Síndico vê ao gerar:

```
┌─────────────────────────────────────────────────────────────┐
│           GERAR COBRANÇA MENSAL                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Data de Vencimento: [  10  ] / [ 04 ] / [ 2026 ]           │
│                                                             │
│ ─────────────────────────────────────────────────────────  │
│ COMPOSIÇÃO DO VALOR:                                        │
│ ─────────────────────────────────────────────────────────  │
│                                                             │
│ Cota Condominial:    R$ [  450,00  ]  ← Valor base         │
│ Fundo de Reserva:    R$ [   45,00  ]  ← 10% da cota        │
│ Multa por Infração:  R$ [    0,00  ]  ← Se houver          │
│ Taxa de Controle:    R$ [   15,00  ]  ← Taxa adm           │
│ Rateio de Água:      R$ [  120,00  ]  ← Se medido          │
│ Desconto:            R$ [    0,00  ]  ← Se houver          │
│                                                             │
│ ─────────────────────────────────────────────────────────  │
│ VALOR POR UNIDADE:   R$   630,00                           │
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

## 3. Modo Automático (FUNCIONALIDADE FUTURA)

> ⚠️ **Status:** Ainda não implementado, mas planejado.

### Como vai funcionar:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    MODO AUTOMÁTICO (FUTURO)                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   CONFIGURAÇÃO ÚNICA (feita 1x):                                        │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │ • Dia do vencimento: dia 10                                     │  │
│   │ • Valor base da cota: R$ 450,00                                 │  │
│   │ • Fundo reserva: 10%                                            │  │
│   │ • Taxa controle: R$ 15,00                                       │  │
│   │ • Enviar automaticamente: SIM                                   │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│   TODO DIA 1 do mês, às 08:00:                                          │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │ ✓ Sistema gera os boletos automaticamente                       │  │
│   │ ✓ Envia para registro no ASAAS                                  │  │
│   │ ✓ Envia por email para todos os moradores                       │  │
│   │ ✓ Notifica o síndico: "Boletos de Abril gerados!"              │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│   O SÍNDICO NÃO PRECISA FAZER NADA!                                    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Dá para Gerar Boletos do Semestre Inteiro?

### Resposta: SIM, mas com ressalvas.

O sistema **permite gerar boletos com datas futuras**, mas há considerações:

| Situação | Recomendado? | Por Quê? |
|----------|--------------|----------|
| **Valores fixos** (condomínio sem variação) | ✅ SIM | Se a cota é sempre igual, pode gerar 6 meses |
| **Valores variáveis** (condomínio com variações) | ❌ NÃO | Cada mês tem um valor diferente |

### Como gerar vários meses:

```
┌─────────────────────────────────────────────────────────────┐
│           GERAR COBRANÇA MENSAL - MÚLTIPLOS MESES            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Gerar boletos para:                                         │
│                                                             │
│ ☑ Abril/2026   - Vencimento: 10/04                          │
│ ☑ Maio/2026    - Vencimento: 10/05                          │
│ ☑ Junho/2026   - Vencimento: 10/06                          │
│ ☐ Julho/2026   - Vencimento: 10/07                          │
│ ☐ Agosto/2026  - Vencimento: 10/08                          │
│ ☐ Setembro/2026 - Vencimento: 10/09                         │
│                                                             │
│ Valor para todos: R$ 630,00 (igual para todos os meses)    │
│                                                             │
│           [CANCELAR]    [GERAR 3 MESES]                     │
└─────────────────────────────────────────────────────────────┘
```

> ⚠️ **Atenção:** Se em maio o valor mudar (ex: conta de água maior), o síndico precisará **cancelar** o boleto de maio e gerar um novo com o valor correto.

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
│ │ 📄 BOLETO - Abril/2026                                 ││
│ │                                                         ││
│ │ Unidade: A/101                                          ││
│ │ Vencimento: 10/04/2026                                  ││
│ │ Status: ⚪ A Vencer                                     ││
│ │                                                         ││
│ │ VALOR: R$ 630,00                                        ││
│ │                                                         ││
│ │ ▼ Ver Composição                                        ││
│ │   ├─ Cota Condominial... R$ 450,00                     ││
│ │   ├─ Fundo de Reserva... R$  45,00                     ││
│ │   ├─ Taxa de Controle... R$  15,00                     ││
│ │   └─ Rateio de Água..... R$ 120,00                     ││
│ │                                                         ││
│ │ [📋 COPIAR CÓDIGO] [📄 VER PDF] [📤 COMPARTILHAR]      ││
│ └─────────────────────────────────────────────────────────┘│
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ 📄 BOLETO - Março/2026                                 ││
│ │ Status: ✅ PAGO em 08/03/2026                           ││
│ │ VALOR: R$ 630,00                                        ││
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
| **Ver Composição** | Mostra de onde vem o valor |

---

## 6. Resumo: Quem Faz O Quê?

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    DIVISÃO DE RESPONSABILIDADES                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │                        SÍNDICO                                   │  │
│   ├─────────────────────────────────────────────────────────────────┤  │
│   │ • Lança as despesas do mês                                      │  │
│   │ • Define o valor da cota condominial                            │  │
│   │ • Gera os boletos (manual ou automático)                        │  │
│   │ • Dá baixa quando alguém paga em dinheiro                       │  │
│   │ • Faz acordos de pagamento                                      │  │
│   │ • Gera boletos avulsos (extras)                                 │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │                    PROPRIETÁRIO / INQUILINO                      │  │
│   ├─────────────────────────────────────────────────────────────────┤  │
│   │ • Visualiza seus boletos                                        │  │
│   │ • Copia o código de barras                                      │  │
│   │ • Baixa o PDF do boleto                                         │  │
│   │ • Compartilha o boleto                                          │  │
│   │ • Vê a composição do valor                                      │  │
│   │ • Vê o demonstrativo financeiro                                 │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│   ┌─────────────────────────────────────────────────────────────────┐  │
│   │                        SISTEMA                                   │  │
│   ├─────────────────────────────────────────────────────────────────┤  │
│   │ • Registra os boletos no banco (ASAAS)                          │  │
│   │ • Gera código de barras e linha digitável                       │  │
│   │ • Envia os boletos por email                                    │  │
│   │ • Atualiza status quando pago                                   │  │
│   │ • Calcula juros e multas                                        │  │
│   └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Perguntas Frequentes

### P: O síndico ESQUECEU de gerar os boletos. E agora?
**R:** Ele pode gerar a qualquer momento. Os moradores recebem por email assim que ele gera.

### P: O morador perdeu o boleto. Pode reenviar?
**R:** Sim! O síndico pode reenviar por email, ou o morador pode ver no app.

### P: O valor do mês mudou (conta de água mais alta). Como ajustar?
**R:** O síndico gera um novo boleto com o valor correto. Se já gerou errado, cancela e gera novo.

### P: O morador pagou em dinheiro na portaria. Como registrar?
**R:** O síndico entra no boleto, clica em "Receber" e registra o pagamento manual.

### P: O morador está devendo 3 meses. Dá para fazer um acordo?
**R:** Sim! O síndico seleciona os 3 boletos e clica em "Agrupar". Vira um único boleto com a soma.

---

## 8. Fluxo Visual Simplificado

```
                    COMEÇO DO MÊS
                         │
                         ▼
    ┌─────────────────────────────────────┐
    │  Síndico lança as DESPESAS          │
    │  (luz, água, salários, etc.)        │
    └──────────────┬──────────────────────┘
                   │
                   ▼
    ┌─────────────────────────────────────┐
    │  Síndico GERA A COBRANÇA MENSAL     │
    │  (define valor e vencimento)        │
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
    │  (automático via ASAAS)             │
    └─────────────────────────────────────┘
                         │
                         ▼
                    FIM DO MÊS
```

---

## 9. Conclusão

| Pergunta | Resposta |
|----------|----------|
| Síndico precisa gerar todo mês? | **Não obrigatoriamente**. Pode ser automático (futuro) ou gerar vários meses de uma vez. |
| Dá para gerar o semestre inteiro? | **Sim**, se os valores forem fixos. Se variam, melhor gerar mês a mês. |
| Morador precisa pedir o boleto? | **Não**. Recebe automaticamente por email e vê no app. |
| Quem registra no banco? | **O sistema**, via integração com ASAAS. O síndico não precisa ir ao banco. |
