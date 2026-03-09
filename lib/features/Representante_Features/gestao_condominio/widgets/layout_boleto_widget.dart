import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../utils/download_helper.dart';

class LayoutBoletoWidget extends StatefulWidget {
  const LayoutBoletoWidget({super.key});

  @override
  State<LayoutBoletoWidget> createState() => _LayoutBoletoWidgetState();
}

class _LayoutBoletoWidgetState extends State<LayoutBoletoWidget> {
  Future<void> _baixarArquivo(String assetPath, String customFileName) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );

      if (mounted) {
        Navigator.pop(context);
      } else {
        return; // Protection if the widget is no longer in the tree
      }

      // Utiliza o DownloadHelper que gerencia Web/Mobile automaticamente
      // Usando async gaps check com mounted
      if (mounted) {
        await DownloadHelper.downloadBytes(bytes, customFileName, context);
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar recurso visual: $e')),
        );
      }
    }
  }

  Widget _buildDownloadButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.download, color: Colors.black54, size: 20),
          ],
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
              _baixarArquivo(
                'assets/docs/boletos/modelo boleto.pdf',
                'modelo_boleto.pdf',
              );
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

        // Row of 3 Download Buttons
        Row(
          children: [
            Expanded(
              child: _buildDownloadButton(
                label: 'Mensal 1',
                onTap: () => _baixarArquivo(
                  'assets/docs/boletos/layout cota condominial mensal.xlsx',
                  'layout_mensal.xlsx',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDownloadButton(
                label: 'Acordo 1',
                onTap: () => _baixarArquivo(
                  'assets/docs/boletos/layout acordo.xlsx',
                  'layout_acordo.xlsx',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDownloadButton(
                label: 'Avulso 8',
                onTap: () => _baixarArquivo(
                  'assets/docs/boletos/layout avulso.xlsx',
                  'layout_avulso.xlsx',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
