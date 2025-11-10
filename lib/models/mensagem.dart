/// Model para representar uma mensagem em uma conversa
class Mensagem {
  final String id;
  final String conversaId;
  final String condominioId;
  final String remetenteTipo; // 'usuario' | 'representante'
  final String remetenteId;
  final String remetenteNome;
  final String conteudo;
  final String tipoConteudo; // 'texto' | 'imagem' | 'arquivo' | 'audio'
  final String? anexoUrl;
  final String? anexoNome;
  final int? anexoTamanho;
  final String? anexoTipo;
  final String status; // 'enviada' | 'entregue' | 'lida' | 'erro'
  final bool lida;
  final DateTime? dataLeitura;
  final String? respostaAMensagemId;
  final bool editada;
  final DateTime? dataEdicao;
  final String? conteudoOriginal;
  final String prioridade; // 'baixa' | 'normal' | 'alta' | 'urgente'
  final String? categoria;
  final DateTime createdAt;
  final DateTime updatedAt;

  Mensagem({
    required this.id,
    required this.conversaId,
    required this.condominioId,
    required this.remetenteTipo,
    required this.remetenteId,
    required this.remetenteNome,
    required this.conteudo,
    required this.tipoConteudo,
    this.anexoUrl,
    this.anexoNome,
    this.anexoTamanho,
    this.anexoTipo,
    this.status = 'enviada',
    this.lida = false,
    this.dataLeitura,
    this.respostaAMensagemId,
    this.editada = false,
    this.dataEdicao,
    this.conteudoOriginal,
    this.prioridade = 'normal',
    this.categoria,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma Mensagem a partir de um JSON (do Supabase)
  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      id: json['id'] as String,
      conversaId: json['conversa_id'] as String,
      condominioId: json['condominio_id'] as String,
      remetenteTipo: json['remetente_tipo'] as String,
      remetenteId: json['remetente_id'] as String,
      remetenteNome: json['remetente_nome'] as String,
      conteudo: json['conteudo'] as String,
      tipoConteudo: json['tipo_conteudo'] as String? ?? 'texto',
      anexoUrl: json['anexo_url'] as String?,
      anexoNome: json['anexo_nome'] as String?,
      anexoTamanho: json['anexo_tamanho'] as int?,
      anexoTipo: json['anexo_tipo'] as String?,
      status: json['status'] as String? ?? 'enviada',
      lida: json['lida'] as bool? ?? false,
      dataLeitura: json['data_leitura'] != null
          ? DateTime.parse(json['data_leitura'] as String)
          : null,
      respostaAMensagemId: json['resposta_a_mensagem_id'] as String?,
      editada: json['editada'] as bool? ?? false,
      dataEdicao: json['data_edicao'] != null
          ? DateTime.parse(json['data_edicao'] as String)
          : null,
      conteudoOriginal: json['conteudo_original'] as String?,
      prioridade: json['prioridade'] as String? ?? 'normal',
      categoria: json['categoria'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte a Mensagem para JSON (para enviar ao Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversa_id': conversaId,
      'condominio_id': condominioId,
      'remetente_tipo': remetenteTipo,
      'remetente_id': remetenteId,
      'remetente_nome': remetenteNome,
      'conteudo': conteudo,
      'tipo_conteudo': tipoConteudo,
      'anexo_url': anexoUrl,
      'anexo_nome': anexoNome,
      'anexo_tamanho': anexoTamanho,
      'anexo_tipo': anexoTipo,
      'status': status,
      'lida': lida,
      'data_leitura': dataLeitura?.toIso8601String(),
      'resposta_a_mensagem_id': respostaAMensagemId,
      'editada': editada,
      'data_edicao': dataEdicao?.toIso8601String(),
      'conteudo_original': conteudoOriginal,
      'prioridade': prioridade,
      'categoria': categoria,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cria uma cópia com alguns campos modificados
  Mensagem copyWith({
    String? id,
    String? conversaId,
    String? condominioId,
    String? remetenteTipo,
    String? remetenteId,
    String? remetenteNome,
    String? conteudo,
    String? tipoConteudo,
    String? anexoUrl,
    String? anexoNome,
    int? anexoTamanho,
    String? anexoTipo,
    String? status,
    bool? lida,
    DateTime? dataLeitura,
    String? respostaAMensagemId,
    bool? editada,
    DateTime? dataEdicao,
    String? conteudoOriginal,
    String? prioridade,
    String? categoria,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Mensagem(
      id: id ?? this.id,
      conversaId: conversaId ?? this.conversaId,
      condominioId: condominioId ?? this.condominioId,
      remetenteTipo: remetenteTipo ?? this.remetenteTipo,
      remetenteId: remetenteId ?? this.remetenteId,
      remetenteNome: remetenteNome ?? this.remetenteNome,
      conteudo: conteudo ?? this.conteudo,
      tipoConteudo: tipoConteudo ?? this.tipoConteudo,
      anexoUrl: anexoUrl ?? this.anexoUrl,
      anexoNome: anexoNome ?? this.anexoNome,
      anexoTamanho: anexoTamanho ?? this.anexoTamanho,
      anexoTipo: anexoTipo ?? this.anexoTipo,
      status: status ?? this.status,
      lida: lida ?? this.lida,
      dataLeitura: dataLeitura ?? this.dataLeitura,
      respostaAMensagemId: respostaAMensagemId ?? this.respostaAMensagemId,
      editada: editada ?? this.editada,
      dataEdicao: dataEdicao ?? this.dataEdicao,
      conteudoOriginal: conteudoOriginal ?? this.conteudoOriginal,
      prioridade: prioridade ?? this.prioridade,
      categoria: categoria ?? this.categoria,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se a mensagem foi enviada por representante
  bool get isRepresentante => remetenteTipo == 'representante';

  /// Verifica se a mensagem foi enviada por usuário
  bool get isUsuario => remetenteTipo == 'usuario';

  /// Verifica se é uma mensagem de texto
  bool get isTexto => tipoConteudo == 'texto';

  /// Verifica se tem anexo
  bool get temAnexo =>
      anexoUrl != null && anexoUrl!.isNotEmpty;

  /// Formata o horário da mensagem (fuso horário de Brasília)
  String get horaFormatada {
    // O Supabase já retorna em Brasília, então não precisa converter
    final dia = createdAt.day.toString().padLeft(2, '0');
    final mes = createdAt.month.toString().padLeft(2, '0');
    final ano = createdAt.year.toString().substring(2);
    final hora = createdAt.hour.toString().padLeft(2, '0');
    final minuto = createdAt.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano - $hora:$minuto';
  }

  /// Formata a data e hora completa (fuso horário de Brasília)
  String get dataHoraFormatada {
    // O Supabase já retorna em Brasília, então não precisa converter
    final dia = createdAt.day.toString().padLeft(2, '0');
    final mes = createdAt.month.toString().padLeft(2, '0');
    final hora = createdAt.hour.toString().padLeft(2, '0');
    final minuto = createdAt.minute.toString().padLeft(2, '0');
    return '$dia/$mes ${hora}h$minuto';
  }

  /// Retorna o ícone de status baseado no status da mensagem
  String get iconeStatus {
    switch (status) {
      case 'enviada':
        return '✓'; // 1 check
      case 'entregue':
        return '✓✓'; // 2 checks
      case 'lida':
        return '✓✓'; // 2 checks (cor diferente)
      case 'erro':
        return '✗'; // X
      default:
        return '•';
    }
  }

  /// Retorna a cor do status
  String get corStatus {
    switch (status) {
      case 'enviada':
        return '#999999'; // cinza
      case 'entregue':
        return '#3498DB'; // azul claro
      case 'lida':
        return '#2196F3'; // azul
      case 'erro':
        return '#E74C3C'; // vermelho
      default:
        return '#999999';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mensagem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Mensagem(id: $id, remetente: $remetenteNome, status: $status, lida: $lida)';
}
