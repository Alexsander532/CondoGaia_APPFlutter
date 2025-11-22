class Cidade {
  final int id;
  final String nome;

  Cidade({
    required this.id,
    required this.nome,
  });

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      id: json['id'] as int,
      nome: json['nome'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
  };

  @override
  String toString() => nome;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cidade &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nome == other.nome;

  @override
  int get hashCode => id.hashCode ^ nome.hashCode;
}
