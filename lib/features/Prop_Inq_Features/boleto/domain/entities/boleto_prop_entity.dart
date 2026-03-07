/// Entidade pura do Boleto para Proprietário/Inquilino
/// Sem dependências externas - apenas dados de negócio
class BoletoPropEntity {
  final String id;
  final DateTime dataVencimento;
  final double valor;
  final String status; // 'Ativo', 'Pago', 'Cancelado', 'Cancelado por Acordo'
  final String tipo; // 'Mensal', 'Avulso', 'Acordo'
  final String? codigoBarras;
  final String? descricao;
  final bool isVencido;

  const BoletoPropEntity({
    required this.id,
    required this.dataVencimento,
    required this.valor,
    required this.status,
    required this.tipo,
    this.codigoBarras,
    this.descricao,
    this.isVencido = false,
  });
}
