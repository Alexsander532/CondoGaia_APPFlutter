/// Modelo de dados para porteiros de condomínios
/// Porteiros têm acesso exclusivo à área de Portaria
class Porteiro {
  final String id;
  final String condominioId;
  final String nomeCompleto;
  final String cpf;
  final String senhaAcesso;
  final String? celular;
  final String? email;
  final String? fotoPerfil;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Porteiro({
    required this.id,
    required this.condominioId,
    required this.nomeCompleto,
    required this.cpf,
    required this.senhaAcesso,
    this.celular,
    this.email,
    this.fotoPerfil,
    this.ativo = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma instância de Porteiro a partir de um Map (JSON)
  factory Porteiro.fromJson(Map<String, dynamic> json) {
    return Porteiro(
      id: json['id'] as String,
      condominioId: json['condominio_id'] as String,
      nomeCompleto: json['nome_completo'] as String,
      cpf: json['cpf'] as String,
      senhaAcesso: json['senha_acesso'] as String,
      celular: json['celular'] as String?,
      email: json['email'] as String?,
      fotoPerfil: json['foto_perfil'] as String?,
      ativo: json['ativo'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte a instância de Porteiro para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'condominio_id': condominioId,
      'nome_completo': nomeCompleto,
      'cpf': cpf,
      'senha_acesso': senhaAcesso,
      'celular': celular,
      'email': email,
      'foto_perfil': fotoPerfil,
      'ativo': ativo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cria uma cópia do porteiro com campos modificados
  Porteiro copyWith({
    String? id,
    String? condominioId,
    String? nomeCompleto,
    String? cpf,
    String? senhaAcesso,
    String? celular,
    String? email,
    String? fotoPerfil,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Porteiro(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      cpf: cpf ?? this.cpf,
      senhaAcesso: senhaAcesso ?? this.senhaAcesso,
      celular: celular ?? this.celular,
      email: email ?? this.email,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se o porteiro tem foto de perfil
  bool get temFotoPerfil => fotoPerfil != null && fotoPerfil!.isNotEmpty;

  /// Retorna o CPF formatado (XXX.XXX.XXX-XX)
  String get cpfFormatado {
    final cpfLimpo = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpfLimpo.length != 11) return cpf;
    return '${cpfLimpo.substring(0, 3)}.${cpfLimpo.substring(3, 6)}.${cpfLimpo.substring(6, 9)}-${cpfLimpo.substring(9, 11)}';
  }

  @override
  String toString() {
    return 'Porteiro(id: $id, nomeCompleto: $nomeCompleto, cpf: $cpf, condominioId: $condominioId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Porteiro && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
