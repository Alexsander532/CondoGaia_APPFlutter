// =====================================================
// MODELO: Encomenda
// DESCRIÇÃO: Modelo para dados de encomendas recebidas pela portaria
// RELACIONAMENTOS: N:1 com condominios, representantes, unidades
//                  N:1 com proprietarios OU inquilinos (exclusivo)
// AUTOR: Sistema CondoGaia
// DATA: 2024-01-15
// =====================================================

class Encomenda {
  // =====================================================
  // CAMPOS DE IDENTIFICAÇÃO
  // =====================================================

  /// Identificador único da encomenda (UUID)
  final String id;

  /// ID do condomínio onde a encomenda foi recebida
  final String condominioId;

  /// ID do representante que cadastrou a encomenda
  final String representanteId;

  /// ID da unidade destinatária da encomenda
  final String unidadeId;

  // =====================================================
  // PESSOA SELECIONADA (EXCLUSIVO)
  // =====================================================

  /// ID do proprietário destinatário (exclusivo com inquilinoId)
  /// Apenas um dos dois pode estar preenchido
  final String? proprietarioId;

  /// ID do inquilino destinatário (exclusivo com proprietarioId)
  /// Apenas um dos dois pode estar preenchido
  final String? inquilinoId;

  // =====================================================
  // INFORMAÇÕES DA ENCOMENDA
  // =====================================================

  /// URL da foto da encomenda armazenada no Supabase Storage
  /// Pode ser null se não foi anexada foto
  final String? fotoUrl;

  /// Indica se deve notificar a unidade sobre o recebimento da encomenda
  /// Controlado pelo checkbox na interface
  final bool notificarUnidade;

  // =====================================================
  // STATUS E CONTROLE
  // =====================================================

  /// Indica se a encomenda foi retirada pelo destinatário
  /// false = Pendente de retirada
  /// true = Já foi retirada
  final bool recebido;

  /// Nome da pessoa que recebeu a encomenda
  /// Preenchido quando a encomenda é marcada como recebida
  final String? recebidoPor;

  /// Data e hora em que a encomenda foi cadastrada no sistema
  /// Automaticamente preenchida no horário de Brasília
  final DateTime dataCadastro;

  /// Data e hora em que a encomenda foi marcada como recebida/retirada
  /// Null enquanto estiver pendente de retirada
  final DateTime? dataRecebimento;

  // =====================================================
  // CAMPOS DE CONTROLE DO SISTEMA
  // =====================================================

  /// Indica se o registro está ativo no sistema (soft delete)
  final bool ativo;

  /// Data de criação do registro no banco de dados
  final DateTime createdAt;

  /// Data da última atualização do registro
  final DateTime updatedAt;

  // =====================================================
  // CONSTRUTOR PRINCIPAL
  // =====================================================

