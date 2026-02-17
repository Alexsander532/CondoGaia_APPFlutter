import 'package:bloc/bloc.dart';
import '../models/despesa_model.dart';
import '../models/receita_model.dart';
import '../models/transferencia_model.dart';
import '../services/despesa_receita_service.dart';
import 'despesa_receita_state.dart';

class DespesaReceitaCubit extends Cubit<DespesaReceitaState> {
  final DespesaReceitaService _service;
  final String condominioId;

  DespesaReceitaCubit({
    required DespesaReceitaService service,
    required this.condominioId,
  }) : _service = service,
       super(
         DespesaReceitaState(
           mesSelecionado: DateTime.now().month,
           anoSelecionado: DateTime.now().year,
         ),
       );

  /// Carregamento inicial de todos os dados
  Future<void> carregarDados() async {
    emit(state.copyWith(status: DespesaReceitaStatus.loading));
    try {
      final contas = await _service.listarContas(condominioId);
      final categorias = await _service.listarCategorias(condominioId);
      final despesas = await _service.listarDespesas(
        condominioId,
        mes: state.mesSelecionado,
        ano: state.anoSelecionado,
      );
      final receitas = await _service.listarReceitas(
        condominioId,
        mes: state.mesSelecionado,
        ano: state.anoSelecionado,
      );
      final transferencias = await _service.listarTransferencias(
        condominioId,
        mes: state.mesSelecionado,
        ano: state.anoSelecionado,
      );

      emit(
        state.copyWith(
          status: DespesaReceitaStatus.success,
          contas: contas,
          categorias: categorias,
          despesas: despesas,
          receitas: receitas,
          transferencias: transferencias,
          itensSelecionados: {},
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DespesaReceitaStatus.error,
          errorMessage: e.toString(),
        ),
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
    String? contaId,
    String? categoriaId,
    String? subcategoriaId,
    String? palavraChave,
    String? contaContabil,
    String? tipoReceita,
    String? contaCreditoId,
  }) {
    emit(
      state.copyWith(
        filtroContaId: contaId ?? '',
        filtroCategoriaId: categoriaId ?? '',
        filtroSubcategoriaId: subcategoriaId ?? '',
        filtroPalavraChave: palavraChave ?? '',
        filtroContaContabil: contaContabil ?? '',
        filtroContaCreditoId: contaCreditoId ?? state.filtroContaCreditoId,
        filtroTipoReceita: tipoReceita ?? state.filtroTipoReceita,
      ),
    );
  }

  Future<void> pesquisarDespesas() async {
    emit(state.copyWith(status: DespesaReceitaStatus.loading));
    try {
      final despesas = await _service.listarDespesas(
        condominioId,
        mes: state.mesSelecionado,
        ano: state.anoSelecionado,
        contaId: state.filtroContaId,
        categoriaId: state.filtroCategoriaId,
        subcategoriaId: state.filtroSubcategoriaId,
        palavraChave: state.filtroPalavraChave,
      );
      emit(
        state.copyWith(
          status: DespesaReceitaStatus.success,
          despesas: despesas,
          itensSelecionados: {},
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DespesaReceitaStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> pesquisarReceitas() async {
    emit(state.copyWith(status: DespesaReceitaStatus.loading));
    try {
      final receitas = await _service.listarReceitas(
        condominioId,
        mes: state.mesSelecionado,
        ano: state.anoSelecionado,
        contaId: state.filtroContaId,
        contaContabil: state.filtroContaContabil,
        tipo: state.filtroTipoReceita,
      );
      emit(
        state.copyWith(
          status: DespesaReceitaStatus.success,
          receitas: receitas,
          itensSelecionados: {},
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DespesaReceitaStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> pesquisarTransferencias() async {
    emit(state.copyWith(status: DespesaReceitaStatus.loading));
    try {
      final transferencias = await _service.listarTransferencias(
        condominioId,
        mes: state.mesSelecionado,
        ano: state.anoSelecionado,
      );
      emit(
        state.copyWith(
          status: DespesaReceitaStatus.success,
          transferencias: transferencias,
          itensSelecionados: {},
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DespesaReceitaStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // CRUD DESPESAS
  // ============================================================

  Future<void> salvarDespesa(Despesa despesa) async {
    emit(state.copyWith(isSaving: true));
    try {
      await _service.salvarDespesa(despesa);
      emit(state.copyWith(isSaving: false));
      await pesquisarDespesas();
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  Future<void> excluirDespesasSelecionadas() async {
    if (state.itensSelecionados.isEmpty) return;
    emit(state.copyWith(status: DespesaReceitaStatus.loading));
    try {
      await _service.excluirDespesasMultiplas(state.itensSelecionados.toList());
      await pesquisarDespesas();
    } catch (e) {
      emit(
        state.copyWith(
          status: DespesaReceitaStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // CRUD RECEITAS
  // ============================================================

  Future<void> salvarReceita(Receita receita) async {
    emit(state.copyWith(isSaving: true));
    try {
      await _service.salvarReceita(receita);
      emit(state.copyWith(isSaving: false));
      await pesquisarReceitas();
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  Future<void> excluirReceitasSelecionadas() async {
    if (state.itensSelecionados.isEmpty) return;
    emit(state.copyWith(status: DespesaReceitaStatus.loading));
    try {
      await _service.excluirReceitasMultiplas(state.itensSelecionados.toList());
      await pesquisarReceitas();
    } catch (e) {
      emit(
        state.copyWith(
          status: DespesaReceitaStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // CRUD TRANSFERÊNCIAS
  // ============================================================

  Future<void> salvarTransferencia(Transferencia transferencia) async {
    emit(state.copyWith(isSaving: true));
    try {
      await _service.salvarTransferencia(transferencia);
      emit(state.copyWith(isSaving: false));
      await pesquisarTransferencias();
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  Future<void> excluirTransferenciasSelecionadas() async {
    if (state.itensSelecionados.isEmpty) return;
    emit(state.copyWith(status: DespesaReceitaStatus.loading));
    try {
      await _service.excluirTransferenciasMultiplas(
        state.itensSelecionados.toList(),
      );
      await pesquisarTransferencias();
    } catch (e) {
      emit(
        state.copyWith(
          status: DespesaReceitaStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
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
  // UI STATE
  // ============================================================

  void toggleCadastro() {
    emit(state.copyWith(cadastroExpandido: !state.cadastroExpandido));
  }
}
