# 🔧 Guia de Debug - Problema com Seleção de Cidades

## 📋 Problema Relatado
Quando o usuário seleciona um estado, os municípios não aparecem no dropdown de cidades.

---

## 🎯 Logs Adicionados

Foi adicionado um sistema completo de logs em 3 arquivos para rastrear o fluxo:

### 1. **IBGEService** (`lib/services/ibge_service.dart`)
Rastreia a requisição à API IBGE:

```
🔵 [IBGEService] Iniciando busca de cidades para UF: SP
🔍 [IBGEService] Procurando código IBGE para: SP
✓ [IBGEService] Código IBGE encontrado: 35
🌐 [IBGEService] URL da API: https://servicodados.ibge.gov.br/...
📤 [IBGEService] Enviando requisição HTTP GET...
📥 [IBGEService] Resposta recebida com status: 200
📦 [IBGEService] JSON decodificado com sucesso
📊 [IBGEService] Total de municipios na resposta: 645
✅ [IBGEService] Convertendo 645 cidades para objetos Cidade
📋 [IBGEService] Primeiras 5 cidades: Abaete, Abadia dos Dourados, Abaeté, ...
💾 [IBGEService] Cidades armazenadas em CACHE para reutilização
✨ [IBGEService] Busca concluída com sucesso! Total: 645 cidades
```

### 2. **CidadeFilteredDropdown** (`lib/widgets/cidade_filtered_dropdown.dart`)
Rastreia o widget e carregamento de cidades:

```
🟢 [CidadeFilteredDropdown] initState chamado
🟡 [CidadeFilteredDropdown] UF selecionado detectado, carregando cidades...
🔄 [CidadeFilteredDropdown] didUpdateWidget chamado
🟢 [CidadeFilteredDropdown] MUDANÇA DE UF DETECTADA: SP
🟡 [CidadeFilteredDropdown._carregarCidades] Iniciando carregamento para: SP
📞 [CidadeFilteredDropdown._carregarCidades] Chamando IBGEService.buscarCidades(SP)
✅ [CidadeFilteredDropdown._carregarCidades] Retorno do IBGEService: 645 cidades
🔵 [CidadeFilteredDropdown._carregarCidades] setState completado
   - _cidades.length: 645
   - _cidadesFiltradas.length: 645
   - _isLoading: false
```

### 3. **CadastroCondominioScreen** (`lib/screens/ADMIN/cadastro_condominio_screen.dart`)
Rastreia a seleção de estado e cidade:

```
🟢 [CadastroCondominioScreen] Estado selecionado: SP
   - _estadoSelecionado atualizado para: SP
🟢 [CadastroCondominioScreen] Cidade selecionada no callback: São Paulo
   - _cidadeSelecionada atualizada para: São Paulo
```

---

## 🚀 Como Testar e Capturar Logs

### Opção 1: Android Studio / IntelliJ (Recomendado)

1. **Abra o projeto no Android Studio**
2. **Abra a aba "Logcat"** (inferior da tela)
3. **Execute o app:**
   ```bash
   flutter run
   ```
4. **No Logcat, filtre por:**
   ```
   IBGEService|CidadeFilteredDropdown|CadastroCondominioScreen
   ```
5. **Navegue para a tela de Cadastro de Condomínio**
6. **Selecione um estado**
7. **Observe os logs aparecendo**

### Opção 2: Terminal (Alternativa)

```bash
# Execute o app
flutter run

# Em outro terminal, veja os logs
flutter logs
```

### Opção 3: VS Code

1. **Execute o app em Debug:**
   ```
   Debug > Start Debugging
   ```
2. **Abra a aba "Debug Console"** (inferior)
3. **Veja os logs enquanto interage com o app**

---

## 🔍 Fluxo Esperado (com logs)

### Quando abre a tela:
```
🟢 [CidadeFilteredDropdown] initState chamado
   - Estado selecionado: null
   - Cidade selecionada: null
⚪ [CidadeFilteredDropdown] Nenhum UF selecionado no initState
```

