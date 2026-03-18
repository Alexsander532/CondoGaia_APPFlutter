# 📊 Relatório Completo — Sistema de Boletos CondoGaia

**Data:** 17/03/2026  
**Versão:** 2.0  
**Status Geral:** 🟡 Em Desenvolvimento Avançado  
**Módulos Analisados:** Representante, Prop/Inq, Cobrança Avulsa, Backend Laravel

---

## 1. Resumo Executivo

O sistema de boletos do CondoGaia está em **estágio avançado de desenvolvimento** com a arquitetura principal já implementada e funcional. O fluxo completo de **geração → registro ASAAS → visualização → pagamento** funciona ponta a ponta. Existem pendências específicas em cada módulo que precisam ser finalizadas para considerar a feature pronta para produção.

### Nível de Completude por Módulo

| Módulo | Completude | Status |
|--------|-----------|--------|
| **Backend Laravel (ASAAS)** | 🟢 ~90% | Endpoints funcionais, falta webhook de pagamento automático |
| **Representante (Boleto)** | 🟢 ~85% | Tela funcional, geração mensal ok, faltam ações dos cards superiores |
| **Representante (Cobrança Avulsa)** | 🟡 ~60% | UI implementada, falta integração ASAAS e condominioId dinâmico |
| **Prop/Inq (Boleto)** | 🟡 ~75% | Funcionalidades core ok, faltam leituras/balancete reais e testes |
| **Email (Resend)** | 🟢 ~85% | Envio implementado, faltam templates mais elaborados |

---

## 2. Arquitetura Atual — Visão Macro

```
┌───────────────────────────────────────────────────────────────────┐
│                    SISTEMA DE BOLETOS CONDOGAIA                   │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────────┐  │
│  │  REPRESENTANTE  │  │   PROP / INQ     │  │   COBRANÇA     │  │
│  │  (Síndico)      │  │   (Morador)      │  │   AVULSA       │  │
│  └───────┬─────────┘  └────────┬─────────┘  └──────┬─────────┘  │
│          │                     │                    │            │
│          ▼                     ▼                    ▼            │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    SUPABASE (Banco de Dados)                │ │
│  │         Tabela: boletos, moradores, unidades                │ │
│  └────────────────────────┬────────────────────────────────────┘ │
│                           │                                      │
│  ┌────────────────────────▼────────────────────────────────────┐ │
│  │             BACKEND LARAVEL (API)                           │ │
│  │  BoletoController → BoletoService                          │ │
│  │  BoletoEmailController → BoletoEmailService                │ │
│  └────────────────────────┬────────────────────────────────────┘ │
│                           │                                      │
│  ┌────────────────────────▼────────────────────────────────────┐ │
│  │                  ASAAS (Gateway)                            │ │
│  │  Cobrança → PDF → Código de Barras → Webhooks              │ │
│  └─────────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────────┘
```

---

## 3. Detalhamento — Backend Laravel

### 3.1 Endpoints Implementados

| Rota | Método | Status | Descrição |
|------|--------|--------|-----------|
| `/api/asaas/boletos/gerar-mensal` | POST | ✅ Funcional | Gera boletos em lote para todas as unidades |
| `/api/asaas/boletos/registrar-individual` | POST | ✅ Funcional | Registra um boleto individual no ASAAS |
| `/api/asaas/boletos/verificar-registro` | POST | ✅ Funcional | Verifica status de registro de múltiplos boletos |
| `/api/asaas/boletos/agrupar` | POST | ✅ Funcional | Agrupa boletos em acordo |
| `/api/asaas/boletos/{id}/linha-digitavel` | GET | ✅ Funcional | Obtém linha digitável de um boleto |
| `/api/asaas/boletos/{id}/pdf` | GET | ✅ Funcional | Obtém URL do PDF |

### 3.2 Serviços Backend

