import 'package:bloc/bloc.dart';
import '../models/despesa_model.dart';
import '../models/receita_model.dart';
import '../models/transferencia_model.dart';
import '../services/despesa_receita_service.dart';
import 'despesa_receita_state.dart';
import 'package:image_picker/image_picker.dart';

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
      final categorias = await _service.listarCategorias();
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

      // Buscar saldo anterior (mês passado)
      final saldoAnterior = await _service.calcularSaldoAnterior(
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
          saldoAnterior: saldoAnterior,
          despesasSelecionadas: {},
          receitasSelecionadas: {},
          transferenciasSelecionadas: {},
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
    String? contaDebitoId,
  }) {
    emit(
      state.copyWith(
        filtroContaId: contaId ?? '',
        filtroCategoriaId: categoriaId ?? '',
        filtroSubcategoriaId: subcategoriaId ?? '',
        filtroPalavraChave: palavraChave ?? '',
        filtroContaContabil: contaContabil ?? '',
        filtroContaCreditoId: contaCreditoId ?? state.filtroContaCreditoId,
        filtroContaDebitoId: contaDebitoId ?? state.filtroContaDebitoId,
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
          despesasSelecionadas: {},
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
        categoriaId: state.filtroCategoriaId,
        subcategoriaId: state.filtroSubcategoriaId,
        contaContabil: state.filtroContaContabil,
        tipo: state.filtroTipoReceita,
        palavraChave: state.filtroPalavraChave,
      );
      emit(
        state.copyWith(
          status: DespesaReceitaStatus.success,
          receitas: receitas,
          receitasSelecionadas: {},
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
        contaDebitoId: state.filtroContaDebitoId,
        contaCreditoId: state.filtroContaCreditoId,
        palavraChave: state.filtroPalavraChave,
      );
      emit(
        state.copyWith(
          status: DespesaReceitaStatus.success,
          transferencias: transferencias,
          transferenciasSelecionadas: {},
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
      String? fotoUrl = despesa.fotoUrl;

      // Se houver uma nova imagem selecionada, faz o upload primeiro
      if (state.imagemArquivo != null) {
        fotoUrl = await _service.uploadFoto(state.imagemArquivo!);
      }

      final despesaFinal = despesa.copyWith(fotoUrl: fotoUrl);

      // Lógica de Recorrência (apenas para novos registros)
      if (despesa.id == null && despesa.recorrente) {
        final int meses = (despesa.qtdMeses != null && despesa.qtdMeses! > 0)
            ? despesa.qtdMeses!
            : 12; // Padrão 12 meses para "infinito"

        final List<Despesa> despesasParaSalvar = [];
        final dataBase = despesaFinal.dataVencimento ?? DateTime.now();

        for (int i = 0; i < meses; i++) {
          final novaData = DateTime(
            dataBase.year,
            dataBase.month + i,
            dataBase.day,
          );
          despesasParaSalvar.add(despesaFinal.copyWith(dataVencimento: novaData));
        }

        await _service.salvarDespesasMultiplas(despesasParaSalvar);
      } else {
        // Fluxo normal (adição simples ou edição)
        await _service.salvarDespesa(despesaFinal);
      }

      emit(
        state.copyWith(
          isSaving: false,
          clearDespesaEditando: true,
          clearImagemArquivo: true,
          successMessage: 'Despesa salva com sucesso!',
        ),
      );
      await pesquisarDespesas();
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  Future<void> excluirDespesasSelecionadas() async {
    if (state.despesasSelecionadas.isEmpty) return;
    emit(state.copyWith(status: DespesaReceitaStatus.loading));
    try {
      await _service.excluirDespesasMultiplas(
        state.despesasSelecionadas.toList(),
      );
      await pesquisarDespesas();
      emit(state.copyWith(successMessage: 'Despesas excluídas com sucesso!'));
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
      final receitaFinal = receita;

      // Lógica de Recorrência (apenas para novos registros)
      if (receita.id == null && receita.recorrente) {
        // Se não informar a quantidade de meses, gera 12 meses por padrão
        final int meses = (receita.qtdMeses != null && receita.qtdMeses! > 0)
            ? receita.qtdMeses!
            : 12;

        final List<Receita> receitasParaSalvar = [];
        final dataBase = receitaFinal.dataCredito ?? DateTime.now();

        for (int i = 0; i < meses; i++) {
          final novaData = DateTime(
            dataBase.year,
            dataBase.month + i,
            dataBase.day,
          );
          receitasParaSalvar.add(receitaFinal.copyWith(dataCredito: novaData));
        }

        await _service.salvarReceitasMultiplas(receitasParaSalvar);
      } else {
        // Fluxo normal (adição simples ou edição)
        await _service.salvarReceita(receitaFinal);
      }

      emit(
        state.copyWith(
          isSaving: false,
          clearReceitaEditando: true,
          clearImagemArquivo: true,
          successMessage: 'Receita salva com sucesso!',
        ),
      );
      await pesquisarReceitas();
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  Future<void> excluirReceitasSelecionadas() async {
    if (state.receitasSelecionadas.isEmpty) return;
    emit(state.copyWith(status: DespesaReceitaStatus.loading));
    try {
      await _service.excluirReceitasMultiplas(
        state.receitasSelecionadas.toList(),
      );
      await pesquisarReceitas();
      emit(state.copyWith(successMessage: 'Receitas excluídas com sucesso!'));
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
      emit(state.copyWith(
        isSaving: false,
        clearTransferenciaEditando: true,
        successMessage: 'Transferência realizada com sucesso!',
      ));
      await pesquisarTransferencias();
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  Future<void> excluirTransferenciasSelecionadas() async {
    if (state.transferenciasSelecionadas.isEmpty) return;
    emit(state.copyWith(status: DespesaReceitaStatus.loading));
    try {
      await _service.excluirTransferenciasMultiplas(
        state.transferenciasSelecionadas.toList(),
      );
      await pesquisarTransferencias();
      emit(state.copyWith(successMessage: 'Transferências excluídas com sucesso!'));
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
  // SELEÇÃO POR ABA
  // ============================================================

  void toggleDespesaSelecionada(String id) {
    final current = Set<String>.from(state.despesasSelecionadas);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    emit(state.copyWith(despesasSelecionadas: current));
  }

  void selecionarTodasDespesas(List<String> ids) {
    final allSelected = ids.every(
      (id) => state.despesasSelecionadas.contains(id),
    );
    if (allSelected) {
      emit(state.copyWith(despesasSelecionadas: {}));
    } else {
      emit(state.copyWith(despesasSelecionadas: ids.toSet()));
    }
  }

  void toggleReceitaSelecionada(String id) {
    final current = Set<String>.from(state.receitasSelecionadas);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    emit(state.copyWith(receitasSelecionadas: current));
  }

  void selecionarTodasReceitas(List<String> ids) {
    final allSelected = ids.every(
      (id) => state.receitasSelecionadas.contains(id),
    );
    if (allSelected) {
      emit(state.copyWith(receitasSelecionadas: {}));
    } else {
      emit(state.copyWith(receitasSelecionadas: ids.toSet()));
    }
  }

  void toggleTransferenciaSelecionada(String id) {
    final current = Set<String>.from(state.transferenciasSelecionadas);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    emit(state.copyWith(transferenciasSelecionadas: current));
  }

  void selecionarTodasTransferencias(List<String> ids) {
    final allSelected = ids.every(
      (id) => state.transferenciasSelecionadas.contains(id),
    );
    if (allSelected) {
      emit(state.copyWith(transferenciasSelecionadas: {}));
    } else {
      emit(state.copyWith(transferenciasSelecionadas: ids.toSet()));
    }
  }

  // ============================================================
  // MODO EDIÇÃO
  // ============================================================

  void iniciarEdicaoDespesa(Despesa despesa) {
    emit(state.copyWith(despesaEditando: despesa));
  }

  void cancelarEdicaoDespesa() {
    emit(state.copyWith(clearDespesaEditando: true));
  }

  void iniciarEdicaoReceita(Receita receita) {
    emit(state.copyWith(receitaEditando: receita));
  }

  void cancelarEdicaoReceita() {
    emit(state.copyWith(clearReceitaEditando: true));
  }

  void iniciarEdicaoTransferencia(Transferencia transferencia) {
    emit(state.copyWith(transferenciaEditando: transferencia));
  }

  void cancelarEdicaoTransferencia() {
    emit(state.copyWith(clearTransferenciaEditando: true));
  }

  // ============================================================
  // IMAGENS (FOTOS)
  // ============================================================

  Future<void> selecionarImagem(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 70, // Reduz qualidade para economizar storage e banda
        maxWidth: 1200,
      );

      if (image != null) {
        emit(state.copyWith(imagemArquivo: image));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Erro ao selecionar imagem: $e'));
    }
  }

  void removerImagem() {
    emit(state.copyWith(clearImagemArquivo: true));
  }

  void removerFotoExistenteDespesa() {
    if (state.despesaEditando != null) {
      emit(
        state.copyWith(
          despesaEditando: state.despesaEditando!.copyWith(clearFotoUrl: true),
        ),
      );
    }
  }


  // ============================================================
  // UI STATE
  // ============================================================

  void toggleCadastro() {
    emit(state.copyWith(cadastroExpandido: !state.cadastroExpandido));
  }

  void limparErro() {
    emit(state.copyWith(clearErrorMessage: true));
  }

  void limparSucesso() {
    emit(state.copyWith(clearSuccessMessage: true));
  }
}
