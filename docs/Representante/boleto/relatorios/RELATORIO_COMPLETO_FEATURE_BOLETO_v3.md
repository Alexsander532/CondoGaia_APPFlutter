# 📋 Relatório Completo — Feature de Boleto do Representante

**Data:** 28/03/2026  
**Versão:** 3.0  
**Status:** Em desenvolvimento ativo  
**Última atualização:** 28/03/2026

---

## 1. Resumo Executivo

A feature de **Boleto** é o módulo central de cobrança financeira do sistema CondoGaia. Ela permite que o representante (síndico/administrador) gere, gerencie e acompanhe cobranças para os moradores do condomínio.

Atualmente, o sistema possui **duas formas de geração de boletos**:

| Tipo | Status | Descrição |
|---|---|---|
| **Cobrança Mensal** | ✅ Funcionando | Gera boletos mensais em lote para todas as unidades |
| **Cobrança Avulsa (Boleto Avulso)** | ✅ Funcionando | Gera boletos individuais para despesas extras |
| **Cobrança Avulsa (Junto à Taxa)** | ❌ Não implementado | Acumula despesas para o próximo boleto mensal |

---

## 2. Arquitetura do Sistema

### 2.1 Stack Tecnológica

```
┌──────────────────────────────────────────────────────────┐
│                    FRONTEND (Flutter)                     │
│  BoletoCubit / CobrancaAvulsaCubit → State Management    │
│  BoletoService → Lógica de negócio                       │
│  CobrancaAvulsaRepository → Chamadas à API               │
│  CobrancaAvulsaEmailService → Disparo de e-mails         │
└──────────────┬───────────────────┬───────────────────────┘
               │                   │
               ▼                   ▼
┌──────────────────────┐  ┌──────────────────────────────┐
│      SUPABASE        │  │      BACKEND (Laravel)       │
│  Banco de Dados      │  │  CobrancaController          │
│  Storage             │  │  CobrancaService             │
│  Auth                │  │  BoletoController            │
│                      │  │  BoletoAvulsoService         │
│  Tabelas:            │  │  BoletoService               │
│  - boletos           │  │  AsaasClientService          │
│  - unidades          │  │  CobrancaAvulsaEmailCtrl     │
│  - proprietarios     │  │  BoletoEmailController       │
│  - inquilinos        │  └──────────────┬───────────────┘
│  - moradores         │                 │
│  - config_financeira │                 ▼
│                      │  ┌──────────────────────────────┐
│                      │  │   INTEGRAÇÕES EXTERNAS       │
│                      │  │   - ASAAS (Gateway bancário)  │
│                      │  │   - Resend (E-mails)         │
│                      │  └──────────────────────────────┘
└──────────────────────┘
```

### 2.2 Estrutura de Diretórios

