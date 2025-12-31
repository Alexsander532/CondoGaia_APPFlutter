class CondominioModel {
  final String id;
  final String nome;
  final String localizacao; // Ex: "Três Lagoas/MS"
  final bool selecionado;

  CondominioModel({
    required this.id,
    required this.nome,
    required this.localizacao,
    this.selecionado = false,
  });

  /// Cria uma cópia do modelo com valores modificados
  CondominioModel copyWith({
    String? id,
    String? nome,
    String? localizacao,
    bool? selecionado,
  }) {
    return CondominioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      localizacao: localizacao ?? this.localizacao,
      selecionado: selecionado ?? this.selecionado,
    );
  }

  @override
  String toString() => '$nome - $localizacao';
}
