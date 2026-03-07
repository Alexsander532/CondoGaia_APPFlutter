/// Representa um lançamento/boleto na aba Pesquisar
class Acordo {
  final String? id;
  final String blUnid;
  final String parcela; // ex: "1/5"
  final String mesAno; // ex: "05/2022"
  final DateTime dataVencimento;
  final double valor;
  final String tipo; // MENSAL, AVULSO, ACORDO
  final String situacao; // PAGO, ATIVO, A VENCER, CANCELADO, CANCELADO ACORDO
  final String? anexoUrl;
  final String? nome;
  bool selecionado;

  Acordo({
    this.id,
    required this.blUnid,
    required this.parcela,
    required this.mesAno,
    required this.dataVencimento,
    required this.valor,
    required this.tipo,
    required this.situacao,
    this.anexoUrl,
    this.nome,
    this.selecionado = false,
  });

  factory Acordo.fromJson(Map<String, dynamic> json) {
    return Acordo(
      id: json['id'],
      blUnid: json['bl_unid'] ?? '',
      parcela: json['parcela'] ?? '',
      mesAno: json['mes_ano'] ?? '',
      dataVencimento: json['data_vencimento'] != null
          ? DateTime.parse(json['data_vencimento'])
          : DateTime.now(),
      valor: (json['valor'] ?? 0).toDouble(),
      tipo: json['tipo'] ?? 'MENSAL',
      situacao: json['situacao'] ?? 'ATIVO',
      anexoUrl: json['anexo_url'],
      nome: json['nome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'bl_unid': blUnid,
      'parcela': parcela,
      'mes_ano': mesAno,
      'data_vencimento': dataVencimento.toIso8601String().split('T').first,
      'valor': valor,
      'tipo': tipo,
      'situacao': situacao,
      'anexo_url': anexoUrl,
      'nome': nome,
    };
  }

  Acordo copyWith({
    String? id,
    String? blUnid,
    String? parcela,
    String? mesAno,
    DateTime? dataVencimento,
    double? valor,
    String? tipo,
    String? situacao,
    String? anexoUrl,
    String? nome,
    bool? selecionado,
  }) {
    return Acordo(
      id: id ?? this.id,
      blUnid: blUnid ?? this.blUnid,
      parcela: parcela ?? this.parcela,
      mesAno: mesAno ?? this.mesAno,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      valor: valor ?? this.valor,
      tipo: tipo ?? this.tipo,
      situacao: situacao ?? this.situacao,
      anexoUrl: anexoUrl ?? this.anexoUrl,
      nome: nome ?? this.nome,
      selecionado: selecionado ?? this.selecionado,
    );
  }
}

/// Representa uma parcela simulada na aba Negociar
class ParcelaAcordo {
  final String? id;
  final String blUnid;
  final String parcela;
  final String mesAno;
  final DateTime dataVencimento;
  final double valor;
  final double juros;
  final double multa;
  final double indice;
  final double outrosAcrescimos;
  final double total;
  bool selecionado;

  ParcelaAcordo({
    this.id,
    required this.blUnid,
    required this.parcela,
    required this.mesAno,
    required this.dataVencimento,
    required this.valor,
    this.juros = 0,
    this.multa = 0,
    this.indice = 0,
    this.outrosAcrescimos = 0,
    required this.total,
    this.selecionado = false,
  });

  ParcelaAcordo copyWith({
    String? id,
    String? blUnid,
    String? parcela,
    String? mesAno,
    DateTime? dataVencimento,
    double? valor,
    double? juros,
    double? multa,
    double? indice,
    double? outrosAcrescimos,
    double? total,
    bool? selecionado,
  }) {
    return ParcelaAcordo(
      id: id ?? this.id,
      blUnid: blUnid ?? this.blUnid,
      parcela: parcela ?? this.parcela,
      mesAno: mesAno ?? this.mesAno,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      valor: valor ?? this.valor,
      juros: juros ?? this.juros,
      multa: multa ?? this.multa,
      indice: indice ?? this.indice,
      outrosAcrescimos: outrosAcrescimos ?? this.outrosAcrescimos,
      total: total ?? this.total,
      selecionado: selecionado ?? this.selecionado,
    );
  }
}

/// Representa uma entrada de log na aba Histórico
class HistoricoAcordo {
  final String? id;
  final String blUnid;
  final DateTime data;
  final String hora;
  final String descricao;

  HistoricoAcordo({
    this.id,
    required this.blUnid,
    required this.data,
    required this.hora,
    required this.descricao,
  });

  factory HistoricoAcordo.fromJson(Map<String, dynamic> json) {
    return HistoricoAcordo(
      id: json['id'],
      blUnid: json['bl_unid'] ?? '',
      data: json['data'] != null
          ? DateTime.parse(json['data'])
          : DateTime.now(),
      hora: json['hora'] ?? '',
      descricao: json['descricao'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'bl_unid': blUnid,
      'data': data.toIso8601String().split('T').first,
      'hora': hora,
      'descricao': descricao,
    };
  }
}
