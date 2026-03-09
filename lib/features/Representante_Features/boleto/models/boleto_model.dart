class Boleto {
  final String? id;
  final String condominioId;
  final String? blocoUnidade;
  final String? sacado;
  final String? referencia;
  final DateTime? dataVencimento;
  final double valor;
  final String status; // Ativo, Pago, Cancelado, Cancelado por Acordo
  final String? pgto;
  final String tipo; // Mensal, Avulso, Acordo
  final String? classe;
  final String baixa; // Manual, Automática
  final String? nossoNumero;
  final String boletoRegistrado; // SIM, NAO, PENDENTE, ERRO
  final DateTime? dataPagamento;
  final double juros;
  final double multa;
  final double outrosAcrescimos;
  final double valorTotal;
  final String? obs;
  final String? contaBancariaId;
  final String? unidadeId;
  final String? blocoId;
  final double cotaCondominial;
  final double fundoReserva;
  final double multaInfracao;
  final double controle;
  final double rateioAgua;
  final double desconto;
  final DateTime? createdAt;

  // Campos auxiliares (join)
  final String? sacadoNome;
  final String? sacadoEmail;
  final String? contaBancariaNome;

  Boleto({
    this.id,
    required this.condominioId,
    this.blocoUnidade,
    this.sacado,
    this.referencia,
    this.dataVencimento,
    this.valor = 0,
    this.status = 'Ativo',
    this.pgto,
    this.tipo = 'Mensal',
    this.classe,
    this.baixa = 'Manual',
    this.nossoNumero,
    this.boletoRegistrado = 'NAO',
    this.dataPagamento,
    this.juros = 0,
    this.multa = 0,
    this.outrosAcrescimos = 0,
    this.valorTotal = 0,
    this.obs,
    this.contaBancariaId,
    this.unidadeId,
    this.blocoId,
    this.cotaCondominial = 0,
    this.fundoReserva = 0,
    this.multaInfracao = 0,
    this.controle = 0,
    this.rateioAgua = 0,
    this.desconto = 0,
    this.createdAt,
    this.sacadoNome,
    this.sacadoEmail,
    this.contaBancariaNome,
  });

  factory Boleto.fromJson(Map<String, dynamic> json) {
    return Boleto(
      id: json['id'],
      condominioId: json['condominio_id'] ?? '',
      blocoUnidade: json['bloco_unidade'],
      sacado: json['sacado'],
      referencia: json['referencia'],
      dataVencimento: json['data_vencimento'] != null
          ? DateTime.tryParse(json['data_vencimento'])
          : null,
      valor: (json['valor'] ?? 0).toDouble(),
      status: json['status'] ?? 'Ativo',
      pgto: json['pgto'],
      tipo: json['tipo'] ?? 'Mensal',
      classe: json['classe'],
      baixa: json['baixa'] ?? 'Manual',
      nossoNumero: json['nosso_numero'],
      boletoRegistrado: json['boleto_registrado'] ?? 'NAO',
      dataPagamento: json['data_pagamento'] != null
          ? DateTime.tryParse(json['data_pagamento'])
          : null,
      juros: (json['juros'] ?? 0).toDouble(),
      multa: (json['multa'] ?? 0).toDouble(),
      outrosAcrescimos: (json['outros_acrescimos'] ?? 0).toDouble(),
      valorTotal: (json['valor_total'] ?? 0).toDouble(),
      obs: json['obs'],
      contaBancariaId: json['conta_bancaria_id'],
      unidadeId: json['unidade_id'],
      blocoId: json['bloco_id'],
      cotaCondominial: (json['cota_condominial'] ?? 0).toDouble(),
      fundoReserva: (json['fundo_reserva'] ?? 0).toDouble(),
      multaInfracao: (json['multa_infracao'] ?? 0).toDouble(),
      controle: (json['controle'] ?? 0).toDouble(),
      rateioAgua: (json['rateio_agua'] ?? 0).toDouble(),
      desconto: (json['desconto'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      // Join fields
      sacadoNome: json['moradores']?['nome'],
      sacadoEmail: json['moradores']?['email'],
      contaBancariaNome: json['contas_bancarias']?['banco'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'condominio_id': condominioId,
      'bloco_unidade': blocoUnidade,
      'sacado': sacado,
      'referencia': referencia,
      'data_vencimento': dataVencimento?.toIso8601String().split('T').first,
      'valor': valor,
      'status': status,
      'pgto': pgto,
      'tipo': tipo,
      'classe': classe,
      'baixa': baixa,
      'nosso_numero': nossoNumero,
      'boleto_registrado': boletoRegistrado,
      'data_pagamento': dataPagamento?.toIso8601String().split('T').first,
      'juros': juros,
      'multa': multa,
      'outros_acrescimos': outrosAcrescimos,
      'valor_total': valorTotal,
      'obs': obs,
      'conta_bancaria_id': contaBancariaId,
      'unidade_id': unidadeId,
      'bloco_id': blocoId,
      'cota_condominial': cotaCondominial,
      'fundo_reserva': fundoReserva,
      'multa_infracao': multaInfracao,
      'controle': controle,
      'rateio_agua': rateioAgua,
      'desconto': desconto,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  Boleto copyWith({
    String? id,
    String? condominioId,
    String? blocoUnidade,
    String? sacado,
    String? referencia,
    DateTime? dataVencimento,
    double? valor,
    String? status,
    String? pgto,
    String? tipo,
    String? classe,
    String? baixa,
    String? nossoNumero,
    String? boletoRegistrado,
    DateTime? dataPagamento,
    double? juros,
    double? multa,
    double? outrosAcrescimos,
    double? valorTotal,
    String? obs,
    String? contaBancariaId,
    String? unidadeId,
    String? blocoId,
    double? cotaCondominial,
    double? fundoReserva,
    double? multaInfracao,
    double? controle,
    double? rateioAgua,
    double? desconto,
    DateTime? createdAt,
    String? sacadoNome,
    String? sacadoEmail,
    String? contaBancariaNome,
  }) {
    return Boleto(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      blocoUnidade: blocoUnidade ?? this.blocoUnidade,
      sacado: sacado ?? this.sacado,
      referencia: referencia ?? this.referencia,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      valor: valor ?? this.valor,
      status: status ?? this.status,
      pgto: pgto ?? this.pgto,
      tipo: tipo ?? this.tipo,
      classe: classe ?? this.classe,
      baixa: baixa ?? this.baixa,
      nossoNumero: nossoNumero ?? this.nossoNumero,
      boletoRegistrado: boletoRegistrado ?? this.boletoRegistrado,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      juros: juros ?? this.juros,
      multa: multa ?? this.multa,
      outrosAcrescimos: outrosAcrescimos ?? this.outrosAcrescimos,
      valorTotal: valorTotal ?? this.valorTotal,
      obs: obs ?? this.obs,
      contaBancariaId: contaBancariaId ?? this.contaBancariaId,
      unidadeId: unidadeId ?? this.unidadeId,
      blocoId: blocoId ?? this.blocoId,
      cotaCondominial: cotaCondominial ?? this.cotaCondominial,
      fundoReserva: fundoReserva ?? this.fundoReserva,
      multaInfracao: multaInfracao ?? this.multaInfracao,
      controle: controle ?? this.controle,
      rateioAgua: rateioAgua ?? this.rateioAgua,
      desconto: desconto ?? this.desconto,
      createdAt: createdAt ?? this.createdAt,
      sacadoNome: sacadoNome ?? this.sacadoNome,
      sacadoEmail: sacadoEmail ?? this.sacadoEmail,
      contaBancariaNome: contaBancariaNome ?? this.contaBancariaNome,
    );
  }
}
