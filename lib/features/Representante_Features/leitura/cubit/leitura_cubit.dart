import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../models/leitura_model.dart';
import '../services/leitura_service.dart';
import 'leitura_state.dart';

class LeituraCubit extends Cubit<LeituraState> {
  final LeituraService _service;
  final String condominioId;

  LeituraCubit({required LeituraService service, required this.condominioId})
    : _service = service,
      super(LeituraState(selectedDate: DateTime.now()));

  Future<void> loadLeituras() async {
    try {
      emit(state.copyWith(status: LeituraStatus.loading));

      // 1. Fetch Units
      final units = await _service.fetchUnidades(condominioId);

      // 2. Fetch Existing Readings for Month/Tipo
      final readings = await _service.fetchLeituras(
        condominioId: condominioId,
        tipo: state.selectedTipo,
        month: state.selectedDate.month,
        year: state.selectedDate.year,
      );

      // 3. Fetch Taxa
      final taxa = await _service.fetchTaxaPorUnidade(
        condominioId,
        state.selectedTipo,
      );

      // 4. Merge
      // Create a map of existing readings by unidade_id
      final readingMap = {for (var r in readings) r.unidadeId: r};

      final List<LeituraModel> mergedList = units.map((unit) {
        if (readingMap.containsKey(unit.id)) {
          return readingMap[unit.id]!;
        } else {
          // Empty template
          return LeituraModel(
            id: '', // Empty ID means not saved yet
            unidadeId: unit.id,
            unidadeNome: unit.numero,
            bloco: unit.bloco,
            leituraAnterior:
                0.0, // Could fetch previous month here realistically
            leituraAtual: 0.0,
            valor: 0.0,
            dataLeitura: state.selectedDate,
            tipo: state.selectedTipo,
          );
        }
      }).toList();

      // Sort by Unidade/Bloco
      mergedList.sort((a, b) {
        int cmpBloco = (a.bloco ?? '').compareTo(b.bloco ?? '');
        if (cmpBloco != 0) return cmpBloco;
        return a.unidadeNome.compareTo(b.unidadeNome);
      });

      emit(
        state.copyWith(
          status: LeituraStatus.success,
          leituras: mergedList,
          taxaPorUnidade: taxa,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LeituraStatus.error,
          errorMessage: 'Erro ao carregar dados: $e',
        ),
      );
    }
  }

  void updateTipo(String tipo) {
    emit(state.copyWith(selectedTipo: tipo));
    loadLeituras(); // Reload for new type
  }

  void updateData(DateTime date) {
    emit(state.copyWith(selectedDate: date));
    loadLeituras();
  }

  void updateSearch(String query) {
    emit(state.copyWith(unidadePesquisa: query));
    // Filtering is usually done in UI or we filter the list here?
    // For now just storing state, UI can filter display list.
  }

  void selectUnidade(String unidadeId) {
    emit(state.copyWith(selectedUnidadeId: unidadeId));
  }

  // Called when Form saves
  Future<void> gravarLeitura({
    required String unidadeId,
    required double leituraAtual,
    File? imagem,
  }) async {
    try {
      // Find current item to get previous/taxa
      final index = state.leituras.indexWhere((l) => l.unidadeId == unidadeId);
      if (index == -1) return;

      final currentItem = state.leituras[index];

      // Calculate value based on logic (simplified)
      // Value = (Atual - Anterior) * Taxa? Or Fixed Taxa?
      // User prompt: "Valor por Unidade (R$): Já vai puxar do banco"
      // Suggests fixed rate or pre-calc. Using fixed rate for now.
      double valorCalculado = state.taxaPorUnidade;

      // Update Model
      final updatedModel = currentItem.copyWith(
        leituraAtual: leituraAtual,
        valor: valorCalculado,
        dataLeitura: DateTime.now(),
        // imagemUrl: process upload if real
      );

      // Optimistic Update
      final deepList = List<LeituraModel>.from(state.leituras);
      deepList[index] = updatedModel;
      emit(state.copyWith(leituras: deepList));

      // Save to DB
      await _service.saveLeitura(updatedModel, condominioId);

      emit(
        state.copyWith(status: LeituraStatus.success),
      ); // Just to trigger listener?
      // Ideally reload proper ID from DB response, but for now ok.
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Erro ao gravar: $e'));
    }
  }

  void toggleSelection(String unidadeId, bool? val) {
    final deepList = state.leituras.map((l) {
      if (l.unidadeId == unidadeId) {
        return l.copyWith(isSelected: val ?? false);
      }
      return l;
    }).toList();
    emit(state.copyWith(leituras: deepList));
  }

  Future<void> deleteSelected() async {
    // Filter selected and delete
    final selected = state.leituras
        .where((l) => l.isSelected && l.id.isNotEmpty)
        .toList();
    if (selected.isEmpty) return;

    try {
      for (var item in selected) {
        await _service.deleteLeitura(item.id);
      }
      loadLeituras(); // Refresh
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Erro ao excluir: $e'));
    }
  }
}

// Removed import at end