| Arquivo | Linhas | Status | Funcionalidades |
|---------|--------|--------|-----------------|
| `BoletoService.php` | 349 | ✅ | Registro ASAAS, geração mensal, agrupamento, `obterLinhaDigitavel` com retries |
| `BoletoController.php` | 169 | ✅ | 6 endpoints REST |
| `CobrancaService.php` | — | ✅ | Criação de cobranças ASAAS (multa 2%, juros 1%) |
| `AsaasClientService.php` | — | ✅ | Criação/busca de clientes ASAAS |
| `BoletoEmailController.php` | — | ✅ | Envio de boletos por email |
| `BoletoEmailService.php` | — | ✅ | Lógica de envio via Resend |

### 3.3 Pendências do Backend

| Item | Prioridade | Descrição |
|------|-----------|-----------|
| **Webhook de Pagamento** | 🔴 Alta | Falta handler para webhook `PAYMENT_RECEIVED` do ASAAS para marcar boleto como Pago automaticamente |
| **Cancelamento no ASAAS** | 🟡 Média | Ao excluir ou cancelar boleto no app, não há chamada ao ASAAS para cancelar a cobrança lá |
| **Segunda Via** | 🟡 Média | Não há endpoint para reemitir boletos vencidos com nova data |
| **Cron de Lembretes** | 🟢 Baixa | Futuro: enviar lembretes automáticos X dias antes do vencimento |

---

## 4. Detalhamento — Módulo Representante (Síndico)

### 4.1 Arquivos e Status

| Arquivo | Linhas | Status |
|---------|--------|--------|
| `boleto_screen.dart` | 248 | ✅ Funcional |
| `boleto_cubit.dart` | 381 | ✅ Funcional |
| `boleto_state.dart` | — | ✅ Funcional |
| `boleto_model.dart` | — | ✅ Funcional |
| `boleto_service.dart` | 530 | ✅ Funcional |
| `boleto_email_service.dart` | 72 | ✅ Funcional |
| `boleto_filtro_widget.dart` | — | ✅ Funcional |
| `boleto_list_widget.dart` | — | ✅ Funcional |
| `boleto_acoes_widget.dart` | — | ✅ Funcional |
| `receber_boleto_dialog.dart` | — | ✅ Funcional |
| `gerar_cobranca_mensal_dialog.dart` | — | ✅ Funcional |

### 4.2 Funcionalidades Implementadas ✅

| Funcionalidade | Código | Observação |
|---------------|--------|------------|
| Listar boletos com filtros | `listarBoletos()` | Filtro por tipo, situação, período, nosso número, pesquisa |
| Navegação mês/ano | `mesAnterior()` / `proximoMes()` | Recarrega dados ao mudar |
| Gerar cobrança mensal | `gerarCobrancaMensal()` | Chama backend Laravel → ASAAS → Supabase |
| Receber boleto (baixa manual) | `receberBoleto()` | Atualiza status, juros, multa direto no Supabase |
| Excluir boletos | `excluirSelecionados()` | Exclusão múltipla via `inFilter` |
| Agrupar boletos (acordo) | `agruparSelecionados()` | Soma valores, cancela demais |
| Enviar para registro ASAAS | `enviarParaRegistro()` | Registro em lote via backend |
| Enviar por email | `enviarBoletosPorEmail()` | Determina pagador (prop vs inq) e envia via Resend |
| Seleção múltipla | `toggleItemSelecionado()` / `selecionarTodos()` | Controle de checkboxes |
| Detalhar composição | `toggleDetalharComposicao()` | Expande composição na lista |
| Navegação para Cobrança Avulsa | AppBar action button | `Navigator.push → CobrancaAvulsaScreen` |

### 4.3 Pendências do Representante

| Item | Prioridade | Descrição |
|------|-----------|-----------|
| **Ações dos cards superiores** | 🟡 Média | Os 3 primeiros ícones no topo da tela (nota, imagem, lista) têm `onTap` vazio |
| **Feedback de loading melhorado** | 🟢 Baixa | Sem skeleton loading, apenas loading genérico |
| **Impressão em lote** | 🟢 Baixa | Sem funcionalidade de imprimir vários boletos de uma vez |
| **Relatório financeiro** | 🟢 Baixa | Sem tela de resumo financeiro consolidado |

