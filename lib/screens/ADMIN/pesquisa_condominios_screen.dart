import 'package:condogaiaapp/services/supabase_service.dart';
import 'package:flutter/material.dart';
import '../login_screen.dart';

class PesquisaCondominiosScreen extends StatefulWidget {
  const PesquisaCondominiosScreen({super.key});

  @override
  State<PesquisaCondominiosScreen> createState() => _PesquisaCondominiosScreenState();
}

class _PesquisaCondominiosScreenState extends State<PesquisaCondominiosScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _ufSelecionada;
  String? _cidadeSelecionada;
  String? _statusSelecionado;
  
  // Listas dinâmicas carregadas do banco de dados
  List<String> _ufs = [];
  List<String> _cidades = [];
  bool _isLoadingUfs = true;
  bool _isLoadingCidades = false;
  
  // Dados reais dos condomínios e representantes
  List<Map<String, dynamic>> _condominiosComRepresentantes = [];
  bool _isLoadingPesquisa = false;
  double _totalValor = 0.0;

  @override
  void initState() {
    super.initState();
    _carregarUfs();
    _realizarPesquisa(); // Carrega todos os condomínios inicialmente
  }

  /// Carrega as UFs únicas dos representantes
  Future<void> _carregarUfs() async {
    try {
      setState(() {
        _isLoadingUfs = true;
      });
      
      final ufs = await SupabaseService.getUfsFromCondominios();
      
      setState(() {
        _ufs = ufs;
        _isLoadingUfs = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUfs = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar UFs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Carrega as cidades únicas dos representantes filtradas por UF
  Future<void> _carregarCidades(String? uf) async {
    try {
      setState(() {
        _isLoadingCidades = true;
        _cidades = [];
        _cidadeSelecionada = null;
      });
      
      if (uf != null && uf.isNotEmpty) {
        final cidades = await SupabaseService.getCidadesFromCondominios(uf: uf);
        
        setState(() {
          _cidades = cidades;
          _isLoadingCidades = false;
        });
      } else {
        setState(() {
          _isLoadingCidades = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCidades = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar cidades: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Alterna o status ativo/inativo de um condomínio
  Future<void> _alternarStatusCondominio(Map<String, dynamic> condominio) async {
    try {
      final condominioId = condominio['id'].toString();
      final statusAtual = condominio['ativo'] ?? true;
      final novoStatus = !statusAtual;
      
      // Atualiza no banco de dados
      await SupabaseService.updateCondominio(condominioId, {'ativo': novoStatus});
      
      // Recarrega a pesquisa para atualizar a interface
      await _realizarPesquisa();
      
      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            novoStatus 
                ? 'Condomínio ativado com sucesso!' 
                : 'Condomínio desativado com sucesso!'
          ),
          backgroundColor: novoStatus ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar status do condomínio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Exclui um condomínio após confirmação do usuário
  Future<void> _excluirCondominio(Map<String, dynamic> condominio) async {
    final bool? confirmacao = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmar Exclusão',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tem certeza que deseja excluir este condomínio?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Condomínio: ${condominio['nome_condominio'] ?? 'Nome não informado'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'CNPJ: ${condominio['cnpj'] ?? 'Não informado'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '⚠️ Esta ação não pode ser desfeita!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmacao == true) {
      try {
        final condominioId = condominio['id'].toString();
        
        // Exclui do banco de dados
        await SupabaseService.deleteCondominio(condominioId);
        
        // Recarrega a pesquisa para atualizar a interface
        await _realizarPesquisa();
        
        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Condomínio excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir condomínio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Realiza a pesquisa de condomínios com dados reais
  Future<void> _realizarPesquisa() async {
    try {
      setState(() {
        _isLoadingPesquisa = true;
        _condominiosComRepresentantes = [];
        _totalValor = 0.0;
      });
      
      // Converte status selecionado para boolean
      bool? ativo;
      if (_statusSelecionado == 'Ativos') {
        ativo = true;
      } else if (_statusSelecionado == 'Desativados') {
        ativo = false;
      }
      
      // Busca condomínios com os filtros (permite pesquisa sem filtros)
      final condominios = await SupabaseService.pesquisarCondominios(
        uf: (_ufSelecionada?.isEmpty == true || _ufSelecionada == 'Selecione') ? null : _ufSelecionada,
        cidade: (_cidadeSelecionada?.isEmpty == true || _cidadeSelecionada == 'Selecione') ? null : _cidadeSelecionada,
        ativo: ativo,
      );
      
      // Calcula o total pela coluna valor (apenas condomínios ativos)
      double total = 0.0;
      for (final condominio in condominios) {
        final valor = condominio['valor'];
        final isAtivo = condominio['ativo'] ?? true;
        if (valor != null && isAtivo) {
          total += (valor is int) ? valor.toDouble() : (valor as double? ?? 0.0);
        }
      }
      
      // Para cada condomínio, busca os representantes associados e agrupa
      List<Map<String, dynamic>> condominiosComReps = [];
      
      for (final condominio in condominios) {
        final representantes = await SupabaseService.getRepresentantesByCondominio(
          condominio['id'].toString()
        );
        
        // Cria uma única entrada por condomínio com todos os representantes
        final condominioCompleto = Map<String, dynamic>.from(condominio);
        condominioCompleto['representantes'] = representantes;
        condominiosComReps.add(condominioCompleto);
      }
      
      setState(() {
        _condominiosComRepresentantes = condominiosComReps;
        _totalValor = total;
        _isLoadingPesquisa = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesquisa realizada! Encontrados ${condominios.length} condomínios.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoadingPesquisa = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao realizar pesquisa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildBreadcrumb(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFilters(),
                    const SizedBox(height: 20),
                    _buildStatusRadio(),
                    const SizedBox(height: 20),
                    _buildSearchButton(),
                    const SizedBox(height: 20),
                    _buildTotal(),
                    const SizedBox(height: 20),
                    _buildCondominiosList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Menu hamburger
          GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: const Icon(
              Icons.menu,
              size: 24,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 16),
          // Logo
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/logo_CondoGaia.png',
                height: 40,
              ),
            ),
          ),
          // Ícones do lado direito
          Image.asset(
            'assets/images/Sino_Notificacao.png',
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/Fone_Ouvido_Cabecalho.png',
            height: 24,
            width: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              size: 24,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Home/Pesquisar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UF:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonFormField<String>(
                  value: _ufSelecionada,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    suffixIcon: _isLoadingUfs 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  hint: const Text('Selecione'),
                  isExpanded: true,
                  items: _isLoadingUfs 
                      ? []
                      : _ufs.map((uf) {
                          return DropdownMenuItem(
                            value: uf,
                            child: Text(uf),
                          );
                        }).toList(),
                  onChanged: _isLoadingUfs 
                      ? null
                      : (value) {
                          setState(() {
                            _ufSelecionada = value;
                          });
                          // Carrega cidades da UF selecionada
                          _carregarCidades(value);
                        },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cidade:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonFormField<String>(
                  value: _cidadeSelecionada,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    suffixIcon: _isLoadingCidades 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  hint: Text(_ufSelecionada == null 
                      ? 'Selecione uma UF primeiro' 
                      : _isLoadingCidades 
                          ? 'Carregando...' 
                          : 'Selecione'),
                  isExpanded: true,
                  items: (_isLoadingCidades || _ufSelecionada == null) 
                      ? []
                      : _cidades.map((cidade) {
                          return DropdownMenuItem(
                            value: cidade,
                            child: Text(cidade),
                          );
                        }).toList(),
                  onChanged: (_isLoadingCidades || _ufSelecionada == null) 
                      ? null
                      : (value) {
                          setState(() {
                            _cidadeSelecionada = value;
                          });
                        },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRadio() {
    return Row(
      children: [
        Radio<String>(
          value: 'Ativos',
          groupValue: _statusSelecionado,
          onChanged: (value) {
            setState(() {
              _statusSelecionado = value!;
            });
          },
        ),
        const Text('Ativos'),
        const SizedBox(width: 20),
        Radio<String>(
          value: 'Desativados',
          groupValue: _statusSelecionado,
          onChanged: (value) {
            setState(() {
              _statusSelecionado = value!;
            });
          },
        ),
        const Text('Desativados'),
      ],
    );
  }

  Widget _buildSearchButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: _isLoadingPesquisa ? null : _realizarPesquisa,
        icon: _isLoadingPesquisa 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.search, color: Colors.white),
        label: Text(
          _isLoadingPesquisa ? 'Pesquisando...' : 'Pesquisar',
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTotal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Center(
        child: Text(
          'TOTAL: R\$ ${_totalValor.toStringAsFixed(2).replaceAll('.', ',')}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildCondominiosList() {
    if (_isLoadingPesquisa) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_condominiosComRepresentantes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Nenhum condomínio encontrado. Realize uma pesquisa.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _condominiosComRepresentantes.length,
      itemBuilder: (context, index) {
        return _buildCondominioCard(_condominiosComRepresentantes[index]);
      },
    );
  }

  Widget _buildCondominioCard(Map<String, dynamic> condominio) {
    final valor = condominio['valor'];
    final valorFormatado = valor != null 
        ? (valor is int ? valor.toDouble() : (valor as double? ?? 0.0))
            .toStringAsFixed(2).replaceAll('.', ',')
        : '0,00';
    
    // Verifica se o condomínio está ativo
    final bool isAtivo = condominio['ativo'] ?? true;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: isAtivo ? null : Colors.red[50], // Cor vermelha mais bonita para inativos
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          condominio['nome_condominio'] ?? 'Nome não informado',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'CNPJ: ${condominio['cnpj'] ?? 'Não informado'}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Card azul da mensalidade (valor do condomínio)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[300]!, width: 1),
                  ),
                  child: Text(
                    'Mensalidade R\$ $valorFormatado',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                // Cards dos representantes
                if (condominio['representantes'] != null && (condominio['representantes'] as List).isNotEmpty)
                  ...((condominio['representantes'] as List).map<Widget>((representante) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[300]!, width: 1),
                      ),
                      child: Text(
                        'Representante: ${representante['nome_completo'] ?? 'Nome não informado'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList())
                else
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: const Text(
                      'Nenhum representante cadastrado',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),
                // Botão de ativar/desativar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _alternarStatusCondominio(condominio),
                    icon: Icon(
                      isAtivo ? Icons.block : Icons.check_circle,
                      color: Colors.white,
                    ),
                    label: Text(
                      isAtivo ? 'Desativar Condomínio' : 'Ativar Condomínio',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAtivo ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Botão de excluir condomínio
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _excluirCondominio(condominio),
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Excluir Condomínio',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header do drawer
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_CondoGaia.png',
                  height: 40,
                ),
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
              Navigator.pop(context);
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
              Navigator.pop(context);
              _handleDeleteAccount();
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
                  await SupabaseService.client.auth.signOut();
                  
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao sair: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  /// Trata exclusão de conta do admin
  Future<void> _handleDeleteAccount() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Conta'),
          content: const Text(
            'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  // Implementar lógica de exclusão de conta aqui
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao excluir conta: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}