class CobrancaAvulsaEntity {
  final String? id;
  final String condominioId;
  final String? unidadeId;
  final String? moradorId;
  final String? contaContabilId;
  final double valor;
  final DateTime? dataVencimento;
  final String? mesRef;
  final String? anoRef;
  final String? descricao;
  final String? tipoCobranca;
  final String status;
  final String? anexoUrl;
  final bool recorrente;
  final int? qtdMeses;

  CobrancaAvulsaEntity({
    this.id,
    required this.condominioId,
    this.unidadeId,
    this.moradorId,
    this.contaContabilId,
    required this.valor,
    this.dataVencimento,
    this.mesRef,
    this.anoRef,
    this.descricao,
    this.tipoCobranca,
    this.status = 'Pendente',
    this.anexoUrl,
    this.recorrente = false,
    this.qtdMeses,
  });

  // ============ COPYWITH ============
  CobrancaAvulsaEntity copyWith({
    String? id,
    String? condominioId,
    String? unidadeId,
    String? moradorId,
    String? contaContabilId,
    double? valor,
    DateTime? dataVencimento,
    String? mesRef,
    String? anoRef,
    String? descricao,
    String? tipoCobranca,
    String? status,
    String? anexoUrl,
    bool? recorrente,
    int? qtdMeses,
  }) {
    return CobrancaAvulsaEntity(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      unidadeId: unidadeId ?? this.unidadeId,
      moradorId: moradorId ?? this.moradorId,
      contaContabilId: contaContabilId ?? this.contaContabilId,
      valor: valor ?? this.valor,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      mesRef: mesRef ?? this.mesRef,
      anoRef: anoRef ?? this.anoRef,
      descricao: descricao ?? this.descricao,
      tipoCobranca: tipoCobranca ?? this.tipoCobranca,
      status: status ?? this.status,
      anexoUrl: anexoUrl ?? this.anexoUrl,
      recorrente: recorrente ?? this.recorrente,
      qtdMeses: qtdMeses ?? this.qtdMeses,
    );
  }
}
