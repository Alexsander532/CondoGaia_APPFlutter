import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/documento_service.dart';

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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await DocumentoService.criarPasta(
        nome: _nomePastaController.text.trim(),
        privado: _privacidade == 'Privado',
        condominioId: widget.condominioId,
        representanteId: widget.representanteId,
      );
      
      if (mounted) {
        Navigator.pop(context, true); // Retorna true para indicar sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pasta criada com sucesso!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao criar pasta: $e';
        _isLoading = false;
      });
    }
  }

  // Método para selecionar e fazer upload de PDF do dispositivo
  Future<void> _selecionarPDF() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Selecionar arquivo PDF do dispositivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        String nomeArquivo = result.files.single.name;

        // Validar se é realmente um PDF
        if (!nomeArquivo.toLowerCase().endsWith('.pdf')) {
          throw Exception('Apenas arquivos PDF são permitidos');
        }

        // Primeiro, criar uma pasta temporária se não houver nome definido
        String nomePasta = _nomePastaController.text.trim();
        if (nomePasta.isEmpty) {
          nomePasta = 'Nova Pasta ${DateTime.now().millisecondsSinceEpoch}';
        }

        // Criar a pasta primeiro
        final pasta = await DocumentoService.criarPasta(
          nome: nomePasta,
          privado: _privacidade == 'Privado',
          condominioId: widget.condominioId,
          representanteId: widget.representanteId,
        );

        // Fazer upload do arquivo na pasta criada usando bytes
        await DocumentoService.adicionarArquivoComUploadBytes(
          nome: nomeArquivo,
          bytes: bytes,
          descricao: 'Documento PDF enviado do dispositivo',
          privado: _privacidade == 'Privado',
          pastaId: pasta.id,
          condominioId: widget.condominioId,
          representanteId: widget.representanteId,
        );

        if (mounted) {
          Navigator.pop(context, true); // Retorna true para indicar sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pasta criada e PDF adicionado com sucesso!')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao selecionar PDF: $e';
        _isLoading = false;
      });
    }
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
                    const Text(
                      'Nome da Pasta:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
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
                    // Seção Adicionar Arquivos
                    const Text(
                      'Adicionar Arquivos',
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
                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // TODO: Implementar tirar foto
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tirar foto em desenvolvimento'),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tirar foto',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _isLoading ? null : _selecionarPDF,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: _isLoading ? Colors.grey[300]! : Colors.blue),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 30,
                                    color: _isLoading ? Colors.grey : Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Fazer Upload PDF',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
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