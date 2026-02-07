import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/configuracao_financeira_model.dart';
import '../services/gestao_condominio_service.dart';
import 'configuracao_financeira_state.dart';

class ConfiguracaoFinanceiraCubit extends Cubit<ConfiguracaoFinanceiraState> {
  final GestaoCondominioService _service;

  ConfiguracaoFinanceiraCubit({required GestaoCondominioService service})
    : _service = service,
      super(const ConfiguracaoFinanceiraState());

  Future<void> carregarConfiguracao(String condominioId) async {
    emit(state.copyWith(status: ConfiguracaoFinanceiraStatus.loading));
    try {
      var config = await _service.obterConfiguracaoFinanceira(condominioId);

      // Se não existir, criamos um template local vazio para edição (sem ID)
      config ??= ConfiguracaoFinanceira(condominioId: condominioId);

      emit(
        state.copyWith(
          status: ConfiguracaoFinanceiraStatus.success,
          configuracao: config,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConfiguracaoFinanceiraStatus.error,
          errorMessage: 'Erro ao carregar configurações: $e',
        ),
      );
    }
  }

  Future<void> salvarConfiguracao(ConfiguracaoFinanceira config) async {
    emit(state.copyWith(status: ConfiguracaoFinanceiraStatus.loading));
    try {
      await _service.salvarConfiguracaoFinanceira(config);

      // Recarrega para obter ID gerado se for novo, ou confirmação dos dados
      await carregarConfiguracao(config.condominioId);

      // Emite sucesso novamente para triggers de UI se necessário
      // O carregarConfiguracao já emite success, mas podemos reforçar ou usar listen
    } catch (e) {
      emit(
        state.copyWith(
          status: ConfiguracaoFinanceiraStatus.error,
          errorMessage: 'Erro ao salvar configurações: $e',
        ),
      );
    }
  }
}
