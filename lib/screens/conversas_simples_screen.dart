import 'package:flutter/material.dart';
import 'package:condogaiaapp/models/conversa.dart';
import 'package:condogaiaapp/services/conversas_service.dart';
import 'package:condogaiaapp/services/condominio_init_service.dart';
import 'package:condogaiaapp/screens/chat_representante_screen_v2.dart';

/// Tela de lista de conversas SIMPLIFICADA para o REPRESENTANTE (Portaria)
/// 
/// Versão simplificada com:
/// - Apenas search por nome/unidade (sem filtros de status)
/// - UI limpa e minimalista similar à foto
/// - Lista ordenada por última mensagem
/// - Preview da última mensagem
/// - Badge de não-lidas
class ConversasSimples extends StatefulWidget {
  final String condominioId;
  final String representanteId;
  final String representanteName;

  const ConversasSimples({
    Key? key,
    required this.condominioId,
    required this.representanteId,
    required this.representanteName,
  }) : super(key: key);

  @override
  State<ConversasSimples> createState() => _ConversasSimplesState();
}

class _ConversasSimplesState extends State<ConversasSimples> {
  late ConversasService _conversasService;
  late CondominioInitService _initService;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late DateTime _lastRefresh;

  @override
  void initState() {
    super.initState();
    _lastRefresh = DateTime.now();
    _conversasService = ConversasService();
    _initService = CondominioInitService();
    
    // Inicializa conversas automáticas
    _initService.inicializarConversas(widget.condominioId).then((_) {
      if (mounted) {
        print('OK: Conversas inicializadas');
      }
    }).catchError((e) {
      if (mounted) {
        print('Erro ao inicializar conversas: $e');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filtra apenas por search (sem status)
  List<Conversa> _filtrarConversas(List<Conversa> conversas) {
    if (_searchQuery.isEmpty) {
      return conversas;
    }

    final query = _searchQuery.toLowerCase();
    return conversas.where((c) {
      return c.usuarioNome.toLowerCase().contains(query) ||
          (c.unidadeNumero?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          debugPrint('[CONVERSAS_SIMPLES] Voltando da conversa, refrescando lista');
          // Força um rebuild para recarregar os dados do stream
          if (mounted) {
            setState(() {});
          }
        }
      },
      child: Column(
      children: [
        // Search bar - SIMPLIFICADA (sem bordas complexas)
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
            decoration: InputDecoration(
              hintText: 'Buscar conversas...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 22),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1976D2)),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        // Lista de conversas (SEM FILTROS DE STATUS)
        Expanded(
          child: StreamBuilder<List<Conversa>>(
            key: ValueKey(_lastRefresh.toString()),
            stream: _conversasService.streamTodasConversasCondominio(
              widget.condominioId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                debugPrint('[CONVERSAS_SIMPLES] StreamBuilder waiting...');
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1976D2)),
                );
              }

              if (snapshot.hasError) {
                debugPrint('[CONVERSAS_SIMPLES] STREAM ERROR: ${snapshot.error}');
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
                    ],
                  ),
                );
              }

              final conversas = _filtrarConversas(snapshot.data!);
              
              debugPrint('[CONVERSAS_SIMPLES] StreamBuilder recebeu ${conversas.length} conversas');
              if (conversas.isNotEmpty) {
                final primeiraConversa = conversas.first;
                debugPrint('[CONVERSAS_SIMPLES]   - Primeira: ${primeiraConversa.usuarioNome}');
                debugPrint('[CONVERSAS_SIMPLES]   - Preview: ${primeiraConversa.ultimaMensagemPreview}');
                debugPrint('[CONVERSAS_SIMPLES]   - Updated: ${primeiraConversa.updatedAt}');
              }

              if (conversas.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma conversa encontrada',
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
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  itemCount: conversas.length,
                  itemBuilder: (context, index) {
                    final conversa = conversas[index];
                    return _buildConversaCard(context, conversa);
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

  /// Card de conversa - SIMILAR À FOTO ANEXADA
  Widget _buildConversaCard(BuildContext context, Conversa conversa) {
    // Cores para avatar (alternando)
    final colors = [
      const Color(0xFF2C3E50), // Azul escuro
      const Color(0xFF3498DB), // Azul
      const Color(0xFF1ABC9C), // Turquesa
      const Color(0xFF2ECC71), // Verde
      const Color(0xFF9B59B6), // Roxo
    ];
    final colorIndex = conversa.id.hashCode % colors.length;
    final avatarColor = colors[colorIndex];

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _abrirConversa(context, conversa),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Avatar com iniciais
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getIniciaisUsuario(conversa.usuarioNome),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Nome + Unidade + Última mensagem
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome + Unidade (mesma linha)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversa.usuarioNome,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              conversa.unidadeNumero ?? 'N/A',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Data + Preview de última mensagem
                      Row(
                        children: [
                          Text(
                            _formatarData(conversa.updatedAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              conversa.ultimaMensagemPreview ?? 'Sem mensagens',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: conversa.ultimaMensagemPreview == null
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Badge de não-lidas
                if (conversa.temMensagensNaoLidasParaRepresentante)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${conversa.mensagensNaoLidasRepresentante}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.done_all,
                    size: 16,
                    color: Colors.grey[400],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formata a data para exibição (similar à foto: "25/11/2023 17:20")
  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inMinutes < 1) {
      return 'Agora';
    } else if (diferenca.inMinutes < 60) {
      return 'Há ${diferenca.inMinutes}m';
    } else if (diferenca.inHours < 24) {
      return 'Há ${diferenca.inHours}h';
    } else if (diferenca.inDays < 7) {
      return 'Há ${diferenca.inDays}d';
    } else {
      // Formato completo
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Extrai as iniciais do nome do usuário
  String _getIniciaisUsuario(String nome) {
    final partes = nome.split(' ');
    if (partes.isEmpty) return '?';
    if (partes.length == 1) {
      return partes[0].substring(0, 1).toUpperCase();
    }
    return (partes[0].substring(0, 1) + partes[1].substring(0, 1))
        .toUpperCase();
  }

  /// Abre a conversa (navega para chat)
  Future<void> _abrirConversa(
    BuildContext context,
    Conversa conversa,
  ) async {
    debugPrint('[CONVERSAS_SIMPLES] ABRINDO CONVERSA');
    debugPrint('[CONVERSAS_SIMPLES] Conversa ID: ${conversa.id}');
    debugPrint('[CONVERSAS_SIMPLES] Usuario: ${conversa.usuarioNome}');
    debugPrint('[CONVERSAS_SIMPLES] Unidade: ${conversa.unidadeNumero}');
    debugPrint('[CONVERSAS_SIMPLES] Representante ID (widget): ${widget.representanteId}');
    debugPrint('[CONVERSAS_SIMPLES] Representante Nome (widget): ${widget.representanteName}');
    
    // Valida dados críticos
    if (widget.representanteId.isEmpty) {
      debugPrint('[CONVERSAS_SIMPLES] ERROR: representanteId está VAZIO!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: ID do representante não carregado')),
        );
      }
      return;
    }

    // Marca como lida
    debugPrint('[CONVERSAS_SIMPLES] Marcando conversa como lida...');
    try {
      await _conversasService.marcarComoLida(conversa.id, true);
      debugPrint('[CONVERSAS_SIMPLES] OK: Conversa marcada como lida');
    } catch (e) {
      debugPrint('[CONVERSAS_SIMPLES] WARN: Erro ao marcar como lida: $e');
    }

    // Navega para ChatRepresentanteScreenV2
    if (mounted) {
      debugPrint('[CONVERSAS_SIMPLES] Navegando para ChatRepresentanteScreenV2...');
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
      debugPrint('[CONVERSAS_SIMPLES] OK: Tela de chat aberta');
    }
  }
}

