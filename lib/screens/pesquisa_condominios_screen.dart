import 'package:condogaiaapp/services/supabase_service.dart';
import 'package:flutter/material.dart';

class PesquisaCondominiosScreen extends StatefulWidget {
  const PesquisaCondominiosScreen({super.key});

  @override
  State<PesquisaCondominiosScreen> createState() => _PesquisaCondominiosScreenState();
}

class _PesquisaCondominiosScreenState extends State<PesquisaCondominiosScreen> {
  String? _ufSelecionada;
  String? _cidadeSelecionada;
  String? _statusSelecionado;
  
  // Listas dinâmicas carregadas do banco de dados
  List<String> _ufs = [];
  List<String> _cidades = [];
  bool _isLoadingUfs = true;
  bool _isLoadingCidades = false;
  
  // Dados reais dos condomínios e representantes
  List<Map<String, dynamic>> _condominios = [];
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

  /// Realiza a pesquisa de condomínios com dados reais
  Future<void> _realizarPesquisa() async {
    try {
      setState(() {
        _isLoadingPesquisa = true;
        _condominios = [];
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
        _condominios = condominios;
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
      backgroundColor: Colors.white,
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
          const Icon(
            Icons.menu,
            size: 24,
            color: Colors.black,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}