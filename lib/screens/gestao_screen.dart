import 'package:flutter/material.dart';
import 'unidade_morador_screen.dart';
import 'portaria_representante_screen.dart';
import 'package:condogaiaapp/services/unidade_service.dart';
import '../features/Representante_Features/email_gestao/screens/email_gestao_screen.dart';

class GestaoScreen extends StatefulWidget {
  final String? condominioId;
  final String? condominioNome;
  final String? condominioCnpj;

  const GestaoScreen({
    super.key,
    this.condominioId,
    this.condominioNome,
    this.condominioCnpj,
  });

  @override
  State<GestaoScreen> createState() => _GestaoScreenState();
}

class _GestaoScreenState extends State<GestaoScreen> {
  final UnidadeService _unidadeService = UnidadeService();
  bool? _temBlocos;
  bool _loadingTemBlocos = false;

  // Lista de itens de gestão baseada na imagem
  final List<Map<String, dynamic>> gestaoItems = [
    {
      'title': 'Boleto',
      'imagePath':
          'assets/images/HOME_Inquilino/Gestao_Inquilino/Boleto_icone_gestao.png',
    },
    {
      'title': 'Acordo',
      'imagePath':
          'assets/images/HOME_Inquilino/Gestao_Inquilino/acordoiconegestao.png',
    },
    {
      'title': 'Relatórios',
      'imagePath':
          'assets/images/HOME_Inquilino/Gestao_Inquilino/relatoriosiconegestao.png',
    },
    {
      'title': 'E-Mail',
      'imagePath':
          'assets/images/HOME_Inquilino/Gestao_Inquilino/emailiconegestao.png',
    },
    {
      'title': 'Despesa/Receita',
      'imagePath':
          'assets/images/HOME_Inquilino/Gestao_Inquilino/despesareceitaiconegestao.png',
    },
    {
      'title': 'Morador/Unidade',
      'imagePath':
          'assets/images/HOME_Inquilino/Gestao_Inquilino/moradorunidadeiconegestao.png',
    },
    {
      'title': 'Condomínio',
      'imagePath':
          'assets/images/HOME_Inquilino/Gestao_Inquilino/condominioiconegestao.png',
    },
    {
      'title': 'Portaria',
      'imagePath':
          'assets/images/HOME_Inquilino/Gestao_Inquilino/portariaiconegestao.png',
    },
  ];

