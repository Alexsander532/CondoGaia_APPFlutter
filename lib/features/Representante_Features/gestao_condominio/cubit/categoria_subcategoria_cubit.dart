import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/categoria_financeira_model.dart';
import '../services/gestao_condominio_service.dart';
import 'categoria_subcategoria_state.dart';

class CategoriaSubcategoriaCubit extends Cubit<CategoriaSubcategoriaState> {
  final GestaoCondominioService service;

  CategoriaSubcategoriaCubit({required this.service})
    : super(const CategoriaSubcategoriaState());

  Future<void> carregarCategorias(String condominioId) async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      final categorias = await service.listarCategorias(condominioId);
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

  Future<void> adicionarCategoria(String condominioId, String nome) async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      final novaCategoria = CategoriaFinanceira(
        condominioId: condominioId,
        nome: nome,
      );
      await service.salvarCategoria(novaCategoria);
      await carregarCategorias(condominioId);
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.error,
          errorMessage: 'Erro ao adicionar categoria.',
        ),
      );
    }
  }

  Future<void> excluirCategoria(String condominioId, String id) async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      await service.excluirCategoria(id);
      await carregarCategorias(condominioId);
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.error,
          errorMessage: 'Erro ao excluir categoria.',
        ),
      );
    }
  }

  Future<void> adicionarSubcategoria(
    String condominioId,
    String categoriaId,
    String nome,
  ) async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      final novaSub = SubcategoriaFinanceira(
        categoriaId: categoriaId,
        nome: nome,
      );
      await service.salvarSubcategoria(novaSub);
      await carregarCategorias(condominioId);
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.error,
          errorMessage: 'Erro ao adicionar subcategoria.',
        ),
      );
    }
  }

  Future<void> excluirSubcategoria(String condominioId, String id) async {
    emit(state.copyWith(status: CategoriaSubcategoriaStatus.loading));
    try {
      await service.excluirSubcategoria(id);
      await carregarCategorias(condominioId);
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoriaSubcategoriaStatus.error,
          errorMessage: 'Erro ao excluir subcategoria.',
        ),
      );
    }
  }
}
