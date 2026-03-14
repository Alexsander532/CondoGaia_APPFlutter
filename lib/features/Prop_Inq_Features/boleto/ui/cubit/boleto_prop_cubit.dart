import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/usecases/boleto_prop_usecases.dart';
import 'boleto_prop_state.dart';

class BoletoPropCubit extends Cubit<BoletoPropState> {
  final ObterBoletosPropUseCase _obterBoletos;
  final ObterComposicaoBoletoUseCase _obterComposicao;
  final ObterDemonstrativoFinanceiroUseCase _obterDemonstrativo;
  final ObterLeiturasUseCase _obterLeituras;
  final ObterBalanceteOnlineUseCase _obterBalanceteOnline;
  final String moradorId;
  final String condominioId;

  BoletoPropCubit({
    required ObterBoletosPropUseCase obterBoletos,
    required ObterComposicaoBoletoUseCase obterComposicao,
    required ObterDemonstrativoFinanceiroUseCase obterDemonstrativo,
    required ObterLeiturasUseCase obterLeituras,
    required ObterBalanceteOnlineUseCase obterBalanceteOnline,
    required this.moradorId,
    required this.condominioId,
  })  : _obterBoletos = obterBoletos,
        _obterComposicao = obterComposicao,
        _obterDemonstrativo = obterDemonstrativo,
        _obterLeituras = obterLeituras,
        _obterBalanceteOnline = obterBalanceteOnline,
        super(
          BoletoPropState(
            mesSelecionado: DateTime.now().month,
            anoSelecionado: DateTime.now().year,
          ),
        );

  // ============================================================
  // CARREGAMENTO INICIAL
  // ============================================================

