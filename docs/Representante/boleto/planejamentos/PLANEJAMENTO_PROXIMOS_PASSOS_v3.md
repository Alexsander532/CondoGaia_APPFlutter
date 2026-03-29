# 🗺️ Planejamento — Próximos Passos da Feature de Boleto

**Data:** 28/03/2026  
**Versão:** 3.0  
**Prioridades:** 🔴 Alta · 🟡 Média · 🟢 Baixa

---

## 📊 Visão Geral do Status

```
FEATURE DE BOLETO DO REPRESENTANTE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ CONCLUÍDO  ─── Cobrança Mensal ............ 100%
✅ CONCLUÍDO  ─── Boleto Avulso .............. 90%
⬜ PENDENTE   ─── Junto à Taxa ............... 0%
🔧 REFINAMENTO ── Melhorias de UX ............ 30%
🔧 REFINAMENTO ── Relatórios ................. 0%
```

---

## FASE 1 — Fechar Boleto Avulso (90% → 100%)

**Objetivo:** Garantir que o fluxo de Boleto Avulso está 100% estável e testado.  
**Esforço estimado:** 2-3 dias  
**Prioridade:** 🔴 Alta

### 1.1 🔴 Validação e Feedback ao Usuário

- [ ] **Diálogo de confirmação antes de gerar** — "Tem certeza que deseja gerar X boletos no valor de R$ Y?"
  - Mostrar: quantidade de boletos, valor unitário, valor total
  - Botões: "Cancelar" / "Confirmar e Gerar"
  - **Arquivo:** `gerar_cobranca_avulsa_dialog.dart`

- [ ] **Feedback de progresso durante geração** — Quando são muitos boletos (>5), mostrar progresso
  - Contagem: "Gerando boleto 3/24..."
  - **Arquivo:** `boleto_cubit.dart` + dialog

- [ ] **Validação de CPF/CNPJ** — Verificar se o morador tem CPF antes de tentar gerar
  - Se não tiver CPF → erro amigável: "O morador da unidade X não possui CPF cadastrado"
  - **Arquivo:** `boleto_service.dart`

### 1.2 🔴 Tratamento de Erros

- [ ] **Erros parciais em lote** — Se 20 de 24 boletos forem gerados com sucesso:
  - Mostrar quais falharam e por quê
  - Permitir tentar novamente apenas os que falharam
  - **Arquivo:** `boleto_cubit.dart` + UI

- [ ] **Timeout da API** — Tratar cenário onde o backend demora mais de 30s
  - Mostrar mensagem: "A geração está demorando mais do que o esperado..."
  - **Arquivo:** `laravel_api_service.dart`

- [ ] **Falha de e-mail visível** — Informar ao síndico se o e-mail não foi enviado
  - Adicionar retorno do backend com status de envio de e-mail
  - **Arquivo:** `cobranca_avulsa_email_service.dart`

### 1.3 🟡 Unificação de Rotas de API

Atualmente existem 2 rotas para gerar boleto avulso:
- `POST /asaas/cobrancas/gerar-avulsa` (CobrancaService)
- `POST /asaas/boletos/gerar-avulso` (BoletoAvulsoService)

- [ ] **Decidir qual rota será a oficial** — Recomendação: manter `/boletos/gerar-avulso` (BoletoAvulsoService) por ser mais otimizada
- [ ] **Migrar a tela de Cobrança Avulsa para usar a mesma rota**
- [ ] **Deprecar a rota antiga** após migração

---

## FASE 2 — Melhorias de UX na Pesquisa

**Objetivo:** Tornar a aba Pesquisar mais útil e completa.  
**Esforço estimado:** 3-4 dias  
**Prioridade:** 🟡 Média

### 2.1 🔴 Ver Detalhes de um Boleto

- [ ] **Criar tela/modal de detalhes** — ao clicar em um item da lista:
  - Mostrar: unidade, morador, valor, vencimento, descrição
  - Mostrar: status (badge colorido), conta contábil
  - Mostrar: link do boleto (se houver), linha digitável
  - Botão: "Copiar Linha Digitável"
  - Botão: "Abrir Boleto PDF"
  - **Novo arquivo:** `detalhes_cobranca_dialog.dart`

