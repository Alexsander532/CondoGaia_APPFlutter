import 'package:flutter_bloc/flutter_bloc.dart';
import 'relatorios_state.dart';

class RelatoriosCubit extends Cubit<RelatoriosState> {
  final String condominioId;

  RelatoriosCubit({required this.condominioId})
    : super(const RelatoriosState());

  /// Lista de tipos de relatório disponíveis
  static const List<String> tiposRelatorio = [
    'Boleto',
    'Despesas',
    'Receitas',
    'DRE',
    'Morador/Unid',
    'Acordo',
    'E-Mail',
    'Portaria',
    'Contas Bancárias',
    'Demonstrativo p/ Balancete',
    'Livro Diário de Lançamento',
    'Inadimplência',
  ];

  /// Troca o tipo de relatório selecionado
  void trocarTipoRelatorio(String tipo) {
    emit(state.copyWith(tipoRelatorio: tipo, status: RelatoriosStatus.loaded));
  }
}
