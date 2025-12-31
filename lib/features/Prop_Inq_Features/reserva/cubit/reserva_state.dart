import 'package:equatable/equatable.dart';
import '../models/reserva_model.dart';
import '../models/ambiente_model.dart';

/// Estado abstrato para Reservas
abstract class ReservaState extends Equatable {
  const ReservaState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ReservaInitial extends ReservaState {
  const ReservaInitial();
}

/// Estado de carregamento
class ReservaLoading extends ReservaState {
  const ReservaLoading();
}

/// Estado com lista de reservas carregadas
class ReservaCarregada extends ReservaState {
  final List<ReservaModel> reservas;
  final List<AmbienteModel> ambientes;

  const ReservaCarregada({
    required this.reservas,
    required this.ambientes,
  });

  @override
  List<Object?> get props => [reservas, ambientes];
}

/// Estado de reserva criada com sucesso
class ReservaCriada extends ReservaState {
  final ReservaModel reserva;
  final String mensagem;

  const ReservaCriada({
    required this.reserva,
    required this.mensagem,
  });

  @override
  List<Object?> get props => [reserva, mensagem];
}

/// Estado de reserva cancelada com sucesso
class ReservaCancelada extends ReservaState {
  final String reservaId;
  final String mensagem;

  const ReservaCancelada({
    required this.reservaId,
    required this.mensagem,
  });

  @override
  List<Object?> get props => [reservaId, mensagem];
}

/// Estado de erro
class ReservaErro extends ReservaState {
  final String mensagem;

  const ReservaErro({required this.mensagem});

  @override
  List<Object?> get props => [mensagem];
}

/// Estado do formulário atualizado
class ReservaFormularioAtualizado extends ReservaState {
  final String descricao;
  final AmbienteModel? ambienteSelecionado;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final bool formularioValido;

  const ReservaFormularioAtualizado({
    required this.descricao,
    required this.ambienteSelecionado,
    required this.dataInicio,
    required this.dataFim,
    required this.formularioValido,
  });

  @override
  List<Object?> get props => [
    descricao,
    ambienteSelecionado,
    dataInicio,
    dataFim,
    formularioValido,
  ];
}
