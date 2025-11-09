# 🔧 GUIA DE DEBUG - Erro do Representante

## 📍 O Erro Que Você Está Vendo

```
PostgreException(message: invalid input syntax for type uuid: "rep-id-temp", 
code: 22P02, details: ..., hint: null)
```

## ✅ O QUE FOI CORRIGIDO

1. ✅ Adicionada variável `_representanteAtual` em `portaria_representante_screen.dart`
2. ✅ Adicionado método `_carregarRepresentanteAtual()` para obter dados reais
3. ✅ Modificado `initState()` para chamar `_carregarRepresentanteAtual()` PRIMEIRO
4. ✅ Atualizado `_buildMensagemTab()` para usar dados reais ao invés de `'rep-id-temp'`
5. ✅ Corrigido nome do campo: `nomeCompleto` (não `nome`)

## 🧪 COMO DEBUGAR AGORA

### Passo 1: Verificar Logs no Console

Quando você abrir a aba de mensagens, verifique o console Flutter:

```
🔍 Representante carregado: <ID_UUID> - <NOME>
✅ Representante ID VÁLIDO: <ID_UUID>
```

**Se vir isso**, significa que o representante foi carregado corretamente ✅

**Se vir:**
```
❌ Representante NULL ou ID vazio
❌ Erro ao carregar representante: <erro>
```

Significa que há um problema com `AuthService.getCurrentRepresentante()`

---

### Passo 2: Verificar se AuthService está Funcionando

Abra `lib/services/auth_service.dart` e procure:

```dart
static Future<Representante?> getCurrentRepresentante() async {
```

**Se o método existe**, então:
- ✅ Verifique se `Supabase.instance.client.auth.currentUser` retorna um usuário
- ✅ Verifique se a tabela `representantes` tem dados com esse `id`

**Se o método NÃO existe**, você precisa criá-lo

---

### Passo 3: Verificar Supabase

1. Abra Supabase Console
2. Navegue para tabela `representantes`
3. Procure pelo representante logado:
   - Campo `id` deve ser um UUID válido (ex: `3fa85f64-5717-4562-b3fc-2c963f66afa6`)
   - NÃO deve ser `rep-id-temp` ou algo genérico

4. Verifique tabela `mensagens`:
   - Campo `remetente_id` deve ter um UUID válido
   - NÃO `rep-id-temp`

---

## 🎯 DOIS CENÁRIOS POSSÍVEIS

### Cenário 1: AuthService.getCurrentRepresentante() Está NULL

**Problema**: O representante não está logado ou o método retorna null

**Solução**:
1. Verifique se o representante está logado corretamente
2. Adicione verificação em `_buildMensagemTab()`:

```dart
Widget _buildMensagemTab() {
  if (_isLoadingRepresentante) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_representanteAtual == null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('❌ Representante não logado'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _carregarRepresentanteAtual(),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  return ConversasSimples(
    condominioId: widget.condominioId!,
    representanteId: _representanteAtual.id,
    representanteName: _representanteAtual.nomeCompleto,
  );
}
```

### Cenário 2: ID Do Representante Está Vazio

**Problema**: `_representanteAtual.id` é vazio ou null

**Solução**:
1. Adicione validação antes de enviar mensagem:

```dart
Future<void> _enviarMensagem() async {
  if (_messageController.text.trim().isEmpty) return;
  
  // ✅ Validação CRÍTICA
  if (widget.representanteId == null || widget.representanteId!.isEmpty) {
    debugPrint('❌ ERRO: representanteId é vazio!');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro: ID do representante inválido')),
    );
    return;
  }

  try {
    await _mensagensService.enviar(
      conversaId: widget.conversaId,
      condominioId: widget.condominioId,
      remetenteTipo: 'representante',
      remententeId: widget.representanteId, // ✅ Deve ser UUID válido
      remetenteName: widget.representanteName,
      conteudo: _messageController.text.trim(),
    );
  } catch (e) {
    debugPrint('❌ Erro ao enviar: $e');
  }
}
```

---

## 📋 CHECKLIST DE DEBUG

- [ ] Console mostra `✅ Representante ID VÁLIDO`?
- [ ] `AuthService.getCurrentRepresentante()` retorna um objeto (não null)?
- [ ] Campo `id` do representante é um UUID válido (não `rep-id-temp`)?
- [ ] Tabela `representantes` no Supabase tem dados?
- [ ] Representante está logado (sessionStorage tem token)?
- [ ] Campo `representanteId` em `ConversasSimples` NÃO é vazio?

---

## 🚀 PRÓXIMO PASSO

Execute o app com:

```bash
flutter run -v
```

A flag `-v` mostrará todos os logs incluindo os `debugPrint()` que adicionei:

```
🔍 Representante carregado: ...
✅ Representante ID VÁLIDO: ...
```

**Compartilhe a saída do console** e poderemos debugar juntos!

---

## 🔍 LOGS IMPORTANTES QUE VOCÊ DEVE VER

### ✅ Esperado:
```
I  🔍 Representante carregado: 3fa85f64-5717-4562-b3fc-2c963f66afa6 - João da Silva
I  ✅ Representante ID VÁLIDO: 3fa85f64-5717-4562-b3fc-2c963f66afa6
I  Conversa criada com sucesso!
I  Mensagem enviada!
```

### ❌ NÃO Esperado:
```
E  ❌ Representante NULL ou ID vazio
E  ❌ Erro ao carregar representante: Invalid token
E  PostgresException(...invalid input syntax for type uuid: "rep-id-temp"...)
```

---

## 💡 DICA RÁPIDA

Se ainda receber o erro `rep-id-temp`, significa que em **ALGUM LUGAR** ainda há um hardcode com esse valor.

Faça uma busca global no projeto:

```bash
grep -r "rep-id-temp" lib/
```

Se encontrar, substitua por:
```dart
representante.id  // Do objeto carregado dinamicamente
```

---

## 🎯 AÇÃO IMEDIATA

1. ✅ Compile o app: `flutter pub get && flutter run`
2. ✅ Navegue até Portaria → Tab "Mensagem"
3. ✅ Verifique os logs no console Flutter
4. ✅ Compartilhe a saída dos logs comigo
5. ✅ Se funcionar, teste enviar uma mensagem
6. ✅ Verifique no Supabase se a mensagem foi inserida com UUID válido

