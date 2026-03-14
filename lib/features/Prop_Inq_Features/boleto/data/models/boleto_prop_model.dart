import '../../domain/entities/boleto_prop_entity.dart';

/// Model com serialização JSON para o Boleto do Proprietário/Inquilino
class BoletoPropModel extends BoletoPropEntity {
  const BoletoPropModel({
    required super.id,
    required super.condominioId,
    super.unidadeId,
    super.sacado,
    super.blocoUnidade,
    super.referencia,
    required super.dataVencimento,
    required super.valor,
    required super.status,
    required super.tipo,
    super.classe,
    super.cotaCondominial = 0.0,
    super.fundoReserva = 0.0,
    super.multaInfracao = 0.0,
    super.controle = 0.0,
    super.rateioAgua = 0.0,
    super.desconto = 0.0,
    super.valorTotal = 0.0,
    super.bankSlipUrl,
    super.barCode,
    super.identificationField,
    super.invoiceUrl,
    super.codigoBarras,
    super.descricao,
    super.isVencido = false,
  });

  factory BoletoPropModel.fromJson(Map<String, dynamic> json) {
    final dataVenc = json['data_vencimento'] != null
        ? DateTime.tryParse(json['data_vencimento']) ?? DateTime.now()
        : DateTime.now();

    return BoletoPropModel(
      id: json['id'] ?? '',
      condominioId: json['condominio_id'] ?? '',
      unidadeId: json['unidade_id'],
      sacado: json['sacado'],
      blocoUnidade: json['bloco_unidade'],
      referencia: json['referencia'],
      dataVencimento: dataVenc,
      valor: (json['valor'] ?? 0).toDouble(),
      status: json['status'] ?? 'Ativo',
      tipo: json['tipo'] ?? 'Mensal',
      classe: json['classe'],
      cotaCondominial: (json['cota_condominial'] ?? 0).toDouble(),
      fundoReserva: (json['fundo_reserva'] ?? 0).toDouble(),
      multaInfracao: (json['multa_infracao'] ?? 0).toDouble(),
      controle: (json['controle'] ?? 0).toDouble(),
      rateioAgua: (json['rateio_agua'] ?? 0).toDouble(),
      desconto: (json['desconto'] ?? 0).toDouble(),
      valorTotal: (json['valor_total'] ?? 0).toDouble(),
      bankSlipUrl: json['bank_slip_url'],
      barCode: json['bar_code'],
      identificationField: json['identification_field'],
      invoiceUrl: json['invoice_url'],
      codigoBarras: json['codigo_barras'] ?? json['bar_code'], // Compatibilidade
      descricao: json['descricao'],
      isVencido: dataVenc.isBefore(DateTime.now()) && json['status'] != 'Pago',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'condominio_id': condominioId,
      'unidade_id': unidadeId,
      'sacado': sacado,
      'bloco_unidade': blocoUnidade,
      'referencia': referencia,
      'data_vencimento': dataVencimento.toIso8601String().split('T').first,
      'valor': valor,
      'status': status,
      'tipo': tipo,
      'classe': classe,
      'cota_condominial': cotaCondominial,
      'fundo_reserva': fundoReserva,
      'multa_infracao': multaInfracao,
      'controle': controle,
      'rateio_agua': rateioAgua,
      'desconto': desconto,
      'valor_total': valorTotal,
      'bank_slip_url': bankSlipUrl,
      'bar_code': barCode,
      'identification_field': identificationField,
      'invoice_url': invoiceUrl,
      'codigo_barras': codigoBarras,
      'descricao': descricao,
    };
  }
}
