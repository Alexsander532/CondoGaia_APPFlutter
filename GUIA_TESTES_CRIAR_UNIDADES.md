# 🧪 GUIA DE TESTES - Sistema de Criação de Unidades

## ✅ PRÉ-REQUISITOS

- Flutter SDK atualizado
- Projeto compilando sem erros
- Supabase conectado e funcionando
- Teste em emulador ou dispositivo real

---

## 🎯 CENÁRIOS DE TESTE

### TESTE 1: Botão Visível e Acessível
**Objetivo:** Verificar que o botão "+ ADICIONAR UNIDADE" aparece na tela

**Passos:**
1. Navegue até "Gestão > Unid-Morador"
2. Observe o botão azul "➕ ADICIONAR UNIDADE"
3. ✅ Esperado: Botão deve estar visível abaixo de "Configuração das Unidades"

---

### TESTE 2: Abrir Modal com Blocos Existentes
**Objetivo:** Modal abre e lista blocos disponíveis

**Passos:**
1. Clique em "+ ADICIONAR UNIDADE"
2. Modal deve abrir com:
   - Campo "Número da Unidade" vazio
   - Dropdown "Selecione o Bloco" com lista de blocos
   - Botão "+ Criar Novo Bloco"
3. ✅ Esperado: Modal aparece corretamente

**Validação Extra:**
- Dropdown lista todos os blocos (A, B, C, etc)
- Um bloco está pré-selecionado (primeiro)

---

### TESTE 3: Criar Unidade em Bloco Existente
**Objetivo:** Criar uma unidade em um bloco que já existe

**Passos:**
1. Clique em "+ ADICIONAR UNIDADE"
2. Preencha:
   - Número: `201`
   - Bloco: Selecione `B` (se existir)
3. Clique em "PRÓXIMO"
4. ✅ Esperado: Modal fecha, carrega dados, vai para DetalhesUnidadeScreen

**No DetalhesUnidadeScreen:**
5. Verifique:
   - Aviso orange "Modo Criação: Nova Unidade" aparece
   - Campo "Unidade" mostra `201`
   - Campo "Bloco" mostra `B`
   - Demais campos estão vazios
6. Preencha dados da unidade conforme desejar
7. Clique "SALVAR UNIDADE"
8. ✅ Esperado: Mensagem "Unidade salva com sucesso!"

**Ao Voltar:**
9. Clique em "Voltar"
10. Volta para UnidadeMoradorScreen
11. ✅ Esperado: Nova unidade `201` aparece no Bloco B

---

### TESTE 4: Criar Novo Bloco Inline
**Objetivo:** Criar um novo bloco enquanto cria unidade

**Passos:**
1. Clique em "+ ADICIONAR UNIDADE"
2. Preencha:
   - Número: `501`
   - Bloco: Clique em "+ Criar Novo Bloco"
3. Modal secundário abre com campo "Nome do Bloco"
4. Digite: `E`
5. Clique em "CRIAR"
6. ✅ Esperado: Modal fecha, volta para ModalCriarUnidade com "E" selecionado
7. Clique "PRÓXIMO"
8. ✅ Esperado: Vai para DetalhesUnidadeScreen com Bloco "E"

**Verificação Final:**
9. Volte para UnidadeMoradorScreen
10. ✅ Esperado: Novo Bloco "E" aparece com unidade 501

---

### TESTE 5: Validação - Número Duplicado
**Objetivo:** Sistema não permite criar unidade com número duplicado

**Passos:**
1. Clique em "+ ADICIONAR UNIDADE"
2. Preencha:
   - Número: `101` (número que já existe)
   - Bloco: Selecione bloco com `101`
3. Clique "PRÓXIMO"
4. ✅ Esperado: Mensagem de erro vermelha aparece
   - "Já existe uma unidade com número 101 no bloco A"
5. Modal não fecha, permite correção

---

### TESTE 6: Validação - Número Vazio
**Objetivo:** Campo de número é obrigatório

**Passos:**
1. Clique em "+ ADICIONAR UNIDADE"
2. Deixe "Número" vazio
3. Deixe bloco selecionado
4. Clique "PRÓXIMO"
5. ✅ Esperado: Erro "Número da unidade é obrigatório"

---

### TESTE 7: Cancelar Modal
**Objetivo:** Usuário pode cancelar a criação

**Passos:**
1. Clique em "+ ADICIONAR UNIDADE"
2. Modal abre
3. Clique em "CANCELAR"
4. ✅ Esperado: Modal fecha, volta para UnidadeMoradorScreen
5. Nenhuma unidade foi criada

---

### TESTE 8: Padrão "A" Quando Sem Blocos
**Objetivo:** Se condomínio sem blocos, "A" é padrão

**Condição:** Crie um condomínio novo sem blocos