```
lib/features/Representante_Features/
├── boleto/
│   ├── cubit/
│   │   ├── boleto_cubit.dart         # Gerenciamento de estado principal
│   │   └── boleto_state.dart         # Definição dos estados
│   ├── screens/
│   │   └── boleto_screen.dart        # Tela principal de boletos
│   ├── services/
│   │   └── boleto_service.dart       # Serviço de integração (Supabase + API)
│   └── widgets/
│       ├── gerar_cobranca_mensal_dialog.dart  # Modal para cobrança mensal
│       ├── gerar_cobranca_avulsa_dialog.dart  # Modal para cobrança avulsa
│       └── selecionar_bloco_unid_dialog.dart  # Seletor de unidades
│
├── cobranca_avulsa/
│   ├── data/
│   │   ├── models/
│   │   │   └── cobranca_avulsa_model.dart     # Modelo de dados
│   │   └── repositories/
│   │       └── cobranca_avulsa_repository.dart # Repositório (API + Supabase)
│   ├── domain/
│   │   └── entities/
│   │       └── cobranca_avulsa_entity.dart     # Entidade de domínio
│   ├── services/
│   │   └── cobranca_avulsa_email_service.dart  # Serviço de e-mail
│   └── ui/
│       ├── cubit/
│       │   ├── cobranca_avulsa_cubit.dart      # Cubit da cobrança avulsa
│       │   └── cobranca_avulsa_state.dart      # Estados específicos
│       ├── screens/
│       │   └── cobranca_avulsa_screen.dart     # Tela com abas (Pesquisar/Cadastrar)
│       └── widgets/
│           ├── pesquisar_tab_widget.dart       # Aba de pesquisa
│           └── cadastrar_tab_widget.dart       # Aba de cadastro
│
Backend (Laravel)/
├── app/Asaas/
│   ├── Cobranca/
│   │   ├── CobrancaController.php    # Endpoints de cobrança
│   │   └── CobrancaService.php       # Integração com ASAAS Payments
│   ├── Boleto/
│   │   ├── BoletoController.php      # Endpoints de boleto
│   │   ├── BoletoService.php         # Geração mensal + registro
│   │   └── BoletoAvulsoService.php   # Geração avulsa em lote
│   ├── Client/
│   │   └── AsaasClientService.php    # Gestão de customers no ASAAS
│   └── Webhook/
│       └── AsaasWebhookHandler.php   # Sincronização automática
│
├── app/Resend/
│   ├── Boleto/
│   │   └── BoletoEmailController.php       # E-mail de boleto mensal
│   ├── Cobranca/
│   │   └── CobrancaEmailController.php     # E-mail de cobrança regular
│   └── CobrancaAvulsa/
│       └── CobrancaAvulsaEmailController.php # E-mail de cobrança avulsa
```

---

## 3. Integrações — Estado Atual

### 3.1 Integração com Supabase

**Status: ✅ Totalmente funcional**

| Operação | Tabela | Método | Status |
|---|---|---|---|
| Listar boletos por condomínio | `boletos` | SELECT com JOIN em `unidades` | ✅ |
| Filtrar por tipo (Mensal/Avulso) | `boletos` | WHERE tipo = 'Avulso' | ✅ |
| Inserir boleto (via backend) | `boletos` | INSERT (feito pelo Laravel) | ✅ |
| Excluir boleto | `boletos` | DELETE | ✅ |
| Upload de comprovante | Storage `cobrancas-avulsas` | UPLOAD + getPublicUrl | ✅ |
| Buscar unidades | `unidades` | SELECT | ✅ |
| Buscar configuração financeira | `config_financeira` | SELECT | ✅ |

**Tabela `boletos` — Campos utilizados no fluxo avulso:**
```sql
-- Campos preenchidos pelo BoletoAvulsoService no backend
condominio_id     UUID    -- FK para condominios
unidade_id        UUID    -- FK para unidades
valor             DECIMAL -- Valor base da cobrança
valor_total       DECIMAL -- Valor total (igual ao valor no avulso)
status            TEXT    -- 'Ativo', 'Registrado', 'Pago', etc.
tipo              TEXT    -- 'Avulso' ou 'Mensal'
classe            TEXT    -- Conta contábil (ex: 'agua', 'multa_infracao')
obs               TEXT    -- Descrição/observação
asaas_payment_id  TEXT    -- ID da cobrança no ASAAS
bank_slip_url     TEXT    -- URL do boleto PDF
identification_field TEXT -- Linha digitável
bar_code          TEXT    -- Código de barras
data_vencimento   DATE    -- Data de vencimento
referencia        TEXT    -- Mês/Ano de referência
boleto_registrado TEXT    -- 'SIM' ou 'NAO'
constar_relatorio TEXT    -- 'SIM' ou 'NAO'
```

### 3.2 Integração com ASAAS

**Status: ✅ Totalmente funcional**

O ASAAS é o gateway bancário utilizado para geração real dos boletos. A comunicação é feita exclusivamente via Backend Laravel → API ASAAS.

**Rotas da API utilizadas:**

