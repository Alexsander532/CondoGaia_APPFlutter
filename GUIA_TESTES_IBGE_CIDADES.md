# 📋 Guia de Testes - Integração IBGE API para Cidades

## 🎯 Objetivo
Validar a funcionalidade de seleção de cidades via API do IBGE na tela de cadastro de condomínio.

---

## ✅ Casos de Teste

### Teste 1: Seleção de Estado
**Passos:**
1. Abra a tela de cadastro de condomínio
2. Clique no dropdown de "Estado"
3. Selecione um estado qualquer (ex: São Paulo - SP)

**Resultado esperado:**
- Estado é selecionado corretamente
- Campo "Cidade" fica habilitado
- Uma mensagem aparece indicando "Selecione um estado primeiro" desaparece

---

### Teste 2: Carregamento de Cidades
**Passos:**
1. Selecione um estado (ex: São Paulo - SP)
2. Clique no campo "Cidade"
3. Aguarde o carregamento das cidades

**Resultado esperado:**
- Um spinner de carregamento aparece
- Após 2-3 segundos, lista de cidades é exibida
- Cidades aparecem em ordem alfabética
- Exemplo: Abaete, Abadia dos Dourados, Abaeté...

---

### Teste 3: Filtro em Tempo Real
**Passos:**
1. Selecione um estado (ex: São Paulo - SP)
2. Clique no campo "Cidade"
3. Digite "São" no campo de busca
4. Observe a lista sendo filtrada
5. Continue digitando "Paulo"

**Resultado esperado:**
- A lista de cidades filtra conforme você digita
- Apenas cidades contendo "São" aparecem
- Quando digita "Paulo", apenas "São Paulo" aparece
- Filtro é case-insensitive (funciona com maiúsculas e minúsculas)

---

### Teste 4: Seleção de Cidade
**Passos:**
1. Selecione um estado (ex: São Paulo - SP)
2. Clique no campo "Cidade"
3. Digite "São Paulo"
4. Clique na opção "São Paulo" da lista

**Resultado esperado:**
- Campo "Cidade" mostra "São Paulo" selecionado
- Dropdown fecha automaticamente
- Keyboard fecha

---

### Teste 5: Limpeza de Seleção
**Passos:**
1. Selecione uma cidade qualquer
2. Clique no ícone "X" (clear) que aparece à direita do campo
3. Observe a lista

**Resultado esperado:**
- Campo "Cidade" fica vazio
- Lista de todas as cidades reaparece

---

### Teste 6: Mudança de Estado
**Passos:**
1. Selecione um estado (ex: São Paulo - SP)
2. Selecione uma cidade (ex: São Paulo)
3. Mude para outro estado (ex: Rio de Janeiro - RJ)

**Resultado esperado:**
- Campo "Cidade" é limpo automaticamente
- Nova lista de cidades do RJ é carregada
- Cidade anterior (São Paulo - SP) não aparece na nova lista
- Apenas cidades do RJ aparecem

---

### Teste 7: Validação de Campos Obrigatórios
**Passos:**
1. Preencha todos os campos EXCETO "Cidade"
2. Clique em "SALVAR"

**Resultado esperado:**
- Mensagem de erro: "Por favor, preencha todos os campos obrigatórios da seção Dados."
- Condomínio NÃO é salvo

**Passos 2:**
1. Preencha todos os campos EXCETO "Estado"
2. Clique em "SALVAR"

**Resultado esperado:**
- Mensagem de erro: "Por favor, preencha todos os campos obrigatórios da seção Dados."
- Condomínio NÃO é salvo

---

### Teste 8: Salvamento Completo
**Passos:**
1. Preencha todos os campos obrigatórios:
   - CNPJ: 19.555.666/0001-69
   - Nome Condomínio: Condomínio Teste IBGE
   - CEP: 11123-456
   - Endereço: Rua Teste
   - Número: 100
   - Bairro: Bairro Teste
   - Estado: São Paulo (SP)
   - Cidade: São Paulo
2. Clique em "SALVAR"

**Resultado esperado:**
- Mensagem de sucesso: "Condomínio cadastrado com sucesso!"
- Formulário é limpo
- Estado e Cidade voltam a null/vazio
- Condomínio foi salvo no banco de dados com a cidade "São Paulo"

---

### Teste 9: Cache de Cidades
**Passos:**
1. Selecione um estado (ex: São Paulo - SP)
2. Clique no campo "Cidade"
3. Observe o tempo de carregamento (primeira vez: 2-3 segundos)
4. Mude para outro estado
5. Volte para São Paulo (SP)
6. Clique no campo "Cidade" novamente

**Resultado esperado:**
- Na primeira vez, aguarda o carregamento da API
- Na segunda vez, cidades aparecem INSTANTANEAMENTE (do cache)
- Sem delay ou spinner de carregamento
- Melhora a experiência do usuário

---

### Teste 10: Erro de Conexão
**Passos:**
1. Desligue a internet ou use Flight Mode
2. Selecione um estado (ex: São Paulo - SP)
3. Clique no campo "Cidade"
4. Aguarde 10 segundos

**Resultado esperado:**
- Mensagem de erro: "Erro ao carregar cidades: ..."
- Dropdown não exibe cidades
- Usuário pode tentar novamente quando internet voltar

---

## 🎨 Casos de Teste Visuais

### Teste 11: Aparência do Dropdown
**Esperado:**
- Campo com borda cinza leve
- Ícone de seta dropdown à direita quando vazio
- Ícone "X" à direita quando há valor
- Texto de hint: "Digite ou selecione uma cidade"
- Lista dropdown aparece abaixo do campo com fundo branco
- Itens alternam entre branco e cinza claro para melhor legibilidade
- Campo tem label "Cidade:" com asterisco vermelho (obrigatório)

---

## 📊 Estados Testados

Teste com pelo menos TRÊS estados diferentes:
1. ✅ São Paulo (SP) - 645 cidades
2. ✅ Rio de Janeiro (RJ) - 92 cidades
3. ✅ Minas Gerais (MG) - 853 cidades

---

## 🔍 Verificações Finais

- [ ] IBGEService carrega cidades corretamente
- [ ] Filtro funciona em tempo real
- [ ] Cache previne requisições desnecessárias
- [ ] Validação de campos obrigatórios funciona
- [ ] Dados são salvos corretamente no banco
- [ ] UI é responsiva e não congela durante o carregamento
- [ ] Mensagens de erro são claras
- [ ] Widget funciona em diferentes tamanhos de tela

---

## 🐛 Possíveis Problemas Conhecidos

Se encontrar algum erro durante os testes:

1. **Erro: "Undefined class 'Cidade'"**
   - Verificar se `lib/models/cidade.dart` existe
   - Verificar imports em `cadastro_condominio_screen.dart`

2. **Erro: "Timeout ao buscar cidades"**
   - Verificar conexão com internet
   - API do IBGE pode estar indisponível (raro)

3. **Cidades não aparecem ordenadas**
   - Verificar se o `sort()` está funcionando no IBGEService

4. **Filtro não funciona**
   - Verificar se `IBGEService.filtrarCidades()` está sendo chamado
   - Verificar case-sensitivity

---

## ✨ Notas Importantes

- API do IBGE é **pública e gratuita**
- Não requer autenticação
- Resposta é rápida (< 1 segundo normalmente)
- Dados são cacheados para evitar requisições repetidas
- Widget é **fully responsive** (funciona em web, mobile, tablet)

---

