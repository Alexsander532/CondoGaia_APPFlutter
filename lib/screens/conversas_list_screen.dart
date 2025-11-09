import 'package:flutter/material.dart';
import 'package:condogaiaapp/models/conversa.dart';
import 'package:condogaiaapp/services/conversas_service.dart';
import 'package:condogaiaapp/services/condominio_init_service.dart';
import 'package:condogaiaapp/screens/chat_representante_screen_v2.dart';

/// Tela de lista de conversas para o REPRESENTANTE (Portaria)
/// 
/// Exibe todas as conversas do condomínio com:
/// - Lista ordenada por última mensagem (mais recente primeiro)
/// - Preview da última mensagem
/// - Badge de mensagens não lidas
/// - Search para filtrar por nome
/// - Pull-to-refresh
/// - Status de conversa (ativa/arquivada/bloqueada)
/// 
/// Fluxo:
/// 1. Representante abre "Mensagens"
/// 2. Vê lista de conversas: João (A/400), Maria (B/501), etc.
/// 3. Clica em uma conversa para abrir o chat
/// 4. Badge mostra quantas mensagens não lidas tem
class ConversasListScreen extends StatefulWidget {
  final String condominioId;
  final String representanteId;
  final String representanteName;

  const ConversasListScreen({
    Key? key,
    required this.condominioId,
    required this.representanteId,
    required this.representanteName,
  }) : super(key: key);

  @override
  State<ConversasListScreen> createState() => _ConversasListScreenState();
}

class _ConversasListScreenState extends State<ConversasListScreen> {
  late ConversasService _conversasService;
  late CondominioInitService _initService;
  
  // Filtros
  String _searchQuery = '';
  String _statusFiltro = 'ativa'; // 'ativa' | 'arquivada' | 'bloqueada' | 'todas'

  @override
  void initState() {
    super.initState();
    _conversasService = ConversasService();
    _initService = CondominioInitService();
    
    // Inicializa conversas automáticas com proprietários e inquilinos
    _initService.inicializarConversas(widget.condominioId).then((_) {
      print('✅ Conversas inicializadas');
    }).catchError((e) {
      print('Erro ao inicializar conversas: $e');
    });
  }

