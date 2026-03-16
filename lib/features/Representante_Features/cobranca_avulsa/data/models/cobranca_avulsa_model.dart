import '../../domain/entities/cobranca_avulsa_entity.dart';

class CobrancaAvulsaModel extends CobrancaAvulsaEntity {
  CobrancaAvulsaModel({
    super.id,
    required super.condominioId,
    super.unidadeId,
    super.moradorId,
    super.contaContabilId,
    required super.valor,
    super.dataVencimento,
    super.mesRef,
    super.anoRef,
    super.descricao,
    super.tipoCobranca,
    super.status,
    super.anexoUrl,
  });

  factory CobrancaAvulsaModel.fromJson(Map<String, dynamic> json) {
    return CobrancaAvulsaModel(
      id: json['id'],
      condominioId: json['condominio_id'],
      unidadeId: json['unidade_id'],
      moradorId: json['morador_id'],
      contaContabilId: json['conta_contabil_id'],
      valor: (json['valor'] ?? 0).toDouble(),
      dataVencimento: json['data_vencimento'] != null ? DateTime.parse(json['data_vencimento']) : null,
      mesRef: json['mes_ref'],
      anoRef: json['ano_ref'],
      descricao: json['descricao'],
      tipoCobranca: json['tipo_cobranca'],
      status: json['status'] ?? 'Pendente',
      anexoUrl: json['anexo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'condominio_id': condominioId,
      'unidade_id': unidadeId,
      'morador_id': moradorId,
      'conta_contabil_id': contaContabilId,
      'valor': valor,
      'data_vencimento': dataVencimento?.toIso8601String().split('T').first,
      'mes_ref': mesRef,
      'ano_ref': anoRef,
      'descricao': descricao,
      'tipo_cobranca': tipoCobranca,
      'status': status,
      'anexo_url': anexoUrl,
    };
  }
}
