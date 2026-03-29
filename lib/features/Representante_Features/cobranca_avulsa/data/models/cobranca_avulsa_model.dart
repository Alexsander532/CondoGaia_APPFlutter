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
    super.recorrente = false,
    super.qtdMeses,
  });

  factory CobrancaAvulsaModel.fromJson(Map<String, dynamic> json) {
    // Tenta extrair valores aninhados do Join do Supabase
    String unidadeFormatada = json['unidade_id'] ?? '';
    String moradorFormatado = '';
    
    if (json['unidade'] != null) {
      final u = json['unidade'];
      final bloco = u['bloco'] ?? '';
      final num = u['numero'] ?? '';
      unidadeFormatada = '$bloco - $num';
      
      if (u['morador_id'] != null && u['morador_id'] is Map) {
        moradorFormatado = u['morador_id']['nome'] ?? '';
      }
    }

    return CobrancaAvulsaModel(
      id: json['id'],
      condominioId: json['condominio_id'],
      unidadeId: unidadeFormatada,
      moradorId: moradorFormatado.isEmpty ? null : moradorFormatado,
      contaContabilId: null, // Boletos não mapeiam isso diretamente (já estão nos logs com o tipo/obs)
      valor: (json['valor_total'] ?? json['valor'] ?? 0).toDouble(),
      dataVencimento: json['data_vencimento'] != null ? DateTime.parse(json['data_vencimento']) : null,
      mesRef: json['referencia']?.toString().split('-').last ?? json['mes_ref'],
      anoRef: json['referencia']?.toString().split('-').first ?? json['ano_ref'],
      descricao: json['obs'] ?? json['descricao'],
      tipoCobranca: json['tipo'] ?? json['tipo_cobranca'],
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
