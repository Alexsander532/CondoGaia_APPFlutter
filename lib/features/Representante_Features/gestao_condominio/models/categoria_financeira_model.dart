class SubcategoriaFinanceira {
  final String? id;
  final String categoriaId;
  final String nome;

  SubcategoriaFinanceira({
    this.id,
    required this.categoriaId,
    required this.nome,
  });

  factory SubcategoriaFinanceira.fromJson(Map<String, dynamic> json) {
    return SubcategoriaFinanceira(
      id: json['id'],
      categoriaId: json['categoria_id'],
      nome: json['nome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'categoria_id': categoriaId, 'nome': nome};
  }
}

class CategoriaFinanceira {
  final String? id;
  final String condominioId;
  final String nome;
  final String tipo;
  final List<SubcategoriaFinanceira> subcategorias;

  CategoriaFinanceira({
    this.id,
    required this.condominioId,
    required this.nome,
    this.tipo = 'DESPESA',
    this.subcategorias = const [],
  });

  factory CategoriaFinanceira.fromJson(Map<String, dynamic> json) {
    var list = json['subcategorias_financeiras'] as List? ?? [];
    List<SubcategoriaFinanceira> subList = list
        .map((i) => SubcategoriaFinanceira.fromJson(i))
        .toList();

    return CategoriaFinanceira(
      id: json['id'],
      condominioId: json['condominio_id'],
      nome: json['nome'],
      tipo: json['tipo'] ?? 'DESPESA',
      subcategorias: subList,
    );
  }

  Map<String, dynamic> toJson() {
    return {'condominio_id': condominioId, 'nome': nome, 'tipo': tipo};
  }
}
