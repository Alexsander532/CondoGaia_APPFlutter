import 'package:equatable/equatable.dart';
import '../models/boleto_model.dart';

enum BoletoStatus { initial, loading, success, error }

class BoletoState extends Equatable {
  final BoletoStatus status;
  final List<Boleto> boletos;
  final List<Map<String, dynamic>> contasBancarias;
  final List<Map<String, dynamic>> unidades;

  // Filtros
  final int mesSelecionado;
  final int anoSelecionado;
  final String tipoEmissao;
  final String situacao;
  final String? dataInicio;
  final String? dataFim;
  final String? nossoNumero;
  final String? pesquisa;
  final String
  filtroRapido; // Todos, Ativo, A vencer, Cancelado, Pago, Cancelado acordo

  // Seleção
  final Set<String> itensSelecionados;

  // UI state
  final bool filtroExpandido;
  final bool detalharComposicao;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const BoletoState({
    this.status = BoletoStatus.initial,
    this.boletos = const [],
    this.contasBancarias = const [],
    this.unidades = const [],
    this.mesSelecionado = 0,
    this.anoSelecionado = 0,
    this.tipoEmissao = 'Todos',
    this.situacao = 'Todos',
    this.dataInicio,
    this.dataFim,
    this.nossoNumero,
    this.pesquisa,
    this.filtroRapido = 'Todos',
    this.itensSelecionados = const {},
    this.filtroExpandido = true,
    this.detalharComposicao = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Total do valor dos boletos selecionados
  double get totalSelecionado {
    return boletos
        .where((b) => itensSelecionados.contains(b.id))
        .fold(0.0, (sum, b) => sum + b.valor);
  }

  /// Quantidade de boletos selecionados
  int get qtdSelecionada => itensSelecionados.length;

  /// Boletos filtrados pelo filtro rápido
  List<Boleto> get boletosFiltrados {
    if (filtroRapido == 'Todos') return boletos;
    if (filtroRapido == 'A vencer') {
      return boletos
          .where(
            (b) =>
                b.status == 'Ativo' &&
                b.dataVencimento != null &&
                b.dataVencimento!.isAfter(DateTime.now()),
          )
          .toList();
    }
    if (filtroRapido == 'Cancelado acordo') {
      return boletos.where((b) => b.status == 'Cancelado por Acordo').toList();
    }
    return boletos.where((b) => b.status == filtroRapido).toList();
  }

  BoletoState copyWith({
    BoletoStatus? status,
    List<Boleto>? boletos,
    List<Map<String, dynamic>>? contasBancarias,
    List<Map<String, dynamic>>? unidades,
    int? mesSelecionado,
    int? anoSelecionado,
    String? tipoEmissao,
    String? situacao,
    String? dataInicio,
    String? dataFim,
    String? nossoNumero,
    String? pesquisa,
    String? filtroRapido,
    Set<String>? itensSelecionados,
    bool? filtroExpandido,
    bool? detalharComposicao,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
  }) {
    return BoletoState(
      status: status ?? this.status,
      boletos: boletos ?? this.boletos,
      contasBancarias: contasBancarias ?? this.contasBancarias,
      unidades: unidades ?? this.unidades,
      mesSelecionado: mesSelecionado ?? this.mesSelecionado,
      anoSelecionado: anoSelecionado ?? this.anoSelecionado,
      tipoEmissao: tipoEmissao ?? this.tipoEmissao,
      situacao: situacao ?? this.situacao,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      nossoNumero: nossoNumero ?? this.nossoNumero,
      pesquisa: pesquisa ?? this.pesquisa,
      filtroRapido: filtroRapido ?? this.filtroRapido,
      itensSelecionados: itensSelecionados ?? this.itensSelecionados,
      filtroExpandido: filtroExpandido ?? this.filtroExpandido,
      detalharComposicao: detalharComposicao ?? this.detalharComposicao,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    boletos,
    contasBancarias,
    unidades,
    mesSelecionado,
    anoSelecionado,
    tipoEmissao,
    situacao,
    dataInicio,
    dataFim,
    nossoNumero,
    pesquisa,
    filtroRapido,
    itensSelecionados,
    filtroExpandido,
    detalharComposicao,
    isSaving,
    errorMessage,
    successMessage,
  ];
}
