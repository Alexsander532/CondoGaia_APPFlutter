import 'package:flutter/material.dart';

/// Widget do relatório de Acordo.
/// Campos: Pesquisa, Intervalo, Radio (Acordo/Acordo Cancelado),
/// Checkboxes (Acréscimos, Histórico, Anexo), Ver PDF/Visualizar/E-mail/Share/xlsx
class RelatorioAcordoWidget extends StatefulWidget {
  const RelatorioAcordoWidget({super.key});

  @override
  State<RelatorioAcordoWidget> createState() => _RelatorioAcordoWidgetState();
}

class _RelatorioAcordoWidgetState extends State<RelatorioAcordoWidget> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _buscaController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();

  String _tipoAcordo = 'Acordo'; // 'Acordo' ou 'Acordo Cancelado'
  bool _acrescimos = false;
  bool _historico = false;
  bool _anexo = false;

  @override
  void dispose() {
    _buscaController.dispose();
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
          _buildSearchBar(),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          // Radio Acordo / Acordo Cancelado
          Row(
            children: [
              Radio<String>(
                value: 'Acordo',
                groupValue: _tipoAcordo,
                onChanged: (v) => setState(() => _tipoAcordo = v ?? 'Acordo'),
                activeColor: _primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const Text('Acordo', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 24),
              Radio<String>(
                value: 'Acordo Cancelado',
                groupValue: _tipoAcordo,
                onChanged: (v) => setState(() => _tipoAcordo = v ?? 'Acordo'),
                activeColor: _primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const Text('Acordo Cancelado', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          // Checkboxes
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _checkboxTile(
                'Acréscimos',
                _acrescimos,
                (v) => setState(() => _acrescimos = v),
              ),
              _checkboxTile(
                'Histórico',
                _historico,
                (v) => setState(() => _historico = v),
              ),
              _checkboxTile('Anexo', _anexo, (v) => setState(() => _anexo = v)),
            ],
          ),
          const SizedBox(height: 28),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _buscaController,
            decoration: InputDecoration(
              hintText: 'Pesquisar TODOS ou unidade/bloco ou nome',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
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
            icon: const Icon(Icons.search, color: _primaryColor, size: 24),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _checkboxTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
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
