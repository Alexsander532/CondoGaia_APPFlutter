import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/inquilino.dart';
import '../services/supabase_service.dart';
import '../screens/inquilino_dashboard_screen.dart';

// Conditional import for File (only for mobile/desktop)
import 'dart:io' if (dart.library.html) 'dart:html' as io;

class UploadFotoPerfilInquilinoScreen extends StatefulWidget {
  final Inquilino inquilino;

  const UploadFotoPerfilInquilinoScreen({super.key, required this.inquilino});

  @override
  State<UploadFotoPerfilInquilinoScreen> createState() =>
      _UploadFotoPerfilInquilinoScreenState();
}

class _UploadFotoPerfilInquilinoScreenState
    extends State<UploadFotoPerfilInquilinoScreen> {
  final ImagePicker _picker = ImagePicker();
  final SupabaseService _supabaseService = SupabaseService();

  Uint8List? _selectedImageBytes;
  bool _isUploading = false;
  String? _imageBase64;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);

        setState(() {
          _selectedImageBytes = bytes;
          _imageBase64 = 'data:image/jpeg;base64,$base64String';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              // Mostrar câmera apenas em plataformas móveis
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Câmera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadFoto() async {
    if (_imageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma foto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final success = await SupabaseService.updateInquilinoFotoPerfil(
        widget.inquilino.id,
        _imageBase64!,
      );

      if (mounted) {
        if (success != null) {
          // Navegar para o dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => InquilinoDashboardScreen(
                inquilino: widget.inquilino.copyWith(fotoPerfil: _imageBase64),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar foto de perfil'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _skipUpload() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            InquilinoDashboardScreen(inquilino: widget.inquilino),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Foto de Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48, // Subtraindo o padding
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20), // Reduzido de 40 para 20
                      // Título
                      const Text(
                        'Adicione sua foto de perfil',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12), // Reduzido de 16 para 12
                      // Subtítulo
                      Text(
                        'Isso ajudará outros moradores a identificá-lo',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32), // Reduzido de 40 para 32
                      // Preview da imagem
                      Center(
                        child: GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: _selectedImageBytes != null
                                ? ClipOval(
                                    child: Image.memory(
                                      _selectedImageBytes!,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_a_photo,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // Reduzido de 24 para 16
                      // Texto de instrução
                      Text(
                        _selectedImageBytes != null
                            ? 'Toque na imagem para alterar'
                            : 'Toque para adicionar uma foto',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(), // Adiciona espaço flexível
                      // Botões
                      Column(
                        children: [
                          // Botão de upload/continuar
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _selectedImageBytes != null && !_isUploading
                                  ? _uploadFoto
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isUploading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      _selectedImageBytes != null
                                          ? 'Continuar'
                                          : 'Selecione uma foto',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Botão de pular
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: TextButton(
                              onPressed: _isUploading ? null : _skipUpload,
                              child: const Text(
                                'Pular por agora',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // Reduzido de 40 para 20
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}