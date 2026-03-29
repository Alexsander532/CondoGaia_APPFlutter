import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cobranca_avulsa_state.dart';
import 'package:intl/intl.dart';
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

  // ============ ATUALIZADORES DO FORMULÁRIO ============

  void atualizarContaContabil(String? valor) {
    emit(state.copyWith(contaContabilId: valor));
  }

  void atualizarContaContabilPesquisa(String? valor) {
    emit(state.copyWith(contaContabilPesquisaId: valor));
  }

  void atualizarPesquisaUnidade(String val) async {
    emit(state.copyWith(pesquisaUnidade: val, loadingUnidades: true));
    
    if (val.isEmpty) {
      emit(state.copyWith(unidadesPesquisadas: [], loadingUnidades: false, nomeProprietarioPorUnidade: {}));
      return;
    }

    try {
      final resultados = await _unidadeService.buscarUnidades(
        condominioId: condominioId,
        termo: val,
      );

      // Buscar nomes dos proprietários/inquilinos para exibição na tabela
      final allUnidadeIds = resultados
          .expand((b) => b.unidades)
          .map((u) => u.id)
          .where((id) => id.isNotEmpty)
          .toList();

      final Map<String, String> nomesMap = {};

      if (allUnidadeIds.isNotEmpty) {
        final supabase = Supabase.instance.client;

        // Buscar proprietários
        final propRes = await supabase
            .from('proprietarios')
            .select('unidade_id, nome')
            .eq('condominio_id', condominioId)
            .inFilter('unidade_id', allUnidadeIds);

        for (var p in (propRes as List)) {
          final uid = p['unidade_id']?.toString() ?? '';
          if (uid.isNotEmpty && !nomesMap.containsKey(uid)) {
            nomesMap[uid] = p['nome']?.toString() ?? 'Proprietário';
          }
        }

        // Buscar inquilinos (para unidades sem proprietário)
        final inqRes = await supabase
            .from('inquilinos')
            .select('unidade_id, nome')
            .eq('condominio_id', condominioId)
            .inFilter('unidade_id', allUnidadeIds);

        for (var i in (inqRes as List)) {
          final uid = i['unidade_id']?.toString() ?? '';
          if (uid.isNotEmpty && !nomesMap.containsKey(uid)) {
            nomesMap[uid] = i['nome']?.toString() ?? 'Inquilino';
          }
        }
      }

      emit(state.copyWith(
        unidadesPesquisadas: resultados,
        nomeProprietarioPorUnidade: nomesMap,
        loadingUnidades: false,
      ));
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

  void atualizarDia(int dia) {
    emit(state.copyWith(dia: dia));
  }

  void atualizarDataVencimento(String data) {
    emit(state.copyWith(dataVencimentoStr: data));
  }

  void atualizarValorPorUnidade(String unidadeId, double val) {
    final map = Map<String, double>.from(state.valoresPorUnidade);
    map[unidadeId] = val;
    emit(state.copyWith(valoresPorUnidade: map));
  }

  void atualizarRecorrente(bool val) {
    emit(state.copyWith(recorrente: val));
  }

  void atualizarQtdMeses(int? val) {
    emit(state.copyWith(qtdMeses: val));
  }

  void atualizarDataInicio(DateTime? date) {
    emit(state.copyWith(dataInicio: date));
    // Auto-calcular dataFim se qtdMeses estiver definida
    if (date != null && state.qtdMeses != null && state.qtdMeses! > 0) {
      final fim = DateTime(date.year, date.month + state.qtdMeses! - 1, date.day);
      emit(state.copyWith(dataFim: fim));
    }
  }

  void atualizarQtdMesesERecalcular(int? val) {
    emit(state.copyWith(qtdMeses: val));
    // Recalcular dataFim se dataInicio estiver definida
    if (val != null && val > 0 && state.dataInicio != null) {
      final fim = DateTime(state.dataInicio!.year, state.dataInicio!.month + val - 1, state.dataInicio!.day);
      emit(state.copyWith(dataFim: fim));
    }
  }

  void atualizarEnviarRegistro(bool val) {
    emit(state.copyWith(enviarParaRegistro: val));
  }

  void atualizarEnviarEmail(bool val) {
    emit(state.copyWith(enviarPorEmail: val));
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
    if (state.contaContabilId == null) {
      emit(state.copyWith(errorMessage: 'Preencha os campos obrigatórios.'));
      return;
    }

    if (state.unidadesSelecionadas.isEmpty) {
      emit(state.copyWith(errorMessage: 'Selecione pelo menos uma unidade.'));
      return;
    }

    // Parse da data de vencimento
    DateTime? dataVencimento;
    if (state.dataVencimentoStr != null && state.dataVencimentoStr!.length == 10) {
      try {
        dataVencimento = DateFormat('dd/MM/yyyy').parse(state.dataVencimentoStr!);
        
        // Validação: Não pode ser antes de hoje
        final hoje = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        if (dataVencimento.isBefore(hoje)) {
          emit(state.copyWith(errorMessage: 'A data de vencimento deve ser hoje ou uma data futura.'));
          return;
        }
      } catch (e) {
        emit(state.copyWith(errorMessage: 'Data de vencimento inválida. Use o formato dd/mm/aaaa.'));
        return;
      }
    } else {
      emit(state.copyWith(errorMessage: 'Informe uma data de vencimento válida (dd/mm/aaaa).'));
      return;
    }

    final novosItems = <CobrancaAvulsaEntity>[];
    for (var unidadeId in state.unidadesSelecionadas) {
      final valorUnidade = state.valoresPorUnidade[unidadeId] ?? 0.0;
      if (valorUnidade <= 0) {
        emit(state.copyWith(errorMessage: 'Preencha os valores para as unidades selecionadas.'));
        return;
      }

      novosItems.add(CobrancaAvulsaEntity(
        condominioId: condominioId,
        contaContabilId: state.contaContabilId,
        unidadeId: unidadeId,
        valor: valorUnidade,
        descricao: state.descricao ?? "Cobrança Avulsa", // Valor padrão se vazio
        tipoCobranca: state.tipoCobranca,
        mesRef: state.mesSelecionado.toString().padLeft(2, '0'),
        anoRef: state.anoSelecionado.toString(),
        dataVencimento: dataVencimento,
        recorrente: state.recorrente,
        qtdMeses: state.recorrente ? state.qtdMeses : null,
      ));
    }

    final listaAtualizada = List<CobrancaAvulsaEntity>.from(state.itemsCarrinho)..addAll(novosItems);
    emit(state.copyWith(
      itemsCarrinho: listaAtualizada,
      unidadesSelecionadas: {}, // Limpar seleção após adicionar
      valoresPorUnidade: {}, // Limpa os valores também
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
          valor: state.itemsCarrinho.first.valor,
          dataVencimento: dataVencimentoStr,
          comprovanteUrl: comprovanteUrl,
        );
      } catch (_) {
        // Silencioso: falha de e-mail não impede sucesso da cobrança
      }

      emit(state.copyWith(
        status: CobrancaAvulsaStatus.saveSuccess,
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

  Future<void> carregarCobrancas() async {
    emit(state.copyWith(status: CobrancaAvulsaStatus.loading));
    try {
      final lista = await _repository.getCobrancasAvulsas(condominioId);
      emit(state.copyWith(status: CobrancaAvulsaStatus.loadSuccess, cobrancasCarregadas: lista));
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
      
      await carregarCobrancas();
      
      emit(state.copyWith(
        status: CobrancaAvulsaStatus.deleteSuccess,
        itemsSelecionados: {},
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CobrancaAvulsaStatus.error,
        errorMessage: 'Erro ao excluir itens: $e',
      ));
    }
  }

  Future<void> sincronizarStatus(String id) async {
    // 1. Achar o boleto na lista carregada para pegar o asaas_payment_id
    // final boleto = state.cobrancasCarregadas.firstWhere((e) => e.id == id);
    
    emit(state.copyWith(status: CobrancaAvulsaStatus.loading));

    try {
      // Se não tivermos o asaas_id em mãos, não podemos sincronizar.
      // Vou buscar o asaas_id do Supabase agora só para garantir.
      final supabase = Supabase.instance.client;
      final res = await supabase.from('boletos').select('asaas_payment_id').eq('id', id).single();
      final realAsaasId = res['asaas_payment_id'];

      if (realAsaasId == null) {
        throw Exception('Este boleto não possui um ID do ASAAS vinculado.');
      }

      await _repository.sincronizarBoleto(realAsaasId);
      
      // Recarregar a lista para ver o novo status
      await carregarCobrancas();
      
      emit(state.copyWith(status: CobrancaAvulsaStatus.syncSuccess));
    } catch (e) {
      emit(state.copyWith(
        status: CobrancaAvulsaStatus.error,
        errorMessage: 'Erro ao sincronizar: $e',
      ));
    }
  }

  // ============ AUXILIARES ============

  void resetStatus() {
    emit(state.copyWith(status: CobrancaAvulsaStatus.initial));
  }

  void limparErro() {
    emit(state.copyWith(clearErrorMessage: true));
  }
}
