class EstadoModel {
  final String sigla;
  final String nome;

  EstadoModel({
    required this.sigla,
    required this.nome,
  });

  @override
  String toString() => '$nome ($sigla)';
}

class CidadeModel {
  final int id;
  final String nome;
  final String estadoSigla;

  CidadeModel({
    required this.id,
    required this.nome,
    required this.estadoSigla,
  });

  @override
  String toString() => nome;
}
