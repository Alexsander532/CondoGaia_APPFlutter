import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../models/documento.dart';
import '../services/documento_service.dart';
import '../utils/download_helper.dart';

class EditarDocumentosScreen extends StatefulWidget {
  final Documento pasta;
  final String condominioId;
  final String representanteId;
  final VoidCallback? onPastaAtualizada;

  const EditarDocumentosScreen({
    Key? key,
    required this.pasta,
    required this.condominioId,
    required this.representanteId,
    this.onPastaAtualizada,
  }) : super(key: key);

  @override
  _EditarDocumentosScreenState createState() => _EditarDocumentosScreenState();
}

class _EditarDocumentosScreenState extends State<EditarDocumentosScreen> {
  late TextEditingController _nomePastaController;
  late TextEditingController _linkController;
  String _privacidade = 'Público';
  
  List<Documento> _arquivos = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nomePastaController = TextEditingController(text: widget.pasta.nome);
    _linkController = TextEditingController();
    _privacidade = widget.pasta.privado ? 'Privado' : 'Público';
    _carregarArquivos();
  }
  
  Future<void> _carregarArquivos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final arquivos = await DocumentoService.getArquivosDaPasta(widget.pasta.id);
      setState(() {
        _arquivos = arquivos;
        _isLoading = false;
      });
    } catch (e) {
       setState(() {
         _errorMessage = 'Erro ao carregar arquivos: $e';
         _isLoading = false;
       });
     }
   }

  // Método para editar nome do arquivo
  Future<void> _editarNomeArquivo(Documento arquivo) async {
    // Extrair nome sem extensão
    final nomeOriginal = arquivo.nome;
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Nome do Arquivo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do arquivo',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
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
            ElevatedButton(
              onPressed: () {
                if (nomeController.text.trim().isNotEmpty) {
                  Navigator.pop(context, nomeController.text.trim());
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (novoNomeSemExt != null && novoNomeSemExt.isNotEmpty) {
      final novoNomeCompleto = '$novoNomeSemExt$extensao';
      if (novoNomeCompleto != arquivo.nome) {
        try {
          setState(() => _isLoading = true);
          
          // Atualizar o nome do arquivo no banco
          await DocumentoService.atualizarDocumento(
            arquivo.id,
            nome: novoNomeCompleto,
          );
          
          // Recarregar a lista de arquivos
          await _carregarArquivos();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nome do arquivo atualizado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao atualizar nome: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    }
    
    nomeController.dispose();
  }

  // Método para copiar link para área de transferência
  Future<void> _copiarLink(Documento arquivo) async {
    final link = arquivo.linkExterno ?? arquivo.url;
    if (link != null) {
      try {
        await Clipboard.setData(ClipboardData(text: link));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link copiado para a área de transferência!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao copiar link: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Método para verificar se é um link externo
  bool _isLinkExterno(Documento arquivo) {
    return arquivo.linkExterno != null && arquivo.linkExterno!.isNotEmpty;
  }

  // Método para verificar se é uma imagem
  bool _isImagem(Documento arquivo) {
    final extensoesImagem = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    return extensoesImagem.any((ext) => arquivo.nome.toLowerCase().endsWith(ext));
  }

  // Método para verificar se é um PDF
  bool _isPDF(Documento arquivo) {
    return arquivo.nome.toLowerCase().endsWith('.pdf');
  }

   @override
   void dispose() {
    _nomePastaController.dispose();
    _linkController.dispose();
    super.dispose();
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
                'Home/Documentos/Editar',
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
              
              // Seção Editar Pasta
              const Text(
                'Editar Pasta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nomePastaController,
                      decoration: InputDecoration(
                        hintText: 'Nome da pasta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      _showDeleteDialog();
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Seção Privacidade
              const Text(
                'Privacidade:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
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
              
              // Seção Adicionar Arquivos
              const Text(
                'Adicionar Arquivos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: 'Link:',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Botões de ação
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
              
              // Botão Salvar
              Center(
                child: ElevatedButton(
                  onPressed: _salvarAlteracoes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Seção Arquivos
              const Text(
                'Arquivos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              // Lista de arquivos
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _carregarArquivos,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              else if (_arquivos.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Nenhum arquivo encontrado nesta pasta',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ..._arquivos.map((arquivo) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        arquivo.nome.toLowerCase().endsWith('.pdf')
                            ? Icons.picture_as_pdf
                            : Icons.insert_drive_file,
                        color: arquivo.nome.toLowerCase().endsWith('.pdf')
                            ? Colors.red
                            : Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              arquivo.nome,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (arquivo.descricao != null && arquivo.descricao!.isNotEmpty)
                              Text(
                                arquivo.descricao!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (arquivo.url != null || arquivo.linkExterno != null) ...[
                        // Botão de editar nome (sempre presente)
                        IconButton(
                          onPressed: _isLoading ? null : () => _editarNomeArquivo(arquivo),
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.orange,
                          ),
                          tooltip: 'Editar nome',
                        ),
                        // Botão de ação baseado no tipo de arquivo
                        if (_isLinkExterno(arquivo))
                          // Para links externos: apenas copiar
                          IconButton(
                            onPressed: _isLoading ? null : () => _copiarLink(arquivo),
                            icon: const Icon(
                              Icons.copy,
                              color: Colors.blue,
                            ),
                            tooltip: 'Copiar link',
                          )
                        else if (_isPDF(arquivo))
                          // Para PDFs: download
                          IconButton(
                            onPressed: _isLoading ? null : () => _baixarPDF(arquivo),
                            icon: const Icon(
                              Icons.download,
                              color: Colors.green,
                            ),
                            tooltip: 'Baixar PDF',
                          )
                        else if (_isImagem(arquivo))
                          // Para imagens: visualizar com zoom
                          IconButton(
                            onPressed: _isLoading ? null : () => _visualizarImagem(arquivo),
                            icon: const Icon(
                              Icons.visibility,
                              color: Colors.blue,
                            ),
                            tooltip: 'Visualizar imagem',
                          ),
                      ],
                      IconButton(
                        onPressed: () {
                          _deleteArquivo(arquivo);
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ));
  }
  
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deletar Pasta'),
          content: Text('Tem certeza que deseja deletar a pasta "${widget.pasta.nome}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await DocumentoService.deletarPasta(widget.pasta.id);
                  if (mounted) {
                    Navigator.pop(context); // Volta para a tela anterior
                    widget.onPastaAtualizada?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pasta deletada com sucesso')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao deletar pasta: $e')),
                    );
                  }
                }
              },
              child: const Text(
                'Deletar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _salvarAlteracoes() async {
    // Validar se o nome da pasta não está vazio
    if (_nomePastaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O nome da pasta não pode estar vazio')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Atualizar informações da pasta (nome e privacidade)
      await DocumentoService.atualizarPasta(
        widget.pasta.id,
        nome: _nomePastaController.text.trim(),
        privado: _privacidade == 'Privado',
      );

      // 2. Se há um link para adicionar, criar um novo arquivo
      if (_linkController.text.trim().isNotEmpty) {
        await DocumentoService.adicionarArquivoComLink(
          pastaId: widget.pasta.id,
          nome: 'Link - ${DateTime.now().millisecondsSinceEpoch}',
          linkExterno: _linkController.text.trim(),
          privado: _privacidade == 'Privado',
          condominioId: widget.condominioId,
          representanteId: widget.representanteId,
        );
        
        // Limpar o campo de link após adicionar
        _linkController.clear();
      }

      // 3. Recarregar a lista de arquivos para mostrar as mudanças
      await _carregarArquivos();

      // 4. Notificar que a pasta foi atualizada
      widget.onPastaAtualizada?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alterações salvas com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar alterações: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Método para tirar foto e salvar como PNG
  Future<void> _tirarFoto() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        // Fazer upload da imagem
        await DocumentoService.adicionarArquivoComUpload(
          nome: 'Foto_${DateTime.now().millisecondsSinceEpoch}.png',
          arquivo: File(image.path),
          descricao: 'Foto capturada pela câmera',
          privado: _privacidade == 'Privado',
          pastaId: widget.pasta.id,
          condominioId: widget.condominioId,
          representanteId: widget.representanteId,
        );

        // Recarregar a lista de arquivos
        await _carregarArquivos();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto adicionada com sucesso!')),
          );
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
          _isLoading = false;
        });
      }
    }
  }

  // Método para selecionar e fazer upload de PDF do dispositivo
  Future<void> _selecionarPDF() async {
    try {
      setState(() {
        _isLoading = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        try {
          // Obter o arquivo original
          final File originalFile = File(result.files.single.path!);
          
          // Verificar se o arquivo existe
          if (!await originalFile.exists()) {
            print('Erro: Arquivo não encontrado em ${result.files.single.path}');
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
          final tempDir = Directory('${appDocDir.path}/pdf_temporarios');
          if (!await tempDir.exists()) {
            await tempDir.create(recursive: true);
          }

          final fileName = result.files.single.name;
          final copiedFile = File('${tempDir.path}/$fileName');
          
          // Copiar conteúdo do arquivo
          final bytes = await originalFile.readAsBytes();
          await copiedFile.writeAsBytes(bytes);

          print('PDF copiado com sucesso: ${copiedFile.path}');
          print('Tamanho do arquivo: ${bytes.length} bytes');

          // Fazer upload do arquivo
          await DocumentoService.adicionarArquivoComUpload(
            nome: fileName,
            arquivo: copiedFile,
            descricao: 'Documento PDF enviado do dispositivo',
            privado: _privacidade == 'Privado',
            pastaId: widget.pasta.id,
            condominioId: widget.condominioId,
            representanteId: widget.representanteId,
          );

          // Recarregar a lista de arquivos
          await _carregarArquivos();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✓ PDF "$fileName" importado com sucesso!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } catch (uploadError) {
          print('Erro ao fazer upload do PDF: $uploadError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao fazer upload do PDF: $uploadError'),
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
          _isLoading = false;
        });
      }
    }
  }

  void _deleteArquivo(Documento arquivo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('Deseja realmente deletar o arquivo "${arquivo.nome}"?'),
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
        await DocumentoService.deletarArquivo(arquivo.id);
        _carregarArquivos(); // Recarrega a lista
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Arquivo removido com sucesso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao remover arquivo: $e')),
          );
        }
      }
    }
  }

  // Função para visualizar imagem ampliada com zoom
  void _visualizarImagem(Documento arquivo) {
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
                    arquivo.url ?? '',
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

  // Função para baixar PDF (suporta Web, Android e iOS)
  Future<void> _baixarPDF(Documento arquivo) async {
    try {
      if (arquivo.url == null || arquivo.url!.isEmpty) {
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

      final String pdfUrl = arquivo.url!;
      final String fileName = arquivo.nome;

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
    final Directory? downloadsDir = await _getDownloadsDirectory();
    
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
  Future<Directory?> _getDownloadsDirectory() async {
    try {
      // No Android, usa Documents directory que funciona melhor
      // No iOS, usa Documents também
      if (Platform.isAndroid) {
        // Tenta obter o diretório de downloads
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          // Tenta retornar /storage/emulated/0/Download se possível
          final downloadPath = '/storage/emulated/0/Download';
          if (await Directory(downloadPath).exists()) {
            return Directory(downloadPath);
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
}