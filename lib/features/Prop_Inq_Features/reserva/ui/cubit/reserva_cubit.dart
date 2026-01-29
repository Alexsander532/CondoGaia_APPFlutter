import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/reserva_entity.dart';
import '../../domain/entities/ambiente_entity.dart';
import '../../domain/usecases/reserva_usecases.dart';
import 'reserva_state.dart';

class ReservaCubit extends Cubit<ReservaState> {
  final ObterReservasUseCase obterReservasUseCase;
  final ObterAmbientesUseCase obterAmbientesUseCase;
  final CriarReservaUseCase criarReservaUseCase;
  final CancelarReservaUseCase cancelarReservaUseCase;
  final ValidarDisponibilidadeUseCase validarDisponibilidadeUseCase;
  final AtualizarReservaUseCase atualizarReservaUseCase;

  ReservaCubit({
    required this.obterReservasUseCase,
    required this.obterAmbientesUseCase,
    required this.criarReservaUseCase,
    required this.cancelarReservaUseCase,
    required this.validarDisponibilidadeUseCase,
    required this.atualizarReservaUseCase,
  }) : super(const ReservaInitial());

  @override
  Future<void> close() {
    return super.close();
  }

  /// Inicializa o calendário
  void inicializarCalendario() {
    _today = DateTime.now();
    _dataSelecionada = _today;
    _mesAtual = _today.month - 1;
    _anoAtual = _today.year;
  }

  // Estados do formulário
  String _descricao = '';
  AmbienteEntity? _ambienteSelecionado;
  DateTime? _dataInicio;
  DateTime? _dataFim;
  List<ReservaEntity> _reservas = [];
  List<AmbienteEntity> _ambientes = [];

  // Calendário
  late DateTime _today;
  late DateTime _dataSelecionada;
  late int _mesAtual;
  late int _anoAtual;

  // Getters
  String get descricao => _descricao;
  AmbienteEntity? get ambienteSelecionado => _ambienteSelecionado;
  DateTime? get dataInicio => _dataInicio;
  DateTime? get dataFim => _dataFim;
  List<ReservaEntity> get reservas => _reservas;
  List<AmbienteEntity> get ambientes => _ambientes;

  // Getters Calendário
  DateTime get dataSelecionada => _dataSelecionada;
  int get mesAtual => _mesAtual;
  int get anoAtual => _anoAtual;
  DateTime get today => _today;

  // Reservas do dia selecionado
  List<ReservaEntity> get reservasDoDia {
    return _reservas.where((r) {
      return r.dataReserva.day == _dataSelecionada.day &&
          r.dataReserva.month == _dataSelecionada.month &&
          r.dataReserva.year == _dataSelecionada.year;
    }).toList();
  }

  /// Carrega os ambientes do Supabase
  Future<void> carregarAmbientes() async {
    emit(const ReservaLoading());

    try {
      final ambientes = await obterAmbientesUseCase();
      _ambientes = ambientes;

      emit(ReservaCarregada(reservas: _reservas, ambientes: ambientes));
    } catch (e) {
      print('❌ Erro ao carregar ambientes: $e');
      emit(ReservaErro(mensagem: 'Erro ao carregar ambientes: $e'));
    }
  }

  /// Carrega as reservas
  Future<void> carregarReservas(String condominioId) async {
    emit(const ReservaLoading());

    try {
      final reservas = await obterReservasUseCase(condominioId);
      _reservas = reservas;

      emit(ReservaCarregada(reservas: reservas, ambientes: _ambientes));
    } catch (e) {
      emit(ReservaErro(mensagem: 'Erro ao carregar reservas: $e'));
    }
  }

  /// Valida se o formulário está completo
  bool _validarFormulario() {
    return _ambienteSelecionado != null &&
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
    emit(
      ReservaFormularioAtualizado(
        descricao: _descricao,
        ambienteSelecionado: _ambienteSelecionado,
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        formularioValido: _validarFormulario(),
      ),
    );
  }

  /// Cria uma nova reserva
  Future<void> criarReserva({
    required String condominioId,
    required String usuarioId,
    required bool termoLocacaoAceito,
    bool isInquilino = true,
    bool isProprietario = false,
  }) async {
    // Validar Campos Obrigatórios da UI
    if (_ambienteSelecionado == null) {
      emit(const ReservaErro(mensagem: 'Selecione um ambiente'));
      return;
    }

    if (!termoLocacaoAceito) {
      emit(
        const ReservaErro(
          mensagem: 'É necessário aceitar os termos de locação',
        ),
      );
      return;
    }

    if (!_validarFormulario()) {
      emit(
        const ReservaErro(
          mensagem: 'Por favor, preencha todos os campos obrigatórios',
        ),
      );
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
        emit(
          const ReservaErro(
            mensagem: 'Este ambiente não está disponível nesta data',
          ),
        );
        return;
      }
    } catch (e) {
      // Se der erro na validação, vamos tentar criar mesmo assim ou abordar diferente?
      // Vamos manter o fluxo de erro por segurança.
      emit(ReservaErro(mensagem: 'Erro ao validar disponibilidade: $e'));
      return;
    }

