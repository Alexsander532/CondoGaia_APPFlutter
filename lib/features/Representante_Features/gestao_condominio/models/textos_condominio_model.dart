class TextosCondominio {
  final String? id;
  final String condominioId;
  final String comunicadoBoletoCota;
  final String comunicadoBoletoAcordo;
  final String textoBoletoTaxa;
  final String textoBoletoAcordo;
  final String responsavelTecnicoNome;
  final String responsavelTecnicoCpf;
  final String responsavelTecnicoConselho;
  final String responsavelTecnicoFuncoes;
  final bool exibirDataDemonstrativo;

  TextosCondominio({
    this.id,
    required this.condominioId,
    this.comunicadoBoletoCota = '',
    this.comunicadoBoletoAcordo = '',
    this.textoBoletoTaxa = '',
    this.textoBoletoAcordo = '',
    this.responsavelTecnicoNome = '',
    this.responsavelTecnicoCpf = '',
    this.responsavelTecnicoConselho = '',
    this.responsavelTecnicoFuncoes = '',
    this.exibirDataDemonstrativo = true,
  });

  factory TextosCondominio.fromJson(Map<String, dynamic> json) {
    return TextosCondominio(
      id: json['id'],
      condominioId: json['condominio_id'],
      comunicadoBoletoCota: json['comunicado_boleto_cota'] ?? '',
      comunicadoBoletoAcordo: json['comunicado_boleto_acordo'] ?? '',
      textoBoletoTaxa: json['texto_boleto_taxa'] ?? '',
      textoBoletoAcordo: json['texto_boleto_acordo'] ?? '',
      responsavelTecnicoNome: json['responsavel_tecnico_nome'] ?? '',
      responsavelTecnicoCpf: json['responsavel_tecnico_cpf'] ?? '',
      responsavelTecnicoConselho: json['responsavel_tecnico_conselho'] ?? '',
      responsavelTecnicoFuncoes: json['responsavel_tecnico_funcoes'] ?? '',
      exibirDataDemonstrativo: json['exibir_data_demonstrativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'condominio_id': condominioId,
      'comunicado_boleto_cota': comunicadoBoletoCota,
      'comunicado_boleto_acordo': comunicadoBoletoAcordo,
      'texto_boleto_taxa': textoBoletoTaxa,
      'texto_boleto_acordo': textoBoletoAcordo,
      'responsavel_tecnico_nome': responsavelTecnicoNome,
      'responsavel_tecnico_cpf': responsavelTecnicoCpf,
      'responsavel_tecnico_conselho': responsavelTecnicoConselho,
      'responsavel_tecnico_funcoes': responsavelTecnicoFuncoes,
      'exibir_data_demonstrativo': exibirDataDemonstrativo,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  TextosCondominio copyWith({
    String? id,
    String? condominioId,
    String? comunicadoBoletoCota,
    String? comunicadoBoletoAcordo,
    String? textoBoletoTaxa,
    String? textoBoletoAcordo,
    String? responsavelTecnicoNome,
    String? responsavelTecnicoCpf,
    String? responsavelTecnicoConselho,
    String? responsavelTecnicoFuncoes,
    bool? exibirDataDemonstrativo,
  }) {
    return TextosCondominio(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      comunicadoBoletoCota: comunicadoBoletoCota ?? this.comunicadoBoletoCota,
      comunicadoBoletoAcordo:
          comunicadoBoletoAcordo ?? this.comunicadoBoletoAcordo,
      textoBoletoTaxa: textoBoletoTaxa ?? this.textoBoletoTaxa,
      textoBoletoAcordo: textoBoletoAcordo ?? this.textoBoletoAcordo,
      responsavelTecnicoNome:
          responsavelTecnicoNome ?? this.responsavelTecnicoNome,
      responsavelTecnicoCpf:
          responsavelTecnicoCpf ?? this.responsavelTecnicoCpf,
      responsavelTecnicoConselho:
          responsavelTecnicoConselho ?? this.responsavelTecnicoConselho,
      responsavelTecnicoFuncoes:
          responsavelTecnicoFuncoes ?? this.responsavelTecnicoFuncoes,
      exibirDataDemonstrativo:
          exibirDataDemonstrativo ?? this.exibirDataDemonstrativo,
    );
  }
}
