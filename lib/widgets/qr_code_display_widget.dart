import 'package:flutter/material.dart';
import '../utils/qr_code_helper.dart';

/// Widget para exibir QR Code de visitante representante
/// Exibe APENAS a URL salva no banco, sem gerar novo QR Code
class QrCodeDisplayWidget extends StatefulWidget {
  final String? qrCodeUrl;
  final String visitanteNome;
  final String visitanteCpf;
  final String unidade;

  const QrCodeDisplayWidget({
    Key? key,
    this.qrCodeUrl,
    required this.visitanteNome,
    required this.visitanteCpf,
    required this.unidade,
  }) : super(key: key);

  @override
  State<QrCodeDisplayWidget> createState() => _QrCodeDisplayWidgetState();
}

class _QrCodeDisplayWidgetState extends State<QrCodeDisplayWidget> {
  bool _compartilhando = false;

  @override
  void initState() {
    super.initState();
    // Debug: Mostrar a URL ao carregar o widget
    print('[QrCodeDisplayWidget] URL recebida: "${widget.qrCodeUrl}"');
    print('[QrCodeDisplayWidget] Nome: "${widget.visitanteNome}"');
  }

  Future<void> _compartilharQR() async {
    if (widget.qrCodeUrl == null || widget.qrCodeUrl!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code não disponível'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _compartilhando = true);

    try {
      print('[QR Display] Compartilhando: ${widget.qrCodeUrl}');
      final sucesso = await QrCodeHelper.compartilharQRURL(
        widget.qrCodeUrl!,
        widget.visitanteNome,
      );

      if (!mounted) return;

      setState(() => _compartilhando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sucesso
                ? 'QR Code compartilhado com sucesso!'
                : 'Erro ao compartilhar QR Code',
          ),
          backgroundColor: sucesso ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _compartilhando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao compartilhar: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🆕 Se não tem QR Code salvo, não mostra nada
    if (widget.qrCodeUrl == null || widget.qrCodeUrl!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange[300]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'QR Code em processamento...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'O QR Code será exibido em breve',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[600],
              ),
            ),
          ],
        ),
      );
    }

    // 🔑 AQUI: Exibir APENAS a URL salva
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1976D2).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título
          const Text(
            'QR Code',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A59),
            ),
          ),
          const SizedBox(height: 12),

          // 🆕 Exibir imagem do QR Code
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey[300]!,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () => _mostrarQRCodeAmpliado(context),
              child: SizedBox(
                width: 280,
                height: 280,
                child: Image.network(
                  widget.qrCodeUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[300],
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Erro ao carregar QR',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[300],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF1976D2),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Botão de Compartilhar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _compartilhando ? null : _compartilharQR,
              icon: _compartilhando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.share, color: Colors.white),
              label: Text(
                _compartilhando ? 'Compartilhando...' : 'Compartilhar QR Code',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                disabledBackgroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Informação adicional
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green[600],
              ),
              const SizedBox(width: 6),
              Text(
                'QR Code gerado com sucesso',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarQRCodeAmpliado(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabeçalho
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QR Code - ${widget.visitanteNome}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Imagem ampliada
              Image.network(
                widget.qrCodeUrl!,
                width: 400,
                height: 400,
                fit: BoxFit.scaleDown,
              ),
              const SizedBox(height: 24),

              // Botão de compartilhar no dialog
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _compartilhando ? null : _compartilharQR,
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(
                    'Compartilhar QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
