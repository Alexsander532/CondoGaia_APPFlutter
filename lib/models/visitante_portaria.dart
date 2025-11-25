/// Modelo de dados para visitantes autorizados pela portaria do representante
class VisitantePortaria {
  final String id;
  final String condominioId;
  final String? unidadeId;
  final String nome;
  final String cpf;
  final String celular;
  final String tipoAutorizacao;
  final String? quemAutorizou;
  final String? observacoes;
  final DateTime dataVisita;
  final String? horaEntrada;
  final String? horaSaida;
  final String statusVisita;
  final String? veiculoTipo;
  final String? veiculoMarca;
  final String? veiculoModelo;
  final String? veiculoCor;
  final String? veiculoPlaca;
  final String? fotoUrl;
  final String? qrCodeUrl;
  final bool ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VisitantePortaria({
    required this.id,
    required this.condominioId,
    this.unidadeId,
    required this.nome,
    required this.cpf,
    required this.celular,
    this.tipoAutorizacao = 'unidade',
    this.quemAutorizou,
    this.observacoes,
    required this.dataVisita,
    this.horaEntrada,
    this.horaSaida,
    this.statusVisita = 'agendado',
    this.veiculoTipo,
    this.veiculoMarca,
    this.veiculoModelo,
    this.veiculoCor,
    this.veiculoPlaca,
    this.fotoUrl,
    this.qrCodeUrl,
    this.ativo = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Cria uma instância de VisitantePortaria a partir de um Map (JSON)
  factory VisitantePortaria.fromJson(Map<String, dynamic> json) {
    return VisitantePortaria(
      id: json['id'] as String,
      condominioId: json['condominio_id'] as String,
      unidadeId: json['unidade_id'] as String?,
      nome: json['nome'] as String,
      cpf: json['cpf'] as String,
      celular: json['celular'] as String,
      tipoAutorizacao: json['tipo_autorizacao'] as String? ?? 'unidade',
      quemAutorizou: json['quem_autorizou'] as String?,
      observacoes: json['observacoes'] as String?,
      dataVisita: DateTime.parse(json['data_visita'] as String),
      horaEntrada: json['hora_entrada'] as String?,
      horaSaida: json['hora_saida'] as String?,
      statusVisita: json['status_visita'] as String? ?? 'agendado',
      veiculoTipo: json['veiculo_tipo'] as String?,
      veiculoMarca: json['veiculo_marca'] as String?,
      veiculoModelo: json['veiculo_modelo'] as String?,
      veiculoCor: json['veiculo_cor'] as String?,
      veiculoPlaca: json['veiculo_placa'] as String?,
      fotoUrl: json['foto_url'] as String?,
      qrCodeUrl: json['qr_code_url'] as String?,
      ativo: json['ativo'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converte a instância de VisitantePortaria para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'condominio_id': condominioId,
      'unidade_id': unidadeId,
      'nome': nome,
      'cpf': cpf,
      'celular': celular,
      'tipo_autorizacao': tipoAutorizacao,
      'quem_autorizou': quemAutorizou,
      'observacoes': observacoes,
      'data_visita': dataVisita.toIso8601String().split(
        'T',
      )[0], // Apenas a data
      'hora_entrada': horaEntrada,
      'hora_saida': horaSaida,
      'status_visita': statusVisita,
      'veiculo_tipo': veiculoTipo,
      'veiculo_marca': veiculoMarca,
      'veiculo_modelo': veiculoModelo,
      'veiculo_cor': veiculoCor,
      'veiculo_placa': veiculoPlaca,
      'foto_url': fotoUrl,
      'qr_code_url': qrCodeUrl,
      'ativo': ativo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Converte para Map para inserção no banco (sem id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  /// Cria uma cópia do visitante com campos modificados
  VisitantePortaria copyWith({
    String? id,
    String? condominioId,
    String? unidadeId,
    String? nome,
    String? cpf,
    String? celular,
    String? tipoAutorizacao,
    String? quemAutorizou,
    String? observacoes,
    DateTime? dataVisita,
    String? horaEntrada,
    String? horaSaida,
    String? statusVisita,
    String? veiculoTipo,
    String? veiculoMarca,
    String? veiculoModelo,
    String? veiculoCor,
    String? veiculoPlaca,
    String? fotoUrl,
    String? qrCodeUrl,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VisitantePortaria(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      unidadeId: unidadeId ?? this.unidadeId,
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      celular: celular ?? this.celular,
      tipoAutorizacao: tipoAutorizacao ?? this.tipoAutorizacao,
      quemAutorizou: quemAutorizou ?? this.quemAutorizou,
      observacoes: observacoes ?? this.observacoes,
      dataVisita: dataVisita ?? this.dataVisita,
      horaEntrada: horaEntrada ?? this.horaEntrada,
      horaSaida: horaSaida ?? this.horaSaida,
      statusVisita: statusVisita ?? this.statusVisita,
      veiculoTipo: veiculoTipo ?? this.veiculoTipo,
      veiculoMarca: veiculoMarca ?? this.veiculoMarca,
      veiculoModelo: veiculoModelo ?? this.veiculoModelo,
      veiculoCor: veiculoCor ?? this.veiculoCor,
      veiculoPlaca: veiculoPlaca ?? this.veiculoPlaca,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'VisitantePortaria(id: $id, nome: $nome, cpf: $cpf, tipoAutorizacao: $tipoAutorizacao)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VisitantePortaria && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}