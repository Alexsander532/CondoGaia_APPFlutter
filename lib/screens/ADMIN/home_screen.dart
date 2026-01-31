import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../login_screen.dart';
import 'cadastro_condominio_screen.dart';
import 'cadastro_representante_screen.dart';
import 'pesquisa_condominios_screen.dart';
import '../../features/ADMIN_Features/push_notification_admin/screens/push_notification_admin_screen.dart';
import '../../features/ADMIN_Features/gateway_pagamento_admin/screens/gateway_pagamento_admin_screen.dart';
import '../../features/ADMIN_Features/documentos_admin/screens/admin_documentos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = SupabaseService.client.auth.currentUser;
    setState(() {
      userEmail = user?.email;
    });
  }

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

                try {
                  await SupabaseService.client.auth.signOut();

                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao sair: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho superior
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Botão de menu (hambúrguer)
                  IconButton(
                    icon: const Icon(Icons.menu, size: 24),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
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
            // Seção com título HOME
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Center(
                      child: Text(
                        'HOME',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Conteúdo principal scrollável
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Cadastrar Condomínio
                    _buildMenuItem(
                      iconPath:
                          'assets/images/ADMIN/home_ADMIN/Cadastra_Condominio_Home.png',
                      textImagePath:
                          'assets/images/ADMIN/home_ADMIN/Cadastrar_Condomínio_Texto.png',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const CadastroCondominioScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Cadastrar Representante
                    _buildMenuItemTextImageOnly(
                      textImagePath:
                          'assets/images/ADMIN/home_ADMIN/Cadastrar_Representante_Texto.png',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const CadastroRepresentanteScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Pesquisar
                    _buildMenuItem(
                      iconPath:
                          'assets/images/ADMIN/home_ADMIN/Simbolo_Pesquisar.png',
                      textImagePath:
                          'assets/images/ADMIN/home_ADMIN/Pesquisar_Texto.png',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const PesquisaCondominiosScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Push
                    _buildMenuItem(
                      iconPath:
                          'assets/images/ADMIN/home_ADMIN/Push_Imagem.png',
                      textImagePath:
                          'assets/images/ADMIN/home_ADMIN/Push_Texto.png',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const PushNotificationAdminScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Gateway de Pagamento
                    _buildMenuItem(
                      iconPath:
                          'assets/images/ADMIN/home_ADMIN/Gateway_de_Pagamento.png',
                      textImagePath:
                          'assets/images/ADMIN/home_ADMIN/Gateway_de_Pagamento_Texto.png',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const GatewayPagamentoAdminScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Documentos
                    _buildMenuItemTextImageOnly(
                      textImagePath:
                          'assets/images/ADMIN/home_ADMIN/Documentos_Texto.png',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AdminDocumentosScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // Botão de logout (oculto, acessível por gesture)
                    GestureDetector(
                      onLongPress: _handleLogout,
                      child: Container(height: 20, color: Colors.transparent),
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

  Widget _buildMenuItem({
    required String iconPath,
    required String textImagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // Ícone
          Image.asset(iconPath, width: 32, height: 32),
          const SizedBox(width: 16),
          // Texto como imagem
          Image.asset(textImagePath, height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItemTextImageOnly({
    required String textImagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          const SizedBox(width: 48), // Espaço para alinhar com outros itens
          Image.asset(textImagePath, height: 20),
        ],
      ),
    );
  }

  /// Constrói o drawer (barra lateral)
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header do drawer
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1976D2)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo_CondoGaia.png', height: 40),
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
              Navigator.pop(context);
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
              Navigator.pop(context);
              _handleDeleteAccount();
            },
          ),
        ],
      ),
    );
  }

  /// Trata exclusão de conta do admin
  Future<void> _handleDeleteAccount() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Conta'),
          content: const Text(
            'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  // Implementar lógica de exclusão de conta aqui
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao excluir conta: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
