/// Entity é uma representação pura do domínio, sem conhecimento de dados
/// Não tem métodos de serialização, é apenas dados estruturados
class ReservaEntity {
  final String id;
  final String condominioId;
  final String ambienteId;
  final String usuarioId;
  final String descricao;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String status;
  final DateTime dataCriacao;

  ReservaEntity({
    required this.id,
    required this.condominioId,
    required this.ambienteId,
    required this.usuarioId,
    required this.descricao,
    required this.dataInicio,
    required this.dataFim,
    required this.status,
    required this.dataCriacao,
  });
}
