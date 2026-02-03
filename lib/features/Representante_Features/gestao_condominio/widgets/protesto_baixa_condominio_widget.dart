import 'package:flutter/material.dart';
import '../../../../models/condominio.dart';

class ProtestoBaixaCondominioWidget extends StatefulWidget {
  final Condominio? condominio;

  const ProtestoBaixaCondominioWidget({super.key, this.condominio});

  @override
  State<ProtestoBaixaCondominioWidget> createState() =>
      _ProtestoBaixaCondominioWidgetState();
}

class _ProtestoBaixaCondominioWidgetState
    extends State<ProtestoBaixaCondominioWidget> {
  final _protestarBoletoController = TextEditingController();
  final _diasBaixaController = TextEditingController();

  @override
  void dispose() {
    _protestarBoletoController.dispose();
    _diasBaixaController.dispose();
    super.dispose();
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center, // Center the number roughly
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 11),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildInput(
                  'Protestar boleto:',
                  _protestarBoletoController,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Dias', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildInput('Dias para Baixa:', _diasBaixaController),
              ),
              const SizedBox(width: 8),
              const Text('Dias', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}
