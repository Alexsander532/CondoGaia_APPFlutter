# Relatório de Status — Cobrança Avulsa / Desp. Extraordinária (v2)

**Data:** 27/03/2026 — 19:25  
**Responsável:** Equipe de Desenvolvimento  
**Feature:** Cobrança Avulsa / Despesa Extraordinária (Representante)

---

## 1. Resumo Executivo

A feature de **Cobrança Avulsa** está **parcialmente implementada**. A estrutura de arquitetura (Clean Architecture), navegação, layout das duas abas e a integração com o backend Laravel + ASAAS já existem. No entanto, **vários itens da aba "Cadastrar" ainda estão incompletos ou contêm TODOs**, e a aba "Pesquisar" está funcional mas usa um `condominioId` fixo/hardcoded. O fluxo completo "ponta a ponta" ainda **não foi testado com dados reais**.

---

## 2. Arquitetura Atual (O que EXISTE)

### 2.1 Estrutura de Diretórios
```
cobranca_avulsa/
├── data/
│   ├── models/         → cobranca_avulsa_model.dart (fromJson/toJson)
│   └── repositories/   → cobranca_avulsa_repository.dart (Supabase + Laravel API)
├── domain/
│   └── entities/       → cobranca_avulsa_entity.dart (16 campos)
├── services/           → cobranca_avulsa_email_service.dart (Resend via Laravel)
└── ui/
    ├── cubit/          → cobranca_avulsa_cubit.dart + state (316 + 143 linhas)
    ├── screens/        → cobranca_avulsa_screen.dart (Scaffold + TabBar)
    └── tabs/           → cadastrar_cobranca_tab.dart (780 linhas)
                          pesquisar_cobranca_tab.dart (268 linhas)
```

### 2.2 Backend (Laravel)
| Endpoint | Controller | Status |
|---|---|---|
| `POST /api/asaas/cobrancas/gerar-avulsa` | `CobrancaController@gerarAvulsa` | ✅ Implementado |
| `POST /api/resend/cobranca-avulsa/enviar` | `CobrancaAvulsaEmailController` | ✅ Implementado |
| Upload Supabase Storage (`comprovantes/`) | Repository direto | ✅ Implementado |

### 2.3 Integração ASAAS (CobrancaService.php)
- ✅ Busca morador pela `unidade_id` no Supabase
- ✅ Se não tem `asaas_customer_id`, cria o customer automaticamente
- ✅ Cria cobrança no ASAAS com billingType `BOLETO`
- ✅ Suporte a **recorrência**: gera N parcelas com vencimento mensal incrementado
- ✅ Salva cada boleto gerado na tabela `boletos` do Supabase

---

## 3. Aba "Cadastrar" — Análise Detalhada

### 3.1 O que FUNCIONA ✅

| Funcionalidade | Detalhe |
|---|---|
| **Step 1 — Classificação** | Dropdown "Conta Contábil" (10 opções hardcoded) + Mês/Ano |
| **Mês/Ano dinâmico** | Agora inicia no **próximo mês** automaticamente (ex: Abr/2026 em Março) |
| **Descrição** | Campo de texto livre ligado ao Cubit |
| **Step 2 — Forma de Cobrança** | Toggle segmentado "Junto à Taxa Cond." / "Boleto Avulso" |
| **Recorrente toggle** | Exibe campos Início/Fim/Qtd.Meses quando ativado |
| **Step 3 — Selecionar Unidades** | Busca via `UnidadeService.buscarUnidades()` no Supabase |
| **Tabela de unidades** | Checkbox + Bloco/Unidade + Proprietário + Valor inline editável |
| **Seleção de unidades** | Checkbox alterna seleção, desmarcar limpa valor |
| **Valor inline** | Campo editável por unidade, atualiza `valoresPorUnidade` no state |
| **Rodapé fixo** | Mostra "X unid. · R$ total" + botão "Excluir" (limpar seleção) |
| **Botão "Gerar Composição"** | Aparece quando tipo = "Junto à Taxa Cond." |
| **Botão "Gerar Boleto"** | Aparece quando tipo = "Boleto Avulso" |
| **Checkboxes Registro/Email** | Aparecem quando "Boleto Avulso", ligados ao state |
| **Carrinho (lote)** | Cubit agrupa itens por características e envia em batch |
| **Repository Batch** | `insertCobrancaAvulsaBatch()` envia ao Laravel API |

### 3.2 O que está INCOMPLETO / COM BUGS 🔴

