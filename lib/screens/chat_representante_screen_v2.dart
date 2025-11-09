import 'package:flutter/material.dart';
import 'package:condogaiaapp/models/mensagem.dart';
import 'package:condogaiaapp/services/mensagens_service.dart';
import 'package:condogaiaapp/services/conversas_service.dart';

/// Tela de chat para REPRESENTANTE (Portaria) conversar com Usuário
/// 
/// Permite que representante:
/// - Receba e responda mensagens de moradores
/// - Veja histórico de conversas
/// - Marque como lida
/// - Tenha admin features (arquivar, bloquear, etc)
/// 
/// Fluxo:
/// 1. Representante clica em conversa na lista
/// 2. Abre ChatRepresentanteScreen
/// 3. Pode responder em tempo real
/// 4. Mensagens atualizam automaticamente
class ChatRepresentanteScreenV2 extends StatefulWidget {
  final String conversaId;
  final String condominioId;
  final String representanteId;
  final String representanteName;
  final String usuarioNome;
  final String? unidadeNumero;

  const ChatRepresentanteScreenV2({
    Key? key,
    required this.conversaId,
    required this.condominioId,
    required this.representanteId,
    required this.representanteName,
    required this.usuarioNome,
    this.unidadeNumero,
  }) : super(key: key);

  @override
  State<ChatRepresentanteScreenV2> createState() =>
      _ChatRepresentanteScreenV2State();
}

class _ChatRepresentanteScreenV2State extends State<ChatRepresentanteScreenV2> {
  late MensagensService _mensagensService;
  late ConversasService _conversasService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    debugPrint('[CHAT_REP_V2] INICIALIZANDO TELA');
    debugPrint('[CHAT_REP_V2] Conversa ID: ${widget.conversaId}');
    debugPrint('[CHAT_REP_V2] Condominio ID: ${widget.condominioId}');
    debugPrint('[CHAT_REP_V2] Representante ID: ${widget.representanteId}');
    debugPrint('[CHAT_REP_V2] Representante Nome: ${widget.representanteName}');
    debugPrint('[CHAT_REP_V2] Usuario: ${widget.usuarioNome}');
    debugPrint('[CHAT_REP_V2] Unidade: ${widget.unidadeNumero}');
    
    _mensagensService = MensagensService();
    _conversasService = ConversasService();
    
    // Marca conversa como lida quando abre
    _marcarConversaComoLida();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Marca conversa como lida para representante
  Future<void> _marcarConversaComoLida() async {
    try {
      debugPrint('[CHAT_REP_V2] Marcando conversa ${widget.conversaId} como lida...');
      await _conversasService.marcarComoLida(widget.conversaId, true);
      debugPrint('[CHAT_REP_V2] OK: Conversa marcada como lida');
    } catch (e) {
      debugPrint('[CHAT_REP_V2] ERROR: ao marcar como lida: $e');
    }
  }