  /// Filtra conversas baseado em search e status
  List<Conversa> _filtrarConversas(List<Conversa> conversas) {
    var filtered = conversas;

    // Filtrar por status
    if (_statusFiltro != 'todas') {
      filtered = filtered.where((c) => c.status == _statusFiltro).toList();
    }

    // Filtrar por search (nome ou unidade)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        final query = _searchQuery.toLowerCase();
        return c.usuarioNome.toLowerCase().contains(query) ||
            (c.unidadeNumero?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Mostrar info de como usar
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou unidade...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[400]),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filtros de status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _buildFilterChip('Todas', 'todas'),
                const SizedBox(width: 8),
                _buildFilterChip('Ativas', 'ativa'),
                const SizedBox(width: 8),
                _buildFilterChip('Arquivadas', 'arquivada'),
                const SizedBox(width: 8),
                _buildFilterChip('Bloqueadas', 'bloqueada'),
              ],
            ),
          ),

          // Lista de conversas (TODAS do condomínio - automáticas)
          Expanded(
            child: StreamBuilder<List<Conversa>>(
              stream: _conversasService.streamTodasConversasCondominio(
                widget.condominioId,
              ),
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
                        Text(
                          'Erro ao carregar conversas',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
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
                          'Nenhuma conversa',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Nenhuma conversa encontrada para "$_searchQuery"'
                              : 'Você ainda não tem conversas neste condomínio',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final conversas = _filtrarConversas(snapshot.data!);

                if (conversas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_alt_off,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma conversa com esse filtro',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Força atualização do stream
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: conversas.length,
                    itemBuilder: (context, index) {
                      final conversa = conversas[index];
                      return ConversaCard(
                        conversa: conversa,
                        onTap: () => _abrirConversa(context, conversa),
                        onLongPress: () =>
                            _mostrarOpcoes(context, conversa),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Cria um FilterChip para filtro de status
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFiltro == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFiltro = selected ? value : 'todas';
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue[100],
      side: BorderSide(
        color: isSelected ? Colors.blue : Colors.grey[300]!,
        width: isSelected ? 2 : 1,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// Abre a conversa (navega para chat)
  Future<void> _abrirConversa(BuildContext context, Conversa conversa) async {
    // Marca como lida quando abre
    await _conversasService.marcarComoLida(conversa.id, true);

    // Navega para ChatRepresentanteScreenV2
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRepresentanteScreenV2(
            conversaId: conversa.id,
            condominioId: widget.condominioId,
            representanteId: widget.representanteId,
            representanteName: widget.representanteName,
            usuarioNome: conversa.usuarioNome,
            unidadeNumero: conversa.unidadeNumero,
          ),
        ),
      );
    }
  }

  /// Mostra menu de opções ao pressionar por mais tempo
  void _mostrarOpcoes(BuildContext context, Conversa conversa) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _buildMenuOpcoes(conversa),
    );
  }

  /// Menu de opções para a conversa
  Widget _buildMenuOpcoes(Conversa conversa) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversa.usuarioNome,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  conversa.unidadeNumero ?? 'Unidade desconhecida',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Divider(),

          // Opções
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: Text(
              conversa.status == 'arquivada' ? 'Desarquivar' : 'Arquivar',
            ),
            onTap: () {
              Navigator.pop(context);
              _arquivarConversa(conversa);
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Bloquear'),
            enabled: conversa.status != 'bloqueada',
            onTap: conversa.status == 'bloqueada'
                ? null
                : () {
                    Navigator.pop(context);
                    _bloquearConversa(conversa);
                  },
          ),
          ListTile(
            leading: Icon(Icons.notifications_none,
                color: conversa.notificacoesAtivas ? Colors.blue : Colors.grey),
            title: Text(
              conversa.notificacoesAtivas
                  ? 'Desativar notificações'
                  : 'Ativar notificações',
            ),
            onTap: () {
              Navigator.pop(context);
              _alternarNotificacoes(conversa);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Deletar', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deletarConversa(conversa);
            },
          ),
        ],
      ),
    );
  }

  /// Arquiva/desarquiva a conversa
  Future<void> _arquivarConversa(Conversa conversa) async {
    try {
      final novoStatus = conversa.status == 'arquivada' ? 'ativa' : 'arquivada';
      await _conversasService.atualizarStatus(conversa.id, novoStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              novoStatus == 'arquivada' ? 'Conversa arquivada' : 'Conversa desarquivada',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  /// Bloqueia a conversa
  Future<void> _bloquearConversa(Conversa conversa) async {
    try {
      await _conversasService.atualizarStatus(conversa.id, 'bloqueada');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversa bloqueada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  /// Alterna notificações
  Future<void> _alternarNotificacoes(Conversa conversa) async {
    try {
      await _conversasService.atualizarNotificacoes(
        conversa.id,
        !conversa.notificacoesAtivas,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              conversa.notificacoesAtivas
                  ? 'Notificações desativadas'
                  : 'Notificações ativadas',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  /// Deleta a conversa
  Future<void> _deletarConversa(Conversa conversa) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deletar conversa?'),
        content: Text(
          'Tem certeza que deseja deletar a conversa com ${conversa.usuarioNome}? Esta ação não pode ser desfeita.',
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
                await _conversasService.deletar(conversa.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Conversa deletada')),
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
}

/// Card que exibe uma conversa na lista
class ConversaCard extends StatelessWidget {
  final Conversa conversa;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ConversaCard({
    Key? key,
    required this.conversa,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  /// Retorna a cor do status
  Color _getCorStatus() {
    switch (conversa.status) {
      case 'ativa':
        return Colors.green;
      case 'arquivada':
        return Colors.grey;
      case 'bloqueada':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: conversa.temMensagensNaoLidasParaRepresentante
              ? Colors.blue[100]!
              : Colors.grey[200]!,
          width: conversa.temMensagensNaoLidasParaRepresentante ? 2 : 1,
        ),
      ),
      child: Material(
        color: conversa.temMensagensNaoLidasParaRepresentante
            ? Colors.blue[50]
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getCorStatus().withOpacity(0.2),
                  ),
                  child: Center(
                    child: Text(
                      conversa.usuarioNome[0].toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: _getCorStatus(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome + Unidade
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversa.usuarioNome,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conversa.unidadeNumero != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                conversa.unidadeNumero!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Preview da mensagem
                      Text(
                        conversa.subtituloPadrao,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Data + Status
                      Row(
                        children: [
                          Text(
                            conversa.ultimaMensagemDataFormatada,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getCorStatus().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              conversa.status,
                              style: TextStyle(
                                fontSize: 10,
                                color: _getCorStatus(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Badge de não lidas
                if (conversa.temMensagensNaoLidasParaRepresentante)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      conversa.mensagensNaoLidasRepresentante > 99
                          ? '99+'
                          : conversa.mensagensNaoLidasRepresentante.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
