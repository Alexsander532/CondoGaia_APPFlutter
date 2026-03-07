import 'package:equatable/equatable.dart';
import '../models/acordo_model.dart';

enum AcordoStatus { initial, loading, loaded, error }

class AcordoState extends Equatable {
  final AcordoStatus status;
  final List<Acordo> acordos;
  final List<ParcelaAcordo> parcelas;
  final List<HistoricoAcordo> historico;
  final String? errorMessage;

  const AcordoState({
    this.status = AcordoStatus.initial,
    this.acordos = const [],
    this.parcelas = const [],
    this.historico = const [],
    this.errorMessage,
  });

  AcordoState copyWith({
    AcordoStatus? status,
    List<Acordo>? acordos,
    List<ParcelaAcordo>? parcelas,
    List<HistoricoAcordo>? historico,
    String? errorMessage,
  }) {
    return AcordoState(
      status: status ?? this.status,
      acordos: acordos ?? this.acordos,
      parcelas: parcelas ?? this.parcelas,
      historico: historico ?? this.historico,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    acordos,
    parcelas,
    historico,
    errorMessage,
  ];
}
