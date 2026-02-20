import 'package:flutter/material.dart';

/// Widget do relatório Morador/Unid.
/// Campos: Pesquisa, Radio (Dados Proprietário / Lista Presença Assembleia),
/// Checkboxes condicionais, Título (se Lista), Ver PDF/Visualizar/E-mail/Share/xlsx
class RelatorioMoradorUnidWidget extends StatefulWidget {
  const RelatorioMoradorUnidWidget({super.key});

  @override
  State<RelatorioMoradorUnidWidget> createState() =>
      _RelatorioMoradorUnidWidgetState();
}

class _RelatorioMoradorUnidWidgetState
    extends State<RelatorioMoradorUnidWidget> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _buscaController = TextEditingController();
  final _tituloController = TextEditingController(
    text:
        'Lista de presença da Assembleia ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
  );

  String _tipoRelatorio = 'dados'; // 'dados' ou 'lista'
  bool _inquilino = false;
  bool _imobiliaria = false;
  bool _historico = false;
  // Para Lista de Presença
  bool _inquilinoLista = false;
  bool _conjugeLista = false;

  @override
  void dispose() {
    _buscaController.dispose();
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pesquisa
          _buildSearchBar(),
          const SizedBox(height: 24),

          // Radio — Dados Proprietário e unid.
          _buildRadioOption('dados', 'Dados Proprietário e unid.'),
          if (_tipoRelatorio == 'dados') ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  _checkboxTile(
                    'Inquilino',
                    _inquilino,
                    (v) => setState(() => _inquilino = v),
                  ),
                  _checkboxTile(
                    'Imobiliária',
                    _imobiliaria,
                    (v) => setState(() => _imobiliaria = v),
                  ),
                  _checkboxTile(
                    'Histórico',
                    _historico,
                    (v) => setState(() => _historico = v),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Radio — Lista de Presença Assembleia
          _buildRadioOption('lista', 'Lista de Presença Assembleia'),
          if (_tipoRelatorio == 'lista') ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '//se selecionado, ativar TÍTULO para edição',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _tituloController,
                    decoration: InputDecoration(
                      labelText: 'Título:',
                      labelStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
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
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _primaryColor),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _checkboxTile(
                        'Inquilino',
                        _inquilinoLista,
                        (v) => setState(() => _inquilinoLista = v),
                      ),
                      _checkboxTile(
                        'Cônjuge',
                        _conjugeLista,
                        (v) => setState(() => _conjugeLista = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildRadioOption(String value, String label) {
    return InkWell(
      onTap: () => setState(() => _tipoRelatorio = value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _tipoRelatorio,
            onChanged: (v) => setState(() => _tipoRelatorio = v ?? 'dados'),
            activeColor: _primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
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
