import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/categoria_financeira_model.dart';
import '../services/gestao_condominio_service.dart';
import 'categoria_subcategoria_state.dart';

class CategoriaSubcategoriaCubit extends Cubit<CategoriaSubcategoriaState> {
  final GestaoCondominioService service;

  CategoriaSubcategoriaCubit({required this.service})
    : super(const CategoriaSubcategoriaState());

  Future<void> carregarCategorias() async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      final categorias = await service.listarCategorias();
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.success,
          categorias: categorias,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.error,
          errorMessage: 'Erro ao carregar categorias.',
        ),
      );
    }
  }

  Future<void> adicionarCategoria(String nome) async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      final novaCategoria = CategoriaFinanceira(nome: nome);
      await service.salvarCategoria(novaCategoria);
      await carregarCategorias();
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.error,
          errorMessage: 'Erro ao adicionar categoria.',
        ),
      );
    }
  }

  Future<void> excluirCategoria(String id) async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      await service.excluirCategoria(id);
      await carregarCategorias();
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.error,
          errorMessage: 'Erro ao excluir categoria.',
        ),
      );
    }
  }

  Future<void> adicionarSubcategoria(String categoriaId, String nome) async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      final novaSub = SubcategoriaFinanceira(
        categoriaId: categoriaId,
        nome: nome,
      );
      await service.salvarSubcategoria(novaSub);
      await carregarCategorias();
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.error,
          errorMessage: 'Erro ao adicionar subcategoria.',
        ),
      );
    }
  }

  Future<void> excluirSubcategoria(String id) async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      await service.excluirSubcategoria(id);
      await carregarCategorias();
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.error,
          errorMessage: 'Erro ao excluir subcategoria.',
        ),
      );
    }
  }

  // --- Edição ---

  Future<void> editarCategoria(String categoriaId, String novoNome) async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      final categoriaAtualizada = CategoriaFinanceira(
        id: categoriaId,
        nome: novoNome,
      );
      await service.salvarCategoria(categoriaAtualizada);
      await carregarCategorias();
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.error,
          errorMessage: 'Erro ao editar categoria.',
        ),
      );
    }
  }

  Future<void> editarSubcategoria(
    String subcategoriaId,
    String categoriaId,
    String novoNome,
  ) async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      final subAtualizada = SubcategoriaFinanceira(
        id: subcategoriaId,
        categoriaId: categoriaId,
        nome: novoNome,
      );
      await service.salvarSubcategoria(subAtualizada);
      await carregarCategorias();
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.error,
          errorMessage: 'Erro ao editar subcategoria.',
        ),
      );
    }
  }

  // --- Verificação de vínculos ---

  Future<int> contarDespesasPorCategoria(String categoriaId) async {
    return await service.contarDespesasPorCategoria(categoriaId);
  }

  Future<int> contarDespesasPorSubcategoria(String subcategoriaId) async {
    return await service.contarDespesasPorSubcategoria(subcategoriaId);
  }

  Future<void> reatribuirEExcluirCategoria(
    String categoriaAntigaId,
    String categoriaNovaId,
  ) async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      await service.reatribuirCategoriaDespesas(
        categoriaAntigaId,
        categoriaNovaId,
      );
      await service.excluirCategoria(categoriaAntigaId);
      await carregarCategorias();
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.error,
          errorMessage: 'Erro ao reatribuir e excluir categoria.',
        ),
      );
    }
  }

  Future<void> reatribuirEExcluirSubcategoria(
    String subcategoriaAntigaId,
    String subcategoriaNovaId,
  ) async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      await service.reatribuirSubcategoriaDespesas(
        subcategoriaAntigaId,
        subcategoriaNovaId,
      );
      await service.excluirSubcategoria(subcategoriaAntigaId);
      await carregarCategorias();
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.error,
          errorMessage: 'Erro ao reatribuir e excluir subcategoria.',
        ),
      );
    }
  }
}
