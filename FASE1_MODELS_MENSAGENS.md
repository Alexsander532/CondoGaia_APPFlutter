# ✅ FASE 1 - MODELS (CONVERSA + MENSAGEM)

## 📋 Resumo

Implementação completa dos 2 models principais do sistema de mensagens:
- ✅ `Conversa` model
- ✅ `Mensagem` model

Ambos com:
- ✅ FromJson/ToJson para Supabase
- ✅ CopyWith para imutabilidade
- ✅ Getters helpers para lógica de UI
- ✅ Validação de tipos
- ✅ ToString, Equals e HashCode

---

## 📁 Arquivos Criados

### 1. `lib/models/conversa.dart`

**Classe**: `Conversa`

**Campos principais**:
```dart
- id (String)                            // UUID único
- condominioId (String)                  // FK para condomínio
- unidadeId (String)                     // FK para unidade
- usuarioTipo (String)                   // 'proprietario' | 'inquilino'
- usuarioId (String)                     // FK para usuário
- usuarioNome (String)                   // "João Moreira"
- unidadeNumero (String?)                // "A/400" (para exibir)
- representanteId (String?)              // FK para representante
- representanteNome (String?)            // "Portaria"
- assunto (String?)                      // Opcional
- status (String)                        // 'ativa' | 'arquivada' | 'bloqueada'
- totalMensagens (int)                   // Contador
- mensagensNaoLidasUsuario (int)        // Badge do usuário
- mensagensNaoLidasRepresentante (int)  // Badge da portaria
- ultimaMensagemData (DateTime?)         // Última atividade
- ultimaMensagemPor (String?)            // Quem enviou
- ultimaMensagemPreview (String?)        // Preview (truncado)
- notificacoesAtivas (bool)             // Flag de notificações
- prioridade (String)                    // 'baixa' | 'normal' | 'alta' | 'urgente'
- createdAt (DateTime)                   // Data de criação
- updatedAt (DateTime)                   // Última atualização
```

**Métodos principais**:

```dart
// Factory Constructor
factory Conversa.fromJson(Map<String, dynamic> json)

// Serialization
Map<String, dynamic> toJson()

// Imutabilidade
Conversa copyWith({...})

// Getters Helpers
bool get temMensagensNaoLidasParaUsuario
bool get temMensagensNaoLidasParaRepresentante
String get nomeParaBadge
String get subtituloPadrao          // Preview ou "Nenhuma mensagem ainda"
String get ultimaMensagemDataFormatada  // "Agora", "há 5m", "há 2h", etc

// Standard
@override operator ==
@override get hashCode
@override toString()
```

**Uso Esperado**:
```dart
// Criar da API
final conversa = Conversa.fromJson(supabaseJson);

// Modificar (imutável)
final updatedConversa = conversa.copyWith(
  status: 'arquivada',
  mensagensNaoLidasUsuario: 0,
);

// Exibir
Text(conversa.subtituloPadrao);  // "Olá, preciso de..."
Text(conversa.ultimaMensagemDataFormatada);  // "há 5m"
showBadge(conversa.mensagensNaoLidasUsuario);  // 3
```

---

### 2. `lib/models/mensagem.dart`

**Classe**: `Mensagem`

**Campos principais**:
```dart
- id (String)                   // UUID único
- conversaId (String)           // FK para conversa
- condominioId (String)         // FK para condomínio
- remetenteTipo (String)        // 'usuario' | 'representante'
- remetenteId (String)          // FK para usuário/representante
- remetenteNome (String)        // "João Moreira" ou "Portaria"
- conteudo (String)             // "Olá, preciso de ajuda"
- tipoConteudo (String)         // 'texto' | 'imagem' | 'arquivo' | 'audio'
- anexoUrl (String?)            // URL no storage
- anexoNome (String?)           // "documento.pdf"
- anexoTamanho (int?)           // Tamanho em bytes
- anexoTipo (String?)           // "application/pdf"
- status (String)               // 'enviada' | 'entregue' | 'lida' | 'erro'
- lida (bool)                   // Flag de leitura
- dataLeitura (DateTime?)       // Quando foi lida
- respostaAMensagemId (String?)// Para threads/respostas
- editada (bool)                // Flag de edição
- dataEdicao (DateTime?)        // Quando foi editada
- conteudoOriginal (String?)    // Para mostrar "editado"
- prioridade (String)           // 'baixa' | 'normal' | 'alta' | 'urgente'
- categoria (String?)           // Opcional (para filtros)
- createdAt (DateTime)          // Data de criação
- updatedAt (DateTime)          // Última atualização
```

**Métodos principais**:

```dart
// Factory Constructor
factory Mensagem.fromJson(Map<String, dynamic> json)

// Serialization
Map<String, dynamic> toJson()

// Imutabilidade
Mensagem copyWith({...})

// Getters Lógicos
bool get isRepresentante           // remetenteTipo == 'representante'
bool get isUsuario                 // remetenteTipo == 'usuario'
bool get isTexto                   // tipoConteudo == 'texto'
bool get temAnexo                  // anexoUrl != null && !empty

// Getters para Formatação
String get horaFormatada           // "09:15"
String get dataHoraFormatada       // "25/11 09h15"
String get iconeStatus             // "✓" | "✓✓" | "✗"
String get corStatus               // "#999999" | "#3498DB" | "#E74C3C"

// Standard
@override operator ==
@override get hashCode
@override toString()
```

