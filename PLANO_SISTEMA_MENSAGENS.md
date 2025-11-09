# 📱 PLANO COMPLETO - SISTEMA DE MENSAGENS

## 🎯 Entendimento do Sistema

### Regras de Negócio
```
PORTARIA (Representante)
├─ Pode conversar com TODOS os usuários do condomínio
├─ Vê lista de conversas: Luana Sichieri B/501, João Moreira A/400, etc.
└─ Cada conversa é com 1 usuário específico

USUÁRIO (Proprietário/Inquilino)
├─ Só pode conversar com a PORTARIA
├─ Vê apenas 1 conversa: "Portaria - Disponível 24h"
└─ Não vê outros usuários
```

### Fluxo de Conversas
```
Representante ve:
┌─────────────────────────┐
│ 📋 Lista de Conversas   │
├─────────────────────────┤
│ 👤 Luana Sichieri B/501 │ ← 1 conversa
│    25/11/2023 17:20     │
├─────────────────────────┤
│ 👤 João Moreira A/400   │ ← outra conversa
│    24/11/2023 07:20     │
└─────────────────────────┘

Usuário vê:
┌─────────────────────────┐
│ 📋 Mensagens            │
├─────────────────────────┤
│ 🛡️ Portaria             │ ← ÚNICA conversa
│    Disponível 24h       │
└─────────────────────────┘
```

---

## 🗄️ Análise do Banco de Dados

### ✅ Tabela `conversas` - ESTÁ PERFEITA

Estrutura ideal para seu caso:

```sql
conversas:
- id (uuid)
- condominio_id (uuid) ← filtra por condomínio
- unidade_id (uuid) ← sabe de qual unidade é
- usuario_tipo ('proprietario' | 'inquilino')
- usuario_id (uuid) ← ID do prop/inq
- usuario_nome (varchar) ← "João Moreira"
- representante_id (uuid) ← ID do representante (pode ser NULL)
- representante_nome (varchar) ← "Portaria"
- total_mensagens (int)
- mensagens_nao_lidas_usuario (int) ← badge para usuário
- mensagens_nao_lidas_representante (int) ← badge para portaria
- ultima_mensagem_preview (text) ← "Olá, preciso de ajuda..."
- ultima_mensagem_data (timestamp)
- status ('ativa' | 'arquivada' | 'bloqueada')
```

**Constraint Importante**:
```sql
unique (condominio_id, unidade_id, usuario_tipo, usuario_id)
```
Isso garante: **1 conversa por usuário por unidade**

### ✅ Tabela `mensagens` - ESTÁ PERFEITA

```sql
mensagens:
- id (uuid)
- conversa_id (uuid) ← FK para conversas
- condominio_id (uuid) ← sempre inclui para queries
- remetente_tipo ('usuario' | 'representante')
- remetente_id (uuid)
- remetente_nome (varchar) ← "João Moreira"
- conteudo (text)
- tipo_conteudo ('texto' | 'imagem' | 'arquivo' | 'audio')
- anexo_url (varchar) ← se tem anexo
- lida (boolean)
- data_leitura (timestamp)
- resposta_a_mensagem_id (uuid) ← para threads
- editada (boolean)
- created_at (timestamp)
```

---

## 🏗️ Arquitetura do Sistema

### 1. Models (Dart)

```
lib/models/
├─ conversa.dart ← Model da conversa
├─ mensagem.dart ← Model da mensagem
└─ usuario_mensagem.dart ← Dados do usuário na conversa
```

### 2. Services

```
lib/services/
├─ conversas_service.dart ← CRUD de conversas
└─ mensagens_service.dart ← CRUD de mensagens + real-time
```

### 3. Screens

```
lib/screens/
├─ conversas_list_screen.dart ← Lista de conversas (representante)
├─ mensagem_chat_screen.dart ← Tela de chat (ambos)
└─ mensagem_portaria_screen.dart ← Tela única do usuário
```

---

## 📝 Implementação - Fase por Fase

### FASE 1: Models (Dart Classes)

#### 1.1 - Model `Conversa`
```dart
class Conversa {
  final String id;
  final String condominioId;
  final String unidadeId;
  final String usuarioTipo; // 'proprietario' | 'inquilino'
  final String usuarioId;
  final String usuarioNome; // "João Moreira"
  final String? unidadeNumero; // "A/400" - para exibir
  final String? representanteId;
  final String? representanteNome;
  final String? assunto;
  final String status; // 'ativa' | 'arquivada'
  final int totalMensagens;
  final int mensagensNaoLidasUsuario;
  final int mensagensNaoLidasRepresentante;
  final DateTime? ultimaMensagemData;
  final String? ultimaMensagemPor;
  final String? ultimaMensagemPreview;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Construtor, fromJson, toJson, copyWith
}
```

