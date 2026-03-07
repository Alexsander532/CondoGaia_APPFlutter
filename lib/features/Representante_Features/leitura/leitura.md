# 📊 Módulo de Leitura de Consumo (Água, Gás, Energia)

## 📋 Visão Geral

O módulo de **Leitura** permite ao **Representante do Condomínio** registrar e gerenciar as leituras de consumo (água, gás, energia, etc.) de todas as unidades do condomínio. Com base nessas leituras, o sistema calcula automaticamente o consumo e o valor a ser cobrado de cada unidade.

---

## 🎯 Objetivo Principal

Permitir que o representante:
1. Registre a leitura atual do medidor de cada unidade
2. O sistema calcule automaticamente o **consumo** (leitura atual - leitura anterior)
3. O sistema calcule automaticamente o **valor** a pagar baseado na configuração de preços
4. Anexe uma foto comprovando a leitura (opcional)
5. Gere cobranças junto com a taxa condominial ou de forma avulsa

---

## 🖥️ Estrutura das Telas

### Tela Principal de Leitura (`LeituraScreen`)

A tela principal possui **duas abas**:

| Aba | Função |
|-----|--------|
| **Cadastrar** | Registrar novas leituras para as unidades |
| **Configurar** | Definir valores por m³/kWh e faixas de preço |

---

## 📝 Aba "Cadastrar" - Fluxo de Trabalho

### 1. Seleção do Tipo de Leitura

O representante seleciona qual tipo de consumo vai registrar:

| Tipo | Unidade de Medida | Exemplo de Uso |
|------|-------------------|----------------|
| **Água** | M³ (metros cúbicos) | Consumo de água potável |
| **Gás** | M³ ou KG | Gás encanado ou botijão |
| **Energia** | kWh | Consumo elétrico (futuro) |
| **Outros** | Configurável | Qualquer outro serviço medido |

### 2. Campos do Formulário

| Campo | Descrição | Exemplo |
|-------|-----------|---------|
| **Tipo** | Dropdown para selecionar Água, Gás, etc. | "Água" |
| **Pesquisar** | Filtro para buscar unidade por bloco/número | "Bloco A" ou "101" |
| **Data da Leitura** | Preenchido automaticamente com a data atual | "07/02/2026" |
| **M³ / kWh** | Campo para digitar o valor lido no medidor | "125.500" |
| **Valor base** | Mostra o valor por m³ configurado (somente leitura) | "R$ 8.50" |
| **Anexar foto** | Botão para tirar/selecionar foto do medidor | 📷 |

### 3. Tabela de Unidades

A tabela mostra todas as unidades do condomínio com as seguintes colunas:

| Coluna | Descrição | Exemplo |
|--------|-----------|---------|
| **Sel.** | Checkbox para selecionar a unidade | ☑️ |
| **Bloco** | Identificação do bloco | "A" |
| **Unidade** | Número do apartamento/sala | "101" |
| **Leit. Anterior** | Última leitura registrada (mês anterior) | "120.000" |
| **Leit. Atual** | Leitura do mês atual (se já registrada) | "125.500" |
| **Consumo** | Diferença entre atual e anterior | "5.500" |
| **Valor** | Valor calculado a pagar | "R$ 46.75" |

### 4. Ações Disponíveis

| Botão | Ação |
|-------|------|
| **Gravar** | Salva a leitura da unidade selecionada |
| **Excluir** | Remove leituras selecionadas |
| **Editar** | Permite editar uma leitura já registrada |

---

## ⚙️ Aba "Configurar" - Configurações de Preço

### 1. Campos de Configuração

| Campo | Descrição | Exemplo |
|-------|-----------|---------|
| **Tipo** | Tipo de leitura (Água, Gás, etc.) | "Água" |
| **Unidade de Medida** | M³, KG, L, kWh | "M³" |
| **Valor por 1 unidade** | Preço base por m³/kWh | "R$ 8.50" |

### 2. Faixas de Valores (Sistema Progressivo)

Alguns condomínios cobram valores diferentes dependendo do consumo. Por exemplo, quem consome mais paga mais caro por m³.

#### Exemplo Real de Faixas:

```
Faixa 1:  0 M³  até  10 M³  = R$ 5,00 por M³
Faixa 2: 10 M³  até  20 M³  = R$ 8,00 por M³  
Faixa 3: 20 M³  até  50 M³  = R$ 12,00 por M³
Acima de 50 M³: usa o valor base configurado
```

#### Como Funciona o Cálculo por Faixas?

**Cenário:** Unidade consumiu **25 M³** no mês

