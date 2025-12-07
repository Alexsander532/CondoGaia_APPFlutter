# 📖 Guia de Uso - Tela Push Notification Admin

## 🎯 Objetivo
Enviar notificações push para síndicos e/ou moradores de um condomínio, especificando a localização (UF e Cidade).

---

## 🚀 Como Acessar

```
1. Login como ADMIN
   ↓
2. Tela HOME do ADMIN
   ↓
3. Clique no botão "Push"
   ↓
4. Abre PushNotificationAdminScreen
```

---

## 📋 Campos do Formulário

### 1️⃣ **Título**
- **Tipo**: Text Input
- **Limite**: 3 a 100 caracteres
- **Obrigatório**: ✅ Sim
- **Validação**: Comprimento mínimo e máximo
- **Exemplo**: "Assembleia Condominial"

### 2️⃣ **Mensagem**
- **Tipo**: Text Area (multilinhas)
- **Linhas**: 3 a 5 (minimum e maximum)
- **Limite**: 10 a 500 caracteres
- **Obrigatório**: ✅ Sim
- **Validação**: Comprimento
- **Exemplo**: "Convite para Assembleia Geral Extraordinária no próximo sábado às 10h"

### 3️⃣ **Sinônicos** (Checkbox)
- **Tipo**: Checkbox
- **Função**: Incluir ou excluir síndicos dos destinatários
- **Padrão**: ❌ Desmarcado
- **Nota**: Pode selecionar síndicos E moradores simultaneamente

### 4️⃣ **Moradores** (Seletor com Busca)
- **Tipo**: Seletor com busca (checkboxes múltiplos)
- **Função**: Selecionar um ou mais moradores
- **Busca**: Busca por nome, unidade ou bloco
- **Obrigatório**: ✅ Sim (se não selecionar síndicos)
- **Padrão**: Vazio
- **Resumo**: Mostra quantidade de selecionados
- **Ação**: Botão "Limpar" para desselecionar todos

### 5️⃣ **UF (Estado)**
- **Tipo**: Dropdown (select)
- **Opções**: 27 estados brasileiros
- **Obrigatório**: ✅ Sim
- **Padrão**: Vazio
- **Função**: Filtra cidades disponíveis

### 6️⃣ **Cidade**
- **Tipo**: Dropdown (select)
- **Opções**: Depende do estado selecionado
- **Obrigatório**: ✅ Sim
- **Padrão**: Vazio
- **Função**: Cascata com UF (só habilita após UF selecionado)

---

## ⚙️ Validações

### Antes de Enviar
O sistema valida automaticamente:

✅ **Título**: 3-100 caracteres obrigatório  
✅ **Mensagem**: 10-500 caracteres obrigatório  
✅ **Destinatários**: Mínimo 1 (síndicos OU moradores)  
✅ **UF**: Selecionado obrigatoriamente  
✅ **Cidade**: Selecionada obrigatoriamente  

### Se houver erro
- ❌ Mostra **diálogo** com lista de erros
- ❌ **Não avança** para confirmação
- ❌ Usuário pode corrigir e tentar novamente

---

## 📤 Fluxo de Envio

### Passo 1: Preenchimento
```
Preencha todos os 6 campos do formulário
```

### Passo 2: Clique "ENVIAR"
```
Botão fica habilitado quando tudo está válido
- Se algum campo obrigatório estiver vazio → Botão desabilitado
- Se tudo está preenchido → Botão azul e clicável
```

### Passo 3: Validação
```
Sistema valida todos os campos
- Se erro → Mostra diálogo com mensagens
- Se OK → Passa para próximo passo
```

### Passo 4: Confirmação
```
Diálogo mostra resumo:
- Título digitado
- Mensagem digitada
- Quantidade de destinatários
- UF e Cidade selecionadas

Opções:
- [Cancelar] → Volta ao formulário (sem perdas)
- [Confirmar] → Prossegue com envio
```

### Passo 5: Envio
```
- Mostra spinner de loading
- Aguarda 2 segundos (simulado)
- Botão fica desabilitado
```

### Passo 6: Resultado
```
✅ SE SUCESSO:
   - Diálogo: "Notificação enviada com sucesso"
   - Formulário é **limpo automaticamente**
   - Ao clicar OK, volta para HOME

❌ SE ERRO:
   - Diálogo: "Erro ao enviar notificação"
   - Mostra detalhes do erro
   - Usuário pode tentar novamente
```

---

## 🎯 Exemplos de Uso