#### 1.2 - Model `Mensagem`
```dart
class Mensagem {
  final String id;
  final String conversaId;
  final String condominioId;
  final String remetenteTipo; // 'usuario' | 'representante'
  final String remetenteId;
  final String remetenteNome;
  final String conteudo;
  final String tipoConteudo; // 'texto' | 'imagem' | 'arquivo'
  final String? anexoUrl;
  final String? anexoNome;
  final int? anexoTamanho;
  final bool lida;
  final DateTime? dataLeitura;
  final String? respostaAMensagemId;
  final bool editada;
  final DateTime createdAt;

  // Métodos auxiliares
  bool get isEnviadaPorMim => ...; // compara com userId atual
  bool get isRepresentante => remetenteTipo == 'representante';
}
```

---

### FASE 2: Services (Lógica de Negócio)

#### 2.1 - `ConversasService`

**Métodos principais**:

```dart
class ConversasService {
  final SupabaseClient _supabase;

  // ============================================
  // REPRESENTANTE: Listar todas conversas
  // ============================================
  Future<List<Conversa>> listarConversasRepresentante({
    required String condominioId,
    String? status, // filtrar ativas/arquivadas
  }) async {
    final response = await _supabase
        .from('conversas')
        .select('''
          *,
          unidade:unidades(numero, bloco)
        ''')
        .eq('condominio_id', condominioId)
        .order('ultima_mensagem_data', ascending: false);
    
    // Retorna lista ordenada por última mensagem
  }

  // ============================================
  // USUÁRIO: Buscar ou criar conversa única
  // ============================================
  Future<Conversa> buscarOuCriarConversaUsuario({
    required String condominioId,
    required String unidadeId,
    required String usuarioTipo, // 'proprietario' | 'inquilino'
    required String usuarioId,
    required String usuarioNome,
  }) async {
    // 1. Tenta buscar conversa existente
    final existing = await _supabase
        .from('conversas')
        .select()
        .eq('condominio_id', condominioId)
        .eq('unidade_id', unidadeId)
        .eq('usuario_tipo', usuarioTipo)
        .eq('usuario_id', usuarioId)
        .maybeSingle();

    if (existing != null) {
      return Conversa.fromJson(existing);
    }

    // 2. Cria nova conversa
    final nova = await _supabase.from('conversas').insert({
      'condominio_id': condominioId,
      'unidade_id': unidadeId,
      'usuario_tipo': usuarioTipo,
      'usuario_id': usuarioId,
      'usuario_nome': usuarioNome,
      'representante_nome': 'Portaria',
      'status': 'ativa',
    }).select().single();

    return Conversa.fromJson(nova);
  }

  // ============================================
  // Stream para atualizar em tempo real
  // ============================================
  Stream<List<Conversa>> streamConversasRepresentante(
    String condominioId,
  ) {
    return _supabase
        .from('conversas')
        .stream(primaryKey: ['id'])
        .eq('condominio_id', condominioId)
        .order('ultima_mensagem_data', ascending: false)
        .map((data) => data.map((e) => Conversa.fromJson(e)).toList());
  }

  // Marcar como lida (zerar badge)
  Future<void> marcarComoLidaPorRepresentante(String conversaId) async {
    await _supabase.from('conversas').update({
      'mensagens_nao_lidas_representante': 0,
    }).eq('id', conversaId);
  }

  Future<void> marcarComoLidaPorUsuario(String conversaId) async {
    await _supabase.from('conversas').update({
      'mensagens_nao_lidas_usuario': 0,
    }).eq('id', conversaId);
  }
}
```

#### 2.2 - `MensagensService`

