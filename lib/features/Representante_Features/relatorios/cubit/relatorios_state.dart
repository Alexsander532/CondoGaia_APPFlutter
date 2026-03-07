import 'package:equatable/equatable.dart';

enum RelatoriosStatus { initial, loaded }

class RelatoriosState extends Equatable {
  final RelatoriosStatus status;
  final String tipoRelatorio;

  const RelatoriosState({
    this.status = RelatoriosStatus.initial,
    this.tipoRelatorio = 'Boleto',
  });

  RelatoriosState copyWith({RelatoriosStatus? status, String? tipoRelatorio}) {
    return RelatoriosState(
      status: status ?? this.status,
      tipoRelatorio: tipoRelatorio ?? this.tipoRelatorio,
    );
  }

  @override
  List<Object?> get props => [status, tipoRelatorio];
}
