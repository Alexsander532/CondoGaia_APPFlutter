class EventoDiario {
  final String id;
  final String representanteId;
  final String condominioId;
  final String titulo;
  final String? descricao;
  final DateTime dataEvento;
  final String status;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  EventoDiario({
    required this.id,
    required this.representanteId,
    required this.condominioId,
    required this.titulo,
    this.descricao,
    required this.dataEvento,
    this.status = 'ativo',
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory EventoDiario.fromJson(Map<String, dynamic> json) {
    return EventoDiario(
      id: json['id'] as String,
      representanteId: json['representante_id'] as String,
      condominioId: json['condominio_id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      dataEvento: DateTime.parse(json['data_evento'] as String),
      status: json['status'] as String? ?? 'ativo',
      criadoEm: DateTime.parse(json['criado_em'] as String),
      atualizadoEm: DateTime.parse(json['atualizado_em'] as String),
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
      'status': status,
      'criado_em': criadoEm.toIso8601String(),
      'atualizado_em': atualizadoEm.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsert() {
    return {
      'representante_id': representanteId,
      'condominio_id': condominioId,
      'titulo': titulo,
      'descricao': descricao,
      'data_evento': dataEvento.toIso8601String().split('T')[0],
      'status': status,
    };
  }

  EventoDiario copyWith({
    String? id,
    String? representanteId,
    String? condominioId,
    String? titulo,
    String? descricao,
    DateTime? dataEvento,
    String? status,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return EventoDiario(
      id: id ?? this.id,
      representanteId: representanteId ?? this.representanteId,
      condominioId: condominioId ?? this.condominioId,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataEvento: dataEvento ?? this.dataEvento,
      status: status ?? this.status,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return 'EventoDiario(id: $id, titulo: $titulo, dataEvento: $dataEvento, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventoDiario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Propriedades auxiliares para verificação de status
  bool get isAtivo => status == 'ativo';
  bool get isCancelado => status == 'cancelado';
  bool get isConcluido => status == 'concluido';
  bool get isInativo => status == 'inativo';

  // Validação de status
  static bool isStatusValido(String status) {
    return statusValidos.contains(status);
  }

  static const List<String> statusValidos = [
    'ativo',
    'cancelado',
    'concluido',
    'inativo',
  ];

  // Formatação da data para exibição
  String get dataEventoFormatada {
    return '${dataEvento.day.toString().padLeft(2, '0')}/${dataEvento.month.toString().padLeft(2, '0')}/${dataEvento.year}';
  }
}