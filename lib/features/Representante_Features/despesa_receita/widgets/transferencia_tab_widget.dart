import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/despesa_receita_cubit.dart';
import '../cubit/despesa_receita_state.dart';
import '../models/transferencia_model.dart';
import 'resumo_financeiro_widget.dart';

class TransferenciaTabWidget extends StatefulWidget {
  const TransferenciaTabWidget({super.key});

  @override
  State<TransferenciaTabWidget> createState() => _TransferenciaTabWidgetState();
}

class _TransferenciaTabWidgetState extends State<TransferenciaTabWidget> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _dataController = TextEditingController();
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

  static const List<String> _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  static const _primaryColor = Color(0xFF0D3B66);
  static const _accentColor = Color(0xFF1A73E8);

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _dataController.dispose();
    _qtdMesesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DespesaReceitaCubit, DespesaReceitaState>(
      builder: (context, state) {
        final cubit = context.read<DespesaReceitaCubit>();

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMesAnoSelector(state, cubit),
                  const SizedBox(height: 16),

                  // ── Card: Filtros ──
                  _buildSectionCard(
                    icon: Icons.filter_list,
                    title: 'Filtros',
                    isExpanded: _filtrosExpandidos,
                    onToggle: () => setState(
                      () => _filtrosExpandidos = !_filtrosExpandidos,
                    ),
                    child: _buildFiltrosContent(state, cubit),
                  ),
                  const SizedBox(height: 12),

                  // ── Card: Nova Transferência ──
                  _buildSectionCard(
                    icon: Icons.swap_horiz,
                    title: 'Nova Transferência',
                    isExpanded: _cadastroExpandido,
                    onToggle: () => setState(
                      () => _cadastroExpandido = !_cadastroExpandido,
                    ),
                    accentColor: Colors.green.shade700,
                    child: _buildCadastroForm(state, cubit),
                  ),
                  const SizedBox(height: 16),

                  // ── Registros ──
                  _buildRegistrosSection(state, cubit),

                  const SizedBox(height: 16),

                  ResumoFinanceiroWidget(
                    totalCredito: state.totalReceitas,
                    totalDebito: state.totalDespesas,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            if (!_cadastroExpandido)
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  heroTag: 'fab_transferencia',
                  backgroundColor: _primaryColor,
                  onPressed: () => setState(() => _cadastroExpandido = true),
                  child: const Icon(
                    Icons.swap_horiz,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // SELETOR MÊS / ANO
  // ══════════════════════════════════════════════════════

  Widget _buildMesAnoSelector(
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
  ) {
    final mesNome = _meses[state.mesSelecionado - 1];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: _primaryColor),
            onPressed: cubit.mesAnterior,
          ),
          const Icon(Icons.calendar_month, size: 20, color: _primaryColor),
          const SizedBox(width: 8),
          Text(
            '$mesNome/${state.anoSelecionado}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _primaryColor,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: _primaryColor),
            onPressed: cubit.proximoMes,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // CARD GENÉRICO COM HEADER
  // ══════════════════════════════════════════════════════

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    Color? accentColor,
  }) {
    final color = accentColor ?? _primaryColor;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: isExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(12))
                    : BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: color,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: child,
            ),
        ],
      ),
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
        // Visual de setas: Débito → Crédito
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
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
              child: Icon(Icons.arrow_forward, color: _primaryColor, size: 22),
            ),
            Expanded(
              child: _buildDropdownField(
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
                      contaId: _filtroContaDebitoId,
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
              backgroundColor: _accentColor,
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
  // FORMULÁRIO DE CADASTRO
  // ══════════════════════════════════════════════════════

  Widget _buildCadastroForm(
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contas: Débito e Crédito com seta
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
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
                  color: _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.swap_horiz,
                  color: _primaryColor,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: _buildDropdownField(
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

        // Descrição
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

        // Valor e Data
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _valorController,
                keyboardType: TextInputType.number,
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
              child: TextField(
                controller: _dataController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Data Transferência',
                  prefixIcon: const Icon(Icons.calendar_today, size: 18),
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
          ],
        ),
        const SizedBox(height: 12),

        // Recorrente
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.repeat, size: 18, color: _primaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Recorrente',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const Spacer(),
                  Switch(
                    value: _recorrente,
                    onChanged: (v) => setState(() => _recorrente = v),
                    activeColor: _primaryColor,
                  ),
                ],
              ),
              if (_recorrente) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _qtdMesesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Qtd. Meses',
                    hintText: '∞ se vazio',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Botão Salvar
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: state.isSaving
                ? null
                : () {
                    final transferencia = Transferencia(
                      condominioId: cubit.condominioId,
                      contaDebitoId: _contaDebitoId,
                      contaCreditoId: _contaCreditoId,
                      descricao: _descricaoController.text,
                      valor:
                          double.tryParse(
                            _valorController.text.replaceAll(',', '.'),
                          ) ??
                          0,
                      dataTransferencia: _parseDate(_dataController.text),
                      recorrente: _recorrente,
                      qtdMeses: int.tryParse(_qtdMesesController.text),
                    );
                    cubit.salvarTransferencia(transferencia);
                    _limparFormulario();
                  },
            icon: state.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save, size: 20),
            label: Text(
              state.isSaving ? 'Salvando...' : 'Salvar Transferência',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  // REGISTROS (TABELA)
  // ══════════════════════════════════════════════════════

  Widget _buildRegistrosSection(
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.swap_horiz, size: 20, color: _primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Transferências Registradas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${state.transferencias.length} registro${state.transferencias.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (state.status == DespesaReceitaStatus.loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (state.transferencias.isEmpty)
          _buildEmptyState()
        else
          _buildTransferenciasList(state, cubit),

        if (state.transferencias.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildRodape(state, cubit),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.swap_horiz, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Nenhuma transferência encontrada',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toque no botão para registrar uma transferência',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferenciasList(
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: _primaryColor,
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: GestureDetector(
                      onTap: () {
                        cubit.selecionarTodos(
                          state.transferencias
                              .where((t) => t.id != null)
                              .map((t) => t.id!)
                              .toList(),
                        );
                      },
                      child: Icon(
                        state.transferencias.isNotEmpty &&
                                state.transferencias.every(
                                  (t) => state.itensSelecionados.contains(t.id),
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
            ),
            ...state.transferencias.asMap().entries.map((entry) {
              return _buildTransferenciaRow(
                entry.value,
                entry.key,
                state,
                cubit,
              );
            }),
          ],
        ),
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
    final isSelected = state.itensSelecionados.contains(t.id);
    final dataStr = t.dataTransferencia != null
        ? '${t.dataTransferencia!.day.toString().padLeft(2, '0')}/${t.dataTransferencia!.month.toString().padLeft(2, '0')}/${t.dataTransferencia!.year}'
        : '--';
    final valorStr = 'R\$ ${t.valor.toStringAsFixed(2).replaceAll('.', ',')}';

    return GestureDetector(
      onTap: () {
        if (t.id != null) cubit.toggleItemSelecionado(t.id!);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? _accentColor.withOpacity(0.06)
              : (index.isEven ? Colors.white : Colors.grey.shade50),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
            left: isSelected
                ? BorderSide(color: _accentColor, width: 3)
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
                color: isSelected ? _accentColor : Colors.grey.shade400,
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
                style: TextStyle(fontSize: 11, color: Colors.red.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                t.contaCreditoNome ?? '--',
                style: TextStyle(fontSize: 11, color: Colors.green.shade600),
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
                  color: _primaryColor,
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
    final qtd = state.itensSelecionados.length;
    final total = state.transferencias
        .where((t) => state.itensSelecionados.contains(t.id))
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
                onPressed: qtd == 1 ? () {} : null,
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('Editar', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
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
                onPressed: () => cubit.excluirTransferenciasSelecionadas(),
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
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = items.any((item) => item.value == value) ? value : null;
    return DropdownButtonFormField<String>(
      value: validValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
      items: items,
      onChanged: onChanged,
    );
  }

  DateTime? _parseDate(String text) {
    if (text.isEmpty) return null;
    try {
      if (text.contains('/')) {
        final parts = text.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
      final day = int.tryParse(text);
      if (day != null) {
        final cubit = context.read<DespesaReceitaCubit>();
        return DateTime(
          cubit.state.anoSelecionado,
          cubit.state.mesSelecionado,
          day,
        );
      }
    } catch (_) {}
    return null;
  }

  void _limparFormulario() {
    _descricaoController.clear();
    _valorController.clear();
    _dataController.clear();
    _qtdMesesController.clear();
    setState(() {
      _recorrente = false;
      _contaDebitoId = null;
      _contaCreditoId = null;
    });
  }
}