| Faixa | Consumo na Faixa | Valor/M³ | Subtotal |
|-------|------------------|----------|----------|
| 0 até 10 M³ | 10 M³ | R$ 5,00 | R$ 50,00 |
| 10 até 20 M³ | 10 M³ | R$ 8,00 | R$ 80,00 |
| 20 até 50 M³ | 5 M³ | R$ 12,00 | R$ 60,00 |
| **TOTAL** | **25 M³** | - | **R$ 190,00** |

### 3. Tipo de Cobrança

| Opção | Descrição |
|-------|-----------|
| **Junto com Taxa de Cond.** | O valor será incluído no boleto mensal do condomínio |
| **Avulso** | Gera um boleto separado apenas para o consumo |

---

## 🔄 Fluxo Completo de uma Leitura

### Passo a Passo Prático

```
1. Representante acessa o módulo de Leitura
2. Seleciona o tipo "Água" no dropdown
3. Na tabela, aparece a lista de todas as unidades do condomínio
4. Para cada unidade, ele:
   a) Clica na linha para selecionar a unidade
   b) Digita o número que está no hidrômetro (ex: 125.500)
   c) Opcionalmente tira uma foto do medidor
   d) Clica em "Gravar"
5. O sistema automaticamente:
   a) Busca a leitura anterior dessa unidade (ex: 120.000)
   b) Calcula o consumo: 125.500 - 120.000 = 5.500 M³
   c) Aplica as faixas de preço configuradas
   d) Calcula o valor: R$ 46.75
6. A tabela é atualizada mostrando os dados
7. No final do mês, os valores são cobrados
```

---

## 🧮 Fórmulas de Cálculo

### Consumo
```
Consumo = Leitura Atual - Leitura Anterior
```

### Valor (sem faixas)
```
Valor = Consumo × Valor Base por M³
```

### Valor (com faixas progressivas)
```
Para cada faixa:
  consumo_na_faixa = min(consumo_restante, faixa.fim - faixa.inicio)
  valor_faixa = consumo_na_faixa × faixa.valor
  consumo_restante = consumo_restante - consumo_na_faixa

Valor Total = Soma de todos os valores_faixa
```

---

## 📊 Exemplos Práticos

### Exemplo 1: Cálculo Simples (Sem Faixas)

**Configuração:**
- Valor base: R$ 10,00 por M³
- Sem faixas definidas

**Dados:**
- Leitura anterior: 100.000 M³
- Leitura atual: 108.500 M³

**Cálculo:**
```
Consumo = 108.500 - 100.000 = 8.500 M³
Valor = 8.500 × R$ 10,00 = R$ 85,00
```

---

### Exemplo 2: Cálculo com Faixas Progressivas

**Configuração:**
- Faixa 1: 0 a 10 M³ → R$ 5,00/M³
- Faixa 2: 10 a 20 M³ → R$ 8,00/M³
- Faixa 3: 20 a 50 M³ → R$ 12,00/M³
- Valor base (acima de 50 M³): R$ 15,00/M³

**Dados:**
- Consumo: 35 M³

**Cálculo:**
```
Faixa 1: 10 M³ × R$ 5,00 = R$ 50,00
Faixa 2: 10 M³ × R$ 8,00 = R$ 80,00
Faixa 3: 15 M³ × R$ 12,00 = R$ 180,00
-----------------------------------------
TOTAL: R$ 310,00
```

---

### Exemplo 3: Consumo que Extrapola as Faixas

**Configuração:** (mesma do exemplo 2)

**Dados:**
- Consumo: 60 M³

**Cálculo:**
```
Faixa 1: 10 M³ × R$ 5,00 = R$ 50,00
Faixa 2: 10 M³ × R$ 8,00 = R$ 80,00
Faixa 3: 30 M³ × R$ 12,00 = R$ 360,00
Excedente: 10 M³ × R$ 15,00 = R$ 150,00
-----------------------------------------
TOTAL: R$ 640,00
```

---

## 🗃️ Estrutura de Dados

### Tabela `leituras` (Banco de Dados)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | UUID | Identificador único |
| `unidade_id` | UUID | FK para tabela unidades |
| `leitura_anterior` | DECIMAL | Valor da leitura anterior |
| `leitura_atual` | DECIMAL | Valor da leitura registrada |
| `valor` | DECIMAL | Valor calculado a pagar |
| `data_leitura` | DATE | Data em que a leitura foi feita |
| `tipo` | VARCHAR | "Agua", "Gas", "Energia" |
| `imagem_url` | VARCHAR | URL da foto do medidor |

