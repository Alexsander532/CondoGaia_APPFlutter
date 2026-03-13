/// Modelo de email salvo no Supabase para reutilização.
///
/// Associado a um [topico] específico de forma que ao selecionar
/// o tópico o assunto e corpo já são preenchidos automaticamente.
class EmailModeloModel {
  final String id;
  final String condominioId;

  /// Tópico do email (ex: 'Cobrança', 'Comunicado', 'Assembleia')
  final String topico;

  /// Nome de identificação do modelo (ex: 'Circular de Manutenção')
  final String titulo;

  final String assunto;
  final String corpo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const EmailModeloModel({
    required this.id,
    required this.condominioId,
    required this.topico,
    required this.titulo,
    required this.assunto,
    required this.corpo,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory EmailModeloModel.fromJson(Map<String, dynamic> json) {
    return EmailModeloModel(
      id: json['id'] as String,
      condominioId: json['condominio_id'] as String,
      topico: json['topico'] as String,
      titulo: json['titulo'] as String,
      assunto: json['assunto'] as String,
      corpo: json['corpo'] as String,
      criadoEm: DateTime.parse(json['criado_em'] as String),
      atualizadoEm: DateTime.parse(json['atualizado_em'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condominio_id': condominioId,
      'topico': topico,
      'titulo': titulo,
      'assunto': assunto,
      'corpo': corpo,
    };
  }

  EmailModeloModel copyWith({
    String? id,
    String? condominioId,
    String? topico,
    String? titulo,
    String? assunto,
    String? corpo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return EmailModeloModel(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      topico: topico ?? this.topico,
      titulo: titulo ?? this.titulo,
      assunto: assunto ?? this.assunto,
      corpo: corpo ?? this.corpo,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  String toString() => 'EmailModeloModel(titulo: $titulo, topico: $topico)';
}