| Rota Laravel | Método | O que faz |
|---|---|---|
| `POST /api/asaas/cobrancas/gerar-avulsa` | CobrancaController@gerarAvulsa | Gera boletos avulsos (com recorrência) |
| `POST /api/asaas/boletos/gerar-avulso` | BoletoController@gerarAvulso | Gera boletos avulsos em lote (via dialog) |
| `POST /api/asaas/boletos/gerar-mensal` | BoletoController@gerarMensal | Gera boletos mensais em lote |
| `GET /api/asaas/cobrancas/{id}/sincronizar` | CobrancaController@sincronizar | Sincroniza status ASAAS → Supabase |
| `GET /api/asaas/boletos/{id}/linha-digitavel` | BoletoController@linhaDigitavel | Obtém linha digitável |
| `GET /api/asaas/boletos/{id}/pdf` | BoletoController@pdf | Obtém URL do PDF do boleto |

**Fluxo de criação no ASAAS (BoletoAvulsoService):**
1. Recebe lista de moradores com nome e CPF
2. Para cada morador: `AsaasClientService::criarOuBuscar()` → garante customer no ASAAS
3. Cria payment via `CobrancaService::criar()` com `billingType = 'BOLETO'`
4. Tenta obter linha digitável com retry (2 tentativas, 1s de espera)
5. Salva resultado no Supabase (batch insert na tabela `boletos`)
6. Retorna contagem de sucessos/erros

**Fluxo alternativo via CobrancaService (rota `/cobrancas/gerar-avulsa`):**
1. Recebe `condominioId`, `unidades[]`, `valor`, `dataVencimento`
2. Busca morador de cada unidade no Supabase
3. Cria/busca customer no ASAAS
4. Suporta recorrência: gera N boletos com vencimentos incrementais
5. Salva cada boleto individualmente no Supabase

### 3.3 Integração com Resend (E-mail)

**Status: ✅ Funcional (melhor esforço)**

O envio de e-mails é feito pelo flutter via o `CobrancaAvulsaEmailService` que chama o backend Laravel → Resend.

**Rota utilizada:**
```
POST /api/resend/cobranca-avulsa/enviar
```

**Payload:**
```json
{
  "email": "morador@email.com",
  "nome": "João da Silva",
  "descricao": "Multa por infração - Art. 12",
  "valor": 500.00,
  "dataVencimento": "15/04/2026",
  "comprovanteUrl": "https://..." // opcional
}
```

**Comportamento:**
- O envio de e-mail **NÃO bloqueia** o fluxo principal
- Se falhar, o erro é logado mas a cobrança é gerada normalmente
- O `try/catch` no `CobrancaAvulsaEmailService` garante que falhas de e-mail são tratadas silenciosamente

---

## 4. Funcionalidades — O Que Consigo Fazer Hoje

### 4.1 ✅ Cobrança Mensal

| Funcionalidade | Status | Detalhes |
|---|---|---|
| Gerar boleto mensal para todas as unidades | ✅ | Via modal `GerarCobrancaMensalDialog` |
| Selecionar unidades específicas (Bloco/Unid) | ✅ | Via `SelecionarBlocoUnidDialog` |
| Pré-preencher valores da configuração financeira | ✅ | Cota, Fundo de Reserva, Desconto auto-calculados |
| Alertar se configuração financeira ausente | ✅ | Exibe warning + botão "Configurar agora" |
| Cálculo automático de desconto (unitário × unidades) | ✅ | Recalcula ao alterar seleção de unidades |
| Campos editáveis: Multa, Controle, Rateio Água | ✅ | Preenchimento manual |
| Opção "Enviar p/ Registro" | ✅ | Checkbox |
| Opção "Enviar p/ E-Mail" | ✅ | Checkbox |

### 4.2 ✅ Cobrança Avulsa (Boleto Avulso) — Via Tela de Boletos

