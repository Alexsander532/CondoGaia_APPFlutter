import 'package:flutter/material.dart';
import 'package:condogaiaapp/models/mensagem.dart';
import 'package:condogaiaapp/services/mensagens_service.dart';
import 'package:condogaiaapp/services/conversas_service.dart';
import 'package:condogaiaapp/widgets/foto_perfil_avatar.dart';

/// Tela de chat para USUÁRIO (Proprietário/Inquilino) conversar com Portaria
/// 
/// Permite que moradores:
/// - Enviem mensagens para a portaria
/// - Vejam histórico de mensagens
/// - Anexem arquivos/imagens
/// - Editem mensagens próprias
/// - Respondam a mensagens
/// 
/// Fluxo:
/// 1. Usuário abre "Mensagens" na app do morador
/// 2. Vê a conversa com a portaria
/// 3. Pode digitar e enviar mensagens
/// 4. Recebe respostas em tempo real
class MensagemPortariaScreen extends StatefulWidget {
  final String conversaId;
  final String condominioId;
  final String usuarioId;
  final String usuarioNome;
  final String unidadeNumero;

  const MensagemPortariaScreen({
    Key? key,
    required this.conversaId,
    required this.condominioId,
    required this.usuarioId,
    required this.usuarioNome,
    required this.unidadeNumero,
  }) : super(key: key);

  @override
  State<MensagemPortariaScreen> createState() => _MensagemPortariaScreenState();
}

class _MensagemPortariaScreenState extends State<MensagemPortariaScreen> {
  late MensagensService _mensagensService;
  late ConversasService _conversasService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _mensagensService = MensagensService();
    _conversasService = ConversasService();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Envia uma mensagem
  Future<void> _enviarMensagem() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await _mensagensService.enviar(
        conversaId: widget.conversaId,
        condominioId: widget.condominioId,
        remetenteTipo: 'usuario',
        remententeId: widget.usuarioId,
        remetenteName: widget.usuarioNome,
        conteudo: _messageController.text.trim(),
        tipoConteudo: 'texto',
      );

      // Atualiza última mensagem na conversa
      await _conversasService.atualizarUltimaMensagem(
        widget.conversaId,
        _messageController.text.trim(),
        'usuario',
      );

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar: $e')),
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
        if (!msg.lida && msg.remetenteTipo == 'representante') {
          await _mensagensService.marcarLida(msg.id);
        }
      }
    } catch (e) {
      // Silent error - não precisa notificar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Portaria', style: TextStyle(fontSize: 16)),
            Text(
              'Unidade ${widget.unidadeNumero}',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Lista de mensagens
          Expanded(
            child: StreamBuilder<List<Mensagem>>(
              stream: _mensagensService.streamMensagens(widget.conversaId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text('Erro ao carregar mensagens'),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                        const SizedBox(height: 8),
                        Text(
                          'Comece uma conversa com a portaria',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                final mensagens = snapshot.data!;
                
                // Marca como lidas
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _marcarComoLidas(mensagens);
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final msg = mensagens[index];
                    final isUsuario = msg.remetenteTipo == 'usuario';

                    return MensagemTile(
                      mensagem: msg,
                      isUsuario: isUsuario,
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
                    // TODO: Implementar seleção de arquivo
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

/// Widget para exibir uma mensagem individual
class MensagemTile extends StatelessWidget {
  final Mensagem mensagem;
  final bool isUsuario;

  const MensagemTile({
    Key? key,
    required this.mensagem,
    required this.isUsuario,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Row(
          mainAxisAlignment:
              isUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar (esquerda, apenas para não usuário)
            if (!isUsuario)
              Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 4),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: FotoPerfilAvatar(
                    fotoUrl: mensagem.remetenteFoto,
                    nome: mensagem.remetenteNome,
                    radius: 16,
                  ),
                ),
              ),

            // Coluna com mensagem
            Expanded(
              child: Column(
                crossAxisAlignment: isUsuario
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Remetente (se necessário)
                  if (!isUsuario)
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
                      color: isUsuario ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      mensagem.conteudo,
                      style: TextStyle(
                        color: isUsuario ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
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
                        if (isUsuario) ...[
                          const SizedBox(width: 4),
                          Icon(
                            mensagem.lida
                                ? Icons.done_all
                                : Icons.done,
                            size: 12,
                            color: mensagem.lida
                                ? Colors.blue
                                : Colors.grey[500],
                          ),
                        ],
                      ],
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
