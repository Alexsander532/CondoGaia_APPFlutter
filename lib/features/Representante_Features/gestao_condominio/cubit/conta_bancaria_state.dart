import 'package:equatable/equatable.dart';
import '../models/conta_bancaria_model.dart';

enum ContaBancariaStatus { initial, loading, success, error }

class ContaBancariaState extends Equatable {
  final ContaBancariaStatus status;
  final List<ContaBancaria> contas;
  final String? errorMessage;

  const ContaBancariaState({
    this.status = ContaBancariaStatus.initial,
    this.contas = const [],
    this.errorMessage,
  });

  ContaBancariaState copyWith({
    ContaBancariaStatus? status,
    List<ContaBancaria>? contas,
    String? errorMessage,
  }) {
    return ContaBancariaState(
      status: status ?? this.status,
      contas: contas ?? this.contas,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, contas, errorMessage];
}