| Funcionalidade | Status | Detalhes |
|---|---|---|
| Gerar boleto avulso via dialog | ✅ | Modal `GerarCobrancaAvulsaDialog` |
| Selecionar conta contábil (dropdown) | ✅ | 10 categorias pré-definidas |
| Selecionar unidades específicas | ✅ | Via `SelecionarBlocoUnidDialog` |
| Definir valor único para todas as unidades | ✅ | Campo de valor manual |
| Descrição personalizada | ✅ | Campo texto livre |
| "Constar no Relatório" (auto para Multa/Advertência) | ✅ | Checkbox condicional |
| Opção "Enviar p/ Registro" / "Enviar p/ E-Mail" | ✅ | Checkboxes |

### 4.3 ✅ Cobrança Avulsa — Via Tela Dedicada

| Funcionalidade | Status | Detalhes |
|---|---|---|
| Aba Pesquisar: listar cobranças avulsas | ✅ | Lista com status, valor, unidade |
| Aba Pesquisar: excluir cobrança | ✅ | Confirmação + delete no Supabase |
| Aba Pesquisar: sincronizar status com ASAAS | ✅ | Atualiza status via webhook handler |
| Aba Cadastrar: formulário completo | ✅ | Etapas de classificação → forma → seleção |
| Aba Cadastrar: "Boleto Avulso" (gerar agora) | ✅ | Integração completa com backend |
| Aba Cadastrar: recorrência (N meses) | ✅ | Suportado no backend (CobrancaService) |
| Upload de comprovante | ✅ | Via Supabase Storage |
| Envio de e-mail de notificação | ✅ | Via Resend (melhor esforço) |

### 4.4 ❌ Funcionalidades Pendentes

| Funcionalidade | Status | Motivo |
|---|---|---|
| "Junto à Taxa Cond." (composição) | ❌ | Tabela `despesas_extras` não criada |
| Ver detalhes de um boleto avulso | ❌ | UI não implementada |
| Editar cobrança avulsa existente | ❌ | Fluxo de edição não existe |
| Reenviar boleto por e-mail (aba pesquisa) | ❌ | Botão não implementado |
| Filtros avançados na pesquisa | ❌ | Filtro por data/status não existe |
| Prorrogação de boleto avulso | ❌ | API ASAAS suporta mas não implementado |

---

## 5. Fluxos Técnicos Detalhados

### 5.1 Fluxo: Gerar Boleto Avulso (Dialog — Tela de Boletos)

```
Usuário abre Dialog → Preenche campos → Clica "GERAR BOLETO AVULSO"
    │
    ▼
BoletoCubit.gerarCobrancaAvulsa()
    │
    ▼ Monta payload com: condominioId, contaContabil, contaNome,
    │  dataVencimento, valor, descricao, constarRelatorio, moradores[]
    │
    ▼ Para cada unidade selecionada:
    │  - Busca proprietário/inquilino no Supabase
    │  - Monta objeto {name, cpfCnpj, bloco, numero, unidadeId}
    │
    ▼ Chama API: POST /api/asaas/boletos/gerar-avulso
    │
    ▼ Backend (BoletoAvulsoService):
    │  1. criarOuBuscar customer no ASAAS
    │  2. CobrancaService.criar() → POST /payments no ASAAS
    │  3. Tenta obter linha digitável (retry 2x)
    │  4. Batch insert na tabela 'boletos' do Supabase
    │
    ▼ Retorna: {total, sucesso, erros, resultados[]}
    │
    ▼ BoletoCubit emite estado de sucesso/erro
    │
    ▼ UI mostra SnackBar com resultado
```

### 5.2 Fluxo: Gerar Boleto Avulso (Tela de Cobrança Avulsa)

