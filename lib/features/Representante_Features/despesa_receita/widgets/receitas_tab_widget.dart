import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/despesa_receita_cubit.dart';
import '../cubit/despesa_receita_state.dart';
import '../models/receita_model.dart';
import 'resumo_financeiro_widget.dart';

class ReceitasTabWidget extends StatefulWidget {
  const ReceitasTabWidget({super.key});

  @override
  State<ReceitasTabWidget> createState() => _ReceitasTabWidgetState();
}

class _ReceitasTabWidgetState extends State<ReceitasTabWidget> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _dataCreditoController = TextEditingController();
  final _qtdMesesController = TextEditingController();

  bool _filtrosExpandidos = true;
  bool _cadastroExpandido = false;
  bool _recorrente = false;

  // Filtros
  String? _filtroContaId;
  String? _filtroContaContabil;
  String _filtroTipo = 'Todos';

  // Cadastro
  String? _contaIdCadastro;
  String? _contaContabilCadastro;

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

  static const List<String> _tiposReceita = ['Todos', 'Manual', 'Automático'];
  static const _primaryColor = Color(0xFF0D3B66);
  static const _accentColor = Color(0xFF1A73E8);

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _dataCreditoController.dispose();
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
                  // ── Seletor Mês/Ano ──
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

                  // ── Card: Cadastrar Nova Receita ──
                  _buildSectionCard(
                    icon: Icons.add_circle_outline,
                    title: 'Cadastrar Nova Receita',
                    isExpanded: _cadastroExpandido,
                    onToggle: () => setState(
                      () => _cadastroExpandido = !_cadastroExpandido,
                    ),
                    accentColor: Colors.green.shade700,
                    child: _buildCadastroForm(state, cubit),
                  ),
                  const SizedBox(height: 16),

                  // ── Registros (Tabela) ──
                  _buildRegistrosSection(state, cubit),

                  const SizedBox(height: 16),

                  // ── Resumo ──
                  ResumoFinanceiroWidget(
                    totalCredito: state.totalReceitas,
                    totalDebito: state.totalDespesas,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // FAB para cadastrar
            if (!_cadastroExpandido)
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  heroTag: 'fab_receita',
                  backgroundColor: _primaryColor,
                  onPressed: () => setState(() => _cadastroExpandido = true),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
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
        _buildDropdownField(
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
        _buildDropdownField(
          label: 'Conta Contábil',
          icon: Icons.book,
          value: _filtroContaContabil,
          items: ['Controle', 'Fundo Reserva', 'Obras']
              .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _filtroContaContabil = v),
        ),
        const SizedBox(height: 10),
        _buildDropdownField(
          label: 'Tipo',
          icon: Icons.tune,
          value: _filtroTipo,
          items: _tiposReceita
              .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _filtroTipo = v ?? 'Todos'),
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
                      contaId: _filtroContaId,
                      contaContabil: _filtroContaContabil,
                      tipoReceita: _filtroTipo,
                    );
                    cubit.pesquisarReceitas();
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
        _buildDropdownField(
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
        _buildDropdownField(
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

        // Valor e Data Crédito em row
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
                controller: _dataCreditoController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Dia do Crédito',
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
                    final receita = Receita(
                      condominioId: cubit.condominioId,
                      contaId: _contaIdCadastro,
                      contaContabil: _contaContabilCadastro,
                      descricao: _descricaoController.text,
                      valor:
                          double.tryParse(
                            _valorController.text.replaceAll(',', '.'),
                          ) ??
                          0,
                      dataCredito: _parseDate(_dataCreditoController.text),
                      recorrente: _recorrente,
                      qtdMeses: int.tryParse(_qtdMesesController.text),
                    );
                    cubit.salvarReceita(receita);
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
              state.isSaving ? 'Salvando...' : 'Salvar Receita',
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
            const Icon(Icons.list_alt, size: 20, color: _primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Receitas Registradas',
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
                '${state.receitas.length} registro${state.receitas.length != 1 ? 's' : ''}',
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
        else if (state.receitas.isEmpty)
          _buildEmptyState()
        else
          _buildReceitasList(state, cubit),

        if (state.receitas.isNotEmpty) ...[
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
          Icon(Icons.trending_up, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Nenhuma receita encontrada',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Use o botão + para cadastrar uma nova receita',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildReceitasList(
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
                          state.receitas
                              .where((r) => r.id != null)
                              .map((r) => r.id!)
                              .toList(),
                        );
                      },
                      child: Icon(
                        state.receitas.isNotEmpty &&
                                state.receitas.every(
                                  (r) => state.itensSelecionados.contains(r.id),
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
                  _headerCell('Conta', flex: 2),
                  _headerCell('Crédito', flex: 2),
                  _headerCell('Valor', flex: 2),
                  _headerCell('Tipo', flex: 1),
                ],
              ),
            ),
            ...state.receitas.asMap().entries.map((entry) {
              return _buildReceitaRow(entry.value, entry.key, state, cubit);
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

  Widget _buildReceitaRow(
    Receita r,
    int index,
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
  ) {
    final isSelected = state.itensSelecionados.contains(r.id);
    final dataStr = r.dataCredito != null
        ? '${r.dataCredito!.day.toString().padLeft(2, '0')}/${r.dataCredito!.month.toString().padLeft(2, '0')}/${r.dataCredito!.year}'
        : '--';
    final valorStr = 'R\$ ${r.valor.toStringAsFixed(2).replaceAll('.', ',')}';

    return GestureDetector(
      onTap: () {
        if (r.id != null) cubit.toggleItemSelecionado(r.id!);
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
              child: Text(
                r.contaNome ?? '--',
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
                    color: r.recorrente ? Colors.orange.shade700 : _accentColor,
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
    final qtd = state.itensSelecionados.length;
    final total = state.receitas
        .where((r) => state.itensSelecionados.contains(r.id))
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
                onPressed: () => cubit.excluirReceitasSelecionadas(),
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
    _dataCreditoController.clear();
    _qtdMesesController.clear();
    setState(() {
      _recorrente = false;
      _contaIdCadastro = null;
      _contaContabilCadastro = null;
    });
  }
}
