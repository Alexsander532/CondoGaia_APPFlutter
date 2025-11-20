/// Modelo de dados para imobiliárias
class Imobiliaria {
  final String id;
  final String condominioId;
  final String nome;
  final String cnpj;
  final String? telefone;
  final String? celular;
  final String? email;
  final bool? ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Imobiliaria({
    required this.id,
    required this.condominioId,
    required this.nome,
    required this.cnpj,
    this.telefone,
    this.celular,
    this.email,
    this.ativo,
    this.createdAt,
    this.updatedAt,
  });

  factory Imobiliaria.fromJson(Map<String, dynamic> json) {
    return Imobiliaria(
      id: json['id'] as String,
      condominioId: json['condominio_id'] as String,
      nome: json['nome'] as String,
      cnpj: json['cnpj'] as String,
      telefone: json['telefone'] as String?,
      celular: json['celular'] as String?,
      email: json['email'] as String?,
      ativo: json['ativo'] as bool?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'condominio_id': condominioId,
      'nome': nome,
      'cnpj': cnpj,
      'telefone': telefone,
      'celular': celular,
      'email': email,
      'ativo': ativo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Imobiliaria copyWith({
    String? id,
    String? condominioId,
    String? nome,
    String? cnpj,
    String? telefone,
    String? celular,
    String? email,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Imobiliaria(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      nome: nome ?? this.nome,
      cnpj: cnpj ?? this.cnpj,
      telefone: telefone ?? this.telefone,
      celular: celular ?? this.celular,
      email: email ?? this.email,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Imobiliaria(id: $id, nome: $nome, cnpj: $cnpj)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Imobiliaria &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nome == other.nome &&
          cnpj == other.cnpj;

  @override
  int get hashCode => id.hashCode ^ nome.hashCode ^ cnpj.hashCode;
}
