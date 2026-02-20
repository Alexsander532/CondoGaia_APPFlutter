import 'package:flutter/material.dart';

/// Widget do relatório Demonstrativo p/ Balancete.
/// Campos: Mês/Ano, Grid de checkboxes agrupados por seção,
/// Ver PDF/Visualizar/E-mail/Share
class RelatorioDemonstrativoBalanceteWidget extends StatefulWidget {
  const RelatorioDemonstrativoBalanceteWidget({super.key});

  @override
  State<RelatorioDemonstrativoBalanceteWidget> createState() =>
      _RelatorioDemonstrativoBalanceteWidgetState();
}

class _RelatorioDemonstrativoBalanceteWidgetState
    extends State<RelatorioDemonstrativoBalanceteWidget> {
  static const _primaryColor = Color(0xFF0D3B66);

  int _mesVenc = DateTime.now().month;
  int _anoVenc = DateTime.now().year;

  // Todas as opções do balancete — iniciam selecionadas
  bool _textoCapa = true;
  bool _1 = true;
  bool _2 = true;
  bool _3 = true;
  bool _boletos = true;
  bool _ativo = true;
  bool _pago = true;
  bool _despesas = true;
  bool _imagem = true;
  bool _dre = true;
  bool _livroDiario = true;
  bool _acordo = true;
  bool _inadimplencia = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMesAnoSelector(),
          const SizedBox(height: 24),
          // Grid de checkboxes
          _checkRow([
            _cb(
              'Texto Capa',
              _textoCapa,
              (v) => setState(() => _textoCapa = v),
            ),
            _cb('1', _1, (v) => setState(() => _1 = v)),
            _cb('2', _2, (v) => setState(() => _2 = v)),
            _cb('3', _3, (v) => setState(() => _3 = v)),
          ]),
          _checkRow([
            _cb('Boletos', _boletos, (v) => setState(() => _boletos = v)),
            _cb('Ativo', _ativo, (v) => setState(() => _ativo = v)),
            _cb('Pago', _pago, (v) => setState(() => _pago = v)),
          ]),
          _checkRow([
            _cb('Despesas', _despesas, (v) => setState(() => _despesas = v)),
            _cb('Imagem', _imagem, (v) => setState(() => _imagem = v)),
          ]),
          _checkRow([_cb('DRE', _dre, (v) => setState(() => _dre = v))]),
          _checkRow([
            _cb(
              'Livro Diário de Lançamento',
              _livroDiario,
              (v) => setState(() => _livroDiario = v),
            ),
          ]),
          _checkRow([
            _cb('Acordo', _acordo, (v) => setState(() => _acordo = v)),
          ]),
          _checkRow([
            _cb(
              'Inadimplência',
              _inadimplencia,
              (v) => setState(() => _inadimplencia = v),
            ),
          ]),
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

  Widget _checkRow(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Wrap(spacing: 4, runSpacing: 4, children: children),
    );
  }

  Widget _cb(String label, bool value, ValueChanged<bool> onChanged) {
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
