import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../models/leitura_model.dart';
import '../models/leitura_configuracao_model.dart';
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

      // Limpar cache ao recarregar para garantir dados atualizados
      await _service.clearLeiturasCache(condominioId, state.selectedTipo);
      await _service.clearConfigCache(condominioId, state.selectedTipo);

      // Carregar todos os dados em paralelo para melhor performance
      final futures = await Future.wait([
        _service.fetchUnidades(condominioId),
        _service.fetchLeituras(
          condominioId: condominioId,
          tipo: state.selectedTipo,
          month: state.selectedDate.month,
          year: state.selectedDate.year,
        ),
        _service.fetchConfiguracao(
          condominioId: condominioId,
          tipo: state.selectedTipo,
        ),
        _service.fetchLeiturasAnteriores(
          condominioId: condominioId,
          tipo: state.selectedTipo,
          month: state.selectedDate.month,
          year: state.selectedDate.year,
        ),
        _service.fetchTodasConfiguracoes(condominioId),
      ]);

      final units = futures[0] as List;
      final readings = futures[1] as List<LeituraModel>;
      final config = futures[2] as LeituraConfiguracaoModel?;
      final leiturasAnteriores = futures[3] as Map<String, double>;
      final configsList = futures[4] as List<LeituraConfiguracaoModel>;

      // Atualizar lista de tipos disponíveis
      final Set<String> tiposSet = {'Agua', 'Gas'};
      if (configsList.isNotEmpty) {
        tiposSet.addAll(configsList.map((c) => c.tipo));
      }
      final tiposDisponiveis = tiposSet.toList()..sort();

      final readingMap = {for (var r in readings) r.unidadeId: r};

      final List<LeituraModel> mergedList = units.map((unit) {
        if (readingMap.containsKey(unit.id)) {
          final r = readingMap[unit.id]!;
          return r.copyWith(unidadeNome: unit.numero, bloco: unit.bloco);
        }
        final leituraAnterior = leiturasAnteriores[unit.id] ?? 0.0;
        return LeituraModel(
          id: '',
          unidadeId: unit.id,
          unidadeNome: unit.numero,
          bloco: unit.bloco,
          leituraAnterior: leituraAnterior,
          leituraAtual: 0.0,
          valor: 0.0,
          dataLeitura: state.selectedDate,
          tipo: state.selectedTipo,
        );
      }).toList();

      mergedList.sort((a, b) {
        int cmpBloco = (a.bloco ?? '').compareTo(b.bloco ?? '');
        if (cmpBloco != 0) return cmpBloco;
        return a.unidadeNome.compareTo(b.unidadeNome);
      });

      emit(
        state.copyWith(
          status: LeituraStatus.success,
          leituras: mergedList,
          configuracao: config,
          tiposDisponiveis: tiposDisponiveis,
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
    loadLeituras();
  }

  void updateData(DateTime date) {
    emit(state.copyWith(selectedDate: date));
    loadLeituras();
  }

  void updateSearch(String query) {
    emit(state.copyWith(unidadePesquisa: query));
  }

  void selectUnidade(String unidadeId) {
    emit(state.copyWith(selectedUnidadeId: unidadeId));
  }

  Future<void> gravarLeitura({
    required String unidadeId,
    required double leituraAtual,
    File? imagem,
  }) async {
    try {
      final index = state.leituras.indexWhere((l) => l.unidadeId == unidadeId);
      if (index == -1) return;

      final currentItem = state.leituras[index];

      if (leituraAtual < currentItem.leituraAnterior) {
        emit(
          state.copyWith(
            errorMessage: 'Leitura atual não pode ser menor que a anterior',
          ),
        );
        return;
      }

      final consumo = leituraAtual - currentItem.leituraAnterior;
      double valorCalculado = 0;
      if (state.configuracao != null) {
        valorCalculado = state.configuracao!.calcularValor(consumo);
      } else {
        valorCalculado = consumo * 0; // Sem config, valor zero
      }

      final updatedModel = currentItem.copyWith(
        leituraAtual: leituraAtual,
        valor: valorCalculado,
        dataLeitura: DateTime(
          state.selectedDate.year,
          state.selectedDate.month,
          state.selectedDate.day,
        ),
      );

      final deepList = List<LeituraModel>.from(state.leituras);
      deepList[index] = updatedModel;
      emit(state.copyWith(leituras: deepList));

      await _service.saveLeitura(updatedModel, condominioId, imagem: imagem);

      // Recarregar dados automaticamente após gravar
      await loadLeituras();
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

  Future<void> loadMoreUnidades() async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final limit = 20;
      final offset = (state.currentPage - 1) * limit;

      final additionalUnits = await _service.fetchUnidadesPaginated(
        condominioId: condominioId,
        limit: limit,
        offset: offset,
      );

      if (additionalUnits.isEmpty) {
        emit(state.copyWith(isLoadingMore: false, hasReachedMax: true));
        return;
      }

      // Mesclar com leituras existentes
      final readingMap = {for (var r in state.leituras) r.unidadeId: r};

      final List<LeituraModel> mergedAdditionalList = additionalUnits.map((
        unit,
      ) {
        if (readingMap.containsKey(unit.id)) {
          final r = readingMap[unit.id]!;
          return r.copyWith(unidadeNome: unit.numero, bloco: unit.bloco);
        }
        return LeituraModel(
          id: '',
          unidadeId: unit.id,
          unidadeNome: unit.numero,
          bloco: unit.bloco,
          leituraAnterior: 0.0,
          leituraAtual: 0.0,
          valor: 0.0,
          dataLeitura: state.selectedDate,
          tipo: state.selectedTipo,
        );
      }).toList();

      final updatedLeituras = [...state.leituras, ...mergedAdditionalList];

      emit(
        state.copyWith(
          leituras: updatedLeituras,
          currentPage: state.currentPage + 1,
          isLoadingMore: false,
          hasReachedMax: additionalUnits.length < limit,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Erro ao carregar mais unidades: $e',
        ),
      );
    }
  }

  Future<void> deleteSelected() async {
    final selected = state.leituras
        .where((l) => l.isSelected && l.id.isNotEmpty)
        .toList();
    if (selected.isEmpty) return;

    try {
      for (var item in selected) {
        await _service.deleteLeitura(item.id);
      }
      loadLeituras();
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Erro ao excluir: $e'));
    }
  }
}