---

## 5. Detalhamento — Módulo Prop/Inq (Morador)

### 5.1 Arquitetura (Clean Architecture)

```
boleto/
├── data/
│   ├── datasources/boleto_prop_remote_datasource.dart    ✅
│   ├── models/boleto_prop_model.dart                     ✅
│   └── repositories/boleto_prop_repository_impl.dart     ✅
├── domain/
│   ├── entities/boleto_prop_entity.dart                   ✅  (30+ campos)
│   ├── repositories/boleto_prop_repository.dart           ✅
│   └── usecases/boleto_prop_usecases.dart                ✅  (6 use cases)
└── ui/
    ├── cubit/boleto_prop_cubit.dart                       ✅  (372 linhas)
    ├── cubit/boleto_prop_state.dart                       ✅
    ├── screens/boleto_prop_screen.dart                    ✅
    └── widgets/
        ├── boleto_card_widget.dart                        ✅
        ├── boleto_acoes_expandidas.dart                   ✅
        ├── boleto_filtro_dropdown.dart                    ✅
        ├── demonstrativo_financeiro_widget.dart           ✅
        └── secoes_expansiveis_widget.dart                 ⚠️ Parcial
```

### 5.2 Funcionalidades Implementadas ✅

| Funcionalidade | Status | Implementação |
|---------------|--------|---------------|
| Listar boletos do morador | ✅ | Filtra por `sacado = moradorId` |
| Filtro Vencido/A Vencer vs Pago | ✅ | Dropdown com consulta real |
| Composição do boleto | ✅ | Dados reais do banco (cota, fundo, rateio, etc.) |
| Demonstrativo financeiro | ✅ | Use case dedicado com somatórias |
| Ver PDF do boleto | ✅ | `url_launcher` abre `bankSlipUrl` |
| Copiar código de barras | ✅ | Prioriza `identification_field` > `barCode` > `codigoBarras` |
| Sincronizar com ASAAS | ✅ | Se não tiver código, chama backend para registrar |
| **Compartilhar boleto** | ✅ | Implementado com `share_plus`, compartilha PDF ou texto |
| Navegação mês/ano | ✅ | Recarrega demonstrativo e balancete |
| Expandir/colapsar boletos | ✅ | Carrega composição e leituras ao expandir |

### 5.3 Pendências do Prop/Inq

| Item | Prioridade | Descrição |
|------|-----------|-----------|
| **Leituras de água/gás reais** | 🟡 Média | O `_obterLeituras` existe no cubit mas a integração com a tabela `leituras` pode não estar completamente testada |
| **Balancete online real** | 🟡 Média | O `_obterBalanceteOnline` existe mas precisa de verificação da query no DataSource |
| **Skeleton loading** | 🟢 Baixa | Sem widget de loading elaborado |
| **Estados vazios** | 🟢 Baixa | Sem feedback visual elaborado quando não há boletos |
| **Testes automatizados** | 🔴 Alta | Zero cobertura de testes |

---

## 6. Detalhamento — Módulo Cobrança Avulsa

### 6.1 Arquivos e Status

| Arquivo | Linhas | Status |
|---------|--------|--------|
| `cobranca_avulsa_screen.dart` | — | ✅ UI implementada (2 abas) |
| `cadastrar_cobranca_tab.dart` | — | ✅ Formulário completo |
| `pesquisar_cobranca_tab.dart` | — | ✅ Listagem implementada |
| `cobranca_avulsa_cubit.dart` | 206 | ⚠️ Funcional parcialmente |
| `cobranca_avulsa_state.dart` | — | ✅ |
| `cobranca_avulsa_entity.dart` | — | ✅ |
| `cobranca_avulsa_model.dart` | — | ✅ |
| `cobranca_avulsa_repository.dart` | — | ✅ |

### 6.2 Funcionalidades

