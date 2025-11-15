import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'documentos_inquilino_screen.dart';
import 'agenda_inquilino_screen.dart';
import 'portaria_inquilino_screen.dart';
import 'login_screen.dart';
import 'proprietario_dashboard_screen.dart';
import '../services/auth_service.dart';

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
                Image.asset(
                  'assets/images/logo_CondoGaia.png',
                  height: 40,
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
                  // Excluir a conta
                  await Supabase.instance.client
                      .from('inquilinos')
                      .delete()
                      .eq('id', widget.inquilinoId ?? widget.proprietarioId ?? '');
                  
                  // Fazer logout
                  await _authService.logout();
                  
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
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
                              inquilinoId:
                                  widget.inquilinoId ?? widget.proprietarioId!,
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
                      onTap: () {
                        // TODO: Implementar compartilhamento
                      },
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