# 📱 FASE 1 - RESUMO VISUAL

## ✅ O Que Foi Criado

### Modelo: Conversa
```
Conversa
├─ ID & IDs Externos
│  ├─ id (String)
│  ├─ condominioId
│  ├─ unidadeId
│  ├─ usuarioId
│  └─ representanteId
├─ Informações do Usuário
│  ├─ usuarioTipo ('proprietario'|'inquilino')
│  ├─ usuarioNome ("João Moreira")
│  └─ unidadeNumero ("A/400")
├─ Representante
│  ├─ representanteNome ("Portaria")
│  └─ assunto (opcional)
├─ Status & Flags
│  ├─ status ('ativa'|'arquivada'|'bloqueada')
│  ├─ notificacoesAtivas (bool)
│  └─ prioridade ('baixa'|'normal'|'alta'|'urgente')
├─ Contadores
│  ├─ totalMensagens (int)
│  ├─ mensagensNaoLidasUsuario (int) ← Badge
│  └─ mensagensNaoLidasRepresentante (int) ← Badge
├─ Última Mensagem
│  ├─ ultimaMensagemData (DateTime)
│  ├─ ultimaMensagemPor ('usuario'|'representante')
│  └─ ultimaMensagemPreview ("Olá, preciso de...")
└─ Timestamps
   ├─ createdAt (DateTime)
   └─ updatedAt (DateTime)

Getters Helpers:
  • temMensagensNaoLidasParaUsuario: bool
  • temMensagensNaoLidasParaRepresentante: bool
  • subtituloPadrao: String ("Olá, preciso..." ou "Nenhuma mensagem")
  • ultimaMensagemDataFormatada: String ("há 5m", "Ontem", etc)
```

### Modelo: Mensagem
```
Mensagem
├─ ID & IDs Externos
│  ├─ id (String)
│  ├─ conversaId
│  └─ condominioId
├─ Remetente
│  ├─ remetenteTipo ('usuario'|'representante')
│  ├─ remetenteId
│  └─ remetenteNome ("João Moreira" ou "Portaria")
├─ Conteúdo
│  ├─ conteudo ("Olá, preciso de ajuda")
│  ├─ tipoConteudo ('texto'|'imagem'|'arquivo'|'audio')
│  └─ resposta (opcional - para threads)
├─ Anexos (Opcionais)
│  ├─ anexoUrl (String?)
│  ├─ anexoNome ("documento.pdf")
│  ├─ anexoTamanho (int?)
│  └─ anexoTipo ("application/pdf")
├─ Status
│  ├─ status ('enviada'|'entregue'|'lida'|'erro')
│  ├─ lida (bool)
│  ├─ dataLeitura (DateTime?)
│  └─ prioridade ('baixa'|'normal'|'alta'|'urgente')
├─ Edição (Opcionais)
│  ├─ editada (bool)
│  ├─ dataEdicao (DateTime?)
│  └─ conteudoOriginal (String?)
├─ Categoria (Opcional)
│  └─ categoria (String?)
└─ Timestamps
   ├─ createdAt (DateTime)
   └─ updatedAt (DateTime)

Getters Helpers:
  • isRepresentante: bool
  • isUsuario: bool
  • isTexto: bool
  • temAnexo: bool
  • horaFormatada: String ("09:15")
  • dataHoraFormatada: String ("25/11 09h15")
  • iconeStatus: String ("✓", "✓✓", "✗")
  • corStatus: String ("#999999", "#3498DB", "#E74C3C")
```

---

## 📂 Estrutura de Arquivos

```
lib/
└─ models/
   ├─ conversa.dart         ← 180 linhas
   └─ mensagem.dart         ← 210 linhas
```

---

## 🎯 Características

| Característica | Conversa | Mensagem |
|----------------|----------|----------|
| Factory fromJson | ✅ | ✅ |
| toJson | ✅ | ✅ |
| copyWith | ✅ | ✅ |
| Getters helpers | ✅ (5+) | ✅ (8+) |
| Operador == | ✅ | ✅ |
| hashCode | ✅ | ✅ |
| toString | ✅ | ✅ |
| Tipagem forte | ✅ | ✅ |
| Nullability explícita | ✅ | ✅ |