```dart
class MensagensService {
  final SupabaseClient _supabase;

  // ============================================
  // Listar mensagens de uma conversa
  // ============================================
  Future<List<Mensagem>> listarMensagens({
    required String conversaId,
    int limit = 50,
  }) async {
    final response = await _supabase
        .from('mensagens')
        .select()
        .eq('conversa_id', conversaId)
        .order('created_at', ascending: true) // mais antiga primeiro
        .limit(limit);

    return response.map((e) => Mensagem.fromJson(e)).toList();
  }

  // ============================================
  // Enviar mensagem
  // ============================================
  Future<Mensagem> enviarMensagem({
    required String conversaId,
    required String condominioId,
    required String remetenteTipo, // 'usuario' | 'representante'
    required String remetenteId,
    required String remetenteNome,
    required String conteudo,
    String tipoConteudo = 'texto',
    String? anexoUrl,
  }) async {
    final response = await _supabase.from('mensagens').insert({
      'conversa_id': conversaId,
      'condominio_id': condominioId,
      'remetente_tipo': remetenteTipo,
      'remetente_id': remetenteId,
      'remetente_nome': remetenteNome,
      'conteudo': conteudo,
      'tipo_conteudo': tipoConteudo,
      'anexo_url': anexoUrl,
      'lida': false,
    }).select().single();

    return Mensagem.fromJson(response);
  }

  // ============================================
  // Marcar mensagem como lida
  // ============================================
  Future<void> marcarComoLida(String mensagemId) async {
    await _supabase.from('mensagens').update({
      'lida': true,
      'data_leitura': DateTime.now().toIso8601String(),
    }).eq('id', mensagemId);
  }

  // ============================================
  // Stream de mensagens (real-time)
  // ============================================
  Stream<List<Mensagem>> streamMensagens(String conversaId) {
    return _supabase
        .from('mensagens')
        .stream(primaryKey: ['id'])
        .eq('conversa_id', conversaId)
        .order('created_at', ascending: true)
        .map((data) => data.map((e) => Mensagem.fromJson(e)).toList());
  }

  // ============================================
  // Deletar mensagem
  // ============================================
  Future<void> deletarMensagem(String mensagemId) async {
    await _supabase.from('mensagens').delete().eq('id', mensagemId);
  }
}
```

---

### FASE 3: Telas (UI)

#### 3.1 - Tela do REPRESENTANTE (Lista de Conversas)

**`conversas_list_screen.dart`**

```dart
class ConversasListScreen extends StatelessWidget {
  final String condominioId;

  // UI:
  // AppBar: "Mensagens"
  // Body: StreamBuilder com lista de conversas
  // Cada item: 
  //   - Avatar circular
  //   - Nome: "Luana Sichieri"
  //   - Unidade: "B/501"
  //   - Preview: "Olá, preciso de..."
  //   - Data: "25/11/2023 17:20"
  //   - Badge: mensagens não lidas (se > 0)
  //
  // onTap: navega para MensagemChatScreen
}
```

**Visual esperado**:
```
┌─────────────────────────────────────┐
│  Mensagens                     [+]  │ ← AppBar
├─────────────────────────────────────┤
│                                     │
│  ┌───┐  Luana Sichieri    17:20    │
│  │ 👤 │  B/501                   (2)│ ← Badge
│  └───┘  Preciso de ajuda...        │
│                                     │
│  ┌───┐  João Moreira       07:20   │
│  │ 👤 │  A/400                      │
│  └───┘  Bom dia!                   │
│                                     │
│  ┌───┐  Pedro Tebet        Ontem   │
│  │ 👤 │  C/200                      │
│  └───┘  Obrigado                   │
└─────────────────────────────────────┘
```

#### 3.2 - Tela do USUÁRIO (Conversa Única)

**`mensagem_portaria_screen.dart`**

```dart
class MensagemPortariaScreen extends StatelessWidget {
  final String condominioId;
  final String usuarioId;
  final String usuarioTipo; // 'proprietario' | 'inquilino'

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Conversa>(
      future: ConversasService().buscarOuCriarConversaUsuario(...),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Loading();
        
        final conversa = snapshot.data!;
        
        // Navega direto para o chat
        return MensagemChatScreen(
          conversaId: conversa.id,
          tituloAppBar: 'Portaria',
          subtituloAppBar: 'Disponível 24h',
        );
      },
    );
  }
}
```

**Visual esperado**:
```
┌─────────────────────────────────────┐
│ ← Portaria               [info]     │ ← AppBar
│   Disponível 24h                    │
├─────────────────────────────────────┤
│                                     │
│         ┌─────────────┐             │
│         │ Oi, portaria│   09:15     │ ← Eu
│         └─────────────┘             │
│                                     │
│  ┌─────────────┐                    │
│  │ Olá! Em que │         09:16      │ ← Portaria
│  │ posso ajudar?│                   │
│  └─────────────┘                    │
│                                     │
├─────────────────────────────────────┤
│ [📎]  Digite uma mensagem...   [>] │ ← Input
└─────────────────────────────────────┘
```

#### 3.3 - Tela de CHAT (Comum para ambos)

**`mensagem_chat_screen.dart`**

```dart
class MensagemChatScreen extends StatefulWidget {
  final String conversaId;
  final String tituloAppBar;
  final String? subtituloAppBar;

  // UI Components:
  // - AppBar com título e subtítulo
  // - StreamBuilder de mensagens
  // - ListView de mensagens (bolas alinhadas)
  // - Input com campo de texto + botão anexar + botão enviar
  // - Marca mensagens como lidas quando abre
}
```