### 2.2 🟡 Filtros e Busca

- [ ] **Filtro por status** — Dropdown: "Todos", "Ativo", "Pago", "Vencido", "Cancelado"
- [ ] **Filtro por período** — DatePicker: "De: ___  Até: ___"
- [ ] **Filtro por bloco/unidade** — Reutilizar `SelecionarBlocoUnidDialog`
- [ ] **Barra de busca** — Pesquisar por descrição ou nome do morador
- **Arquivo:** `pesquisar_tab_widget.dart` + `cobranca_avulsa_cubit.dart`

### 2.3 🟡 Reenviar Boleto por E-mail

- [ ] **Botão "Reenviar E-mail"** em cada item da lista (ícone de envelope)
- [ ] **Obter e-mail do morador** — Buscar no Supabase (proprietário ou inquilino da unidade)
- [ ] **Chamar endpoint Resend** — `POST /resend/cobranca-avulsa/enviar`
- [ ] **Feedback:** "E-mail reenviado com sucesso" ou erro

### 2.4 🟢 Editar Cobrança Existente

- [ ] **Modal de edição** — Permite alterar:
  - Descrição
  - Data de vencimento (se não estiver pago)
  - Valor (requer atualização no ASAAS)
- [ ] **Chamar API de atualização** — `PUT /asaas/cobrancas/{id}`
- [ ] **Atualizar Supabase** — Sincronizar dado local

### 2.5 🟢 Prorrogação de Vencimento

- [ ] **Botão "Prorrogar"** para boletos vencidos/ativos
- [ ] **Modal com novo vencimento** — DatePicker
- [ ] **Chamar API ASAAS** — atualizar dueDate
- [ ] **Atualizar Supabase** — nova data

---

## FASE 3 — Implementar "Junto à Taxa Condominial"

**Objetivo:** Permitir que o síndico registre despesas extras que serão somadas ao próximo boleto mensal.  
**Esforço estimado:** 5-7 dias  
**Prioridade:** 🟡 Média (depende de validação do sócio)

### 3.1 🔴 Criar Tabela no Supabase

```sql
CREATE TABLE despesas_extras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    condominio_id UUID NOT NULL REFERENCES condominios(id),
    unidade_id UUID NOT NULL REFERENCES unidades(id),
    conta_contabil TEXT NOT NULL,          -- 'Água', 'Gás', 'Multa', etc.
    descricao TEXT,
    valor NUMERIC(10, 2) NOT NULL,
    mes_referencia INTEGER NOT NULL,       -- Mês (1-12)
    ano_referencia INTEGER NOT NULL,       -- Ano (ex: 2026)
    status TEXT DEFAULT 'Pendente',        -- 'Pendente' | 'Processado' | 'Cancelado'
    boleto_id UUID REFERENCES boletos(id), -- Preenchido quando processado
    anexo_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policy
ALTER TABLE despesas_extras ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Representante pode CRUD despesas_extras do seu condomínio"
ON despesas_extras
FOR ALL
USING (condominio_id IN (
    SELECT condominio_id FROM representantes
    WHERE user_id = auth.uid()
));
```

### 3.2 🔴 Criar Repository/Service no Flutter

- [ ] **Novo método:** `inserirDespesaExtra()` no `CobrancaAvulsaRepository` ou novo `DespesaExtraRepository`
  - INSERT direto no Supabase (NÃO chama ASAAS, NÃO chama Laravel)
  - Campos: condominio_id, unidade_id, conta_contabil, descricao, valor, mes_referencia, ano_referencia

- [ ] **Novo método:** `listarDespesasExtras()` — para exibir na aba Pesquisar
  - Filtro: status = 'Pendente' e/ou 'Processado'

- [ ] **Novo método:** `cancelarDespesaExtra()` — soft delete (status = 'Cancelado')

### 3.3 🔴 Alterar Cubit da Cobrança Avulsa