---

## 💻 Exemplo de Uso

### Converter JSON do Supabase
```dart
// Do Supabase vem assim:
final json = {
  'id': 'conv-123',
  'condominio_id': 'condo-1',
  'unidade_id': 'unit-1',
  'usuario_tipo': 'proprietario',
  'usuario_id': 'user-1',
  'usuario_nome': 'João Moreira',
  'unidade_numero': 'A/400',
  'total_mensagens': 5,
  'mensagens_nao_lidas_usuario': 2,
  'ultima_mensagem_preview': 'Olá, preciso de ajuda',
  'created_at': '2025-11-09T10:30:00Z',
  'updated_at': '2025-11-09T10:30:00Z',
};

// Converte para Dart
final conversa = Conversa.fromJson(json);

// Usa nos Widgets
Text(conversa.usuarioNome);                    // "João Moreira"
Text(conversa.unidadeNumero ?? '');           // "A/400"
Text(conversa.subtituloPadrao);                // "Olá, preciso de ajuda"
Text(conversa.ultimaMensagemDataFormatada);   // "há 5m"

// Se tiver não lidas
if (conversa.temMensagensNaoLidasParaRepresentante) {
  Badge(label: Text(conversa.mensagensNaoLidasRepresentante.toString()));
}
```

### Usar em ListView
```dart
ListView.builder(
  itemCount: conversas.length,
  itemBuilder: (context, index) {
    final conversa = conversas[index];
    
    return ListTile(
      leading: CircleAvatar(
        child: Text(conversa.usuarioNome[0].toUpperCase()),
      ),
      title: Text(conversa.usuarioNome),
      subtitle: Text(conversa.subtituloPadrao),
      trailing: conversa.temMensagensNaoLidasParaRepresentante
          ? Badge(
              label: Text(
                conversa.mensagensNaoLidasRepresentante.toString(),
              ),
            )
          : null,
      onTap: () => navigator.push(...), // Abre chat
    );
  },
);
```

### Trabalhar com Mensagens
```dart
// Do Supabase
final json = {
  'id': 'msg-123',
  'conversa_id': 'conv-123',
  'remetente_tipo': 'usuario',
  'remetente_nome': 'João Moreira',
  'conteudo': 'Olá, preciso de ajuda com a portaria',
  'tipo_conteudo': 'texto',
  'status': 'lida',
  'lida': true,
  'data_leitura': '2025-11-09T10:35:00Z',
  'created_at': '2025-11-09T10:30:00Z',
  'updated_at': '2025-11-09T10:30:00Z',
};

final msg = Mensagem.fromJson(json);

// Exibir bubble
Container(
  alignment: msg.isRepresentante ? Alignment.centerLeft : Alignment.centerRight,
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: msg.isRepresentante ? Colors.grey[100] : Colors.blue[50],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          msg.remetenteNome,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(msg.conteudo),
        SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg.horaFormatada,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            SizedBox(width: 4),
            Text(
              msg.iconeStatus,
              style: TextStyle(
                fontSize: 10,
                color: Color(int.parse('0xff${msg.corStatus.substring(1)}')),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
```

---

## 🚀 Próximas Fases

```
FASE 1: ✅ Models (Conversa + Mensagem) ← VOCÊ ESTÁ AQUI
       ↓
FASE 2: Services (ConversasService + MensagensService)
       ↓
FASE 3: UI Representante (ConversasListScreen)
       ↓
FASE 4: UI Usuário + Chat (MensagemPortariaScreen + MensagemChatScreen)
```

---

## ✨ Status

- ✅ Código compilando sem erros
- ✅ Tipagem forte em 100%
- ✅ JSON serialization completo
- ✅ Getters helpers implementados
- ✅ Pronto para usar em Services

**Próximo passo?** Quer que eu implemente a Fase 2 (Services)?