**Uso Esperado**:
```dart
// Criar da API
final msg = Mensagem.fromJson(supabaseJson);

// Checar quem enviou
if (msg.isRepresentante) {
  // Alinha à esquerda (portaria)
} else {
  // Alinha à direita (usuário)
}

// Exibir bubble de mensagem
Container(
  color: msg.isRepresentante ? Colors.grey[100] : Colors.blue[50],
  child: Column(
    children: [
      Text(msg.conteudo),
      Row(
        children: [
          Text(msg.horaFormatada),
          Text(msg.iconeStatus, style: TextStyle(color: msg.corStatus)),
        ],
      ),
    ],
  ),
);

// Modificar (imutável)
final lida = msg.copyWith(
  lida: true,
  dataLeitura: DateTime.now(),
  status: 'lida',
);
```

---

## 🎯 Características Implementadas

### ✅ Tipagem Forte
- Todos os campos com tipos corretos
- Nullability explícita (String?, int?)
- Sem any casts desnecessários

### ✅ JSON Serialization
- fromJson: Supabase → Dart
- toJson: Dart → Supabase
- Trata nulls corretamente
- Converte timestamps automaticamente

### ✅ Imutabilidade
- copyWith para modificações
- Campos finais
- Padrão recomendado para Flutter

### ✅ Getters Helpers
- Lógica de UI separada dos dados
- Formatação de datas
- Badges e contadores
- Status de mensagem

### ✅ Igualdade
- operator == customizado (por ID)
- get hashCode para coleções
- toString() útil para debug

---

## 🔄 Fluxo de Dados

```
Supabase (JSON)
    ↓
fromJson()
    ↓
Conversa / Mensagem (Dart Objects)
    ↓
Getters helpers para UI
    ↓
Widget exibe dados formatados
```

### Exemplo Prático

```dart
// 1. Buscar conversa do Supabase
final json = await supabase
    .from('conversas')
    .select()
    .eq('id', conversaId)
    .single();

// 2. Converter para Dart
final conversa = Conversa.fromJson(json);

// 3. Usar em UI
ListTile(
  title: Text(conversa.usuarioNome),
  subtitle: Text(conversa.subtituloPadrao),
  trailing: conversa.temMensagensNaoLidasParaUsuario
      ? Badge(label: Text(conversa.mensagensNaoLidasUsuario.toString()))
      : null,
  onTap: () => navigateTo(conversa.id),
);

// 4. Modificar (imutável)
await updateConversa(
  conversa.copyWith(
    mensagensNaoLidasUsuario: 0,
    status: 'ativa',
  ),
);
```

---

## ✅ Validações Implementadas

### Conversa
- ✅ IDs não-nulos
- ✅ Tipos de usuário validados
- ✅ Status válidos
- ✅ Contadores >= 0
- ✅ Datas parseadas corretamente

### Mensagem
- ✅ IDs não-nulos
- ✅ Conteúdo não-vazio (por constraint do DB)
- ✅ Tipos de conteúdo validados
- ✅ Status válidos
- ✅ Anexo URL + tipo coerentes
- ✅ Datas parseadas corretamente

---

## 🚀 Próximo: Fase 2 - Services

Com os models prontos, agora implementaremos:

1. **ConversasService**
   - listarConversasRepresentante()
   - buscarOuCriarConversaUsuario()
   - streamConversas() (real-time)
   - marcarComoLida()
   - etc.

2. **MensagensService**
   - listarMensagens()
   - enviarMensagem()
   - marcarComoLida()
   - streamMensagens() (real-time)
   - etc.

---

## 📊 Estatísticas

- ✅ 2 models criados
- ✅ 40+ campos mapeados
- ✅ 15+ getters helpers
- ✅ 100% tipagem forte
- ✅ 0 erros de compilação
- ✅ Pronto para usar em Services

---

## 💡 Dicas de Uso

### Para ListView/GridView
```dart
final conversas = await ConversasService().listarConversas(...);

ListView.builder(
  itemCount: conversas.length,
  itemBuilder: (context, index) {
    final conversa = conversas[index];
    return ListTile(
      title: Text(conversa.usuarioNome),
      subtitle: Text(conversa.subtituloPadrao),
      trailing: conversa.temMensagensNaoLidasParaRepresentante
          ? Badge(
              label: Text(conversa.mensagensNaoLidasRepresentante.toString()),
            )
          : null,
    );
  },
);
```

### Para Condicionais
```dart
if (conversa.status == 'ativa') {
  // Mostra conversa normal
} else if (conversa.status == 'arquivada') {
  // Mostra com opacidade
} else if (conversa.status == 'bloqueada') {
  // Mostra com ícone de bloqueio
}
```

### Para Streams (Real-time)
```dart
streamMensagens(conversaId).listen((mensagens) {
  setState(() {
    this.mensagens = mensagens;
  });
});
```

---

**Status**: ✅ FASE 1 COMPLETA

**Próximo passo**: Quer que eu passe para Fase 2 (Services)?
