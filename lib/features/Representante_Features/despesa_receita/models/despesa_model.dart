import 'package:equatable/equatable.dart';

class Despesa extends Equatable {
  final String? id;
  final String condominioId;
  final String? contaId;
  final String? categoriaId;
  final String? subcategoriaId;
  final String? descricao;
  final double valor;
  final DateTime? dataVencimento;
  final bool recorrente;
  final int? qtdMeses;
  final bool meAvisar;
  final String? link;
  final String? fotoUrl;
  final String tipo; // MANUAL ou AUTOMATICO
  final DateTime? createdAt;

  // Campos auxiliares (join data, não salvos diretamente)
  final String? contaNome;
  final String? categoriaNome;
  final String? subcategoriaNome;

  const Despesa({
    this.id,
    required this.condominioId,
    this.contaId,
    this.categoriaId,
    this.subcategoriaId,
    this.descricao,
    this.valor = 0,
    this.dataVencimento,
    this.recorrente = false,
    this.qtdMeses,
    this.meAvisar = false,
    this.link,
    this.fotoUrl,
    this.tipo = 'MANUAL',
    this.createdAt,
    this.contaNome,
    this.categoriaNome,
    this.subcategoriaNome,
  });

  factory Despesa.fromJson(Map<String, dynamic> json) {
    return Despesa(
      id: json['id'],
      condominioId: json['condominio_id'] ?? '',
      contaId: json['conta_id'],
      categoriaId: json['categoria_id'],
      subcategoriaId: json['subcategoria_id'],
      descricao: json['descricao'],
      valor: (json['valor'] ?? 0).toDouble(),
      dataVencimento: json['data_vencimento'] != null
          ? DateTime.tryParse(json['data_vencimento'])
          : null,
      recorrente: json['recorrente'] ?? false,
      qtdMeses: json['qtd_meses'],
      meAvisar: json['me_avisar'] ?? false,
      link: json['link'],
      fotoUrl: json['foto_url'],
      tipo: json['tipo'] ?? 'MANUAL',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      // Auxiliary join fields
      contaNome: json['contas_bancarias']?['banco'],
      categoriaNome: json['categorias_financeiras']?['nome'],
      subcategoriaNome: json['subcategorias_financeiras']?['nome'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'condominio_id': condominioId,
      'conta_id': contaId,
      'categoria_id': categoriaId,
      'subcategoria_id': subcategoriaId,
      'descricao': descricao,
      'valor': valor,
      'data_vencimento': dataVencimento?.toIso8601String().split('T').first,
      'recorrente': recorrente,
      'qtd_meses': qtdMeses,
      'me_avisar': meAvisar,
      'link': link,
      'foto_url': fotoUrl,
      'tipo': tipo,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  Despesa copyWith({
    String? id,
    String? condominioId,
    String? contaId,
    String? categoriaId,
    String? subcategoriaId,
    String? descricao,
    double? valor,
    DateTime? dataVencimento,
    bool? recorrente,
    int? qtdMeses,
    bool? meAvisar,
    String? link,
    String? fotoUrl,
    String? tipo,
    DateTime? createdAt,
    String? contaNome,
    String? categoriaNome,
    String? subcategoriaNome,
  }) {
    return Despesa(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      contaId: contaId ?? this.contaId,
      categoriaId: categoriaId ?? this.categoriaId,
      subcategoriaId: subcategoriaId ?? this.subcategoriaId,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      recorrente: recorrente ?? this.recorrente,
      qtdMeses: qtdMeses ?? this.qtdMeses,
      meAvisar: meAvisar ?? this.meAvisar,
      link: link ?? this.link,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      tipo: tipo ?? this.tipo,
      createdAt: createdAt ?? this.createdAt,
      contaNome: contaNome ?? this.contaNome,
      categoriaNome: categoriaNome ?? this.categoriaNome,
      subcategoriaNome: subcategoriaNome ?? this.subcategoriaNome,
    );
  }

  @override
  List<Object?> get props => [
    id,
    condominioId,
    contaId,
    categoriaId,
    subcategoriaId,
    descricao,
    valor,
    dataVencimento,
    recorrente,
    qtdMeses,
    meAvisar,
    link,
    fotoUrl,
    tipo,
    createdAt,
    contaNome,
    categoriaNome,
    subcategoriaNome,
  ];
}
