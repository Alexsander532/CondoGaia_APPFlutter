import 'package:equatable/equatable.dart';
import '../models/leitura_model.dart';

enum LeituraStatus { initial, loading, success, error }

class LeituraState extends Equatable {
  final LeituraStatus status;
  final List<LeituraModel> leituras; // Merged list (Units + Readings)
  final String selectedTipo; // 'Agua' or 'Gas'
  final DateTime selectedDate;
  final double taxaPorUnidade;
  final String? errorMessage;

  // Form fields state
  final String? selectedUnidadeId;
  final String unidadePesquisa;

  // Computed totals
  double get totalValor => leituras.fold(0, (sum, item) => sum + item.valor);
  int get totalQuantity =>
      leituras.where((l) => l.leituraAtual > 0 || l.id.isNotEmpty).length;

  const LeituraState({
    this.status = LeituraStatus.initial,
    this.leituras = const [],
    this.selectedTipo = 'Agua',
    required this.selectedDate,
    this.taxaPorUnidade = 0.0,
    this.errorMessage,
    this.selectedUnidadeId,
    this.unidadePesquisa = '',
  });

  LeituraState copyWith({
    LeituraStatus? status,
    List<LeituraModel>? leituras,
    String? selectedTipo,
    DateTime? selectedDate,
    double? taxaPorUnidade,
    String? errorMessage,
    String? selectedUnidadeId,
    String? unidadePesquisa,
  }) {
    return LeituraState(
      status: status ?? this.status,
      leituras: leituras ?? this.leituras,
      selectedTipo: selectedTipo ?? this.selectedTipo,
      selectedDate: selectedDate ?? this.selectedDate,
      taxaPorUnidade: taxaPorUnidade ?? this.taxaPorUnidade,
      errorMessage:
          errorMessage, // Reset error on copy usually, or explicit pass
      selectedUnidadeId: selectedUnidadeId ?? this.selectedUnidadeId,
      unidadePesquisa: unidadePesquisa ?? this.unidadePesquisa,
    );
  }

  @override
  List<Object?> get props => [
    status,
    leituras,
    selectedTipo,
    selectedDate,
    taxaPorUnidade,
    errorMessage,
    selectedUnidadeId,
    unidadePesquisa,
  ];
}
