class ContaBancaria {
  final String? id;
  final String condominioId;
  final String nomeTitular;
  final String banco;
  final String agencia;
  final String conta;
  final String tipoConta;
  final bool isPrincipal;

  ContaBancaria({
    this.id,
    required this.condominioId,
    required this.nomeTitular,
    required this.banco,
    required this.agencia,
    required this.conta,
    this.tipoConta = 'CORRENTE',
    this.isPrincipal = false,
  });

  factory ContaBancaria.fromJson(Map<String, dynamic> json) {
    return ContaBancaria(
      id: json['id'],
      condominioId: json['condominio_id'],
      nomeTitular: json['nome_titular'] ?? '',
      banco: json['banco'] ?? '',
      agencia: json['agencia'] ?? '',
      conta: json['conta'] ?? '',
      tipoConta: json['tipo_conta'] ?? 'CORRENTE',
      isPrincipal: json['is_principal'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'condominio_id': condominioId,
      'nome_titular': nomeTitular,
      'banco': banco,
      'agencia': agencia,
      'conta': conta,
      'tipo_conta': tipoConta,
      'is_principal': isPrincipal,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  ContaBancaria copyWith({
    String? id,
    String? condominioId,
    String? nomeTitular,
    String? banco,
    String? agencia,
    String? conta,
    String? tipoConta,
    bool? isPrincipal,
  }) {
    return ContaBancaria(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      nomeTitular: nomeTitular ?? this.nomeTitular,
      banco: banco ?? this.banco,
      agencia: agencia ?? this.agencia,
      conta: conta ?? this.conta,
      tipoConta: tipoConta ?? this.tipoConta,
      isPrincipal: isPrincipal ?? this.isPrincipal,
    );
  }
}
