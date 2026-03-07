import 'package:flutter/material.dart';

/// Widget do relatório de Portaria.
/// Campos: Mês/Ano, Filtro (Intervalo), Radio (Condomínio/Unidade/Detalhado),
/// Ver PDF/Visualizar/E-mail/Share
class RelatorioPortariaWidget extends StatefulWidget {
  const RelatorioPortariaWidget({super.key});

  @override
  State<RelatorioPortariaWidget> createState() =>
      _RelatorioPortariaWidgetState();
}

class _RelatorioPortariaWidgetState extends State<RelatorioPortariaWidget> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();

  bool _filtroExpandido = true;
  int _mesVenc = DateTime.now().month;
  int _anoVenc = DateTime.now().year;
  String _tipoVisualizacao = 'Condomínio';

  @override
  void dispose() {
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
          const SizedBox(height: 20),
          // Radio Condomínio / Unidade / Detalhado
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _radioOption('Condomínio'),
              _radioOption('Unidade'),
              _radioOption('Detalhado'),
            ],
          ),
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
        ],
      ],
    );
  }

  Widget _radioOption(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: label,
          groupValue: _tipoVisualizacao,
          onChanged: (v) =>
              setState(() => _tipoVisualizacao = v ?? 'Condomínio'),
          activeColor: _primaryColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Text(label, style: const TextStyle(fontSize: 13)),
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
      ],
    );
  }

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
