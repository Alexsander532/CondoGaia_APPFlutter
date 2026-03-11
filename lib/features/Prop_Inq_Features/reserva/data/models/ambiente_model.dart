import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/ambiente_entity.dart';

class AmbienteModel extends AmbienteEntity {
  AmbienteModel({
    required String id,
    required String nome,
    required double valor,
    required String condominioId,
    String? descricao,
    String? locacaoUrl,
    String? fotoUrl,
    DateTime? dataCriacao,
  }) : super(
         id: id,
         nome: nome,
         valor: valor,
         descricao: descricao ?? '',
         locacaoUrl: locacaoUrl,
         condominioId: condominioId,
         tipo: '',
         capacidadeMaxima: 0,
         dataCriacao: dataCriacao ?? DateTime.now(),
       );

  factory AmbienteModel.fromJson(Map<String, dynamic> json) {
    return AmbienteModel(
      id: json['id'] as String? ?? '',
      nome:
          json['titulo'] as String? ??
          '', // Tabela usa 'titulo', entity usa 'nome'
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      condominioId: json['condominio_id'] as String? ?? '',
      descricao: json['descricao'] as String?,
      locacaoUrl: json['locacao_url'] as String?,
      fotoUrl: json['foto_url'] as String?,
      dataCriacao: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': nome,
      'descricao': descricao,
      'valor': valor,
      'condominio_id': condominioId,
      'locacao_url': locacaoUrl,
    };
  }
}
