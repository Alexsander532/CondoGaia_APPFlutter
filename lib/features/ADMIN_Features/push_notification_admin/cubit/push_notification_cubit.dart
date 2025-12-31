import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/localizacao_model.dart';
import '../models/condominio_model.dart';
import '../services/push_notification_service.dart';
import 'push_notification_state.dart';

class PushNotificationCubit extends Cubit<PushNotificationState> {
  final PushNotificationService _service;

  PushNotificationCubit(this._service)
      : super(const PushNotificationInitial());

  // Estados do formulário
  String _titulo = '';
  String _mensagem = '';
  bool _sindicosInclusos = false;
  List<CondominioModel> _condominiosSelecionados = [];
  EstadoModel? _estadoSelecionado;
  CidadeModel? _cidadeSelecionada;

  // Getters
  String get titulo => _titulo;
  String get mensagem => _mensagem;
  bool get sindicosInclusos => _sindicosInclusos;
  List<CondominioModel> get condominiosSelecionados =>
      _condominiosSelecionados;
  EstadoModel? get estadoSelecionado => _estadoSelecionado;
  CidadeModel? get cidadeSelecionada => _cidadeSelecionada;

  /// Valida se o formulário está completo
  bool _validarFormulario() {
    return _titulo.isNotEmpty &&
        _mensagem.isNotEmpty &&
        (_sindicosInclusos || _condominiosSelecionados.isNotEmpty);
  }

  /// Atualiza o título
  void atualizarTitulo(String titulo) {
    _titulo = titulo;
    _emitirFormularioAtualizado();
  }

  /// Atualiza a mensagem
  void atualizarMensagem(String mensagem) {
    _mensagem = mensagem;
    _emitirFormularioAtualizado();
  }

  /// Atualiza se síndicos estão inclusos
  void atualizarSindicosInclusos(bool valor) {
    _sindicosInclusos = valor;
    _emitirFormularioAtualizado();
  }

  /// Atualiza os condomínios selecionados
  void atualizarCondominiosSelecionados(
      List<CondominioModel> condominios) {
    _condominiosSelecionados = condominios;
    _emitirFormularioAtualizado();
  }

  /// Atualiza o estado selecionado
  void atualizarEstadoSelecionado(EstadoModel? estado) {
    _estadoSelecionado = estado;
    _emitirFormularioAtualizado();
  }

  /// Atualiza a cidade selecionada
  void atualizarCidadeSelecionada(CidadeModel? cidade) {
    _cidadeSelecionada = cidade;
    _emitirFormularioAtualizado();
  }

  /// Emite o estado do formulário atualizado
  void _emitirFormularioAtualizado() {
    emit(PushNotificationFormularioAtualizado(
      titulo: _titulo,
      mensagem: _mensagem,
      sindicosInclusos: _sindicosInclusos,
      condominiosSelecionados: _condominiosSelecionados,
      estadoSelecionado: _estadoSelecionado,
      cidadeSelecionada: _cidadeSelecionada,
      formularioValido: _validarFormulario(),
    ));
  }

  /// Valida a notificação antes de enviar
  List<String> _validarNotificacao() {
    return _service.validarNotificacao(
      titulo: _titulo,
      mensagem: _mensagem,
      sindicosInclusos: _sindicosInclusos,
      moradoresSelecionados: _condominiosSelecionados,
      estadoSelecionado: _estadoSelecionado,
      cidadeSelecionada: _cidadeSelecionada,
    );
  }

  /// Envia a notificação
  Future<void> enviarNotificacao() async {
    // Validar
    final erros = _validarNotificacao();
    if (erros.isNotEmpty) {
      emit(PushNotificationErro(mensagem: erros.join('\n')));
      return;
    }

    // Carregando
    emit(const PushNotificationLoading());

    try {
      final sucesso = await _service.enviarNotificacao(
        titulo: _titulo,
        mensagem: _mensagem,
        sindicosInclusos: _sindicosInclusos,
        moradoresSelecionados: _condominiosSelecionados,
        estadoSelecionado: _estadoSelecionado,
        cidadeSelecionada: _cidadeSelecionada,
      );

      if (sucesso) {
        emit(const PushNotificationEnviada());
        _limparFormulario();
      } else {
        emit(const PushNotificationErro(
            mensagem: 'Erro ao enviar notificação'));
      }
    } catch (e) {
      emit(PushNotificationErro(
          mensagem: 'Erro ao enviar notificação: $e'));
    }
  }

  /// Limpa o formulário
  void _limparFormulario() {
    _titulo = '';
    _mensagem = '';
    _sindicosInclusos = false;
    _condominiosSelecionados = [];
    _estadoSelecionado = null;
    _cidadeSelecionada = null;
  }

  /// Reseta para o estado inicial
  void resetar() {
    _limparFormulario();
    emit(const PushNotificationInitial());
  }
}
