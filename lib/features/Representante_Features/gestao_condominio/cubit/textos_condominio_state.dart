import 'package:equatable/equatable.dart';
import '../models/textos_condominio_model.dart';

enum TextosStatus { initial, loading, success, error }

class TextosCondominioState extends Equatable {
  final TextosStatus status;
  final TextosCondominio? textos;
  final String? errorMessage;

  const TextosCondominioState({
    this.status = TextosStatus.initial,
    this.textos,
    this.errorMessage,
  });

  TextosCondominioState copyWith({
    TextosStatus? status,
    TextosCondominio? textos,
    String? errorMessage,
  }) {
    return TextosCondominioState(
      status: status ?? this.status,
      textos: textos ?? this.textos,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, textos, errorMessage];
}
