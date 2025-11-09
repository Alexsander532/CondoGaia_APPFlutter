import 'package:flutter/material.dart';
import 'package:condogaiaapp/models/mensagem.dart';
import 'package:condogaiaapp/services/conversas_service.dart';
import 'package:condogaiaapp/services/mensagens_service.dart';
import 'package:intl/intl.dart';

/// Tela de chat para REPRESENTANTE (Portaria) conversar com INQUILINO/PROPRIETÁRIO
/// 
/// VERSÃO SIMPLIFICADA - Igual ao ChatInquilinoV2Screen
/// Sem anexos, edição, ou opções complexas
/// 
/// Fluxo:
/// 1. Representante clica em conversa em portaria_representante_screen.dart
/// 2. Abre esta tela (ChatRepresentanteSimples V3)
/// 3. Representante envia mensagem
/// 4. Inquilino vê em tempo real em portaria_inquilino_screen.dart
/// 5. Inquilino responde
/// 6. Representante vê em tempo real
class ChatRepresentanteSimples extends StatefulWidget {
  final String conversaId;
  final String condominioId;
  final String representanteId;
  final String representanteName;
  final String usuarioNome;
  final String? unidadeNumero;

  const ChatRepresentanteSimples({
    Key? key,
    required this.conversaId,
    required this.condominioId,
    required this.representanteId,
    required this.representanteName,
    required this.usuarioNome,
    this.unidadeNumero,
  }) : super(key: key);

  @override
  State<ChatRepresentanteSimples> createState() =>
      _ChatRepresentanteSimples();
}

class _ChatRepresentanteSimples extends State<ChatRepresentanteSimples> {
  late ConversasService _conversasService;
  late MensagensService _mensagensService;
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _conversasService = ConversasService();
    _mensagensService = MensagensService();
    _messageController = TextEditingController();
    _scrollController = ScrollController();

    // Marca conversa como lida quando abre
    _marcarComoLida();

    debugPrint('[CHAT_REP_SIMPLES] Conversa aberta: ${widget.conversaId}');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Marca conversa como lida para representante
  Future<void> _marcarComoLida() async {
    try {
      await _conversasService.marcarComoLida(widget.conversaId, true);
      debugPrint('[CHAT_REP_SIMPLES] OK: Conversa marcada como lida');
    } catch (e) {
      debugPrint('[CHAT_REP_SIMPLES] ERROR ao marcar como lida: $e');
    }
  }

  /// Envia mensagem do representante
  Future<void> _enviarMensagem() async {
    if (_messageController.text.trim().isEmpty) return;

    final textoMensagem = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      debugPrint('[CHAT_REP_SIMPLES] Enviando mensagem...');
      debugPrint('[CHAT_REP_SIMPLES] Conteudo: "$textoMensagem"');
      debugPrint('[CHAT_REP_SIMPLES] Representante: ${widget.representanteName}');

      final mensagem = await _mensagensService.enviar(
        conversaId: widget.conversaId,
        condominioId: widget.condominioId,
        remetenteTipo: 'representante',
        remententeId: widget.representanteId,
        remetenteName: widget.representanteName,
        conteudo: textoMensagem,
      );

      debugPrint('[CHAT_REP_SIMPLES] OK: Mensagem enviada - ${mensagem.id}');

      // Atualiza última mensagem na conversa
      await _conversasService.atualizarUltimaMensagem(
        widget.conversaId,
        textoMensagem,
        'representante',
      );

      // Scroll para a mensagem nova
      _scrollToBottom();
    } catch (e) {
      debugPrint('[CHAT_REP_SIMPLES] ERROR ao enviar: $e');
      _mostrarErro('Erro ao enviar mensagem: $e');
      // Restaurar o texto se falhar
      _messageController.text = textoMensagem;
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  /// Faz scroll para o final da lista
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Formata a data/hora (corrigindo fuso horário)
  String _formatarHora(DateTime data) {
    // Converter ambas para local para comparar corretamente
    final dataLocal = data.isUtc ? data.toLocal() : data;
    final agora = DateTime.now();
    final diferenca = agora.difference(dataLocal);

    if (diferenca.inSeconds < 0) {
      // Se for no futuro, mostrar a hora exata
      final formatter = DateFormat('HH:mm');
      return formatter.format(dataLocal);
    } else if (diferenca.inMinutes < 1) {
      return 'Agora';
    } else if (diferenca.inHours < 1) {
      return 'Há ${diferenca.inMinutes}m';
    } else if (diferenca.inHours < 24) {
      return 'Há ${diferenca.inHours}h';
    } else {
      final formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(dataLocal);
    }
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.usuarioNome,
              style: const TextStyle(
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
      body: Column(
        children: [
          // Lista de mensagens
          Expanded(
            child: StreamBuilder<List<Mensagem>>(
              key: ValueKey('stream-${widget.conversaId}'),
              stream: _mensagensService.streamMensagens(widget.conversaId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1976D2),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint('[CHAT_REP_SIMPLES] STREAM ERROR: ${snapshot.error}');
                  return Center(
                    child: Text(
                      'Erro ao carregar mensagens: ${snapshot.error}',
                    ),
                  );
                }

                final mensagens = snapshot.data ?? [];

                debugPrint('[CHAT_REP_SIMPLES] Stream recebeu ${mensagens.length} mensagens');

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

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final mensagem = mensagens[index];
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
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFF1976D2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
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
    final isRepresentante = mensagem.remetenteTipo == 'representante';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: isRepresentante ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isRepresentante ? const Color(0xFF1976D2) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isRepresentante
                ? null
                : Border.all(color: Colors.grey[300]!),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: isRepresentante
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Nome do remetente (se for do usuário)
              if (!isRepresentante)
                Text(
                  mensagem.remetenteNome,
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
                  color: isRepresentante ? Colors.white : Colors.black87,
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
                      color: isRepresentante
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),
                  if (isRepresentante) ...[
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
