/// Entity é uma representação pura do domínio, sem conhecimento de dados
class AmbienteEntity {
  final String id;
  final String condominioId;
  final String nome;
  final String descricao;
  final String tipo;
  final int capacidadeMaxima;
  final DateTime dataCriacao;

  AmbienteEntity({
    required this.id,
    required this.condominioId,
    required this.nome,
    required this.descricao,
    required this.tipo,
    required this.capacidadeMaxima,
    required this.dataCriacao,
  });
}
