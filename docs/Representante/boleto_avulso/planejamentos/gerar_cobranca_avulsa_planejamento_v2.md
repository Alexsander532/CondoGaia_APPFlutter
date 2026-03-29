# Planejamento de Implementação v2 — Cobrança Avulsa / Desp. Extraordinárias

**Data:** 27/03/2026 — 19:25 (Sexta-feira)  
**Objetivo:** Finalizar a feature hoje à noite  
**Estimativa Restante:** ~6 a 8 horas de desenvolvimento

---

> [!NOTE]
> Este planejamento é uma **atualização da v1** (14/03/2026), adaptado ao estado atual do código.
> As Fases 1, 2 e 3 da v1 estão **100% concluídas**.
> As Fases 4, 5, 6, 7 e 8 estão **parcialmente concluídas** e foram reorganizadas em blocos de prioridade abaixo.

---

## 📊 Status Geral das Fases Originais

| Fase (v1) | Descrição | Status |
|---|---|---|
| Fase 1 | Setup e Navegação | ✅ 100% |
| Fase 2 | Modelagem e Supabase | ✅ 100% |
| Fase 3 | Layout e Tabs | ✅ 100% |
| Fase 4 | Aba Cadastrar — Formulário | 🟡 ~70% |
| Fase 5 | Aba Cadastrar — Tabela de Prévia | 🟡 ~60% |
| Fase 6 | Aba Pesquisar | 🟡 ~80% |
| Fase 7 | Regra de Negócio ASAAS/Supabase | 🟡 ~70% |
| Fase 8 | Testes e UX Review | 🔴 ~10% |

---

## 🔴 BLOCO A — Prioridade ALTA (Bugs que impedem uso) — ~2.5h

### A1. Corrigir `condominioId` hardcoded na aba Pesquisar (15min)
- **Arquivo:** `pesquisar_cobranca_tab.dart` (linha 133)
- **Problema:** `cubit.carregarCobrancas('COND_ID_FIXO')` usa string fixa
- **Solução:** Usar `cubit.condominioId` (já disponível no Cubit)

### A2. Buscar nome real do Proprietário/Morador (45min)
- **Arquivo:** `cadastrar_cobranca_tab.dart` (linha 593)
- **Problema:** Mostra texto fixo `'Proprietário'` para todas as unidades
- **Solução:** Enriquecer o model `Unidade` ou `BlocoComUnidades` com dados do morador (nome). Fazer JOIN com tabela `moradores` no `UnidadeService` ou buscar via endpoint separado

### A3. Campos Recorrente não funcionais (45min)
- **Arquivo:** `cadastrar_cobranca_tab.dart` (linhas 391-478)
- **Problema:** Início, Fim e Qtd.Meses são apenas visuais, não editáveis
- **Solução:**
  - Início/Fim: Adicionar `GestureDetector` → `showDatePicker()` ou picker de mês/ano
  - Qtd.Meses: Conectar ao `_qtdMesesController` ou usar `+`/`-` stepper
  - Auto-calcular: Quando Início e Qtd definidos, calcular Fim automaticamente

### A4. Lógica de "Junto à Taxa Cond." (45min)
- **Problema:** O botão "Gerar Composição" chama o mesmo `adicionarAoCarrinho()` que envia ao ASAAS. Deveria apenas registrar a composição na tabela `composicao_boleto` (ou similar) para ser incluída no próximo boleto mensal
- **Solução:** Criar método `adicionarComposicao()` no Cubit que salva no Supabase sem chamar ASAAS. O registro deve ficar associado ao condomínio/unidade/mês para ser agregado na geração mensal

---

## 🟡 BLOCO B — Prioridade MÉDIA (UX e completude) — ~2h

### B1. Contas Contábeis dinâmicas do banco (45min)
- **Problema:** Dropdown hardcoded com 10 opções fixas em ambas as abas
- **Solução:** Buscar da tabela `contas_contabeis` do Supabase. Se a tabela não existe, criar. Implementar botão `+` que abre modal de criação

