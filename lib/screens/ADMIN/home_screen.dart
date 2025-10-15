import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
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
  List<Map<String, dynamic>> _representantes = [];
  bool _isLoadingRepresentantes = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadRepresentantes();
  }

  Future<void> _loadUserInfo() async {
    final email = await _authService.getCurrentUserEmail();
    setState(() {
      userEmail = email;
    });
  }

  Future<void> _loadRepresentantes() async {
    setState(() {
      _isLoadingRepresentantes = true;
    });

    try {
      final representantes = await SupabaseService.getRepresentantesComCondominiosParaAdmin();
      setState(() {
        _representantes = representantes;
        _isLoadingRepresentantes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRepresentantes = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar representantes: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                    const SizedBox(height: 40),
                    
                    // Seção de Representantes Cadastrados
                    _buildRepresentantesSection(),
                    
                    const SizedBox(height: 40),
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

  Widget _buildRepresentantesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Row(
          children: [
            const Icon(
              Icons.people,
              size: 24,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            const Text(
              'Representantes Cadastrados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            // Botão de refresh
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              onPressed: _loadRepresentantes,
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Conteúdo da seção
        if (_isLoadingRepresentantes)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_representantes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.person_off,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Text(
                  'Nenhum representante cadastrado',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: _representantes.map((representante) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRepresentanteCard(representante),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildRepresentanteCard(Map<String, dynamic> representante) {
    final condominios = representante['condominios'] as List<dynamic>? ?? [];
    final totalCondominios = condominios.length;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com nome e CPF
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      representante['nome_completo'] ?? 'Nome não informado',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'CPF: ${representante['cpf'] ?? 'Não informado'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Informações de acesso
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Email
                Row(
                  children: [
                    const Icon(
                      Icons.email,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Email:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        representante['email'] ?? 'Não informado',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Senha
                Row(
                  children: [
                    const Icon(
                      Icons.lock,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Senha:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        representante['senha_acesso'] ?? 'Não informado',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Condomínios associados
          Row(
            children: [
              const Icon(
                Icons.apartment,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                'Condomínios ($totalCondominios):',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          if (condominios.isEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Nenhum condomínio associado',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: condominios.map<Widget>((condominio) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.business,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              condominio['nome_condominio'] ?? 'Nome não informado',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            if (condominio['cidade'] != null && condominio['estado'] != null)
                              Text(
                                '${condominio['cidade']}/${condominio['estado']}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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