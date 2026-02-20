import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/acordo_cubit.dart';
import '../cubit/acordo_state.dart';
import '../models/acordo_model.dart';

class PesquisarAcordoTab extends StatefulWidget {
  const PesquisarAcordoTab({super.key});

  @override
  State<PesquisarAcordoTab> createState() => _PesquisarAcordoTabState();
}

class _PesquisarAcordoTabState extends State<PesquisarAcordoTab> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _buscaController = TextEditingController();
  bool _filtroExpandido = false;

  // Filtros
  int _mesVenc = DateTime.now().month;
  int _anoVenc = DateTime.now().year;
  String _tipoEmissao = 'Todos';
  String _situacao = 'Ativo/a vencer';

  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();

  @override
  void dispose() {
    _buscaController.dispose();
    _dataInicioController.dispose();
    _dataFimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AcordoCubit, AcordoState>(
      builder: (context, state) {
        final cubit = context.read<AcordoCubit>();
        final acordosFiltrados = _filtrarAcordos(state.acordos);
        final selecionados = acordosFiltrados
            .where((a) => a.selecionado)
            .toList();
        final totalSelecionado = selecionados.fold<double>(
          0,
          (sum, a) => sum + a.valor,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Barra de busca ===
              _buildSearchBar(),
              const SizedBox(height: 16),

              // === Filtros ===
              _buildFiltroSection(),
              const SizedBox(height: 16),

              // === Tabela de resultados ===
              if (acordosFiltrados.isNotEmpty)
                _buildResultsTable(acordosFiltrados, cubit),

              if (acordosFiltrados.isEmpty) _buildEmptyState(),

              const SizedBox(height: 16),

              // === Barra de ações ===
              _buildActionBar(context),

              const SizedBox(height: 12),

              // === Cancelar Acordo ===
              _buildCancelarAcordoButton(context, selecionados),

              const SizedBox(height: 12),

              // === Rodapé ===
              _buildFooter(selecionados.length, totalSelecionado),
            ],
          ),
        );
      },
    );
  }

  List<Acordo> _filtrarAcordos(List<Acordo> todos) {
    String busca = _buscaController.text.trim().toLowerCase();
    return todos.where((a) {
      if (busca.isNotEmpty) {
        final matchBlUnid = a.blUnid.toLowerCase().contains(busca);
        final matchNome =
            a.nome != null && a.nome!.toLowerCase().contains(busca);
        if (!matchBlUnid && !matchNome) return false;
      }
      if (_tipoEmissao != 'Todos' &&
          a.tipo.toUpperCase() != _tipoEmissao.toUpperCase()) {
        return false;
      }
      if (_situacao != 'Todos') {
        if (_situacao == 'Ativo/a vencer' &&
            a.situacao != 'ATIVO' &&
            a.situacao != 'A VENCER') {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // ======================= BARRA DE BUSCA =======================
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _buscaController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Pesquisar unidade/bloco ou nome',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: _primaryColor),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _primaryColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: _primaryColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Leitor QR — Em breve')),
              );
            },
          ),
        ),
      ],
    );
  }

  // ======================= FILTROS =======================
  Widget _buildFiltroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _filtroExpandido = !_filtroExpandido),
          child: Row(
            children: [
              const Text(
                'Filtro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Icon(
                _filtroExpandido
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        const Divider(),
        if (_filtroExpandido) ...[
          const SizedBox(height: 8),
          // Venc. Mês/Ano com setas
          Row(
            children: [
              const Text(
                'Venc.: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: () {
                  setState(() {
                    _mesVenc--;
                    if (_mesVenc < 1) {
                      _mesVenc = 12;
                      _anoVenc--;
                    }
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                '${_mesVenc.toString().padLeft(2, '0')} / $_anoVenc',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: () {
                  setState(() {
                    _mesVenc++;
                    if (_mesVenc > 12) {
                      _mesVenc = 1;
                      _anoVenc++;
                    }
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Intervalo de Vencimento
          Row(
            children: [
              const Text(
                'Intervalo de Venc.: ',
                style: TextStyle(fontSize: 13),
              ),
              Expanded(
                child: TextField(
                  controller: _dataInicioController,
                  decoration: const InputDecoration(
                    hintText: '__/__/____',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('a'),
              ),
              Expanded(
                child: TextField(
                  controller: _dataFimController,
                  decoration: const InputDecoration(
                    hintText: '__/__/____',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tipo de Emissão
          Row(
            children: [
              const Text('Tipo de Emissão ', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _tipoEmissao,
                  isDense: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: ['Todos', 'Avulso', 'Mensal', 'Acordo']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 13)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _tipoEmissao = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Situação
          Row(
            children: [
              const Text('Situação ', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _situacao,
                  isDense: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items:
                      [
                            'Todos',
                            'Ativo/a vencer',
                            'Ativo(Vencido)',
                            'A vencer',
                            'Ativo / A vencer',
                            'Cancelado',
                            'Pago',
                            'Cancelado acordo',
                          ]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _situacao = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Pesquisar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ======================= TABELA DE RESULTADOS =======================
  Widget _buildResultsTable(List<Acordo> acordos, AcordoCubit cubit) {
    return Column(
      children: [
        // Header
        Container(
          color: _primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              _headerCheckbox(acordos, cubit),
              _headerCell('BL/UNID', flex: 2),
              _headerCell('PAR'),
              _headerCell('MÊS/ANO', flex: 2),
              _headerCell('DATA VENC', flex: 2),
              _headerCell('VALOR', flex: 2),
              _headerCell('TIPO', flex: 2),
              _headerCell('SITUAÇÃO', flex: 2),
              _headerCell('ANEXO'),
            ],
          ),
        ),
        // Rows
        ...acordos.map((a) => _buildAcordoRow(a, cubit)),
        // Empty selection rows
        ...List.generate(
          (3 - acordos.length).clamp(0, 3),
          (_) => Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: false,
                    onChanged: null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerCheckbox(List<Acordo> acordos, AcordoCubit cubit) {
    final allSelected =
        acordos.isNotEmpty && acordos.every((a) => a.selecionado);
    return SizedBox(
      width: 24,
      height: 24,
      child: Checkbox(
        value: allSelected,
        onChanged: (val) => cubit.toggleSelecionarTodos(val ?? false),
        activeColor: Colors.white,
        checkColor: _primaryColor,
        side: const BorderSide(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
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
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAcordoRow(Acordo acordo, AcordoCubit cubit) {
    final isSelected = acordo.selecionado;
    final dataStr =
        '${acordo.dataVencimento.day.toString().padLeft(2, '0')}/${acordo.dataVencimento.month.toString().padLeft(2, '0')}/${acordo.dataVencimento.year}';
    final valorStr = 'R\$${acordo.valor.toStringAsFixed(2)}';

    Color situacaoColor;
    switch (acordo.situacao) {
      case 'PAGO':
        situacaoColor = Colors.green;
        break;
      case 'ATIVO':
        situacaoColor = Colors.orange;
        break;
      case 'A VENCER':
        situacaoColor = Colors.blue;
        break;
      case 'CANCELADO':
        situacaoColor = Colors.red;
        break;
      default:
        situacaoColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? _primaryColor.withOpacity(0.06)
            : Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isSelected,
              onChanged: (_) => cubit.toggleSelecionarAcordo(acordo.id!),
              activeColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          _rowCell(acordo.blUnid, color: _primaryColor, bold: true, flex: 2),
          _rowCell(acordo.parcela),
          _rowCell(acordo.mesAno, flex: 2),
          _rowCell(dataStr, color: _primaryColor, flex: 2),
          _rowCell(valorStr, color: _primaryColor, flex: 2),
          _rowCell(acordo.tipo, flex: 2),
          Expanded(
            flex: 2,
            child: Text(
              acordo.situacao,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: situacaoColor,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: acordo.anexoUrl != null
                ? const Icon(Icons.attach_file, size: 16, color: _primaryColor)
                : const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: _primaryColor,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _rowCell(
    String text, {
    Color? color,
    bool bold = false,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color ?? Colors.black87,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ======================= ESTADO VAZIO =======================
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            'Nenhum resultado encontrado',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ======================= BARRA DE AÇÕES =======================
  Widget _buildActionBar(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _actionButton('Gerar PDF', Icons.picture_as_pdf, context),
        _actionButton('Visualizar', Icons.visibility, context),
        _actionButton('Email', Icons.email, context),
        IconButton(
          icon: const Icon(Icons.share, color: _primaryColor),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Compartilhar — Em breve')),
            );
          },
        ),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$label — Em breve')));
      },
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // ======================= CANCELAR ACORDO =======================
  Widget _buildCancelarAcordoButton(
    BuildContext context,
    List<Acordo> selecionados,
  ) {
    return OutlinedButton(
      onPressed: selecionados.isEmpty
          ? null
          : () => _showCancelarAcordoPopup(context, selecionados),
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryColor,
        side: const BorderSide(color: _primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text(
        'Cancelar\nAcordo',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  void _showCancelarAcordoPopup(
    BuildContext context,
    List<Acordo> selecionados,
  ) {
    final acordo = selecionados.first;
    final pagos = selecionados.where((a) => a.situacao == 'PAGO').toList();
    final ativos = selecionados.where((a) => a.situacao == 'ATIVO').toList();
    final aVencer = selecionados
        .where((a) => a.situacao == 'A VENCER')
        .toList();

    final totalPagas = pagos.fold<double>(0, (s, a) => s + a.valor);
    final totalAtivas = ativos.fold<double>(0, (s, a) => s + a.valor);
    final totalAVencer = aVencer.fold<double>(0, (s, a) => s + a.valor);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'CANCELAR ACORDO',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'BL/UNID: ${acordo.blUnid}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.person, size: 18, color: _primaryColor),
                ],
              ),
              Text(
                'NOME: ${acordo.nome ?? '—'}',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              // Cabeçalho da mini-tabela
              Container(
                color: Colors.red.shade100,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'DATA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'VALOR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'SITUAÇÃO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...selecionados.map((a) {
                final dataStr =
                    '${a.dataVencimento.day.toString().padLeft(2, '0')}/${a.dataVencimento.month.toString().padLeft(2, '0')}/${a.dataVencimento.year}';
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dataStr,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'R\$ ${a.valor.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          a.situacao,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              _totalRow('TOTAL  PAGAS R\$', totalPagas),
              _totalRow('TOTAL  ATIVAS R\$', totalAtivas),
              _totalRow('TOTAL  A VENCER R\$', totalAVencer),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AcordoCubit>().cancelarAcordo();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Acordo cancelado (stub)'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'CANCELAR ACORDO',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Text(valor.toStringAsFixed(2), style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  // ======================= RODAPÉ =======================
  Widget _buildFooter(int qtnd, double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Qtnd.: $qtnd',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        Text(
          'Total: R\$ ${total.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: _primaryColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
