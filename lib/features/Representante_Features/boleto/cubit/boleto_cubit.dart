import 'package:bloc/bloc.dart';
import '../services/boleto_service.dart';
import 'boleto_state.dart';

class BoletoCubit extends Cubit<BoletoState> {
  final BoletoService _service;
  final String condominioId;

  BoletoCubit({required BoletoService service, required this.condominioId})
    : _service = service,
      super(
        BoletoState(
          mesSelecionado: DateTime.now().month,
          anoSelecionado: DateTime.now().year,
        ),
      );

  // ============================================================
  // CARREGAMENTO INICIAL
  // ============================================================

  Future<void> carregarDados() async {
    emit(state.copyWith(status: BoletoStatus.loading));
    try {
      final boletos = await _service.listarBoletos(
        condominioId,
        mes: state.mesSelecionado,
        ano: state.anoSelecionado,
        tipoEmissao: state.tipoEmissao,
        situacao: state.situacao,
        nossoNumero: state.nossoNumero,
        pesquisa: state.pesquisa,
        dataInicio: state.dataInicio,
        dataFim: state.dataFim,
      );

      final contas = await _service.listarContasBancarias(condominioId);

      emit(
        state.copyWith(
          status: BoletoStatus.success,
          boletos: boletos,
          contasBancarias: contas,
          itensSelecionados: {},
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: BoletoStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // ============================================================
  // PESQUISAR
  // ============================================================

  Future<void> pesquisar() async {
    emit(state.copyWith(status: BoletoStatus.loading));
    try {
      final boletos = await _service.listarBoletos(
        condominioId,
        mes: state.mesSelecionado,
        ano: state.anoSelecionado,
        tipoEmissao: state.tipoEmissao,
        situacao: state.situacao,
        nossoNumero: state.nossoNumero,
        pesquisa: state.pesquisa,
        dataInicio: state.dataInicio,
        dataFim: state.dataFim,
      );
      emit(
        state.copyWith(
          status: BoletoStatus.success,
          boletos: boletos,
          itensSelecionados: {},
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: BoletoStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // ============================================================
  // NAVEGAÇÃO MÊS/ANO
  // ============================================================

  void mesAnterior() {
    int mes = state.mesSelecionado - 1;
    int ano = state.anoSelecionado;
    if (mes < 1) {
      mes = 12;
      ano--;
    }
    emit(state.copyWith(mesSelecionado: mes, anoSelecionado: ano));
    carregarDados();
  }

  void proximoMes() {
    int mes = state.mesSelecionado + 1;
    int ano = state.anoSelecionado;
    if (mes > 12) {
      mes = 1;
      ano++;
    }
    emit(state.copyWith(mesSelecionado: mes, anoSelecionado: ano));
    carregarDados();
  }

  // ============================================================
  // FILTROS
  // ============================================================

  void atualizarFiltros({
    String? tipoEmissao,
    String? situacao,
    String? dataInicio,
    String? dataFim,
    String? nossoNumero,
    String? pesquisa,
    String? filtroRapido,
  }) {
    emit(
      state.copyWith(
        tipoEmissao: tipoEmissao ?? state.tipoEmissao,
        situacao: situacao ?? state.situacao,
        dataInicio: dataInicio ?? state.dataInicio,
        dataFim: dataFim ?? state.dataFim,
        nossoNumero: nossoNumero ?? state.nossoNumero,
        pesquisa: pesquisa ?? state.pesquisa,
        filtroRapido: filtroRapido ?? state.filtroRapido,
      ),
    );
  }

  void toggleFiltro() {
    emit(state.copyWith(filtroExpandido: !state.filtroExpandido));
  }

  void toggleDetalharComposicao() {
    emit(state.copyWith(detalharComposicao: !state.detalharComposicao));
  }

  void setFiltroRapido(String filtro) {
    emit(state.copyWith(filtroRapido: filtro));
  }

  // ============================================================
  // SELEÇÃO
  // ============================================================

  void toggleItemSelecionado(String id) {
    final current = Set<String>.from(state.itensSelecionados);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    emit(state.copyWith(itensSelecionados: current));
  }

  void selecionarTodos(List<String> ids) {
    final allSelected = ids.every((id) => state.itensSelecionados.contains(id));
    if (allSelected) {
      emit(state.copyWith(itensSelecionados: {}));
    } else {
      emit(state.copyWith(itensSelecionados: ids.toSet()));
    }
  }

  void limparSelecao() {
    emit(state.copyWith(itensSelecionados: {}));
  }

  // ============================================================
  // RECEBER BOLETO
  // ============================================================

  Future<void> receberBoleto({
    required String boletoId,
    required String contaBancariaId,
    required String dataPagamento,
    required double juros,
    required double multa,
    required double outrosAcrescimos,
    required double valorTotal,
    String? obs,
  }) async {
    emit(state.copyWith(isSaving: true));
    try {
      await _service.receberBoleto(
        boletoId: boletoId,
        contaBancariaId: contaBancariaId,
        dataPagamento: dataPagamento,
        juros: juros,
        multa: multa,
        outrosAcrescimos: outrosAcrescimos,
        valorTotal: valorTotal,
        obs: obs,
      );
      emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Boleto recebido com sucesso!',
        ),
      );
      await carregarDados();
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  // ============================================================
  // EXCLUIR BOLETOS
  // ============================================================

  Future<void> excluirSelecionados() async {
    if (state.itensSelecionados.isEmpty) return;
    emit(state.copyWith(status: BoletoStatus.loading));
    try {
      await _service.excluirBoletosMultiplos(state.itensSelecionados.toList());
      emit(
        state.copyWith(
          successMessage:
              '${state.itensSelecionados.length} boleto(s) excluído(s) com sucesso!',
        ),
      );
      await carregarDados();
    } catch (e) {
      emit(
        state.copyWith(status: BoletoStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // ============================================================
  // AGRUPAR BOLETOS
  // ============================================================

  Future<void> agruparSelecionados() async {
    if (state.itensSelecionados.length < 2) return;
    emit(state.copyWith(status: BoletoStatus.loading));
    try {
      await _service.agruparBoletos(state.itensSelecionados.toList());
      emit(state.copyWith(successMessage: 'Boletos agrupados com sucesso!'));
      await carregarDados();
    } catch (e) {
      emit(
        state.copyWith(status: BoletoStatus.error, errorMessage: e.toString()),
      );
    }
  }

  // ============================================================
  // GERAR COBRANÇA MENSAL
  // ============================================================

  Future<void> gerarCobrancaMensal({
    required String dataVencimento,
    required double cotaCondominial,
    required double fundoReserva,
    required double multaInfracao,
    required double controle,
    required double rateioAgua,
    required double desconto,
    required bool enviarParaRegistro,
    required bool enviarPorEmail,
    List<String>? unidadeIds,
  }) async {
    emit(state.copyWith(isSaving: true));
    try {
      await _service.gerarCobrancaMensal(
        condominioId: condominioId,
        dataVencimento: dataVencimento,
        cotaCondominial: cotaCondominial,
        fundoReserva: fundoReserva,
        multaInfracao: multaInfracao,
        controle: controle,
        rateioAgua: rateioAgua,
        desconto: desconto,
        enviarParaRegistro: enviarParaRegistro,
        enviarPorEmail: enviarPorEmail,
        unidadeIds: unidadeIds,
      );
      emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Cobrança mensal gerada com sucesso!',
        ),
      );
      await carregarDados();
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  // ============================================================
  // ENVIAR PARA REGISTRO
  // ============================================================

  Future<void> enviarParaRegistro() async {
    if (state.itensSelecionados.isEmpty) return;
    emit(state.copyWith(isSaving: true));
    try {
      final resultado = await _service.enviarParaRegistro(
        state.itensSelecionados.toList(),
      );
      final sucesso = resultado['sucesso'] as int;
      final erros = resultado['erros'] as List;

      String msg = '$sucesso Boletos enviados com Sucesso.';
      if (erros.isNotEmpty) {
        msg += '\n${erros.length} erros encontrados.';
      }

      emit(state.copyWith(isSaving: false, successMessage: msg));
      await carregarDados();
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  // ============================================================
  // ENVIAR POR E-MAIL
  // ============================================================

  Future<void> enviarBoletosPorEmail() async {
    if (state.itensSelecionados.isEmpty) return;
    emit(state.copyWith(isSaving: true));
    try {
      await _service.enviarBoletosPorEmail(
        condominioId: condominioId,
        boletoIds: state.itensSelecionados.toList(),
      );
      emit(
        state.copyWith(
          isSaving: false,
          successMessage: 'Boletos enviados por e-mail com sucesso!',
        ),
      );
      await carregarDados(); // Optional: remove selection
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  // ============================================================
  // CARREGAR UNIDADES (para dialog)
  // ============================================================

  Future<void> carregarUnidades({String? pesquisa}) async {
    try {
      final unidades = await _service.listarUnidades(
        condominioId,
        pesquisa: pesquisa,
      );
      emit(state.copyWith(unidades: unidades));
    } catch (e) {
      print('⚠️ [BoletoCubit] Erro ao carregar unidades: $e');
    }
  }
}