```
Usuário navega para Cobrança Avulsa → Aba Cadastrar
    │
    ▼ Preenche: Conta Contábil, Forma de Cobrança = "Boleto Avulso"
    │  Dia de Vencimento, Recorrência, Seleciona Unidades, Define Valores
    │
    ▼ Clica "Gerar Boleto"
    │
    ▼ CobrancaAvulsaCubit.salvarCobrancas()
    │  1. Upload de comprovante (se houver)
    │  2. Agrupa itens por unidade
    │  3. insertCobrancaAvulsaBatch() → API Laravel
    │  4. Dispara e-mail (CobrancaAvulsaEmailService)
    │
    ▼ Chama API: POST /api/asaas/cobrancas/gerar-avulsa
    │
    ▼ Backend (CobrancaService.gerarAvulsa()):
    │  1. Busca morador da unidade no Supabase
    │  2. criarOuBuscar customer ASAAS
    │  3. Se recorrente: loop de 1..N meses
    │  4. Cria payment no ASAAS para cada vencimento 
    │  5. Salva cada boleto no Supabase (INSERT individual)
    │
    ▼ Retorna: [{asaas_id, vencimento, valor}, ...]
    │
    ▼ CobrancaAvulsaCubit emite saveSuccess
    │
    ▼ BlocListener mostra SnackBar + recarrega lista
```

### 5.3 Fluxo: Sincronizar Status com ASAAS

```
Usuário clica "Sincronizar" em um boleto
    │
    ▼ CobrancaAvulsaCubit.sincronizarBoleto(asaas_payment_id)
    │
    ▼ Chama API: GET /api/asaas/cobrancas/{id}/sincronizar
    │
    ▼ Backend (CobrancaController.sincronizar()):
    │  1. Busca payment atual no ASAAS
    │  2. Mapeia status ASAAS → evento de webhook
    │     CONFIRMED/RECEIVED → PAYMENT_RECEIVED
    │     OVERDUE → PAYMENT_OVERDUE
    │     REFUNDED → PAYMENT_REFUNDED  
    │     DELETED → PAYMENT_DELETED
    │     default → PAYMENT_UPDATED
    │  3. Chama AsaasWebhookHandler.process()
    │  4. Webhook handler atualiza Supabase
    │
    ▼ Retorna: {asaas_id, status_asaas, event_processed}
    │
    ▼ CobrancaAvulsaCubit emite syncSuccess
```

---

## 6. Gerenciamento de Estado (Cubit/BLoC)

### 6.1 BoletoCubit (Tela Principal de Boletos)

**Estados:**
- `BoletoStatus.initial` → Tela acabou de abrir
- `BoletoStatus.loading` → Carregando dados
- `BoletoStatus.success` → Dados carregados com sucesso
- `BoletoStatus.error` → Erro na operação

**Ações principais:**
- `carregarBoletos()` → Lista boletos por condomínio
- `carregarUnidades()` → Carrega unidades para seleção
- `gerarCobrancaMensal()` → Gerar lote mensal
- `gerarCobrancaAvulsa()` → Gerar boleto avulso (dialog)
- `filtrarBoletos()` → Filtra lista local

### 6.2 CobrancaAvulsaCubit (Tela de Cobrança Avulsa)

**Estados específicos:**
- `CobrancaAvulsaStatus.saveSuccess` → Cobrança salva com sucesso
- `CobrancaAvulsaStatus.deleteSuccess` → Cobrança excluída 
- `CobrancaAvulsaStatus.syncSuccess` → Status sincronizado

**Mecanismo de notificação:**
- Cada sucesso emite um estado específico
- O `BlocListener` na UI detecta a mudança
- Após exibir o SnackBar, o status é resetado para `loaded` via `resetStatus()`
- Isso evita notificações duplicadas

---

## 7. Duas Rotas de API para Boleto Avulso (Diferenças)

O sistema possui **duas rotas distintas** no backend para gerar boletos avulsos:

### Rota 1: `/api/asaas/cobrancas/gerar-avulsa`
- **Usada por:** `CobrancaAvulsaRepository.insertCobrancaAvulsaBatch()`
- **Recebe:** `condominioId`, `unidades[]` (UUIDs), `valor`, `dataVencimento`
- **Backend:** `CobrancaService.gerarAvulsa()` → busca moradores no Supabase
- **Suporta:** Recorrência nativa (N meses)
- **Salva no Supabase:** sim (INSERT individual por boleto)

