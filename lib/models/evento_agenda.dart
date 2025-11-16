class EventoAgenda {
  final String id;
  final String representanteId;
  final String condominioId;
  final String titulo;
  final String? descricao;
  final DateTime dataEvento;
  final String horaInicio;
  final String? horaFim;
  final bool eventoRecorrente;
  final int? numeroMesesRecorrencia;
  final bool avisarCondominiosEmail;
  final bool avisarRepresentanteEmail;
  final String status;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final String? fotoUrl;

  EventoAgenda({
    required this.id,
    required this.representanteId,
    required this.condominioId,
    required this.titulo,
    this.descricao,
    required this.dataEvento,
    required this.horaInicio,
    this.horaFim,
    this.eventoRecorrente = false,
    this.numeroMesesRecorrencia,
    this.avisarCondominiosEmail = false,
    this.avisarRepresentanteEmail = false,
    this.status = 'ativo',
    required this.criadoEm,
    required this.atualizadoEm,
    this.fotoUrl,
  });

  factory EventoAgenda.fromJson(Map<String, dynamic> json) {
    return EventoAgenda(
      id: json['id'] as String,
      representanteId: json['representante_id'] as String,
      condominioId: json['condominio_id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      dataEvento: DateTime.parse(json['data_evento'] as String),
      horaInicio: json['hora_inicio'] as String,
      horaFim: json['hora_fim'] as String?,
      eventoRecorrente: json['evento_recorrente'] as bool? ?? false,
      numeroMesesRecorrencia: json['numero_meses_recorrencia'] as int?,
      avisarCondominiosEmail: json['avisar_condominios_email'] as bool? ?? false,
      avisarRepresentanteEmail: json['avisar_representante_email'] as bool? ?? false,
      status: json['status'] as String? ?? 'ativo',
      criadoEm: DateTime.parse(json['criado_em'] as String),
      atualizadoEm: DateTime.parse(json['atualizado_em'] as String),
      fotoUrl: json['foto_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'representante_id': representanteId,
      'condominio_id': condominioId,
      'titulo': titulo,
      'descricao': descricao,
      'data_evento': dataEvento.toIso8601String().split('T')[0], // Apenas a data
      'hora_inicio': horaInicio,
      'hora_fim': horaFim,
      'evento_recorrente': eventoRecorrente,
      'numero_meses_recorrencia': numeroMesesRecorrencia,
      'avisar_condominios_email': avisarCondominiosEmail,
      'avisar_representante_email': avisarRepresentanteEmail,
      'status': status,
      'criado_em': criadoEm.toIso8601String(),
      'atualizado_em': atualizadoEm.toIso8601String(),
      'foto_url': fotoUrl,
    };
  }

  Map<String, dynamic> toInsert() {
    return {
      'representante_id': representanteId,
      'condominio_id': condominioId,
      'titulo': titulo,
      'descricao': descricao,
      'data_evento': dataEvento.toIso8601String().split('T')[0],
      'hora_inicio': horaInicio,
      'hora_fim': horaFim,
      'evento_recorrente': eventoRecorrente,
      'numero_meses_recorrencia': numeroMesesRecorrencia,
      'avisar_condominios_email': avisarCondominiosEmail,
      'avisar_representante_email': avisarRepresentanteEmail,
      'status': status,
      'foto_url': fotoUrl,
    };
  }

  EventoAgenda copyWith({
    String? id,
    String? representanteId,
    String? condominioId,
    String? titulo,
    String? descricao,
    DateTime? dataEvento,
    String? horaInicio,
    String? horaFim,
    bool? eventoRecorrente,
    int? numeroMesesRecorrencia,
    bool? avisarCondominiosEmail,
    bool? avisarRepresentanteEmail,
    String? status,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    String? fotoUrl,
  }) {
    return EventoAgenda(
      id: id ?? this.id,
      representanteId: representanteId ?? this.representanteId,
      condominioId: condominioId ?? this.condominioId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataEvento: dataEvento ?? this.dataEvento,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFim: horaFim ?? this.horaFim,
      eventoRecorrente: eventoRecorrente ?? this.eventoRecorrente,
      numeroMesesRecorrencia: numeroMesesRecorrencia ?? this.numeroMesesRecorrencia,
      avisarCondominiosEmail: avisarCondominiosEmail ?? this.avisarCondominiosEmail,
      avisarRepresentanteEmail: avisarRepresentanteEmail ?? this.avisarRepresentanteEmail,
      status: status ?? this.status,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }

  @override
  String toString() {
    return 'EventoAgenda(id: $id, titulo: $titulo, dataEvento: $dataEvento, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventoAgenda && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Métodos auxiliares para validação
  bool get isAtivo => status == 'ativo';
  bool get isCancelado => status == 'cancelado';
  bool get isConcluido => status == 'concluido';

  // Validação de status
  static const List<String> statusValidos = [
    'ativo',
    'cancelado',
    'concluido'
  ];

  // Validação de recorrência por meses
  bool get isRecorrenciaValida {
    if (!eventoRecorrente) return true;
    return numeroMesesRecorrencia != null && 
           numeroMesesRecorrencia! > 0 && 
           numeroMesesRecorrencia! <= 60;
  }

  // Métodos auxiliares para notificações
  bool get temNotificacaoEmail => avisarCondominiosEmail || avisarRepresentanteEmail;

  bool get isStatusValido => statusValidos.contains(status);
}