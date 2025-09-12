import 'dart:convert';
import 'dart:typed_data';
import 'package:condogaiaapp/screens/representante_home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/representante.dart';
import '../services/supabase_service.dart';
import 'representante_home_screen.dart';

// Conditional import for File (only for mobile/desktop)
import 'dart:io' if (dart.library.html) 'dart:html' as io;

class UploadFotoPerfilScreen extends StatefulWidget {
  final Representante representante;

  const UploadFotoPerfilScreen({
    super.key,
    required this.representante,
  });

  @override
  State<UploadFotoPerfilScreen> createState() => _UploadFotoPerfilScreenState();
}

class _UploadFotoPerfilScreenState extends State<UploadFotoPerfilScreen> {
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
      final success = await SupabaseService.updateRepresentanteFotoPerfil(
        widget.representante.id,
        _imageBase64!,
      );

      if (mounted) {
        if (success != null) {
          // Navegar para o dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RepresentanteHomeScreen(
                representante: widget.representante.copyWith(
                  fotoPerfil: _imageBase64,
                ),
                condominioId: '', // TODO: Obter do contexto
                condominioNome: '', // TODO: Obter do contexto
                condominioCnpj: '', // TODO: Obter do contexto
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
    // Navegar para o dashboard sem foto
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RepresentanteHomeScreen(
          representante: widget.representante,
          condominioId: '', // TODO: Obter do contexto
          condominioNome: '', // TODO: Obter do contexto
          condominioCnpj: '', // TODO: Obter do contexto
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Foto de Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Título de boas-vindas
              Text(
                'Olá, ${widget.representante.nomeCompleto.split(' ').first}!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Adicione uma foto de perfil para personalizar sua conta',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Área da foto
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: _selectedImageBytes != null
                        ? ClipOval(
                            child: Image.memory(
                              _selectedImageBytes!,
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
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
              const SizedBox(height: 16),
              
              const Text(
                'Toque para adicionar foto',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Botão Salvar
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadFoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Salvar Foto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Botão Pular
              SizedBox(
                height: 50,
                child: TextButton(
                  onPressed: _isUploading ? null : _skipUpload,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Pular por agora',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}