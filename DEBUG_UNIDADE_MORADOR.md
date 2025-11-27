# 🔍 DEBUG - Unidade Morador (Sem Unidades Aparecendo)

## 📋 Logs Adicionados

Foi adicionado um sistema completo de logs para debugar o problema de unidades não aparecerem quando você acessa "Morador/Unidade" com um representante de outro condomínio.

### Pontos de Log

#### 1. **GestaoScreen** (quando clica em "Morador/Unidade")
```
🚀 [GestaoScreen] Navegando para UnidadeMoradorScreen
   condominioId: ...
   condominioNome: ...
   condominioCnpj: ...
```

#### 2. **UnidadeMoradorScreen - initState()**
```
📱 [UnidadeMoradorScreen] initState() chamado
📱 [UnidadeMoradorScreen] condominioId recebido: ...
📱 [UnidadeMoradorScreen] condominioNome recebido: ...
📱 [UnidadeMoradorScreen] condominioCnpj recebido: ...
```

#### 3. **UnidadeMoradorScreen - _carregarDados()**
```
📱 [UnidadeMoradorScreen] ===== INICIANDO CARREGAMENTO DE DADOS =====
📱 [UnidadeMoradorScreen] condominioId: [ID]
📱 [UnidadeMoradorScreen] condominioNome: [NOME]
```

#### 4. **UnidadeService - listarUnidadesCondominio()**
```
🔍 [UnidadeService] Iniciando listarUnidadesCondominio
🔍 [UnidadeService] condominioId: [ID]
🔍 [UnidadeService] Response recebido: [TYPE]
🔍 [UnidadeService] Response é null: [true/false]
🔍 [UnidadeService] Response value: [VALUE]
📊 [UnidadeService] Quantidade de blocos na resposta: [COUNT]
🔍 [UnidadeService] Processando item: [ITEM]
✅ [UnidadeService] Total de blocos processados: [COUNT]
```

#### 5. **UnidadeMoradorScreen - Resultado Final**
```
✅ [UnidadeMoradorScreen] Dados carregados com sucesso!
📊 [UnidadeMoradorScreen] Total de blocos retornados: [COUNT]
   Bloco 0: [NOME] - [QUANTIDADE] unidades
      Unidade 1: [NUMERO] ([ID])
      Unidade 2: [NUMERO] ([ID])
```

## 🚀 Como Ver os Logs

### Opção 1: Terminal do Flutter (Recomendado)
1. Abra um terminal na pasta do projeto
2. Execute:
   ```bash
   flutter run
   ```
3. Os logs aparecerão em tempo real no terminal

### Opção 2: Android Studio Logcat
1. Abra Android Studio
2. Vá em **View** > **Tool Windows** > **Logcat**
3. Selecione seu dispositivo/emulador
4. Procure pelos prefixos: `📱`, `🔍`, `✅`, `❌`

### Opção 3: VS Code Debug Console
1. Pressione `F5` para iniciar debug
2. Vá em **Debug Console** (aba inferior)
3. Os logs aparecerão lá

## 📊 O que Procurar

### ✅ Cenário Esperado (Funcionando)
```
🚀 [GestaoScreen] Navegando para UnidadeMoradorScreen
   condominioId: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   condominioNome: Condomínio XYZ
   condominioCnpj: XX.XXX.XXX/0001-XX

📱 [UnidadeMoradorScreen] initState() chamado
📱 [UnidadeMoradorScreen] condominioId recebido: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

🔍 [UnidadeService] Iniciando listarUnidadesCondominio
📊 [UnidadeService] Quantidade de blocos na resposta: 4

✅ [UnidadeMoradorScreen] Dados carregados com sucesso!
📊 [UnidadeMoradorScreen] Total de blocos retornados: 4
   Bloco 0: A - 6 unidades
      Unidade 1: 101 (uuid...)
      Unidade 2: 102 (uuid...)
```

### ❌ Cenário com Erro (Vazio)
```
🚀 [GestaoScreen] Navegando para UnidadeMoradorScreen
   condominioId: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

📱 [UnidadeMoradorScreen] initState() chamado

🔍 [UnidadeService] Response recebido: Null
⚠️  [UnidadeService] Response é null, retornando lista vazia
```

ou

```
🔍 [UnidadeService] Quantidade de blocos na resposta: 0
✅ [UnidadeMoradorScreen] Dados carregados com sucesso!
📊 [UnidadeMoradorScreen] Total de blocos retornados: 0
```

## 🔧 Checklist de Debug

Quando você entrar como representante de um condomínio diferente e clicar em "Morador/Unidade", procure:

- [ ] condominioId é diferente do primeiro condomínio?
- [ ] O response da RPC retorna NULL?
- [ ] O response retorna uma lista vazia `[]`?
- [ ] O response retorna blocos, mas sem unidades?
- [ ] A mensagem de erro aparece na tela?

## 💡 Possíveis Causas

1. **condominioId NULL**: O representante não tem condomínioId definido corretamente
2. **Response NULL**: Problema na RPC do Supabase ou permissões RLS
3. **Response vazio**: Não há blocos criados para este condomínio
4. **Blocos mas sem unidades**: As unidades não foram criadas ou estão com `ativo = false`
5. **Erro de RLS**: O usuário não tem permissão de acessar os dados do condomínio

## 📝 Próximos Passos

Após fazer o teste:

1. Compartilhe os logs que aparecerem (copie do terminal/console)
2. Especifique qual cenário você está vendo (vazio, null, erro, etc.)
3. Indicar qual representante e qual condomínio você usou

Com os logs, será possível identificar exatamente onde está o problema! 🎯
