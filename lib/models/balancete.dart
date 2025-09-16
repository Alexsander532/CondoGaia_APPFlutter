class Balancete {
  final String id;
  final String nomeArquivo;
  final String? url;
  final String? linkExterno;
  final String mes;
  final String ano;
  final bool privado;
  final String condominioId;
  final String representanteId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Balancete({
    required this.id,
    required this.nomeArquivo,
    this.url,
    this.linkExterno,
    required this.mes,
    required this.ano,
    required this.privado,
    required this.condominioId,
    required this.representanteId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Balancete.fromJson(Map<String, dynamic> json) {
    return Balancete(
      id: json['id'],
      nomeArquivo: json['nome_arquivo'],
      url: json['url'],
      linkExterno: json['link_externo'],
      mes: json['mes'],
      ano: json['ano'],
      privado: json['privado'] ?? false,
      condominioId: json['condominio_id'],
      representanteId: json['representante_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_arquivo': nomeArquivo,
      'url': url,
      'link_externo': linkExterno,
      'mes': mes,
      'ano': ano,
      'privado': privado,
      'condominio_id': condominioId,
      'representante_id': representanteId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = <String, dynamic>{
      'nome_arquivo': nomeArquivo,
      'mes': mes,
      'ano': ano,
      'privado': privado,
      'condominio_id': condominioId,
      'representante_id': representanteId,
    };

    if (url != null) json['url'] = url;
    if (linkExterno != null) json['link_externo'] = linkExterno;

    return json;
  }

  Balancete copyWith({
    String? id,
    String? nomeArquivo,
    String? url,
    String? linkExterno,
    String? mes,
    String? ano,
    bool? privado,
    String? condominioId,
    String? representanteId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Balancete(
      id: id ?? this.id,
      nomeArquivo: nomeArquivo ?? this.nomeArquivo,
      url: url ?? this.url,
      linkExterno: linkExterno ?? this.linkExterno,
      mes: mes ?? this.mes,
      ano: ano ?? this.ano,
      privado: privado ?? this.privado,
      condominioId: condominioId ?? this.condominioId,
      representanteId: representanteId ?? this.representanteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Método auxiliar para obter o período formatado
  String get periodoFormatado => '$mes/$ano';

  @override
  String toString() {
    return 'Balancete{id: $id, nomeArquivo: $nomeArquivo, periodo: $periodoFormatado}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Balancete &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}