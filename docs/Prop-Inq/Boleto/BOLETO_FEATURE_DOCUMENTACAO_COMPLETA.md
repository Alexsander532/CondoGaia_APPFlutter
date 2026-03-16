# 📋 Documentação Completa — Feature Boleto (Proprietário/Inquilino)

**Versão:** 1.0  
**Última atualização:** Março de 2026  
**Status:** Em Desenvolvimento  
**Responsável:** Tim Dev CondoGaia

---

## 📑 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura Técnica](#arquitetura-técnica)
3. [Estrutura de Diretórios](#estrutura-de-diretórios)
4. [Regras de Negócio](#regras-de-negócio)
5. [Fluxo de Dados](#fluxo-de-dados)
6. [Modelos de Dados](#modelos-de-dados)
7. [Camada de Apresentação (UI)](#camada-de-apresentação-ui)
8. [Gerenciamento de Estado (Cubit)](#gerenciamento-de-estado-cubit)
9. [Casos de Uso (Use Cases)](#casos-de-uso-use-cases)
10. [Integração com ASAAS (Gateway de Pagamento)](#integração-com-asaas-gateway-de-pagamento)
11. [Sincronização e Webhooks](#sincronização-e-webhooks)
12. [Funcionalidades Principais](#funcionalidades-principais)
13. [Estados e Transições](#estados-e-transições)
14. [Endpoints e APIs](#endpoints-e-apis)
15. [Testes e Validações](#testes-e-validações)
16. [Próximas Funcionalidades](#próximas-funcionalidades)

---

## Visão Geral

### O que é?

A **feature de Boleto** para **Proprietário/Inquilino (Prop/Inq)** é um módulo do aplicativo CondoGaia que permite aos moradores visualizar, controlar e gerenciar seus boletos (faturas/cobranças) do condomínio.

### Objetivos Principais

- ✅ Visualizar lista de boletos do morador
- ✅ Filtrar boletos por status (Pagos / A Vencer/Vencidos)
- ✅ Ver detalhes completos de cada boleto
- ✅ Visualizar a composição do boleto (cota, fundo de reserva, etc.)
- ✅ Copiar código de barras do boleto
- ✅ Visualizar PDF do boleto
- ✅ Compartilhar boleto com outros
- ✅ Sincronizar boletos com ASAAS
- ✅ Visualizar demonstrativo financeiro mensal
- ✅ Acessar leituras de água/consumo
- ✅ Consultar balancete online

### Usuários Alvo

- **Proprietários** de unidades no condomínio
- **Inquilinos** que alugam unidades
- **Síndicos/Administradores** (visualização de boletos de moradores específicos)

### Fluxo básico do usuário

```
Tela de Menu Principal
         ↓
Propriedades/Gestão do Condomínio
         ↓
Visualizar Boletos
         ↓
Filtrar/Buscar Boletos
         ↓
Ver Detalhes de um Boleto
         ↓
Copiar Código/Visualizar PDF/Compartilhar
```

---

## Arquitetura Técnica

### Padrão Arquitetural: Clean Architecture + BLoC

A feature segue a **Clean Architecture** com divisão clara de camadas:

```
┌─────────────────────────────────────────────┐
│         PRESENTATION LAYER (UI)             │
│  • Screens, Widgets, CUBITs, States         │
└──────────────────┬──────────────────────────┘
                   ↑
┌──────────────────┴──────────────────────────┐
│       DOMAIN LAYER (Business Logic)          │
│  • Entities, Repositories (abs), Use Cases  │
└──────────────────┬──────────────────────────┘
                   ↑
┌──────────────────┴──────────────────────────┐
│         DATA LAYER (API/Database)           │
│  • Models, Data Sources, Repository Impl    │
└─────────────────────────────────────────────┘
```

### Componentes Principais

| Componente | Responsabilidade | Localização |
|-----------|-----------------|-------------|
| **Entities** | Objetos puros do domínio | `domain/entities/` |
| **Models** | Conversão entre JSON e Dart | `data/models/` |
| **DataSources** | Chamadas ao Supabase/API | `data/datasources/` |
| **Repositories** | Implementação do contrato abstrato | `data/repositories/` |
| **Use Cases** | Lógica de negócio isolada | `domain/usecases/` |
| **Cubits** | Gerenciamento de estado (Presentation) | `ui/cubits/` |
| **States** | Estados imutáveis | `ui/states/` |
| **Screens** | Telas principais | `ui/screens/` |
| **Widgets** | Componentes reutilizáveis | `ui/widgets/` |

---

## Estrutura de Diretórios

### Frontend (Flutter) — Prop/Inq

```
lib/
└── features/
    └── Prop_Inq_Features/
        └── boleto/                          # Feature Boleto Pro/Inq
            ├── data/
            │   ├── datasources/
            │   │   ├── boleto_prop_remote_datasource.dart
            │   │   └── boleto_prop_remote_datasource_impl.dart
            │   ├── models/
            │   │   └── boleto_prop_model.dart
            │   └── repositories/
            │       └── boleto_prop_repository_impl.dart
            │
            ├── domain/
            │   ├── entities/
            │   │   └── boleto_prop_entity.dart      # Entidade pura (dados de negócio)
            │   ├── repositories/
            │   │   └── boleto_prop_repository.dart  # Contrato abstrato
            │   └── usecases/
            │       └── boleto_prop_usecases.dart    # Casos de uso
            │
            └── ui/
                ├── cubit/
                │   ├── boleto_prop_cubit.dart       # Gerenciador de estado (Cubit)
                │   └── boleto_prop_state.dart       # Estados imutáveis
                ├── screens/
                │   └── boleto_prop_screen.dart      # Tela principal Boleto
                └── widgets/
                    ├── boleto_card_widget.dart      # Card individual de boleto
                    ├── boleto_filtro_dropdown.dart  # Dropdown de filtros
                    ├── boleto_acoes_expandidas.dart # Ações (copiar, compartilhar, etc.)
                    ├── demonstrativo_financeiro_widget.dart
                    ├── secoes_expansiveis_widget.dart
                    ├── skeleton_widgets.dart         # Loading states
                    └── empty_state_widgets.dart      # Estados vazios
```

### Frontend (Flutter) — Representante

```
lib/
└── features/
    └── Representante_Features/
        └── boleto/                          # Feature Boleto Representante
            ├── cubit/
            │   ├── boleto_cubit.dart
            │   └── boleto_state.dart
            ├── models/
            │   └── boleto_model.dart
            ├── services/
            │   ├── boleto_service.dart
            │   └── boleto_email_service.dart
            ├── screens/
            │   └── boleto_screen.dart
            └── widgets/
                ├── boleto_filtro_widget.dart
                ├── boleto_list_widget.dart
                ├── boleto_acoes_widget.dart
                ├── receber_boleto_dialog.dart
                └── gerar_cobranca_mensal_dialog.dart
```

### Backend (Laravel)

```
Backend/
├── app/
│   ├── Http/
│   │   └── Controllers/
│   │       └── AsaasWebhookHandler.php      # Handler de webhooks ASAAS
│   ├── Models/
│   │   ├── Boleto.php
│   │   └── Morador.php
│   └── Asaas/
│       └── AsaasService.php                  # Integração ASAAS
├── database/
│   ├── migrations/
│   │   └── create_boletos_table.php          # Tabela de boletos
│   └── seeders/
└── routes/
    └── api.php                               # Rotas de APIs
```

---

## Regras de Negócio

### 1. Tipos de Boleto

| Tipo | Descrição | Frequência | Composição |
|------|-----------|-----------|-----------|
| **Mensal** | Cobrança recorrente da taxa de condomínio | Mensal | Cota + Fundo Reserva + Rateio Água + Descontos |
| **Avulso** | Cobrança extraordinária (consumo extra, multas, etc.) | Irregular | Customizável pelo síndico |
| **Acordo** | Resultado de negociação (parcelamento de débito) | Conforme acordo | Definido no contrato do acordo |

### 2. Composição do Boleto

Cada boleto é composto por diferentes itens que geram sua composição:

```
┌─────────────────────────────────────────────┐
│      VALOR TOTAL DO BOLETO (Exemplo)        │
├─────────────────────────────────────────────┤
│                                              │
│  Cota Condominial        ............. R$ 500,00
│  Fundo de Reserva        ............. R$ 150,00
│  Rateio de Água          ............. R$ 80,00
│  Multa por Infração      ............. R$ 50,00
│  Controle/Taxas          ............. R$ 10,00
│  (-) Desconto            ........... -R$ 20,00
│                          ─────────────────────
│  VALOR TOTAL             ........... R$ 770,00
│
│  + Juros (se atraso)     .............. R$ 0,00
│  + Multa (se atraso)     .............. R$ 0,00
│  + Outros Acréscimos     .............. R$ 0,00
│                          ─────────────────────
│  VALOR FINAL             ........... R$ 770,00
│
└─────────────────────────────────────────────┘
```

**Campos da Composição:**
- `cotaCondominial` — Taxa mensal base do condomínio
- `fundoReserva` — Fundo para reformas/manutenção futura
- `rateioAgua` — Divisão do consumo de água entre unidades
- `multaInfracao` — Multas por infrações no regulamento
- `controle` — Taxas de controle/processamento
- `desconto` — Descontos concedidos (promoções, adimplência)
- `valorTotal` — Soma de todos os itens
- `juros` — Juros por atraso (calculado se vencido)
- `multa` — Multa moratória por atraso
- `outrosAcrescimos` — Outros valores adicionais

### 3. Estados do Boleto

```
┌─────────────────────────────────────────────────────┐
│                 CICLO DE VIDA                       │
└─────────────────────────────────────────────────────┘

Criação
   ↓
[ATIVO/PENDENTE]  ← Boleto gerado, aguardando pagamento
   ↓                 • Pode ser visualizado
   ↓                 • Pode ser pago
   ↓
   ├─→ [PAGO]        ← Boleto já foi pago
   │    • Data de pagamento registrada
   │    • Não pode mais gerar juros/multas
   │
   ├─→ [VENCIDO]     ← Ultrapassou data de vencimento
   │    • Acumula juros e multas
   │    • Ainda pode ser pago
   │
   └─→ [CANCELADO]   ← Boleto anulado
        • Cancelado por Acordo — parcelado em outros boletos
        • Não pode ser pago
        • Histórico mantido
```

### 4. Fluxo de Pagamento

```
┌─────────────────────────────────────────────┐
│  1. GERAÇÃO DO BOLETO                       │
├─────────────────────────────────────────────┤
│  • Boleto criado no Supabase                │
│  • Status: ATIVO                            │
│  • Ainda sem registro no ASAAS              │
└────────────────────┬────────────────────────┘
                     ↓
┌─────────────────────────────────────────────┐
│  2. SINCRONIZAÇÃO COM ASAAS                 │
├─────────────────────────────────────────────┤
│  • Registro no gateway ASAAS                │
│  • Geração de PDF (bankSlipUrl)             │
│  • Geração de código de barras              │
│  • Campo: asaas_payment_id preenchido       │
└────────────────────┬────────────────────────┘
                     ↓
┌─────────────────────────────────────────────┐
│  3. PAGAMENTO REALIZADO (Usuário)           │
├─────────────────────────────────────────────┤
│  • Pagamento feito via app banco/débito     │
│  • ASAAS recebe compensação bancária        │
└────────────────────┬────────────────────────┘
                     ↓
┌─────────────────────────────────────────────┐
│  4. WEBHOOK ASAAS → BACKEND                 │
├─────────────────────────────────────────────┤
│  • URL: /api/asaas/webhook                  │
│  • Evento: PAYMENT_RECEIVED/CONFIRMED       │
│  • Dados: payment_id, valor, data           │
└────────────────────┬────────────────────────┘
                     ↓
┌─────────────────────────────────────────────┐
│  5. ATUALIZAÇÃO NO SUPABASE                 │
├─────────────────────────────────────────────┤
│  • Status: PAGO                             │
│  • data_pagamento: preenchida               │
│  • valor_pago: registrado                   │
│  • UI atualiza em tempo real                │
└─────────────────────────────────────────────┘
```

### 5. Regras de Cálculo

**Juros por Atraso:**
```
Juros = Valor Base × (Taxa Juros / 100) × (Dias Atraso / 30)
```

**Multa Moratória:**
```
Multa = Valor Base × (% Multa Fixa)  [ex: 2% do valor]
```

**Desconto por Adimplência:**
```
Desconto = Valor × (% Desconto) [Configurável por condomínio]
```

---

## Fluxo de Dados

### Fluxo Completo de uma Requisição

```
┌──────────────────────────────────────────────────────┐
│             CAMADA DE APRESENTAÇÃO                   │
│  User taps "Ver Boletos" → BoletoPropCubit           │
└────────────────────┬─────────────────────────────────┘
                     ↓
         carregarBoletos() chamado
                     ↓
┌────────────────────────────────────────────────────────┐
│           CAMADA DE DOMÍNIO                           │
│  Use Case: ObterBoletosPropUseCase                     │
│  ↓                                                     │
│  repository.obterBoletos(moradorId, filtro)           │
└────────────────────┬─────────────────────────────────┘
                     ↓
┌────────────────────────────────────────────────────────┐
│           CAMADA DE DADOS                             │
│  Repository: BoletoPropRepositoryImpl                  │
│  ↓                                                     │
│  DataSource: BoletoPropRemoteDataSourceImpl            │
│  ↓                                                     │
│  Supabase.from('boletos')                             │
│    .select('*')                                        │
│    .eq('sacado', moradorId)                            │
│    .not('status', 'eq', 'Pago')                        │
│    .order('data_vencimento', ascending: false)         │
└────────────────────┬─────────────────────────────────┘
                     ↓
        ┌────────────────────────┐
        │   PARSE JSON → MODELS  │
        │ ↓                       │
        │ BoletoPropModel.fromJson│
        │ ↓                       │
        │ Mapear para Entities   │
        └────────────┬───────────┘
                     ↓
        ┌────────────────────────┐
        │  Retornar ao Use Case  │
        │      ↓                  │
        │  Retornar ao Cubit     │
        │      ↓                  │
        │  emit(BoletoPropState) │
        └────────────┬───────────┘
                     ↓
┌────────────────────────────────────────────────────────┐
│          CAMADA DE APRESENTAÇÃO (UI)                  │
│  BlocBuilder recebe novo estado                       │
│  ↓                                                     │
│  Rebuild com lista de boletos                         │
│  ↓                                                     │
│  User vê boletos na tela                              │
└────────────────────────────────────────────────────────┘
```

### Fluxo de Integração com ASAAS

```
┌──────────────────────────────────┐
│  Usuário clica "Ver PDF Boleto"  │
└────────────┬─────────────────────┘
             ↓
┌────────────────────────────────────────────┐
│  BoletoPropCubit.sincronizarBoleto(id)     │
└────────────┬───────────────────────────────┘
             ↓
┌────────────────────────────────────────────┐
│  Verificar se já tem asaas_payment_id      │
│  - Se SIM → Buscar código no banco         │
│  - Se NÃO → Chamar backend para registrar  │
└────────────┬───────────────────────────────┘
             ↓
┌────────────────────────────────────────────┐
│  POST /asaas/boletos/registrar-individual  │
│  Backend Laravel                           │
│  ↓                                         │
│  AsaasService.registrarBoleto()            │
│  ↓                                         │
│  API ASAAS: POST /payments                 │
└────────────┬───────────────────────────────┘
             ↓
┌────────────────────────────────────────────┐
│  ASAAS retorna:                            │
│  - payment_id (ex: pay_123xyz)             │
│  - bankSlipUrl (URL do PDF)                │
│  - barCode / identificationField           │
└────────────┬───────────────────────────────┘
             ↓
┌────────────────────────────────────────────┐
│  Backend salva dados no Supabase:          │
│  UPDATE boletos SET                        │
│    asaas_payment_id = 'pay_123xyz',       │
│    bank_slip_url = 'https://...',          │
│    bar_code = '12345.678 90000.000000...'  │
│  WHERE id = 'boleto_id'                    │
└────────────┬───────────────────────────────┘
             ↓
┌────────────────────────────────────────────┐
│  Frontend recebe resposta com URL          │
│  ↓                                         │
│  url_launcher.launchUrl(bankSlipUrl)       │
│  ↓                                         │
│  Abre PDF no navegador/visualizador        │
└────────────────────────────────────────────┘
```

---

## Modelos de Dados

### Entity: BoletoPropEntity

**Localização:** `domain/entities/boleto_prop_entity.dart`

```dart
class BoletoPropEntity {
  // Identificadores
  final String id;                          // UUID único do boleto
  final String condominioId;                // ID do condomínio
  final String? unidadeId;                  // ID da unidade (opcional)
  
  // Informações Básicas
  final String? sacado;                     // ID do morador (quem deve)
  final String? blocoUnidade;               // "Bloco A - Apto 101"
  final String? referencia;                 // Nº de referência da cobrança
  
  // Vencimento e Valores
  final DateTime dataVencimento;            // Data de vencimento
  final double valor;                       // Valor principal
  final String status;                      // 'Ativo', 'Pago', 'Cancelado'
  final String tipo;                        // 'Mensal', 'Avulso', 'Acordo'
  
  // Composição Detalhada
  final double cotaCondominial;             // Cota base
  final double fundoReserva;                // Fundo de reserva
  final double multaInfracao;               // Multas
  final double controle;                    // Taxas de controle
  final double rateioAgua;                  // Rateio de água
  final double desconto;                    // Desconto aplicado (-R$)
  final double valorTotal;                  // Valor final = (itens)
  
  // Integração ASAAS
  final String? bankSlipUrl;                // URL do PDF do boleto
  final String? barCode;                    // Código de barras
  final String? identificationField;        // "Linha digitável"
  final String? invoiceUrl;                 // URL da fatura
  final String? asaasPaymentId;             // ID único no ASAAS
  
  // Legado (compatibilidade)
  final String? codigoBarras;
  final String? descricao;
  
  // Calculado
  final bool isVencido;                     // Passou da data?
}
```

### Model: BoletoPropModel

**Localização:** `data/models/boleto_prop_model.dart`

Extensão de BoletoPropEntity que adiciona métodos de serialização:

```dart
class BoletoPropModel extends BoletoPropEntity {
  const BoletoPropModel({...});
  
  // Converte JSON do Supabase → Model
  factory BoletoPropModel.fromJson(Map<String, dynamic> json) {
    return BoletoPropModel(
      id: json['id'],
      condominioId: json['condominio_id'],
      sacado: json['sacado'],
      blocoUnidade: json['bloco_unidade'],
      dataVencimento: DateTime.tryParse(json['data_vencimento']) ?? DateTime.now(),
      valor: (json['valor'] ?? 0).toDouble(),
      status: json['status'] ?? 'Ativo',
      tipo: json['tipo'] ?? 'Mensal',
      cotaCondominial: (json['cota_condominial'] ?? 0).toDouble(),
      fundoReserva: (json['fundo_reserva'] ?? 0).toDouble(),
      rateioAgua: (json['rateio_agua'] ?? 0).toDouble(),
      multaInfracao: (json['multa_infracao'] ?? 0).toDouble(),
      controle: (json['controle'] ?? 0).toDouble(),
      desconto: (json['desconto'] ?? 0).toDouble(),
      valorTotal: (json['valor_total'] ?? 0).toDouble(),
      bankSlipUrl: json['bank_slip_url'],
      barCode: json['bar_code'],
      identificationField: json['identification_field'],
      invoiceUrl: json['invoice_url'],
      asaasPaymentId: json['asaas_payment_id'],
    );
  }
  
  // Converte Model → JSON (se necessário enviar)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'condominio_id': condominioId,
      'sacado': sacado,
      'bloco_unidade': blocoUnidade,
      // ... etc
    };
  }
}
```

### Backend Model: Boleto (Representante)

**Localização:** `lib/features/Representante_Features/boleto/models/boleto_model.dart`

Modelo utilizado pela tela do Representante (síndico):

```dart
class Boleto {
  final String? id;                         // UUID único
  final String condominioId;                // ID do condomínio
  final String? blocoUnidade;               // "Bloco A - Apto 101"
  final String? sacado;                     // ID do morador
  final String? referencia;
  
  final DateTime? dataVencimento;
  final double valor;
  final String status;                      // Ativo, Pago, Cancelado, etc.
  final String? pgto;                       // SIM/NAO (pagamento recebido?)
  final String tipo;                        // Mensal, Avulso, Acordo
  final String? classe;
  final String baixa;                       // Manual, Automática
  
  final String? nossoNumero;
  final String boletoRegistrado;            // SIM, NAO, PENDENTE, ERRO
  final DateTime? dataPagamento;
  
  final double juros;
  final double multa;
  final double outrosAcrescimos;
  final double valorTotal;
  final String? obs;
  
  final String? contaBancariaId;
  final String? unidadeId;
  final String? blocoId;
  
  // Composição
  final double cotaCondominial;
  final double fundoReserva;
  final double multaInfracao;
  final double controle;
  final double rateioAgua;
  final double desconto;
  
  final DateTime? createdAt;
  
  // ASAAS
  final String? asaasPaymentId;
  final String? bankSlipUrl;
  final String? invoiceUrl;
  final String? identificationField;
  final String? barCode;
  
  // Auxiliares (joins)
  final String? sacadoNome;
  final String? sacadoEmail;
  final String? contaBancariaNome;
}
```

---

## Camada de Apresentação (UI)

### Tela Principal: BoletoPropScreen

**Localização:** `ui/screens/boleto_prop_screen.dart`

Tela principal onde o morador visualiza seus boletos.

**Componentes:**

```
┌─────────────────────────────────────────────┐
│  HEADER                                     │
│  ← Back  Logo  🔔 Suporte                  │
├─────────────────────────────────────────────┤
│  Breadcrumb: Home/Gestão/Boleto             │
├─────────────────────────────────────────────┤
│  FILTRO DROPDOWN                            │
│  [ ▼ Vencidos/A Vencer ]  [ ○ Pagos ]      │
├─────────────────────────────────────────────┤
│  MÊS/ANO SELECTOR                           │
│  < Março 2025 >                             │
├─────────────────────────────────────────────┤
│  LISTA DE BOLETOS                           │
│  ┌─────────────────────────────────────────┐
│  │ 15/03/2025 | R$ 750,00                  │
│  │ Mensal - Pago ✓                         │
│  │ [Expandir ▼]                            │
│  └─────────────────────────────────────────┘
│  ┌─────────────────────────────────────────┐
│  │ 10/04/2025 | R$ 850,00                  │
│  │ Mensal - A Vencer                       │
│  │ [Expandir ▼]                            │
│  └─────────────────────────────────────────┘
├─────────────────────────────────────────────┤
│  SEÇÕES EXPANSÍVEIS                         │
│  ▼ Composição do Boleto                     │
│    Cota Condominial ........... R$ 500,00   │
│    Fundo Reserva .............. R$ 150,00   │
│    Rateio Água ................ R$ 80,00    │
│    Desconto ................... -R$ 20,00   │
│    TOTAL ...................... R$ 750,00   │
│                                             │
│  ▼ Leituras (Água/Gás)                      │
│    Leitura Água: 1250 m³                    │
│    Consumo: 45 m³                           │
│                                             │
│  ▼ Balancete Online                         │
│    Saldo em aberto: R$ 1.200,00             │
│    Data de Atualização: 01/03/2025          │
│                                             │
│  ▼ Demonstrativo Financeiro                 │
│    Total a Pagar: R$ 2.500,00               │
│    Já Pago: R$ 1.500,00                     │
│    Saldo: R$ 1.000,00                       │
│                                             │
│  ▼ Ações                                    │
│    [👁️ Ver PDF] [📋 Copiar Código]         │
│    [✉️ Compartilhar]                        │
└─────────────────────────────────────────────┘
```

### Widget: BoletoCardWidget

**Localização:** `ui/widgets/boleto_card_widget.dart`

Card individual que representa um boleto na lista.

**Estados:**

1. **Collapsed (Retraído):**
   ```
   ┌──────────────────────────────────────┐
   │ 15/03/2025 | R$ 750,00 | Mensal      │
   │ Status: Pago ✓                        │
   │ [Expandir ▼]                          │
   └──────────────────────────────────────┘
   ```

2. **Expanded (Expandido):**
   ```
   ┌──────────────────────────────────────┐
   │ 15/03/2025 | R$ 750,00 | Mensal      │
   │ Status: Pago ✓                        │
   │                                       │
   │ Bloco/Unidade: Bloco A - Apto 101    │
   │ Tipo: Mensal                          │
   │ Data Vencimento: 15/03/2025           │
   │ Data Pagamento: 14/03/2025            │
   │                                       │
   │ ▼ COMPOSIÇÃO                          │
   │   Cota Cond.: R$ 500,00               │
   │   Fundo Res.: R$ 150,00               │
   │   Rateio Água: R$ 80,00               │
   │   Desconto: -R$ 20,00                 │
   │   TOTAL: R$ 750,00                    │
   │                                       │
   │ [👁️ Ver] [📋 Copiar] [✉️ Compartilhar]│
   │ [🔄 Sincronizar] [🗑️ Excluir]        │
   └──────────────────────────────────────┘
   ```

**Ações Disponíveis:**
- 👁️ **Ver PDF** — Abre a URL do PDF no navegador via `url_launcher`
- 📋 **Copiar Código** — Copia o código de barras para a área de transferência
- ✉️ **Compartilhar** — Abre o share nativo com informações do boleto
- 🔄 **Sincronizar** — Sincroniza com ASAAS se ainda não tem registro
- 🗑️ **Excluir** — Remove boleto da listagem (apenas representante)

### Widget: BoletoFiltroDropdown

**Localização:** `ui/widgets/boleto_filtro_dropdown.dart`

Dropdown para filtrar boletos por status.

```
┌──────────────────────────────────────────┐
│  [ ▼ Vencidos/A Vencer ]                 │
│    → Vencidos/A Vencer (Ativo)           │
│    → Pagos                               │
└──────────────────────────────────────────┘
```

**Lógica:**
- `filtroSelecionado == 'Vencido/ A Vencer'` → Filtra boletos onde `status != 'Pago'`
- `filtroSelecionado == 'Pago'` → Filtra boletos onde `status == 'Pago'`

---

## Gerenciamento de Estado (Cubit)

### BoletoPropCubit

**Localização:** `ui/cubit/boleto_prop_cubit.dart`

Responsável por toda a lógica de estado da feature Boleto para Proprietário/Inquilino.

**Dependências Injetadas:**

```dart
BoletoPropCubit({
  required ObterBoletosPropUseCase obterBoletos,
  required ObterComposicaoBoletoUseCase obterComposicao,
  required ObterDemonstrativoFinanceiroUseCase obterDemonstrativo,
  required ObterLeiturasUseCase obterLeituras,
  required ObterBalanceteOnlineUseCase obterBalanceteOnline,
  required SincronizarBoletoUseCase sincronizarBoleto,
  required String moradorId,
  required String condominioId,
})
```

**Métodos Principais:**

#### 1. Carregamento Inicial

```dart
/// Carrega lista de boletos do morador
Future<void> carregarBoletos() async {
  emit(state.copyWith(status: BoletoPropStatus.loading));
  try {
    final boletos = await _obterBoletos.call(
      moradorId: moradorId,
      filtroStatus: state.filtroSelecionado,
    );
    emit(state.copyWith(status: BoletoPropStatus.success, boletos: boletos));
  } catch (e) {
    emit(state.copyWith(
      status: BoletoPropStatus.error,
      errorMessage: e.toString(),
    ));
  }
}
```

#### 2. Filtros e Busca

```dart
/// Alterna entre filtros de status
void alterarFiltro(String novoFiltro) {
  emit(state.copyWith(filtroSelecionado: novoFiltro));
  carregarBoletos(); // Recarregar com novo filtro
}
```

#### 3. Navegação de Mês/Ano

```dart
/// Avança para o mês anterior
void mesPosterior() {
  int mes = state.mesSelecionado - 1;
  int ano = state.anoSelecionado;
  if (mes < 1) {
    mes = 12;
    ano--;
  }
  emit(state.copyWith(mesSelecionado: mes, anoSelecionado: ano));
  carregarDemonstrativoFinanceiro();
  carregarBalanceteOnline();
}

/// Avança para o próximo mês
void proximoMes() {
  int mes = state.mesSelecionado + 1;
  int ano = state.anoSelecionado;
  if (mes > 12) {
    mes = 1;
    ano++;
  }
  emit(state.copyWith(mesSelecionado: mes, anoSelecionado: ano));
  carregarDemonstrativoFinanceiro();
  carregarBalanceteOnline();
}
```

#### 4. Expansão de Cards

```dart
/// Expande/Colapsa um boleto
void expandirBoleto(String boletoId) {
  final isExpanded = state.boletoExpandidoId == boletoId;
  emit(state.copyWith(
    boletoExpandidoId: isExpanded ? null : boletoId,
  ));
}
```

#### 5. Seções Expansíveis

```dart
/// Define se a seção de composição está expandida
void toggleComposicaoBoleto() async {
  final wasExpanded = state.composicaoBoletoExpandida;
  emit(state.copyWith(composicaoBoletoExpandida: !wasExpanded));
  
  if (!wasExpanded && state.boletoExpandidoId != null) {
    try {
      final composicao = await _obterComposicao(state.boletoExpandidoId!);
      emit(state.copyWith(composicaoBoleto: composicao));
    } catch (e) {
      print('Erro ao carregar composição: $e');
    }
  }
}

void toggleLeituras() {
  emit(state.copyWith(leiturasExpandida: !state.leiturasExpandida));
}

void toggleBalanceteOnline() {
  emit(state.copyWith(balanceteOnlineExpandido: !state.balanceteOnlineExpandido));
}
```

#### 6. Ações do Boleto

```dart
/// Abre o PDF do boleto no navegador
Future<void> verBoleto(String boletoId) async {
  try {
    final boleto = state.boletos.firstWhere((b) => b.id == boletoId);
    if (boleto.bankSlipUrl != null && boleto.bankSlipUrl!.isNotEmpty) {
      final uri = Uri.parse(boleto.bankSlipUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  } catch (e) {
    emit(state.copyWith(errorMessage: 'Erro ao abrir boleto: $e'));
  }
}

/// Copia o código de barras para a área de transferência
Future<void> copiarCodigoBarras(String boletoId) async {
  try {
    final boleto = state.boletos.firstWhere((b) => b.id == boletoId);
    final codigo = boleto.identificationField ?? boleto.barCode;
    if (codigo != null && codigo.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: codigo));
      emit(state.copyWith(successMessage: 'Código copiado!'));
    }
  } catch (e) {
    emit(state.copyWith(errorMessage: 'Erro ao copiar código: $e'));
  }
}

/// Compartilha informações do boleto
Future<void> compartilharBoleto(String boletoId) async {
  try {
    final boleto = state.boletos.firstWhere((b) => b.id == boletoId);
    final texto = '''
Boleto do Condomínio
Vencimento: ${boleto.dataVencimento}
Valor: R\$ ${boleto.valor.toStringAsFixed(2)}
Código: ${boleto.identificationField ?? boleto.barCode}
''';
    await Share.share(texto);
  } catch (e) {
    emit(state.copyWith(errorMessage: 'Erro ao compartilhar: $e'));
  }
}

/// Sincroniza boleto com ASAAS (gera PDF e código)
Future<void> sincronizarBoleto(String boletoId) async {
  try {
    emit(state.copyWith(status: BoletoPropStatus.loading));
    final codigo = await _sincronizarBoleto(boletoId);
    emit(state.copyWith(
      status: BoletoPropStatus.success,
      successMessage: 'Boleto sincronizado!',
    ));
  } catch (e) {
    emit(state.copyWith(
      status: BoletoPropStatus.error,
      errorMessage: 'Erro ao sincronizar: $e',
    ));
  }
}
```

### BoletoPropState

**Localização:** `ui/cubit/boleto_prop_state.dart`

Estado imutável que armazena todo estado da feature.

```dart
enum BoletoPropStatus { initial, loading, success, error }

class BoletoPropState extends Equatable {
  final BoletoPropStatus status;             // Status da requisição
  final List<BoletoPropEntity> boletos;      // Lista completa de boletos
  final String filtroSelecionado;            // Filtro ativo
  final String? boletoExpandidoId;           // ID do boleto expandido
  
  final int mesSelecionado;                  // Mês do demonstrativo
  final int anoSelecionado;                  // Ano do demonstrativo
  
  final bool composicaoBoletoExpandida;      // Seção expandida?
  final bool leiturasExpandida;
  final bool balanceteOnlineExpandido;
  
  final Map<String, double>? composicaoBoleto;          // Composição carregada
  final Map<String, dynamic>? demonstrativoFinanceiro;  // Demonstrativo
  final List<Map<String, dynamic>>? leituras;           // Leituras
  final Map<String, dynamic>? balanceteOnline;          // Balancete
  
  final String? errorMessage;                // Mensagem de erro
  final String? successMessage;              // Mensagem de sucesso
  
  /// Getter que filtra boletos conforme o filtro selecionado
  List<BoletoPropEntity> get boletosFiltrados {
    if (filtroSelecionado == 'Pago') {
      return boletos.where((b) => b.status == 'Pago').toList();
    }
    return boletos.where((b) => b.status != 'Pago').toList();
  }
}
```

---

## Casos de Uso (Use Cases)

**Localização:** `domain/usecases/boleto_prop_usecases.dart`

Use cases encapsulam a lógica de negócio e são chamados pelo Cubit.

### 1. ObterBoletosPropUseCase

```dart
class ObterBoletosPropUseCase {
  final BoletoPropRepository repository;
  
  ObterBoletosPropUseCase({required this.repository});
  
  Future<List<BoletoPropEntity>> call({
    required String moradorId,
    String? filtroStatus,  // 'Vencido/A Vencer', 'Pago', null
  }) {
    return repository.obterBoletos(
      moradorId: moradorId,
      filtroStatus: filtroStatus,
    );
  }
}
```

**Regra de Negócio:**
- Retorna apenas boletos do morador logado (`moradorId`)
- Filtra por status se `filtroStatus` for informado
- Ordena por `dataVencimento` decrescente

### 2. ObterComposicaoBoletoUseCase

```dart
class ObterComposicaoBoletoUseCase {
  final BoletoPropRepository repository;
  
  Future<Map<String, double>> call(String boletoId) {
    return repository.obterComposicaoBoleto(boletoId);
  }
}
```

**Retorna mapa com:**
- `cotaCondominial`
- `fundoReserva`
- `rateioAgua`
- `multaInfracao`
- `controle`
- `desconto`
- `valorTotal`

### 3. ObterDemonstrativoFinanceiroUseCase

```dart
class ObterDemonstrativoFinanceiroUseCase {
  final BoletoPropRepository repository;
  
  Future<Map<String, dynamic>> call({
    required String moradorId,
    required int mes,
    required int ano,
  }) {
    return repository.obterDemonstrativoFinanceiro(
      moradorId: moradorId,
      mes: mes,
      ano: ano,
    );
  }
}
```

**Retorna:**
```dart
{
  'totalValor': 1250.50,        // Total de boletos no período
  'totalPago': 750.00,          // Total já pago
  'totalEmAberto': 500.50,      // Ainda a pagar
  'quantidadeBoletos': 3,
  'quantidadePagos': 2,
  'quantidadeEmAberto': 1,
}
```

### 4. ObterLeiturasUseCase

```dart
class ObterLeiturasUseCase {
  final BoletoPropRepository repository;
  
  Future<List<Map<String, dynamic>>> call({
    required String unidadeId,
    required int mes,
    required int ano,
  }) {
    return repository.obterLeituras(
      unidadeId: unidadeId,
      mes: mes,
      ano: ano,
    );
  }
}
```

Retorna leituras de água, gás, etc. do período.

### 5. ObterBalanceteOnlineUseCase

```dart
class ObterBalanceteOnlineUseCase {
  final BoletoPropRepository repository;
  
  Future<Map<String, dynamic>> call({
    required String condominioId,
    required int mes,
    required int ano,
  }) {
    return repository.obterBalanceteOnline(
      condominioId: condominioId,
      mes: mes,
      ano: ano,
    );
  }
}
```

Retorna balancete atualizado do condomínio.

### 6. SincronizarBoletoUseCase

```dart
class SincronizarBoletoUseCase {
  final BoletoPropRepository repository;
  
  Future<String> call(String boletoId) {
    return repository.sincronizarBoleto(boletoId);
  }
}
```

**Fluxo:**
1. Verifica se boleto já tem `asaas_payment_id`
2. Se NÃO, registra no ASAAS via backend
3. Retorna o código de barras (linha digitável)

---

## Integração com ASAAS (Gateway de Pagamento)

### O que é ASAAS?

ASAAS é um gateway de pagamento brasileiro que permite:
- ✅ Criar e gerenciar boletos
- ✅ Processar cobranças
- ✅ Receber pagamentos
- ✅ Notificar via webhooks

### Fluxo de Integração

```
┌─────────────────────────────────────────────┐
│  APLICATIVO (Flutter/Frontend)              │
│  • Interface do usuário                     │
│  • Exibição de boletos                      │
└────────────────┬────────────────────────────┘
                 ↓
    Usuário clica "Ver/Copiar Boleto"
                 ↓
┌─────────────────────────────────────────────┐
│  BACKEND (Laravel)                          │
│  • AsaasService.php                         │
│  • AsaasWebhookHandler.php                  │
└────────────────┬────────────────────────────┘
                 ↓
    POST /asaas/boletos/registrar-individual
                 ↓
┌─────────────────────────────────────────────┐
│  ASAAS API (Serviço Externo)                │
│  https://api.asaas.com/v3/...               │
│  • POST /payments (criar boleto)             │
│  • GET /payments/:id (buscar)                │
│  • POST /webhook (receber notificações)      │
└────────────────┬────────────────────────────┘
                 ↓
    Retorna: payment_id, bankSlipUrl, barCode
                 ↓
┌─────────────────────────────────────────────┐
│  BANCO DE DADOS (Supabase)                  │
│  UPDATE boletos SET                         │
│    asaas_payment_id = payment_id,          │
│    bank_slip_url = bankSlipUrl,            │
│    bar_code = barCode                      │
└─────────────────────────────────────────────┘
```

### Campos ASAAS no Boleto

| Campo | Tipo | Descrição | Exemplo |
|-------|------|-----------|---------|
| `asaas_payment_id` | String | ID único no ASAAS | `pay_xg754jui2hj928` |
| `bank_slip_url` | String | URL do PDF do boleto | `https://asaas.blob/boletos/...pdf` |
| `bar_code` | String | Código de barras simples | `12345 67890 12345 67890 ...` |
| `identification_field` | String | Linha digitável (47 dígitos) | `12345.67890 12345.678901 ...` |
| `invoice_url` | String | URL da fatura/nota | `https://...` |

### Backend — AsaasService

**Localização:** `Backend/app/Asaas/AsaasService.php`

Serviço que encapsula toda a comunicação com ASAAS.

```php
class AsaasService {
  private string $apiKey;
  private string $baseUrl = 'https://api.asaas.com/v3';
  
  public function __construct() {
    $this->apiKey = config('asaas.api_key');
  }
  
  /**
   * Registra um boleto no ASAAS
   */
  public function registrarBoleto(array $dados) {
    // Dados esperados:
    // - customer_name, customer_email, customer_cpf
    // - due_date, value, description
    // - discount, interest, fine, etc.
    
    return $this->post('/payments', $dados);
  }
  
  /**
   * Busca detalhes de um pagamento
   */
  public function buscarPagamento(string $paymentId) {
    return $this->get("/payments/{$paymentId}");
  }
  
  /**
   * Lista todos os pagamentos
   */
  public function listarPagamentos(array $filtros = []) {
    return $this->get('/payments', $filtros);
  }
  
  /**
   * Atualiza um pagamento
   */
  public function atualizarPagamento(string $paymentId, array $dados) {
    return $this->patch("/payments/{$paymentId}", $dados);
  }
  
  private function post(string $endpoint, array $dados) {
    // Fazer requisição POST à API ASAAS
  }
  
  private function get(string $endpoint, array $filtros = []) {
    // Fazer requisição GET à API ASAAS
  }
  
  private function patch(string $endpoint, array $dados) {
    // Fazer requisição PATCH à API ASAAS
  }
}
```

---

## Sincronização e Webhooks

### Webhook ASAAS → Backend

**URL Endpoint:** `/api/asaas/webhook`

Quando um pagamento é confirmado/rejeitado/cancelado no ASAAS, ele notifica automaticamente nosso backend.

**Handler:** `Backend/app/Http/Controllers/AsaasWebhookHandler.php`

```php
class AsaasWebhookHandler {
  
  /**
   * Processa webhook do ASAAS
   */
  public function handle(Request $request) {
    $event = $request->input('event');
    $data = $request->input('data');
    
    return match($event) {
      'PAYMENT_CREATED' => $this->onPaymentCreated($data),
      'PAYMENT_CONFIRMED' => $this->onPaymentConfirmed($data),
      'PAYMENT_RECEIVED' => $this->onPaymentReceived($data),
      'PAYMENT_OVERDUE' => $this->onPaymentOverdue($data),
      'PAYMENT_DELETED' => $this->onPaymentDeleted($data),
      'PAYMENT_REFUNDED' => $this->onPaymentRefunded($data),
      default => response()->json(['status' => 'unknown_event'], 400),
    };
  }
  
  /**
   * Pagamento confirmado/recebido
   */
  private function onPaymentReceived(array $payment) {
    // 1. Encontrar o boleto pelo asaas_payment_id
    $boleto = Boleto::where('asaas_payment_id', $payment['id'])->first();
    
    if ($boleto) {
      // 2. Atualizar status para PAGO
      $boleto->update([
        'status' => 'Pago',
        'data_pagamento' => $payment['confirmedDate'],
        'valor_pago' => $payment['value'],
        'valor_liquido' => $payment['netValue'],
      ]);
      
      // 3. (BÔNUS) Disparar email de confirmação via Resend
      // Mail::send(new BolotoPagoNotification($boleto));
      
      // 4. Log
      Log::info('Boleto pago via ASAAS', ['boleto_id' => $boleto->id]);
    }
    
    return response()->json(['status' => 'ok']);
  }
  
  /**
   * Pagamento atrasado
   */
  private function onPaymentOverdue(array $payment) {
    $boleto = Boleto::where('asaas_payment_id', $payment['id'])->first();
    
    if ($boleto) {
      $boleto->update([
        'status' => 'Atrasado', // ou 'Vencido'
      ]);
      
      // (BÔNUS) Enviar alerta ao morador
      // Notification::send($boleto->morador, new BoletoAtrasadoNotification($boleto));
    }
    
    return response()->json(['status' => 'ok']);
  }
  
  /**
   * Pagamento deletado/cancelado
   */
  private function onPaymentDeleted(array $payment) {
    $boleto = Boleto::where('asaas_payment_id', $payment['id'])->first();
    
    if ($boleto) {
      $boleto->update([
        'status' => 'Cancelado',
      ]);
    }
    
    return response()->json(['status' => 'ok']);
  }
  
  /**
   * Pagamento reembolsado
   */
  private function onPaymentRefunded(array $payment) {
    $boleto = Boleto::where('asaas_payment_id', $payment['id'])->first();
    
    if ($boleto) {
      $boleto->update([
        'status' => 'Estornado',
        'data_pagamento' => null, // Limpar data de pagamento
      ]);
    }
    
    return response()->json(['status' => 'ok']);
  }
}
```

### Mapeamento de Status

| Evento ASAAS | Status no CondoGaia | Ação |
|-------------|----------------|------|
| `PAYMENT_CREATED` | Ativo (Pendente) | Apenas log (boleto já existe) |
| `PAYMENT_CONFIRMED` | Pago ✓ | Atualizar `data_pagamento`, `status` |
| `PAYMENT_RECEIVED` | Pago ✓ | Idem + enviar email confirmação |
| `PAYMENT_OVERDUE` | Atrasado/Vencido | Marcar como atrasado, notificar morador |
| `PAYMENT_DELETED` | Cancelado | Cancelar na base |
| `PAYMENT_REFUNDED` | Estornado | Marcar como estornado |

---

## Funcionalidades Principais

### 1. Visualizar Lista de Boletos

**Fluxo:**

```
User abre BoletoPropScreen
     ↓
Cubit chama carregarBoletos()
     ↓
Use Case consulta Repository
     ↓
DataSource faz query Supabase:
  SELECT * FROM boletos
  WHERE sacado = moradorId
  ORDER BY data_vencimento DESC
     ↓
Parse JSON → Models → Entities
     ↓
Cubit emite estado com lista
     ↓
UI constrói BoletoCards para cada item
```

**Filtros aplicados:**
- Por morador logado (`sacado` = `moradorId`)
- Por status (Ativo/Pago)
- Opção: Por período (mês/ano)

### 2. Expandir Boleto e Ver Detalhes

**Ações ao expandir:**

1. Exibir composição detalhada
2. Carregar leituras (água, gás) se disponível
3. Mostrar botões de ação (Ver, Copiar, Compartilhar)

**Widget afetado:** `BoletoCardWidget`

### 3. Copiar Código de Barras

**Implementação:**

```dart
Future<void> copiarCodigoBarras(String boletoId) async {
  try {
    final boleto = state.boletos.firstWhere((b) => b.id == boletoId);
    
    // Tentar copiar linha digitável primeiro; se não existir, copiar código simples
    final codigo = boleto.identificationField ?? boleto.barCode ?? '';
    
    if (codigo.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: codigo));
      emit(state.copyWith(
        successMessage: 'Código copiado para a área de transferência!'
      ));
    } else {
      emit(state.copyWith(
        errorMessage: 'Código de barras não disponível'
      ));
    }
  } catch (e) {
    emit(state.copyWith(errorMessage: 'Erro ao copiar: $e'));
  }
}
```

**Resultado:**
- Código copiado para clipboard do celular
- Usuário pode colar no app do seu banco
- SnackBar exibindo confirmação

### 4. Visualizar PDF do Boleto

**Fluxo:**

```
User clica "Ver PDF"
     ↓
Cubit verifica se bankSlipUrl existe
     ↓
Se NÃO → Chamar sincronizarBoleto()
     ↓
Se SIM → Chamar url_launcher.launchUrl()
     ↓
Abre PDF em app visualizador/navegador
```

**Implementação:**

```dart
Future<void> verBoleto(String boletoId) async {
  try {
    final boleto = state.boletos.firstWhere((b) => b.id == boletoId);
    
    if (boleto.bankSlipUrl != null && boleto.bankSlipUrl!.isNotEmpty) {
      final uri = Uri.parse(boleto.bankSlipUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      emit(state.copyWith(
        errorMessage: 'PDF do boleto não disponível. Sincronizando...'
      ));
      // Chamar sincronizarBoleto() primeiro
    }
  } catch (e) {
    emit(state.copyWith(errorMessage: 'Erro ao abrir boleto: $e'));
  }
}
```

### 5. Compartilhar Boleto

**Status:** ⏳ Em desenvolvimento (TODO comentado no planejamento)

**Implementação prevista:**

```dart
Future<void> compartilharBoleto(String boletoId) async {
  try {
    final boleto = state.boletos.firstWhere((b) => b.id == boletoId);
    
    final texto = '''
🏢 Informações do Boleto - CondoGaia
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Unidade: ${boleto.blocoUnidade}
📅 Vencimento: ${DateFormat('dd/MM/yyyy').format(boleto.dataVencimento)}
💰 Valor: R\$ ${boleto.valorTotal.toStringAsFixed(2)}
📋 Tipo: ${boleto.tipo}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📌 CÓDIGO DE BARRAS:
${boleto.identificationField ?? boleto.barCode ?? 'Não disponível'}

✉️ Compartilhado via CondoGaia
    ''';
    
    await Share.share(
      texto,
      subject: 'Boleto do Condomínio - ${boleto.blocoUnidade}',
    );
  } catch (e) {
    emit(state.copyWith(errorMessage: 'Erro ao compartilhar: $e'));
  }
}
```

**Fluxo:**
1. Formata texto com informações do boleto
2. Abre share sheet nativo
3. Usuário escolhe app para compartilhar (WhatsApp, Email, etc.)

### 6. Sincronizar com ASAAS

**Objetivo:** Registrar boleto no ASAAS e obter PDF + código de barras

**Fluxo:**

```
User clica "Sincronizar" ou "Ver PDF" (sem URL)
     ↓
Cubit chama sincronizarBoleto(boletoId)
     ↓
Use Case executa SincronizarBoletoUseCase
     ↓
Repository chama RemoteDataSource.sincronizarBoleto()
     ↓
┌─────────────────────────────────────────┐
│  DataSource executa sincronização:      │
│                                         │
│  1. Buscar boleto no Supabase           │
│  2. Verificar se tem asaas_payment_id   │
│     ├─ SIM → Pular para paso 4          │
│     └─ NÃO → Ir para passo 3            │
│  3. Chamar backend:                     │
│     POST /asaas/boletos/registrar       │
│       Backend chama ASAAS API           │
│       Retorna payment_id                │
│  4. Chamar backend para obter código:   │
│     GET /asaas/boletos/{id}/codigo     │
│  5. Retornar código/PDF para Frontend   │
└────────────────────┬────────────────────┘
     ↓
Update no Supabase:
  asaas_payment_id = nova_id
  bank_slip_url = novo_url
  bar_code = novo_codigo
     ↓
Cubit emite successMessage
     ↓
UI atualiza exibindo PDF/código
```

**Implementação:**

```dart
Future<void> sincronizarBoleto(String boletoId) async {
  emit(state.copyWith(status: BoletoPropStatus.loading));
  try {
    final codigo = await _sincronizarBoleto.call(boletoId);
    
    emit(state.copyWith(
      status: BoletoPropStatus.success,
      successMessage: 'Boleto sincronizado com sucesso!',
    ));
    
    // Recarregar dados para exibir nova URL
    await carregarBoletos();
  } catch (e) {
    emit(state.copyWith(
      status: BoletoPropStatus.error,
      errorMessage: 'Erro ao sincronizar boleto: $e',
    ));
  }
}
```

### 7. Filtrar e Buscar

**Filtros disponíveis:**

1. **Por Status:**
   - "Vencidos/A Vencer" (status != 'Pago')
   - "Pagos" (status == 'Pago')

2. **Por Período (Demonstrativo):**
   - Seletor Mês/Ano anterior/próximo
   - Carrega dados do mês selecionado

**Implementação:**

```dart
void alterarFiltro(String novoFiltro) {
  emit(state.copyWith(filtroSelecionado: novoFiltro));
  carregarBoletos(); // Recarregar com novo filtro
}

// No State, getter de boletos filtrados:
List<BoletoPropEntity> get boletosFiltrados {
  if (filtroSelecionado == 'Pago') {
    return boletos.where((b) => b.status == 'Pago').toList();
  }
  // 'Vencido/ A Vencer' → Não pagos
  return boletos.where((b) => b.status != 'Pago').toList();
}
```

### 8. Ver Demonstrativo Financeiro

**Dados exibidos:**

```
┌─────────────────────────────────────┐
│  Demonstrativo - Março 2025         │
├─────────────────────────────────────┤
│  Total Boletos: 3                   │
│  Total Valor:     R$ 2.250,00       │
│  Total Pago:      R$ 1.500,00 ✓     │
│  Saldo Em Aberto: R$  750,00        │
│                                     │
│  Boletos Pagos:      2 ✓            │
│  Boletos Pendentes:  1              │
└─────────────────────────────────────┘
```

**Implementação:**

```dart
Future<void> carregarDemonstrativoFinanceiro() async {
  try {
    final demonstrativo = await _obterDemonstrativo(
      moradorId: moradorId,
      mes: state.mesSelecionado,
      ano: state.anoSelecionado,
    );
    
    emit(state.copyWith(
      status: BoletoPropStatus.success,
      demonstrativoFinanceiro: demonstrativo,
    ));
  } catch (e) {
    emit(state.copyWith(
      status: BoletoPropStatus.error,
      errorMessage: 'Erro ao carregar demonstrativo: $e',
    ));
  }
}
```

---

## Estados e Transições

### Diagrama de Estados do Cubit

```
┌──────────────┐
│   INITIAL    │ (Tela não carregou ainda)
└──────┬───────┘
       │ User entra na tela
       ↓
┌──────────────┐
│   LOADING    │ (Buscando dados no Supabase)
└──────┬───────┘
       │
       ├──→ SUCCESS → (Dados carregados)
       │
       └──→ ERROR → (Erro na requisição)
           ↓
       Exibir mensagem de erro
```

### Transições de Estado do Boleto

```
CRIAÇÃO
   ↓
ATIVO (Pendente Pagamento)
   ├─→ PAGO ✓ (via ASAAS Webhook)
   │    ↓
   │   (Final - não pode voltar)
   │
   ├─→ VENCIDO (Data passou)
   │    ├─→ PAGO (com juros/multas)
   │    └─→ CANCELADO
   │
   └─→ CANCELADO (Síndico anuLou)
        └─→ CANCELADO POR ACORDO (Parcelado)

ESTADO FINAL: PAGO | CANCELADO | ESTORNADO
```

---

## Endpoints e APIs

### Frontend → Backend

**Base URL:** `http://backend.api/api`

#### 1. Registrar Boleto no ASAAS

```
POST /asaas/boletos/registrar-individual

Request:
{
  "boletoId": "uuid-do-boleto"
}

Response (Sucesso - 200/201):
{
  "success": true,
  "data": {
    "paymentId": "pay_xg754jui2hj",
    "boleto": {
      "id": "uuid-boleto",
      "identification_field": "12345.67890...",
      "bar_code": "123456789...",
      "bank_slip_url": "https://...",
      ...
    }
  }
}

Response (Erro - 400/500):
{
  "success": false,
  "message": "Erro ao registrar boleto"
}
```

#### 2. Obter Código de Barras

```
GET /asaas/boletos/{asaasPaymentId}/linha-digitavel

Response (Sucesso):
{
  "success": true,
  "data": {
    "identificationField": "12345.67890...",
    "barCode": "123456789..."
  }
}
```

### Frontend → Supabase (Direto)

#### 1. Obter Boletos do Morador

```dart
var query = _supabase
    .from('boletos')
    .select('*')
    .eq('sacado', moradorId);

if (filtroStatus == 'Vencido/ A Vencer') {
  query = query.not('status', 'eq', 'Pago');
} else if (filtroStatus == 'Pago') {
  query = query.eq('status', 'Pago');
}

final response = await query.order('data_vencimento', ascending: false);
```

#### 2. Obter Composição do Boleto

```dart
final response = await _supabase
    .from('boletos')
    .select('''
      cota_condominial,
      fundo_reserva,
      rateio_agua,
      multa_infracao,
      controle,
      desconto,
      valor_total
    ''')
    .eq('id', boletoId)
    .maybeSingle();
```

#### 3. Obter Demonstrativo Financeiro

```dart
// Buscar todos os boletos do morador para o mês/ano
var query = _supabase
    .from('boletos')
    .select('valor, status, data_vencimento')
    .eq('sacado', moradorId)
    .gte('data_vencimento', DateTime(ano, mes, 1).toIso8601String())
    .lte('data_vencimento', DateTime(ano, mes + 1, 0).toIso8601String());

final response = await query;

// Parse e cálculo:
final totalValor = response.fold<double>(0, (sum, b) => sum + b['valor']);
final totalPago = response
    .where((b) => b['status'] == 'Pago')
    .fold<double>(0, (sum, b) => sum + b['valor']);
```

---

## Testes e Validações

### Testes Unitários (Planejado)

**Localização:** `test/`

```dart
// test_boleto_prop_cubit.dart
void main() {
  group('BoletoPropCubit', () {
    test('carregarBoletos emite estados corretos', () async {
      // Arrange
      final mockRepository = MockBoletoPropRepository();
      when(mockRepository.obterBoletos(...))
          .thenAnswer((_) async => [boleto1, boleto2]);
      
      final cubit = BoletoPropCubit(...);
      
      // Act
      cubit.carregarBoletos();
      
      // Assert
      expect(
        cubit.stream,
        emitsInOrder([
          BoletoPropStatus.loading,
          BoletoPropStatus.success,
        ]),
      );
    });
    
    test('alterarFiltro filtra boletos corretamente', () {
      final cubit = BoletoPropCubit(...);
      cubit.emit(state.copyWith(boletos: [boleto1, boleto2, boleto3]));
      
      cubit.alterarFiltro('Pago');
      
      expect(cubit.state.boletosFiltrados.length, 1); // Apenas 1 pago
    });
  });
}
```

### Validações de Negócio

**No Cubit:**

```dart
/// Valida antes de copiar código
if (codigo.isEmpty) {
  emit(state.copyWith(
    errorMessage: 'Código de barras não disponível'
  ));
  return;
}

/// Valida se data é futura para abrir "Ver PDF"
if (boleto.dataVencimento.isBefore(DateTime.now())) {
  // OK, pode exibir (mesmo vencido)
}
```

**No DataSource:**

```dart
/// Valida resposta do ASAAS
if (response.statusCode != 200 && response.statusCode != 201) {
  final error = jsonDecode(response.body);
  throw Exception(error['message'] ?? 'Erro ao registrar boleto');
}
```

---

## Próximas Funcionalidades

### ✅ Fases Concluídas

- [x] **Fase 1** — Navegação e estrutura de pastas
- [x] **Fase 2** — Entities e Models completos
- [x] **Fase 3** — DataSource com Supabase real
- [x] **Fase 4** — Use Cases e injeção de dependência

### 🏃 Fases em Desenvolvimento

- [ ] **Fase 5** — UI: Ações de boleto
  - [x] Ver PDF (`url_launcher`)
  - [x] Copiar código de barras (`Clipboard`)
  - [ ] Compartilhar boleto (`share_plus`)

### 📋 Backlog Futuro

1. **Integração Completa com ASAAS**
   - [ ] Webhook automático de pagamentos
   - [ ] Atualização de status em tempo real
   - [ ] Notificações por email (Resend)
   - [ ] Alertas de atraso

2. **Filtros Avançados**
   - [ ] Filtro por período customizado
   - [ ] Filtro por valor
   - [ ] Busca por número de boleto
   - [ ] Busca por unidade

3. **Relatórios**
   - [ ] PDF com histórico de pagamentos
   - [ ] Gráficos de evolução de débitos
   - [ ] Comprovante de pagamento

4. **Funcionalidades para Representante**
   - [ ] Gerar/emitir boletos avulsos
   - [ ] Parcelar débitos
   - [ ] Registrar pagamentos manualmente
   - [ ] Enviar boleto por email (Resend)
   - [ ] Cancelar/ajustar boletos

5. **Performance**
   - [ ] Paginação na lista de boletos
   - [ ] Cache local (drift/sqflite)
   - [ ] Sincronização offline-first

6. **Acessibilidade**
   - [ ] Suporte a temas escuros
   - [ ] Melhoria na contrastação
   - [ ] Suporte a leitura de tela (screen reader)

---

## Glossário

| Termo | Definição |
|-------|-----------|
| **Boleto** | Documento de cobrança bancário brasileiro |
| **Linha Digitável** | Sequência de 47 dígitos do boleto para pagamento |
| **Código de Barras** | Código visual representando os dados do boleto |
| **Sacado** | Quem deve pagar (morador) |
| **ASAAS** | Gateway de pagamento utilizado |
| **Webhook** | Notificação automática de eventos |
| **PDF do Boleto** | Documento visual imprimível |
| **Composição** | Detalhamento dos itens que compõem o valor |
| **Demonstrativo** | Resumo financeiro de um período |
| **Balancete** | Extrato financeiro do condomínio |
| **Sincronização** | Atualização de dados com sistema externo |
| **Vencido** | Boleto cuja data de pagamento passou |

---

## Referências

- [Diagrama de Arquitetura](../ARQUITETURA_EXPLICADA.md)
- [Planejamento de Implementação](../planejamentos/boleto_prop_inq_planejamento.md)
- [Plano de Webhooks ASAAS](../../Backend/ASAAS_WEBHOOK_PLANO.md)
- [Documentação Security](../agents/security.md)
- [Documentação de Estrutura Reserva](../ESTRUTURA_RESERVA_FINAL.md)

---

## Contato e Suporte

Para dúvidas ou sugestões sobre esta feature:

- **Repositório:** `/condogaiaapp/lib/features/Prop_Inq_Features/boleto/`
- **Backend:** `/Backend/app/`
- **Documentação:** Este arquivo e planejamentos relacionados

---

**Última atualização:** Março de 2026  
**Versão:** 1.0  
**Status:** Em Desenvolvimento