  Widget _buildGestaoItem({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 1),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: Row(
          children: [
            // Ícone do item
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported,
                    color: Color(0xFFBDBDBD),
                    size: 24,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Título do item
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2E3A59),
                ),
              ),
            ),
            // Seta para a direita
            const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho superior padronizado
            Container(
              color: Colors.white,
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
            Container(height: 1, color: const Color(0xFFE0E0E0)),

            // Lista de itens de gestão
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: gestaoItems.length,
                  itemBuilder: (context, index) {
                    final item = gestaoItems[index];
                    return _buildGestaoItem(
                      title: item['title'],
                      imagePath: item['imagePath'],
                      onTap: () {
                        if (item['title'] == 'Morador/Unidade') {
                          print(
                            '🚀 [GestaoScreen] Navegando para UnidadeMoradorScreen',
                          );
                          print('   condominioId: ${widget.condominioId}');
                          print('   condominioNome: ${widget.condominioNome}');
                          print('   condominioCnpj: ${widget.condominioCnpj}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UnidadeMoradorScreen(
                                condominioId: widget.condominioId,
                                condominioNome: widget.condominioNome,
                                condominioCnpj: widget.condominioCnpj,
                              ),
                            ),
                          );
                        } else if (item['title'] == 'Portaria') {
                          debugPrint('═' * 80);
                          debugPrint(
                            '🔴 [GESTAO] ═══ NAVEGANDO PARA PORTARIA ═══',
                          );
                          debugPrint('═' * 80);
                          debugPrint('[GESTAO] Clicou em: Portaria');
                          debugPrint(
                            '[GESTAO] widget.condominioId: ${widget.condominioId}',
                          );
                          debugPrint(
                            '[GESTAO] widget.condominioNome: ${widget.condominioNome}',
                          );
                          debugPrint(
                            '[GESTAO] widget.condominioCnpj: ${widget.condominioCnpj}',
                          );

                          // Carrega temBlocos do banco ANTES de navegar
                          _carregarTemBlocosDoCondominio()
                              .then((temBlocosValue) {
                                debugPrint('[GESTAO] ═' * 40);
                                debugPrint(
                                  '[GESTAO] .then() EXECUTADO - Navegando',
                                );
                                debugPrint(
                                  '[GESTAO] temBlocos retornado de _carregarTemBlocosDoCondominio(): $temBlocosValue',
                                );
                                debugPrint(
                                  '[GESTAO] Tipo: ${temBlocosValue.runtimeType}',
                                );
                                debugPrint(
                                  '[GESTAO] ✓ Navegando para Portaria com temBlocos: $temBlocosValue',
                                );
                                debugPrint(
                                  '[GESTAO] Criando PortariaRepresentanteScreen...',
                                );
                                debugPrint('[GESTAO] ═' * 40);

                                final screen = PortariaRepresentanteScreen(
                                  condominioId: widget.condominioId,
                                  condominioNome: widget.condominioNome,
                                  condominioCnpj: widget.condominioCnpj,
                                  temBlocos:
                                      temBlocosValue, // Usando valor do banco!
                                );

                                debugPrint(
                                  '[GESTAO] ✓ Screen criada com temBlocos = $temBlocosValue',
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => screen,
                                  ),
                                );

                                debugPrint(
                                  '[GESTAO] ✓ Navigator.push() chamado',
                                );
                                debugPrint('═' * 80);
                              })
                              .catchError((e) {
                                debugPrint('[GESTAO] ❌ ERRO NO .catchError()');
                                debugPrint('[GESTAO] Erro: $e');
                                debugPrint(
                                  '[GESTAO] Navegando com padrão (true)',
                                );
                                debugPrint('═' * 80);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PortariaRepresentanteScreen(
                                          condominioId: widget.condominioId,
                                          condominioNome: widget.condominioNome,
                                          condominioCnpj: widget.condominioCnpj,
                                          temBlocos:
                                              true, // Padrão: true em caso de erro
                                        ),
                                  ),
                                );
                              });
                        } else if (item['title'] == 'E-Mail') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmailGestaoScreen(
                                condominioId: widget.condominioId ?? '',
                              ),
                            ),
                          );
                        } else {
                          // TODO: Implementar navegação para ${item['title']}
                          print('Clicou em: ${item['title']}');
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Carrega temBlocos do banco de dados antes de navegar para Portaria
  Future<bool> _carregarTemBlocosDoCondominio() async {
    debugPrint('═' * 80);
    debugPrint('🔵 [GESTAO] ═══ CARREGANDO TEM_BLOCOS DO CONDOMINIO ═══');
    debugPrint('═' * 80);
    debugPrint('[GESTAO] Início da função _carregarTemBlocosDoCondominio()');
    debugPrint('[GESTAO] widget.condominioId: ${widget.condominioId}');

    if (widget.condominioId == null || widget.condominioId!.isEmpty) {
      debugPrint('[GESTAO] ❌ condominioId é nulo/vazio, usando padrão (true)');
      _temBlocos = true;
      debugPrint(
        '[GESTAO] _temBlocos definido como: true (padrão por ID vazio)',
      );
      debugPrint('═' * 80);
      return true;
    }

    try {
      debugPrint('[GESTAO] 🔄 Chamando _unidadeService.obterCondominioById()');
      debugPrint('[GESTAO] Aguardando resposta do banco...');
      _loadingTemBlocos = true;

      final condominio = await _unidadeService.obterCondominioById(
        widget.condominioId!,
      );

      debugPrint('[GESTAO] ✓ Resposta recebida do banco');

      if (condominio != null) {
        debugPrint('[GESTAO] ✓ Condominio NÃO é nulo');
        debugPrint('[GESTAO] Nome: ${condominio.nomeCondominio}');
        debugPrint('[GESTAO] ID: ${condominio.id}');
        debugPrint('[GESTAO] CNPJ: ${condominio.cnpj}');
        debugPrint('[GESTAO] temBlocos DO OBJETO: ${condominio.temBlocos}');
        debugPrint(
          '[GESTAO] Tipo de temBlocos: ${condominio.temBlocos.runtimeType}',
        );

        final novoValor = condominio.temBlocos;
        debugPrint('[GESTAO] Atribuindo: _temBlocos = $novoValor');

        setState(() {
          _temBlocos = novoValor;
          debugPrint(
            '[GESTAO] setState() chamado com _temBlocos = $_temBlocos',
          );
        });

        debugPrint('[GESTAO] ✓ _temBlocos atualmente: $_temBlocos');
        debugPrint('[GESTAO] ✓ Retornando valor: $novoValor');
        debugPrint('═' * 80);
        return novoValor;
      } else {
        debugPrint('[GESTAO] ❌ Condominio é NULO (não encontrado no banco)');
        _temBlocos = true;
        debugPrint(
          '[GESTAO] _temBlocos definido como: true (padrão por condominio nulo)',
        );
        debugPrint('[GESTAO] Retornando valor: true');
        debugPrint('═' * 80);
        return true;
      }
    } catch (e) {
      debugPrint('[GESTAO] ❌ EXCEÇÃO ao carregar condominio');
      debugPrint('[GESTAO] Tipo da exceção: ${e.runtimeType}');
      debugPrint('[GESTAO] Mensagem: $e');
      debugPrint('[GESTAO] Stack trace: ${StackTrace.current}');
      _temBlocos = true; // Padrão: true
      debugPrint('[GESTAO] _temBlocos definido como: true (padrão por erro)');
      debugPrint('[GESTAO] Retornando valor: true');
      debugPrint('═' * 80);
      return true;
    } finally {
      _loadingTemBlocos = false;
      debugPrint('[GESTAO] [FINALLY] _loadingTemBlocos = false');
    }
  }
}
