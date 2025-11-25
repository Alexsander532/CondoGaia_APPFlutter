import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/qr_code_helper.dart';

class QrCodeWidget extends StatefulWidget {
  final String dados;
  final String nome;
  final String? qrCodeUrl;
  final String? autorizadoId;
  final VoidCallback? onCompartilhar;

  const QrCodeWidget({
    Key? key,
    required this.dados,
    required this.nome,
    this.qrCodeUrl,
    this.autorizadoId,
    this.onCompartilhar,
  }) : super(key: key);

  @override
  State<QrCodeWidget> createState() => _QrCodeWidgetState();
}

class _QrCodeWidgetState extends State<QrCodeWidget> {
  bool _gerando = false;
  bool _compartilhando = false;
  String? _urlQr;
  String? _erro;

  @override
  void initState() {
    super.initState();
    
    // Se já tem URL salva na tabela, usar direto
    if (widget.qrCodeUrl != null && widget.qrCodeUrl!.isNotEmpty) {
      print('[Widget] Usando QR Code salvo: ${widget.qrCodeUrl}');
      setState(() {
        _urlQr = widget.qrCodeUrl;
        _gerando = false;
      });
    } else {
      // Se não tem, gerar novo
      print('[Widget] Gerando novo QR Code (sem URL salva)...');
      _gerarESalvarQR();
    }
  }

  /// Gera e salva QR Code no Supabase
  Future<void> _gerarESalvarQR() async {
    if (!mounted) return;

    setState(() {
      _gerando = true;
      _erro = null;
    });

    try {
      print('[Widget] Iniciando geração e salvamento do QR Code...');
      
      final urlQr = await QrCodeHelper.gerarESalvarQRNoSupabase(
        widget.dados,
        nomeAutorizado: widget.nome,
        tamanho: 220,
      );

      if (!mounted) return;

      if (urlQr != null) {
        setState(() {
          _urlQr = urlQr;
          _gerando = false;
        });
        print('[Widget] QR Code salvo com sucesso: $urlQr');
        
        // 🆕 Salvar URL na tabela do autorizado
        if (widget.autorizadoId != null && widget.autorizadoId!.isNotEmpty) {
          try {
            print('[Widget] Salvando URL na tabela para autorizado: ${widget.autorizadoId}');
            final supabase = Supabase.instance.client;
            
            await supabase
                .from('autorizados_inquilinos')
                .update({'qr_code_url': urlQr})
                .eq('id', widget.autorizadoId!)
                .then((_) {
              print('[Widget] ✅ URL salva na tabela com sucesso!');
            }).catchError((e) {
              print('[Widget] ⚠️ Erro ao salvar URL na tabela: $e');
              // Não quebra o fluxo se falhar
            });
          } catch (e) {
            print('[Widget] ⚠️ Erro ao salvar URL na tabela: $e');
            // Não quebra o fluxo se falhar salvar na tabela
          }
        }
      } else {
        setState(() {
          _erro = 'Erro ao gerar QR Code. Tente novamente.';
          _gerando = false;
        });
        print('[Widget] Erro: QR URL é nulo');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Erro ao gerar QR Code: $e';
        _gerando = false;
      });
      print('[Widget] Erro: $e');
    }
  }

  Future<void> _compartilharQR() async {
    if (_urlQr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code não está pronto. Aguarde...'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _compartilhando = true);

    try {
      print('[Widget] Iniciando compartilhamento do QR Code...');
      final sucesso = await QrCodeHelper.compartilharQRURL(
        _urlQr!,
        widget.nome,
      );

      setState(() => _compartilhando = false);

      if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    // Validar dados
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

    // Mostrar erro se houver
    if (_erro != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.red[50],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[700],
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Erro ao gerar QR',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'QR Code de: ${widget.nome}',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _gerarESalvarQR,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mostrar loading
    if (_gerando) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'QR Code de: ${widget.nome}',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: null,
                icon: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                label: const Text('Gerando QR Code...'),
              ),
            ),
          ],
        ),
      );
    }

    // Renderizar QR Code com sucesso (exibir imagem do Supabase)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // QR Code Image
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _urlQr != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      _urlQr!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4CAF50),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey[400],
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Erro ao carregar QR',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'QR Code',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),

          // Label
          Text(
            'QR Code de: ${widget.nome}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Botão de Compartilhar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _compartilhando ? null : _compartilharQR,
              icon: _compartilhando
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.share, size: 20),
              label: Text(
                _compartilhando ? 'Compartilhando...' : 'Compartilhar QR Code',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
