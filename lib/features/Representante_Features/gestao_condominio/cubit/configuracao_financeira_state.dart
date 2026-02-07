import 'package:equatable/equatable.dart';
import '../models/configuracao_financeira_model.dart';

enum ConfiguracaoFinanceiraStatus { initial, loading, success, error }

class ConfiguracaoFinanceiraState extends Equatable {
  final ConfiguracaoFinanceiraStatus status;
  final ConfiguracaoFinanceira? configuracao;
  final String? errorMessage;

  const ConfiguracaoFinanceiraState({
    this.status = ConfiguracaoFinanceiraStatus.initial,
    this.configuracao,
    this.errorMessage,
  });

  ConfiguracaoFinanceiraState copyWith({
    ConfiguracaoFinanceiraStatus? status,
    ConfiguracaoFinanceira? configuracao,
    String? errorMessage,
  }) {
    return ConfiguracaoFinanceiraState(
      status: status ?? this.status,
      configuracao: configuracao ?? this.configuracao,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, configuracao, errorMessage];
}
