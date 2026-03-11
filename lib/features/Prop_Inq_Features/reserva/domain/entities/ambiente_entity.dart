/// Entity é uma representação pura do domínio, sem conhecimento de dados
class AmbienteEntity {
  final String id;
  final String nome;
  final double valor;
  final String condominioId;
  final String descricao;
  final DateTime dataCriacao;
  final String? locacaoUrl;
  final String? fotoUrl;

  AmbienteEntity({
    required this.id,
    required this.nome,
    required this.valor,
    required this.condominioId,
    required this.descricao,
    required this.dataCriacao,
    this.locacaoUrl,
    this.fotoUrl,
  });
}
