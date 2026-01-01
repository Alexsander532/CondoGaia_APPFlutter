import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/ambiente_entity.dart';

class AmbienteModel extends AmbienteEntity {
  AmbienteModel({
    required String id,
    required String condominioId,
    required String nome,
    required String descricao,
    required String tipo,
    required int capacidadeMaxima,
    required DateTime dataCriacao,
  }) : super(
    id: id,
    condominioId: condominioId,
    nome: nome,
    descricao: descricao,
    tipo: tipo,
    capacidadeMaxima: capacidadeMaxima,
    dataCriacao: dataCriacao,
  );

  factory AmbienteModel.fromJson(Map<String, dynamic> json) {
    return AmbienteModel(
      id: json['id'] as String,
      condominioId: json['condominio_id'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      tipo: json['tipo'] as String,
      capacidadeMaxima: json['capacidade_maxima'] as int,
      dataCriacao: DateTime.parse(json['data_criacao'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'condominio_id': condominioId,
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo,
      'capacidade_maxima': capacidadeMaxima,
      'data_criacao': dataCriacao.toIso8601String(),
    };
  }
}
