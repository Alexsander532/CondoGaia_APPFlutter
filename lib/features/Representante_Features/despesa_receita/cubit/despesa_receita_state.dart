import 'package:equatable/equatable.dart';
import '../models/despesa_model.dart';
import '../models/receita_model.dart';
import '../models/transferencia_model.dart';
import '../../gestao_condominio/models/conta_bancaria_model.dart';
import '../../gestao_condominio/models/categoria_financeira_model.dart';
import 'package:image_picker/image_picker.dart';

enum DespesaReceitaStatus { initial, loading, success, error }

class DespesaReceitaState extends Equatable {
  final DespesaReceitaStatus status;
  final List<Despesa> despesas;
  final List<Receita> receitas;
  final List<Transferencia> transferencias;
  final List<ContaBancaria> contas;
  final List<CategoriaFinanceira> categorias;

  // Filtros / seleção
  final int mesSelecionado;
  final int anoSelecionado;
  final String? filtroContaId;
  final String? filtroCategoriaId;
  final String? filtroSubcategoriaId;
  final String? filtroPalavraChave;
  final String? filtroContaContabil;
  final String? filtroContaCreditoId;
  final String? filtroContaDebitoId;
  final String filtroTipoReceita; // Todos, Manual, Automático

  // Seleção separada por aba
  final Set<String> despesasSelecionadas;
  final Set<String> receitasSelecionadas;
  final Set<String> transferenciasSelecionadas;

  // Modo edição
  final Despesa? despesaEditando;
  final Receita? receitaEditando;
  final Transferencia? transferenciaEditando;

  // Resumo financeiro
  final double saldoAnterior;

  // UI state
  final bool cadastroExpandido;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final XFile? imagemArquivo;

  const DespesaReceitaState({
    this.status = DespesaReceitaStatus.initial,
    this.despesas = const [],
    this.receitas = const [],
    this.transferencias = const [],
    this.contas = const [],
    this.categorias = const [],
    this.mesSelecionado = 0,
    this.anoSelecionado = 0,
    this.filtroContaId,
    this.filtroCategoriaId,
    this.filtroSubcategoriaId,
    this.filtroPalavraChave,
    this.filtroContaContabil,
    this.filtroContaCreditoId,
    this.filtroContaDebitoId,
    this.filtroTipoReceita = 'Todos',
    this.despesasSelecionadas = const {},
    this.receitasSelecionadas = const {},
    this.transferenciasSelecionadas = const {},
    this.despesaEditando,
    this.receitaEditando,
    this.transferenciaEditando,
    this.saldoAnterior = 0,
    this.cadastroExpandido = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.imagemArquivo,
  });

