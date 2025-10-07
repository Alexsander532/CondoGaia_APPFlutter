class Bloco {
  final String id;
  final String condominioId;
  final String nome;
  final String codigo;
  final int ordem;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bloco({
    required this.id,
    required this.condominioId,
    required this.nome,
    required this.codigo,
    required this.ordem,
    this.ativo = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Construtor para criar um novo bloco (sem ID)
  Bloco.novo({
    required this.condominioId,
    required this.nome,
    required this.codigo,
    required this.ordem,
    this.ativo = true,
  })  : id = '',
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  // Converter do JSON do Supabase
  factory Bloco.fromJson(Map<String, dynamic> json) {
    return Bloco(
      id: json['id'] ?? '',
      condominioId: json['condominio_id'] ?? '',
      nome: json['nome'] ?? '',
      codigo: json['codigo'] ?? '',
      ordem: json['ordem'] ?? 0,
      ativo: json['ativo'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Converter para JSON para enviar ao Supabase
  Map<String, dynamic> toJson() {
    return {
      'condominio_id': condominioId,
      'nome': nome,
      'codigo': codigo,
      'ordem': ordem,
      'ativo': ativo,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Converter para JSON incluindo ID (para updates)
  Map<String, dynamic> toJsonWithId() {
    return {
      'id': id,
      'condominio_id': condominioId,
      'nome': nome,
      'codigo': codigo,
      'ordem': ordem,
      'ativo': ativo,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Criar cópia com modificações
  Bloco copyWith({
    String? id,
    String? condominioId,
    String? nome,
    String? codigo,
    int? ordem,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bloco(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      nome: nome ?? this.nome,
      codigo: codigo ?? this.codigo,
      ordem: ordem ?? this.ordem,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Bloco{id: $id, nome: $nome, codigo: $codigo, ordem: $ordem}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bloco &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}