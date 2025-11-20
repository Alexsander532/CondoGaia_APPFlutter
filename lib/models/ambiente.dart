class Ambiente {
  final String? id;
  final String titulo;
  final String? descricao;
  final double valor;
  final String? limiteHorario; // time without time zone
  final String? limiteTempoDuracao; // text - entrada livre do usuário
  final String? diasBloqueados; // text - entrada livre do usuário
  final bool inadimplentePodemReservar; // inadiplente_podem_assinar
  final DateTime? createdAt; // created_at - mapeamento correto
  final DateTime? updatedAt; // updated_at - mapeamento correto
  final String? createdBy; // created_by - mapeamento correto
  final String? updatedBy; // updated_by - mapeamento correto
  final String? fotoUrl; // Foto do ambiente
  final String? locacaoUrl; // URL do PDF do termo de locação

  const Ambiente({
    this.id,
    required this.titulo,
    this.descricao,
    required this.valor,
    this.limiteHorario,
    this.limiteTempoDuracao,
    this.diasBloqueados,
    this.inadimplentePodemReservar = false,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.fotoUrl,
    this.locacaoUrl,
  });

  // Construtor para criar uma instância a partir de JSON (Supabase)
  factory Ambiente.fromJson(Map<String, dynamic> json) {
    return Ambiente(
      id: json['id']?.toString(),
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'],
      valor: (json['valor'] ?? 0.0).toDouble(),
      limiteHorario: json['limite_horario'],
      limiteTempoDuracao: json['limite_tempo_duracao'],
      diasBloqueados: json['dias_bloqueados'],
      inadimplentePodemReservar: json['inadiplente_podem_assinar'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      fotoUrl: json['foto_url'],
      locacaoUrl: json['locacao_url'],
    );
  }

  // Converter para JSON (para enviar ao Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'valor': valor,
      'limite_horario': limiteHorario,
      'limite_tempo_duracao': limiteTempoDuracao,
      'dias_bloqueados': diasBloqueados,
      'inadiplente_podem_assinar': inadimplentePodemReservar,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (fotoUrl != null) 'foto_url': fotoUrl,
      if (locacaoUrl != null) 'locacao_url': locacaoUrl,
    };
  }

  // Método para criar uma cópia com alterações
  Ambiente copyWith({
    String? id,
    String? titulo,
    String? descricao,
    double? valor,
    String? limiteHorario,
    int? limiteTempoDuracao,
    List<int>? diasBloqueados,
    bool? inadimplentePodemReservar,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    String? fotoUrl,
    String? locacaoUrl,
  }) {
    return Ambiente(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      limiteHorario: limiteHorario ?? this.limiteHorario,
      limiteTempoDuracao: limiteTempoDuracao?.toString() ?? this.limiteTempoDuracao,
      diasBloqueados: diasBloqueados?.toString() ?? this.diasBloqueados,
      inadimplentePodemReservar: inadimplentePodemReservar ?? this.inadimplentePodemReservar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      locacaoUrl: locacaoUrl ?? this.locacaoUrl,
    );
  }

  // Método para validar se o ambiente está configurado corretamente
  bool get isValid {
    return titulo.isNotEmpty && valor >= 0;
  }

  // Método para formatar o valor como moeda
  String get valorFormatado {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  String toString() {
    return 'Ambiente{id: $id, titulo: $titulo, valor: $valor}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ambiente && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}