  /// Envia uma mensagem
  Future<void> _enviarMensagem() async {
    if (_messageController.text.trim().isEmpty) {
      debugPrint('[CHAT_REP_V2] WARN: Mensagem vazia, ignorando');
      return;
    }

    debugPrint('[CHAT_REP_V2] ENVIANDO MENSAGEM');
    debugPrint('[CHAT_REP_V2] Conteudo: "${_messageController.text.trim()}"');
    debugPrint('[CHAT_REP_V2] Conversa ID: ${widget.conversaId}');
    debugPrint('[CHAT_REP_V2] Condominio ID: ${widget.condominioId}');
    debugPrint('[CHAT_REP_V2] Representante ID: ${widget.representanteId}');
    debugPrint('[CHAT_REP_V2] Representante Nome: ${widget.representanteName}');

    // Validação CRÍTICA: representanteId não pode estar vazio
    if (widget.representanteId.isEmpty) {
      debugPrint('[CHAT_REP_V2] ERRO CRÍTICO: representanteId está VAZIO!');
      debugPrint('═' * 80);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(' Erro: ID do representante inválido')),
        );
      }
      return;
    }

    try {
      debugPrint(' [CHAT_REP_V2] Chamando MensagensService.enviar()...');
      
      final mensagem = await _mensagensService.enviar(
        conversaId: widget.conversaId,
        condominioId: widget.condominioId,
        remetenteTipo: 'representante',
        remententeId: widget.representanteId,
        remetenteName: widget.representanteName,
        conteudo: _messageController.text.trim(),
        tipoConteudo: 'texto',
      );
      
      debugPrint('[CHAT_REP_V2] OK: Mensagem enviada com sucesso!');
      debugPrint('[CHAT_REP_V2] Mensagem ID: ${mensagem.id}');
      debugPrint('[CHAT_REP_V2] Status: ${mensagem.status}');

      debugPrint('[CHAT_REP_V2] Atualizando ultima mensagem na conversa...');
      // Atualiza última mensagem na conversa
      await _conversasService.atualizarUltimaMensagem(
        widget.conversaId,
        _messageController.text.trim(),
        'representante',
      );
      debugPrint('[CHAT_REP_V2] OK: Conversa atualizada');

      _messageController.clear();
      _scrollToBottom();
    } catch (e, stackTrace) {
      debugPrint('[CHAT_REP_V2] ERRO ao enviar mensagem!');
      debugPrint('   📌 Erro: $e');
      debugPrint('   📌 Stack: $stackTrace');
      debugPrint('═' * 80);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' Erro ao enviar: $e')),
        );
      }
    }
  }

  /// Scroll para o final das mensagens
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

  /// Marca mensagens como lidas
  Future<void> _marcarComoLidas(List<Mensagem> mensagens) async {
    try {
      for (final msg in mensagens) {
        if (!msg.lida && msg.remetenteTipo == 'usuario') {
          await _mensagensService.marcarLida(msg.id);
        }
      }
    } catch (e) {
      // Silent error
    }
  }

  /// Edita uma mensagem
  Future<void> _editarMensagem(Mensagem mensagem) async {
    final controller = TextEditingController(text: mensagem.conteudo);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar mensagem'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Digite o novo conteúdo',
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _mensagensService.editar(
                  mensagem.id,
                  controller.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mensagem editada')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  /// Deleta uma mensagem
  Future<void> _deletarMensagem(Mensagem mensagem) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deletar mensagem?'),
        content: const Text(
          'Tem certeza que deseja deletar esta mensagem? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _mensagensService.deletar(mensagem.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mensagem deletada')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.usuarioNome, style: const TextStyle(fontSize: 16)),
            if (widget.unidadeNumero != null)
              Text(
                'Unidade ${widget.unidadeNumero}',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Menu de opções (arquivar, bloquear, etc)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensagens
          Expanded(
            child: StreamBuilder<List<Mensagem>>(
              key: ValueKey('stream-${widget.conversaId}'),
              stream: _mensagensService.streamMensagens(widget.conversaId),
              builder: (context, snapshot) {
                debugPrint('[CHAT_REP_V2] StreamBuilder status: ${snapshot.connectionState}');
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint('[CHAT_REP_V2] STREAM ERROR: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        const Text('Erro ao carregar mensagens'),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  debugPrint('[CHAT_REP_V2] Nenhuma mensagem ainda');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mail_outline,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma mensagem ainda',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                final mensagens = snapshot.data!;
                debugPrint('[CHAT_REP_V2] Recebeu ${mensagens.length} mensagens do stream');
                
                // Marca como lidas
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _marcarComoLidas(mensagens);
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final msg = mensagens[index];
                    final isRepresentante = msg.remetenteTipo == 'representante';

                    return MensagemChatTile(
                      mensagem: msg,
                      isRepresentante: isRepresentante,
                      onEdit: () => _editarMensagem(msg),
                      onDelete: () => _deletarMensagem(msg),
                    );
                  },
                );
              },
            ),
          ),

          // Input de mensagem
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Botão anexo
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Anexos em desenvolvimento')),
                    );
                  },
                  color: Colors.grey[600],
                ),

                // Input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
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
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    minLines: 1,
                  ),
                ),

                const SizedBox(width: 8),

                // Botão enviar
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _enviarMensagem,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para exibir uma mensagem individual com opções
class MensagemChatTile extends StatelessWidget {
  final Mensagem mensagem;
  final bool isRepresentante;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MensagemChatTile({
    Key? key,
    required this.mensagem,
    required this.isRepresentante,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isRepresentante ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: GestureDetector(
          onLongPress: isRepresentante
              ? () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text('Editar'),
                            onTap: () {
                              Navigator.pop(context);
                              onEdit?.call();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete,
                                color: Colors.red),
                            title:
                                const Text('Deletar', style: TextStyle(color: Colors.red)),
                            onTap: () {
                              Navigator.pop(context);
                              onDelete?.call();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
              : null,
          child: Column(
            crossAxisAlignment: isRepresentante
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Remetente (se necessário)
              if (!isRepresentante)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    mensagem.remetenteNome,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // Mensagem
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isRepresentante ? Colors.blue : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mensagem.conteudo,
                      style: TextStyle(
                        color: isRepresentante
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    if (mensagem.editada)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '(editado)',
                          style: TextStyle(
                            fontSize: 10,
                            color: isRepresentante
                                ? Colors.white70
                                : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Data/Status
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mensagem.horaFormatada,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    if (isRepresentante) ...[
                      const SizedBox(width: 4),
                      Icon(
                        mensagem.lida ? Icons.done_all : Icons.done,
                        size: 12,
                        color:
                            mensagem.lida ? Colors.blue : Colors.grey[500],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
