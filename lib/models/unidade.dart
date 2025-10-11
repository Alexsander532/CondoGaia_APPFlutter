// =====================================================
// MODELO: Unidade
// DESCRIÇÃO: Modelo para dados de unidades preenchidos manualmente
// AUTOR: Sistema
// DATA: 2024-01-15
// =====================================================

class Unidade {
  // Campos de identificação
  final String id;
  final String numero;                    // Unidade* (obrigatório)
  final String condominioId;              // Referência ao condomínio
  
  // Campos opcionais da interface principal
  final String? bloco;                    // Bloco
  final double? fracaoIdeal;              // Fração Ideal (ex: 0.014)
  final double? areaM2;                   // Área (m²)
  final int? vencimentoDiaDiferente;      // Vencto dia diferente (1-31)
  final double? pagarValorDiferente;      // Pagar valor diferente
  final String tipoUnidade;               // Tipo (A, B, C, etc.)
  
  // Campos de Isenção (apenas um pode ser true)
  final bool isencaoNenhum;               // Nenhum (padrão)
  final bool isencaoTotal;                // Total
  final bool isencaoCota;                 // Cota
  final bool isencaoFundoReserva;         // Fundo Reserva
  
  // Campos de Ação Judicial
  final bool acaoJudicial;                // Sim/Não (padrão Não)
  
  // Campos de Correios
  final bool correios;                    // Sim/Não (padrão Não)
  
  // Campos de Nome Pagador do Boleto
  final String nomePagadorBoleto;         // proprietario ou inquilino
  
  // Campo de Observação
  final String? observacoes;              // Observação (texto livre)
  
  // Campos de controle do sistema
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  // =====================================================
  // CONSTRUTOR PRINCIPAL
  // =====================================================
  
