import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/documento_service.dart';
import '../services/photo_picker_service.dart';

// Importação condicional de dart:io para mobile/desktop
import 'dart:io' if (kIsWeb) 'dart:async' as io;

// Classe simples para armazenar arquivo na web ou dados binários
class ArquivoTemporario {
  final String nome;
  final Uint8List bytes;

  ArquivoTemporario({
    required this.nome,
    required this.bytes,
  });
}

class NovaPastaScreen extends StatefulWidget {
  final String condominioId;
  final String representanteId;
  
  const NovaPastaScreen({
    super.key,
    required this.condominioId,
    required this.representanteId,
  });

  @override
  State<NovaPastaScreen> createState() => _NovaPastaScreenState();
}

class _NovaPastaScreenState extends State<NovaPastaScreen> {
  final TextEditingController _nomePastaController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  String _privacidade = 'Público';
  List<String> _arquivos = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _linkValido = true;

  // ✨ NOVO: Variáveis para upload de fotos e PDFs
  // Usar dynamic para compatibilidade com Web (File não está disponível na web)
  List<dynamic> _imagensSelecionadas = []; // Pode ser File (mobile) ou XFile/bytes (web)
  List<dynamic> _pdfsTemporarios = []; // Pode ser File ou ArquivoTemporario (web)
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nomePastaController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _criarPasta() async {
    if (_nomePastaController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Nome da pasta é obrigatório';
      });
      return;
    }

    // Validar link se fornecido
    if (_linkController.text.isNotEmpty && !_linkValido) {
      setState(() {
        _errorMessage = 'Link inválido. Deve começar com http://, https:// ou www.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Criar a pasta primeiro
      final pasta = await DocumentoService.criarPasta(
        nome: _nomePastaController.text.trim(),
        privado: _privacidade == 'Privado',
        condominioId: widget.condominioId,
        representanteId: widget.representanteId,
      );
      
      // Adicionar link se fornecido
      if (_linkController.text.isNotEmpty && _linkValido) {
        await DocumentoService.adicionarArquivoComLink(
          nome: 'Link - ${_linkController.text.trim()}',
          linkExterno: _linkController.text.trim(),
          privado: _privacidade == 'Privado',
          pastaId: pasta.id,
          condominioId: widget.condominioId,
          representanteId: widget.representanteId,
        );
      }
      
      // ✨ NOVO: Fazer upload das fotos
      if (_imagensSelecionadas.isNotEmpty) {
        for (dynamic imagem in _imagensSelecionadas) {
          try {
            // Na web, usar ArquivoTemporario; no mobile, usar File
            if (kIsWeb && imagem is ArquivoTemporario) {
              print('[NovaPastaScreen] Upload de Foto (ArquivoTemporario - Web): ${imagem.nome}');
              await DocumentoService.adicionarArquivoComUploadBytes(
                nome: 'Foto_${DateTime.now().millisecondsSinceEpoch}_${imagem.nome}',
                bytes: imagem.bytes,
                descricao: 'Foto adicionada durante criação da pasta',
                privado: _privacidade == 'Privado',
                pastaId: pasta.id,
                condominioId: widget.condominioId,
                representanteId: widget.representanteId,
              );
            } else if (!kIsWeb) {
              // No mobile, o tipo é File
              final imageFile = imagem as dynamic;
              if (imageFile != null) {
                print('[NovaPastaScreen] Upload de Foto (File - Mobile): ${imageFile.path}');
                await DocumentoService.adicionarArquivoComUpload(
                  nome: 'Foto_${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}',
                  arquivo: imageFile,
                  descricao: 'Foto adicionada durante criação da pasta',
                  privado: _privacidade == 'Privado',
                  pastaId: pasta.id,
                  condominioId: widget.condominioId,
                  representanteId: widget.representanteId,
                );
              }
            }
          } catch (e) {
            print('Erro ao fazer upload da foto: $e');
            // Continua o loop mesmo se uma foto falhar
          }
        }
      }
      
      // ✨ NOVO: Fazer upload dos PDFs
      if (_pdfsTemporarios.isNotEmpty) {
        for (dynamic pdfItem in _pdfsTemporarios) {
          try {
            String pdfNome = '';
            
            // Na web, será ArquivoTemporario; no mobile, será File
            if (kIsWeb && pdfItem is ArquivoTemporario) {
              pdfNome = pdfItem.nome;
              print('[NovaPastaScreen] Upload de PDF (ArquivoTemporario - Web): $pdfNome');
              // Na web, usar bytes diretamente
              await DocumentoService.adicionarArquivoComUploadBytes(
                nome: pdfNome,
                bytes: pdfItem.bytes,
                descricao: 'PDF adicionado durante criação da pasta',
                privado: _privacidade == 'Privado',
                pastaId: pasta.id,
                condominioId: widget.condominioId,
                representanteId: widget.representanteId,
              );
            } else if (!kIsWeb) {
              // No mobile, é File
              try {
                final pdfFile = pdfItem as dynamic;
                pdfNome = (pdfFile as dynamic).path.split('/').last;
                print('[NovaPastaScreen] Upload de PDF (File - Mobile): $pdfNome');
                await DocumentoService.adicionarArquivoComUpload(
                  nome: pdfNome,
                  arquivo: pdfFile,
                  descricao: 'PDF adicionado durante criação da pasta',
                  privado: _privacidade == 'Privado',
                  pastaId: pasta.id,
                  condominioId: widget.condominioId,
                  representanteId: widget.representanteId,
                );
              } catch (castError) {
                print('[NovaPastaScreen] ERRO ao fazer cast de PDF: $castError');
              }
            } else {
              print('[NovaPastaScreen] ERRO: Tipo de PDF desconhecido: ${pdfItem.runtimeType}');
            }
          } catch (e) {
            print('Erro ao fazer upload do PDF: $e');
            // Continua o loop mesmo se um PDF falhar
          }
        }
      }
      
      // Preparar mensagem de sucesso antes de limpar
      final temLink = _linkController.text.isNotEmpty;
      final temFotos = _imagensSelecionadas.isNotEmpty;
      final temPDFs = _pdfsTemporarios.isNotEmpty;
      
      // Limpar listas de arquivos temporários
      _imagensSelecionadas.clear();
      _pdfsTemporarios.clear();
      
      if (mounted) {
        Navigator.pop(context, true); // Retorna true para indicar sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pasta criada com sucesso!' +
              (temLink ? ' Link adicionado.' : '') +
              (temFotos ? ' Fotos enviadas.' : '') +
              (temPDFs ? ' PDFs enviados.' : '')
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao criar pasta: $e';
        _isLoading = false;
      });
    }
  }

  // ✨ NOVO: Método para tirar foto com opção de câmera ou galeria
  Future<void> _tirarFoto() async {
    try {
      // Mostrar diálogo com opções
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Selecionar Imagem'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Câmera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeria'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        final _photoPickerService = PhotoPickerService();
        final XFile? image = source == ImageSource.camera
            ? await _photoPickerService.pickImageFromCamera()
            : await _photoPickerService.pickImage();

        if (image != null) {
          // Na web, XFile não pode ser convertido para File
          if (kIsWeb) {
            // Na web, armazenar o XFile diretamente ou seus bytes
            final bytes = await image.readAsBytes();
            setState(() {
              _imagensSelecionadas.add(ArquivoTemporario(
                nome: image.name,
                bytes: bytes,
              ));
            });
          } else {
            // No mobile, converter para File
            // Criar File dinâmico sem tipo explícito
            final imageFile = io.File(image.path);
            setState(() {
              _imagensSelecionadas.add(imageFile);
            });
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto adicionada!')),
            );
          }
        }
      }
    } catch (e) {
      print('[NovaPastaScreen] Erro ao tirar foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao tirar foto: $e')),
        );
      }
    }
  }

  // ✨ NOVO: Método para selecionar PDF
  Future<void> _selecionarPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null) {
        try {
          final fileName = result.files.single.name;
          
          // Na web, armazenar bytes diretamente
          if (kIsWeb) {
            final bytes = result.files.single.bytes;
            if (bytes != null) {
              print('[NovaPastaScreen] PDF selecionado na WEB: $fileName (${bytes.length} bytes)');
              setState(() {
                _pdfsTemporarios.add(ArquivoTemporario(
                  nome: fileName,
                  bytes: bytes,
                ));
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ PDF "$fileName" selecionado!'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
              return;
            } else {
              throw Exception('Não foi possível ler os bytes do arquivo na web');
            }
          } 
          
          // No mobile/desktop, usar caminho do arquivo
          if (result.files.single.path != null) {
            // Criar File dinâmico sem tipo explícito
            final originalFile = io.File(result.files.single.path!);
            
            // Verificar se existe (apenas no mobile)
            bool fileExists = false;
            try {
              fileExists = await originalFile.exists();
            } catch (e) {
              print('[NovaPastaScreen] Não foi possível verificar existência do arquivo: $e');
              fileExists = true; // Assumir que existe
            }
            
            if (!fileExists) {
              print('[NovaPastaScreen] ERRO: Arquivo não encontrado em ${result.files.single.path}');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro: Arquivo não encontrado no caminho especificado.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }

            print('[NovaPastaScreen] PDF selecionado no MOBILE: $fileName');
            print('[NovaPastaScreen] Tipo do arquivo: ${originalFile.runtimeType}');
            try {
              print('[NovaPastaScreen] Caminho: ${originalFile.path}');
            } catch (e) {
              print('[NovaPastaScreen] Não foi possível acessar path: $e');
            }
            
            setState(() {
              _pdfsTemporarios.add(originalFile);
              print('[NovaPastaScreen] Arquivo adicionado à lista. Total de PDFs: ${_pdfsTemporarios.length}');
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ PDF "$fileName" selecionado!'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          } else {
            throw Exception('Caminho do arquivo não disponível no mobile');
          }
        } catch (copyError) {
          print('[NovaPastaScreen] Erro ao processar PDF: $copyError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao processar PDF: $copyError'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('[NovaPastaScreen] Erro ao selecionar PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✨ NOVO: Método para remover arquivo
  void _removerArquivo(dynamic arquivo) {
    setState(() {
      _imagensSelecionadas.remove(arquivo);
      _pdfsTemporarios.remove(arquivo);
    });
  }

  // ✨ NOVO: Método para obter nome do arquivo (compatível com File e ArquivoTemporario)
  String _obterNomeArquivo(dynamic arquivo) {
    if (arquivo is ArquivoTemporario) {
      return arquivo.nome;
    } else {
      // No mobile, é File - tentar acessar o path
      try {
        return (arquivo as dynamic).path.split('/').last;
      } catch (e) {
        return 'Arquivo desconhecido';
      }
    }
  }

  // Método para validar link em tempo real
  void _validarLink(String link) {
    setState(() {
      _linkValido = link.isEmpty || 
                   link.startsWith('http://') || 
                   link.startsWith('https://') ||
                   link.startsWith('www.');
    });
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
              child: const Text(
                'Home/Documentos/NovaPasta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Conteúdo da tela
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção Adicionar Nova Pasta
                    const Text(
                      'Adicionar Nova Pasta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Campo Nome da Pasta
                    Row(
                      children: [
                        const Text(
                          'Nome da Pasta:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nomePastaController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Seção Privacidade
                    const Text(
                      'Privacidade:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Público',
                          groupValue: _privacidade,
                          onChanged: (value) {
                            setState(() {
                              _privacidade = value!;
                            });
                          },
                          activeColor: const Color(0xFF1E3A8A),
                        ),
                        const Text('Público'),
                        const SizedBox(width: 24),
                        Radio<String>(
                          value: 'Privado',
                          groupValue: _privacidade,
                          onChanged: (value) {
                            setState(() {
                              _privacidade = value!;
                            });
                          },
                          activeColor: const Color(0xFF1E3A8A),
                        ),
                        const Text('Privado'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Seção Link Externo
                    const Text(
                      'Link Externo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Campo Link
                    const Text(
                      'Link:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _linkController,
                      onChanged: _validarLink,
                      decoration: InputDecoration(
                        hintText: 'https://exemplo.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _linkController.text.isNotEmpty && !_linkValido 
                                ? Colors.red 
                                : Colors.grey[300]!
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _linkController.text.isNotEmpty && !_linkValido 
                                ? Colors.red 
                                : Colors.grey[300]!
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _linkController.text.isNotEmpty && !_linkValido 
                                ? Colors.red 
                                : const Color(0xFF1E3A8A)
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        suffixIcon: _linkController.text.isNotEmpty
                            ? Icon(
                                _linkValido ? Icons.check_circle : Icons.error,
                                color: _linkValido ? Colors.green : Colors.red,
                              )
                            : null,
                      ),
                    ),
                    if (_linkController.text.isNotEmpty && !_linkValido)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Link deve começar com http://, https:// ou www.',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    
                    // ✨ NOVO: Seção Arquivos (Fotos e PDFs)
                    const Text(
                      'Adicionar Arquivos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Botões para adicionar fotos e PDFs (idênticos aos da edição)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _tirarFoto,
                            icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF1E3A8A)),
                            label: const Text(
                              'Tirar foto',
                              style: TextStyle(color: Color(0xFF1E3A8A)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1E3A8A)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _selecionarPDF,
                            icon: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
                            label: const Text(
                              'Fazer Upload PDF',
                              style: TextStyle(color: Colors.blue),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Lista de imagens selecionadas
                    if (_imagensSelecionadas.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fotos Selecionadas:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._imagensSelecionadas.map((imagem) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                border: Border.all(color: Colors.blue[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.image, color: Colors.blue[700]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _obterNomeArquivo(imagem),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () => _removerArquivo(imagem),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    
                    // Lista de PDFs selecionados
                    if (_pdfsTemporarios.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PDFs Selecionados:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._pdfsTemporarios.map((pdfItem) {
                            String pdfNome = '';
                            if (pdfItem is ArquivoTemporario) {
                              pdfNome = pdfItem.nome;
                            } else {
                              // No mobile, é File (dinâmico)
                              try {
                                pdfNome = (pdfItem as dynamic).path.split('/').last;
                              } catch (e) {
                                pdfNome = 'PDF desconhecido';
                              }
                            }
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                border: Border.all(color: Colors.red[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.picture_as_pdf, color: Colors.red[700]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      pdfNome,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _pdfsTemporarios.remove(pdfItem);
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    
                    // Mensagem de erro
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Botão Criar Pasta
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _criarPasta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Criar Pasta',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Seção Arquivos
                    const Text(
                      'Arquivos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _arquivos.isEmpty
                        ? const Text(
                            'Nenhum',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          )
                        : Column(
                            children: _arquivos.map((arquivo) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        arquivo,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _arquivos.remove(arquivo);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}