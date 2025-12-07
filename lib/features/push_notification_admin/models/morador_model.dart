class MoradorModel {
  final String id;
  final String nome;
  final String unidade;
  final String bloco;
  final bool selecionado;

  MoradorModel({
    required this.id,
    required this.nome,
    required this.unidade,
    required this.bloco,
    this.selecionado = false,
  });

  /// Cria uma cópia do modelo com valores modificados
  MoradorModel copyWith({
    String? id,
    String? nome,
    String? unidade,
    String? bloco,
    bool? selecionado,
  }) {
    return MoradorModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      unidade: unidade ?? this.unidade,
      bloco: bloco ?? this.bloco,
      selecionado: selecionado ?? this.selecionado,
    );
  }

  @override
  String toString() => '$nome - Unidade $unidade/$bloco';
}
