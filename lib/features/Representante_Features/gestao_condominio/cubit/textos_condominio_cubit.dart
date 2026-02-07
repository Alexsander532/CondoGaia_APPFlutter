import 'package:bloc/bloc.dart';
import '../models/textos_condominio_model.dart';
import '../services/gestao_condominio_service.dart';
import 'textos_condominio_state.dart';

class TextosCondominioCubit extends Cubit<TextosCondominioState> {
  final GestaoCondominioService _service;

  TextosCondominioCubit({required GestaoCondominioService service})
    : _service = service,
      super(const TextosCondominioState());

  Future<void> carregarTextos(String condominioId) async {
    emit(state.copyWith(status: TextosStatus.loading));
    try {
      final textos = await _service.obterTextos(condominioId);
      // Se não existir, retorna um objeto vazio com o ID do condomínio para preenchimento
      final initialTextos =
          textos ?? TextosCondominio(condominioId: condominioId);

      emit(state.copyWith(status: TextosStatus.success, textos: initialTextos));
    } catch (e) {
      emit(
        state.copyWith(
          status: TextosStatus.error,
          errorMessage: 'Erro ao carregar textos: $e',
        ),
      );
    }
  }

  Future<void> salvarTextos(TextosCondominio textos) async {
    emit(state.copyWith(status: TextosStatus.loading));
    try {
      await _service.salvarTextos(textos);
      emit(state.copyWith(status: TextosStatus.success, textos: textos));
    } catch (e) {
      emit(
        state.copyWith(
          status: TextosStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}