| # | Item | Problema | Severidade |
|---|---|---|---|
| 1 | **Conta Contábil hardcoded** | O dropdown usa 10 opções fixas no código. Deveria buscar do banco (tabela `contas_contabeis`) e ter botão `+` para criar nova conta | 🔴 Alta |
| 2 | **Proprietário fixo "Proprietário"** | A coluna Proprietário na tabela de unidades mostra texto fixo `'Proprietário'`. Deveria buscar o nome do morador real da unidade | 🔴 Alta |
| 3 | **Mês/Ano só avança** | O seletor de mês/ano na aba Cadastrar só tem botão para avançar (clicando no dropdown icon), não tem botão para voltar | 🟡 Média |
| 4 | **Recorrente — Início/Fim não editáveis** | Os campos de data Início e Fim no modo recorrente são apenas `Container` com `Text`, não tem interação para selecionar data | 🔴 Alta |
| 5 | **Recorrente — Qtd.Meses não editável** | O campo mostra `state.qtdMeses` mas não tem input para editar. O `_qtdMesesController` existe mas não está conectado | 🔴 Alta |
| 6 | **Checkboxes Registro/Email** | Têm `onChanged` com `// TODO`, não estão conectados ao Cubit | 🟡 Média |
| 7 | **Upload de anexo/foto** | Não há nenhum componente de upload na aba Cadastrar (só existe no state + repository) | 🔴 Alta |
| 8 | **Campo "Link"** | O `_linkController` é declarado mas nunca usado no UI | 🟡 Média |
| 9 | **Dia de vencimento** | Só aparece quando "Boleto Avulso". Não tem validação de min/max (1-31) | 🟡 Média |
| 10 | **contaContabilId no payload** | O repository envia `contaContabilId` ao backend, mas o `CobrancaController.php` não recebe/trata esse campo | 🟡 Média |
| 11 | **Tipo de cobrança "Junto à Taxa"** | O botão "Gerar Composição" chama `adicionarAoCarrinho()` que é o mesmo fluxo do boleto avulso. A lógica de "junto à taxa" (registrar como composição do boleto mensal sem gerar boleto ASAAS) **não está implementada** | 🔴 Alta |
| 12 | **FloatingActionButton conflito** | O FAB "Gerar X Cobrança(s)" na `cobranca_avulsa_screen.dart` é acionado pelo carrinho, mas compete com o botão "Gerar Composição" da tab. Ambos fazem ações diferentes mas geram confusão | 🟡 Média |
| 13 | **Texto de ajuda visível** | Há textos como `'↑ visível apenas quando Recorrente = Sim'` e `'★ Boleto Avulso: mostra campo de dia...'` visíveis para o usuário final. São anotações de dev que precisam ser removidas | 🟡 Média |
| 14 | **Valor zero aceito** | Se o usuário não preencher valor e clicar "Gerar", o cubit exibe erro genérico. Não há validação visual no campo | 🟡 Média |

### 3.3 Fluxo Completo Esperado (End-to-End)

```
1. Usuário seleciona Conta Contábil → 2. Define Mês/Ano de referência
→ 3. Escreve Descrição → 4. Escolhe "Junto à Taxa" ou "Boleto Avulso"
→ 5. (Opcional) Marca Recorrente e define período
→ 6. Busca unidades → 7. Seleciona unidades + define valor por unidade
→ 8. Clica "Gerar Composição" ou "Gerar Boleto"
   → Se "Gerar Boleto": Chama API Laravel → Cria no ASAAS → Salva no Supabase
   → Se "Junto à Taxa": Registra composição local para o boleto mensal
```

---

## 4. Aba "Pesquisar" — Status

| Funcionalidade | Status |
|---|---|
| Dropdown Conta Contábil + botão `+` | ✅ UI presente |
| Busca por unidade/bloco/nome | ✅ Conectado ao cubit |
| Seletor Mês/Ano (com setas) | ✅ Funcional |
| Botão Pesquisar | ⚠️ Usa `condominioId` hardcoded `'COND_ID_FIXO'` |
| Tabela de resultados | ✅ Funcional (listholder) |
| Checkbox seleção individual/todos | ✅ Funcional |
| Botão Excluir (lote) | ✅ Funcional via Supabase `.delete()` |
| Rodapé: Qtidade + Total R$ | ✅ Calculado via getters |
| Coluna Status (Pago/Pendente) | ✅ Exibida |

> **Bug principal:** O `condominioId` na aba Pesquisar está hardcoded como `'COND_ID_FIXO'` no `onPressed` do botão Pesquisar (linha 133 do `pesquisar_cobranca_tab.dart`). Deveria usar o ID real do condomínio passado via Cubit.

---

## 5. Mapa de Arquivos e Responsabilidades

| Arquivo | Linhas | Papel |
|---|---|---|
| `cobranca_avulsa_screen.dart` | 160 | Scaffold principal, TabBar, BlocProvider, FAB |
| `cadastrar_cobranca_tab.dart` | 780 | Formulário completo da aba Cadastrar |
| `pesquisar_cobranca_tab.dart` | 268 | Listagem e filtros da aba Pesquisar |
| `cobranca_avulsa_cubit.dart` | 316 | Lógica de negócio, carrinho, persistência |
| `cobranca_avulsa_state.dart` | 148 | Estado reativo (23+ campos) |
| `cobranca_avulsa_entity.dart` | 73 | Entidade de domínio (16 campos) |
| `cobranca_avulsa_model.dart` | 58 | Model com fromJson/toJson |
| `cobranca_avulsa_repository.dart` | 115 | CRUD Supabase + chamada API Laravel |
| `cobranca_avulsa_email_service.dart` | 33 | Disparo de e-mail via Resend |
| `CobrancaController.php` | 187 | Controller Laravel (gerar-avulsa) |
| `CobrancaService.php` | 273 | Service ASAAS + Supabase (gerarAvulsa) |