| Funcionalidade | Status | Observação |
|---------------|--------|------------|
| Formulário de cadastro | ✅ | Campos: conta contábil, unidade, descrição, valor, tipo, dia vencimento |
| Carrinho de cobranças | ✅ | Adicionar/remover itens antes de salvar |
| Salvar no Supabase | ✅ | Salva via repository |
| Listar cobranças | ✅ | Carrega do banco |
| Seleção e exclusão em massa | ✅ | `alternarSelecaoItem()`, `excluirSelecionados()` |
| Anexo de imagem | ✅ | Via `image_picker` |
| Cobrança recorrente | ⚠️ | Campo existe no state mas lógica de repetição não implementada |

### 6.3 Pendências da Cobrança Avulsa

| Item | Prioridade | Descrição |
|------|-----------|-----------|
| **`condominioId` dinâmico** | 🔴 Alta | Linha 90: `condominioId: 'COND_FIXO_TEMP'` precisa pegar do contexto/Auth |
| **Integração com ASAAS** | 🔴 Alta | Sem chamada ao backend para registrar cobrança avulsa no ASAAS |
| **Envio por email** | 🟡 Média | Sem disparo de email para o morador da cobrança avulsa |
| **Lógica de recorrência** | 🟡 Média | Quando `recorrente = true`, precisaria gerar X meses automaticamente |
| **Upload de imagem** | 🟡 Média | Imagem selecionada mas não salva no Supabase Storage |
| **Header refinado** | ✅ | Já ajustado para match com BoletoScreen |

---

## 7. Integração com Email (Resend)

### 7.1 Serviços Implementados

| Serviço Flutter | Endpoints Backend | Status |
|----------------|-------------------|--------|
| `BoletoEmailService` | `/resend/boleto/enviar` | ✅ Envio individual |
| `BoletoEmailService` | `/resend/boleto/lembrete` | ✅ Lembrete de vencimento |
| `BoletoEmailService` | `/resend/boleto/enviar-lote` | ✅ Envio em lote |
| `CobrancaEmailService` | `/resend/cobranca/confirmar` | ✅ Confirmação |
| `CobrancaEmailService` | `/resend/cobranca/recibo` | ✅ Recibo |

### 7.2 Templates Blade

| Template | Status | Uso |
|----------|--------|-----|
| `boleto_emitido.blade.php` | ✅ | Email com dados do boleto emitido |
| `boleto_lembrete.blade.php` | ✅ | Lembrete com dias restantes |
| `cobranca_confirmacao.blade.php` | ✅ | Confirmação de cobrança avulsa |
| `cobranca_recibo.blade.php` | ✅ | Recibo de pagamento |

---

## 8. Banco de Dados (Supabase)

### 8.1 Tabela `boletos` — Campos Principais

| Campo | Tipo | Fonte |
|-------|------|-------|
| `id` | UUID | Auto-gerado |
| `condominio_id` | UUID | FK → condominios |
| `unidade_id` | UUID | FK → unidades |
| `sacado` | UUID | FK → moradores (pagador) |
| `bloco_unidade` | TEXT | "A/101" |
| `referencia` | TEXT | "03/2026" |
| `data_vencimento` | DATE | — |
| `valor` | DECIMAL | — |
| `valor_total` | DECIMAL | Com juros/multas |
| `status` | TEXT | Ativo, Registrado, Pago, Cancelado |
| `tipo` | TEXT | Mensal, Avulso, Acordo |
| `boleto_registrado` | TEXT | SIM, NAO, PENDENTE, ERRO |
| `asaas_payment_id` | TEXT | ID no gateway ASAAS |
| `bank_slip_url` | TEXT | URL do PDF do boleto |
| `identification_field` | TEXT | Linha digitável |
| `bar_code` | TEXT | Código de barras |
| `cota_condominial` | DECIMAL | Composição |
| `fundo_reserva` | DECIMAL | Composição |
| `rateio_agua` | DECIMAL | Composição |
| `multa_infracao` | DECIMAL | Composição |
| `controle` | DECIMAL | Composição |
| `desconto` | DECIMAL | Composição |
| `juros` | DECIMAL | Acréscimos |
| `multa` | DECIMAL | Acréscimos |
| `outros_acrescimos` | DECIMAL | Acréscimos |
| `data_pagamento` | DATE | Quando foi pago |
| `conta_bancaria_id` | UUID | Qual conta recebeu |
| `pgto` | TEXT | SIM/NAO |
| `nosso_numero` | TEXT | Referência bancária |

