# 📊 Relatório de Implementação — Leitura de Consumo (Água e Gás)

> **Documento para revisão de sócio** · Versão 1.0 · Março 2026  
> **Objetivo:** Explicar como funciona a feature de leitura de medidores, como o consumo é calculado, como as faixas de preço funcionam e como isso se reflete nos boletos dos moradores.

---

## 1. Visão Geral do Módulo

O módulo de **Leitura** permite que o síndico ou zelador registre as leituras mensais de consumo de **água** e **gás** de cada unidade do condomínio. O sistema calcula automaticamente:

- **Consumo do período** (leitura atual – leitura anterior)
- **Valor a pagar** (baseado em faixas de preço configuráveis)

### Status Geral:

| Funcionalidade | Status | Descrição |
|---|---|---|
| Registrar leitura de água | ✅ Funcional | Registro manual por unidade |
| Registrar leitura de gás | ✅ Funcional | Registro manual por unidade |
| Cálculo automático de consumo | ✅ Funcional | Diferença entre leitura atual e anterior |
| Cálculo por faixas de preço | ✅ Funcional | Preço progressivo conforme consumo |
| Configurar faixas de preço | ✅ Funcional | Síndico define faixas e valores |
| Anexar foto do medidor | ✅ Funcional | Upload de foto como comprovante |
| Cobrança junto com taxa | ✅ Funcional | Valor é incluído no boleto mensal |
| Cobrança avulsa | ✅ Funcional | Gera boleto separado para consumo |
| Cache local (offline) | ✅ Funcional | Dados ficam salvos mesmo sem internet |
| Histórico gráfico de consumo | 🔲 Futuro | Ainda não implementado |
| Importação por planilha | 🔲 Futuro | Ainda não implementado |

---

## 2. Fluxo de Trabalho — Passo a Passo

### 2.1 Como registrar uma leitura

```
╭──────────────────────────────────────╮
│  1. Síndico/Zelador abre "Leitura"  │
╰──────────────┬───────────────────────╯
               │
               ▼
╭──────────────────────────────────────╮
│  2. Seleciona o tipo: Água ou Gás   │
╰──────────────┬───────────────────────╯
               │
               ▼
╭──────────────────────────────────────╮
│  3. Navega no mês/ano desejado      │
╰──────────────┬───────────────────────╯
               │
               ▼
╭──────────────────────────────────────╮
│  4. Vê a tabela com todas as        │
│     unidades do condomínio          │
╰──────────────┬───────────────────────╯
               │
               ▼
╭──────────────────────────────────────╮
│  5. Para cada unidade:              │
│     - Insere a leitura atual (m³)   │
│     - Sistema mostra a anterior     │
│     - Calcula consumo e valor       │
│     - Opcionalmente tira uma foto   │
╰──────────────┬───────────────────────╯
               │
               ▼
╭──────────────────────────────────────╮
│  6. Salva as leituras               │
│     (dados vão para o Supabase)     │
╰──────────────────────────────────────╯
```

### 2.2 O que aparece na tabela de leituras

A tabela mostra uma linha para cada unidade do condomínio com as seguintes colunas:

| Coluna | O que é | Exemplo |
|---|---|---|
| **Bloco/Unid** | Identificação da unidade | A-101 |
| **Leitura Anterior** | Medição do mês passado (m³) | 150 |
| **Leitura Atual** | Medição deste mês (preenchida pelo zelador) | 162 |
| **Consumo** | Diferença (calculada automaticamente) | 12 m³ |
| **Valor** | Preço calculado pelas faixas de preço | R$ 84,00 |
| **📷 Foto** | Comprovante fotográfico do medidor | (ícone de câmera) |

---

## 3. Sistema de Faixas de Preço — A Regra Mais Importante

### 3.1 O que são faixas de preço?

As faixas funcionam como uma **tabela progressiva** — quanto mais consome, mais caro fica por unidade (m³). É igual ao imposto de renda progressivo: cada faixa tem seu próprio preço.

### 3.2 Como o síndico configura?

O síndico vai em **Leitura > Configuração** e define:

