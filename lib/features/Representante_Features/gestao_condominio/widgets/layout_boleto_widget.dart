import 'package:flutter/material.dart';

class LayoutBoletoWidget extends StatefulWidget {
  const LayoutBoletoWidget({super.key});

  @override
  State<LayoutBoletoWidget> createState() => _LayoutBoletoWidgetState();
}

class _LayoutBoletoWidgetState extends State<LayoutBoletoWidget> {
  String _mensalValue = 'Mensal 1';
  String _acordoValue = 'Acordo 1';
  String _avulsoValue = 'Avulso 8';

  final List<String> _mensalOptions = ['Mensal 1', 'Mensal 2', 'Mensal 3'];
  final List<String> _acordoOptions = ['Acordo 1', 'Acordo 2', 'Acordo 3'];
  final List<String> _avulsoOptions = ['Avulso 1', 'Avulso 8', 'Avulso 10'];

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Link "Ver Modelos de Boletos"
        Center(
          child: TextButton.icon(
            onPressed: () {
              // TODO: Implement navigation or modal to view models
            },
            icon: const Icon(
              Icons.description_outlined,
              color: Color(0xFF0D3B66),
            ),
            label: const Text(
              'Ver Modelos de Boletos',
              style: TextStyle(
                color: Color(0xFF0D3B66),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Row of 3 Dropdowns
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                value: _mensalValue,
                items: _mensalOptions,
                onChanged: (val) => setState(() => _mensalValue = val!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdown(
                value: _acordoValue,
                items: _acordoOptions,
                onChanged: (val) => setState(() => _acordoValue = val!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdown(
                value: _avulsoValue,
                items: _avulsoOptions,
                onChanged: (val) => setState(() => _avulsoValue = val!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
