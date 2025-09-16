class Documento {
  final String id;
  final String nome;
  final String? descricao;
  final String tipo; // 'pasta' ou 'arquivo'
  final String? url;
  final String? linkExterno;
  final bool privado;
  final String? pastaId; // Se for um arquivo, referencia a pasta pai
  final String condominioId;
  final String representanteId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Documento({
    required this.id,
    required this.nome,
    this.descricao,
    required this.tipo,
    this.url,
    this.linkExterno,
    required this.privado,
    this.pastaId,
    required this.condominioId,
    required this.representanteId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      tipo: json['tipo'],
      url: json['url'],
      linkExterno: json['link_externo'],
      privado: json['privado'] ?? false,
      pastaId: json['pasta_id'],
      condominioId: json['condominio_id'],
      representanteId: json['representante_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo,
      'url': url,
      'link_externo': linkExterno,
      'privado': privado,
      'pasta_id': pastaId,
      'condominio_id': condominioId,
      'representante_id': representanteId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = <String, dynamic>{
      'nome': nome,
      'tipo': tipo,
      'privado': privado,
      'condominio_id': condominioId,
      'representante_id': representanteId,
    };

    if (descricao != null) json['descricao'] = descricao;
    if (url != null) json['url'] = url;
    if (linkExterno != null) json['link_externo'] = linkExterno;
    if (pastaId != null) json['pasta_id'] = pastaId;

    return json;
  }

  Documento copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? tipo,
    String? url,
    String? linkExterno,
    bool? privado,
    String? pastaId,
    String? condominioId,
    String? representanteId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Documento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      url: url ?? this.url,
      linkExterno: linkExterno ?? this.linkExterno,
      privado: privado ?? this.privado,
      pastaId: pastaId ?? this.pastaId,
      condominioId: condominioId ?? this.condominioId,
      representanteId: representanteId ?? this.representanteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Método auxiliar para verificar se é uma pasta
  bool get isPasta => tipo == 'pasta';

  // Método auxiliar para verificar se é um arquivo
  bool get isArquivo => tipo == 'arquivo';

  @override
  String toString() {
    return 'Documento{id: $id, nome: $nome, tipo: $tipo, privado: $privado}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Documento &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}