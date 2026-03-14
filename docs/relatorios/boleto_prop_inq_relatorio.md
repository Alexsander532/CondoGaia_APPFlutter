# Relatório Completo — Feature Boleto (Proprietário/Inquilino)

**Data:** 13/03/2026  
**Versão:** 1.0  
**Status Geral:** 🟡 UI implementada com dados mock — sem integração backend

---

## 1. Visão Geral

A feature de Boleto para Proprietário/Inquilino (Prop/Inq) permite que moradores visualizem seus boletos de condomínio, filtrem por status, vejam a composição, demonstrativo financeiro, leituras e balancete online. A tela é acessada via a Home do Inquilino/Proprietário (`inquilino_home_screen.dart`).

### Fluxo de Navegação
```
Home (Prop/Inq) → Boletos → BoletoPropScreen
```
- Recebe apenas `condominioId` — **não recebe** `moradorId`, `inquilinoId` ou `proprietarioId`.

---

## 2. Arquitetura Atual

A feature segue **Clean Architecture** com 3 camadas:

```
boleto/
├── data/
│   ├── datasources/
│   │   └── boleto_prop_remote_datasource.dart    ← STUB (retorna listas vazias)
│   ├── models/
│   │   └── boleto_prop_model.dart                ← fromJson/toJson implementados
│   └── repositories/
│       └── boleto_prop_repository_impl.dart      ← Delega para DataSource
├── domain/
│   ├── entities/
│   │   └── boleto_prop_entity.dart                ← 8 campos
│   ├── repositories/
│   │   └── boleto_prop_repository.dart            ← Interface abstrata
│   └── usecases/
│       └── boleto_prop_usecases.dart              ← 3 use cases
└── ui/
    ├── cubit/
    │   ├── boleto_prop_cubit.dart                 ← USA DADOS MOCK HARDCODED
    │   └── boleto_prop_state.dart                 ← Estado com Equatable
    ├── screens/
    │   └── boleto_prop_screen.dart                ← Tela principal
    └── widgets/
        ├── boleto_card_widget.dart                ← Card expansível individual
        ├── boleto_acoes_expandidas.dart           ← Ações: Ver/Copiar/Compartilhar
        ├── boleto_filtro_dropdown.dart             ← Dropdown Vencido/Pago
        ├── demonstrativo_financeiro_widget.dart    ← Seletor mês/ano
        └── secoes_expansiveis_widget.dart          ← Composição/Leituras/Balancete
```

**Total: 11 arquivos** | **~1.100 linhas de código**

---

## 3. O Que Funciona (UI)

| Funcionalidade | Status | Observações |
|---|---|---|
| Dropdown filtro Vencido/A Vencer vs Pago | ✅ Funcional | Filtra lista local (mock) |
| Lista de boletos com cards expansíveis | ✅ Funcional | 5 boletos mock hardcoded |
| Indicador visual de vencido (flag vermelha) | ✅ Funcional | Cor vermelha na data e valor |
| Indicador visual de pago (thumb up verde) | ✅ Funcional | Ícone verde |
| Expandir/colapsar boleto individual | ✅ Funcional | Toggle por ID |
| Tipo do boleto na expansão | ✅ Funcional | "Taxa Condominial", "Avulso", "Acordo" |
| Copiar código de barras para clipboard | ✅ Funcional | Usa Clipboard.setData |
| Mensagem "2ª Via entrar em contato" | ✅ Funcional | Aparece quando vencido sem código de barras |
| Seletor mês/ano do demonstrativo | ✅ Funcional | Navega meses |
| Seções expansíveis (Composição/Leituras/Balancete) | ✅ Funcional | UI pronta mas dados mock |

---

## 4. O Que NÃO Funciona (Requer Backend)

| Funcionalidade | Status | Problema |
|---|---|---|
| **Carregar boletos reais do Supabase** | ❌ Não implementado | Cubit usa dados mock hardcoded |
| **Filtro por morador logado** | ❌ Não implementado | Tela não recebe moradorId |
| **Ver Boleto (PDF)** | ❌ Placeholder | Mostra snackbar "Em breve" |
| **Compartilhar Boleto** | ❌ Placeholder | Mostra snackbar "Em breve" |
| **Composição do Boleto (real)** | ❌ Dados mock | Valores hardcoded (R$300, R$50, R$50) |
| **Leituras do período** | ❌ Sem integração | Mensagem "Nenhuma leitura disponível" |
| **Balancete Online** | ❌ Sem integração | Mensagem "não disponível" |
| **Demonstrativo Financeiro (dados reais)** | ❌ Sem integração | Seletor funciona mas não busca dados |
| **DataSource remoto** | ❌ Stub | Todos os métodos retornam listas vazias |
| **Injeção de dependências** | ❌ Não configurada | Cubit instanciado direto sem UseCase |
| **Testes automatizados** | ❌ Nenhum teste | Zero cobertura |

