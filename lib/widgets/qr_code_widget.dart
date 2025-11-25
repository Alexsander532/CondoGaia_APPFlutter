import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/qr_code_helper.dart';

class QrCodeWidget extends StatefulWidget {
  final String dados;
  final String nome;
  final VoidCallback? onCopiar;
  final VoidCallback? onCompartilhar;

  const QrCodeWidget({
    Key? key,
    required this.dados,
    required this.nome,
    this.onCopiar,
    this.onCompartilhar,
  }) : super(key: key);

  @override
  State<QrCodeWidget> createState() => _QrCodeWidgetState();
}

class _QrCodeWidgetState extends State<QrCodeWidget> {
  bool _copiando = false;
  bool _compartilhando = false;

  Widget _buildQrCode() {
    try {
      return RepaintBoundary(
        child: QrImageView(
          data: widget.dados,
          version: QrVersions.auto,
          size: 180,
          gapless: true,
          errorCorrectionLevel: QrErrorCorrectLevel.H,
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
          ),
          backgroundColor: Colors.white,
        ),
      );
    } catch (e) {
      print('[QR Widget] Erro ao renderizar QR: $e');
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_2, size: 50, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'QR Code\n(${widget.dados.length} chars)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!QrCodeHelper.validarDados(widget.dados)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.red[50],
        ),
        child: Text(
          'Dados inválidos para gerar QR Code',
          style: TextStyle(color: Colors.red[700]),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          // QR Code
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox(
                width: 180,
                height: 180,
                child: _buildQrCode(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Label
          Text(
            'QR Code de: ${widget.nome}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Botões
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _copiando ? null : _copiarQR,
                icon: _copiando
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.content_copy),
                label: Text(_copiando ? 'Copiando...' : 'Copiar QR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _compartilhando ? null : _compartilharQR,
                icon: _compartilhando
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.share),
                label: Text(
                  _compartilhando ? 'Compartilhando...' : 'Compartilhar',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copiarQR() async {
    setState(() => _copiando = true);

    try {
      print('[Widget] Iniciando cópia do QR Code...');
      final sucesso = await QrCodeHelper.copiarQRParaClipboard(
        widget.dados,
      );

      setState(() => _copiando = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sucesso
                ? 'QR Code pronto para copiar!'
                : 'Erro ao gerar QR Code',
          ),
          backgroundColor: sucesso ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );

      if (sucesso && widget.onCopiar != null) {
        widget.onCopiar!();
      }
    } catch (e) {
      print('[Widget] Erro ao copiar: $e');
      setState(() => _copiando = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao copiar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _compartilharQR() async {
    setState(() => _compartilhando = true);

    try {
      print('[Widget] Iniciando compartilhamento do QR Code...');
      final sucesso = await QrCodeHelper.compartilharQR(
        widget.dados,
        widget.nome,
      );

      setState(() => _compartilhando = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sucesso
                ? 'QR Code pronto para compartilhar!'
                : 'Erro ao gerar QR Code',
          ),
          backgroundColor: sucesso ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );

      if (sucesso && widget.onCompartilhar != null) {
        widget.onCompartilhar!();
      }
    } catch (e) {
      print('[Widget] Erro ao compartilhar: $e');
      setState(() => _compartilhando = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao compartilhar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}