  Unidade({
    required this.id,
    required this.numero,
    required this.condominioId,
    this.bloco,
    this.fracaoIdeal,
    this.areaM2,
    this.vencimentoDiaDiferente,
    this.pagarValorDiferente,
    this.tipoUnidade = 'A',
    this.isencaoNenhum = true,
    this.isencaoTotal = false,
    this.isencaoCota = false,
    this.isencaoFundoReserva = false,
    this.acaoJudicial = false,
    this.correios = false,
    this.nomePagadorBoleto = 'proprietario',
    this.observacoes,
    this.ativo = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // =====================================================
  // CONSTRUTOR PARA NOVA UNIDADE
  // =====================================================
  
  Unidade.nova({
    required this.numero,
    required this.condominioId,
    this.bloco,
    this.fracaoIdeal,
    this.areaM2,
    this.vencimentoDiaDiferente,
    this.pagarValorDiferente,
    this.tipoUnidade = 'A',
    this.isencaoNenhum = true,
    this.isencaoTotal = false,
    this.isencaoCota = false,
    this.isencaoFundoReserva = false,
    this.acaoJudicial = false,
    this.correios = false,
    this.nomePagadorBoleto = 'proprietario',
    this.observacoes,
    this.ativo = true,
  })  : id = '',
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  // =====================================================
  // CONVERSÃO DE/PARA JSON
  // =====================================================
  
  factory Unidade.fromJson(Map<String, dynamic> json) {
    return Unidade(
      id: json['id'] ?? '',
      numero: json['numero'] ?? '',
      condominioId: json['condominio_id'] ?? '',
      bloco: json['bloco'],
      fracaoIdeal: json['fracao_ideal']?.toDouble(),
      areaM2: json['area_m2']?.toDouble(),
      vencimentoDiaDiferente: json['vencto_dia_diferente'],
      pagarValorDiferente: json['pagar_valor_diferente']?.toDouble(),
      tipoUnidade: json['tipo_unidade'] ?? 'A',
      isencaoNenhum: json['isencao_nenhum'] ?? true,
      isencaoTotal: json['isencao_total'] ?? false,
      isencaoCota: json['isencao_cota'] ?? false,
      isencaoFundoReserva: json['isencao_fundo_reserva'] ?? false,
      acaoJudicial: json['acao_judicial'] ?? false,
      correios: json['correios'] ?? false,
      nomePagadorBoleto: json['nome_pagador_boleto'] ?? 'proprietario',
      observacoes: json['observacoes'],
      ativo: json['ativo'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.isEmpty ? null : id,
      'numero': numero,
      'condominio_id': condominioId,
      'bloco': bloco,
      'fracao_ideal': fracaoIdeal,
      'area_m2': areaM2,
      'vencto_dia_diferente': vencimentoDiaDiferente,
      'pagar_valor_diferente': pagarValorDiferente,
      'tipo_unidade': tipoUnidade,
      'isencao_nenhum': isencaoNenhum,
      'isencao_total': isencaoTotal,
      'isencao_cota': isencaoCota,
      'isencao_fundo_reserva': isencaoFundoReserva,
      'acao_judicial': acaoJudicial,
      'correios': correios,
      'nome_pagador_boleto': nomePagadorBoleto,
      'observacoes': observacoes,
      'ativo': ativo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // =====================================================
  // MÉTODO COPYWITH
  // =====================================================
  
  Unidade copyWith({
    String? id,
    String? numero,
    String? condominioId,
    String? bloco,
    double? fracaoIdeal,
    double? areaM2,
    int? vencimentoDiaDiferente,
    double? pagarValorDiferente,
    String? tipoUnidade,
    bool? isencaoNenhum,
    bool? isencaoTotal,
    bool? isencaoCota,
    bool? isencaoFundoReserva,
    bool? acaoJudicial,
    bool? correios,
    String? nomePagadorBoleto,
    String? observacoes,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Unidade(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      condominioId: condominioId ?? this.condominioId,
      bloco: bloco ?? this.bloco,
      fracaoIdeal: fracaoIdeal ?? this.fracaoIdeal,
      areaM2: areaM2 ?? this.areaM2,
      vencimentoDiaDiferente: vencimentoDiaDiferente ?? this.vencimentoDiaDiferente,
      pagarValorDiferente: pagarValorDiferente ?? this.pagarValorDiferente,
      tipoUnidade: tipoUnidade ?? this.tipoUnidade,
      isencaoNenhum: isencaoNenhum ?? this.isencaoNenhum,
      isencaoTotal: isencaoTotal ?? this.isencaoTotal,
      isencaoCota: isencaoCota ?? this.isencaoCota,
      isencaoFundoReserva: isencaoFundoReserva ?? this.isencaoFundoReserva,
      acaoJudicial: acaoJudicial ?? this.acaoJudicial,
      correios: correios ?? this.correios,
      nomePagadorBoleto: nomePagadorBoleto ?? this.nomePagadorBoleto,
      observacoes: observacoes ?? this.observacoes,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =====================================================
  // MÉTODOS UTILITÁRIOS
  // =====================================================
  
  /// Retorna o tipo de isenção ativa
  String get tipoIsencao {
    if (isencaoTotal) return 'Total';
    if (isencaoCota) return 'Cota';
    if (isencaoFundoReserva) return 'Fundo Reserva';
    return 'Nenhum';
  }
  
  /// Verifica se a unidade tem alguma isenção (exceto "nenhum")
  bool get temIsencao => isencaoTotal || isencaoCota || isencaoFundoReserva;
  
  /// Retorna uma descrição completa da unidade
  String get descricaoCompleta {
    final blocoTexto = bloco != null ? 'Bloco $bloco - ' : '';
    return '${blocoTexto}Unidade $numero';
  }
  
  /// Verifica se todos os campos obrigatórios estão preenchidos
  bool get isValida {
    return numero.trim().isNotEmpty && condominioId.trim().isNotEmpty;
  }

  // =====================================================
  // MÉTODOS DE COMPARAÇÃO
  // =====================================================
  
  @override
  String toString() {
    return 'Unidade{id: $id, numero: $numero, bloco: $bloco, tipo: $tipoUnidade}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unidade &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  get totalMoradores => null;
}