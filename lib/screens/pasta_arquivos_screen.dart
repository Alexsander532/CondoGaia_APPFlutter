import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../models/documento.dart';
import '../services/documento_service.dart';

class PastaArquivosScreen extends StatefulWidget {
  final String nomePasta;
  final String condominioId;
  final String inquilinoId;
  
  const PastaArquivosScreen({
    super.key,
    required this.nomePasta,
    required this.condominioId,
    required this.inquilinoId,
  });

  @override
  State<PastaArquivosScreen> createState() => _PastaArquivosScreenState();
}

class _PastaArquivosScreenState extends State<PastaArquivosScreen> {
  
  // Dados dinâmicos
  List<Documento> arquivos = [];
  bool isLoading = false;
  String? errorMessage;
  String? pastaId;
  
  @override
  void initState() {
    super.initState();
    _carregarArquivos();
  }
  
  Future<void> _carregarArquivos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      print('🔍 Carregando arquivos da pasta: ${widget.nomePasta}');
      
      // Primeiro, buscar a pasta para obter seu ID
      final pastas = await DocumentoService.getPastas(widget.condominioId);
      final pasta = pastas.firstWhere(
        (p) => p.nome == widget.nomePasta,
        orElse: () => throw Exception('Pasta não encontrada'),
      );
      
      pastaId = pasta.id;
      print('✅ Pasta encontrada: $pastaId');
      
      // Agora buscar os arquivos da pasta
      final arquivosCarregados = await DocumentoService.getArquivosDaPasta(pastaId!);
      
      setState(() {
        arquivos = arquivosCarregados;
        isLoading = false;
      });
      
