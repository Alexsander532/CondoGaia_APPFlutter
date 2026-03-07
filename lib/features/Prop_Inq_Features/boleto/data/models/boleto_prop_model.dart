import '../../domain/entities/boleto_prop_entity.dart';

/// Model com serialização JSON para o Boleto do Proprietário/Inquilino
class BoletoPropModel extends BoletoPropEntity {
  const BoletoPropModel({
    required super.id,
    required super.dataVencimento,
    required super.valor,
    required super.status,
    required super.tipo,
    super.codigoBarras,
    super.descricao,
    super.isVencido,
  });

  factory BoletoPropModel.fromJson(Map<String, dynamic> json) {
    final dataVenc = json['data_vencimento'] != null
        ? DateTime.tryParse(json['data_vencimento']) ?? DateTime.now()
        : DateTime.now();

    return BoletoPropModel(
      id: json['id'] ?? '',
      dataVencimento: dataVenc,
      valor: (json['valor'] ?? 0).toDouble(),
      status: json['status'] ?? 'Ativo',
      tipo: json['tipo'] ?? 'Mensal',
      codigoBarras: json['codigo_barras'],
      descricao: json['descricao'],
      isVencido: dataVenc.isBefore(DateTime.now()) && json['status'] != 'Pago',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_vencimento': dataVencimento.toIso8601String().split('T').first,
      'valor': valor,
      'status': status,
      'tipo': tipo,
      'codigo_barras': codigoBarras,
      'descricao': descricao,
    };
  }
}
