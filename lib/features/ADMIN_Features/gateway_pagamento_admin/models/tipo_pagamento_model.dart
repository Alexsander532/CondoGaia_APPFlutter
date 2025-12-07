class TipoPagamentoModel {
  final String id;
  final String nome;
  final String descricao;
  final bool ativo;

  TipoPagamentoModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.ativo,
  });

  TipoPagamentoModel copyWith({
    String? id,
    String? nome,
    String? descricao,
    bool? ativo,
  }) {
    return TipoPagamentoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      ativo: ativo ?? this.ativo,
    );
  }

  @override
  String toString() => 'TipoPagamentoModel(id: $id, nome: $nome)';
}
