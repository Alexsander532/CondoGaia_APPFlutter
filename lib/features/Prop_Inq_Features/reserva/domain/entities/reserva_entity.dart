/// Entity é uma representação pura do domínio, sem conhecimento de dados
/// Não tem métodos de serialização, é apenas dados estruturados
class ReservaEntity {
  final String id;
  final String ambienteId;
  final String representanteId;
  final DateTime dataReserva;
  final String horaInicio;
  final String horaFim;
  final String local;
  final double valorLocacao;
  final bool termoLocacao;
  final String para; // 'Condomínio' ou 'Bloco/Unid'
  final String? listaPresentesId; // ID do documento com lista de presentes
  final String? blocoUnidadeId; // UUID da unidade se for Bloco/Unid
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  ReservaEntity({
    required this.id,
    required this.ambienteId,
    required this.representanteId,
    required this.dataReserva,
    required this.horaInicio,
    required this.horaFim,
    required this.local,
    required this.valorLocacao,
    required this.termoLocacao,
    required this.para,
    required this.dataCriacao,
    required this.dataAtualizacao,
    this.listaPresentesId,
    this.blocoUnidadeId,
  });
}