### Rota 2: `/api/asaas/boletos/gerar-avulso`
- **Usada por:** `BoletoCubit.gerarCobrancaAvulsa()` (dialog)
- **Recebe:** `moradores[]` com `{name, cpfCnpj}` já resolvidos
- **Backend:** `BoletoAvulsoService.gerarCobrancaAvulsa()`
- **Suporta:** Batch insert no Supabase (mais eficiente)
- **Salva no Supabase:** sim (batch)

> **Nota:** Ambas as rotas são funcionais. A Rota 2 é mais otimizada para lotes grandes pois o Flutter já resolve os dados dos moradores antes de enviar.

---

## 8. Webhook ASAAS (Sincronização Automática)

O sistema recebe webhooks em `POST /api/asaas/webhook` para sincronização automática de status:

**Eventos tratados:**
- `PAYMENT_RECEIVED` → Marca boleto como "Pago"
- `PAYMENT_OVERDUE` → Marca boleto como "Vencido"
- `PAYMENT_REFUNDED` → Marca como "Estornado"
- `PAYMENT_DELETED` → Remove/cancela boleto

**Sincronização manual:** Também disponível via botão na tela de Cobrança Avulsa, que chama `/cobrancas/{id}/sincronizar`.

---

## 9. Contas Contábeis Disponíveis

As contas contábeis para cobrança avulsa estão definidas estaticamente no dialog:

| ID | Nome | Constar Relatório |
|---|---|---|
| `taxa_condominal` | Taxa Condominal | ❌ |
| `multa_infracao` | Multa por Infração | ✅ |
| `advertencia` | Advertência | ✅ |
| `controle_tags` | Controle/Tags | ❌ |
| `manutencao_servicos` | Manutenção/Serviços | ❌ |
| `salao_festa` | Salão de Festa/Churrasqueira | ❌ |
| `agua` | Água | ❌ |
| `gas` | Gás | ❌ |
| `sinistro` | Sinistro | ❌ |

---

## 10. Bugs Conhecidos e Limitações

### 10.1 Limitações Atuais
1. **Valor único para todas as unidades** — No dialog de boleto avulso da tela principal, não é possível definir valores diferentes por unidade (a tela de Cobrança Avulsa permite edição inline)
2. **Contas contábeis estáticas** — Definidas no código, não no banco de dados
3. **Sem validação de CPF/CNPJ** — Se o morador não tiver CPF cadastrado, o ASAAS pode rejeitar
4. **Sem preview do boleto** — Não é possível visualizar o boleto antes de gerar

### 10.2 Pontos de Atenção
1. **Linha digitável** — Pode não estar disponível imediatamente após geração (ASAAS processa de forma assíncrona). O backend faz retry de 2 tentativas.
2. **E-mail best-effort** — Falhas de e-mail são silenciosas. O representante não é avisado se o e-mail não foi enviado.
3. **Duas rotas de API** — Existem duas implementações paralelas para boleto avulso. Futuramente devem ser unificadas.

---

## 11. Métricas de Implementação

| Componente | Arquivos | Linhas (aprox.) |
|---|---|---|
| Flutter - Boleto Feature | 7 | ~2.000 |
| Flutter - Cobrança Avulsa Feature | 10 | ~1.500 |
| Backend - Cobrança | 3 | ~490 |
| Backend - Boleto | 4 | ~590 |
| Backend - Resend | 3 | ~130 |
| **Total** | **~27** | **~4.710** |

---

## 12. Conclusão

A feature de boleto do representante está **operacionalmente funcional** para os fluxos de **cobrança mensal** e **boleto avulso**. As integrações com ASAAS (geração de boletos reais), Supabase (persistência) e Resend (notificações por e-mail) estão todas funcionando.

O principal item pendente é a implementação do fluxo **"Junto à Taxa Condominial"**, que requer uma nova tabela no Supabase (`despesas_extras`) e alterações no fluxo de geração mensal para incorporar despesas extras acumuladas.
