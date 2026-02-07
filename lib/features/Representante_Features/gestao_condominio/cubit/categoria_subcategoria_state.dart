import '../models/categoria_financeira_model.dart';

enum CategoriaSubcategoriaStatus { initial, loading, success, error }

class CategoriaSubcategoriaState {
  final CategoriaSubcategoriaStatus status;
  final List<CategoriaFinanceira> categorias;
  final String? errorMessage;

  const CategoriaSubcategoriaState({
    this.status = CategoriaSubcategoriaStatus.initial,
    this.categorias = const [],
    this.errorMessage,
  });

  CategoriaSubcategoriaState copyWith({
    CategoriaSubcategoriaStatus? status,
    List<CategoriaFinanceira>? categorias,
    String? errorMessage,
  }) {
    return CategoriaSubcategoriaState(
      status: status ?? this.status,
      categorias: categorias ?? this.categorias,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
