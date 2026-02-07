import 'package:equatable/equatable.dart';
import '../models/leitura_model.dart';
import '../models/leitura_configuracao_model.dart';

enum LeituraStatus { initial, loading, success, error }

class LeituraState extends Equatable {
  final LeituraStatus status;
  final List<LeituraModel> leituras;
  final String selectedTipo;
  final DateTime selectedDate;
  final LeituraConfiguracaoModel? configuracao;
  final String? errorMessage;

  final String? selectedUnidadeId;
  final String unidadePesquisa;

  double get totalValor => leituras.fold(0, (sum, item) => sum + item.valor);
  int get totalQuantity =>
      leituras.where((l) => l.leituraAtual > 0 || l.id.isNotEmpty).length;

  const LeituraState({
    this.status = LeituraStatus.initial,
    this.leituras = const [],
    this.selectedTipo = 'Agua',
    required this.selectedDate,
    this.configuracao,
    this.errorMessage,
    this.selectedUnidadeId,
    this.unidadePesquisa = '',
  });

  LeituraState copyWith({
    LeituraStatus? status,
    List<LeituraModel>? leituras,
    String? selectedTipo,
    DateTime? selectedDate,
    LeituraConfiguracaoModel? configuracao,
    String? errorMessage,
    String? selectedUnidadeId,
    String? unidadePesquisa,
  }) {
    return LeituraState(
      status: status ?? this.status,
      leituras: leituras ?? this.leituras,
      selectedTipo: selectedTipo ?? this.selectedTipo,
      selectedDate: selectedDate ?? this.selectedDate,
      configuracao: configuracao ?? this.configuracao,
      errorMessage: errorMessage,
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
        configuracao,
        errorMessage,
        selectedUnidadeId,
        unidadePesquisa,
      ];
}