| Faixa | De (m³) | Até (m³) | Valor por m³ |
|---|---|---|---|
| Faixa 1 | 0 | 10 | R$ 5,00 |
| Faixa 2 | 10 | 20 | R$ 7,00 |
| Faixa 3 | 20 | 30 | R$ 10,00 |
| Faixa 4 | 30+ | ∞ | R$ 15,00 |

### 3.3 Como o cálculo funciona na prática?

#### Caso Real 1: Consumo dentro da primeira faixa

> **Unidade A-101 consumiu 8 m³ de água**
>
> | Faixa | Consumo na faixa | Valor por m³ | Subtotal |
> |---|---|---|---|
> | Faixa 1 (0–10) | 8 m³ | R$ 5,00 | R$ 40,00 |
> | **Total** | **8 m³** | | **R$ 40,00** |

#### Caso Real 2: Consumo atravessando duas faixas

> **Unidade B-202 consumiu 15 m³ de água**
>
> | Faixa | Consumo na faixa | Valor por m³ | Subtotal |
> |---|---|---|---|
> | Faixa 1 (0–10) | 10 m³ | R$ 5,00 | R$ 50,00 |
> | Faixa 2 (10–20) | 5 m³ | R$ 7,00 | R$ 35,00 |
> | **Total** | **15 m³** | | **R$ 85,00** |

#### Caso Real 3: Alto consumo atravessando três faixas

> **Unidade C-303 consumiu 25 m³ de água**
>
> | Faixa | Consumo na faixa | Valor por m³ | Subtotal |
> |---|---|---|---|
> | Faixa 1 (0–10) | 10 m³ | R$ 5,00 | R$ 50,00 |
> | Faixa 2 (10–20) | 10 m³ | R$ 7,00 | R$ 70,00 |
> | Faixa 3 (20–30) | 5 m³ | R$ 10,00 | R$ 50,00 |
> | **Total** | **25 m³** | | **R$ 170,00** |
>
> **Note:** Se o condomínio não tivesse faixas e cobrasse tudo a R$ 7/m³, o morador pagaria R$ 175. Com faixas, ele paga R$ 170 porque o começo do consumo é mais barato.

#### Caso Real 4: Consumo zero

> **Unidade D-404 teve leitura anterior 200 e leitura atual 200**
>
> Consumo = 200 - 200 = **0 m³** → **Valor = R$ 0,00**
>
> O sistema não cobra nada quando não há consumo.

### 3.4 Valor Base (fallback)

Se o síndico **não configurar faixas**, o sistema usa um **valor base** por m³. Exemplo:

> Valor base: R$ 6,00/m³
> Consumo: 12 m³
> Total: 12 × R$ 6,00 = **R$ 72,00**

---

## 4. Configurações Disponíveis

O síndico configura cada tipo de medidor (Água, Gás) separadamente:

| Configuração | O que é | Opções |
|---|---|---|
| **Tipo** | Qual recurso está medindo | Água / Gás |
| **Unidade de Medida** | Como o consumo é medido | M³ (padrão) |
| **Valor Base** | Preço por m³ quando sem faixas | Ex: R$ 6,00 |
| **Faixas de Preço** | Tabela progressiva de preços | Personalizável |
| **Tipo de Cobrança** | Como o valor vai ser cobrado | 1 = Junto com Taxa / 2 = Boleto Avulso |
| **Vencimento Avulso** | Data de vencimento se for boleto separado | Ex: dia 15 |

### 4.1 Diferença entre "Junto com Taxa" e "Boleto Avulso"

| Modo | O que acontece | Quando usar |
|---|---|---|
| **Junto com Taxa** | O valor do consumo é somado ao boleto mensal | Condomínios que querem um único boleto |
| **Boleto Avulso** | É gerado um boleto separado só para água/gás | Quando o consumo varia muito e precisa de destaque |

> **Caso Real:** O "Residencial Pinheiros" cobra R$ 500 de taxa + água junto. O morador da unidade A-101 consumiu R$ 85 de água.  
> → Boleto do mês: **R$ 585,00** (taxa + água incluída)

> **Caso Real 2:** O "Edifício Aurora" cobra água separado. O morador recebe dois boletos:
> → Boleto 1: **R$ 450,00** (taxa mensal)
> → Boleto 2: **R$ 85,00** (consumo de água)

---

## 5. Como a Leitura é Armazenada

Cada leitura registrada grava no banco de dados os seguintes dados:

