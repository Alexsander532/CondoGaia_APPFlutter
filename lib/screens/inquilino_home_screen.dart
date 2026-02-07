import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'documentos_inquilino_screen.dart';
import 'agenda_inquilino_screen.dart';
import 'portaria_inquilino_screen.dart';
import 'login_screen.dart';
import 'proprietario_dashboard_screen.dart';
import 'inquilino_dashboard_screen.dart';
import '../models/proprietario.dart';
import '../models/inquilino.dart';
import '../services/auth_service.dart';
import '../services/unidade_detalhes_service.dart';
import '../services/supabase_service.dart';
import '../services/conversas_service.dart';
import '../features/Prop_Inq_Features/reserva/ui/screens/reserva_screen.dart';

class InquilinoHomeScreen extends StatefulWidget {
  final String condominioId;
  final String condominioNome;
  final String condominioCnpj;
  final String? inquilinoId;
  final String? proprietarioId;
  final String unidadeId;
  final String unidadeNome;
  final dynamic
  proprietarioData; // Dados do proprietário para voltar ao dashboard

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
  // Serviço de conversas para contador de mensagens não lidas
  final ConversasService _conversasService = ConversasService();
  int _mensagensNaoLidas = 0;
  StreamSubscription<int>? _unreadSubscription;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Inicializar contador de mensagens não lidas
    _inicializarContadorMensagens();
  }

  @override
  void dispose() {
    _unreadSubscription?.cancel();
    super.dispose();
  }

  /// Inicializa o contador de mensagens não lidas
  Future<void> _inicializarContadorMensagens() async {
    try {
      // 1. Obter ou criar a conversa para ter o ID
      final conversa = await _conversasService.buscarOuCriar(
        condominioId: widget.condominioId,
        unidadeId: widget.unidadeId,
        usuarioTipo: widget.inquilinoId != null ? 'inquilino' : 'proprietario',
        usuarioId: widget.inquilinoId ?? widget.proprietarioId!,
        usuarioNome: widget.inquilinoId != null
            ? 'Inquilino'
            : 'Proprietário', // Nome será atualizado pelo backend se necessário
      );

      // 2. Inscrever no stream de não lidas
      _unreadSubscription = _conversasService
          .streamNaoLidasUsuario(conversa.id)
          .listen((count) {
            if (mounted) {
              setState(() {
                _mensagensNaoLidas = count;
              });
            }
          });
    } catch (e) {
      debugPrint('❌ Erro ao inicializar contador de mensagens: $e');
    }
  }

  /// Copia dados do condomínio e unidade para a área de transferência
  void _copiarDados() {
    final texto =
        '''Dados da Propriedade
    
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
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: texto));
              if (!context.mounted) return;

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dados copiados para a área de transferência!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF1976D2),
                ),
              );
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

  /// Constrói o drawer (menu lateral)
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
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Deseja realmente sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _authService.logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
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
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Excluir Conta'),
          content: const Text(
            'Tem certeza que deseja excluir sua conta? Esta ação é irreversível!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                try {
                  final service = UnidadeDetalhesService();

                  // Deletar o inquilino ou proprietário
                  if (widget.inquilinoId != null &&
                      widget.inquilinoId!.isNotEmpty) {
                    debugPrint(
                      '🗑️ Deletando inquilino: ${widget.inquilinoId}',
                    );
                    await service.deletarInquilino(
                      inquilinoId: widget.inquilinoId!,
                    );
                    debugPrint('✅ Inquilino deletado com sucesso!');
                  } else if (widget.proprietarioId != null &&
                      widget.proprietarioId!.isNotEmpty) {
                    debugPrint(
                      '🗑️ Deletando proprietário: ${widget.proprietarioId}',
                    );
                    await service.deletarProprietario(
                      proprietarioId: widget.proprietarioId!,
                    );
                    debugPrint('✅ Proprietário deletado com sucesso!');
                  } else {
                    throw Exception('Nenhum ID fornecido para deletar');
                  }

                  // Fazer logout
                  debugPrint('🚪 Realizando logout...');
                  await _authService.logout();
                  debugPrint('✅ Logout realizado!');

                  // Navegar para login (SEM usar ScaffoldMessenger pois a tela foi destruída)
                  if (mounted) {
                    debugPrint('🔄 Navegando para login...');
                    // Determinar o tipo de usuário para a mensagem
                    String nomeUsuario = 'Usuário';
                    if (widget.inquilinoId != null &&
                        widget.inquilinoId!.isNotEmpty) {
                      nomeUsuario = 'Inquilino';
                    } else if (widget.proprietarioId != null &&
                        widget.proprietarioId!.isNotEmpty) {
                      nomeUsuario = 'Proprietário';
                    }

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginScreen(usuarioDeletado: nomeUsuario),
                      ),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  debugPrint('❌ ERRO ao excluir conta: $e');
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
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(imagePath, height: 48, width: 48),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Badge contador (se houver)
            if (badgeCount != null && badgeCount > 0)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1976D2), // Azul igual ao do representante
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Conteúdo esmaecido (com opacidade reduzida)
            Opacity(
              opacity: 0.5,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(imagePath, height: 48, width: 48),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
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
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (BuildContext scaffoldContext) {
            return Column(
              children: [
                // Cabeçalho superior padronizado (IDÊNTICO AO REPRESENTANTE)
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
                                      widget.inquilinoId ??
                                      widget.proprietarioId!,
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
                        _buildMenuCardComingSoon(
                          imagePath:
                              'assets/images/Representante/HOME/Imagem_Controle.png',
                          title: 'Controle',
                        ),
                        _buildMenuCard(
                          imagePath:
                              'assets/images/Representante/HOME/Imagem_Reservas.png',
                          title: 'Reservas',
                          onTap: () {
                            debugPrint('🔴 CLICOU EM RESERVAS');
                            debugPrint(
                              'DEBUG: widget.inquilinoId: ${widget.inquilinoId}',
                            );
                            debugPrint(
                              'DEBUG: widget.proprietarioId: ${widget.proprietarioId}',
                            );
                            debugPrint(
                              'DEBUG: widget.unidadeId: ${widget.unidadeId}',
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservaScreen(
                                  condominioId: widget.condominioId,
                                  usuarioId:
                                      widget.inquilinoId ??
                                      widget.proprietarioId ??
                                      '',
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMenuCardComingSoon(
                          imagePath:
                              'assets/images/HOME_Inquilino/Boleto_icone_Inquilino.png',
                          title: 'Boletos',
                        ),
                        _buildMenuCard(
                          imagePath:
                              'assets/images/HOME_Inquilino/Portaria_icone_Inquilino.png',
                          title: 'Portaria',
                          badgeCount:
                              _mensagensNaoLidas, // Passa o contador para o botão Portaria
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
                            ).then((_) {
                              // Recarregar contador ao voltar
                              _inicializarContadorMensagens();
                            });
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
                        color: Colors.black.withValues(alpha: 0.05),
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
                          onTap: () async {
                            // Se for inquilino, navegar para o dashboard do inquilino
                            if (widget.inquilinoId != null &&
                                widget.inquilinoId!.isNotEmpty) {
                              try {
                                // Buscar dados completos do inquilino
                                final response = await SupabaseService.client
                                    .from('inquilinos')
                                    .select('*')
                                    .eq('id', widget.inquilinoId!)
                                    .maybeSingle();

                                if (response != null) {
                                  final inquilino = Inquilino.fromJson(
                                    response,
                                  );
                                  if (mounted) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            InquilinoDashboardScreen(
                                              inquilino: inquilino,
                                            ),
                                      ),
                                    );
                                  }
                                } else {
                                  debugPrint('❌ Inquilino não encontrado');
                                  if (mounted) Navigator.pop(context);
                                }
                              } catch (e) {
                                debugPrint(
                                  '❌ Erro ao buscar dados do inquilino: $e',
                                );
                                if (mounted) Navigator.pop(context);
                              }
                            }
                            // Se for proprietário e tem dados, voltar ao dashboard
                            else if (widget.proprietarioId != null &&
                                widget.proprietarioData != null) {
                              try {
                                // Converter os dados do proprietário para objeto Proprietario
                                final proprietario = Proprietario.fromJson(
                                  widget.proprietarioData
                                          is Map<String, dynamic>
                                      ? widget.proprietarioData
                                            as Map<String, dynamic>
                                      : widget.proprietarioData.toJson()
                                            as Map<String, dynamic>,
                                );
                                if (mounted) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProprietarioDashboardScreen(
                                            proprietario: proprietario,
                                          ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                debugPrint(
                                  '❌ Erro ao navegar para dashboard do proprietário: $e',
                                );
                                if (mounted) Navigator.pop(context);
                              }
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
                              widget.unidadeNome,
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
      ..color = Colors.red.withValues(alpha: 0.85)
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
