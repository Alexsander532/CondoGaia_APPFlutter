import 'package:equatable/equatable.dart';

class LeituraModel extends Equatable {
  final String id;
  final String unidadeId;
  final String? bloco;
  final String unidadeNome; // e.g. "101"
  final double leituraAnterior;
  final double leituraAtual;
  final double valor;
  final DateTime dataLeitura;
  final String tipo; // 'Agua' or 'Gas'
  final String? imagemUrl;
  final bool isSelected;

  const LeituraModel({
    required this.id,
    required this.unidadeId,
    this.bloco,
    required this.unidadeNome,
    required this.leituraAnterior,
    required this.leituraAtual,
    required this.valor,
    required this.dataLeitura,
    required this.tipo,
    this.imagemUrl,
    this.isSelected = false,
  });

  LeituraModel copyWith({
    String? id,
    String? unidadeId,
    String? bloco,
    String? unidadeNome,
    double? leituraAnterior,
    double? leituraAtual,
    double? valor,
    DateTime? dataLeitura,
    String? tipo,
    String? imagemUrl,
    bool? isSelected,
  }) {
    return LeituraModel(
      id: id ?? this.id,
      unidadeId: unidadeId ?? this.unidadeId,
      bloco: bloco ?? this.bloco,
      unidadeNome: unidadeNome ?? this.unidadeNome,
      leituraAnterior: leituraAnterior ?? this.leituraAnterior,
      leituraAtual: leituraAtual ?? this.leituraAtual,
      valor: valor ?? this.valor,
      dataLeitura: dataLeitura ?? this.dataLeitura,
      tipo: tipo ?? this.tipo,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory LeituraModel.fromJson(Map<String, dynamic> json) {
    return LeituraModel(
      id: json['id'] ?? '',
      unidadeId: json['unidade_id'] ?? '',
      bloco: json['bloco'],
      unidadeNome:
          json['unidade_nome'] ?? '', // Might need join or simple field
      leituraAnterior: (json['leitura_anterior'] ?? 0).toDouble(),
      leituraAtual: (json['leitura_atual'] ?? 0).toDouble(),
      valor: (json['valor'] ?? 0).toDouble(),
      dataLeitura:
          DateTime.tryParse(json['data_leitura'] ?? '') ?? DateTime.now(),
      tipo: json['tipo'] ?? 'Agua',
      imagemUrl: json['imagem_url'],
      isSelected: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unidade_id': unidadeId,
      'bloco': bloco,
      'unidade_nome': unidadeNome,
      'leitura_anterior': leituraAnterior,
      'leitura_atual': leituraAtual,
      'valor': valor,
      'data_leitura': dataLeitura.toIso8601String(),
      'tipo': tipo,
      'imagem_url': imagemUrl,
    };
  }

  @override
  List<Object?> get props => [
    id,
    unidadeId,
    bloco,
    unidadeNome,
    leituraAnterior,
    leituraAtual,
    valor,
    dataLeitura,
    tipo,
    imagemUrl,
    isSelected,
  ];
}