- [ ] **Novo método:** `salvarComposicao()`
  - Se tipoCobranca == 'Junto à Taxa': chamar `inserirDespesaExtra()`
  - Se tipoCobranca == 'Boleto Avulso': chamar `insertCobrancaAvulsaBatch()` (fluxo atual)

- [ ] **Nova mudança de botão na UI:**
  - Se "Boleto Avulso" → texto do botão = "Gerar Boleto"
  - Se "Junto à Taxa" → texto do botão = "Registrar Despesa"

### 3.4 🔴 Alterar Geração Mensal (BoletoService)

O ponto mais crítico: quando o síndico gera o boleto mensal, o sistema precisa **buscar e incorporar** as despesas extras pendentes.

- [ ] **No Flutter — `boleto_service.dart`:**
  ```
  1. Buscar despesas_extras pendentes para o condomínio naquele mês
  2. Agrupar por unidade_id
  3. Somar ao valor de cada boleto
  4. Enviar os valores corretos para o backend
  ```

- [ ] **OU no Backend — `BoletoService.php`:**
  ```
  1. Antes de criar cada payment no ASAAS
  2. Buscar despesas_extras do Supabase
  3. Somar ao valor base da cobrança
  4. Após gerar o boleto, marcar despesas como 'Processado' com boleto_id
  ```

- [ ] **Decisão:** Qual camada faz a soma? 
  - **Recomendação:** Backend (mais seguro, evita inconsistências)

### 3.5 🟡 UI — Indicação Visual no Boleto Mensal

- [ ] **No GerarCobrancaMensalDialog:** Mostrar resumo de despesas extras pendentes
  - "⚠️ 8 despesas extras pendentes (R$ 1.200,00 acumulados)"
  - Lista resumida: "Água: R$ 800 | Gás: R$ 400"

- [ ] **No recibo/detalhes do boleto:** Mostrar composição do valor
  - Cota: R$ 500
  - Fundo: R$ 50
  - Água: R$ 96 ← despesa extra
  - **Total: R$ 646**

### 3.6 🟡 Aba Pesquisar — Listar Composições

- [ ] **Novo filtro:** "Tipo: Boleto Avulso | Composição | Todos"
- [ ] **Listar composições pendentes** com status diferente (tag "Pendente" amarela)
- [ ] **Permitir cancelar** composição pendente antes de gerar o mensal

---

## FASE 4 — Relatórios e Análises

**Objetivo:** Fornecer visibilidade financeira para o representante.  
**Esforço estimado:** 4-5 dias  
**Prioridade:** 🟢 Baixa

### 4.1 🟡 Relatório de Cobranças Avulsas

- [ ] **Tela de relatório** com período (mês/ano)
- [ ] **Dados do relatório:**
  - Total de cobranças geradas no período
  - Total em R$ gerado
  - Percentual de pagos vs pendentes vs vencidos
  - Top 5 categorias (conta contábil) por valor
- [ ] **Exportar para PDF** (usando o pacote `pdf` do Flutter)

### 4.2 🟢 Dashboard Financeiro

- [ ] **Widget no dashboard principal** mostrando:
  - Boletos do mês: X gerados / Y pagos / Z vencidos
  - Inadimplência: X%
  - Gráfico de evolução mensal

### 4.3 🟢 Relatório para Assembleia

- [ ] **Relatório consolidado** para apresentar em assembleia
  - Todas as multas e advertências aplicadas
  - Acordos firmados e status
  - Despesas extraordinárias

---

## FASE 5 — Automações e Notificações

**Objetivo:** Automatizar tarefas repetitivas e manter os moradores informados.  
**Esforço estimado:** 3-4 dias  
**Prioridade:** 🟢 Baixa

### 5.1 🟡 Geração Mensal Automática

- [ ] **Agendamento automático** — Gerar boletos automaticamente todo mês
  - Laravel Task Scheduler: `cron` no dia do vencimento - 5 dias
  - Buscar todos os condomínios com tipo_cobranca = 'FIXO'
  - Gerar boletos automaticamente

### 5.2 🟡 Lembretes Automáticos

