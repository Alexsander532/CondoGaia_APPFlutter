import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'cobranca_avulsa_state.dart';
import '../../data/repositories/cobranca_avulsa_repository.dart';
import '../../domain/entities/cobranca_avulsa_entity.dart';
import 'package:condogaiaapp/services/unidade_service.dart';
import '../../services/cobranca_avulsa_email_service.dart';

class CobrancaAvulsaCubit extends Cubit<CobrancaAvulsaState> {
  final CobrancaAvulsaRepository _repository;
  final UnidadeService _unidadeService;
  final CobrancaAvulsaEmailService _emailService = CobrancaAvulsaEmailService();
  final String condominioId;
  final ImagePicker _picker = ImagePicker();

  CobrancaAvulsaCubit(this._repository, this._unidadeService, {required this.condominioId}) : super(CobrancaAvulsaState());

  // ============ ATUALIZAÇÃO DE CAMPOS ============

  void atualizarContaContabil(String? val) {
    emit(state.copyWith(contaContabilId: val));
  }

  void atualizarPesquisaUnidade(String val) async {
    emit(state.copyWith(pesquisaUnidade: val, loadingUnidades: true));
    
    if (val.isEmpty) {
      emit(state.copyWith(unidadesPesquisadas: [], loadingUnidades: false));
      return;
    }

    try {
      final resultados = await _unidadeService.buscarUnidades(
        condominioId: condominioId,
        termo: val,
      );
      emit(state.copyWith(unidadesPesquisadas: resultados, loadingUnidades: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Erro ao buscar unidades: $e', loadingUnidades: false));
    }
  }

  void alternarSelecaoUnidade(String unidadeId) {
    final novasSelecionadas = Set<String>.from(state.unidadesSelecionadas);
    if (novasSelecionadas.contains(unidadeId)) {
      novasSelecionadas.remove(unidadeId);
    } else {
      novasSelecionadas.add(unidadeId);
    }
    emit(state.copyWith(unidadesSelecionadas: novasSelecionadas));
  }

  void limparSelecaoUnidades() {
    emit(state.copyWith(unidadesSelecionadas: {}));
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

    if (state.unidadesSelecionadas.isEmpty) {
      emit(state.copyWith(errorMessage: 'Selecione pelo menos uma unidade.'));
      return;
    }

    final novosItems = <CobrancaAvulsaEntity>[];
    for (var unidadeId in state.unidadesSelecionadas) {
      novosItems.add(CobrancaAvulsaEntity(
        condominioId: condominioId,
        contaContabilId: state.contaContabilId,
        unidadeId: unidadeId,
        valor: state.valorPorUnidade!,
        descricao: state.descricao,
        tipoCobranca: state.tipoCobranca,
        mesRef: state.mesSelecionado.toString().padLeft(2, '0'),
        anoRef: state.anoSelecionado.toString(),
        dataVencimento: DateTime(state.anoSelecionado, state.mesSelecionado, state.dia ?? 1),
        recorrente: state.recorrente,
        qtdMeses: state.recorrente ? state.qtdMeses : null,
      ));
    }

    final listaAtualizada = List<CobrancaAvulsaEntity>.from(state.itemsCarrinho)..addAll(novosItems);
    emit(state.copyWith(
      itemsCarrinho: listaAtualizada,
      unidadesSelecionadas: {}, // Limpar seleção após adicionar
    ));
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
      // 1. Upload do comprovante (se houver imagem selecionada)
      String? comprovanteUrl;
      if (state.imagemArquivo != null) {
        comprovanteUrl = await _repository.uploadComprovante(
          condominioId: condominioId,
          arquivo: state.imagemArquivo!,
        );
      }

      // 2. Agrupar itens do carrinho por características comuns
      final groupedItems = <String, List<CobrancaAvulsaEntity>>{};
      for (var item in state.itemsCarrinho) {
        final key = '${item.valor}_${item.descricao}_${item.dataVencimento?.toIso8601String()}_${item.recorrente}_${item.qtdMeses}';
        if (!groupedItems.containsKey(key)) {
          groupedItems[key] = [];
        }
        groupedItems[key]!.add(item);
      }

      // 3. Enviar ao backend em lote (uma chamada por grupo de características)
      for (var entry in groupedItems.entries) {
        final items = entry.value;
        final firstItem = items.first;
        final unidades = items.map((e) => e.unidadeId).where((id) => id != null).cast<String>().toList();

        if (unidades.isNotEmpty) {
          await _repository.insertCobrancaAvulsaBatch(
            condominioId: condominioId,
            unidades: unidades,
            valor: firstItem.valor,
            dataVencimento: firstItem.dataVencimento,
            descricao: firstItem.descricao ?? '',
            recorrente: firstItem.recorrente,
            qtdMeses: firstItem.qtdMeses,
          );
        }
      }

      // 4. Disparar e-mail (melhor esforço — não bloqueia sucesso se falhar)
      try {
        final dataVencimentoStr = state.itemsCarrinho.first.dataVencimento
            ?.toIso8601String()
            .split('T')
            .first ?? '';
        await _emailService.enviarCobrancaAvulsa(
          email: '', // Email será buscado pelo backend via morador_id
          nome: '',
          descricao: state.descricao ?? state.itemsCarrinho.first.descricao ?? '',
          valor: state.valorPorUnidade ?? 0,
          dataVencimento: dataVencimentoStr,
          comprovanteUrl: comprovanteUrl,
        );
      } catch (_) {
        // Silencioso: falha de e-mail não impede sucesso da cobrança
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
