import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/reserva_entity.dart';
import '../../domain/entities/ambiente_entity.dart';
import '../../domain/usecases/reserva_usecases.dart';
import 'reserva_state.dart';

class ReservaCubit extends Cubit<ReservaState> {
  final ObterReservasUseCase obterReservasUseCase;
  final CriarReservaUseCase criarReservaUseCase;
  final CancelarReservaUseCase cancelarReservaUseCase;
  final ValidarDisponibilidadeUseCase validarDisponibilidadeUseCase;

  ReservaCubit({
    required this.obterReservasUseCase,
    required this.criarReservaUseCase,
    required this.cancelarReservaUseCase,
    required this.validarDisponibilidadeUseCase,
  }) : super(const ReservaInitial());

  // Estados do formulário
  String _descricao = '';
  AmbienteEntity? _ambienteSelecionado;
  DateTime? _dataInicio;
  DateTime? _dataFim;
  List<ReservaEntity> _reservas = [];
  List<AmbienteEntity> _ambientes = [];

  // Getters
  String get descricao => _descricao;
  AmbienteEntity? get ambienteSelecionado => _ambienteSelecionado;
  DateTime? get dataInicio => _dataInicio;
  DateTime? get dataFim => _dataFim;
  List<ReservaEntity> get reservas => _reservas;
  List<AmbienteEntity> get ambientes => _ambientes;

  /// Carrega as reservas
  Future<void> carregarReservas(String condominioId) async {
    emit(const ReservaLoading());

    try {
      final reservas = await obterReservasUseCase(condominioId);
      _reservas = reservas;

      emit(ReservaCarregada(
        reservas: reservas,
        ambientes: _ambientes,
      ));
    } catch (e) {
      emit(ReservaErro(mensagem: 'Erro ao carregar reservas: $e'));
    }
  }

  /// Valida se o formulário está completo
  bool _validarFormulario() {
    return _descricao.isNotEmpty &&
        _ambienteSelecionado != null &&
        _dataInicio != null &&
        _dataFim != null &&
        _dataFim!.isAfter(_dataInicio!);
  }

  /// Atualiza a descrição
  void atualizarDescricao(String descricao) {
    _descricao = descricao;
    _emitirFormularioAtualizado();
  }

  /// Atualiza o ambiente selecionado
  void atualizarAmbienteSelecionado(AmbienteEntity? ambiente) {
    _ambienteSelecionado = ambiente;
    _emitirFormularioAtualizado();
  }

  /// Atualiza a data de início
  void atualizarDataInicio(DateTime? data) {
    _dataInicio = data;
    _emitirFormularioAtualizado();
  }

  /// Atualiza a data de fim
  void atualizarDataFim(DateTime? data) {
    _dataFim = data;
    _emitirFormularioAtualizado();
  }

  /// Emite o estado do formulário atualizado
  void _emitirFormularioAtualizado() {
    emit(ReservaFormularioAtualizado(
      descricao: _descricao,
      ambienteSelecionado: _ambienteSelecionado,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
      formularioValido: _validarFormulario(),
    ));
  }

  /// Cria uma nova reserva
  Future<void> criarReserva({
    required String condominioId,
    required String usuarioId,
  }) async {
    // Validar
    if (!_validarFormulario()) {
      emit(const ReservaErro(
          mensagem: 'Por favor, preencha todos os campos'));
      return;
    }

    // Validar disponibilidade
    try {
      final disponivel = await validarDisponibilidadeUseCase(
        condominioId: condominioId,
        ambienteId: _ambienteSelecionado!.id,
        dataInicio: _dataInicio!,
        dataFim: _dataFim!,
      );

      if (!disponivel) {
        emit(const ReservaErro(
            mensagem: 'Este ambiente não está disponível nesta data'));
        return;
      }
    } catch (e) {
      emit(ReservaErro(mensagem: 'Erro ao validar disponibilidade: $e'));
      return;
    }

    // Carregando
    emit(const ReservaLoading());

    try {
      final reserva = await criarReservaUseCase(
        condominioId: condominioId,
        ambienteId: _ambienteSelecionado!.id,
        usuarioId: usuarioId,
        descricao: _descricao,
        dataInicio: _dataInicio!,
        dataFim: _dataFim!,
      );

      _reservas.add(reserva);
      emit(ReservaCriada(
        reserva: reserva,
        mensagem: 'Reserva criada com sucesso!',
      ));
      _limparFormulario();
    } catch (e) {
      emit(ReservaErro(mensagem: 'Erro ao criar reserva: $e'));
    }
  }

  /// Cancela uma reserva
  Future<void> cancelarReserva(String reservaId) async {
    emit(const ReservaLoading());

    try {
      await cancelarReservaUseCase(reservaId);

      _reservas.removeWhere((r) => r.id == reservaId);
      emit(ReservaCancelada(
        reservaId: reservaId,
        mensagem: 'Reserva cancelada com sucesso!',
      ));
    } catch (e) {
      emit(ReservaErro(mensagem: 'Erro ao cancelar reserva: $e'));
    }
  }

  /// Limpa o formulário
  void _limparFormulario() {
    _descricao = '';
    _ambienteSelecionado = null;
    _dataInicio = null;
    _dataFim = null;
  }

  /// Reseta para o estado inicial
  void resetar() {
    _limparFormulario();
    emit(const ReservaInitial());
  }
}
