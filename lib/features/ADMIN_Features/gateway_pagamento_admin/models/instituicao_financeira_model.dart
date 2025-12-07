class InstituicaoFinanceiraModel {
  final String id;
  final String nome;
  final String sigla;
  final String icone; // Caminho da imagem ou ícone

  InstituicaoFinanceiraModel({
    required this.id,
    required this.nome,
    required this.sigla,
    required this.icone,
  });

  InstituicaoFinanceiraModel copyWith({
    String? id,
    String? nome,
    String? sigla,
    String? icone,
  }) {
    return InstituicaoFinanceiraModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      sigla: sigla ?? this.sigla,
      icone: icone ?? this.icone,
    );
  }

  @override
  String toString() => 'InstituicaoFinanceiraModel(id: $id, nome: $nome, sigla: $sigla)';
}
