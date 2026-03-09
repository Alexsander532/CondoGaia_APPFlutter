import 'package:equatable/equatable.dart';

class Receita extends Equatable {
  final String? id;
  final String condominioId;
  final String? contaId;
  final String? categoriaId;
  final String? subcategoriaId;
  final String? contaContabil;
  final String? descricao;
  final double valor;
  final DateTime? dataCredito;
  final bool recorrente;
  final int? qtdMeses;
  final String tipo; // MANUAL ou AUTOMATICO
  final DateTime? createdAt;

  // Campos auxiliares (join data)
  final String? contaNome;
  final String? categoriaNome;
  final String? subcategoriaNome;

  const Receita({
    this.id,
    required this.condominioId,
    this.contaId,
    this.categoriaId,
    this.subcategoriaId,
    this.contaContabil,
    this.descricao,
    this.valor = 0,
    this.dataCredito,
    this.recorrente = false,
    this.qtdMeses,
    this.tipo = 'MANUAL',
    this.createdAt,
    this.contaNome,
    this.categoriaNome,
    this.subcategoriaNome,
  });

  factory Receita.fromJson(Map<String, dynamic> json) {
    return Receita(
      id: json['id'],
      condominioId: json['condominio_id'] ?? '',
      contaId: json['conta_id'],
      categoriaId: json['categoria_id'],
      subcategoriaId: json['subcategoria_id'],
      contaContabil: json['conta_contabil'],
      descricao: json['descricao'],
      valor: (json['valor'] ?? 0).toDouble(),
      dataCredito: json['data_credito'] != null
          ? DateTime.tryParse(json['data_credito'])
          : null,
      recorrente: json['recorrente'] ?? false,
      qtdMeses: json['qtd_meses'],
      tipo: json['tipo'] ?? 'MANUAL',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
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
      'conta_contabil': contaContabil,
      'descricao': descricao,
      'valor': valor,
      'data_credito': dataCredito?.toIso8601String().split('T').first,
      'recorrente': recorrente,
      'qtd_meses': qtdMeses,
      'tipo': tipo,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  Receita copyWith({
    String? id,
    String? condominioId,
    String? contaId,
    String? categoriaId,
    String? subcategoriaId,
    String? contaContabil,
    String? descricao,
    double? valor,
    DateTime? dataCredito,
    bool? recorrente,
    int? qtdMeses,
    String? tipo,
    DateTime? createdAt,
    String? contaNome,
    String? categoriaNome,
    String? subcategoriaNome,
  }) {
    return Receita(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      contaId: contaId ?? this.contaId,
      categoriaId: categoriaId ?? this.categoriaId,
      subcategoriaId: subcategoriaId ?? this.subcategoriaId,
      contaContabil: contaContabil ?? this.contaContabil,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      dataCredito: dataCredito ?? this.dataCredito,
      recorrente: recorrente ?? this.recorrente,
      qtdMeses: qtdMeses ?? this.qtdMeses,
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
    contaContabil,
    descricao,
    valor,
    dataCredito,
    recorrente,
    qtdMeses,
    tipo,
    createdAt,
    contaNome,
    categoriaNome,
    subcategoriaNome,
  ];
}