      print('✅ ${arquivos.length} arquivos carregados');
      for (var arquivo in arquivos) {
        print('📄 ${arquivo.nome} (URL: ${arquivo.url}, Link: ${arquivo.linkExterno})');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar arquivos: $e';
        isLoading = false;
      });
      print('❌ Erro ao carregar arquivos: $e');
    }
  }

  /// Detecta se é um arquivo ou link
  bool _ehArquivo(Documento doc) {
    return doc.url != null && doc.url!.isNotEmpty;
  }

  bool _ehLink(Documento doc) {
    return doc.linkExterno != null && doc.linkExterno!.isNotEmpty;
  }

  /// Verifica se é arquivo de imagem
  bool _isImageFile(String fileName) {
    final ext = fileName.toLowerCase();
    return ext.endsWith('.png') || 
           ext.endsWith('.jpg') || 
           ext.endsWith('.jpeg') ||
           ext.endsWith('.gif') ||
           ext.endsWith('.bmp') ||
           ext.endsWith('.webp');
  }

  /// Retorna o ícone apropriado baseado na extensão
  IconData _getIconForFile(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (fileName.toLowerCase().endsWith('.png') || 
               fileName.toLowerCase().endsWith('.jpg') || 
               fileName.toLowerCase().endsWith('.jpeg') ||
               fileName.toLowerCase().endsWith('.gif')) {
      return Icons.image;
    } else if (fileName.toLowerCase().endsWith('.xlsx') || 
               fileName.toLowerCase().endsWith('.xls')) {
      return Icons.table_chart;
    } else if (fileName.toLowerCase().endsWith('.doc') || 
               fileName.toLowerCase().endsWith('.docx')) {
      return Icons.description;
    } else {
      return Icons.file_present;
    }
  }

  Color _getColorForFile(String fileName) {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return Colors.red;
    } else if (fileName.toLowerCase().endsWith('.png') || 
               fileName.toLowerCase().endsWith('.jpg') || 
               fileName.toLowerCase().endsWith('.jpeg') ||
               fileName.toLowerCase().endsWith('.gif')) {
      return Colors.purple;
    } else if (fileName.toLowerCase().endsWith('.xlsx') || 
               fileName.toLowerCase().endsWith('.xls')) {
      return Colors.green;
    } else if (fileName.toLowerCase().endsWith('.doc') || 
               fileName.toLowerCase().endsWith('.docx')) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  /// Abre o PDF no navegador
  Future<void> _abrirPDFNoNavegador(Documento documento) async {
    try {
      if (documento.url == null || documento.url!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('URL do PDF não disponível'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final String pdfUrl = documento.url!;

      // Tentar abrir no navegador
      final Uri uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o PDF'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Erro ao abrir PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Baixa o arquivo usando DocumentoService (igual ao representante)
  Future<void> _baixarArquivo(Documento documento) async {
    if (!_ehArquivo(documento)) return;

    // Se for imagem, visualizar ao invés de baixar
    if (_isImageFile(documento.nome)) {
      _visualizarImagem(documento);
      return;
    }

    // Se for PDF, abrir no navegador
    if (documento.nome.toLowerCase().endsWith('.pdf')) {
      _abrirPDFNoNavegador(documento);
      return;
    }

    // Para outros tipos de arquivo, fazer download
    try {
      // Na web, mostra mensagem
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download de ${documento.nome} iniciado!')),
        );
        return;
      }

      // Solicitar permissão de armazenamento
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        
        if (status.isDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permissão de armazenamento necessária para baixar arquivos'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
        
        if (status.isPermanentlyDenied) {
          // Abrir configurações do app
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permissão permanentemente negada. Abra as configurações do app.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          openAppSettings();
          return;
        }
      }

      // Mostrar diálogo de progresso
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Baixando ${documento.nome}...'),
                ],
              ),
            );
          },
        );
      }

      // Usar a mesma função do representante
      final filePath = await DocumentoService.downloadArquivo(
        documento.url!,
        documento.nome,
      );

      // Fechar o diálogo de progresso
      if (mounted) Navigator.of(context).pop();

      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${documento.nome} baixado com sucesso'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        print('✅ Arquivo baixado: $filePath');
      }
    } catch (e) {
      // Tentar fechar o diálogo
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      print('❌ Erro ao baixar: $e');
    }
  }

  /// Copia o link para a área de transferência
  Future<void> _copiarLink(Documento documento) async {
    if (!_ehLink(documento)) return;

    try {
      await Clipboard.setData(ClipboardData(text: documento.linkExterno!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link "${documento.nome}" copiado para área de transferência'),
          backgroundColor: Colors.blue,
        ),
      );
      print('✅ Link copiado: ${documento.linkExterno}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao copiar link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Visualiza a imagem em tela cheia com zoom
  void _visualizarImagem(Documento documento) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(0),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(80),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    documento.url ?? '',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.white, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar imagem',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                          ),
                        ],
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArquivoItem(Documento documento) {
    final isArquivo = _ehArquivo(documento);
    final isLink = _ehLink(documento);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForFile(documento.nome),
            color: _getColorForFile(documento.nome),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documento.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (documento.descricao != null && documento.descricao!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      documento.descricao!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          // Botão de ação (Visualizar para imagens, Abrir para PDFs, Copiar para links)
          if (isArquivo)
            GestureDetector(
              onTap: () => _baixarArquivo(documento),
              child: Icon(
                _isImageFile(documento.nome) 
                  ? Icons.visibility 
                  : documento.nome.toLowerCase().endsWith('.pdf')
                    ? Icons.open_in_browser
                    : Icons.download,
                color: _isImageFile(documento.nome) 
                  ? Colors.blue 
                  : documento.nome.toLowerCase().endsWith('.pdf')
                    ? Colors.green
                    : Colors.green,
                size: 20,
              ),
            )
          else if (isLink)
            GestureDetector(
              onTap: () => _copiarLink(documento),
              child: const Icon(
                Icons.content_copy,
                color: Colors.blue,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho superior padronizado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Botão de voltar
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 24),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Spacer(),
                  // Logo CondoGaia
                  Image.asset(
                    'assets/images/logo_CondoGaia.png',
                    height: 32,
                  ),
                  const Spacer(),
                  // Ícones do lado direito
                  Row(
                    children: [
                      // Ícone de notificação
                      GestureDetector(
                        onTap: () {
                          // TODO: Implementar notificações
                        },
                        child: Image.asset(
                          'assets/images/Sino_Notificacao.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Ícone de fone de ouvido
                      GestureDetector(
                        onTap: () {
                          // TODO: Implementar suporte/ajuda
                        },
                        child: Image.asset(
                          'assets/images/Fone_Ouvido_Cabecalho.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Linha de separação
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            
            // Título da página
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Home/Documentos/${widget.nomePasta}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Título da seção
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                widget.nomePasta,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Subtítulo Arquivos
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Arquivos',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Lista de arquivos ou estado de carregamento
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _carregarArquivos,
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          )
                        : arquivos.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder_open,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Nenhum arquivo nesta pasta',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView(
                                children: arquivos.map((arquivo) => _buildArquivoItem(arquivo)).toList(),
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}