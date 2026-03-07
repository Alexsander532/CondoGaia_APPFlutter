import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/despesa_receita_cubit.dart';
import '../cubit/despesa_receita_state.dart';
import '../models/transferencia_model.dart';
import 'shared_widgets.dart';
import 'base_tab_widget.dart';

class TransferenciaTabWidget extends StatefulWidget {
  const TransferenciaTabWidget({super.key});

  @override
  State<TransferenciaTabWidget> createState() => _TransferenciaTabWidgetState();
}

class _TransferenciaTabWidgetState extends State<TransferenciaTabWidget> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _qtdMesesController = TextEditingController();

  bool _filtrosExpandidos = true;
  bool _cadastroExpandido = false;
  bool _recorrente = false;

  // Filtros
  String? _filtroContaDebitoId;
  String? _filtroContaCreditoId;

  // Cadastro
  String? _contaDebitoId;
  String? _contaCreditoId;
  DateTime? _dataTransferencia;

  // Edição
  String? _editandoId;

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _qtdMesesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DespesaReceitaCubit, DespesaReceitaState>(
      builder: (context, state) {
        final cubit = context.read<DespesaReceitaCubit>();

        // Preencher form ao entrar em modo edição
        if (state.transferenciaEditando != null &&
            _editandoId != state.transferenciaEditando!.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _preencherFormParaEdicao(state.transferenciaEditando!);
          });
        }

        return BaseTabWidget<Transferencia>(
          fabHeroTag: 'fab_transferencia',
          fabIcon: Icons.swap_horiz,
          isEditing: _editandoId != null,
          titleAdd: 'Nova Transferência',
          titleEdit: 'Editar Transferência',
          filtrosExpandidos: _filtrosExpandidos,
          onToggleFiltros: () =>
              setState(() => _filtrosExpandidos = !_filtrosExpandidos),
          filtrosContent: _buildFiltrosContent(state, cubit),
          cadastroExpandido: _cadastroExpandido,
          onToggleCadastro: () =>
              setState(() => _cadastroExpandido = !_cadastroExpandido),
          cadastroContent: _buildCadastroForm(state, cubit),
          tableName: 'Transferências Registradas',
          items: state.transferencias,
          isLoading: state.status == DespesaReceitaStatus.loading,
          emptyStateIcon: Icon(
            Icons.swap_horiz,
            size: 48,
            color: Colors.grey.shade300,
          ),
          emptyStateText: 'Nenhuma transferência encontrada',
          emptyStateSubtext: 'Toque no botão para registrar uma transferência',
          tableHeader: _buildHeaderRow(state, cubit),
          itemBuilder: (context, state, cubit, item, index) =>
              _buildTransferenciaRow(item, index, state, cubit),
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
      children: [
        Row(
          children: [
            Expanded(
              child: buildDropdownField(
                label: 'Conta Débito',
                icon: Icons.arrow_upward,
                value: _filtroContaDebitoId,
                items: state.contas
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.banco, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _filtroContaDebitoId = v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward, color: kPrimaryColor, size: 22),
            ),
            Expanded(
              child: buildDropdownField(
                label: 'Conta Crédito',
                icon: Icons.arrow_downward,
                value: _filtroContaCreditoId,
                items: state.contas
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.banco, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _filtroContaCreditoId = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: state.status == DespesaReceitaStatus.loading
                ? null
                : () {
                    cubit.atualizarFiltros(
                      contaDebitoId: _filtroContaDebitoId,
                      contaCreditoId: _filtroContaCreditoId,
                    );
                    cubit.pesquisarTransferencias();
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
        Row(
          children: [
            Expanded(
              child: buildDropdownField(
                label: 'De (Débito)',
                icon: Icons.arrow_upward,
                value: _contaDebitoId,
                items: state.contas
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.banco, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _contaDebitoId = v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.swap_horiz,
                  color: kPrimaryColor,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: buildDropdownField(
                label: 'Para (Crédito)',
                icon: Icons.arrow_downward,
                value: _contaCreditoId,
                items: state.contas
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.banco, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _contaCreditoId = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),

        TextField(
          controller: _descricaoController,
          maxLines: 2,
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
                label: 'Data Transferência',
                value: _dataTransferencia,
                onChanged: (d) => setState(() => _dataTransferencia = d),
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
              : (isEditing ? 'Salvar Alterações' : 'Salvar Transferência'),
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
                cubit.selecionarTodasTransferencias(
                  state.transferencias
                      .where((t) => t.id != null)
                      .map((t) => t.id!)
                      .toList(),
                );
              },
              child: Icon(
                state.transferencias.isNotEmpty &&
                        state.transferencias.every(
                          (t) =>
                              state.transferenciasSelecionadas.contains(t.id),
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
          _headerCell('Débito', flex: 2),
          _headerCell('Crédito', flex: 2),
          _headerCell('Data', flex: 2),
          _headerCell('Valor', flex: 2),
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

  Widget _buildTransferenciaRow(
    Transferencia t,
    int index,
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
  ) {
    final isSelected = state.transferenciasSelecionadas.contains(t.id);
    final dataStr = t.dataTransferencia != null
        ? '${t.dataTransferencia!.day.toString().padLeft(2, '0')}/${t.dataTransferencia!.month.toString().padLeft(2, '0')}/${t.dataTransferencia!.year}'
        : '--';
    final valorStr = 'R\$ ${t.valor.toStringAsFixed(2).replaceAll('.', ',')}';

    return GestureDetector(
      onTap: () {
        if (t.id != null) cubit.toggleTransferenciaSelecionada(t.id!);
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
              child: Text(
                t.descricao ?? 'Sem descrição',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                t.contaDebitoNome ?? '--',
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                t.contaCreditoNome ?? '--',
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
                  color: kPrimaryColor,
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
    final qtd = state.transferenciasSelecionadas.length;
    final total = state.transferencias
        .where((t) => state.transferenciasSelecionadas.contains(t.id))
        .fold(0.0, (sum, t) => sum + t.valor);

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
                        final transferencia = state.transferencias.firstWhere(
                          (t) =>
                              state.transferenciasSelecionadas.contains(t.id),
                        );
                        cubit.iniciarEdicaoTransferencia(transferencia);
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
                  if (confirm) cubit.excluirTransferenciasSelecionadas();
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

  void _preencherFormParaEdicao(Transferencia t) {
    setState(() {
      _editandoId = t.id;
      _contaDebitoId = t.contaDebitoId;
      _contaCreditoId = t.contaCreditoId;
      _descricaoController.text = t.descricao ?? '';
      _valorController.text = t.valor.toStringAsFixed(2);
      _dataTransferencia = t.dataTransferencia;
      _recorrente = t.recorrente;
      _qtdMesesController.text = t.qtdMeses != null
          ? t.qtdMeses.toString()
          : '';
      _cadastroExpandido = true;
    });
  }

  void _salvar(DespesaReceitaCubit cubit) {
    final valorStr = _valorController.text.replaceAll(',', '.');
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
    if (_dataTransferencia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a data da transferência.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_contaDebitoId == null || _contaCreditoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione as contas de débito e crédito.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_contaDebitoId == _contaCreditoId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As contas de débito e crédito não podem ser iguais.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final transferencia = Transferencia(
      id: _editandoId,
      condominioId: cubit.condominioId,
      contaDebitoId: _contaDebitoId,
      contaCreditoId: _contaCreditoId,
      descricao: _descricaoController.text,
      valor: valor,
      dataTransferencia: _dataTransferencia,
      recorrente: _recorrente,
      qtdMeses: int.tryParse(_qtdMesesController.text),
    );
    cubit.salvarTransferencia(transferencia);
    _limparFormulario(cubit);
  }

  void _limparFormulario(DespesaReceitaCubit cubit) {
    cubit.cancelarEdicaoTransferencia();
    _descricaoController.clear();
    _valorController.clear();
    _qtdMesesController.clear();
    setState(() {
      _editandoId = null;
      _dataTransferencia = null;
      _recorrente = false;
      _contaDebitoId = null;
      _contaCreditoId = null;
      _cadastroExpandido = false;
    });
  }
}
