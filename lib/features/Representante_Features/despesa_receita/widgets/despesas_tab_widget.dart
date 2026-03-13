import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/despesa_receita_cubit.dart';
import '../cubit/despesa_receita_state.dart';
import '../models/despesa_model.dart';
import 'shared_widgets.dart';
import 'base_tab_widget.dart';
import '../../../../../utils/input_formatters.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class DespesasTabWidget extends StatefulWidget {
  const DespesasTabWidget({super.key});

  @override
  State<DespesasTabWidget> createState() => _DespesasTabWidgetState();
}

class _DespesasTabWidgetState extends State<DespesasTabWidget> {
  // Cadastro controllers
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _linkController = TextEditingController();
  final _qtdMesesController = TextEditingController();
  final _dataVencimentoController = TextEditingController();

  // Filtro controllers
  final _palavraChaveController = TextEditingController();

  bool _filtrosExpandidos = true;
  bool _cadastroExpandido = false;
  bool _recorrente = false;
  bool _meAvisar = false;

  String? _contaIdCadastro;
  String? _categoriaIdCadastro;
  String? _subcategoriaIdCadastro;
  DateTime? _dataVencimento;

  // Filtros
  String? _filtroContaId;
  String? _filtroCategoriaId;
  String? _filtroSubcategoriaId;

  // Edição
  String? _editandoId;

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _linkController.dispose();
    _qtdMesesController.dispose();
    _palavraChaveController.dispose();
    _dataVencimentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DespesaReceitaCubit, DespesaReceitaState>(
      builder: (context, state) {
        final cubit = context.read<DespesaReceitaCubit>();

        // Quando o cubit emitir um despesaEditando, preencher o form
        if (state.despesaEditando != null &&
            _editandoId != state.despesaEditando!.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _preencherFormParaEdicao(state.despesaEditando!);
          });
        }