---

## 9. Consolidado de Pendências — Ordem de Prioridade

### 🔴 Prioridade Alta (Bloqueadoras ou Críticas)

| # | Módulo | Pendência | Esforço |
|---|--------|-----------|---------|
| 1 | Backend | Implementar webhook `PAYMENT_RECEIVED` do ASAAS | Médio |
| 2 | Cobrança Avulsa | Injetar `condominioId` real em vez de `COND_FIXO_TEMP` | Baixo |
| 3 | Cobrança Avulsa | Integrar com backend ASAAS para registro da cobrança | Médio |
| 4 | Prop/Inq | Testes automatizados para Models e Cubit | Médio |

### 🟡 Prioridade Média (Melhorias Importantes)

| # | Módulo | Pendência | Esforço |
|---|--------|-----------|---------|
| 5 | Backend | Cancelar cobrança no ASAAS ao excluir boleto | Baixo |
| 6 | Backend | Endpoint de segunda via de boleto | Baixo |
| 7 | Cobrança Avulsa | Envio de email para cobrança avulsa | Baixo |
| 8 | Cobrança Avulsa | Implementar lógica de recorrência | Médio |
| 9 | Cobrança Avulsa | Upload de imagem no Supabase Storage | Médio |
| 10 | Prop/Inq | Verificar integração real de leituras de água/gás | Baixo |
| 11 | Prop/Inq | Verificar integração real do balancete online | Baixo |
| 12 | Representante | Implementar ações dos cards superiores da tela | Baixo |

### 🟢 Prioridade Baixa (Polimento)

| # | Módulo | Pendência | Esforço |
|---|--------|-----------|---------|
| 13 | Geral | Skeleton loading em todas as telas de boleto | Baixo |
| 14 | Geral | Estados vazios com ilustrações | Baixo |
| 15 | Representante | Impressão de boletos em lote | Médio |
| 16 | Representante | Relatório financeiro consolidado | Alto |
| 17 | Backend | Lembretes automáticos por cron (X dias antes do vencimento) | Médio |
| 18 | Backend | Geração automática mensal (modo automático) | Alto |

---

## 10. Próximos Passos Recomendados

### Fase 1 — Correções Críticas (1-2 dias)

1. **Corrigir `condominioId` na Cobrança Avulsa** — Passar o ID real do condomínio do contexto do Representante logado
2. **Webhook de pagamento ASAAS** — Criar handler para atualizar boleto automaticamente quando pago pelo morador

### Fase 2 — Integração Cobrança Avulsa (2-3 dias)

3. **Integrar Cobrança Avulsa com ASAAS** — Criar endpoint no backend e chamar na hora de gerar
4. **Email automático na cobrança avulsa** — Enviar para o morador ao registrar
5. **Upload de imagem (comprovante)** — Salvar no Supabase Storage

### Fase 3 — Finalização Prop/Inq (1-2 dias)

6. **Testar leituras e balancete** — Verificar se os DataSources estão corretos
7. **Testes automatizados** — Pelo menos para Models e Cubit

### Fase 4 — Polimento (2-3 dias)

8. **Skeleton loading** e **estados vazios** em todas as telas
9. **Ações dos cards superiores** na tela do Representante
10. **Cancelamento no ASAAS** — Sincronizar exclusões

---

## 11. Métricas do Código Atual

| Métrica | Valor |
|---------|-------|
| **Total de arquivos de boleto** | ~49 (Flutter) + ~10 (Backend) |
| **Linhas totais estimadas** | ~4.500+ |
| **Endpoints backend** | 6 implementados |
| **Use cases Prop/Inq** | 6 implementados |
| **Cobertura de testes** | 0% |
| **Templates de email** | 4 |
| **Documentação existente** | 5+ documentos detalhados |
