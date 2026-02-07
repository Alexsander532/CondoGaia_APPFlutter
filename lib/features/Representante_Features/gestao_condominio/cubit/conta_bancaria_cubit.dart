import 'package:bloc/bloc.dart';
import '../models/conta_bancaria_model.dart';
import '../services/gestao_condominio_service.dart';
import 'conta_bancaria_state.dart';

class ContaBancariaCubit extends Cubit<ContaBancariaState> {
  final GestaoCondominioService _service;

  ContaBancariaCubit({required GestaoCondominioService service})
    : _service = service,
      super(const ContaBancariaState());

  Future<void> carregarContas(String condominioId) async {
    emit(state.copyWith(status: ContaBancariaStatus.loading));
    try {
      final contas = await _service.listarContas(condominioId);
      emit(state.copyWith(status: ContaBancariaStatus.success, contas: contas));
    } catch (e) {
      emit(
        state.copyWith(
          status: ContaBancariaStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> adicionarOuEditarConta(ContaBancaria conta) async {
    emit(state.copyWith(status: ContaBancariaStatus.loading));
    try {
      await _service.salvarConta(conta);
      await carregarContas(
        conta.condominioId,
      ); // Recarrega para atualizar a lista
    } catch (e) {
      emit(
        state.copyWith(
          status: ContaBancariaStatus.error,
          errorMessage: 'Erro ao salvar conta.',
        ),
      );
      // Reload to ensure consistent state even on error (optional, but good if optimistic ui fails)
      await carregarContas(conta.condominioId);
    }
  }

  Future<void> definirPrincipal(ContaBancaria conta) async {
    if (conta.id == null) return;
    emit(state.copyWith(status: ContaBancariaStatus.loading));
    try {
      await _service.definirContaPrincipal(conta.id!, conta.condominioId);
      await carregarContas(conta.condominioId);
    } catch (e) {
      emit(
        state.copyWith(
          status: ContaBancariaStatus.error,
          errorMessage: 'Erro ao definir conta principal.',
        ),
      );
      await carregarContas(conta.condominioId);
    }
  }

  Future<void> excluirConta(String id, String condominioId) async {
    emit(state.copyWith(status: ContaBancariaStatus.loading));
    try {
      await _service.excluirConta(id);
      await carregarContas(condominioId);
    } catch (e) {
      // Aqui pegamos a mensagem "Não é possível excluir a conta principal..."
      emit(
        state.copyWith(
          status: ContaBancariaStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
      await carregarContas(condominioId); // Restaura estado
    }
  }
}
