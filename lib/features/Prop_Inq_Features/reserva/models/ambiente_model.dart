class AmbienteModel {
  final String id;
  final String condominioId;
  final String nome;
  final String descricao;
  final String tipo; // quadra, piscina, salao, churrasqueira
  final int capacidadeMaxima;
  final DateTime dataCriacao;

  AmbienteModel({
    required this.id,
    required this.condominioId,
    required this.nome,
    required this.descricao,
    required this.tipo,
    required this.capacidadeMaxima,
    required this.dataCriacao,
  });

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
}