  DespesaReceitaState copyWith({
    DespesaReceitaStatus? status,
    List<Despesa>? despesas,
    List<Receita>? receitas,
    List<Transferencia>? transferencias,
    List<ContaBancaria>? contas,
    List<CategoriaFinanceira>? categorias,
    int? mesSelecionado,
    int? anoSelecionado,
    String? filtroContaId,
    String? filtroCategoriaId,
    String? filtroSubcategoriaId,
    String? filtroPalavraChave,
    String? filtroContaContabil,
    String? filtroContaCreditoId,
    String? filtroContaDebitoId,
    String? filtroTipoReceita,
    Set<String>? despesasSelecionadas,
    Set<String>? receitasSelecionadas,
    Set<String>? transferenciasSelecionadas,
    Despesa? despesaEditando,
    bool clearDespesaEditando = false,
    Receita? receitaEditando,
    bool clearReceitaEditando = false,
    Transferencia? transferenciaEditando,
    bool clearTransferenciaEditando = false,
    double? saldoAnterior,
    bool? cadastroExpandido,
    bool? isSaving,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    XFile? imagemArquivo,
    bool clearImagemArquivo = false,
  }) {
    return DespesaReceitaState(
      status: status ?? this.status,
      despesas: despesas ?? this.despesas,
      receitas: receitas ?? this.receitas,
      transferencias: transferencias ?? this.transferencias,
      contas: contas ?? this.contas,
      categorias: categorias ?? this.categorias,
      mesSelecionado: mesSelecionado ?? this.mesSelecionado,
      anoSelecionado: anoSelecionado ?? this.anoSelecionado,
      filtroContaId: filtroContaId ?? this.filtroContaId,
      filtroCategoriaId: filtroCategoriaId ?? this.filtroCategoriaId,
      filtroSubcategoriaId: filtroSubcategoriaId ?? this.filtroSubcategoriaId,
      filtroPalavraChave: filtroPalavraChave ?? this.filtroPalavraChave,
      filtroContaContabil: filtroContaContabil ?? this.filtroContaContabil,
      filtroContaCreditoId: filtroContaCreditoId ?? this.filtroContaCreditoId,
      filtroContaDebitoId: filtroContaDebitoId ?? this.filtroContaDebitoId,
      filtroTipoReceita: filtroTipoReceita ?? this.filtroTipoReceita,
      despesasSelecionadas: despesasSelecionadas ?? this.despesasSelecionadas,
      receitasSelecionadas: receitasSelecionadas ?? this.receitasSelecionadas,
      transferenciasSelecionadas:
          transferenciasSelecionadas ?? this.transferenciasSelecionadas,
      despesaEditando: clearDespesaEditando
          ? null
          : (despesaEditando ?? this.despesaEditando),
      receitaEditando: clearReceitaEditando
          ? null
          : (receitaEditando ?? this.receitaEditando),
      transferenciaEditando: clearTransferenciaEditando
          ? null
          : (transferenciaEditando ?? this.transferenciaEditando),
      saldoAnterior: saldoAnterior ?? this.saldoAnterior,
      cadastroExpandido: cadastroExpandido ?? this.cadastroExpandido,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
      imagemArquivo: clearImagemArquivo
          ? null
          : (imagemArquivo ?? this.imagemArquivo),
    );
  }

  /// Subcategorias filtradas pela categoria selecionada
  List<SubcategoriaFinanceira> get subcategoriasFiltradas {
    if (filtroCategoriaId == null) return [];
    final cat = categorias.where((c) => c.id == filtroCategoriaId).toList();
    if (cat.isEmpty) return [];
    return cat.first.subcategorias;
  }

  /// Categorias do tipo DESPESA
  List<CategoriaFinanceira> get categoriasDespesa =>
      categorias.where((c) => c.tipo.toUpperCase() == 'DESPESA').toList();

  /// Categorias do tipo RECEITA
  List<CategoriaFinanceira> get categoriasReceita =>
      categorias.where((c) => c.tipo.toUpperCase() == 'RECEITA').toList();

  /// Total das despesas
  double get totalDespesas => despesas.fold(0, (sum, d) => sum + d.valor);

  /// Total das receitas
  double get totalReceitas => receitas.fold(0, (sum, r) => sum + r.valor);

  /// Saldo atual calculado
  double get saldoAtual => saldoAnterior + totalReceitas - totalDespesas;

  @override
  List<Object?> get props => [
    status,
    despesas,
    receitas,
    transferencias,
    contas,
    categorias,
    mesSelecionado,
    anoSelecionado,
    filtroContaId,
    filtroCategoriaId,
    filtroSubcategoriaId,
    filtroPalavraChave,
    filtroContaContabil,
    filtroContaCreditoId,
    filtroContaDebitoId,
    filtroTipoReceita,
    despesasSelecionadas,
    receitasSelecionadas,
    transferenciasSelecionadas,
    despesaEditando,
    receitaEditando,
    transferenciaEditando,
    saldoAnterior,
    cadastroExpandido,
    isSaving,
    errorMessage,
    successMessage,
    imagemArquivo,
  ];
}