  Future<void> carregarBoletos() async {
    emit(state.copyWith(status: BoletoPropStatus.loading));
    try {
      final boletos = await _obterBoletos.call(
        moradorId: moradorId,
        filtroStatus: state.filtroSelecionado,
      );
      emit(state.copyWith(status: BoletoPropStatus.success, boletos: boletos));
    } catch (e) {
      emit(
        state.copyWith(
          status: BoletoPropStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // DEMONSTRATIVO FINANCEIRO
  // ============================================================
  Future<void> carregarDemonstrativoFinanceiro() async {
    try {
      emit(state.copyWith(status: BoletoPropStatus.loading));

      final demonstrativo = await _obterDemonstrativo(
        moradorId: moradorId,
        mes: state.mesSelecionado,
        ano: state.anoSelecionado,
      );

      emit(state.copyWith(
        status: BoletoPropStatus.success,
        demonstrativoFinanceiro: demonstrativo,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BoletoPropStatus.error,
        errorMessage: 'Erro ao carregar demonstrativo financeiro: $e',
      ));
    }
  }

  // ============================================================
  // LEITURAS E COMPOSIÇÃO
  // ============================================================
  Future<void> carregarLeiturasEComposicao(String boletoId) async {
    try {
      final boleto = state.boletos.firstWhere((b) => b.id == boletoId);
      
      // Carregar composição do boleto
      final composicao = await _obterComposicao(boletoId);
      
      // Carregar leituras da unidade (se tiver unidadeId)
      List<Map<String, dynamic>> leituras = [];
      if (boleto.unidadeId != null) {
        try {
          leituras = await _obterLeituras(
            unidadeId: boleto.unidadeId!,
            mes: state.mesSelecionado,
            ano: state.anoSelecionado,
          );
        } catch (e) {
          // Leituras podem não existir, não é erro crítico
          print('Aviso: Leitura não encontrada para a unidade: $e');
        }
      }

      emit(state.copyWith(
        composicaoBoleto: composicao,
        leituras: leituras,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Erro ao carregar composição: $e',
      ));
    }
  }

  // ============================================================
  // BALANCETE ONLINE
  // ============================================================
  Future<void> carregarBalanceteOnline() async {
    try {
      final balancete = await _obterBalanceteOnline(
        condominioId: condominioId,
        mes: state.mesSelecionado,
        ano: state.anoSelecionado,
      );

      emit(state.copyWith(
        balanceteOnline: balancete,
      ));
    } catch (e) {
      // Balancete pode não existir, não é erro crítico
      print('Aviso: Balancete não encontrado para o período: $e');
    }
  }

  // ============================================================
  // FILTRO
  // ============================================================

  void alterarFiltro(String filtro) {
    emit(state.copyWith(filtroSelecionado: filtro, clearBoletoExpandido: true));
    carregarBoletos(); // Recarrega com o novo filtro
  }

  // ============================================================
  // EXPANDIR/COLAPSAR BOLETO
  // ============================================================

  void expandirBoleto(String boletoId) {
    if (state.boletoExpandidoId == boletoId) {
      // Colapsar se já estiver expandido
      emit(state.copyWith(clearBoletoExpandido: true));
    } else {
      // Expandir e carregar dados
      emit(state.copyWith(boletoExpandidoId: boletoId));
      carregarLeiturasEComposicao(boletoId);
    }
  }

  // ============================================================
  // DEMONSTRATIVO FINANCEIRO - NAVEGAÇÃO MÊS/ANO
  // ============================================================

  void mesAnterior() {
    int mes = state.mesSelecionado - 1;
    int ano = state.anoSelecionado;
    if (mes < 1) {
      mes = 12;
      ano--;
    }
    emit(state.copyWith(mesSelecionado: mes, anoSelecionado: ano));
    // Recarregar dados do novo período
    carregarDemonstrativoFinanceiro();
    carregarBalanceteOnline();
  }

  void proximoMes() {
    int mes = state.mesSelecionado + 1;
    int ano = state.anoSelecionado;
    if (mes > 12) {
      mes = 1;
      ano++;
    }
    emit(state.copyWith(mesSelecionado: mes, anoSelecionado: ano));
    // Recarregar dados do novo período
    carregarDemonstrativoFinanceiro();
    carregarBalanceteOnline();
  }

  // ============================================================
  // SEÇÕES EXPANSÍVEIS
  // ============================================================

  void toggleComposicaoBoleto() async {
    final wasExpanded = state.composicaoBoletoExpandida;
    emit(state.copyWith(
      composicaoBoletoExpandida: !wasExpanded,
      composicaoBoleto: wasExpanded ? null : {}, // Limpa ao colapsar
    ));

    // Se está expandindo e há um boleto selecionado, carrega a composição
    if (!wasExpanded && state.boletoExpandidoId != null) {
      try {
        final composicao = await _obterComposicao.call(state.boletoExpandidoId!);
        emit(state.copyWith(composicaoBoleto: composicao));
      } catch (e) {
        print('Erro ao carregar composição do boleto: $e');
      }
    }
  }

  void toggleLeituras() {
    emit(state.copyWith(leiturasExpandida: !state.leiturasExpandida));
  }

  void toggleBalanceteOnline() {
    emit(
      state.copyWith(balanceteOnlineExpandido: !state.balanceteOnlineExpandido),
    );
  }

  // ============================================================
  // AÇÕES
  // ============================================================

  Future<void> verBoleto(String boletoId) async {
    try {
      final boleto = state.boletos.firstWhere((b) => b.id == boletoId);
      
      if (boleto.bankSlipUrl != null && boleto.bankSlipUrl!.isNotEmpty) {
        final uri = Uri.parse(boleto.bankSlipUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          emit(state.copyWith(
            errorMessage: 'Não foi possível abrir o PDF do boleto',
          ));
        }
      } else {
        emit(state.copyWith(
          errorMessage: 'PDF do boleto não disponível',
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Erro ao abrir boleto: $e'));
    }
  }

  Future<void> copiarCodigoBarras(String boletoId) async {
    try {
      final boleto = state.boletos.firstWhere((b) => b.id == boletoId);
      
      // Priorizar identification_field (linha digitável) > barCode
      final texto = boleto.identificationField ?? boleto.barCode ?? '';
      
      if (texto.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: texto));
        emit(state.copyWith(successMessage: 'Código copiado com sucesso!'));
      } else {
        emit(state.copyWith(
          errorMessage: 'Código de barras não disponível',
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Erro ao copiar código: $e'));
    }
  }

  Future<void> compartilharBoleto(String boletoId) async {
    try {
      // TODO: Implementar compartilhamento com package share_plus
      // final boleto = state.boletos.firstWhere((b) => b.id == boletoId);
      // await Share.share('''
      // Boleto CondoGaia
      // Vencimento: ${boleto.dataVencimento.day.toString().padLeft(2, '0')}/${boleto.dataVencimento.month.toString().padLeft(2, '0')}/${boleto.dataVencimento.year}
      // Valor: R\$ ${boleto.valor.toStringAsFixed(2)}
      // Código: ${boleto.identificationField ?? boleto.barCode ?? 'N/A'}
      // ''');
      
      emit(state.copyWith(successMessage: 'Compartilhamento em breve disponível'));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Erro ao compartilhar boleto: $e'));
    }
  }
}
