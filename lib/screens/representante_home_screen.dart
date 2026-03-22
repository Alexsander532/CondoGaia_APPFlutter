import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/representante.dart';
import 'documentos_screen.dart';
import 'agenda_screen_backup.dart';
import 'reservas_screen.dart';
import 'gestao_screen.dart';
import 'representante_dashboard_screen.dart';
import '../features/Representante_Features/leitura/screens/leitura_screen.dart';
import '../services/permission_service.dart';
import '../widgets/custom_drawer.dart';

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
  State<RepresentanteHomeScreen> createState() =>
      _RepresentanteHomeScreenState();
}

class _RepresentanteHomeScreenState extends State<RepresentanteHomeScreen> {
  /// Copia dados do condomínio para a área de transferência
  void _copiarDados() {
    final texto =
        '''Dados do Condomínio
    
Condomínio: ${widget.condominioNome}
CNPJ: ${widget.condominioCnpj}
    
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
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: texto)).then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Dados copiados para a área de transferência!',
                    ),
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

  /// Card de menu com efeito "Em breve" (esmaecido com faixa vermelha)
  Widget _buildMenuCardComingSoon({
    required String imagePath,
    required String title,
  }) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Conteúdo esmaecido (com opacidade reduzida)
            Opacity(
              opacity: 0.5,
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
                    Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Faixa vermelha diagonal "Em breve"
            Positioned.fill(
              child: CustomPaint(painter: _ComingSoonBannerPainter()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (BuildContext scaffoldContext) {
            return Column(
              children: [
                // Cabeçalho superior padronizado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                      Image.asset(
                        'assets/images/logo_CondoGaia.png',
                        height: 32,
                      ),
                      const Spacer(),
                      // Ícones do lado direito
                      Row(
                        mainAxisSize: MainAxisSize.min,
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
                        if (PermissionService().canAccessChat())
                          _buildMenuCardComingSoon(
                            imagePath:
                                'assets/images/Representante/HOME/Imagem_chat.png',
                            title: 'Chat',
                          ),
                        _buildMenuCardComingSoon(
                          imagePath:
                              'assets/images/Representante/HOME/Imagem_Classificados.png',
                          title: 'Classificados',
                        ),
                        if (PermissionService().permissions.documentos ||
                            PermissionService().permissions.todos)
                          _buildMenuCard(
                            imagePath:
                                'assets/images/Representante/HOME/Imagem_Documentos.png',
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
                        if (PermissionService().canAccessDiario())
                          _buildMenuCard(
                            imagePath:
                                'assets/images/Representante/HOME/Imagem_DiarioAgenda.png',
                            title: 'Diário/Agenda',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AgendaScreen(
                                    representante: widget.representante,
                                    condominioId: widget.condominioId,
                                  ),
                                ),
                              );
                            },
                          ),
                        _buildMenuCardComingSoon(
                          imagePath:
                              'assets/images/Representante/HOME/Imagem_Controle.png',
                          title: 'Controle',
                        ),
                        _buildMenuCardComingSoon(
                          imagePath:
                              'assets/images/Representante/HOME/Imagem_Cursos.png',
                          title: 'Cursos',
                        ),
                        if (PermissionService().canAccessGestao())
                          _buildMenuCard(
                            imagePath:
                                'assets/images/Representante/HOME/Imagem_Gestao.png',
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
                        if (PermissionService().canAccessReservas())
                          _buildMenuCard(
                            imagePath:
                                'assets/images/Representante/HOME/Imagem_Reservas.png',
                            title: 'Reservas',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReservasScreen(
                                    representante: widget.representante,
                                    condominioId: widget.condominioId,
                                  ),
                                ),
                              );
                            },
                          ),
                        _buildMenuCardComingSoon(
                          imagePath:
                              'assets/images/Representante/HOME/Imagem_FolhaFunc.png',
                          title: 'Folha Func.',
                        ),
                        if (PermissionService().canAccessLeitura())
                          _buildMenuCard(
                            imagePath:
                                'assets/images/Representante/HOME/Imagem_Leitura.png',
                            title: 'Leitura',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LeituraScreen(
                                    condominioId: widget.condominioId,
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
                        padding: const EdgeInsets.only(right: 0.0),
                        child: GestureDetector(
                          onTap: () {
                            // Navegar para o dashboard principal do representante
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RepresentanteDashboardScreen(
                                      representante: widget.representante,
                                    ),
                              ),
                            );
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

/// CustomPainter para desenhar a faixa diagonal "Em breve"
class _ComingSoonBannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'EM BREVE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Desenhar retângulo diagonal
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.785398); // -45 graus em radianos

    final bannerWidth = size.width * 1.4;
    final bannerHeight = 28.0;

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: bannerWidth,
      height: bannerHeight,
    );

    canvas.drawRect(rect, paint);

    // Desenhar texto centralizado
    final textOffset = Offset(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(canvas, textOffset);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
