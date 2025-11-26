import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:io';
import 'documentos_inquilino_screen.dart';
import 'agenda_inquilino_screen.dart';
import 'portaria_inquilino_screen.dart';
import 'login_screen.dart';
import 'proprietario_dashboard_screen.dart';
import '../services/auth_service.dart';
import '../services/unidade_detalhes_service.dart';
import '../services/supabase_service.dart';

class InquilinoHomeScreen extends StatefulWidget {
  final String condominioId;
  final String condominioNome;
  final String condominioCnpj;
  final String? inquilinoId;
  final String? proprietarioId;
  final String unidadeId;
  final String unidadeNome;
  final dynamic proprietarioData; // Dados do proprietário para voltar ao dashboard

  const InquilinoHomeScreen({
    super.key,
    required this.condominioId,
    required this.condominioNome,
    required this.condominioCnpj,
    this.inquilinoId,
    this.proprietarioId,
    required this.unidadeId,
    required this.unidadeNome,
    this.proprietarioData,
  }) : assert(
         inquilinoId != null || proprietarioId != null,
         'Deve fornecer inquilinoId ou proprietarioId',
       );

  @override
  State<InquilinoHomeScreen> createState() => _InquilinoHomeScreenState();
}

class _InquilinoHomeScreenState extends State<InquilinoHomeScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  
  String? _inquilinoFotoPerfil;
  bool _isUploadingFoto = false;

  @override
  void initState() {
    super.initState();
  }

  /// Copia dados do condomínio e unidade para a área de transferência
  void _copiarDados() {
    final texto = '''Dados da Propriedade
    
Condomínio: ${widget.condominioNome}
CNPJ: ${widget.condominioCnpj}
${widget.unidadeNome}
    
Copiado da CondoGaia''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Dados para compartilhamento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                texto,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: texto)).then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dados copiados para a área de transferência!'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF1976D2),
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Copiar dados'),
          ),
        ],
      ),
    );
  }

  // Funções para upload de foto do Inquilino
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
                  _pickAndUploadFoto(ImageSource.gallery);
                },
              ),
              // Mostrar câmera apenas em plataformas móveis
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Câmera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadFoto(ImageSource.camera);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadFoto(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploadingFoto = true;
      });

      try {
        // Para Web: usar Uint8List diretamente
        // Para Mobile: converter XFile para File
        late Map<String, dynamic>? uploadedInquilino;

        if (kIsWeb) {
          // Web: usar bytes diretamente
          final bytes = await image.readAsBytes();
          uploadedInquilino = await _uploadFotoWeb(widget.inquilinoId ?? widget.proprietarioId!, bytes, image.name);
        } else {
          // Mobile: converter para File
          final imageFile = File(image.path);
          uploadedInquilino = await SupabaseService.uploadInquilinoFotoPerfil(
            widget.inquilinoId ?? widget.proprietarioId!,
            imageFile,
          );
        }

        if (uploadedInquilino != null) {
          setState(() {
            _inquilinoFotoPerfil = uploadedInquilino?['foto_perfil'] as String?;
            _isUploadingFoto = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto atualizada com sucesso!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isUploadingFoto = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar foto: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingFoto = false;
      });
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

  // Upload para Web (usando Uint8List)
  Future<Map<String, dynamic>?> _uploadFotoWeb(
    String inquilinoId,
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      // Detectar extensão
      final fileExtension = fileName.split('.').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      final extension = validExtensions.contains(fileExtension) ? fileExtension : 'jpg';

      // Gerar nome único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'inquilinos/$inquilinoId/$timestamp.$extension';

      // Upload
      await SupabaseService.client.storage
          .from('fotos_perfil')
          .uploadBinary(storagePath, bytes);

      // Obter URL pública
      final imageUrl =
          SupabaseService.client.storage.from('fotos_perfil').getPublicUrl(storagePath);

      // Atualizar banco
      final response = await SupabaseService.client
          .from('inquilinos')
          .update({'foto_perfil': imageUrl})
          .eq('id', inquilinoId)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Erro ao fazer upload da foto do inquilino (Web): $e');
      rethrow;
    }
  }

  /// Constrói o drawer (menu lateral)
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header do drawer
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Foto do Inquilino com botão de editar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // Foto circular
                    if (_inquilinoFotoPerfil != null && _inquilinoFotoPerfil!.isNotEmpty)
                      ClipOval(
                        child: Image.network(
                          _inquilinoFotoPerfil!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      )
                    else
                      // Placeholder sem foto
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    // Botão de editar flutuante
                    FloatingActionButton(
                      onPressed: _isUploadingFoto ? null : _showImageSourceDialog,
                      mini: true,
                      backgroundColor: _isUploadingFoto ? Colors.grey : Colors.white,
                      child: _isUploadingFoto
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                              ),
                            )
                          : const Icon(Icons.edit, size: 16, color: Color(0xFF1976D2)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Botão Sair da conta
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sair da conta',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              _handleLogout();
            },
          ),
          const Divider(),
          // Botão Excluir conta
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Excluir conta',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              _handleDeleteAccount();
            },
          ),
        ],
      ),
    );
  }

  /// Trata logout do usuário
  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Deseja realmente sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  /// Trata exclusão de conta
  Future<void> _handleDeleteAccount() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Conta'),
          content: const Text('Tem certeza que deseja excluir sua conta? Esta ação é irreversível!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  final service = UnidadeDetalhesService();
                  
                  // Deletar o inquilino ou proprietário
                  if (widget.inquilinoId != null && widget.inquilinoId!.isNotEmpty) {
                    print('🗑️ Deletando inquilino: ${widget.inquilinoId}');
                    await service.deletarInquilino(inquilinoId: widget.inquilinoId!);
                    print('✅ Inquilino deletado com sucesso!');
                  } else if (widget.proprietarioId != null && widget.proprietarioId!.isNotEmpty) {
                    print('🗑️ Deletando proprietário: ${widget.proprietarioId}');
                    await service.deletarProprietario(proprietarioId: widget.proprietarioId!);
                    print('✅ Proprietário deletado com sucesso!');
                  } else {
                    throw Exception('Nenhum ID fornecido para deletar');
                  }
                  
                  // Fazer logout
                  print('🚪 Realizando logout...');
                  await _authService.logout();
                  print('✅ Logout realizado!');
                  
                  // Navegar para login (SEM usar ScaffoldMessenger pois a tela foi destruída)
                  if (mounted) {
                    print('🔄 Navegando para login...');
                    // Determinar o tipo de usuário para a mensagem
                    String nomeUsuario = 'Usuário';
                    if (widget.inquilinoId != null && widget.inquilinoId!.isNotEmpty) {
                      nomeUsuario = 'Inquilino';
                    } else if (widget.proprietarioId != null && widget.proprietarioId!.isNotEmpty) {
                      nomeUsuario = 'Proprietário';
                    }
                    
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(usuarioDeletado: nomeUsuario),
                      ),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  print('❌ ERRO ao excluir conta: $e');
                  // NÃO mostrar snackbar aqui pois a tela já foi destruída
                }
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }


  Widget _buildMenuCard({
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    height: 60,
                    width: 60,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (BuildContext scaffoldContext) {
            return Column(
          children: [
            // Cabeçalho superior padronizado (IDÊNTICO AO REPRESENTANTE)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Botão de menu (hamburger)
                  GestureDetector(
                    onTap: () {
                      Scaffold.of(scaffoldContext).openDrawer();
                    },
                    child: const Icon(
                      Icons.menu,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  // Logo CondoGaia
                  Image.asset('assets/images/logo_CondoGaia.png', height: 32),
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
            Container(height: 1, color: Colors.grey[300]),

            // Grid de funcionalidades do inquilino
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _buildMenuCard(
                      imagePath:
                          'assets/images/Representante/HOME/Imagem_chat.png',
                      title: 'Chat',
                      onTap: () {
                        // TODO: Implementar navegação para chat
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/Representante/HOME/Imagem_Classificados.png',
                      title: 'Classificados',
                      onTap: () {
                        // TODO: Implementar navegação para classificados
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/Representante/HOME/Imagem_Documentos.png',
                      title: 'Documentos',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DocumentosInquilinoScreen(
                              condominioId: widget.condominioId,
                              inquilinoId:
                                  widget.inquilinoId ?? widget.proprietarioId!,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/Representante/HOME/Imagem_DiarioAgenda.png',
                      title: 'Diário/Agenda',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgendaInquilinoScreen(
                              condominioId: widget.condominioId,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/Representante/HOME/Imagem_Controle.png',
                      title: 'Controle',
                      onTap: () {
                        // TODO: Implementar navegação para controle
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/Representante/HOME/Imagem_Reservas.png',
                      title: 'Reservas',
                      onTap: () {
                        // TODO: Implementar navegação para reservas
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/HOME_Inquilino/Boleto_icone_Inquilino.png',
                      title: 'Boletos',
                      onTap: () {
                        // TODO: Implementar navegação para boletos
                      },
                    ),
                    _buildMenuCard(
                      imagePath:
                          'assets/images/HOME_Inquilino/Portaria_icone_Inquilino.png',
                      title: 'Portaria',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PortariaInquilinoScreen(
                              condominioId: widget.condominioId,
                              condominioNome: widget.condominioNome,
                              condominioCnpj: widget.condominioCnpj,
                              inquilinoId: widget.inquilinoId,
                              proprietarioId: widget.proprietarioId,
                              unidadeId: widget.unidadeId,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Footer com informações do condomínio
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Setas de mudança de condomínio no canto esquerdo
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        // Se for proprietário e tem dados, voltar ao dashboard
                        if (widget.proprietarioId != null && widget.proprietarioData != null) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => ProprietarioDashboardScreen(
                                proprietario: widget.proprietarioData,
                              ),
                            ),
                          );
                        } else {
                          // Caso contrário, fazer pop normal
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset(
                        'assets/images/Representante/HOME/Setas_Mudancadecomdominio.png',
                        height: 35,
                        width: 35,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.condominioNome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unidade: ${widget.unidadeNome}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Ícone de compartilhamento no lado direito
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: GestureDetector(
                      onTap: _copiarDados,
                      child: Image.asset(
                        'assets/images/Compartilhar.png',
                        height: 35,
                        width: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
            );
          },
        ),
      ),
    );
  }
}