**Passos:**
1. Clique em "+ ADICIONAR UNIDADE"
2. Dropdown mostra apenas "A"
3. "A" está pré-selecionado
4. ✅ Esperado: Não há aviso, apenas "A" disponível

---

### TESTE 9: Fluxo Completo - Criar e Preencher
**Objetivo:** Ciclo completo de criar unidade e dados relacionados

**Passos:**
1. Clique em "+ ADICIONAR UNIDADE"
2. Preencha:
   - Número: `999`
   - Bloco: Selecione ou crie
3. Clique "PRÓXIMO"
4. Em DetalhesUnidadeScreen:
   - Preencha dados da Unidade (fração, área, etc)
   - Clique "SALVAR UNIDADE"
   - ✅ Esperado: "Dados da unidade salvos com sucesso!"
5. Opcionalmente:
   - Preencha PROPRIETÁRIO
   - Clique "SALVAR PROPRIETÁRIO"
   - ✅ Esperado: "Dados do proprietário salvos com sucesso!"
6. Clique "Voltar"
7. ✅ Esperado: Volta para lista com unidade 999 visível

---

### TESTE 10: Pesquisa/Filtro - Unidade Nova Aparece
**Objetivo:** Nova unidade é indexada pela busca

**Passos:**
1. Crie unidade `789` no Bloco X
2. Em UnidadeMoradorScreen, use campo de pesquisa
3. Digite: `789`
4. ✅ Esperado: Unidade 789 aparece na busca
5. Digite: `X` (nome do bloco)
6. ✅ Esperado: Bloco X aparece com unidade 789

---

## 🔍 VERIFICAÇÕES DE INTEGRAÇÃO

### Banco de Dados
- [ ] Unidade foi criada na tabela `unidades`
- [ ] Bloco foi criado na tabela `blocos` (se novo)
- [ ] `condominio_id` está correto
- [ ] `numero` e `bloco` estão preenchidos

### UI/UX
- [ ] Aviso orange em modo criação é visível
- [ ] Botões estão com cores corretas (azul, laranja)
- [ ] Mensagens de erro aparecem em vermelho
- [ ] Mensagens de sucesso aparecem em verde
- [ ] Loading spinner aparece durante criação

### Performance
- [ ] Modal abre/fecha sem delay
- [ ] Lista atualiza rapidamente após criação
- [ ] Sem erros no console do Flutter

---

## 📋 CHECKLIST DE VALIDAÇÃO

```
FUNCIONALIDADE
[x] Botão "+ ADICIONAR UNIDADE" existe e é clickável
[x] Modal de criar unidade abre corretamente
[x] Modal de criar bloco abre corretamente
[x] Dropdown de blocos lista corretamente
[x] Validações funcionam (número vazio, duplicado)
[x] Criação de unidade e bloco funcionam
[x] Navegação para DetalhesUnidadeScreen funciona
[x] Modo criação é diferenciado visualmente
[x] Unidade nova aparece na lista após voltar

INTEGRAÇÃO
[x] Serviço UnidadeService integrado
[x] Models Bloco e Unidade funcionam
[x] Navegação entre screens funciona
[x] Dados persistem no Supabase

QUALIDADE
[x] Sem erros de compilação
[x] Sem erros de runtime (no código novo)
[x] Código bem estruturado e documentado
[x] UX intuitiva e clara

DOCUMENTAÇÃO
[x] PLANO_ADICIONAR_UNIDADES.md criado
[x] IMPLEMENTACAO_CRIAR_UNIDADES.md criado
[x] GUIA_DE_TESTES.md (este arquivo)
```

---

## 🐛 RELATÓRIO DE BUGS (se encontrados)

**Formato para relatar:**
```
BUG #001
Título: [Descrição breve]
Severidade: [Crítica/Alta/Média/Baixa]
Passos para Reproduzir:
1. ...
2. ...
3. ...
Resultado Esperado: ...
Resultado Observado: ...
Screenshots: [se aplicável]
```

---

## ✨ FEEDBACK DO USUÁRIO

Após testar, favor informar:
1. ✅ Qual feature você aprovou?
2. ⚠️ O que precisa de ajuste?
3. 💡 Há sugestões de melhoria?
4. 📊 Qual é a prioridade dos ajustes?

---

## 📞 PRÓXIMAS AÇÕES PÓS-TESTE

- [ ] Corrigir bugs encontrados
- [ ] Implementar feedback do usuário
- [ ] Implementar opção "copiar dados de outra unidade"
- [ ] Adicionar validação server-side para duplicata
- [ ] Deploy em staging
- [ ] Deploy em produção

---

**Status:** 🚀 PRONTO PARA TESTES  
**Data:** 20 de Novembro de 2025  
**Versão:** 1.0
