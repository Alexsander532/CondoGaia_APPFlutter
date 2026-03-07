import 'package:flutter/material.dart';

/// Widget do relatório de Inadimplência.
/// Campos: Pesquisa, Filtro (Intervalo, Tipo dropdown),
/// Checkboxes (Detalhado, Separar por Página, Outros Acréscimos),
/// Taxa Adm. Cobrança dropdown, Valor/Porcentagem + Sobre Juros/Multa,
/// Ver PDF/Visualizar/E-mail/Share/xlsx
class RelatorioInadimplenciaWidget extends StatefulWidget {
  const RelatorioInadimplenciaWidget({super.key});

  @override
  State<RelatorioInadimplenciaWidget> createState() =>
      _RelatorioInadimplenciaWidgetState();
}

class _RelatorioInadimplenciaWidgetState
    extends State<RelatorioInadimplenciaWidget> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _buscaController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();
  final _valorController = TextEditingController();
  final _porcentagemController = TextEditingController();

  bool _filtroExpandido = true;
  String _tipo = 'Adimplentes';
  bool _detalhado = false;
  bool _separarPorPagina = false;
  bool _outrosAcrescimos = false;
  String _taxaAdm = 'Taxa Adm. Cobrança';
  bool _sobreJurosMulta = false;

  @override
  void dispose() {
    _buscaController.dispose();
    _dataInicioController.dispose();
    _dataFimController.dispose();
    _valorController.dispose();
    _porcentagemController.dispose();
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
          _buildFiltroSection(),
          const SizedBox(height: 16),
          // Checkboxes
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _checkboxTile(
                'Detalhado',
                _detalhado,
                (v) => setState(() => _detalhado = v),
              ),
              _checkboxTile(
                'Separar por Página',
                _separarPorPagina,
                (v) => setState(() => _separarPorPagina = v),
              ),
              _checkboxTile(
                'Outros Acréscimos',
                _outrosAcrescimos,
                (v) => setState(() => _outrosAcrescimos = v),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Taxa Adm Cobrança dropdown (habilitado quando Outros Acréscimos)
          if (_outrosAcrescimos) ...[
            DropdownButtonFormField<String>(
              value: _taxaAdm,
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
              items: ['Taxa Adm. Cobrança', 'Honorários Advocatícios']
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 13)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _taxaAdm = v);
              },
            ),
            const SizedBox(height: 14),
            // Valor / Porcentagem
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valorController,
                    decoration: InputDecoration(
                      labelText: 'Valor (R\$):',
                      labelStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
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
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('ou', style: TextStyle(fontSize: 13)),
                ),
                Expanded(
                  child: TextField(
                    controller: _porcentagemController,
                    decoration: InputDecoration(
                      labelText: 'Porcentagem (%):',
                      labelStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
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
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _checkboxTile(
              'Sobre Juros/Multa',
              _sobreJurosMulta,
              (v) => setState(() => _sobreJurosMulta = v),
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
          // Tipo
          Row(
            children: [
              const Text(
                'Tipo:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _tipo,
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
                  items: ['Adimplentes', 'Certidão Negativa de Débitos']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 13)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _tipo = v);
                  },
                ),
              ),
            ],
          ),
        ],
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
