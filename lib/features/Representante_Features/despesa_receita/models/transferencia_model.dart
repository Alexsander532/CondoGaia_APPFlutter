import 'package:equatable/equatable.dart';

class Transferencia extends Equatable {
  final String? id;
  final String condominioId;
  final String? contaDebitoId;
  final String? contaCreditoId;
  final String? descricao;
  final double valor;
  final DateTime? dataTransferencia;
  final bool recorrente;
  final int? qtdMeses;
  final String tipo; // MANUAL ou AUTOMATICO
  final DateTime? createdAt;

  // Campos auxiliares (join data)
  final String? contaDebitoNome;
  final String? contaCreditoNome;

  const Transferencia({
    this.id,
    required this.condominioId,
    this.contaDebitoId,
    this.contaCreditoId,
    this.descricao,
    this.valor = 0,
    this.dataTransferencia,
    this.recorrente = false,
    this.qtdMeses,
    this.tipo = 'MANUAL',
    this.createdAt,
    this.contaDebitoNome,
    this.contaCreditoNome,
  });

  factory Transferencia.fromJson(Map<String, dynamic> json) {
    return Transferencia(
      id: json['id'],
      condominioId: json['condominio_id'] ?? '',
      contaDebitoId: json['conta_debito_id'],
      contaCreditoId: json['conta_credito_id'],
      descricao: json['descricao'],
      valor: (json['valor'] ?? 0).toDouble(),
      dataTransferencia: json['data_transferencia'] != null
          ? DateTime.tryParse(json['data_transferencia'])
          : null,
      recorrente: json['recorrente'] ?? false,
      qtdMeses: json['qtd_meses'],
      tipo: json['tipo'] ?? 'MANUAL',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      contaDebitoNome: json['conta_debito']?['banco'],
      contaCreditoNome: json['conta_credito']?['banco'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'condominio_id': condominioId,
      'conta_debito_id': contaDebitoId,
      'conta_credito_id': contaCreditoId,
      'descricao': descricao,
      'valor': valor,
      'data_transferencia': dataTransferencia
          ?.toIso8601String()
          .split('T')
          .first,
      'recorrente': recorrente,
      'qtd_meses': qtdMeses,
      'tipo': tipo,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  Transferencia copyWith({
    String? id,
    String? condominioId,
    String? contaDebitoId,
    String? contaCreditoId,
    String? descricao,
    double? valor,
    DateTime? dataTransferencia,
    bool? recorrente,
    int? qtdMeses,
    String? tipo,
    DateTime? createdAt,
    String? contaDebitoNome,
    String? contaCreditoNome,
  }) {
    return Transferencia(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      contaDebitoId: contaDebitoId ?? this.contaDebitoId,
      contaCreditoId: contaCreditoId ?? this.contaCreditoId,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      dataTransferencia: dataTransferencia ?? this.dataTransferencia,
      recorrente: recorrente ?? this.recorrente,
      qtdMeses: qtdMeses ?? this.qtdMeses,
      tipo: tipo ?? this.tipo,
      createdAt: createdAt ?? this.createdAt,
      contaDebitoNome: contaDebitoNome ?? this.contaDebitoNome,
      contaCreditoNome: contaCreditoNome ?? this.contaCreditoNome,
    );
  }

  @override
  List<Object?> get props => [
    id,
    condominioId,
    contaDebitoId,
    contaCreditoId,
    descricao,
    valor,
    dataTransferencia,
    recorrente,
    qtdMeses,
    tipo,
    createdAt,
    contaDebitoNome,
    contaCreditoNome,
  ];
}
