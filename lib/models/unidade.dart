class Unidade {
  final String id;
  final String condominioId;
  final String blocoId;
  final String numero;
  final bool temProprietario;
  final bool temInquilino;
  final bool temImobiliaria;
  final bool ativo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Unidade({
    required this.id,
    required this.condominioId,
    required this.blocoId,
    required this.numero,
    this.temProprietario = false,
    this.temInquilino = false,
    this.temImobiliaria = false,
    this.ativo = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Construtor para criar uma nova unidade (sem ID)
  Unidade.nova({
    required this.condominioId,
    required this.blocoId,
    required this.numero,
    this.temProprietario = false,
    this.temInquilino = false,
    this.temImobiliaria = false,
    this.ativo = true,
  })  : id = '',
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  // Converter do JSON do Supabase
  factory Unidade.fromJson(Map<String, dynamic> json) {
    return Unidade(
      id: json['id'] ?? '',
      condominioId: json['condominio_id'] ?? '',
      blocoId: json['bloco_id'] ?? '',
      numero: json['numero'] ?? '',
      temProprietario: json['tem_proprietario'] ?? false,
      temInquilino: json['tem_inquilino'] ?? false,
      temImobiliaria: json['tem_imobiliaria'] ?? false,
      ativo: json['ativo'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Converter para JSON para enviar ao Supabase
  Map<String, dynamic> toJson() {
    return {
      'condominio_id': condominioId,
      'bloco_id': blocoId,
      'numero': numero,
      'tem_proprietario': temProprietario,
      'tem_inquilino': temInquilino,
      'tem_imobiliaria': temImobiliaria,
      'ativo': ativo,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Converter para JSON incluindo ID (para updates)
  Map<String, dynamic> toJsonWithId() {
    return {
      'id': id,
      'condominio_id': condominioId,
      'bloco_id': blocoId,
      'numero': numero,
      'tem_proprietario': temProprietario,
      'tem_inquilino': temInquilino,
      'tem_imobiliaria': temImobiliaria,
      'ativo': ativo,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Criar cópia com modificações
  Unidade copyWith({
    String? id,
    String? condominioId,
    String? blocoId,
    String? numero,
    bool? temProprietario,
    bool? temInquilino,
    bool? temImobiliaria,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Unidade(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      blocoId: blocoId ?? this.blocoId,
      numero: numero ?? this.numero,
      temProprietario: temProprietario ?? this.temProprietario,
      temInquilino: temInquilino ?? this.temInquilino,
      temImobiliaria: temImobiliaria ?? this.temImobiliaria,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Verificar se a unidade tem moradores
  bool get temMoradores => temProprietario || temInquilino;

  // Status da unidade para exibição
  String get status {
    if (temProprietario && temInquilino) return 'Proprietário + Inquilino';
    if (temProprietario) return 'Proprietário';
    if (temInquilino) return 'Inquilino';
    if (temImobiliaria) return 'Imobiliária';
    return 'Vazia';
  }

  @override
  String toString() {
    return 'Unidade{id: $id, numero: $numero, status: $status}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unidade &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}