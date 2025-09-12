/// Modelo de dados para condomínios
class Condominio {
  final String id;
  final String cnpj;
  final String nomeCondominio;
  final String cep;
  final String endereco;
  final String numero;
  final String bairro;
  final String cidade;
  final String estado;
  final String? planoAssinatura;
  final String? pagamento;
  final DateTime? vencimento;
  final double? valor;
  final String? instituicaoFinanceiroCondominio;
  final String? tokenFinanceiroCondominio;
  final String? instituicaoFinanceiroUnidade;
  final String? tokenFinanceiroUnidade;
  final String? representanteId; // Nova coluna para relacionamento 1:N
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Condominio({
    required this.id,
    required this.cnpj,
    required this.nomeCondominio,
    required this.cep,
    required this.endereco,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.estado,
    this.planoAssinatura,
    this.pagamento,
    this.vencimento,
    this.valor,
    this.instituicaoFinanceiroCondominio,
    this.tokenFinanceiroCondominio,
    this.instituicaoFinanceiroUnidade,
    this.tokenFinanceiroUnidade,
    this.representanteId,
    this.ativo = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma instância de Condominio a partir de um Map (JSON)
  factory Condominio.fromJson(Map<String, dynamic> json) {
    return Condominio(
      id: json['id'] as String,
      cnpj: json['cnpj'] as String,
      nomeCondominio: json['nome_condominio'] as String,
      cep: json['cep'] as String,
      endereco: json['endereco'] as String,
      numero: json['numero'] as String,
      bairro: json['bairro'] as String,
      cidade: json['cidade'] as String,
      estado: json['estado'] as String,
      planoAssinatura: json['plano_assinatura'] as String?,
      pagamento: json['pagamento'] as String?,
      vencimento: json['vencimento'] != null 
          ? DateTime.parse(json['vencimento'] as String)
          : null,
      valor: json['valor'] != null 
          ? (json['valor'] as num).toDouble()
          : null,
      instituicaoFinanceiroCondominio: json['instituicao_financeiro_condominio'] as String?,
      tokenFinanceiroCondominio: json['token_financeiro_condominio'] as String?,
      instituicaoFinanceiroUnidade: json['instituicao_financeiro_unidade'] as String?,
      tokenFinanceiroUnidade: json['token_financeiro_unidade'] as String?,
      representanteId: json['representante_id'] as String?,
      ativo: json['ativo'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte a instância de Condominio para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cnpj': cnpj,
      'nome_condominio': nomeCondominio,
      'cep': cep,
      'endereco': endereco,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'plano_assinatura': planoAssinatura,
      'pagamento': pagamento,
      'vencimento': vencimento?.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
      'valor': valor,
      'instituicao_financeiro_condominio': instituicaoFinanceiroCondominio,
      'token_financeiro_condominio': tokenFinanceiroCondominio,
      'instituicao_financeiro_unidade': instituicaoFinanceiroUnidade,
      'token_financeiro_unidade': tokenFinanceiroUnidade,
      'representante_id': representanteId,
      'ativo': ativo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cria uma cópia do condomínio com campos modificados
  Condominio copyWith({
    String? id,
    String? cnpj,
    String? nomeCondominio,
    String? cep,
    String? endereco,
    String? numero,
    String? bairro,
    String? cidade,
    String? estado,
    String? planoAssinatura,
    String? pagamento,
    DateTime? vencimento,
    double? valor,
    String? instituicaoFinanceiroCondominio,
    String? tokenFinanceiroCondominio,
    String? instituicaoFinanceiroUnidade,
    String? tokenFinanceiroUnidade,
    String? representanteId,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Condominio(
      id: id ?? this.id,
      cnpj: cnpj ?? this.cnpj,
      nomeCondominio: nomeCondominio ?? this.nomeCondominio,
      cep: cep ?? this.cep,
      endereco: endereco ?? this.endereco,
      numero: numero ?? this.numero,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      planoAssinatura: planoAssinatura ?? this.planoAssinatura,
      pagamento: pagamento ?? this.pagamento,
      vencimento: vencimento ?? this.vencimento,
      valor: valor ?? this.valor,
      instituicaoFinanceiroCondominio: instituicaoFinanceiroCondominio ?? this.instituicaoFinanceiroCondominio,
      tokenFinanceiroCondominio: tokenFinanceiroCondominio ?? this.tokenFinanceiroCondominio,
      instituicaoFinanceiroUnidade: instituicaoFinanceiroUnidade ?? this.instituicaoFinanceiroUnidade,
      tokenFinanceiroUnidade: tokenFinanceiroUnidade ?? this.tokenFinanceiroUnidade,
      representanteId: representanteId ?? this.representanteId,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se o condomínio tem representante atribuído
  bool get temRepresentante => representanteId != null && representanteId!.isNotEmpty;

  /// Retorna o CNPJ formatado (XX.XXX.XXX/XXXX-XX)
  String get cnpjFormatado {
    if (cnpj.length != 14) return cnpj;
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12, 14)}';
  }

  /// Retorna o CEP formatado (XXXXX-XXX)
  String get cepFormatado {
    if (cep.length != 8) return cep;
    return '${cep.substring(0, 5)}-${cep.substring(5, 8)}';
  }

  /// Retorna o endereço completo formatado
  String get enderecoCompleto {
    final partes = <String>[];
    partes.add(endereco);
    if (numero.isNotEmpty) partes.add(numero);
    partes.add(bairro);
    partes.add('$cidade/$estado');
    partes.add(cepFormatado);
    return partes.join(', ');
  }

  /// Retorna o valor formatado como moeda brasileira
  String get valorFormatado {
    if (valor == null) return 'R\u0024 0,00';
    return 'R\u0024 ${valor!.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Retorna a data de vencimento formatada (DD/MM/AAAA)
  String get vencimentoFormatado {
    if (vencimento == null) return 'Não informado';
    return '${vencimento!.day.toString().padLeft(2, '0')}/${vencimento!.month.toString().padLeft(2, '0')}/${vencimento!.year}';
  }

  @override
  String toString() {
    return 'Condominio(id: $id, nomeCondominio: $nomeCondominio, cnpj: $cnpj, representanteId: $representanteId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Condominio && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}