### Tabela `leitura_configuracoes` (Banco de Dados)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | UUID | Identificador único |
| `condominio_id` | UUID | FK para tabela condominios |
| `tipo` | VARCHAR | "Agua", "Gas", etc. |
| `unidade_medida` | VARCHAR | "M³", "KG", "kWh" |
| `valor_base` | DECIMAL | Preço por unidade de medida |
| `faixas` | JSONB | Array de faixas progressivas |
| `cobranca_tipo` | INT | 1 = junto taxa, 2 = avulso |

### Estrutura das Faixas (JSON)

```json
[
  {"inicio": 0, "fim": 10, "valor": 5.00},
  {"inicio": 10, "fim": 20, "valor": 8.00},
  {"inicio": 20, "fim": 50, "valor": 12.00}
]
```

---

## ✅ Regras de Negócio

1. **Leitura Anterior Automática:** O sistema busca automaticamente a última leitura registrada para calcular o consumo
2. **Validação de Leitura:** A leitura atual não pode ser menor que a anterior (indicaria erro ou troca de medidor)
3. **Foto Opcional:** A foto serve como comprovante, mas não é obrigatória
4. **Uma Leitura por Mês:** Cada unidade tem apenas uma leitura por tipo por mês
5. **Faixas Ordenadas:** As faixas devem ser configuradas em ordem crescente
6. **Valor Base como Fallback:** Se o consumo exceder todas as faixas, usa-se o valor base

---

## 🔮 Melhorias Futuras

1. **Suporte a Energia Elétrica (kWh):** Adicionar tipo "Energia" com unidade kWh
2. **Importação de Planilha:** Permitir importar leituras via Excel/CSV
3. **Histórico Gráfico:** Mostrar gráficos de consumo ao longo dos meses
4. **Alertas de Consumo:** Notificar quando consumo estiver acima da média
5. **Leitura por QR Code:** Escanear QR da unidade para agilizar o registro
6. **Taxa Mínima:** Cobrar um valor mínimo mesmo que não haja consumo
7. **Medidores por Unidade:** Suporte a múltiplos medidores por unidade

---

## 📱 Diagrama de Fluxo Visual

```
┌─────────────────────────────────────────────────────────────────┐
│                    TELA DE LEITURA                              │
├─────────────────────────────────────────────────────────────────┤
│  [Cadastrar]  |  [Configurar]     ← Abas                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Tipo: [▼ Água    ]                                             │
│                                                                 │
│  Pesquisar: [________________] 🔍                               │
│                                                                 │
│  Data da Leitura: 07/02/2026 (Automática)                       │
│                                                                 │
│  M³: [_____________]                                            │
│                                                                 │
│  Valor base/config: R$ 8.50 (faixas na Configurar)              │
│                                                                 │
│  📷 Anexar foto                                                 │
│                                                                 │
│  [       GRAVAR       ]                                         │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  Sel│Bloco│Unid│Leit.Ant│Leit.Atu│Consumo│Valor                 │
│  ───┼─────┼────┼────────┼────────┼───────┼──────                │
│  ☑️ │  A  │101 │ 120.00 │ 125.50 │  5.50 │ R$46.75              │
│  ☐  │  A  │102 │  85.00 │   -    │   -   │   -                  │
│  ☐  │  A  │103 │ 200.00 │ 235.00 │ 35.00 │R$310.00              │
│  ☐  │  B  │201 │  50.00 │  55.00 │  5.00 │ R$25.00              │
├─────────────────────────────────────────────────────────────────┤
│  [Excluir] [Editar]              Qtnd: 4  Total: R$ 381.75      │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎨 Estados da Interface

| Estado | Descrição | Visual |
|--------|-----------|--------|
| **Loading** | Carregando dados | Spinner centralizado |
| **Sucesso** | Dados carregados | Tabela com dados |
| **Erro** | Falha na requisição | Snackbar com mensagem |
| **Vazio** | Sem unidades | Mensagem "Nenhuma unidade encontrada" |
| **Salvando** | Gravando leitura | Botão desabilitado + loading |

---

## 📦 Arquivos do Módulo

```
lib/features/Representante_Features/leitura/
├── cubit/
│   ├── leitura_cubit.dart      # Gerenciamento de estado
│   └── leitura_state.dart      # Definição dos estados
├── models/
│   ├── leitura_model.dart                # Modelo de leitura
│   └── leitura_configuracao_model.dart   # Modelo de configuração
├── screens/
│   ├── leitura_screen.dart               # Tela principal
│   └── leitura_configuracao_screen.dart  # Tela de configuração
├── services/
│   ├── leitura_service.dart    # Comunicação com Supabase
│   └── cache_service.dart      # Cache local
├── widgets/
│   └── leitura_table_widget.dart   # Tabela de leituras
└── leitura.md                  # Este documento
```