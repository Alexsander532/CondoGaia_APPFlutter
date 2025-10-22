import 'package:condogaiaapp/screens/documentos_screen.dart';
import 'package:flutter/material.dart';
import '../models/representante.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'documentos_screen.dart';
import 'agenda_screen_backup.dart';
import 'reservas_screen.dart';
import 'inquilino_home_screen.dart';
import 'gestao_screen.dart';
import 'contatos_chat_representante_screen.dart';

class RepresentanteHomeScreen extends StatefulWidget {
  final Representante representante;
  final String condominioId;
  final String condominioNome;
  final String condominioCnpj;

  const RepresentanteHomeScreen({
    super.key,
    required this.representante,
    required this.condominioId,
    required this.condominioNome,
    required this.condominioCnpj,
  });

  @override
  State<RepresentanteHomeScreen> createState() => _RepresentanteHomeScreenState();
}

class _RepresentanteHomeScreenState extends State<RepresentanteHomeScreen> {
  final AuthService _authService = AuthService();

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
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

            
            // Grid de funcionalidades
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
                      imagePath: 'assets/images/Representante/HOME/Imagem_chat.png',
                      title: 'Chat',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContatosChatRepresentanteScreen(
                              representante: widget.representante,
                              condominioId: widget.condominioId,
                              condominioNome: widget.condominioNome,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      imagePath: 'assets/images/Representante/HOME/Imagem_Classificados.png',
                      title: 'Classificados',
                      onTap: () {
                        // TODO: Implementar navegação para classificados
                      },
                    ),
                    _buildMenuCard(
                      imagePath: 'assets/images/Representante/HOME/Imagem_Documentos.png',
                      title: 'Documentos',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DocumentosScreen(
                              condominioId: widget.condominioId,
                              representanteId: widget.representante.id,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      imagePath: 'assets/images/Representante/HOME/Imagem_DiarioAgenda.png',
                      title: 'Diário/Agenda',
                      onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgendaScreen(
                        representante: widget.representante,
                      ),
                    ),
                  );
                },
                    ),
                    _buildMenuCard(
                      imagePath: 'assets/images/Representante/HOME/Imagem_Controle.png',
                      title: 'Controle',
                      onTap: () {
                        // TODO: Implementar navegação para controle do representante
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funcionalidade de Controle em desenvolvimento'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      imagePath: 'assets/images/Representante/HOME/Imagem_Cursos.png',
                      title: 'Cursos',
                      onTap: () {
                        // TODO: Implementar navegação para Cursos
                      },
                    ),
                    _buildMenuCard(
                      imagePath: 'assets/images/Representante/HOME/Imagem_Gestao.png',
                      title: 'Gestão',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GestaoScreen(
                              condominioId: widget.condominioId,
                              condominioNome: widget.condominioNome,
                              condominioCnpj: widget.condominioCnpj,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      imagePath: 'assets/images/Representante/HOME/Imagem_Reservas.png',
                      title: 'Reservas',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReservasScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      imagePath: 'assets/images/Representante/HOME/Imagem_FolhaFunc.png',
                      title: 'Folha Func.',
                      onTap: () {
                        // TODO: Implementar navegação para Folha Func.
                      },
                    ),
                    _buildMenuCard(
                      imagePath: 'assets/images/Representante/HOME/Imagem_Leitura.png',
                      title: 'Leitura',
                      onTap: () {
                        // TODO: Implementar navegação para Leitura
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
                          'CNPJ: ${widget.condominioCnpj}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Setas de mudança de condomínio no canto inferior direito
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: GestureDetector(
                      onTap: () {
                        // Navegar para o dashboard principal do representante
                        Navigator.pushReplacementNamed(context, '/representante_dashboard_screen');
                      },
                      child: Image.asset(
                        'assets/images/Representante/HOME/Setas_Mudancadecomdominio.png',
                        height: 35,
                        width: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}