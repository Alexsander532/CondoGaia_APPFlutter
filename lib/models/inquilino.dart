/// Modelo de dados para inquilinos de unidades
class Inquilino {
  final String id;
  final String condominioId;
  final String unidadeId;
  final String nome;
  final String cpfCnpj;
  final String? cep;
  final String? endereco;
  final String? numero;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String? telefone;
  final String? celular;
  final String? email;
  final String? conjuge;
  final String? multiproprietarios;
  final String? moradores;
  final bool receberBoletoEmail;
  final bool controleLocacao;
  final bool ativo;
  final String? senhaAcesso;
  final String? fotoPerfil;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Inquilino({
    required this.id,
    required this.condominioId,
    required this.unidadeId,
    required this.nome,
    required this.cpfCnpj,
    this.cep,
    this.endereco,
    this.numero,
    this.bairro,
    this.cidade,
    this.estado,
    this.telefone,
    this.celular,
    this.email,
    this.conjuge,
    this.multiproprietarios,
    this.moradores,
    this.receberBoletoEmail = true,
    this.controleLocacao = true,
    this.ativo = true,
    this.senhaAcesso,
    this.fotoPerfil,
    this.createdAt,
    this.updatedAt,
  });

  /// Cria uma instância de Inquilino a partir de um Map (JSON)
  factory Inquilino.fromJson(Map<String, dynamic> json) {
    return Inquilino(
      id: json['id'] as String,
      condominioId: json['condominio_id'] as String,
      unidadeId: json['unidade_id'] as String,
      nome: json['nome'] as String,
      cpfCnpj: json['cpf_cnpj'] as String,
      cep: json['cep'] as String?,
      endereco: json['endereco'] as String?,
      numero: json['numero'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      telefone: json['telefone'] as String?,
      celular: json['celular'] as String?,
      email: json['email'] as String?,
      conjuge: json['conjuge'] as String?,
      multiproprietarios: json['multiproprietarios'] as String?,
      moradores: json['moradores'] as String?,
      receberBoletoEmail: json['receber_boleto_email'] as bool? ?? true,
      controleLocacao: json['controle_locacao'] as bool? ?? true,
      ativo: json['ativo'] as bool? ?? true,
      senhaAcesso: json['senha_acesso'] as String?,
      fotoPerfil: json['foto_perfil'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converte a instância de Inquilino para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'condominio_id': condominioId,
      'unidade_id': unidadeId,
      'nome': nome,
      'cpf_cnpj': cpfCnpj,
      'cep': cep,
      'endereco': endereco,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'telefone': telefone,
      'celular': celular,
      'email': email,
      'conjuge': conjuge,
      'multiproprietarios': multiproprietarios,
      'moradores': moradores,
      'receber_boleto_email': receberBoletoEmail,
      'controle_locacao': controleLocacao,
      'ativo': ativo,
      'senha_acesso': senhaAcesso,
      'foto_perfil': fotoPerfil,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Cria uma cópia do inquilino com campos modificados
  Inquilino copyWith({
    String? id,
    String? condominioId,
    String? unidadeId,
    String? nome,
    String? cpfCnpj,
    String? cep,
    String? endereco,
    String? numero,
    String? bairro,
    String? cidade,
    String? estado,
    String? telefone,
    String? celular,
    String? email,
    String? conjuge,
    String? multiproprietarios,
    String? moradores,
    bool? receberBoletoEmail,
    bool? controleLocacao,
    bool? ativo,
    String? senhaAcesso,
    String? fotoPerfil,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Inquilino(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      unidadeId: unidadeId ?? this.unidadeId,
      nome: nome ?? this.nome,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      cep: cep ?? this.cep,
      endereco: endereco ?? this.endereco,
      numero: numero ?? this.numero,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      telefone: telefone ?? this.telefone,
      celular: celular ?? this.celular,
      email: email ?? this.email,
      conjuge: conjuge ?? this.conjuge,
      multiproprietarios: multiproprietarios ?? this.multiproprietarios,
      moradores: moradores ?? this.moradores,
      receberBoletoEmail: receberBoletoEmail ?? this.receberBoletoEmail,
      controleLocacao: controleLocacao ?? this.controleLocacao,
      ativo: ativo ?? this.ativo,
      senhaAcesso: senhaAcesso ?? this.senhaAcesso,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se o inquilino tem foto de perfil
  bool get temFotoPerfil => fotoPerfil != null && fotoPerfil!.isNotEmpty;

  /// Verifica se o inquilino está ativo
  bool get isAtivo => ativo;

  /// Retorna o CPF/CNPJ formatado
  String get cpfCnpjFormatado {
    final numeros = cpfCnpj.replaceAll(RegExp(r'[^\d]'), '');

    if (numeros.length == 11) {
      // CPF: XXX.XXX.XXX-XX
      return '${numeros.substring(0, 3)}.${numeros.substring(3, 6)}.${numeros.substring(6, 9)}-${numeros.substring(9, 11)}';
    } else if (numeros.length == 14) {
      // CNPJ: XX.XXX.XXX/XXXX-XX
      return '${numeros.substring(0, 2)}.${numeros.substring(2, 5)}.${numeros.substring(5, 8)}/${numeros.substring(8, 12)}-${numeros.substring(12, 14)}';
    }

    return cpfCnpj; // Retorna original se não for CPF nem CNPJ válido
  }

  /// Verifica se é pessoa física (CPF)
  bool get isPessoaFisica {
    final numeros = cpfCnpj.replaceAll(RegExp(r'[^\d]'), '');
    return numeros.length == 11;
  }

  /// Verifica se é pessoa jurídica (CNPJ)
  bool get isPessoaJuridica {
    final numeros = cpfCnpj.replaceAll(RegExp(r'[^\d]'), '');
    return numeros.length == 14;
  }

  @override
  String toString() {
    return 'Inquilino(id: $id, nome: $nome, cpfCnpj: $cpfCnpj, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Inquilino && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