### B2. Conectar checkboxes "Enviar para Registro" e "Disparar por Email" (15min)
- **Arquivo:** `cadastrar_cobranca_tab.dart` (linhas 700-718)
- **Problema:** `onChanged` tem `// TODO`
- **Solução:** Criar métodos `atualizarEnviarRegistro(bool)` e `atualizarEnviarEmail(bool)` no Cubit (state já tem os campos)

### B3. Seletor Mês/Ano bidirecional (15min)
- **Arquivo:** `cadastrar_cobranca_tab.dart` (linhas 182-195)
- **Problema:** Só tem seta para avançar mês
- **Solução:** Adicionar botão `chevron_left` ao lado do `chevron_right` para voltar o mês

### B4. Upload de anexo/foto (30min)
- **Problema:** Componente de upload não existe no UI (só no state + repository)
- **Solução:** Adicionar seção com botões "Anexar Foto" e "Link" após a área de unidades. Usar `ImagePicker` (já importado no Cubit) e `_linkController`

### B5. Remover textos de dev visíveis ao usuário (15min)
- **Linhas:** `'↑ visível apenas quando Recorrente = Sim'` (L474-477), `'★ Boleto Avulso: ...'` (L287-298), `'Valor editável inline por unidade...'` (L653-656)
- **Solução:** Remover ou transformar em comentários

---

## 🟢 BLOCO C — Prioridade BAIXA (Polish e validações) — ~1.5h

### C1. Validação do dia de vencimento (15min)
- Limitar input a range 1-31 com `inputFormatters`

### C2. Enviar `contaContabilId` no payload do backend (15min)
- Verificar se `CobrancaController.php` precisa receber e armazenar o `conta_contabil` no `boletos` do Supabase

### C3. Resolver conflito FAB vs botão inline (15min)
- Remover o `FloatingActionButton` ou torná-lo condicionalmente visível apenas quando há itens no carrinho e o usuário não está na tab Cadastrar

### C4. Validação visual de campos obrigatórios (15min)
- Conta Contábil não selecionada → borda vermelha
- Nenhuma unidade selecionada → mensagem
- Valor zero em unidade selecionada → destaque

### C5. Testes manuais end-to-end (30min)
- Testar: Selecionar conta → buscar unidades → selecionar unidades → definir valores → gerar boleto → verificar no Supabase e ASAAS
- Testar: Modo recorrente com 3 meses
- Testar: Aba pesquisar com filtros

---

## ⏰ Cronograma Sugerido (Hoje 27/03)

| Horário | Bloco | O que fazer |
|---|---|---|
| 19:30 – 20:00 | A1 + B5 | Fixes rápidos: condominioId, remover textos dev |
| 20:00 – 20:45 | A3 | Campos recorrente funcionais |
| 20:45 – 21:30 | A2 | Nome real do morador nas unidades |
| 21:30 – 22:00 | B2 + B3 | Checkboxes + seletor bidirecional |
| 22:00 – 22:30 | A4 | Lógica "Junto à Taxa" separada |
| 22:30 – 23:00 | B4 | Upload de foto/anexo |
| 23:00 – 23:30 | C1-C4 | Validações e polish |
| 23:30 – 00:00 | C5 | Testes manuais e ajustes finais |

---

## 📋 Checklist para "Feature Completa"

- [ ] Dropdown Conta Contábil dinâmico (ou funcional com opções corretas)
- [ ] Nome do morador real nas unidades
- [ ] Campos Recorrente (Início/Fim/Qtd) editáveis e integrados
- [ ] Lógica "Junto à Taxa Cond." separada da "Boleto Avulso"
- [ ] condominioId real na aba Pesquisar
- [ ] Checkboxes Registro/Email conectados
- [ ] Seletor Mês/Ano bidirecional
- [ ] Upload de foto/anexo funcional
- [ ] Textos de dev removidos
- [ ] Validações visuais nos campos obrigatórios
- [ ] Teste end-to-end com dados reais
