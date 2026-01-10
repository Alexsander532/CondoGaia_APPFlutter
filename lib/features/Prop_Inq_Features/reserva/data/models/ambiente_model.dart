import 'package:condogaiaapp/features/Prop_Inq_Features/reserva/domain/entities/ambiente_entity.dart';

class AmbienteModel extends AmbienteEntity {
  AmbienteModel({
    required String id,
    required String nome,
    required double valor,
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
    condominioId: '', // Campo obrigatório na Entity, mas não está na tabela
    tipo: '', // Campo obrigatório na Entity, mas não está na tabela
    capacidadeMaxima: 0, // Campo obrigatório na Entity, mas não está na tabela
    dataCriacao: dataCriacao ?? DateTime.now(),
  );

  factory AmbienteModel.fromJson(Map<String, dynamic> json) {
    return AmbienteModel(
      id: json['id'] as String? ?? '',
      nome: json['titulo'] as String? ?? '', // A tabela usa 'titulo', não 'nome'
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
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
      'locacao_url': locacaoUrl,
    };
  }
}
