class ConfiguracaoFinanceira {
  final String? id;
  final String condominioId;
  final double jurosMensal;
  final double multaAtraso;
  final double descontoPadrao;
  final int diaVencimento;
  final String fundoReservaTipo; // 'PERCENTUAL' ou 'FIXO'
  final double fundoReservaValor;
  final String tipoCobranca; // 'RATEIO' ou 'FIXO'
  final double? valorCondominioFixo;
  final List<Map<String, dynamic>> configuracaoTiposUnidades;
  final int mesesReferenciaDespesas;
  final int? diasProtesto;
  final int? diasBaixa;
  final bool usaGarantidora;
  final String? tokenGarantidora;

  ConfiguracaoFinanceira({
    this.id,
    required this.condominioId,
    this.jurosMensal = 0,
    this.multaAtraso = 0,
    this.descontoPadrao = 0,
    this.diaVencimento = 10,
    this.fundoReservaTipo = 'PERCENTUAL',
    this.fundoReservaValor = 0,
    this.tipoCobranca = 'RATEIO',
    this.valorCondominioFixo,
    this.configuracaoTiposUnidades = const [],
    this.mesesReferenciaDespesas = 1,
    this.diasProtesto,
    this.diasBaixa,
    this.usaGarantidora = false,
    this.tokenGarantidora,
  });

  factory ConfiguracaoFinanceira.fromJson(Map<String, dynamic> json) {
    return ConfiguracaoFinanceira(
      id: json['id'],
      condominioId: json['condominio_id'],
      jurosMensal: (json['juros_mensal'] as num?)?.toDouble() ?? 0,
      multaAtraso: (json['multa_atraso'] as num?)?.toDouble() ?? 0,
      descontoPadrao: (json['desconto_padrao'] as num?)?.toDouble() ?? 0,
      diaVencimento: json['dia_vencimento'] ?? 10,
      fundoReservaTipo: json['fundo_reserva_tipo'] ?? 'PERCENTUAL',
      fundoReservaValor: (json['fundo_reserva_valor'] as num?)?.toDouble() ?? 0,
      tipoCobranca: json['tipo_cobranca'] ?? 'RATEIO',
      valorCondominioFixo: (json['valor_condominio_fixo'] as num?)?.toDouble(),
      configuracaoTiposUnidades: json['configuracao_tipos_unidades'] != null
          ? List<Map<String, dynamic>>.from(json['configuracao_tipos_unidades'])
          : [],
      mesesReferenciaDespesas: json['meses_referencia_despesas'] ?? 1,
      diasProtesto: json['dias_protesto'],
      diasBaixa: json['dias_baixa'],
      usaGarantidora: json['usa_garantidora'] ?? false,
      tokenGarantidora: json['token_garantidora'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condominio_id': condominioId,
      'juros_mensal': jurosMensal,
      'multa_atraso': multaAtraso,
      'desconto_padrao': descontoPadrao,
      'dia_vencimento': diaVencimento,
      'fundo_reserva_tipo': fundoReservaTipo,
      'fundo_reserva_valor': fundoReservaValor,
      'tipo_cobranca': tipoCobranca,
      'valor_condominio_fixo': valorCondominioFixo,
      'configuracao_tipos_unidades': configuracaoTiposUnidades,
      'meses_referencia_despesas': mesesReferenciaDespesas,
      'dias_protesto': diasProtesto,
      'dias_baixa': diasBaixa,
      'usa_garantidora': usaGarantidora,
      'token_garantidora': tokenGarantidora,
    };
  }

  ConfiguracaoFinanceira copyWith({
    String? id,
    String? condominioId,
    double? jurosMensal,
    double? multaAtraso,
    double? descontoPadrao,
    int? diaVencimento,
    String? fundoReservaTipo,
    double? fundoReservaValor,
    String? tipoCobranca,
    double? valorCondominioFixo,
    List<Map<String, dynamic>>? configuracaoTiposUnidades,
    int? mesesReferenciaDespesas,
    int? diasProtesto,
    int? diasBaixa,
    bool? usaGarantidora,
    String? tokenGarantidora,
  }) {
    return ConfiguracaoFinanceira(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      jurosMensal: jurosMensal ?? this.jurosMensal,
      multaAtraso: multaAtraso ?? this.multaAtraso,
      descontoPadrao: descontoPadrao ?? this.descontoPadrao,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      fundoReservaTipo: fundoReservaTipo ?? this.fundoReservaTipo,
      fundoReservaValor: fundoReservaValor ?? this.fundoReservaValor,
      tipoCobranca: tipoCobranca ?? this.tipoCobranca,
      valorCondominioFixo: valorCondominioFixo ?? this.valorCondominioFixo,
      configuracaoTiposUnidades:
          configuracaoTiposUnidades ?? this.configuracaoTiposUnidades,
      mesesReferenciaDespesas:
          mesesReferenciaDespesas ?? this.mesesReferenciaDespesas,
      diasProtesto: diasProtesto ?? this.diasProtesto,
      diasBaixa: diasBaixa ?? this.diasBaixa,
      usaGarantidora: usaGarantidora ?? this.usaGarantidora,
      tokenGarantidora: tokenGarantidora ?? this.tokenGarantidora,
    );
  }
}
