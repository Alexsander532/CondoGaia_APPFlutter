/// Modelo de dados para histórico de acessos (entradas e saídas)
class HistoricoAcesso {
  final String id;
  final String visitanteId;
  final String condominioId;
  final String tipoRegistro; // 'entrada' ou 'saida'
  final String tipoVisitante; // 'inquilino' ou 'visitante_portaria'
  final DateTime dataHora;
  final String? observacoes;
  final String registradoPor;
  final bool ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HistoricoAcesso({
    required this.id,
    required this.visitanteId,
    required this.condominioId,
    required this.tipoRegistro,
    required this.tipoVisitante,
    required this.dataHora,
    this.observacoes,
    this.registradoPor = 'Sistema',
    this.ativo = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Cria uma instância de HistoricoAcesso a partir de um Map (JSON)
  factory HistoricoAcesso.fromJson(Map<String, dynamic> json) {
    return HistoricoAcesso(
      id: json['id'] as String,
      visitanteId: json['visitante_id'] as String,
      condominioId: json['condominio_id'] as String,
      tipoRegistro: json['tipo_registro'] as String,
      tipoVisitante: json['tipo_visitante'] as String? ?? 'inquilino',
      dataHora: DateTime.parse(json['data_hora'] as String),
      observacoes: json['observacoes'] as String?,
      registradoPor: json['registrado_por'] as String? ?? 'Sistema',
      ativo: json['ativo'] as bool? ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  /// Converte a instância para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitante_id': visitanteId,
      'condominio_id': condominioId,
      'tipo_registro': tipoRegistro,
      'tipo_visitante': tipoVisitante,
      'data_hora': dataHora.toIso8601String(),
      'observacoes': observacoes,
      'registrado_por': registradoPor,
      'ativo': ativo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Converte para Map para inserção no banco (sem campos auto-gerados)
  Map<String, dynamic> toInsertJson() {
    return {
      'visitante_id': visitanteId,
      'condominio_id': condominioId,
      'tipo_registro': tipoRegistro,
      'tipo_visitante': tipoVisitante,
      'data_hora': dataHora.toIso8601String(),
      'observacoes': observacoes,
      'registrado_por': registradoPor,
      'ativo': ativo,
    };
  }

  /// Cria uma cópia da instância com campos modificados
  HistoricoAcesso copyWith({
    String? id,
    String? visitanteId,
    String? condominioId,
    String? tipoRegistro,
    String? tipoVisitante,
    DateTime? dataHora,
    String? observacoes,
    String? registradoPor,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HistoricoAcesso(
      id: id ?? this.id,
      visitanteId: visitanteId ?? this.visitanteId,
      condominioId: condominioId ?? this.condominioId,
      tipoRegistro: tipoRegistro ?? this.tipoRegistro,
      tipoVisitante: tipoVisitante ?? this.tipoVisitante,
      dataHora: dataHora ?? this.dataHora,
      observacoes: observacoes ?? this.observacoes,
      registradoPor: registradoPor ?? this.registradoPor,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se é um registro de entrada
  bool get isEntrada => tipoRegistro == 'entrada';

  /// Verifica se é um registro de saída
  bool get isSaida => tipoRegistro == 'saida';

  /// Formata a data/hora para exibição
  String get dataHoraFormatada {
    return '${dataHora.day.toString().padLeft(2, '0')}/'
           '${dataHora.month.toString().padLeft(2, '0')}/'
           '${dataHora.year} '
           '${dataHora.hour.toString().padLeft(2, '0')}:'
           '${dataHora.minute.toString().padLeft(2, '0')}';
  }

  /// Formata apenas a data para exibição
  String get dataFormatada {
    return '${dataHora.day.toString().padLeft(2, '0')}/'
           '${dataHora.month.toString().padLeft(2, '0')}/'
           '${dataHora.year}';
  }

  /// Formata apenas a hora para exibição
  String get horaFormatada {
    return '${dataHora.hour.toString().padLeft(2, '0')}:'
           '${dataHora.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'HistoricoAcesso{id: $id, visitanteId: $visitanteId, '
           'tipoRegistro: $tipoRegistro, dataHora: $dataHora}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoricoAcesso &&
        other.id == id &&
        other.visitanteId == visitanteId &&
        other.condominioId == condominioId &&
        other.tipoRegistro == tipoRegistro &&
        other.dataHora == dataHora;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        visitanteId.hashCode ^
        condominioId.hashCode ^
        tipoRegistro.hashCode ^
        dataHora.hashCode;
  }
}