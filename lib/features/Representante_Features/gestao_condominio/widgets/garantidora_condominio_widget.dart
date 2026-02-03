import 'package:flutter/material.dart';
import '../../../../models/condominio.dart';

class GarantidoraCondominioWidget extends StatefulWidget {
  final Condominio? condominio;

  const GarantidoraCondominioWidget({super.key, this.condominio});

  @override
  State<GarantidoraCondominioWidget> createState() =>
      _GarantidoraCondominioWidgetState();
}

class _GarantidoraCondominioWidgetState
    extends State<GarantidoraCondominioWidget> {
  final _tokenGarantidoraController = TextEditingController();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _tokenGarantidoraController.text = "423765"; // Mock default
  }

  @override
  void dispose() {
    _tokenGarantidoraController.dispose();
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.only(bottom: 2), // Adjust alignment
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Meu Token: 423765',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.end, // Align roughly with input
          children: [
            Expanded(
              flex: 4,
              child: _buildInput(
                'Token Garantidora:',
                _tokenGarantidoraController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text('Status:', style: TextStyle(fontSize: 13)),
                  ),
                  Row(
                    children: [
                      ScaleTransition(
                        scale: const AlwaysStoppedAnimation(0.8),
                        child: Switch(
                          value: _isConnected,
                          onChanged: (val) =>
                              setState(() => _isConnected = val),
                          activeColor: Colors.white,
                          activeTrackColor: Colors.green.shade400,
                        ),
                      ),
                      const Text('Conectado', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
