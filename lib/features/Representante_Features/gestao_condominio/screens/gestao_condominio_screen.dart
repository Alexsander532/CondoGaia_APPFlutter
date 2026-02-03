import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/condominio.dart';
import '../../../../models/representante.dart';
import '../services/gestao_condominio_service.dart';
import '../widgets/dados_condominio_widget.dart';
import '../widgets/financeiro_condominio_widget.dart';
import '../widgets/layout_boleto_widget.dart';
import '../widgets/conta_bancaria_widget.dart';
import '../widgets/textos_condominio_widget.dart';
import '../widgets/perfil_usuario_condominio_widget.dart';
import '../widgets/protesto_baixa_condominio_widget.dart';
import '../widgets/garantidora_condominio_widget.dart';
import 'categoria_subcategoria_screen.dart';

class GestaoCondominioScreen extends StatefulWidget {
  final String condominioId;

  const GestaoCondominioScreen({super.key, required this.condominioId});

  @override
  State<GestaoCondominioScreen> createState() => _GestaoCondominioScreenState();
}

class _GestaoCondominioScreenState extends State<GestaoCondominioScreen> {
  Condominio? _condominio;
  Representante? _representante;
  bool _isLoading = true;
  final GestaoCondominioService _service = GestaoCondominioService();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    try {
      final condominio = await _service.obterCondominio(widget.condominioId);
      if (condominio != null) {
        _condominio = condominio;
        if (condominio.representanteId != null) {
          _representante = await _service.obterRepresentante(
            condominio.representanteId!,
          );
        }
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // List of items
  final List<Map<String, dynamic>> _itemDefs = [
    {'title': 'Dados', 'icon': Icons.assignment},
    {
      'title': 'Financeiro',
      'icon': Icons.monetization_on,
      'content': 'Conteúdo Financeiro',
    },
    {
      'title': 'Layout Boleto',
      'icon': Icons.receipt_long,
      'content': 'Conteúdo Layout Boleto',
    },
    {
      'title': 'Conta Bancária',
      'icon': Icons.account_balance,
      'content': 'Conteúdo Conta Bancária',
    },
    {
      'title': 'Textos',
      'icon': Icons.text_fields,
      'content': 'Conteúdo Textos',
    },
    {
      'title': 'Perfil de Usuário',
      'icon': Icons.person,
      'content': 'Conteúdo Perfil de Usuário',
    },
    {
      'title': 'Protestar/Baixa Boleto',
      'icon': Icons.archive,
      'content': 'Conteúdo Protestar/Baixa Boleto',
    },
    {
      'title': 'Upload',
      'icon': Icons.cloud_upload,
      'content': 'Conteúdo Upload',
    },
    {
      'title': 'Garantidora',
      'icon': Icons.security,
      'content': 'Conteúdo Garantidora',
    },
    {
      'title': 'Categoria/subcategoria',
      'icon': Icons.category,
      'content': 'Conteúdo Categoria/subcategoria',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: () {
              Scaffold.of(
                context,
              ).openDrawer(); // Functionality if drawer exists, or just visual
            },
          ),
        ),
        title: Column(
          children: [
            Image.asset('assets/images/logo_CondoGaia.png', height: 30),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/Sino_Notificacao.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Image.asset(
              'assets/images/Fone_Ouvido_Cabecalho.png',
              width: 24,
              height: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Text(
                        'Home/Gestão/Condomínio',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ), // Balance the back button spacing
                  ],
                ),
              ),
              Container(color: Colors.grey.shade300, height: 1.0),
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _itemDefs.length,
              separatorBuilder: (context, index) => Divider(
                color: const Color(0xFF0D3B66).withOpacity(0.3),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final item = _itemDefs[index];

                // Special case: Navigate to a separate screen
                if (item['title'] == 'Categoria/subcategoria') {
                  return ListTile(
                    leading: Icon(item['icon'], color: Colors.black, size: 28),
                    title: Text(
                      item['title'],
                      style: const TextStyle(
                        color: Color(0xFF0D3B66),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoriaSubcategoriaScreen(
                            condominioId: widget.condominioId,
                          ),
                        ),
                      );
                    },
                  );
                }

                return Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Icon(item['icon'], color: Colors.black, size: 28),
                    title: Text(
                      item['title'],
                      style: const TextStyle(
                        color: Color(0xFF0D3B66),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    iconColor: const Color(0xFF0D3B66),
                    collapsedIconColor: Colors.grey,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.centerLeft,
                        child: _buildItemContent(item),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildItemContent(Map<String, dynamic> item) {
    switch (item['title']) {
      case 'Dados':
        return DadosCondominioWidget(
          condominio: _condominio,
          representante: _representante,
        );
      case 'Financeiro':
        return FinanceiroCondominioWidget(condominio: _condominio);
      case 'Layout Boleto':
        return const LayoutBoletoWidget();
      case 'Conta Bancária':
        return ContaBancariaWidget(condominio: _condominio);
      case 'Textos':
        return TextosCondominioWidget(condominio: _condominio);
      case 'Perfil de Usuário':
        return PerfilUsuarioCondominioWidget(condominio: _condominio);
      case 'Protestar/Baixa Boleto':
        return ProtestoBaixaCondominioWidget(condominio: _condominio);
      case 'Garantidora':
        return GarantidoraCondominioWidget(condominio: _condominio);
      default:
        return Text(item['content'] ?? '');
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
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
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sair da conta',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
              _handleLogout();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Deseja realmente sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Erro ao sair: $e')));
                }
              },
              child: const Text('Sair', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
