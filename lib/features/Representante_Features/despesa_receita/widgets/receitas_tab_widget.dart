import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/despesa_receita_cubit.dart';
import '../cubit/despesa_receita_state.dart';
import '../models/receita_model.dart';
import '../../gestao_condominio/models/categoria_financeira_model.dart';
import 'shared_widgets.dart';
import 'base_tab_widget.dart';
import '../../../../../utils/input_formatters.dart';

class ReceitasTabWidget extends StatefulWidget {
  const ReceitasTabWidget({super.key});

  @override
  State<ReceitasTabWidget> createState() => _ReceitasTabWidgetState();
}

class _ReceitasTabWidgetState extends State<ReceitasTabWidget> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _qtdMesesController = TextEditingController();
  final _dataCreditoController = TextEditingController();
  final _palavraChaveController = TextEditingController();

  bool _filtrosExpandidos = true;
  bool _cadastroExpandido = false;
  bool _recorrente = false;

  // Filtros
  String? _filtroContaId;
  String? _filtroCategoriaId;
  String? _filtroSubcategoriaId;
  String? _filtroContaContabil;
  String _filtroTipo = 'Todos';

  // Cadastro
  String? _contaIdCadastro;
  String? _categoriaIdCadastro;
  String? _subcategoriaIdCadastro;
  String? _contaContabilCadastro;
  DateTime? _dataCredito;

  List<SubcategoriaFinanceira> _getSubcategorias(
    DespesaReceitaState state,
    String? catId,
  ) {
    if (catId == null) return [];
    final cat = state.categoriasReceita.where((c) => c.id == catId).toList();
    if (cat.isEmpty) return [];
    return cat.first.subcategorias;
  }

  // Edição
  String? _editandoId;

  static const List<String> _tiposReceita = ['Todos', 'Manual', 'Automático'];

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _qtdMesesController.dispose();
    _dataCreditoController.dispose();
    _palavraChaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DespesaReceitaCubit, DespesaReceitaState>(
      builder: (context, state) {
        final cubit = context.read<DespesaReceitaCubit>();

        // Preencher form ao entrar em modo edição
        if (state.receitaEditando != null &&
            _editandoId != state.receitaEditando!.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _preencherFormParaEdicao(state.receitaEditando!);
          });
        }

        return BaseTabWidget<Receita>(
          fabHeroTag: 'fab_receita',
          fabIcon: Icons.add,
          isEditing: _editandoId != null,
          titleAdd: 'Cadastrar Nova Receita',
          titleEdit: 'Editar Receita',
          filtrosExpandidos: _filtrosExpandidos,
          onToggleFiltros: () =>
              setState(() => _filtrosExpandidos = !_filtrosExpandidos),
          filtrosContent: _buildFiltrosContent(state, cubit),
          cadastroExpandido: _cadastroExpandido,
          onToggleCadastro: () =>
              setState(() => _cadastroExpandido = !_cadastroExpandido),
          cadastroContent: _buildCadastroForm(state, cubit),
          tableName: 'Receitas Registradas',
          items: state.receitas,
          isLoading: state.status == DespesaReceitaStatus.loading,
          emptyStateIcon: Icon(
            Icons.receipt_long,
            size: 48,
            color: Colors.grey.shade300,
          ),
          emptyStateText: 'Nenhuma receita encontrada',
          emptyStateSubtext: 'Use o botão + para cadastrar uma nova receita',
          tableHeader: _buildHeaderRow(state, cubit),
          itemBuilder: (context, state, cubit, item, index) =>
              _buildReceitaRow(item, index, state, cubit),
          tableFooterBuilder: (context, state, cubit) =>
              _buildRodape(state, cubit),
          onFabPressed: () {
            setState(() {
              _cadastroExpandido = true;
              if (_editandoId != null) _limparFormulario(cubit);
            });
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // FILTROS
  // ══════════════════════════════════════════════════════

  Widget _buildFiltrosContent(
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDropdownField(
          label: 'Conta',
          icon: Icons.account_balance,
          value: _filtroContaId,
          items: state.contas
              .map(
                (c) => DropdownMenuItem<String>(
                  value: c.id,
                  child: Text(c.banco, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _filtroContaId = v),
        ),
        const SizedBox(height: 10),
        buildDropdownField(
          label: 'Categoria',
          icon: Icons.category,
          value: _filtroCategoriaId,
          items: state.categoriasReceita
              .map(
                (c) => DropdownMenuItem<String>(
                  value: c.id,
                  child: Text(c.nome, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() {
            _filtroCategoriaId = v;
            _filtroSubcategoriaId = null;
          }),
        ),
        const SizedBox(height: 10),
        buildDropdownField(
          label: 'Subcategoria',
          icon: Icons.subdirectory_arrow_right,
          value: _filtroSubcategoriaId,
          items: _getSubcategorias(state, _filtroCategoriaId)
              .map<DropdownMenuItem<String>>(
                (s) => DropdownMenuItem<String>(
                  value: s.id,
                  child: Text(s.nome, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _filtroSubcategoriaId = v),
        ),
        const SizedBox(height: 10),
        buildDropdownField(
          label: 'Conta Contábil',
          icon: Icons.book,
          value: _filtroContaContabil,
          items: ['Controle', 'Fundo Reserva', 'Obras']
              .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _filtroContaContabil = v),
        ),
        const SizedBox(height: 10),
        buildDropdownField(
          label: 'Tipo',
          icon: Icons.tune,
          value: _filtroTipo,
          items: _tiposReceita
              .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _filtroTipo = v ?? 'Todos'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _palavraChaveController,
          decoration: InputDecoration(
            labelText: 'Palavra Chave',
            prefixIcon: const Icon(Icons.search, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: state.status == DespesaReceitaStatus.loading
                      ? null
                      : () {
                          cubit.atualizarFiltros(
                            contaId: _filtroContaId,
                            categoriaId: _filtroCategoriaId,
                            subcategoriaId: _filtroSubcategoriaId,
                            contaContabil: _filtroContaContabil,
                            tipoReceita: _filtroTipo,
                            palavraChave: _palavraChaveController.text,
                          );
                          cubit.pesquisarReceitas();
                        },
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text(
                    'Pesquisar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _filtroContaId = null;
                    _filtroCategoriaId = null;
                    _filtroSubcategoriaId = null;
                    _filtroContaContabil = null;
                    _filtroTipo = 'Todos';
                    _palavraChaveController.clear();
                  });
                  cubit.atualizarFiltros(
                    contaId: '',
                    categoriaId: '',
                    subcategoriaId: '',
                    contaContabil: '',
                    tipoReceita: 'Todos',
                    palavraChave: '',
                  );
                  cubit.pesquisarReceitas();
                },
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Limpar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),            icon: const Icon(Icons.search, size: 18),
            label: const Text(
              'Pesquisar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  // FORMULÁRIO DE CADASTRO / EDIÇÃO
  // ══════════════════════════════════════════════════════

  Widget _buildCadastroForm(
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDropdownField(
          label: 'Conta',
          icon: Icons.account_balance,
          value: _contaIdCadastro,
          items: state.contas
              .map(
                (c) => DropdownMenuItem<String>(
                  value: c.id,
                  child: Text(c.banco, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _contaIdCadastro = v),
        ),
        const SizedBox(height: 10),
        buildDropdownField(
          label: 'Categoria',
          icon: Icons.category,
          value: _categoriaIdCadastro,
          items: state.categoriasReceita
              .map(
                (c) => DropdownMenuItem<String>(
                  value: c.id,
                  child: Text(c.nome, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() {
            _categoriaIdCadastro = v;
            _subcategoriaIdCadastro = null;
          }),
        ),
        const SizedBox(height: 10),
        buildDropdownField(
          label: 'Subcategoria',
          icon: Icons.subdirectory_arrow_right,
          value: _subcategoriaIdCadastro,
          items: _getSubcategorias(state, _categoriaIdCadastro)
              .map<DropdownMenuItem<String>>(
                (s) => DropdownMenuItem<String>(
                  value: s.id,
                  child: Text(s.nome, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _subcategoriaIdCadastro = v),
        ),
        const SizedBox(height: 10),
        buildDropdownField(
          label: 'Conta Contábil',
          icon: Icons.book,
          value: _contaContabilCadastro,
          items: ['Controle', 'Fundo Reserva', 'Obras']
              .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _contaContabilCadastro = v),
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),

        // Descrição
        TextField(
          controller: _descricaoController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Descrição',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [BrazilianCurrencyFormatter()],
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)',
                  prefixIcon: const Icon(Icons.attach_money, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildDateField(
                context: context,
                label: 'Data do Crédito',
                controller: _dataCreditoController,
                onChanged: (d) => setState(() => _dataCredito = d),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        buildRecorrenciaSection(
          recorrente: _recorrente,
          onRecorrenteChanged: (v) => setState(() => _recorrente = v),
          qtdMesesController: _qtdMesesController,
        ),
        const SizedBox(height: 16),

        if (_editandoId != null)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _limparFormulario(cubit),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: _buildSalvarButton(state, cubit)),
            ],
          )
        else
          _buildSalvarButton(state, cubit),
      ],
    );
  }

  Widget _buildSalvarButton(
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
  ) {
    final isEditing = _editandoId != null;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: state.isSaving ? null : () => _salvar(cubit),
        icon: state.isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(isEditing ? Icons.save_as : Icons.save, size: 20),
        label: Text(
          state.isSaving
              ? 'Salvando...'
              : (isEditing ? 'Salvar Alterações' : 'Salvar Receita'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isEditing
              ? Colors.orange.shade700
              : Colors.green.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // REGISTROS (TABELA)
  // ══════════════════════════════════════════════════════

  Widget _buildHeaderRow(DespesaReceitaState state, DespesaReceitaCubit cubit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: kPrimaryColor,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: GestureDetector(
              onTap: () {
                cubit.selecionarTodasReceitas(
                  state.receitas
                      .where((r) => r.id != null)
                      .map((r) => r.id!)
                      .toList(),
                );
              },
              child: Icon(
                state.receitas.isNotEmpty &&
                        state.receitas.every(
                          (r) => state.receitasSelecionadas.contains(r.id),
                        )
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _headerCell('Descrição', flex: 3),
          _headerCell('Categoria', flex: 2),
          _headerCell('Crédito', flex: 2),
          _headerCell('Valor', flex: 2),
          _headerCell('Tipo', flex: 1),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildReceitaRow(
    Receita r,
    int index,
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
  ) {
    final isSelected = state.receitasSelecionadas.contains(r.id);
    final dataStr = r.dataCredito != null
        ? '${r.dataCredito!.day.toString().padLeft(2, '0')}/${r.dataCredito!.month.toString().padLeft(2, '0')}/${r.dataCredito!.year}'
        : '--';
    final valorStr = 'R\$ ${r.valor.toStringAsFixed(2).replaceAll('.', ',')}';

    return GestureDetector(
      onTap: () {
        if (r.id != null) cubit.toggleReceitaSelecionada(r.id!);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? kAccentColor.withOpacity(0.06)
              : (index.isEven ? Colors.white : Colors.grey.shade50),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
            left: isSelected
                ? const BorderSide(color: kAccentColor, width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 18,
                color: isSelected ? kAccentColor : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.descricao ?? 'Sem descrição',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (r.contaContabil != null)
                    Text(
                      r.contaContabil!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.categoriaNome ?? '--',
                    style: const TextStyle(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (r.subcategoriaNome != null)
                    Text(
                      r.subcategoriaNome!,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(dataStr, style: const TextStyle(fontSize: 11)),
            ),
            Expanded(
              flex: 2,
              child: Text(
                valorStr,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: r.recorrente
                      ? Colors.orange.withOpacity(0.12)
                      : Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  r.recorrente ? 'Rec.' : r.tipo,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: r.recorrente ? Colors.orange.shade700 : kAccentColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // RODAPÉ COM AÇÕES
  // ══════════════════════════════════════════════════════

  Widget _buildRodape(DespesaReceitaState state, DespesaReceitaCubit cubit) {
    final qtd = state.receitasSelecionadas.length;
    final total = state.receitas
        .where((r) => state.receitasSelecionadas.contains(r.id))
        .fold(0.0, (sum, r) => sum + r.valor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (qtd > 0) ...[
            SizedBox(
              height: 32,
              child: ElevatedButton.icon(
                onPressed: qtd == 1
                    ? () {
                        final receita = state.receitas.firstWhere(
                          (r) => state.receitasSelecionadas.contains(r.id),
                        );
                        cubit.iniciarEdicaoReceita(receita);
                        setState(() => _cadastroExpandido = true);
                      }
                    : null,
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('Editar', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 32,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showConfirmDeleteDialog(
                    context,
                    quantidade: qtd,
                  );
                  if (confirm) cubit.excluirReceitasSelecionadas();
                },
                icon: const Icon(Icons.delete_outline, size: 14),
                label: const Text('Excluir', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
          const Spacer(),
          Text(
            '$qtd selecionado${qtd != 1 ? 's' : ''}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Text(
            'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════

  void _preencherFormParaEdicao(Receita r) {
    setState(() {
      _editandoId = r.id;
      _contaIdCadastro = r.contaId;
      _categoriaIdCadastro = r.categoriaId;
      _subcategoriaIdCadastro = r.subcategoriaId;
      _contaContabilCadastro = r.contaContabil;
      _descricaoController.text = r.descricao ?? '';
      _valorController.text = r.valor.toStringAsFixed(2).replaceAll('.', ',');
      // Force format with thousands separators
      _valorController.value = BrazilianCurrencyFormatter().formatEditUpdate(
        TextEditingValue.empty,
        _valorController.value,
      );
      _dataCredito = r.dataCredito;
      if (_dataCredito != null) {
        _dataCreditoController.text =
            '${_dataCredito!.day.toString().padLeft(2, '0')}/${_dataCredito!.month.toString().padLeft(2, '0')}/${_dataCredito!.year}';
      } else {
        _dataCreditoController.clear();
      }
      _recorrente = r.recorrente;
      _qtdMesesController.text = r.qtdMeses != null
          ? r.qtdMeses.toString()
          : '';
      _cadastroExpandido = true;
    });
  }

  void _salvar(DespesaReceitaCubit cubit) {
    // Validação
    final valorStr = _valorController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final valor = double.tryParse(valorStr) ?? 0;

    if (valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um valor maior que zero.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_dataCredito == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a data do crédito.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final receita = Receita(
      id: _editandoId,
      condominioId: cubit.condominioId,
      contaId: _contaIdCadastro,
      categoriaId: _categoriaIdCadastro,
      subcategoriaId: _subcategoriaIdCadastro,
      contaContabil: _contaContabilCadastro,
      descricao: _descricaoController.text,
      valor: valor,
      dataCredito: _dataCredito,
      recorrente: _recorrente,
      qtdMeses: int.tryParse(_qtdMesesController.text),
    );
    cubit.salvarReceita(receita);
    _limparFormulario(cubit);
  }

  void _limparFormulario(DespesaReceitaCubit cubit) {
    cubit.cancelarEdicaoReceita();
    _descricaoController.clear();
    _valorController.clear();
    _qtdMesesController.clear();
    _dataCreditoController.clear();
    setState(() {
      _editandoId = null;
      _dataCredito = null;
      _recorrente = false;
      _contaIdCadastro = null;
      _categoriaIdCadastro = null;
      _subcategoriaIdCadastro = null;
      _contaContabilCadastro = null;
      _cadastroExpandido = false;
    });
  }
}
