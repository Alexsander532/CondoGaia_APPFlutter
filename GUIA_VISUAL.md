# 📸 Guia Visual - Usando o Dropdown de Cidades

## Passo a Passo com Imagens/Descrições

### 🔴 Passo 1: Abrir a Tela

```
HOME
  ↓
"Cadastrar Condomínio"
  ↓
Tela de Cadastro Abre
```

---

### 🔴 Passo 2: Selecionar Estado

**Imagem esperada:**
```
┌─────────────────────────┐
│ Estado: *         ▼      │
├─────────────────────────┤
│ [ Dropdown aberto ]     │
│ AC - Acre               │
│ AL - Alagoas            │
│ AP - Amapá              │
│ ...                     │
│ MG - Minas Gerais ← Clique aqui
│ ...                     │
└─────────────────────────┘
```

**Ação:** Clique em "MG - Minas Gerais" (ou outro estado)

**Resultado:** Estado fica selecionado
```
┌─────────────────────────┐
│ Estado: *               │
├─────────────────────────┤
│ MG - Minas Gerais ▼     │
└─────────────────────────┘
```

---

### 🔴 Passo 3: Campo de Cidade Aparece

**Imagem esperada:**
```
┌──────────────────────────────────────┐
│ Estado: *       │ Cidade: *          │
├─────────────────┼────────────────────┤
│ MG - MG    ▼    │ Digite ou sel...▼  │
│                 │                    │
└─────────────────┴────────────────────┘
```

**O que acontece:** 
- Campo "Cidade" agora está habilitado
- Mostra placeholder "Digite ou selecione uma..."

---

### 🔴 Passo 4: Clicar no Campo de Cidade

**Imagem esperada:**
```
┌──────────────────────────────────────┐
│ Estado: *       │ Cidade: *          │
├─────────────────┼────────────────────┤
│ MG - MG    ▼    │ Digite ou sel...▼  │
│                 │                    │
│     ┌─ DROPDOWN APARECE ACIMA ─┐    │
│     │ Abadia dos Dourados      │    │
│     │ Abaeté                   │    │
│     │ Abre Campo               │    │
│     │ Acaiaca                  │    │
│     │ Aguanil                  │    │
│     │ [scroll para mais...]    │    │
│     └──────────────────────────┘    │
│                 │                    │
└─────────────────┴────────────────────┘
```

**Ação:** Clique **dentro** do campo de texto "Digite ou selecione..."

**Resultado:** Dropdown aparece **acima** do campo com todas as 853 cidades

---

### 🔴 Passo 5: Filtrar Cidades (Opcional)

**Você pode:**
1. Apenas scrollar na lista
2. Ou digitar para filtrar

**Exemplo - Digitando "São":**

```
Campo agora tem: "São"
                 ↓
┌──────────────────────────────────────┐
│     ┌─ DROPDOWN FILTRANDO ─┐         │
│     │ São Bento do Sapucaí │         │
│     │ São Brás do Suaçuí    │         │
│     │ São Félix de Minas    │         │
│     │ São Francisco         │         │
│     │ São Gonçalo do Rio... │         │
│     │ [scroll...]           │         │
│     └─────────────────────────┘      │
│                                      │
└──────────────────────────────────────┘
```

**Resultado:** Lista filtrrada apenas cidades com "São" no nome

---

### 🔴 Passo 6: Selecionar uma Cidade

**Você pode clicar em qualquer uma:**

```
Opção A: Usar Scroll
  - Scroll para achar a cidade
  - Clique nela

Opção B: Usar Filtro
  - Digite para filtrar
  - Clique na que apareceu
```

**Exemplo - Selecionando "São Paulo":**

1. **Antes:**
   ```
   Campo: [Digite ou selecione...]
   ```

2. **Você digita:** "paulo"
   ```
   Campo: [paulo]
   
   Dropdown mostra:
   ├─ São Paulo
   └─ (só 1 resultado)
   ```

3. **Você clica:** em "São Paulo"
   ```
   Campo: [São Paulo] ✅
   
   Dropdown FECHA automaticamente
   Keyboard FECHA automaticamente
   ```

---

### ✅ Passo 7: Campo Preenchido

**Imagem final:**
```
┌──────────────────────────────────────┐
│ Estado: *       │ Cidade: *          │
├─────────────────┼────────────────────┤
│ MG - MG    ▼    │ São Paulo       ▼  │
│                 │                    │
└─────────────────┴────────────────────┘
         ✅ PRONTO!
```

Campo agora mostra:
- **Estado:** MG (Minas Gerais)
- **Cidade:** São Paulo

---

## 🎯 Funcionalidades Extras

### 🗑️ Limpar Seleção

Se mudar de ideia, há um ícone **X** no final do campo:

```
Antes: [São Paulo] ✅
                    ↑ Clique aqui (X)
Depois: [Digite ou selecione...] ✓
```

### 🔄 Mudar de Estado

Se selecionar outro estado:

1. Dropdown fecha
2. Campo "Cidade" limpa
3. Nova lista de cidades carrega para novo estado
4. Pronto para selecionar outra cidade

---

## ⚠️ Se Algo Não Funcionar

### ❌ Dropdown não aparece

**Possibilidade:** Está fora de tela (scrolle para cima)
**Solução:** Use Scroll na tela inteira

### ❌ Nenhuma cidade aparece

**Possibilidade:** Ainda está carregando (vê um círculo de loading)
**Solução:** Aguarde 2-3 segundos

### ❌ Campo não deixa digitar

**Possibilidade:** Não selecionou nenhum estado
**Solução:** Selecione um estado primeiro

---

## 📝 Resumo dos Passos

| Passo | O que fazer | Resultado |
|-------|------------|-----------|
| 1 | Clique em "Cadastrar Condomínio" | Tela abre |
| 2 | Selecione um estado no dropdown | Campo "Cidade" ativa |
| 3 | Clique no campo "Cidade" | Dropdown aparece acima |
| 4 | (Opcional) Digite para filtrar | Lista reduz |
| 5 | Clique em uma cidade | Campo preenchido ✅ |
| 6 | Selecione outros campos | Formulário completo |
| 7 | Clique "SALVAR" | Condomínio criado ✅ |

---

## ✨ Dicas Extras

💡 **Tip 1:** Digite rapidinho - o filtro é instantâneo!
💡 **Tip 2:** Não precisa terminar de digitar - "paulo" acha "São Paulo"
💡 **Tip 3:** Se errar, clique no X para limpar e tente outra
💡 **Tip 4:** Cache funciona - segunda vez é mais rápido!

---

**Aproveite sua nova funcionalidade! 🎉**

