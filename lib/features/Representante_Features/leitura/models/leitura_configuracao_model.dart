import 'package:equatable/equatable.dart';

/// Representa uma faixa de consumo para cálculo de valor
class FaixaLeitura extends Equatable {
  final double inicio;
  final double fim;
  final double valor;

  const FaixaLeitura({
    required this.inicio,
    required this.fim,
    required this.valor,
  });

  factory FaixaLeitura.fromJson(Map<String, dynamic> json) {
    return FaixaLeitura(
      inicio: (json['inicio'] ?? 0).toDouble(),
      fim: (json['fim'] ?? 0).toDouble(),
      valor: (json['valor'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'inicio': inicio,
        'fim': fim,
        'valor': valor,
      };

  @override
  List<Object?> get props => [inicio, fim, valor];
}

class LeituraConfiguracaoModel extends Equatable {
  final String? id;
  final String condominioId;
  final String tipo; // 'Agua', 'Gas'
  final String unidadeMedida;
  final double valorBase;
  final List<FaixaLeitura> faixas;
  final int cobrancaTipo; // 1 = junto com taxa, 2 = avulso
  final DateTime? vencimentoAvulso;

  const LeituraConfiguracaoModel({
    this.id,
    required this.condominioId,
    required this.tipo,
    this.unidadeMedida = 'M³',
    this.valorBase = 0,
    this.faixas = const [],
    this.cobrancaTipo = 1,
    this.vencimentoAvulso,
  });

  factory LeituraConfiguracaoModel.fromJson(Map<String, dynamic> json) {
    List<FaixaLeitura> faixasList = [];
    final faixasData = json['faixas'];
    if (faixasData is List) {
      faixasList = faixasData
          .map((e) => FaixaLeitura.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return LeituraConfiguracaoModel(
      id: json['id'],
      condominioId: json['condominio_id'] ?? '',
      tipo: json['tipo'] ?? 'Agua',
      unidadeMedida: json['unidade_medida'] ?? 'M³',
      valorBase: (json['valor_base'] ?? 0).toDouble(),
      faixas: faixasList,
      cobrancaTipo: json['cobranca_tipo'] ?? 1,
      vencimentoAvulso: json['vencimento_avulso'] != null
          ? DateTime.tryParse(json['vencimento_avulso'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'condominio_id': condominioId,
      'tipo': tipo,
      'unidade_medida': unidadeMedida,
      'valor_base': valorBase,
      'faixas': faixas.map((f) => f.toJson()).toList(),
      'cobranca_tipo': cobrancaTipo,
      'vencimento_avulso': vencimentoAvulso?.toIso8601String().split('T').first,
    };
  }

  /// Calcula o valor com base no consumo e nas faixas configuradas.
  /// Cada faixa tem [inicio, fim) e valor por unidade nessa faixa.
  double calcularValor(double consumo) {
    if (consumo <= 0) return 0;
    if (faixas.isEmpty) {
      return consumo * valorBase;
    }
    double total = 0;
    double remaining = consumo;
    for (final faixa in faixas) {
      if (remaining <= 0) break;
      final rangeSize = faixa.fim - faixa.inicio;
      final consumedInRange = remaining < rangeSize ? remaining : rangeSize;
      total += consumedInRange * faixa.valor;
      remaining -= consumedInRange;
    }
    if (remaining > 0 && valorBase > 0) {
      total += remaining * valorBase;
    }
    return total;
  }

  LeituraConfiguracaoModel copyWith({
    String? id,
    String? condominioId,
    String? tipo,
    String? unidadeMedida,
    double? valorBase,
    List<FaixaLeitura>? faixas,
    int? cobrancaTipo,
    DateTime? vencimentoAvulso,
  }) {
    return LeituraConfiguracaoModel(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      tipo: tipo ?? this.tipo,
      unidadeMedida: unidadeMedida ?? this.unidadeMedida,
      valorBase: valorBase ?? this.valorBase,
      faixas: faixas ?? this.faixas,
      cobrancaTipo: cobrancaTipo ?? this.cobrancaTipo,
      vencimentoAvulso: vencimentoAvulso ?? this.vencimentoAvulso,
    );
  }

  @override
  List<Object?> get props =>
      [id, condominioId, tipo, unidadeMedida, valorBase, faixas, cobrancaTipo];
}
