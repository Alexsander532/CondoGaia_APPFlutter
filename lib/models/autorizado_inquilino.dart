/// Modelo de dados para autorizados de inquilinos/proprietários
class AutorizadoInquilino {
  final String id;
  final String unidadeId;
  final String? inquilinoId;
  final String? proprietarioId;
  final String nome;
  final String cpf;
  final String? parentesco;
  final String? horarioInicio;
  final String? horarioFim;
  final List<int>? diasSemanaPermitidos;
  final String? veiculoMarca;
  final String? veiculoModelo;
  final String? veiculoCor;
  final String? veiculoPlaca;
  final bool ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AutorizadoInquilino({
    required this.id,
    required this.unidadeId,
    this.inquilinoId,
    this.proprietarioId,
    required this.nome,
    required this.cpf,
    this.parentesco,
    this.horarioInicio,
    this.horarioFim,
    this.diasSemanaPermitidos,
    this.veiculoMarca,
    this.veiculoModelo,
    this.veiculoCor,
    this.veiculoPlaca,
    this.ativo = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Cria uma instância de AutorizadoInquilino a partir de um Map (JSON)
  factory AutorizadoInquilino.fromJson(Map<String, dynamic> json) {
    return AutorizadoInquilino(
      id: json['id'] as String,
      unidadeId: json['unidade_id'] as String,
      inquilinoId: json['inquilino_id'] as String?,
      proprietarioId: json['proprietario_id'] as String?,
      nome: json['nome'] as String,
      cpf: json['cpf'] as String,
      parentesco: json['parentesco'] as String?,
      horarioInicio: json['horario_inicio'] as String?,
      horarioFim: json['horario_fim'] as String?,
      diasSemanaPermitidos: json['dias_semana_permitidos'] != null
          ? List<int>.from(json['dias_semana_permitidos'] as List)
          : null,
      veiculoMarca: json['veiculo_marca'] as String?,
      veiculoModelo: json['veiculo_modelo'] as String?,
      veiculoCor: json['veiculo_cor'] as String?,
      veiculoPlaca: json['veiculo_placa'] as String?,
      ativo: json['ativo'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converte a instância de AutorizadoInquilino para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unidade_id': unidadeId,
      'inquilino_id': inquilinoId,
      'proprietario_id': proprietarioId,
      'nome': nome,
      'cpf': cpf,
      'parentesco': parentesco,
      'horario_inicio': horarioInicio,
      'horario_fim': horarioFim,
      'dias_semana_permitidos': diasSemanaPermitidos,
      'veiculo_marca': veiculoMarca,
      'veiculo_modelo': veiculoModelo,
      'veiculo_cor': veiculoCor,
      'veiculo_placa': veiculoPlaca,
      'ativo': ativo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Cria uma cópia do autorizado com campos modificados
  AutorizadoInquilino copyWith({
    String? id,
    String? unidadeId,
    String? inquilinoId,
    String? proprietarioId,
    String? nome,
    String? cpf,
    String? parentesco,
    String? horarioInicio,
    String? horarioFim,
    List<int>? diasSemanaPermitidos,
    String? veiculoMarca,
    String? veiculoModelo,
    String? veiculoCor,
    String? veiculoPlaca,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AutorizadoInquilino(
      id: id ?? this.id,
      unidadeId: unidadeId ?? this.unidadeId,
      inquilinoId: inquilinoId ?? this.inquilinoId,
      proprietarioId: proprietarioId ?? this.proprietarioId,
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      parentesco: parentesco ?? this.parentesco,
      horarioInicio: horarioInicio ?? this.horarioInicio,
      horarioFim: horarioFim ?? this.horarioFim,
      diasSemanaPermitidos: diasSemanaPermitidos ?? this.diasSemanaPermitidos,
      veiculoMarca: veiculoMarca ?? this.veiculoMarca,
      veiculoModelo: veiculoModelo ?? this.veiculoModelo,
      veiculoCor: veiculoCor ?? this.veiculoCor,
      veiculoPlaca: veiculoPlaca ?? this.veiculoPlaca,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Retorna uma representação em string do autorizado
  @override
  String toString() {
    return 'AutorizadoInquilino{id: $id, nome: $nome, cpf: $cpf, parentesco: $parentesco, ativo: $ativo}';
  }

  /// Verifica se dois autorizados são iguais
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutorizadoInquilino &&
        other.id == id &&
        other.unidadeId == unidadeId &&
        other.inquilinoId == inquilinoId &&
        other.proprietarioId == proprietarioId &&
        other.nome == nome &&
        other.cpf == cpf;
  }

  /// Retorna o hash code do autorizado
  @override
  int get hashCode {
    return Object.hash(
      id,
      unidadeId,
      inquilinoId,
      proprietarioId,
      nome,
      cpf,
    );
  }

  /// Retorna os dias da semana formatados como string
  String get diasSemanaFormatados {
    if (diasSemanaPermitidos == null || diasSemanaPermitidos!.isEmpty) {
      return 'Todos os dias';
    }
    
    const diasNomes = [
      'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'
    ];
    
    return diasSemanaPermitidos!
        .map((dia) => diasNomes[dia])
        .join(', ');
  }

  /// Retorna o horário formatado
  String get horarioFormatado {
    if (horarioInicio == null && horarioFim == null) {
      return 'Sem restrição';
    }
    
    if (horarioInicio != null && horarioFim != null) {
      return '$horarioInicio às $horarioFim';
    }
    
    if (horarioInicio != null) {
      return 'A partir das $horarioInicio';
    }
    
    return 'Até às $horarioFim';
  }

  /// Verifica se o autorizado tem veículo cadastrado
  bool get temVeiculo {
    return veiculoMarca != null || 
           veiculoModelo != null || 
           veiculoCor != null || 
           veiculoPlaca != null;
  }

  /// Retorna as informações do veículo formatadas
  String get veiculoFormatado {
    if (!temVeiculo) return 'Sem veículo';
    
    List<String> partes = [];
    
    if (veiculoMarca != null) partes.add(veiculoMarca!);
    if (veiculoModelo != null) partes.add(veiculoModelo!);
    if (veiculoCor != null) partes.add('(${veiculoCor!})');
    if (veiculoPlaca != null) partes.add('- ${veiculoPlaca!}');
    
    return partes.join(' ');
  }
}