/// Entidade pura do Boleto para Proprietário/Inquilino
/// Sem dependências externas - apenas dados de negócio
class BoletoPropEntity {
  final String id;
  final String condominioId;
  final String? unidadeId;
  final String? sacado;
  final String? blocoUnidade;
  final String? referencia;
  final DateTime dataVencimento;
  final double valor;
  final String status; // 'Ativo', 'Pago', 'Cancelado', 'Cancelado por Acordo'
  final String tipo; // 'Mensal', 'Avulso', 'Acordo'
  final String? classe;
  
  // Composição do boleto
  final double cotaCondominial;
  final double fundoReserva;
  final double multaInfracao;
  final double controle;
  final double rateioAgua;
  final double desconto;
  final double valorTotal;
  
  // ASAAS
  final String? bankSlipUrl;
  final String? barCode;
  final String? identificationField;
  final String? invoiceUrl;
  
  // Campos legados (mantidos para compatibilidade)
  final String? codigoBarras;
  final String? descricao;
  
  // Calculado
  final bool isVencido;

  const BoletoPropEntity({
    required this.id,
    required this.condominioId,
    this.unidadeId,
    this.sacado,
    this.blocoUnidade,
    this.referencia,
    required this.dataVencimento,
    required this.valor,
    required this.status,
    required this.tipo,
    this.classe,
    this.cotaCondominial = 0.0,
    this.fundoReserva = 0.0,
    this.multaInfracao = 0.0,
    this.controle = 0.0,
    this.rateioAgua = 0.0,
    this.desconto = 0.0,
    this.valorTotal = 0.0,
    this.bankSlipUrl,
    this.barCode,
    this.identificationField,
    this.invoiceUrl,
    this.codigoBarras,
    this.descricao,
    this.isVencido = false,
  });
}
