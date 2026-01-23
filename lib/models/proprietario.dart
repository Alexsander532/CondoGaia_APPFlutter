/// Modelo de dados para proprietários de unidades
class Proprietario {
  final String id;
  final String condominioId;
  final String? unidadeId;
  final String nome;
  final String cpfCnpj;
  final String? cep;
  final String? endereco;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final String? telefone;
  final String? celular;
  final String? email;
  final String? conjuge;
  final String? multiproprietarios;
  final String? moradores;
  final bool? ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? senhaAcesso;
  final String? fotoPerfil;
  final String? qrCodeUrl;
  final bool? agruparBoletos;
  final bool? matriculaImovel;
  final String? matriculaImovelUrl;

  const Proprietario({
    required this.id,
    required this.condominioId,
    this.unidadeId,
    required this.nome,
    required this.cpfCnpj,
    this.cep,
    this.endereco,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.estado,
    this.telefone,
    this.celular,
    this.email,
    this.conjuge,
    this.multiproprietarios,
    this.moradores,
    this.ativo,
    this.createdAt,
    this.updatedAt,
    this.senhaAcesso,
    this.fotoPerfil,
    this.qrCodeUrl,
    this.agruparBoletos,
    this.matriculaImovel,
    this.matriculaImovelUrl,
  });

  /// Cria uma instância de Proprietario a partir de um Map (JSON)
  factory Proprietario.fromJson(Map<String, dynamic> json) {
    return Proprietario(
      id: json['id'] as String,
      condominioId: json['condominio_id'] as String,
      unidadeId: json['unidade_id'] as String?,
      nome: json['nome'] as String,
      cpfCnpj: json['cpf_cnpj'] as String,
      cep: json['cep'] as String?,
      endereco: json['endereco'] as String?,
      numero: json['numero'] as String?,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      telefone: json['telefone'] as String?,
      celular: json['celular'] as String?,
      email: json['email'] as String?,
      conjuge: json['conjuge'] as String?,
      multiproprietarios: json['multiproprietarios'] as String?,
      moradores: json['moradores'] as String?,
      ativo: json['ativo'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      senhaAcesso: json['senha_acesso'] as String?,
      fotoPerfil: json['foto_perfil'] as String?,
      qrCodeUrl: json['qr_code_url'] as String?,
      agruparBoletos: json['agrupar_boletos'] as bool?,
      matriculaImovel: json['matricula_imovel'] as bool?,
      matriculaImovelUrl: json['matricula_imovel_url'] as String?,
    );
  }

  /// Converte a instância de Proprietario para um Map (JSON)
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
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'telefone': telefone,
      'celular': celular,
      'email': email,
      'conjuge': conjuge,
      'multiproprietarios': multiproprietarios,
      'moradores': moradores,
      'ativo': ativo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'senha_acesso': senhaAcesso,
      'foto_perfil': fotoPerfil,
      'qr_code_url': qrCodeUrl,
      'agrupar_boletos': agruparBoletos,
      'matricula_imovel': matriculaImovel,
      'matricula_imovel_url': matriculaImovelUrl,
    };
  }

  /// Cria uma cópia do proprietário com campos modificados
  Proprietario copyWith({
    String? id,
    String? condominioId,
    String? unidadeId,
    String? nome,
    String? cpfCnpj,
    String? cep,
    String? endereco,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? estado,
    String? telefone,
    String? celular,
    String? email,
    String? conjuge,
    String? multiproprietarios,
    String? moradores,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? senhaAcesso,
    String? fotoPerfil,
    String? qrCodeUrl,
    String? matriculaImovelUrl,
  }) {
    return Proprietario(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      unidadeId: unidadeId ?? this.unidadeId,
      nome: nome ?? this.nome,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      cep: cep ?? this.cep,
      endereco: endereco ?? this.endereco,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      telefone: telefone ?? this.telefone,
      celular: celular ?? this.celular,
      email: email ?? this.email,
      conjuge: conjuge ?? this.conjuge,
      multiproprietarios: multiproprietarios ?? this.multiproprietarios,
      moradores: moradores ?? this.moradores,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      senhaAcesso: senhaAcesso ?? this.senhaAcesso,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      matriculaImovelUrl: matriculaImovelUrl ?? this.matriculaImovelUrl,
    );
  }

  /// Verifica se o proprietário tem foto de perfil
  bool get temFotoPerfil => fotoPerfil != null && fotoPerfil!.isNotEmpty;

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
    return 'Proprietario(id: $id, nome: $nome, cpfCnpj: $cpfCnpj, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Proprietario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
