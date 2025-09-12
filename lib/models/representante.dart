/// Modelo de dados para representantes de condomínios
class Representante {
  final String id;
  final String nomeCompleto;
  final String cpf;
  final String senhaAcesso;
  final String? fotoPerfil;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Representante({
    required this.id,
    required this.nomeCompleto,
    required this.cpf,
    required this.senhaAcesso,
    this.fotoPerfil,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma instância de Representante a partir de um Map (JSON)
  factory Representante.fromJson(Map<String, dynamic> json) {
    return Representante(
      id: json['id'] as String,
      nomeCompleto: json['nome_completo'] as String,
      cpf: json['cpf'] as String,
      senhaAcesso: json['senha_acesso'] as String,
      fotoPerfil: json['foto_perfil'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converte a instância de Representante para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_completo': nomeCompleto,
      'cpf': cpf,
      'senha_acesso': senhaAcesso,
      'foto_perfil': fotoPerfil,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cria uma cópia do representante com campos modificados
  Representante copyWith({
    String? id,
    String? nomeCompleto,
    String? cpf,
    String? senhaAcesso,
    String? fotoPerfil,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Representante(
      id: id ?? this.id,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      cpf: cpf ?? this.cpf,
      senhaAcesso: senhaAcesso ?? this.senhaAcesso,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se o representante tem foto de perfil
  bool get temFotoPerfil => fotoPerfil != null && fotoPerfil!.isNotEmpty;

  /// Retorna o CPF formatado (XXX.XXX.XXX-XX)
  String get cpfFormatado {
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';
  }

  @override
  String toString() {
    return 'Representante(id: $id, nomeCompleto: $nomeCompleto, cpf: $cpf)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Representante && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}