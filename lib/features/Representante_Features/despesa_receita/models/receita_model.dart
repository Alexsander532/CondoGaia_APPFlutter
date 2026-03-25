import 'package:equatable/equatable.dart';

class Receita extends Equatable {
  final String? id;
  final String condominioId;
  final String? contaId;
  final String? contaContabilId;
  final String? descricao;
  final double valor;
  final DateTime? dataCredito;
  final bool recorrente;
  final int? qtdMeses;
  final String tipo; // MANUAL ou AUTOMATICO
  final DateTime? createdAt;

  // Campos auxiliares (join data)
  final String? contaNome;
  final String? contaContabilNome;

  const Receita({
    this.id,
    required this.condominioId,
    this.contaId,
    this.contaContabilId,
    this.descricao,
    this.valor = 0,
    this.dataCredito,
    this.recorrente = false,
    this.qtdMeses,
    this.tipo = 'MANUAL',
    this.createdAt,
    this.contaNome,
    this.contaContabilNome,
  });

  factory Receita.fromJson(Map<String, dynamic> json) {
    return Receita(
      id: json['id'],
      condominioId: json['condominio_id'] ?? '',
      contaId: json['conta_id'],
      contaContabilId: json['conta_contabil_id'],
      descricao: json['descricao'],
      valor: (json['valor'] ?? 0).toDouble(),
      dataCredito: json['data_credito'] != null
          ? DateTime.tryParse(json['data_credito'])
          : null,
      recorrente: json['recorrente'] ?? false,
      qtdMeses: json['qtd_meses'],
      tipo: json['tipo'] ?? 'MANUAL',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      contaNome: json['contas_bancarias']?['banco'],
      contaContabilNome: json['conta_contabil']?['nome'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'condominio_id': condominioId,
      'conta_id': contaId,
      'conta_contabil_id': contaContabilId,
      'descricao': descricao,
      'valor': valor,
      'data_credito': dataCredito?.toIso8601String().split('T').first,
      'recorrente': recorrente,
      'qtd_meses': qtdMeses,
      'tipo': tipo,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  Receita copyWith({
    String? id,
    String? condominioId,
    String? contaId,
    String? contaContabilId,
    String? descricao,
    double? valor,
    DateTime? dataCredito,
    bool? recorrente,
    int? qtdMeses,
    String? tipo,
    DateTime? createdAt,
    String? contaNome,
    String? contaContabilNome,
  }) {
    return Receita(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      contaId: contaId ?? this.contaId,
      contaContabilId: contaContabilId ?? this.contaContabilId,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      dataCredito: dataCredito ?? this.dataCredito,
      recorrente: recorrente ?? this.recorrente,
      qtdMeses: qtdMeses ?? this.qtdMeses,
      tipo: tipo ?? this.tipo,
      createdAt: createdAt ?? this.createdAt,
      contaNome: contaNome ?? this.contaNome,
      contaContabilNome: contaContabilNome ?? this.contaContabilNome,
    );
  }

  @override
  List<Object?> get props => [
    id,
    condominioId,
    contaId,
    contaContabilId,
    descricao,
    valor,
    dataCredito,
    recorrente,
    qtdMeses,
    tipo,
    createdAt,
    contaNome,
    contaContabilNome,
  ];
}
