/// Model para representar uma conversa entre usuário (proprietário/inquilino) e representante
class Conversa {
  final String id;
  final String condominioId;
  final String unidadeId;
  final String usuarioTipo; // 'proprietario' | 'inquilino'
  final String usuarioId;
  final String usuarioNome; // Ex: "João Moreira"
  final String? unidadeNumero; // Ex: "A/400" (para exibir, construído a partir de bloco + numero)
  final String? representanteId;
  final String? representanteNome; // Ex: "Portaria"
  final String? assunto;
  final String status; // 'ativa' | 'arquivada' | 'bloqueada'
  final int totalMensagens;
  final int mensagensNaoLidasUsuario;
  final int mensagensNaoLidasRepresentante;
  final DateTime? ultimaMensagemData;
  final String? ultimaMensagemPor; // 'usuario' | 'representante'
  final String? ultimaMensagemPreview;
  final bool notificacoesAtivas;
  final String prioridade; // 'baixa' | 'normal' | 'alta' | 'urgente'
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversa({
    required this.id,
    required this.condominioId,
    required this.unidadeId,
    required this.usuarioTipo,
    required this.usuarioId,
    required this.usuarioNome,
    this.unidadeNumero,
    this.representanteId,
    this.representanteNome,
    this.assunto,
    required this.status,
    required this.totalMensagens,
    required this.mensagensNaoLidasUsuario,
    required this.mensagensNaoLidasRepresentante,
    this.ultimaMensagemData,
    this.ultimaMensagemPor,
    this.ultimaMensagemPreview,
    this.notificacoesAtivas = true,
    this.prioridade = 'normal',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma Conversa a partir de um JSON (do Supabase)
  factory Conversa.fromJson(Map<String, dynamic> json) {
    return Conversa(
      id: json['id'] as String,
      condominioId: json['condominio_id'] as String,
      unidadeId: json['unidade_id'] as String,
      usuarioTipo: json['usuario_tipo'] as String,
      usuarioId: json['usuario_id'] as String,
      usuarioNome: json['usuario_nome'] as String,
      unidadeNumero: json['unidade_numero'] as String?,
      representanteId: json['representante_id'] as String?,
      representanteNome: json['representante_nome'] as String?,
      assunto: json['assunto'] as String?,
      status: json['status'] as String? ?? 'ativa',
      totalMensagens: json['total_mensagens'] as int? ?? 0,
      mensagensNaoLidasUsuario: json['mensagens_nao_lidas_usuario'] as int? ?? 0,
      mensagensNaoLidasRepresentante:
          json['mensagens_nao_lidas_representante'] as int? ?? 0,
      ultimaMensagemData: json['ultima_mensagem_data'] != null
          ? DateTime.parse(json['ultima_mensagem_data'] as String)
          : null,
      ultimaMensagemPor: json['ultima_mensagem_por'] as String?,
      ultimaMensagemPreview: json['ultima_mensagem_preview'] as String?,
      notificacoesAtivas: json['notificacoes_ativas'] as bool? ?? true,
      prioridade: json['prioridade'] as String? ?? 'normal',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte a Conversa para JSON (para enviar ao Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'condominio_id': condominioId,
      'unidade_id': unidadeId,
      'usuario_tipo': usuarioTipo,
      'usuario_id': usuarioId,
      'usuario_nome': usuarioNome,
      'unidade_numero': unidadeNumero,
      'representante_id': representanteId,
      'representante_nome': representanteNome,
      'assunto': assunto,
      'status': status,
      'total_mensagens': totalMensagens,
      'mensagens_nao_lidas_usuario': mensagensNaoLidasUsuario,
      'mensagens_nao_lidas_representante': mensagensNaoLidasRepresentante,
      'ultima_mensagem_data': ultimaMensagemData?.toIso8601String(),
      'ultima_mensagem_por': ultimaMensagemPor,
      'ultima_mensagem_preview': ultimaMensagemPreview,
      'notificacoes_ativas': notificacoesAtivas,
      'prioridade': prioridade,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cria uma cópia com alguns campos modificados
  Conversa copyWith({
    String? id,
    String? condominioId,
    String? unidadeId,
    String? usuarioTipo,
    String? usuarioId,
    String? usuarioNome,
    String? unidadeNumero,
    String? representanteId,
    String? representanteNome,
    String? assunto,
    String? status,
    int? totalMensagens,
    int? mensagensNaoLidasUsuario,
    int? mensagensNaoLidasRepresentante,
    DateTime? ultimaMensagemData,
    String? ultimaMensagemPor,
    String? ultimaMensagemPreview,
    bool? notificacoesAtivas,
    String? prioridade,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversa(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      unidadeId: unidadeId ?? this.unidadeId,
      usuarioTipo: usuarioTipo ?? this.usuarioTipo,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioNome: usuarioNome ?? this.usuarioNome,
      unidadeNumero: unidadeNumero ?? this.unidadeNumero,
      representanteId: representanteId ?? this.representanteId,
      representanteNome: representanteNome ?? this.representanteNome,
      assunto: assunto ?? this.assunto,
      status: status ?? this.status,
      totalMensagens: totalMensagens ?? this.totalMensagens,
      mensagensNaoLidasUsuario:
          mensagensNaoLidasUsuario ?? this.mensagensNaoLidasUsuario,
      mensagensNaoLidasRepresentante: mensagensNaoLidasRepresentante ??
          this.mensagensNaoLidasRepresentante,
      ultimaMensagemData: ultimaMensagemData ?? this.ultimaMensagemData,
      ultimaMensagemPor: ultimaMensagemPor ?? this.ultimaMensagemPor,
      ultimaMensagemPreview:
          ultimaMensagemPreview ?? this.ultimaMensagemPreview,
      notificacoesAtivas: notificacoesAtivas ?? this.notificacoesAtivas,
      prioridade: prioridade ?? this.prioridade,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se há mensagens não lidas para o usuário
  bool get temMensagensNaoLidasParaUsuario =>
      mensagensNaoLidasUsuario > 0;

  /// Verifica se há mensagens não lidas para o representante
  bool get temMensagensNaoLidasParaRepresentante =>
      mensagensNaoLidasRepresentante > 0;

  /// Retorna o nome para exibir no badge
  String get nomeParaBadge => 'Chat com $usuarioNome';

  /// Retorna o subtítulo da conversa
  String get subtituloPadrao {
    if (ultimaMensagemPreview != null && ultimaMensagemPreview!.isNotEmpty) {
      final preview = ultimaMensagemPreview!.length > 50
          ? '${ultimaMensagemPreview!.substring(0, 50)}...'
          : ultimaMensagemPreview!;
      return preview;
    }
    return 'Nenhuma mensagem ainda';
  }

  /// Retorna a data formatada da última mensagem
  String get ultimaMensagemDataFormatada {
    if (ultimaMensagemData == null) return '';

    final agora = DateTime.now();
    final diferenca = agora.difference(ultimaMensagemData!);

    if (diferenca.inMinutes < 1) {
      return 'Agora';
    } else if (diferenca.inHours < 1) {
      return 'há ${diferenca.inMinutes}m';
    } else if (diferenca.inHours < 24) {
      return 'há ${diferenca.inHours}h';
    } else if (diferenca.inDays < 7) {
      return 'há ${diferenca.inDays}d';
    } else {
      // Retorna data formatada
      return '${ultimaMensagemData!.day}/${ultimaMensagemData!.month}';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Conversa &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Conversa(id: $id, usuario: $usuarioNome, status: $status, naoLidas: $mensagensNaoLidasUsuario)';
}
