/// Model é a representação dos dados que vêm do servidor/banco de dados
/// Responsável por serialização/desserialização
/// Estende Entity para herdar as propriedades do domínio
import '../../domain/entities/reserva_entity.dart';

class ReservaModel extends ReservaEntity {
  ReservaModel({
    required String id,
    required String condominioId,
    required String ambienteId,
    required String usuarioId,
    required String descricao,
    required DateTime dataInicio,
    required DateTime dataFim,
    required String status,
    required DateTime dataCriacao,
  }) : super(
    id: id,
    condominioId: condominioId,
    ambienteId: ambienteId,
    usuarioId: usuarioId,
    descricao: descricao,
    dataInicio: dataInicio,
    dataFim: dataFim,
    status: status,
    dataCriacao: dataCriacao,
  );

  /// Converte JSON para Model
  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    return ReservaModel(
      id: json['id'] as String,
      condominioId: json['condominio_id'] as String,
      ambienteId: json['ambiente_id'] as String,
      usuarioId: json['usuario_id'] as String,
      descricao: json['descricao'] as String,
      dataInicio: DateTime.parse(json['data_inicio'] as String),
      dataFim: DateTime.parse(json['data_fim'] as String),
      status: json['status'] as String,
      dataCriacao: DateTime.parse(json['data_criacao'] as String),
    );
  }

  /// Converte Model para JSON
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
    };
  }
}