  Encomenda({
    required this.id,
    required this.condominioId,
    required this.representanteId,
    required this.unidadeId,
    this.proprietarioId,
    this.inquilinoId,
    this.fotoUrl,
    this.notificarUnidade = false,
    this.recebido = false,
    this.recebidoPor,
    required this.dataCadastro,
    this.dataRecebimento,
    this.ativo = true,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(
         // Validação: deve ter OU proprietário OU inquilino (não ambos, não nenhum)
         (proprietarioId != null && inquilinoId == null) ||
             (proprietarioId == null && inquilinoId != null),
         'Deve ter exatamente um destinatário: proprietário OU inquilino',
       );

  // =====================================================
  // CONSTRUTOR PARA NOVA ENCOMENDA
  // =====================================================

  /// Construtor para criar uma nova encomenda
  /// Automaticamente define valores padrão e timestamps atuais
  Encomenda.nova({
    required this.condominioId,
    required this.representanteId,
    required this.unidadeId,
    this.proprietarioId,
    this.inquilinoId,
    this.fotoUrl,
    this.notificarUnidade = false,
  }) : assert(
         // Validação: deve ter OU proprietário OU inquilino (não ambos, não nenhum)
         (proprietarioId != null && inquilinoId == null) ||
             (proprietarioId == null && inquilinoId != null),
         'Deve ter exatamente um destinatário: proprietário OU inquilino',
       ),
       id = '', // Será gerado pelo banco
       recebido = false,
       recebidoPor = null,
       dataCadastro = DateTime.now(),
       dataRecebimento = null,
       ativo = true,
       createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  // =====================================================
  // CONVERSÃO DE/PARA JSON
  // =====================================================

  /// Converte dados JSON do banco para objeto Encomenda
  factory Encomenda.fromJson(Map<String, dynamic> json) {
    return Encomenda(
      id: json['id'] ?? '',
      condominioId: json['condominio_id'] ?? '',
      representanteId: json['representante_id'] ?? '',
      unidadeId: json['unidade_id'] ?? '',
      proprietarioId: json['proprietario_id'],
      inquilinoId: json['inquilino_id'],
      fotoUrl: json['foto_url'],
      notificarUnidade: json['notificar_unidade'] ?? false,
      recebido: json['recebido'] ?? false,
      recebidoPor: json['recebido_por'],
      dataCadastro: DateTime.parse(
        json['data_cadastro'] ?? DateTime.now().toIso8601String(),
      ),
      dataRecebimento: json['data_recebimento'] != null
          ? DateTime.parse(json['data_recebimento'])
          : null,
      ativo: json['ativo'] ?? true,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Converte objeto Encomenda para JSON para envio ao banco
  Map<String, dynamic> toJson() {
    return {
      'id': id.isEmpty ? null : id, // Null para novas encomendas
      'condominio_id': condominioId,
      'representante_id': representanteId,
      'unidade_id': unidadeId,
      'proprietario_id': proprietarioId,
      'inquilino_id': inquilinoId,
      'foto_url': fotoUrl,
      'notificar_unidade': notificarUnidade,
      'recebido': recebido,
      'recebido_por': recebidoPor,
      'data_cadastro': dataCadastro.toIso8601String(),
      'data_recebimento': dataRecebimento?.toIso8601String(),
      'ativo': ativo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // =====================================================
  // MÉTODOS AUXILIARES
  // =====================================================

  /// Retorna true se a encomenda tem um proprietário como destinatário
  bool get temProprietario => proprietarioId != null;

  /// Retorna true se a encomenda tem um inquilino como destinatário
  bool get temInquilino => inquilinoId != null;

  /// Retorna o ID do destinatário (proprietário ou inquilino)
  String get destinatarioId => proprietarioId ?? inquilinoId ?? '';

  /// Retorna o tipo do destinatário ('proprietario' ou 'inquilino')
  String get tipoDestinatario => temProprietario ? 'proprietario' : 'inquilino';

  /// Retorna true se a encomenda tem foto anexada
  bool get temFoto => fotoUrl != null && fotoUrl!.isNotEmpty;

  /// Retorna true se a encomenda está pendente de retirada
  bool get pendente => !recebido;

  /// Retorna uma descrição do status da encomenda
  String get statusDescricao {
    if (recebido) {
      return 'Retirada';
    } else {
      return 'Pendente de Retirada';
    }
  }

  // =====================================================
  // MÉTODOS DE CÓPIA E ATUALIZAÇÃO
  // =====================================================

  /// Cria uma cópia da encomenda com campos atualizados
  Encomenda copyWith({
    String? id,
    String? condominioId,
    String? representanteId,
    String? unidadeId,
    String? proprietarioId,
    String? inquilinoId,
    String? fotoUrl,
    bool? notificarUnidade,
    bool? recebido,
    String? recebidoPor,
    DateTime? dataCadastro,
    DateTime? dataRecebimento,
    bool? ativo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Encomenda(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      representanteId: representanteId ?? this.representanteId,
      unidadeId: unidadeId ?? this.unidadeId,
      proprietarioId: proprietarioId ?? this.proprietarioId,
      inquilinoId: inquilinoId ?? this.inquilinoId,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      notificarUnidade: notificarUnidade ?? this.notificarUnidade,
      recebido: recebido ?? this.recebido,
      recebidoPor: recebidoPor ?? this.recebidoPor,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      dataRecebimento: dataRecebimento ?? this.dataRecebimento,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Marca a encomenda como recebida/retirada
  Encomenda marcarComoRecebida({String? recebidoPor}) {
    return copyWith(
      recebido: true,
      recebidoPor: recebidoPor,
      dataRecebimento: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Marca a encomenda como não recebida (desfazer retirada)
  Encomenda marcarComoPendente() {
    return copyWith(
      recebido: false,
      recebidoPor: null,
      dataRecebimento: null,
      updatedAt: DateTime.now(),
    );
  }

  // =====================================================
  // OVERRIDE DE MÉTODOS PADRÃO
  // =====================================================

  @override
  String toString() {
    return 'Encomenda{id: $id, unidadeId: $unidadeId, '
        'destinatario: $tipoDestinatario($destinatarioId), '
        'status: $statusDescricao, dataCadastro: $dataCadastro}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Encomenda && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
