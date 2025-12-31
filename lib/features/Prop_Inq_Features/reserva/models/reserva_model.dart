class ReservaModel {
  final String id;
  final String condominioId;
  final String ambienteId;
  final String usuarioId;
  final String descricao;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String status; // pending, confirmed, cancelled
  final DateTime dataCriacao;
  final DateTime? dataAtualizacao;

  ReservaModel({
    required this.id,
    required this.condominioId,
    required this.ambienteId,
    required this.usuarioId,
    required this.descricao,
    required this.dataInicio,
    required this.dataFim,
    this.status = 'pending',
    required this.dataCriacao,
    this.dataAtualizacao,
  });

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    return ReservaModel(
      id: json['id'] as String,
      condominioId: json['condominio_id'] as String,
      ambienteId: json['ambiente_id'] as String,
      usuarioId: json['usuario_id'] as String,
      descricao: json['descricao'] as String,
      dataInicio: DateTime.parse(json['data_inicio'] as String),
      dataFim: DateTime.parse(json['data_fim'] as String),
      status: json['status'] as String? ?? 'pending',
      dataCriacao: DateTime.parse(json['data_criacao'] as String),
      dataAtualizacao: json['data_atualizacao'] != null
          ? DateTime.parse(json['data_atualizacao'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'condominio_id': condominioId,
      'ambiente_id': ambienteId,
      'usuario_id': usuarioId,
      'descricao': descricao,
      'data_inicio': dataInicio.toIso8601String(),
      'data_fim': dataFim.toIso8601String(),
      'status': status,
      'data_criacao': dataCriacao.toIso8601String(),
      'data_atualizacao': dataAtualizacao?.toIso8601String(),
    };
  }

  ReservaModel copyWith({
    String? id,
    String? condominioId,
    String? ambienteId,
    String? usuarioId,
    String? descricao,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? status,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return ReservaModel(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      ambienteId: ambienteId ?? this.ambienteId,
      usuarioId: usuarioId ?? this.usuarioId,
      descricao: descricao ?? this.descricao,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      status: status ?? this.status,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }
}