| Campo | Descrição | Exemplo |
|---|---|---|
| `unidade_id` | Qual unidade | ID da unidade A-101 |
| `condominio_id` | Qual condomínio | ID do Residencial Pinheiros |
| `tipo` | Água ou Gás | "Agua" |
| `leitura_anterior` | Medição do mês passado | 150.0 |
| `leitura_atual` | Medição deste mês | 162.0 |
| `consumo` | Diferença calculada | 12.0 |
| `valor_calculado` | Valor em R$ | 85.00 |
| `data_leitura` | Data do registro | 2026-03-15 |
| `imagem_url` | Foto do medidor | URL da foto |
| `observacao` | Alguma nota | "Medidor com vazamento" |

---

## 6. Funcionalidade de Cache (Offline)

O sistema usa **cache local** para que o zelador possa:

1. Abrir a tela de leitura sem internet (dados do mês anterior aparecem do cache)
2. Agilizar a navegação (não precisa esperar carregar toda vez)
3. Em caso de queda de internet, os dados mais recentes ficam salvos localmente

> **Atenção:** O registro (botão "Salvar") **precisa de internet** para enviar ao banco de dados.

---

## 7. Foto do Medidor

O zelador pode tirar ou anexar uma **foto do medidor** para cada unidade. Essa foto serve como:

- **Comprovante** de que a leitura foi feita corretamente
- **Prova** em caso de contestação do morador
- **Registro visual** do estado do medidor

A foto é enviada automaticamente para o Supabase Storage e fica vinculada àquela leitura.

---

## 8. Regras de Negócio — Resumo

### ✅ Regras implementadas:

1. **Consumo = Leitura Atual − Leitura Anterior** — Cálculo automático, o zelador só informa a leitura atual
2. **Leitura anterior é preenchida automaticamente** — O sistema busca no banco de dados a leitura do mês passado
3. **Faixas de preço são progressivas** — Cada faixa tem seu próprio valor por m³
4. **Consumo zero = valor zero** — Não cobra quando não tem consumo
5. **Se não há faixas configuradas, usa valor base** — Fallback de segurança
6. **Consumo excedente acima de todas as faixas usa o valor base** — Se o consumo ultrapassar a última faixa, o excedente é cobrado pelo valor base
7. **Cada tipo (Água/Gás) tem configuração independente** — Podem ter faixas e vencimentos diferentes
8. **O tipo de cobrança (junto/avulso) é definido por tipo de medidor** — Água pode ser junto e gás avulso, ou vice-versa

### ⚠️ O que ainda não está implementado:

1. Gráfico de histórico de consumo por unidade ao longo dos meses
2. Importação em massa de leituras via planilha Excel
3. Alertas automáticos para consumo anormalmente alto
4. Relatório mensal de consumo em PDF

---

## 9. Integração com Boletos

```
╭────────────────╮     ╭──────────────────╮     ╭──────────────────╮
│ Zelador faz    │     │ Sistema calcula  │     │ Valor vai para   │
│ leitura (m³)   │ ──→ │ consumo e valor  │ ──→ │ o boleto mensal  │
│ de cada unid.  │     │ pelas faixas     │     │ (ou avulso)      │
╰────────────────╯     ╰──────────────────╯     ╰──────────────────╯
```

Quando o síndico gera os boletos mensais:
- Se a cobrança é **"Junto com Taxa"**, o valor do consumo de água/gás é somado automaticamente à cota condominial no campo **"Rateio Água"** do boleto.
- Se é **"Boleto Avulso"**, um boleto separado é criado com a descrição do consumo.

---

## 10. Resumo para Verificação

**Perguntas para o sócio validar:**

- [ ] As faixas de preço progressivas fazem sentido para o negócio?
- [ ] A diferenciação "Junto com Taxa" vs "Boleto Avulso" está clara?
- [ ] Falta algum dado que deveria ser registrado na leitura?
- [ ] O fluxo de leitura está prático para quem vai usar no dia a dia (zelador)?
- [ ] A opção de anexar foto é suficiente ou precisa de algo mais?
- [ ] Precisamos de uma funcionalidade de "leitura em massa" (importar planilha)?
- [ ] É necessário ter gráfico de histórico de consumo?