        return BaseTabWidget<Despesa>(
          fabHeroTag: 'fab_despesa',
          fabIcon: Icons.add,
          isEditing: _editandoId != null,
          titleAdd: 'Cadastrar Nova Despesa',
          titleEdit: 'Editar Despesa',
          filtrosExpandidos: _filtrosExpandidos,
          onToggleFiltros: () =>
              setState(() => _filtrosExpandidos = !_filtrosExpandidos),
          filtrosContent: _buildFiltrosContent(state, cubit),
          cadastroExpandido: _cadastroExpandido,
          onToggleCadastro: () =>
              setState(() => _cadastroExpandido = !_cadastroExpandido),
          cadastroContent: _buildCadastroForm(state, cubit),
          tableName: 'Despesas Registradas',
          items: state.despesas,
          isLoading: state.status == DespesaReceitaStatus.loading,
          emptyStateIcon: Icon(
            Icons.receipt_long,
            size: 48,
            color: Colors.grey.shade300,
          ),
          emptyStateText: 'Nenhuma despesa encontrada',
          emptyStateSubtext: 'Use o botão + para cadastrar uma nova despesa',
          tableHeader: _buildHeaderRow(state, cubit),
          itemBuilder: (context, state, cubit, item, index) =>
              _buildDespesaRow(item, index, state, cubit),
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
          items: state.categoriasDespesa
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
                            palavraChave: _palavraChaveController.text,
                          );
                          cubit.pesquisarDespesas();
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
                    _palavraChaveController.clear();
                  });
                  cubit.atualizarFiltros(
                    contaId: '',
                    categoriaId: '',
                    subcategoriaId: '',
                    palavraChave: '',
                  );
                  cubit.pesquisarDespesas();
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
          items: state.categoriasDespesa
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

        // Valor e Vencimento em row
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
                label: 'Data Vencimento',
                controller: _dataVencimentoController,
                onChanged: (d) => setState(() => _dataVencimento = d),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Recorrente
        buildRecorrenciaSection(
          recorrente: _recorrente,
          onRecorrenteChanged: (v) => setState(() => _recorrente = v),
          qtdMesesController: _qtdMesesController,
          showMeAvisar: true,
          meAvisar: _meAvisar,
          onMeAvisarChanged: (v) => setState(() => _meAvisar = v),
        ),
        const SizedBox(height: 10),

        // Link
        TextField(
          controller: _linkController,
          decoration: InputDecoration(
            labelText: 'Link (opcional)',
            prefixIcon: const Icon(Icons.link, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),

        // Seção de Foto
        _buildFotoSection(state, cubit),
        const SizedBox(height: 16),

        // Botões de ação
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
              : (isEditing ? 'Salvar Alterações' : 'Salvar Despesa'),
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
                cubit.selecionarTodasDespesas(
                  state.despesas
                      .where((d) => d.id != null)
                      .map((d) => d.id!)
                      .toList(),
                );
              },
              child: Icon(
                state.despesas.isNotEmpty &&
                        state.despesas.every(
                          (d) => state.despesasSelecionadas.contains(d.id),
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
          _headerCell('Vencimento', flex: 2),
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

  Widget _buildDespesaRow(
    Despesa d,
    int index,
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
  ) {
    final isSelected = state.despesasSelecionadas.contains(d.id);
    final dataStr = d.dataVencimento != null
        ? '${d.dataVencimento!.day.toString().padLeft(2, '0')}/${d.dataVencimento!.month.toString().padLeft(2, '0')}/${d.dataVencimento!.year}'
        : '--';
    final valorStr = 'R\$ ${d.valor.toStringAsFixed(2).replaceAll('.', ',')}';

    return GestureDetector(
      onTap: () {
        if (d.id != null) cubit.toggleDespesaSelecionada(d.id!);
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
                    d.descricao ?? 'Sem descrição',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (d.contaNome != null)
                    Text(
                      d.contaNome!,
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
              child: Text(
                d.categoriaNome ?? '--',
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
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
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: d.recorrente
                      ? Colors.orange.withOpacity(0.12)
                      : Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  d.recorrente ? 'Rec.' : d.tipo,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: d.recorrente ? Colors.orange.shade700 : kAccentColor,
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
    final qtd = state.despesasSelecionadas.length;
    final total = state.despesas
        .where((d) => state.despesasSelecionadas.contains(d.id))
        .fold(0.0, (sum, d) => sum + d.valor);

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
                        final despesa = state.despesas.firstWhere(
                          (d) => state.despesasSelecionadas.contains(d.id),
                        );
                        cubit.iniciarEdicaoDespesa(despesa);
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
                  if (confirm) cubit.excluirDespesasSelecionadas();
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

  List<dynamic> _getSubcategorias(DespesaReceitaState state, String? catId) {
    if (catId == null) return [];
    final cats = state.categoriasDespesa.where((c) => c.id == catId).toList();
    if (cats.isEmpty) return [];
    return cats.first.subcategorias;
  }

  void _preencherFormParaEdicao(Despesa d) {
    setState(() {
      _editandoId = d.id;
      _contaIdCadastro = d.contaId;
      _categoriaIdCadastro = d.categoriaId;
      _subcategoriaIdCadastro = d.subcategoriaId;
      _descricaoController.text = d.descricao ?? '';
      _valorController.text = d.valor.toStringAsFixed(2).replaceAll('.', ',');
      // Force format with thousands separators
      _valorController.value = BrazilianCurrencyFormatter().formatEditUpdate(
        TextEditingValue.empty,
        _valorController.value,
      );
      _dataVencimento = d.dataVencimento;
      if (_dataVencimento != null) {
        _dataVencimentoController.text =
            '${_dataVencimento!.day.toString().padLeft(2, '0')}/${_dataVencimento!.month.toString().padLeft(2, '0')}/${_dataVencimento!.year}';
      } else {
        _dataVencimentoController.clear();
      }
      _recorrente = d.recorrente;
      _qtdMesesController.text = d.qtdMeses != null
          ? d.qtdMeses.toString()
          : '';
      _meAvisar = d.meAvisar;
      _linkController.text = d.link ?? '';
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
    if (_dataVencimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a data de vencimento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final despesa = Despesa(
      id: _editandoId,
      condominioId: cubit.condominioId,
      contaId: _contaIdCadastro,
      categoriaId: _categoriaIdCadastro,
      subcategoriaId: _subcategoriaIdCadastro,
      descricao: _descricaoController.text,
      valor: valor,
      dataVencimento: _dataVencimento,
      recorrente: _recorrente,
      qtdMeses: int.tryParse(_qtdMesesController.text),
      meAvisar: _meAvisar,
      link: _linkController.text.isEmpty ? null : _linkController.text,
    );
    cubit.salvarDespesa(despesa);
    _limparFormulario(cubit);
  }

  Widget _buildFotoSection(DespesaReceitaState state, DespesaReceitaCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.imagemArquivo != null)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                      ? Image.network(
                          state.imagemArquivo!.path,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(state.imagemArquivo!.path),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Foto selecionada',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        state.imagemArquivo!.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => cubit.removerImagem(),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Tirar Foto'),
                      onTap: () {
                        Navigator.pop(context);
                        cubit.selecionarImagem(ImageSource.camera);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Galeria'),
                      onTap: () {
                        Navigator.pop(context);
                        cubit.selecionarImagem(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          icon: const Icon(Icons.add_a_photo_outlined, size: 20),
          label: Text(
            state.imagemArquivo != null ? 'Trocar Foto' : 'Anexar foto',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  void _limparFormulario(DespesaReceitaCubit cubit) {
    cubit.cancelarEdicaoDespesa();
    cubit.removerImagem();
    _descricaoController.clear();
    _valorController.clear();
    _linkController.clear();
    _qtdMesesController.clear();
    _dataVencimentoController.clear();
    setState(() {
      _editandoId = null;
      _dataVencimento = null;
      _recorrente = false;
      _meAvisar = false;
      _contaIdCadastro = null;
      _categoriaIdCadastro = null;
      _subcategoriaIdCadastro = null;
      _cadastroExpandido = false;
    });
  }
}
