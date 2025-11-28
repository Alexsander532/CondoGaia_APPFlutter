import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'editar_documentos_screen.dart';
import 'nova_pasta_screen.dart';
import '../models/documento.dart';
import '../models/balancete.dart';
import '../services/documento_service.dart';
import '../services/photo_picker_service.dart';
import '../utils/download_helper.dart';

// Importação condicional de dart:io para mobile/desktop
import 'dart:io' if (kIsWeb) 'dart:async' as io;

// Classe ArquivoTemporario já está definida em editar_documentos_screen.dart
// mas precisamos redefinir aqui para esta tela
class ArquivoTemporarioBalancete {
  final String nome;
  final Uint8List bytes;

  ArquivoTemporarioBalancete({
    required this.nome,
    required this.bytes,
  });
}

class DocumentosScreen extends StatefulWidget {
  final String? condominioId;
  final String? representanteId;
  
  const DocumentosScreen({
    super.key,
    this.condominioId,
    this.representanteId,
  });

  @override
  State<DocumentosScreen> createState() => _DocumentosScreenState();
}

class _DocumentosScreenState extends State<DocumentosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Dados dinâmicos
  List<Documento> pastas = [];
  List<Balancete> balancetes = [];
  bool isLoading = false;
  String? errorMessage;
  
  // IDs para operações
  String get condominioId => widget.condominioId ?? 'demo-condominio-id';
  String get representanteId => widget.representanteId ?? 'demo-representante-id';
  
  // Controle de período para balancetes
  int _anoSelecionado = 2025;
  int _mesSelecionado = DateTime.now().month; // Mês atual
  
  String selectedPrivacy = 'Público';
  final TextEditingController _linkController = TextEditingController();
  
  // Controle de arquivos temporários
  // Usar dynamic para compatibilidade com Web (File não está disponível na web)
  List<dynamic> _imagensTemporarias = []; // Pode ser File (mobile) ou ArquivoTemporarioBalancete (web)
  List<dynamic> _pdfsTemporarios = []; // Pode ser File (mobile) ou ArquivoTemporarioBalancete (web)
  bool _linkValido = false;
  bool _isUploadingFile = false;
  final _photoPickerService = PhotoPickerService();
  
  // Lista de meses para exibição
  final List<String> _nomesMeses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarDados();
  }
  
  Future<void> _carregarDados() async {
    await Future.wait([
      _carregarPastas(),
      _carregarBalancetes(),
    ]);
  }
  
  Future<void> _carregarPastas() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      // Usar getPastasRepresentante para mostrar pastas públicas + privadas
      final pastasCarregadas = await DocumentoService.getPastasRepresentante(condominioId);
      setState(() {
        pastas = pastasCarregadas;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar pastas: $e';
        isLoading = false;
      });
    }
  }
  
  Future<void> _carregarBalancetes() async {
    try {
      final balancetesCarregados = await DocumentoService.getBalancetesPorPeriodo(
        condominioId,
        _mesSelecionado,
        _anoSelecionado,
      );
      setState(() {
        balancetes = balancetesCarregados;
      });
    } catch (e) {
      print('Erro ao carregar balancetes: $e');
    }
  }
  
  // Métodos de navegação de período
  void _navegarMesAnterior() {
    setState(() {
      if (_mesSelecionado == 1) {
        _mesSelecionado = 12;
        _anoSelecionado--;
      } else {
        _mesSelecionado--;
      }
    });
    _carregarBalancetes(); // Recarregar balancetes do novo período
  }
  
  void _navegarProximoMes() {
    setState(() {
      if (_mesSelecionado == 12) {
        _mesSelecionado = 1;
        _anoSelecionado++;
      } else {
        _mesSelecionado++;
      }
    });
    _carregarBalancetes(); // Recarregar balancetes do novo período
  }
  
  String get _periodoAtual => '${_nomesMeses[_mesSelecionado - 1]}/$_anoSelecionado';
  
  // Método para mostrar opções de foto (câmera ou galeria)
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
        setState(() {
          isLoading = true;
        });

        final XFile? image = source == ImageSource.camera
            ? await _photoPickerService.pickImageFromCamera()
            : await _photoPickerService.pickImage();

        if (image != null) {
          // Adicionar balancete com upload da imagem (passar XFile diretamente)
          await DocumentoService.adicionarBalanceteComUpload(
            arquivo: image,
            nomeArquivo: 'Foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
            mes: _mesSelecionado.toString(),
            ano: _anoSelecionado.toString(),
            privado: selectedPrivacy == 'Privado',
            condominioId: condominioId,
            representanteId: representanteId,
          );

          // Recarregar a lista de balancetes
          await _carregarBalancetes();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto adicionada com sucesso!')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao tirar foto: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Método para selecionar imagem da galeria (funciona na web e mobile)
  // Método para adicionar link como balancete
  Future<void> _adicionarLink() async {
    // Validar se o link não está vazio
    if (_linkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um link')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      // Adicionar balancete com link
      await DocumentoService.adicionarBalancete(
        nomeArquivo: 'Link_${DateTime.now().millisecondsSinceEpoch}',
        linkExterno: _linkController.text.trim(),
        mes: _mesSelecionado.toString(),
        ano: _anoSelecionado.toString(),
        privado: selectedPrivacy == 'Privado',
        condominioId: condominioId,
        representanteId: representanteId,
      );

      // Limpar o campo de link
      if (mounted) {
        _linkController.clear();
      }

      // Recarregar a lista de balancetes
      await _carregarBalancetes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link adicionado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar link: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Métodos auxiliares para balancetes
  Future<void> _editarNomeBalancete(Balancete balancete) async {
    // Extrair nome sem extensão
    final nomeOriginal = balancete.nomeArquivo;
    final ultimoPonto = nomeOriginal.lastIndexOf('.');
    final nomeSemExtensao = ultimoPonto != -1 
      ? nomeOriginal.substring(0, ultimoPonto) 
      : nomeOriginal;
    final extensao = ultimoPonto != -1 
      ? nomeOriginal.substring(ultimoPonto) 
      : '';
    
    final TextEditingController nomeController = TextEditingController(text: nomeSemExtensao);
    
    final novoNomeSemExt = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Nome'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do arquivo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Mostrar a extensão como texto fixo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Extensão: ',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    TextSpan(
                      text: extensao,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nomeController.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    
    if (novoNomeSemExt != null && novoNomeSemExt.isNotEmpty) {
      final novoNomeCompleto = '$novoNomeSemExt$extensao';
      if (novoNomeCompleto != balancete.nomeArquivo) {
        try {
          await DocumentoService.atualizarBalancete(
            balancete.id,
            nomeArquivo: novoNomeCompleto,
          );
          
          await _carregarBalancetes();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nome atualizado com sucesso!')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao atualizar nome: $e')),
            );
          }
        }
      }
    }
    
    nomeController.dispose();
  }

  Future<void> _copiarLinkBalancete(Balancete balancete) async {
    try {
      String? linkParaCopiar;
      
      if (balancete.linkExterno != null && balancete.linkExterno!.isNotEmpty) {
        linkParaCopiar = balancete.linkExterno;
      } else if (balancete.url != null && balancete.url!.isNotEmpty) {
        linkParaCopiar = balancete.url;
      }
      
      if (linkParaCopiar != null) {
        await Clipboard.setData(ClipboardData(text: linkParaCopiar));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link copiado para a área de transferência!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum link disponível para copiar')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao copiar link: $e')),
        );
      }
    }
  }

  // Método para baixar balancete
  Future<void> _baixarBalancete(Balancete balancete) async {
    try {
      setState(() {
        isLoading = true;
      });

      String? filePath;
      String fileName = balancete.nomeArquivo ?? 'balancete_${balancete.mes}_${balancete.ano}.png';

      if (balancete.url != null) {
        // Verificar se é um arquivo local
        if (balancete.url!.startsWith('file://') || !balancete.url!.startsWith('http')) {
          // É um arquivo local - copiar para Downloads
          filePath = await DocumentoService.copiarArquivoLocal(
            balancete.url!,
            fileName,
          );
        } else if (balancete.url!.contains('supabase')) {
          // Se for arquivo do Supabase, usar método específico
          filePath = await DocumentoService.downloadArquivoSupabase(
            balancete.url!,
            fileName,
          );
        } else {
          // Para outros URLs, usar download direto
          filePath = await DocumentoService.downloadArquivo(
            balancete.url!,
            fileName,
          );
        }
      } else if (balancete.linkExterno != null) {
        // Verificar se é um arquivo local
        if (balancete.linkExterno!.startsWith('file://') || !balancete.linkExterno!.startsWith('http')) {
          // É um arquivo local - copiar para Downloads
          filePath = await DocumentoService.copiarArquivoLocal(
            balancete.linkExterno!,
            fileName,
          );
        } else {
          // Para links externos, usar download direto
          filePath = await DocumentoService.downloadArquivo(
            balancete.linkExterno!,
            fileName,
          );
        }
      }

      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arquivo baixado: $fileName'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {
                // Aqui poderia abrir o arquivo ou mostrar sua localização
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar arquivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool _isLinkExternoBalancete(Balancete balancete) {
    return balancete.linkExterno != null && balancete.linkExterno!.isNotEmpty;
  }

  bool _isImagemBalancete(Balancete balancete) {
    final extensoesImagem = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final nomeArquivo = balancete.nomeArquivo ?? '';
    return extensoesImagem.any((ext) => nomeArquivo.toLowerCase().endsWith(ext));
  }

  bool _isPDFBalancete(Balancete balancete) {
    final nomeArquivo = balancete.nomeArquivo ?? '';
    return nomeArquivo.toLowerCase().endsWith('.pdf');
  }

  // Novos métodos para funcionalidades aprimoradas
  
  // Validação de link em tempo real
  void _validarLink(String link) {
    setState(() {
      _linkValido = link.isNotEmpty && Uri.tryParse(link) != null;
    });
  }

  // Método aprimorado para tirar foto com opções
  Future<void> _selecionarImagem() async {
    try {
      // Verificar permissões
      final cameraStatus = await Permission.camera.request();
      final storageStatus = await Permission.storage.request();
      
      if (cameraStatus.isDenied || storageStatus.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissões necessárias não foram concedidas')),
          );
        }
        return;
      }

      // Mostrar opções de fonte
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
        setState(() {
          _isUploadingFile = true;
        });

        final XFile? image = source == ImageSource.camera
            ? await _photoPickerService.pickImageFromCamera()
            : await _photoPickerService.pickImage();

        if (image != null) {
          // Na web, usar bytes; no mobile, usar File
          if (kIsWeb) {
            final bytes = await image.readAsBytes();
            setState(() {
              _imagensTemporarias.add(ArquivoTemporarioBalancete(
                nome: image.name,
                bytes: bytes,
              ));
            });
          } else {
            // No mobile, criar File dinamicamente
            final imageFile = (io.File as dynamic)(image.path);
            setState(() {
              _imagensTemporarias.add(imageFile);
            });
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Imagem adicionada! Clique em "Salvar" para confirmar.')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingFile = false;
        });
      }
    }
  }

  // Método para selecionar PDF
  Future<void> _selecionarPDF() async {
    try {
      setState(() {
        _isUploadingFile = true;
      });

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
              print('[DocumentosScreen] PDF selecionado na WEB: $fileName (${bytes.length} bytes)');
              setState(() {
                _pdfsTemporarios.add(ArquivoTemporarioBalancete(
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
            // Obter o arquivo original
            final originalFile = (io.File as dynamic)(result.files.single.path!);
            
            // Verificar se o arquivo existe
            bool fileExists = false;
            try {
              fileExists = await (originalFile as dynamic).exists();
            } catch (e) {
              print('[DocumentosScreen] Não foi possível verificar existência: $e');
              fileExists = true; // Assumir que existe
            }
            
            if (!fileExists) {
              print('[DocumentosScreen] ERRO: Arquivo não encontrado em ${result.files.single.path}');
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

            // Copiar arquivo para diretório temporário da app (necessário no Android)
            final appDocDir = await getApplicationDocumentsDirectory();
            final tempDir = (io.Directory as dynamic)('${appDocDir.path}/pdf_temporarios');
            
            bool tempDirExists = false;
            try {
              tempDirExists = await (tempDir as dynamic).exists();
            } catch (e) {
              tempDirExists = false;
            }
            
            if (!tempDirExists) {
              await (tempDir as dynamic).create(recursive: true);
            }

            final copiedFile = (io.File as dynamic)('${(tempDir as dynamic).path}/$fileName');
            
            // Copiar conteúdo do arquivo
            final bytes = await (originalFile as dynamic).readAsBytes();
            await (copiedFile as dynamic).writeAsBytes(bytes);

            print('[DocumentosScreen] PDF copiado com sucesso');
            print('[DocumentosScreen] Tamanho do arquivo: ${bytes.length} bytes');

            // Adicionar arquivo copiado à lista
            setState(() {
              _pdfsTemporarios.add(copiedFile);
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ PDF "$fileName" selecionado!\nClique em "Salvar" para importar o PDF selecionado.'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          } else {
            throw Exception('Caminho do arquivo não disponível no mobile');
          }
        } catch (copyError) {
          print('Erro ao copiar PDF: $copyError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao copiar PDF: $copyError'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingFile = false;
        });
      }
    }
  }

  // Método para remover arquivo temporário
  void _removerArquivoTemporario(dynamic arquivo) {
    setState(() {
      _imagensTemporarias.remove(arquivo);
      _pdfsTemporarios.remove(arquivo);
    });
  }

  // Método para obter nome do arquivo (compatível com File e ArquivoTemporarioBalancete)
  String _obterNomeArquivo(dynamic arquivo) {
    if (arquivo is ArquivoTemporarioBalancete) {
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

  // Método aprimorado para salvar todos os arquivos
  Future<void> _salvarArquivos() async {
    // Verificar se há algo para salvar
    final temLink = _linkController.text.trim().isNotEmpty && _linkValido;
    final temImagens = _imagensTemporarias.isNotEmpty;
    final temPDFs = _pdfsTemporarios.isNotEmpty;

    print('[DocumentosScreen] Iniciando salvamento de arquivos');
    print('[DocumentosScreen] Tem Link: $temLink');
    print('[DocumentosScreen] Tem Imagens: $temImagens (${_imagensTemporarias.length})');
    print('[DocumentosScreen] Tem PDFs: $temPDFs (${_pdfsTemporarios.length})');

    if (!temLink && !temImagens && !temPDFs) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um arquivo ou link antes de salvar')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      // Salvar link se existir
      if (temLink) {
        print('[DocumentosScreen] Salvando link: ${_linkController.text.trim()}');
        await DocumentoService.adicionarBalancete(
          nomeArquivo: 'Link_${DateTime.now().millisecondsSinceEpoch}',
          linkExterno: _linkController.text.trim(),
          mes: _mesSelecionado.toString(),
          ano: _anoSelecionado.toString(),
          privado: selectedPrivacy == 'Privado',
          condominioId: condominioId,
          representanteId: representanteId,
        );
        print('[DocumentosScreen] Link salvo com sucesso!');
      }

      // Salvar imagens
      print('[DocumentosScreen] Processando ${_imagensTemporarias.length} imagens...');

      for (dynamic imagem in _imagensTemporarias) {
        try {
          // Na web, será ArquivoTemporarioBalancete; no mobile, será File
          if (kIsWeb && imagem is ArquivoTemporarioBalancete) {
            print('[DocumentosScreen] Salvando imagem (Web): ${imagem.nome}');
            await DocumentoService.adicionarBalanceteComUploadBytes(
              bytes: imagem.bytes,
              nomeArquivo: imagem.nome,
              mes: _mesSelecionado.toString(),
              ano: _anoSelecionado.toString(),
              privado: selectedPrivacy == 'Privado',
              condominioId: condominioId,
              representanteId: representanteId,
            );
          } else if (!kIsWeb) {
            // No mobile
            final imagePath = (imagem as dynamic).path;
            print('[DocumentosScreen] Salvando imagem (Mobile): $imagePath');
            await DocumentoService.adicionarBalanceteComUpload(
              arquivo: imagem,
              nomeArquivo: 'Imagem_${DateTime.now().millisecondsSinceEpoch}.jpg',
              mes: _mesSelecionado.toString(),
              ano: _anoSelecionado.toString(),
              privado: selectedPrivacy == 'Privado',
              condominioId: condominioId,
              representanteId: representanteId,
            );
          }
          print('[DocumentosScreen] Imagem salva com sucesso!');
        } catch (e) {
          print('[DocumentosScreen] ERRO ao salvar imagem: $e');
          rethrow;
        }
      }

      // Salvar PDFs
      print('[DocumentosScreen] Processando ${_pdfsTemporarios.length} PDFs...');
      for (dynamic pdf in _pdfsTemporarios) {
        try {
          // Na web, será ArquivoTemporarioBalancete; no mobile, será File
          if (kIsWeb && pdf is ArquivoTemporarioBalancete) {
            print('[DocumentosScreen] Salvando PDF (Web): ${pdf.nome}');
            await DocumentoService.adicionarBalanceteComUploadBytes(
              bytes: pdf.bytes,
              nomeArquivo: pdf.nome,
              mes: _mesSelecionado.toString(),
              ano: _anoSelecionado.toString(),
              privado: selectedPrivacy == 'Privado',
              condominioId: condominioId,
              representanteId: representanteId,
            );
          } else if (!kIsWeb) {
            // No mobile
            final pdfPath = (pdf as dynamic).path;
            final nomeOriginalPDF = pdfPath.split('/').last;
            print('[DocumentosScreen] Salvando PDF (Mobile): $nomeOriginalPDF');
            await DocumentoService.adicionarBalanceteComUpload(
              arquivo: pdf,
              nomeArquivo: nomeOriginalPDF,
              mes: _mesSelecionado.toString(),
              ano: _anoSelecionado.toString(),
              privado: selectedPrivacy == 'Privado',
              condominioId: condominioId,
              representanteId: representanteId,
            );
          }
          print('[DocumentosScreen] PDF salvo com sucesso!');
        } catch (e) {
          print('[DocumentosScreen] ERRO ao salvar PDF: $e');
          rethrow;
        }
      }

      // Limpar campos e arquivos temporários
      if (mounted) {
        _linkController.clear();
        setState(() {
          _imagensTemporarias.clear();
          _pdfsTemporarios.clear();
          _linkValido = false;
        });
      }

      // Recarregar balancetes
      print('[DocumentosScreen] Recarregando balancetes...');
      await _carregarBalancetes();
      print('[DocumentosScreen] Balancetes recarregados com sucesso!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arquivos salvos com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      print('[DocumentosScreen] Todos os arquivos foram salvos com sucesso!');
    } catch (e) {
      print('[DocumentosScreen] ERRO geral ao salvar arquivos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar arquivos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    try {
      _tabController.dispose();
    } catch (e) {
      print('[DocumentosScreen] Erro ao descartar TabController: $e');
    }
    
    try {
      _linkController.dispose();
    } catch (e) {
      print('[DocumentosScreen] Erro ao descartar LinkController: $e');
    }
    
    super.dispose();
  }

  Widget _buildPastaItem(Documento pasta) {
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
            Icons.folder,
            color: pasta.privado ? Colors.red : Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pasta.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (pasta.descricao != null && pasta.descricao!.isNotEmpty)
                  Text(
                    pasta.descricao!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            pasta.privado ? 'Privado' : 'Público',
            style: TextStyle(
              fontSize: 12,
              color: pasta.privado ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarDocumentosScreen(
                    pasta: pasta,
                    condominioId: condominioId,
                    representanteId: representanteId,
                    onPastaAtualizada: _carregarPastas,
                  ),
                ),
              );
            },
            child: const Icon(
              Icons.edit,
              color: Colors.grey,
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
            
            // Título da página dinâmico
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    _tabController.index == 0 ? 'Home/Documentos' : 'Home/Anexar Balancete',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
            
            // TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1E3A8A),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: const Color(0xFF1E3A8A),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'Pastas de Documento'),
                  Tab(text: 'Anexo Balancete'),
                ],
              ),
            ),
            
            // Conteúdo das abas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDocumentosTab(),
                  _buildBalanceteTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDocumentosTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          if (errorMessage != null)
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
                      errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _carregarPastas,
                  ),
                ],
              ),
            ),
          
          // Lista de pastas
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      ...pastas.map((pasta) => _buildPastaItem(pasta)),
                      const SizedBox(height: 20),
              
                      // Botão Adicionar Nova Pasta
                      GestureDetector(
                        onTap: () async {
                          final resultado = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NovaPastaScreen(
                                condominioId: condominioId,
                                representanteId: representanteId,
                              ),
                            ),
                          );
                          
                          if (resultado == true) {
                            _carregarPastas();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Adicionar',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Text(
                                'Nova Pasta',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBalanceteTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Título da seção
            const Text(
              'Anexo Balancete',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A8A),
              ),
            ),
          const SizedBox(height: 20),
          
          // Seletor de Mês/Ano
          Row(
            children: [
              IconButton(
                onPressed: _navegarMesAnterior,
                icon: const Icon(Icons.chevron_left, color: Color(0xFF1E3A8A)),
              ),
              Expanded(
                child: Text(
                  _periodoAtual,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
              IconButton(
                onPressed: _navegarProximoMes,
                icon: const Icon(Icons.chevron_right, color: Color(0xFF1E3A8A)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Privacidade
          Row(
            children: [
              const Text(
                'Privacidade:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Radio<String>(
                    value: 'Público',
                    groupValue: selectedPrivacy,
                    onChanged: (value) {
                      setState(() {
                        selectedPrivacy = value!;
                      });
                    },
                  ),
                  const Text('Público'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'Privado',
                    groupValue: selectedPrivacy,
                    onChanged: (value) {
                      setState(() {
                        selectedPrivacy = value!;
                      });
                    },
                  ),
                  const Text('Privado'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Adicionar Arquivos
          const Text(
            'Adicionar Arquivos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          
          // Campo Link
          TextField(
            controller: _linkController,
            decoration: InputDecoration(
              labelText: 'Link:',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Botões de ação
          Row(
            children: [
              // Botão de tirar foto
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: isLoading ? null : _tirarFoto,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isLoading ? Colors.grey[200] : const Color(0xFF1E3A8A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isLoading ? Colors.grey[300]! : const Color(0xFF1E3A8A)),
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 30,
                          color: isLoading ? Colors.grey : const Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tirar foto',
                      style: TextStyle(
                        fontSize: 12,
                        color: isLoading ? Colors.grey : const Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Botão de upload PDF
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: isLoading ? null : _selecionarPDF,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isLoading ? Colors.grey[200] : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isLoading ? Colors.grey[300]! : Colors.blue),
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          size: 30,
                          color: isLoading ? Colors.grey : Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload PDF',
                      style: TextStyle(
                        fontSize: 12,
                        color: isLoading ? Colors.grey : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Botão Adicionar arquivo
          Center(
            child: ElevatedButton(
              onPressed: isLoading ? null : _salvarArquivos,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Preview de PDFs selecionados
          if (_pdfsTemporarios.isNotEmpty) ...[
            const Text(
              'PDFs Selecionados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 10),
            ...(_pdfsTemporarios.map((pdf) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _obterNomeArquivo(pdf),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removerArquivoTemporario(pdf),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            }).toList()),
            const SizedBox(height: 20),
          ],
          
          // Lista de Arquivos
          const Text(
            'Arquivos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          
          if (balancetes.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: Text(
                  'Nenhum balancete encontrado',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...balancetes.map((balancete) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            balancete.nomeArquivo,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${balancete.mes}/${balancete.ano}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Ícone de editar nome
                    GestureDetector(
                      onTap: () => _editarNomeBalancete(balancete),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Ações baseadas no tipo de arquivo
                    if (_isLinkExternoBalancete(balancete))
                      // Para links externos: apenas copiar
                      GestureDetector(
                        onTap: () => _copiarLinkBalancete(balancete),
                        child: const Icon(
                          Icons.copy,
                          color: Colors.orange,
                          size: 20,
                        ),
                      )
                    else if (_isPDFBalancete(balancete))
                      // Para PDFs: download
                      GestureDetector(
                        onTap: () => _baixarPDFBalancete(balancete),
                        child: const Icon(
                          Icons.download,
                          color: Colors.green,
                          size: 20,
                        ),
                      )
                    else if (_isImagemBalancete(balancete))
                      // Para imagens: visualizar
                      GestureDetector(
                        onTap: () => _visualizarImagemBalancete(balancete),
                        child: const Icon(
                          Icons.visibility,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text('Deseja realmente deletar este balancete?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Deletar'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirmar == true) {
                          try {
                            await DocumentoService.deletarBalancete(balancete.id);
                            _carregarBalancetes();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Balancete removido com sucesso')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro ao remover balancete: $e')),
                              );
                            }
                          }
                        }
                      },
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Função para visualizar imagem ou PDF ampliado
  void _visualizarImagemBalancete(Balancete balancete) {
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
                    balancete.url ?? '',
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

  // Função para baixar PDF do balancete
  Future<void> _baixarPDFBalancete(Balancete balancete) async {
    try {
      if (balancete.url == null || balancete.url!.isEmpty) {
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

      final String pdfUrl = balancete.url!;
      final String fileName = balancete.nomeArquivo ?? 'balancete_${balancete.mes}_${balancete.ano}.pdf';

      // Verificar se é web
      if (kIsWeb) {
        _downloadPDFWeb(pdfUrl, fileName);
      } else {
        // Para Android e iOS
        await _downloadPDFMobile(pdfUrl, fileName);
      }
    } catch (e) {
      print('Erro ao baixar PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Download para Web
  void _downloadPDFWeb(String pdfUrl, String fileName) {
    if (kIsWeb) {
      // Usar o helper para download de PDF na web
      DownloadHelper.downloadPdfFromUrl(pdfUrl, fileName, context);
    }
  }

  // Download para Mobile (Android e iOS)
  Future<void> _downloadPDFMobile(String pdfUrl, String fileName) async {
    // Obter o diretório de downloads
    final dynamic downloadsDir = await _getDownloadsDirectory();
    
    if (downloadsDir == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível acessar pasta de downloads'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Garantir que o diretório existe
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final String filePath = '${downloadsDir.path}/$fileName';

    // Fazer download usando Dio
    final Dio dio = Dio();
    
    print('Iniciando download: $pdfUrl → $filePath');
    
    await dio.download(
      pdfUrl,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final progress = (received / total * 100).toStringAsFixed(0);
          print('Download em andamento: $progress%');
        }
      },
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ PDF "$fileName" salvo em Downloads'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    
    print('Download concluído: $filePath');
  }

  // Obter diretório de Downloads (funciona em Android e iOS)
  Future<dynamic> _getDownloadsDirectory() async {
    if (kIsWeb) {
      return null; // Na web não há diretório de downloads
    }
    
    try {
      // No Android, usa Documents directory que funciona melhor
      // No iOS, usa Documents também
      final platformCheck = await _isAndroid();
      if (platformCheck) {
        // Tenta obter o diretório de downloads
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          // Tenta retornar /storage/emulated/0/Download se possível
          final downloadPath = '/storage/emulated/0/Download';
          final downloadDir = (io.Directory as dynamic)(downloadPath);
          bool exists = false;
          try {
            exists = await (downloadDir as dynamic).exists();
          } catch (e) {
            exists = false;
          }
          
          if (exists) {
            return downloadDir;
          }
          // Fallback para app documents
          return directory;
        }
      }
      // Para iOS ou se Android falhar
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      print('Erro ao obter diretório de downloads: $e');
      return null;
    }
  }

  // Método auxiliar para verificar se é Android
  Future<bool> _isAndroid() async {
    if (kIsWeb) return false;
    try {
      return (io.Platform as dynamic).isAndroid;
    } catch (e) {
      return false;
    }
  }
}