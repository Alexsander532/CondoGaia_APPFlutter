# 🗺️ Planejamento — Próximos Passos do Sistema de Boletos

**Data:** 17/03/2026  
**Baseado no:** Relatório Completo v2.0

---

## Fase 1 — Correções Críticas 🔴

> Estimativa: 1-2 dias | Bloqueadores para uso em produção

### 1.1 Corrigir `condominioId` na Cobrança Avulsa
- **Arquivo:** `cobranca_avulsa_cubit.dart:90`
- **Problema:** `condominioId: 'COND_FIXO_TEMP'`
- **Solução:** Receber `condominioId` como parâmetro do cubit (injetar via `CobrancaAvulsaScreen`)
- **Impacto:** Sem isso, nenhuma cobrança avulsa será salva corretamente

### 1.2 Implementar Webhook de Pagamento ASAAS
- **Contexto:** Quando o morador paga o boleto pelo banco, o ASAAS envia um webhook `PAYMENT_RECEIVED/PAYMENT_CONFIRMED` para nosso backend
- **Arquivos a criar/modificar:**
  - `Backend/app/Http/Controllers/AsaasWebhookHandler.php` — Adicionar handler para `PAYMENT_RECEIVED`
  - Lógica: Receber `paymentId` → buscar boleto no Supabase por `asaas_payment_id` → atualizar `status = 'Pago'`, `data_pagamento`, `valor_pago`
- **Impacto:** Sem isso, o status do boleto só muda manualmente

---

## Fase 2 — Integração Cobrança Avulsa com ASAAS 🟡

> Estimativa: 2-3 dias | Feature incompleta sem isso

### 2.1 Criar Endpoint Backend para Cobrança Avulsa
- **Rota:** `POST /api/asaas/cobrancas/gerar-avulsa`
- **Dados:** `condominioId`, `unidadeId`, `valor`, `dataVencimento`, `descricao`
- **Lógica:** Buscar morador da unidade → criar cliente ASAAS → criar cobrança → salvar no Supabase
- **Arquivo:** `Backend/app/Asaas/Cobranca/CobrancaController.php`

### 2.2 Chamar Backend ao Salvar Cobrança Avulsa
- **Arquivo:** `cobranca_avulsa_cubit.dart` → método `salvarCobrancas()`
- **Mudança:** Em vez de inserir direto no Supabase via repository, chamar o endpoint backend que fará o registro no ASAAS automaticamente

### 2.3 Envio de E-mail para Cobrança Avulsa
- **Arquivo:** `cobranca_avulsa_cubit.dart`
- **Adicionar:** Chamada ao `BoletoEmailService` após salvar com sucesso

### 2.4 Upload de Comprovante (Imagem)
- **Contexto:** A imagem é selecionada (`image_picker`) mas não salva
- **Solução:** Upload para Supabase Storage e salvar URL na tabela

### 2.5 Lógica de Recorrência
- **Contexto:** Campo `recorrente` e `qtdMeses` existem no state
- **Implementar:** Quando `recorrente = true`, gerar N cobranças com datas incrementais

---

## Fase 3 — Finalização Prop/Inq 🟡

> Estimativa: 1-2 dias | Qualidade da experiência do morador

### 3.1 Verificar Leituras de Água/Gás
- **Arquivo:** `boleto_prop_remote_datasource.dart`
- **Verificar:** Se o `ObterLeiturasUseCase` está fazendo query correta na tabela `leituras`
- **Testar:** Com dados reais, expandir um boleto e verificar se leituras aparecem

### 3.2 Verificar Balancete Online
- **Arquivo:** `boleto_prop_remote_datasource.dart`
- **Verificar:** Se o `ObterBalanceteOnlineUseCase` busca dados corretos
- **Testar:** Navegar entre meses e verificar se os dados mudam

### 3.3 Testes Automatizados
- **Criar arquivos de teste para:**
  - `boleto_prop_model_test.dart` — Testar `fromJson()` com dados reais
  - `boleto_prop_cubit_test.dart` — Testar estados de loading/success/error
  - Usar `mocktail` ou `mockito` para mockar Use Cases

---

## Fase 4 — Polimento e UX 🟢

> Estimativa: 2-3 dias | Melhoria de experiência

### 4.1 Skeleton Loading
- Aplicar em: `BoletoScreen` (Representante), `BoletoPropScreen` (Prop/Inq)
- Widgets shimmer durante carregamento

### 4.2 Estados Vazios
- Quando não há boletos: ilustração + mensagem amigável
- Diferente por filtro ("Nenhum boleto pago" vs "Nenhum boleto a vencer")

### 4.3 Cards de Ação (Representante)
- Os 3 primeiros ícones no topo do `boleto_screen.dart` estão sem ação
- Sugestão: Novo boleto manual, Relatório PDF, Lista resumida

### 4.4 Cancelamento Sincronizado com ASAAS
- Ao excluir boleto no app, chamar `DELETE /payments/{id}` no ASAAS
- Evita cobranças fantasma no gateway

---

## Fase 5 — Funcionalidades Futuras 🔮

> Planejamento de longo prazo

| Feature | Descrição | Complexidade |
|---------|-----------|-------------|
| **Geração Automática** | Cron job que gera boletos todo mês | Alta |
| **Lembretes Automáticos** | Email X dias antes do vencimento | Média |
| **Segunda Via** | Gerar novo boleto com nova data para vencidos | Baixa |
| **Dashboard Financeiro** | Visão consolidada de recebimentos | Alta |
| **PIX como alternativa** | Oferecer PIX além de boleto no ASAAS | Média |
| **Notificações Push** | Avisar no app quando boleto é gerado/pago | Média |

---

## Resumo do Planejamento

```
  Fase 1 ━━━━━━━━  [1-2 dias]  ► Webhook + condominioId fix
  Fase 2 ━━━━━━━━━━ [2-3 dias] ► Cobrança Avulsa + ASAAS
  Fase 3 ━━━━━━━━  [1-2 dias]  ► Prop/Inq + Testes
  Fase 4 ━━━━━━━━━━ [2-3 dias] ► Polimento + UX
  Fase 5 ━━━━━━━━━━━━━━━━━━━━━ ► Futuro
         ─────────────────────
  Total estimado: 6-10 dias úteis para Fases 1-4
```