---

## 5. Comparação com o Boleto do Representante

O boleto do Representante (`Representante_Features/boleto/`) já está **completamente funcional** com integração Supabase e ASAAS:

| Aspecto | Representante | Prop/Inq |
|---|---|---|
| Arquitetura | Service direto (BoletoService) | Clean Architecture (camadas) |
| Dados | Supabase real (tabela `boletos`) | Mock hardcoded |
| Campos do Model | 30+ campos completos | 8 campos básicos |
| Integração ASAAS | ✅ (bank_slip_url, bar_code, etc.) | ❌ |
| Service/DataSource | 575 linhas com queries complexas | Stub vazio |
| Testes | Não tem | Não tem |

---

## 6. Schema do Banco de Dados (Supabase)

A tabela `boletos` existe e tem **35 colunas**:

### Campos principais para o Prop/Inq:
| Coluna | Tipo | Descrição |
|---|---|---|
| `id` | uuid (PK) | ID do boleto |
| `condominio_id` | uuid (FK) | FK para condominios |
| `unidade_id` | uuid (FK) | FK para unidades |
| `sacado` | uuid | ID do morador (proprietário ou inquilino) |
| `data_vencimento` | date | Data de vencimento |
| `valor` | numeric | Valor original |
| `status` | text | Ativo, Pago, Cancelado, etc. |
| `tipo` | text | Mensal, Avulso, Acordo |
| `bar_code` | text | Código de barras ASAAS |
| `bank_slip_url` | text | URL do PDF do boleto ASAAS |
| `identification_field` | text | Linha digitável |
| `cota_condominial` | numeric | Composição: cota |
| `fundo_reserva` | numeric | Composição: fundo reserva |
| `rateio_agua` | numeric | Composição: rateio água |
| `multa_infracao` | numeric | Composição: multa infração |
| `controle` | numeric | Composição: controle |
| `desconto` | numeric | Composição: desconto |
| `valor_total` | numeric | Valor total com acréscimos |

### Como identificar boletos do morador:
- Campo `sacado` = ID do proprietário ou inquilino logado
- Campo `condominio_id` = ID do condomínio selecionado

---

## 7. Problemas Críticos Identificados

### 7.1 Navegação incompleta
A tela `BoletoPropScreen` recebe apenas `condominioId`, mas precisa do `moradorId` (proprietário ou inquilino) para filtrar boletos. A `inquilino_home_screen.dart` tem `widget.inquilinoId` e `widget.proprietarioId` disponíveis mas **não os passa**.

### 7.2 Entity muito simplificada
A `BoletoPropEntity` tem apenas 8 campos vs 30+ no modelo do Representante. Faltam campos essenciais como `bank_slip_url`, `identification_field`, `cota_condominial`, `fundo_reserva`, etc.

### 7.3 Cubit desconectado da arquitetura
O `BoletoPropCubit` instancia dados mock diretamente ao invés de usar os Use Cases definidos na camada de domain. A arquitetura clean existe mas não é utilizada.

### 7.4 Ações sem implementação
- `verBoleto()` — vazio com TODO
- `compartilharBoleto()` — vazio com TODO
- `copiarCodigoBarras()` — no cubit está vazio, mas no widget funciona localmente

---

## 8. Resumo Executivo

A feature de Boleto Prop/Inq possui **UI completa e fiel ao design** (conforme os mockups), com cards expansíveis, filtros, e seções colapsáveis. Porém, **100% dos dados são mock** — nenhuma chamada real ao Supabase é feita. Para tornar a feature funcional, é necessário:

1. ✏️ Passar `moradorId` na navegação
2. ✏️ Expandir a Entity/Model com campos reais do banco
3. ✏️ Implementar o DataSource com queries Supabase
4. ✏️ Conectar o Cubit aos Use Cases reais
5. ✏️ Implementar ações (Ver Boleto PDF, Compartilhar)
6. ✏️ Conectar Composição, Leituras e Balancete com dados reais
7. ✏️ Escrever testes automatizados
