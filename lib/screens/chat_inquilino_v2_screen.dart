import 'package:flutter/material.dart';
import 'package:condogaiaapp/models/mensagem.dart';
import 'package:condogaiaapp/services/conversas_service.dart';
import 'package:condogaiaapp/services/mensagens_service.dart';
import 'package:intl/intl.dart';

/// Tela de chat para INQUILINO/PROPRIETÁRIO conversar com a PORTARIA
/// 
/// Fluxo:
/// 1. Inquilino clica em "Portaria 24 horas" em portaria_inquilino_screen.dart
/// 2. Abre esta tela (ChatInquilinoV2Screen)
/// 3. Inquilino envia mensagem
/// 4. Representante vê em tempo real em portaria_representante_screen.dart
/// 5. Representante responde
/// 6. Inquilino vê em tempo real
class ChatInquilinoV2Screen extends StatefulWidget {
  final String condominioId;
  final String unidadeId;
  final String usuarioId;
  final String usuarioNome;
  final String usuarioTipo; // 'proprietario' | 'inquilino'
  final String? unidadeNumero; // Ex: "B/501"

  const ChatInquilinoV2Screen({
    Key? key,
    required this.condominioId,
    required this.unidadeId,
    required this.usuarioId,
    required this.usuarioNome,
    required this.usuarioTipo,
    this.unidadeNumero,
  }) : super(key: key);

  @override
  State<ChatInquilinoV2Screen> createState() => _ChatInquilinoV2ScreenState();
}

class _ChatInquilinoV2ScreenState extends State<ChatInquilinoV2Screen> {
  late ConversasService _conversasService;
  late MensagensService _mensagensService;
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  String? _conversaId;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _conversasService = ConversasService();
    _mensagensService = MensagensService();
    _messageController = TextEditingController();
    _scrollController = ScrollController();

    // Criar ou obter conversa com a portaria
    _inicializarConversa();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Cria conversa com portaria ou obtém se já existe
  Future<void> _inicializarConversa() async {
    try {
      // Buscar ou criar conversa
      final conversa = await _conversasService.buscarOuCriar(
        condominioId: widget.condominioId,
        unidadeId: widget.unidadeId,
        usuarioTipo: widget.usuarioTipo,
        usuarioId: widget.usuarioId,
        usuarioNome: widget.usuarioNome,
      );

      if (mounted) {
        setState(() {
          _conversaId = conversa.id;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erro ao inicializar conversa: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarErro('Erro ao carregar conversa: $e');
      }
    }
  }

  /// Envia mensagem do usuário
  Future<void> _enviarMensagem() async {
    if (_messageController.text.trim().isEmpty || _conversaId == null) return;

    final textoMensagem = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      // Criar mensagem usando o método 'enviar'
      final mensagem = await _mensagensService.enviar(
        conversaId: _conversaId!,
        condominioId: widget.condominioId,
        remetenteTipo: 'usuario',
        remententeId: widget.usuarioId,
        remetenteName: widget.usuarioNome,
        conteudo: textoMensagem,
      );

      print('✅ Mensagem enviada: ${mensagem.id}');

      // Scroll para a mensagem nova
      _scrollToBottom();
    } catch (e) {
      print('❌ Erro ao enviar mensagem: $e');
      _mostrarErro('Erro ao enviar mensagem: $e');
      // Restaurar o texto se falhar
      _messageController.text = textoMensagem;
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  /// Faz scroll para o final da lista - SEMPRE FUNCIONA
  /// Tenta múltiplas vezes para garantir que funcione
  void _scrollToBottom() {
    try {
      if (_scrollController.hasClients) {
        // Tentar scroll imediato com jump
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
        
        print('[CHAT_INQV2] ✅ Jump scroll para o final');
        
        // Também tentar com animação como backup
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            ).catchError((e) {
              print('[CHAT_INQV2] Erro no animate scroll: $e');
            });
          }
        });
      } else {
        print('[CHAT_INQV2] ⚠️ ScrollController sem clients');
      }
    } catch (e, stackTrace) {
      print('[CHAT_INQV2] ❌ ERRO ao fazer scroll: $e');
      print('[CHAT_INQV2] Stack: $stackTrace');
    }
  }

  /// Formata a data/hora (fuso horário de Brasília)
  String _formatarHora(DateTime data) {
    // Converter para fuso horário de Brasília (UTC-3 = UTC + 3 horas)
    final dataUtc = data.isUtc ? data : data.toUtc();
    final dataBrasilia = dataUtc.add(const Duration(hours: 0));
    
    // Sempre mostrar a data e hora no formato DD/MM/AA - HH:mm
    final formatter = DateFormat('dd/MM/yy - HH:mm');
    return formatter.format(dataBrasilia);
  }

  /// Mostra mensagem de erro
  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Portaria',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.unidadeNumero != null)
              Text(
                'Unidade: ${widget.unidadeNumero}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1976D2)),
            )
          : Column(
              children: [
                // Lista de mensagens
                Expanded(
                  child: _conversaId == null
                      ? const Center(
                          child: Text('Erro ao carregar conversa'),
                        )
                      : StreamBuilder<List<Mensagem>>(
                          stream: _mensagensService.streamMensagens(
                            _conversaId!,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF1976D2),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Erro ao carregar mensagens: ${snapshot.error}',
                                ),
                              );
                            }

                            final mensagens = snapshot.data ?? [];

                            if (mensagens.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.mail_outline,
                                      size: 64,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Nenhuma mensagem ainda',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Envie uma mensagem para começar a conversa',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Faz scroll para a última mensagem quando chega uma nova
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Future.delayed(const Duration(milliseconds: 50), () {
                                _scrollToBottom();
                              });
                            });

                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount: mensagens.length,
                              reverse: false,
                              itemBuilder: (context, index) {
                                final mensagem = mensagens[index];
                                
                                // Após renderizar o último item, faz scroll
                                if (index == mensagens.length - 1) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    Future.delayed(const Duration(milliseconds: 10), () {
                                      _scrollToBottom();
                                    });
                                  });
                                }
                                
                                return _buildMensagemBubble(mensagem);
                              },
                            );
                          },
                        ),
                ),

                // Input de mensagem
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          enabled: !_isSending,
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Digite sua mensagem...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide:
                                  BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide:
                                  BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Color(0xFF1976D2),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: _isSending
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                          onPressed: _isSending ? null : _enviarMensagem,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /// Constrói bubble de mensagem
  Widget _buildMensagemBubble(Mensagem mensagem) {
    final isUsuario = mensagem.remetenteTipo == 'usuario';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: isUsuario ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isUsuario
                ? const Color(0xFF1976D2)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isUsuario
                ? null
                : Border.all(color: Colors.grey[300]!),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: isUsuario
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Nome do remetente (portaria)
              if (!isUsuario)
                Text(
                  'Portaria',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),

              // Conteúdo da mensagem
              Text(
                mensagem.conteudo,
                style: TextStyle(
                  color: isUsuario ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

              // Hora e status
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatarHora(mensagem.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isUsuario
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),
                  if (isUsuario) ...[
                    const SizedBox(width: 4),
                    Icon(
                      _getIconeStatus(mensagem.status),
                      size: 14,
                      color: Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Retorna ícone baseado no status
  IconData _getIconeStatus(String status) {
    switch (status) {
      case 'entregue':
        return Icons.done_all;
      case 'lida':
        return Icons.done_all;
      case 'enviada':
        return Icons.done;
      default:
        return Icons.hourglass_empty;
    }
  }
}
