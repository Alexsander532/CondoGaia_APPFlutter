import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'cadastro_condominio_screen.dart';
import 'cadastro_representante_screen.dart';
import 'pesquisa_condominios_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final email = await _authService.getCurrentUserEmail();
    setState(() {
      userEmail = email;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      // TODO: Implementar menu lateral
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
            // Seção com botão voltar e título HOME
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Botão voltar
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                    ),
                  ),
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
                  // Espaço para balancear o botão voltar
                  const SizedBox(width: 20),
                ],
              ),
            ),
            // Menu principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Cadastrar Condomínio
                    _buildMenuItem(
                      iconPath: 'assets/images/ADMIN/home_ADMIN/Cadastra_Condominio_Home.png',
                      textImagePath: 'assets/images/ADMIN/home_ADMIN/Cadastrar_Condomínio_Texto.png',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CadastroCondominioScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Cadastrar Representante
                    _buildMenuItemTextImageOnly(
                      textImagePath: 'assets/images/ADMIN/home_ADMIN/Cadastrar_Representante_Texto.png',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CadastroRepresentanteScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Pesquisar
                    _buildMenuItem(
                      iconPath: 'assets/images/ADMIN/home_ADMIN/Simbolo_Pesquisar.png',
                      textImagePath: 'assets/images/ADMIN/home_ADMIN/Pesquisar_Texto.png',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PesquisaCondominiosScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Push
                    _buildMenuItem(
                      iconPath: 'assets/images/ADMIN/home_ADMIN/Push_Imagem.png',
                      textImagePath: 'assets/images/ADMIN/home_ADMIN/Push_Texto.png',
                      onTap: () {
                        // TODO: Navegar para push notifications
                        _showFeatureInDevelopment('Push');
                      },
                    ),
                    const SizedBox(height: 24),
                    // Gateway de Pagamento
                    _buildMenuItem(
                      iconPath: 'assets/images/ADMIN/home_ADMIN/Gateway_de_Pagamento.png',
                      textImagePath: 'assets/images/ADMIN/home_ADMIN/Gateway_de_Pagamento_Texto.png',
                      onTap: () {
                        // TODO: Navegar para gateway de pagamento
                        _showFeatureInDevelopment('Gateway de Pagamento');
                      },
                    ),
                    const SizedBox(height: 24),
                    // Documentos
                    _buildMenuItemTextImageOnly(
                      textImagePath: 'assets/images/ADMIN/home_ADMIN/Documentos_Texto.png',
                      onTap: () {
                        // TODO: Navegar para documentos
                        _showFeatureInDevelopment('Documentos');
                      },
                    ),
                    const Spacer(),
                    // Botão de logout (oculto, acessível por gesture)
                    GestureDetector(
                      onLongPress: _logout,
                      child: Container(
                        height: 20,
                        color: Colors.transparent,
                      ),
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
          Image.asset(
            iconPath,
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 16),
          // Texto como imagem
          Image.asset(
            textImagePath,
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemTextOnly({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          const SizedBox(width: 48), // Espaço para alinhar com outros itens
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
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
          Image.asset(
            textImagePath,
            height: 20,
          ),
        ],
      ),
    );
  }

  void _showFeatureInDevelopment(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature em desenvolvimento'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}