- [ ] **E-mail de lembrete** — 3 dias antes do vencimento
  - Rota já existe: `POST /resend/boleto/lembrete`
  - Implementar scheduling no backend

- [ ] **E-mail de atraso** — 1 dia após vencimento
  - Rota já existe: `POST /resend/notificacao/atraso`
  - Implementar scheduling

### 5.3 🟢 Notificação Push no App

- [ ] **Notificar morador** quando boleto é gerado
- [ ] **Notificar síndico** quando boleto é pago
- [ ] **Integração com Firebase Cloud Messaging**

### 5.4 🟢 WhatsApp

- [ ] **Envio de boleto por WhatsApp** — Integração com API WhatsApp Business
- [ ] **Lembrete por WhatsApp** — Automático antes do vencimento

---

## FASE 6 — Contas Contábeis Dinâmicas

**Objetivo:** Permitir que o síndico crie e gerencie suas próprias categorias.  
**Esforço estimado:** 2-3 dias  
**Prioridade:** 🟢 Baixa

### 6.1 🟡 Migrar Contas para o Banco de Dados

Atualmente as contas contábeis são hardcoded no Flutter. A feature de Gestão já possui um CRUD de contas contábeis no módulo de Receitas.

- [ ] **Reutilizar a tabela de contas contábeis** já existente
- [ ] **Carregar via Supabase** no dropdown do dialog de cobrança avulsa
- [ ] **Permitir criar novas categorias** pelo modal (já existe no módulo de Receitas)
- [ ] **Migrar dados existentes** — Mapear IDs das contas hardcoded para a tabela

---

## 📅 Cronograma Sugerido

| Fase | Nome | Esforço | Prioridade | Semana Sugerida |
|---|---|---|---|---|
| 1 | Fechar Boleto Avulso | 2-3 dias | 🔴 Alta | Semana 1 |
| 2 | Melhorias UX Pesquisa | 3-4 dias | 🟡 Média | Semana 1-2 |
| 3 | Junto à Taxa Cond. | 5-7 dias | 🟡 Média | Semana 2-3 |
| 4 | Relatórios | 4-5 dias | 🟢 Baixa | Semana 3-4 |
| 5 | Automações | 3-4 dias | 🟢 Baixa | Semana 4-5 |
| 6 | Contas Dinâmicas | 2-3 dias | 🟢 Baixa | Semana 5 |

**Total estimado:** 19-26 dias de desenvolvimento

---

## 🔄 Dependências Entre Fases

```
Fase 1 (Fechar Avulso)
  └─→ Fase 2 (UX Pesquisa) ── sem dependência, pode ser paralelo
  
Fase 1 (Fechar Avulso)
  └─→ Fase 3 (Junto à Taxa)
        └─→ Fase 4 (Relatórios) ── depende dos dados de composição
        
Fase 5 (Automações) ── independente, pode ser feita a qualquer momento

Fase 6 (Contas Dinâmicas) ── independente, pode ser feita a qualquer momento
```

---

## 📝 Decisões Pendentes (Precisam de Definição)

1. **"Junto à Taxa" é prioridade para o próximo sprint?** — Define se a Fase 3 entra agora ou fica para depois

2. **Gerar confirmação antes de criar boletos?** — Dialog de "Tem certeza?" com resumo

3. **Quem soma as despesas extras ao boleto mensal?** — Flutter ou Backend?
   - **Recomendação:** Backend (mais seguro)

4. **Manter as duas rotas de API para boleto avulso?** — Ou unificar em uma só?
   - **Recomendação:** Unificar na rota `/boletos/gerar-avulso`

5. **Contas contábeis dinâmicas agora?** — Ou manter estáticas por enquanto?
   - **Recomendação:** Migrar quando o módulo de Receitas estiver mais maduro

6. **Integração com WhatsApp é desejada?** — Requer conta Business e API separada

7. **Geração automática mensal?** — Condomínios com valor fixo poderiam gerar sozinhos

---

*Este planejamento será atualizado conforme decisões forem tomadas e tarefas concluídas.*
