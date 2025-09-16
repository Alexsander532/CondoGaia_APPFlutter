import 'package:flutter/material.dart';
import '../models/documento.dart';
import '../services/documento_service.dart';

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
                      onPressed: () {
                        // Implementar tirar foto
                      },
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
                      onPressed: () {
                        // Implementar upload PDF
                      },
                      icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF1E3A8A)),
                      label: const Text(
                        'Fazer Upload PDF',
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
                ],
              ),
              const SizedBox(height: 16),
              
              // Botão Adicionar arquivo
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Implementar adicionar arquivo
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Adicionar arquivo',
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
                      if (arquivo.url != null || arquivo.linkExterno != null)
                        IconButton(
                          onPressed: () {
                            // TODO: Abrir arquivo
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Abrir arquivo em desenvolvimento')),
                            );
                          },
                          icon: const Icon(
                            Icons.open_in_new,
                            color: Colors.blue,
                          ),
                        ),
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
}