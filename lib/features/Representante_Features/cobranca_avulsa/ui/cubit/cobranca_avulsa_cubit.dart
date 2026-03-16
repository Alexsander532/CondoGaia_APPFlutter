import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'cobranca_avulsa_state.dart';
import '../../data/repositories/cobranca_avulsa_repository.dart';
import '../../domain/entities/cobranca_avulsa_entity.dart';

class CobrancaAvulsaCubit extends Cubit<CobrancaAvulsaState> {
  final CobrancaAvulsaRepository _repository;
  final ImagePicker _picker = ImagePicker();

  CobrancaAvulsaCubit(this._repository) : super(CobrancaAvulsaState());

  // ============ ATUALIZAÇÃO DE CAMPOS ============

  void atualizarContaContabil(String? val) {
    emit(state.copyWith(contaContabilId: val));
  }

  void atualizarPesquisaUnidade(String val) {
    emit(state.copyWith(pesquisaUnidade: val));
  }

  void atualizarMes(int mes) {
    emit(state.copyWith(mesSelecionado: mes));
  }

  void atualizarAno(int ano) {
    emit(state.copyWith(anoSelecionado: ano));
  }

  void atualizarDescricao(String val) {
    emit(state.copyWith(descricao: val));
  }

  void atualizarTipoCobranca(String? val) {
    emit(state.copyWith(tipoCobranca: val));
  }

  void atualizarDia(int? val) {
    emit(state.copyWith(dia: val));
  }

  void atualizarValorPorUnidade(double? val) {
    emit(state.copyWith(valorPorUnidade: val));
  }

  void atualizarRecorrente(bool val) {
    emit(state.copyWith(recorrente: val));
  }

  void atualizarQtdMeses(int? val) {
    emit(state.copyWith(qtdMeses: val));
  }

  void atualizarDataInicio(DateTime? date) {
    emit(state.copyWith(dataInicio: date));
  }

  void atualizarDataFim(DateTime? date) {
    emit(state.copyWith(dataFim: date));
  }

  // ============ IMAGEM ============

  Future<void> selecionarImagem() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(state.copyWith(imagemArquivo: File(image.path)));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Erro ao selecionar imagem: $e'));
    }
  }

  void removerImagem() {
    emit(state.copyWith(clearImagemArquivo: true));
  }

  // ============ LÓGICA DO CARRINHO ============

  void adicionarAoCarrinho() {
    if (state.contaContabilId == null || state.valorPorUnidade == null) {
      emit(state.copyWith(errorMessage: 'Preencha os campos obrigatórios.'));
      return;
    }

    final novoItem = CobrancaAvulsaEntity(
      condominioId: 'COND_FIXO_TEMP', // TODO: Pegar do Auth ou Contexto
      contaContabilId: state.contaContabilId,
      valor: state.valorPorUnidade!,
      descricao: state.descricao,
      tipoCobranca: state.tipoCobranca,
      mesRef: state.mesSelecionado.toString().padLeft(2, '0'),
      anoRef: state.anoSelecionado.toString(),
      dataVencimento: DateTime(state.anoSelecionado, state.mesSelecionado, state.dia ?? 1),
    );

    final listaAtualizada = List<CobrancaAvulsaEntity>.from(state.itemsCarrinho)..add(novoItem);
    emit(state.copyWith(itemsCarrinho: listaAtualizada));
  }

  void removerDoCarrinho(int index) {
    final listaAtualizada = List<CobrancaAvulsaEntity>.from(state.itemsCarrinho)..removeAt(index);
    emit(state.copyWith(itemsCarrinho: listaAtualizada));
  }

  // ============ PERSISTÊNCIA ============

  Future<void> salvarCobrancas() async {
    if (state.itemsCarrinho.isEmpty) return;

    emit(state.copyWith(isSaving: true, status: CobrancaAvulsaStatus.loading));

    try {
      for (var item in state.itemsCarrinho) {
        await _repository.insertCobrancaAvulsa(item);
      }
      emit(state.copyWith(
        status: CobrancaAvulsaStatus.success,
        clearCarrinho: true,
        isSaving: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CobrancaAvulsaStatus.error,
        errorMessage: 'Erro ao salvar cobranças: $e',
        isSaving: false,
      ));
    }
  }

  // ============ LISTAGEM ============

  Future<void> carregarCobrancas(String condominioId) async {
    emit(state.copyWith(status: CobrancaAvulsaStatus.loading));
    try {
      final lista = await _repository.getCobrancasAvulsas(condominioId);
      emit(state.copyWith(status: CobrancaAvulsaStatus.success, cobrancasCarregadas: lista));
    } catch (e) {
      emit(state.copyWith(status: CobrancaAvulsaStatus.error, errorMessage: 'Erro ao carregar: $e'));
    }
  }

  // ============ SELEÇÃO E AÇÕES EM MASSA ============

  void alternarSelecaoItem(String id) {
    final novosSelecionados = Set<String>.from(state.itemsSelecionados);
    if (novosSelecionados.contains(id)) {
      novosSelecionados.remove(id);
    } else {
      novosSelecionados.add(id);
    }
    emit(state.copyWith(itemsSelecionados: novosSelecionados));
  }

  void alternarSelecaoTodos(bool selecionar) {
    if (selecionar) {
      final todosIds = state.cobrancasCarregadas
          .map((e) => e.id)
          .whereType<String>()
          .toSet();
      emit(state.copyWith(itemsSelecionados: todosIds));
    } else {
      emit(state.copyWith(itemsSelecionados: {}));
    }
  }

  Future<void> excluirSelecionados() async {
    if (state.itemsSelecionados.isEmpty) return;

    emit(state.copyWith(status: CobrancaAvulsaStatus.loading));

    try {
      for (var id in state.itemsSelecionados) {
        await _repository.deleteCobrancaAvulsa(id);
      }
      
      // Recarregar a lista (usando o id do condomínio do primeiro item ou um fixo balanceado)
      // Idealmente o estado teria o condomínioID atual carregado.
      final condominioId = state.cobrancasCarregadas.isNotEmpty 
        ? state.cobrancasCarregadas.first.condominioId 
        : 'COND_ID_FIXO';

      await carregarCobrancas(condominioId);
      
      emit(state.copyWith(
        status: CobrancaAvulsaStatus.success,
        itemsSelecionados: {},
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CobrancaAvulsaStatus.error,
        errorMessage: 'Erro ao excluir itens: $e',
      ));
    }
  }

  // ============ AUXILIARES ============

  void limparErro() {
    emit(state.copyWith(clearErrorMessage: true));
  }
}