    // Carregando
    emit(const ReservaLoading());

    try {
      // Definir quem está criando a reserva
      String? inquilinoId;
      String? representanteId;
      String? proprietarioId;

      // Lógica baseada no tipo de usuário (assumindo que o chamador passa o ID correto)
      // Se isInquilino for true, é inquilino.
      // Se for false, pode ser Representante ou Proprietário.
      // Vamos adicionar um parâmetro opcional isProprietario no método

      if (isInquilino) {
        inquilinoId = usuarioId;
      } else if (isProprietario) {
        proprietarioId = usuarioId;
      } else {
        representanteId = usuarioId;
      }

      // Define o "local" como a descrição (se houver) ou o nome do ambiente
      final localDefinido = _descricao.isNotEmpty
          ? _descricao
          : 'Reserva de ${_ambienteSelecionado!.nome}';

      final reserva = await criarReservaUseCase(
        condominioId: condominioId,
        ambienteId: _ambienteSelecionado!.id,
        inquilinoId: inquilinoId,
        representanteId: representanteId,
        proprietarioId: proprietarioId,
        local: localDefinido,
        dataInicio: _dataInicio!,
        dataFim: _dataFim!,
        valorLocacao: _ambienteSelecionado!.valor,
        termoLocacao: termoLocacaoAceito,
      );

      _reservas.add(reserva);
      emit(
        ReservaCriada(
          reserva: reserva,
          mensagem: 'Reserva criada com sucesso!',
        ),
      );
      _limparFormulario();
    } catch (e) {
      emit(ReservaErro(mensagem: 'Erro ao criar reserva: $e'));
    }
  }

  /// Atualiza uma reserva existente
  Future<void> atualizarReserva({
    required String reservaId,
    required String condominioId,
    required String usuarioId,
  }) async {
    // Validar Campos Obrigatórios da UI
    if (_ambienteSelecionado == null) {
      emit(const ReservaErro(mensagem: 'Selecione um ambiente'));
      return;
    }

    if (!_validarFormulario()) {
      emit(
        const ReservaErro(
          mensagem: 'Por favor, preencha todos os campos obrigatórios',
        ),
      );
      return;
    }

    // Carregando
    emit(const ReservaLoading());

    try {
      final localDefinido = _descricao.isNotEmpty
          ? _descricao
          : 'Reserva de ${_ambienteSelecionado!.nome}';

      final reserva = await atualizarReservaUseCase(
        reservaId: reservaId,
        ambienteId: _ambienteSelecionado!.id,
        local: localDefinido,
        dataInicio: _dataInicio!,
        dataFim: _dataFim!,
        valorLocacao: _ambienteSelecionado!.valor,
      );

      // Atualizar na lista local
      final index = _reservas.indexWhere((r) => r.id == reservaId);
      if (index != -1) {
        _reservas[index] = reserva;
      } else {
        // Se por algum motivo não achou, recarrega tudo
        await carregarReservas(condominioId);
      }

      emit(
        ReservaCriada(
          // Reusando estado de sucesso
          reserva: reserva,
          mensagem: 'Reserva atualizada com sucesso!',
        ),
      );
      _limparFormulario();
    } catch (e) {
      emit(ReservaErro(mensagem: 'Erro ao atualizar reserva: $e'));
    }
  }

  /// Cancela uma reserva
  Future<void> cancelarReserva(String reservaId) async {
    emit(const ReservaLoading());

    try {
      await cancelarReservaUseCase(reservaId);

      _reservas.removeWhere((r) => r.id == reservaId);
      emit(
        ReservaCancelada(
          reservaId: reservaId,
          mensagem: 'Reserva cancelada com sucesso!',
        ),
      );
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

  /// Próximo mês no calendário
  void proximoMes() {
    if (_mesAtual == 11) {
      _mesAtual = 0;
      _anoAtual++;
    } else {
      _mesAtual++;
    }
    emit(
      ReservaFormularioAtualizado(
        descricao: _descricao,
        ambienteSelecionado: _ambienteSelecionado,
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        formularioValido: _validarFormulario(),
      ),
    );
  }

  /// Mês anterior no calendário
  void mesPosterior() {
    if (_mesAtual == 0) {
      _mesAtual = 11;
      _anoAtual--;
    } else {
      _mesAtual--;
    }
    emit(
      ReservaFormularioAtualizado(
        descricao: _descricao,
        ambienteSelecionado: _ambienteSelecionado,
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        formularioValido: _validarFormulario(),
      ),
    );
  }

  /// Seleciona um dia no calendário
  void selecionarDia(int dia) {
    _dataSelecionada = DateTime(_anoAtual, _mesAtual + 1, dia);
    emit(
      ReservaFormularioAtualizado(
        descricao: _descricao,
        ambienteSelecionado: _ambienteSelecionado,
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        formularioValido: _validarFormulario(),
      ),
    );
  }
}