**Lógica importante**:
```dart
// Ao abrir a tela:
1. Marca conversa como lida (zera badge)
2. Marca todas mensagens não lidas como lidas
3. Inicia stream de novas mensagens

// Ao enviar mensagem:
1. Adiciona mensagem no banco
2. Triggers automáticos atualizam conversa:
   - ultima_mensagem_preview
   - ultima_mensagem_data
   - total_mensagens++
   - mensagens_nao_lidas_[outro_lado]++
```

---

## 🔄 Fluxo Completo - Exemplo Prático

### Cenário: João Moreira (Inquilino) envia mensagem

```
1. João abre app → vai em "Mensagens"
   ↓
2. App chama: buscarOuCriarConversaUsuario()
   - Se não existe: cria conversa no banco
   - Se existe: retorna conversa existente
   ↓
3. Abre MensagemChatScreen com conversaId
   ↓
4. João digita: "Olá, preciso de ajuda"
   ↓
5. App chama: enviarMensagem()
   - INSERT em mensagens
   - Trigger atualiza conversas:
     * ultima_mensagem_preview = "Olá, preciso..."
     * mensagens_nao_lidas_representante = 1
   ↓
6. Portaria vê badge (1) na lista de conversas
   ↓
7. Portaria clica na conversa de "João Moreira A/400"
   ↓
8. App chama: marcarComoLidaPorRepresentante()
   - mensagens_nao_lidas_representante = 0
   - Marca mensagens como lidas
   ↓
9. Portaria responde: "Olá João, como posso ajudar?"
   ↓
10. João recebe notificação/badge
```

---

## 🎨 Componentes UI Importantes

### 1. Card de Conversa (Lista)
```dart
class ConversaCard extends StatelessWidget {
  final Conversa conversa;
  final VoidCallback onTap;

  // Exibe:
  // - Avatar circular (primeira letra do nome)
  // - Nome do usuário + unidade
  // - Preview última mensagem
  // - Data/hora
  // - Badge de não lidas (se > 0)
}
```

### 2. Bubble de Mensagem (Chat)
```dart
class MensagemBubble extends StatelessWidget {
  final Mensagem mensagem;
  final bool isMinha;

  // Alinhamento:
  // - Se isMinha: direita, cor azul
  // - Se outra pessoa: esquerda, cor cinza
  //
  // Exibe:
  // - Conteúdo da mensagem
  // - Hora (09:15)
  // - Ícone de lida (✓✓) se for minha
}
```

### 3. Input de Mensagem
```dart
class MensagemInput extends StatefulWidget {
  final Function(String) onEnviar;
  final VoidCallback onAnexar;

  // TextField + botão anexo + botão enviar
}
```

---

## 📱 Navegação

```dart
// Representante:
Tabs → Mensagens → ConversasListScreen
  ↓ (clica em conversa)
MensagemChatScreen

// Usuário:
Tabs → Mensagens → MensagemPortariaScreen (auto-abre chat)
  = MensagemChatScreen
```

---

## 🔔 Sistema de Notificações (Futuro)

```dart
// Quando nova mensagem chega:
- Se representante é destinatário:
  * Atualiza badge em conversas_nao_lidas_representante
  * Push notification: "João Moreira: Olá, preciso..."

- Se usuário é destinatário:
  * Atualiza badge em conversas_nao_lidas_usuario
  * Push notification: "Portaria: Olá João, como posso..."
```

---

## ✅ Checklist de Implementação

### Fase 1: Models
- [ ] Criar `Conversa` model com fromJson/toJson
- [ ] Criar `Mensagem` model com fromJson/toJson
- [ ] Testar conversão de JSON

### Fase 2: Services
- [ ] Implementar `ConversasService`
- [ ] Implementar `MensagensService`
- [ ] Testar CRUD básico

### Fase 3: UI Representante
- [ ] Criar `ConversasListScreen`
- [ ] Implementar `ConversaCard` widget
- [ ] Testar lista com StreamBuilder

### Fase 4: UI Usuário
- [ ] Criar `MensagemPortariaScreen`
- [ ] Testar auto-criação de conversa

### Fase 5: Chat
- [ ] Criar `MensagemChatScreen`
- [ ] Implementar `MensagemBubble`
- [ ] Implementar `MensagemInput`
- [ ] Testar envio e recebimento

### Fase 6: Real-time
- [ ] Implementar Supabase streams
- [ ] Testar sincronização automática

### Fase 7: Anexos (Opcional)
- [ ] Upload de imagens
- [ ] Upload de arquivos
- [ ] Preview de anexos

---

## 🚀 Próximos Passos

Quer que eu implemente:
1. **Models primeiro** (Conversa + Mensagem)?
2. **Services** (lógica de negócio)?
3. **Tela do Representante** (lista de conversas)?
4. **Tela do Usuário** (chat com portaria)?

**Recomendo começar por: Models → Services → UI Representante → UI Usuário**

Me diga qual fase quer que eu comece! 🎯
