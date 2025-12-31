import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/instituicao_financeira_model.dart';
import '../models/plano_assinatura_model.dart';
import '../models/tipo_pagamento_model.dart';
import '../services/gateway_pagamento_service.dart';
import 'gateway_pagamento_state.dart';

class GatewayPagamentoCubit extends Cubit<GatewayPagamentoState> {
  final GatewayPagamentoService _service;

  GatewayPagamentoCubit(this._service)
      : super(const GatewayPagamentoInitial());

  // Estados do formulário
  String _token = '';
  InstituicaoFinanceiraModel? _instituicaoSelecionada;
  PlanoAssinaturaModel? _planoSelecionado;
  TipoPagamentoModel? _tipoPagamentoSelecionado;

  // Getters
  String get token => _token;
  InstituicaoFinanceiraModel? get instituicaoSelecionada =>
      _instituicaoSelecionada;
  PlanoAssinaturaModel? get planoSelecionado => _planoSelecionado;
  TipoPagamentoModel? get tipoPagamentoSelecionado => _tipoPagamentoSelecionado;

  /// Valida se o formulário está completo
  bool _validarFormulario() {
    return _token.isNotEmpty &&
        _instituicaoSelecionada != null &&
        _planoSelecionado != null &&
        _tipoPagamentoSelecionado != null;
  }

  /// Atualiza o token
  void atualizarToken(String token) {
    _token = token;
    _emitirFormularioAtualizado();
  }

  /// Atualiza a instituição selecionada
  void atualizarInstituicaoSelecionada(
      InstituicaoFinanceiraModel? instituicao) {
    _instituicaoSelecionada = instituicao;
    _emitirFormularioAtualizado();
  }

  /// Atualiza o plano selecionado
  void atualizarPlanoSelecionado(PlanoAssinaturaModel? plano) {
    _planoSelecionado = plano;
    _emitirFormularioAtualizado();
  }

  /// Atualiza o tipo de pagamento selecionado
  void atualizarTipoPagamentoSelecionado(TipoPagamentoModel? tipoPagamento) {
    _tipoPagamentoSelecionado = tipoPagamento;
    _emitirFormularioAtualizado();
  }

  /// Emite o estado do formulário atualizado
  void _emitirFormularioAtualizado() {
    emit(GatewayPagamentoFormularioAtualizado(
      token: _token,
      instituicaoSelecionada: _instituicaoSelecionada,
      planoSelecionado: _planoSelecionado,
      tipoPagamentoSelecionado: _tipoPagamentoSelecionado,
      formularioValido: _validarFormulario(),
    ));
  }

  /// Salva a configuração
  Future<void> salvarConfiguracao() async {
    // Validar
    if (!_validarFormulario()) {
      emit(const GatewayPagamentoErro(
          mensagem: 'Por favor, preencha todos os campos'));
      return;
    }

    // Carregando
    emit(const GatewayPagamentoLoading());

    try {
      final sucesso = await _service.salvarConfiguracao(
        instituicao: _instituicaoSelecionada!,
        plano: _planoSelecionado!,
        tipoPagamento: _tipoPagamentoSelecionado!,
        token: _token,
      );

      if (sucesso) {
        emit(const GatewayPagamentoSalva(
            mensagem: 'Configuração salva com sucesso!'));
        _limparFormulario();
      } else {
        emit(const GatewayPagamentoErro(
            mensagem: 'Erro ao salvar configuração'));
      }
    } catch (e) {
      emit(GatewayPagamentoErro(
          mensagem: 'Erro ao salvar configuração: $e'));
    }
  }

  /// Limpa o formulário
  void _limparFormulario() {
    _token = '';
    _instituicaoSelecionada = null;
    _planoSelecionado = null;
    _tipoPagamentoSelecionado = null;
  }

  /// Reseta para o estado inicial
  void resetar() {
    _limparFormulario();
    emit(const GatewayPagamentoInitial());
  }
}
