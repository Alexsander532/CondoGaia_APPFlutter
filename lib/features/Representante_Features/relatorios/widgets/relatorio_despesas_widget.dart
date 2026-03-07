import 'package:flutter/material.dart';

/// Widget do relatório de Despesas.
/// Campos: Mês/Ano, Filtro (Intervalo, Categoria, Subcategoria, Conta Bancária),
/// Pesquisar palavra-chave + Descrição, Ver PDF/Visualizar/E-mail/Share/xlsx
class RelatorioDespesasWidget extends StatefulWidget {
  const RelatorioDespesasWidget({super.key});

  @override
  State<RelatorioDespesasWidget> createState() =>
      _RelatorioDespesasWidgetState();
}

class _RelatorioDespesasWidgetState extends State<RelatorioDespesasWidget> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _palavraChaveController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();

  bool _filtroExpandido = true;
  bool _descricao = false;
  int _mesVenc = DateTime.now().month;
  int _anoVenc = DateTime.now().year;
  String _categoria = 'Todos';
  String _subcategoria = 'Todos';
  String _contaBancaria = 'Todos';

  @override
  void dispose() {
    _palavraChaveController.dispose();
    _dataInicioController.dispose();
    _dataFimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMesAnoSelector(),
          const SizedBox(height: 20),
          _buildFiltroSection(),
          const SizedBox(height: 16),
          _buildPalavraChave(),
          const SizedBox(height: 28),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMesAnoSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Mês/Ano',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 24, color: _primaryColor),
          onPressed: () => setState(() {
            _mesVenc--;
            if (_mesVenc < 1) {
              _mesVenc = 12;
              _anoVenc--;
            }
          }),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_mesVenc.toString().padLeft(2, '0')} / $_anoVenc',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: _primaryColor,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 24, color: _primaryColor),
          onPressed: () => setState(() {
            _mesVenc++;
            if (_mesVenc > 12) {
              _mesVenc = 1;
              _anoVenc++;
            }
          }),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
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
          // Intervalo
          Row(
            children: [
              const Text(
                'Intervalo:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dateField(_dataInicioController, 'Início __/__'),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('a'),
              ),
              Expanded(child: _dateField(_dataFimController, 'Fim __/__')),
            ],
          ),
          const SizedBox(height: 14),
          // Categoria
          _dropdownRow('Categoria:', _categoria, [
            'Todos',
            'Administração',
            'Manutenção',
            'Pessoal',
            'Outros',
          ], (v) => setState(() => _categoria = v)),
          const SizedBox(height: 14),
          // Subcategoria
          _dropdownRow('Subcategoria:', _subcategoria, [
            'Todos',
            'Limpeza',
            'Segurança',
            'Jardinagem',
            'Outros',
          ], (v) => setState(() => _subcategoria = v)),
          const SizedBox(height: 14),
          // Conta Bancária
          _dropdownRow(
            'Conta Bancária:',
            _contaBancaria,
            ['Todos', 'Banco Inter', 'Santander', 'Bradesco'],
            (v) => setState(() => _contaBancaria = v),
          ),
        ],
      ],
    );
  }

  Widget _buildPalavraChave() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _palavraChaveController,
            decoration: InputDecoration(
              hintText: 'Pesquisar palavra Chave',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            Checkbox(
              value: _descricao,
              onChanged: (v) => setState(() => _descricao = v ?? false),
              activeColor: _primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const Text('Descrição', style: TextStyle(fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _actionButton('Ver PDF', Icons.picture_as_pdf),
        const SizedBox(width: 8),
        _actionButton('Visualizar', Icons.visibility),
        const SizedBox(width: 8),
        _actionButton('E-mail', Icons.email),
        const SizedBox(width: 8),
        _iconBtn(Icons.share),
        const Spacer(),
        TextButton(
          onPressed: () => _showSnack('Exportar xlsx — Em breve'),
          child: const Text(
            'xlsx',
            style: TextStyle(color: _primaryColor, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // ─── Helpers ────────────────────────────────────────

  Widget _dateField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _dropdownRow(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            isDense: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _showSnack('$label — Em breve'),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _primaryColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(icon, color: _primaryColor, size: 20),
        onPressed: () => _showSnack('Compartilhar — Em breve'),
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(),
      ),
    );
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
