class PlanoAssinaturaModel {
  final String id;
  final String nome;
  final String descricao;
  final double valor;
  final String frequencia; // 'Mensal', 'Trimestral', 'Semestral', 'Anual'
  final int diasTentativa; // Dias para tentativa de pagamento

  PlanoAssinaturaModel({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.valor,
    required this.frequencia,
    required this.diasTentativa,
  });

  PlanoAssinaturaModel copyWith({
    String? id,
    String? nome,
    String? descricao,
    double? valor,
    String? frequencia,
    int? diasTentativa,
  }) {
    return PlanoAssinaturaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      frequencia: frequencia ?? this.frequencia,
      diasTentativa: diasTentativa ?? this.diasTentativa,
    );
  }

  @override
  String toString() => 'PlanoAssinaturaModel(id: $id, nome: $nome, valor: R\$ $valor)';
}
