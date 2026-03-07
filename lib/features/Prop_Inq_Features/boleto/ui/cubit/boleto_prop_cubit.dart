import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/boleto_prop_entity.dart';
import 'boleto_prop_state.dart';

class BoletoPropCubit extends Cubit<BoletoPropState> {
  BoletoPropCubit()
    : super(
        BoletoPropState(
          mesSelecionado: DateTime.now().month,
          anoSelecionado: DateTime.now().year,
        ),
      );

  // ============================================================
  // CARREGAMENTO INICIAL (usando dados mock por enquanto)
  // ============================================================

  Future<void> carregarBoletos() async {
    emit(state.copyWith(status: BoletoPropStatus.loading));
    try {
      // TODO: Substituir por chamada real via UseCase
      // Dados mock para visualização da UI
      final boletosMock = [
        BoletoPropEntity(
          id: '1',
          dataVencimento: DateTime(2022, 1, 29),
          valor: 400.00,
          status: 'Ativo',
          tipo: 'Taxa Condominial',
          codigoBarras:
              '23793.38128 60000.000003 00000.000400 1 84340000040000',
          descricao: 'Taxa Condominial',
          isVencido: false,
        ),
        BoletoPropEntity(
          id: '2',
          dataVencimento: DateTime(2021, 12, 9),
          valor: 250.00,
          status: 'Ativo',
          tipo: 'Avulso',
          codigoBarras:
              '23793.38128 60000.000003 00000.000250 1 84340000025000',
          descricao: 'Avulso',
          isVencido: true,
        ),
        BoletoPropEntity(
          id: '3',
          dataVencimento: DateTime(2022, 1, 29),
          valor: 400.00,
          status: 'Pago',
          tipo: 'Taxa Condominial',
          codigoBarras:
              '23793.38128 60000.000003 00000.000400 1 84340000040000',
          descricao: 'Taxa Condominial',
          isVencido: false,
        ),
        BoletoPropEntity(
          id: '4',
          dataVencimento: DateTime(2021, 12, 9),
          valor: 250.00,
          status: 'Pago',
          tipo: 'Acordo',
          codigoBarras:
              '23793.38128 60000.000003 00000.000250 1 84340000025000',
          descricao: 'Acordo',
          isVencido: false,
        ),
        BoletoPropEntity(
          id: '5',
          dataVencimento: DateTime(2021, 10, 9),
          valor: 250.00,
          status: 'Ativo',
          tipo: 'Avulso',
          codigoBarras: null,
          descricao: 'Avulso',
          isVencido: true,
        ),
      ];

      emit(
        state.copyWith(status: BoletoPropStatus.success, boletos: boletosMock),
      );
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
  // FILTRO
  // ============================================================

  void alterarFiltro(String filtro) {
    emit(state.copyWith(filtroSelecionado: filtro, clearBoletoExpandido: true));
  }

  // ============================================================
  // EXPANDIR/COLAPSAR BOLETO
  // ============================================================

  void toggleBoletoExpandido(String boletoId) {
    if (state.boletoExpandidoId == boletoId) {
      emit(state.copyWith(clearBoletoExpandido: true));
    } else {
      emit(state.copyWith(boletoExpandidoId: boletoId));
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
  }

  void proximoMes() {
    int mes = state.mesSelecionado + 1;
    int ano = state.anoSelecionado;
    if (mes > 12) {
      mes = 1;
      ano++;
    }
    emit(state.copyWith(mesSelecionado: mes, anoSelecionado: ano));
  }

  // ============================================================
  // SEÇÕES EXPANSÍVEIS
  // ============================================================

  void toggleComposicaoBoleto() {
    emit(
      state.copyWith(
        composicaoBoletoExpandida: !state.composicaoBoletoExpandida,
      ),
    );
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

  void verBoleto(String boletoId) {
    // TODO: Implementar abertura do PDF do boleto
  }

  void copiarCodigoBarras(String codigoBarras) {
    // TODO: Implementar cópia para clipboard
  }

  void compartilharBoleto(String boletoId) {
    // TODO: Implementar compartilhamento
  }
}