### Exemplo 1: Notificar Síndicos
```
Título: "Reunião Emergencial"
Mensagem: "Reunião de síndicos hoje às 19h para discutir reforma do telhado"
Sindicatos: ✅ Marcado
Moradores: (nenhum selecionado)
UF: São Paulo
Cidade: São Paulo
Clique: ENVIAR
```

### Exemplo 2: Notificar Moradores Específicos
```
Título: "Aviso de Manutenção"
Mensagem: "Manutenção na água de 08h às 12h amanhã. Favor não desperdiçar água"
Sindicatos: ❌ Desmarcado
Moradores: ✅ João Silva, Maria Santos, Pedro Oliveira (3 selecionados)
UF: Rio de Janeiro
Cidade: Rio de Janeiro
Clique: ENVIAR
```

### Exemplo 3: Notificar Síndicos + Moradores
```
Título: "Resultado da Assembleia"
Mensagem: "Resultado da votação sobre aumento da taxa condominial aprovado com 85% de votos"
Sindicatos: ✅ Marcado
Moradores: ✅ Selecionou 10 moradores
UF: Minas Gerais
Cidade: Belo Horizonte
Clique: ENVIAR
```

---

## 💡 Dicas e Truques

### 🔍 Busca de Moradores
- Digite o **nome** do morador
- Digite o **número da unidade** (ex: 101)
- Digite a **letra do bloco** (ex: A)
- A busca é **case-insensitive** (não importa maiúscula/minúscula)

### 📍 Seleção de Localização
- Primeiramente selecione um **UF**
- A lista de **Cidades** carrega automaticamente
- Se trocar de UF, a cidade é **resetada**

### ✏️ Edição
- Todos os campos podem ser **editados** antes de enviar
- Há botões para **limpar** campos específicos

### 🔄 Fluxo Cancelamento
- Se clicar "Cancelar" no diálogo de confirmação → **formulário não é perdido**
- Os dados permanecem preenchidos para edição

---

## 🎨 Indicadores Visuais

| Elemento | Significado |
|---|---|
| 🔵 Botão ENVIAR (azul) | Clicável e pronto |
| ⚫ Botão ENVIAR (cinza) | Desabilitado (faltam dados) |
| ⏳ Spinner no botão | Enviando notificação |
| ✅ Diálogo verde | Sucesso |
| ❌ Diálogo vermelho | Erro |
| 🔍 Ícone lupa | Campo de busca ativo |

---

## ❌ Erros Comuns

### Erro: "O título é obrigatório"
**Solução**: Preencha o campo de título com pelo menos 3 caracteres

### Erro: "O título não pode exceder 100 caracteres"
**Solução**: Reduza o texto do título para até 100 caracteres

### Erro: "A mensagem deve ter no mínimo 10 caracteres"
**Solução**: Digite uma mensagem mais longa (mínimo 10 caracteres)

### Erro: "A mensagem não pode exceder 500 caracteres"
**Solução**: Resuma sua mensagem para máximo 500 caracteres

### Erro: "Selecione pelo menos um destinatário"
**Solução**: Marque "Sindicatos" OU selecione pelo menos 1 morador

### Erro: "Selecione um estado"
**Solução**: Escolha um estado no dropdown UF

### Erro: "Selecione uma cidade"
**Solução**: Escolha uma cidade no dropdown Cidade (após selecionar UF)

---

## 🔐 Dados Mockados (para teste)

### Estados Disponíveis
Todos os 27 estados brasileiros (AC a TO)

### Cidades Disponíveis (exemplo)
- **SP**: São Paulo, Campinas, Santos, Ribeirão Preto, Sorocaba
- **RJ**: Rio de Janeiro, Niterói, Duque de Caxias, São Gonçalo, Itaboraí
- **MG**: Belo Horizonte, Uberlândia, Contagem, Juiz de Fora, Montes Claros

### Moradores Disponíveis
```
1. João Silva (101/A)
2. Maria Santos (102/A)
3. Pedro Oliveira (201/B)
4. Ana Costa (202/B)
5. Carlos Ferreira (301/C)
6. Lucia Rocha (302/C)
7. Felipe Gomes (103/A)
8. Patricia Lima (203/B)
9. Roberto Alves (303/C)
10. Beatriz Martins (104/A)
```

---

## ℹ️ Informações Adicionais

- **Enviado após**: 2 segundos (simulado)
- **Dados persistidos**: Após sucesso, formulário é limpo
- **Histórico**: Não está implementado nesta versão (próximo)
- **Agendamento**: Não está implementado nesta versão (próximo)

---

**✨ Pronto para usar!**