### Quando seleciona um estado (ex: SP):
```
🟢 [CadastroCondominioScreen] Estado selecionado: SP
   - _estadoSelecionado atualizado para: SP

🔄 [CidadeFilteredDropdown] didUpdateWidget chamado
   - UF anterior: null
   - UF novo: SP

🟢 [CidadeFilteredDropdown] MUDANÇA DE UF DETECTADA: SP

🟡 [CidadeFilteredDropdown._carregarCidades] Iniciando carregamento para: SP

📞 [CidadeFilteredDropdown._carregarCidades] Chamando IBGEService.buscarCidades(SP)

🔵 [IBGEService] Iniciando busca de cidades para UF: SP
🔍 [IBGEService] Procurando código IBGE para: SP
✓ [IBGEService] Código IBGE encontrado: 35
🌐 [IBGEService] URL da API: https://servicodados.ibge.gov.br/...
📤 [IBGEService] Enviando requisição HTTP GET...
📥 [IBGEService] Resposta recebida com status: 200
📦 [IBGEService] JSON decodificado com sucesso
📊 [IBGEService] Total de municipios na resposta: 645
✅ [IBGEService] Convertendo 645 cidades para objetos Cidade
💾 [IBGEService] Cidades armazenadas em CACHE

✅ [CidadeFilteredDropdown._carregarCidades] Retorno do IBGEService: 645 cidades

🔵 [CidadeFilteredDropdown._carregarCidades] setState completado
   - _cidades.length: 645
   - _cidadesFiltradas.length: 645
   - _isLoading: false
```

---

## 🐛 Possíveis Problemas e Soluções

### ❌ Logs não aparecem do IBGEService

**Causa:** O `didUpdateWidget` não está sendo chamado
- Verificar se o `estadoSelecionado` está realmente mudando
- Ver se o widget pai está fazendo `setState` corretamente

**Solução:**
1. Procure por um log como: `🔄 [CidadeFilteredDropdown] didUpdateWidget chamado`
2. Se não aparecer, o estado não está sendo propagado

### ❌ Logs do IBGEService aparecem mas retorna erro 404

**Causa:** Código IBGE pode estar inválido
- Verificar se o mapa de UF→Código está correto

**Logs esperados para erro:**
```
❌ [IBGEService] UF inválido: XX
ou
❌ [IBGEService] Erro ao buscar cidades: 404
```

### ❌ Requisição leva mais de 10 segundos

**Causa:** Timeout na API
- API IBGE pode estar lenta ou sem internet

**Logs esperados:**
```
⏱️ [IBGEService] TIMEOUT: Requisição levou mais de 10 segundos
```

### ❌ setState chamado mas cidades não aparecem na UI

**Causa:** Pode ser um problema de renderização
- Verificar se o `_cidadesFiltradas` está realmente sendo populado
- Logs devem mostrar: `_cidadesFiltradas.length: 645`

---

## 📊 Checklist de Debug

Ao testar, verificar se os seguintes logs aparecem **na ordem**:

- [ ] `🟢 [CidadeFilteredDropdown] initState chamado`
- [ ] `🟢 [CadastroCondominioScreen] Estado selecionado: SP`
- [ ] `🔄 [CidadeFilteredDropdown] didUpdateWidget chamado`
- [ ] `🟢 [CidadeFilteredDropdown] MUDANÇA DE UF DETECTADA`
- [ ] `📞 [CidadeFilteredDropdown._carregarCidades] Chamando IBGEService`
- [ ] `🔵 [IBGEService] Iniciando busca de cidades`
- [ ] `📤 [IBGEService] Enviando requisição HTTP GET`
- [ ] `📥 [IBGEService] Resposta recebida com status: 200`
- [ ] `✅ [CidadeFilteredDropdown._carregarCidades] Retorno do IBGEService`
- [ ] `🔵 [CidadeFilteredDropdown._carregarCidades] setState completado`
- [ ] `_cidadesFiltradas.length: X` (deve ser > 0)

---

## 🎯 Próximos Passos

1. **Execute o app com logs**
2. **Capture a saída do terminal**
3. **Compartilhe os logs aqui**
4. Com os logs, poderei identificar exatamente onde está o problema

---

## 💡 Dica Pro

Para facilitar a captura, você pode:

1. **Abrir o app**
2. **Clicar em "Cadastrar Condomínio"**
3. **Selecionar um estado qualquer**
4. **Copiar todos os logs que aparecerem**
5. **Me enviar os logs**

Os logs conterão todos os detalhes necessários para resolver o problema!

---

