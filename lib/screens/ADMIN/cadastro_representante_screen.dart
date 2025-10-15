import 'package:condogaiaapp/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CadastroRepresentanteScreen extends StatefulWidget {
  const CadastroRepresentanteScreen({super.key});

  @override
  State<CadastroRepresentanteScreen> createState() => _CadastroRepresentanteScreenState();
}

class _CadastroRepresentanteScreenState extends State<CadastroRepresentanteScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Lista de todos os estados brasileiros
  static const List<String> _estadosBrasileiros = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
    'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
    'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];
  
  // Controllers para os campos de texto
  final _nomeCompletoController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _celularController = TextEditingController();
  final _emailController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _pesquisaController = TextEditingController();
  final _cidadeController = TextEditingController();
  
  // Máscaras de formatação
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _celularMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  
  // Mensagens de erro
  String? _cpfError;
  String? _telefoneError;
  String? _celularError;
  String? _emailError;
  
  // Valores dos dropdowns
  String _condominioSelecionado = 'Cond. Ecoville';
  String _ufSelecionada = 'MS';
  String _cidadeSelecionada = 'Selvíria';
  
  // Variáveis para dropdowns dinâmicos da aba de pesquisa
  List<String> _ufsRepresentantes = [];
  List<String> _cidadesRepresentantes = [];
  bool _isLoadingUfsRepresentantes = true;
  bool _isLoadingCidadesRepresentantes = false;
  String? _ufSelecionadaPesquisa;
  String? _cidadeSelecionadaPesquisa;
  
  // Variáveis para resultados da pesquisa
  List<Map<String, dynamic>> _resultadosPesquisa = [];
  bool _isLoadingPesquisa = false;
  bool _pesquisaRealizada = false;
  String? _errorPesquisa;
  
  // Condomínios
  List<Map<String, dynamic>> _condominios = [];
  List<String> _condominiosSelecionados = [];
  bool _condominiosLoading = false;
  String? _condominiosError;
  
  // Estados dos checkboxes
  bool _todosMarcado = false;
  
  // Seções principais
  bool _modulosSectionMarcado = false;
  bool _gestaoSectionMarcado = false;
  
  // Módulos
  bool _chatMarcado = false;
  bool _reservasMarcado = false;
  bool _reservasConfigMarcado = false;
  bool _leituraMarcado = false;
  bool _leituraConfigMarcado = false;
  bool _diarioAgendaMarcado = false;
  bool _documentosMarcado = false;
  
  // Gestão
  bool _condominioGestaoMarcado = false;
  bool _condominioConfMarcado = false;
  bool _relatoriosMarcado = false;
  bool _portariaMarcado = false;
  bool _boletoMarcado = false;
  bool _boletoGerarMarcado = false;
  bool _boletoEnviarMarcado = false;
  bool _boletoReceberMarcado = false;
  bool _boletoExcluirMarcado = false;
  bool _acordoMarcado = false;
  bool _acordoGerarMarcado = false;
  bool _acordoEnviarMarcado = false;
  bool _moradorUnidMarcado = false;
  bool _moradorConfMarcado = false;
  bool _emailGestaoMarcado = false;
  bool _despReceitaMarcado = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCondominios();
    _carregarUfsRepresentantes();
    _realizarPesquisa(); // Carrega todos os representantes inicialmente
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeCompletoController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _celularController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _pesquisaController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  Future<void> _loadCondominios() async {
    setState(() {
      _condominiosLoading = true;
      _condominiosError = null;
    });

    try {
      // Carrega apenas condomínios que ainda não possuem representante
      final condominios = await SupabaseService.getCondominiosDisponiveis();
      setState(() {
        _condominios = condominios;
        _condominiosLoading = false;
      });
    } catch (e) {
      setState(() {
        _condominiosError = 'Erro ao carregar condomínios disponíveis: $e';
        _condominiosLoading = false;
      });
    }
  }

  /// Carrega as UFs únicas dos representantes para a aba de pesquisa
  Future<void> _carregarUfsRepresentantes() async {
    try {
      setState(() {
        _isLoadingUfsRepresentantes = true;
      });
      
      final ufs = await SupabaseService.getUfsFromRepresentantes();
      
      setState(() {
        _ufsRepresentantes = ufs;
        _isLoadingUfsRepresentantes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUfsRepresentantes = false;
      });
      print('Erro ao carregar UFs dos representantes: $e');
    }
  }

  /// Carrega as cidades únicas dos representantes filtradas por UF para a aba de pesquisa
  Future<void> _carregarCidadesRepresentantes(String? uf) async {
    try {
      setState(() {
        _isLoadingCidadesRepresentantes = true;
        _cidadesRepresentantes = [];
        _cidadeSelecionadaPesquisa = null;
      });
      
      if (uf != null && uf.isNotEmpty) {
        final cidades = await SupabaseService.getCidadesFromRepresentantes(uf: uf);
        
        setState(() {
          _cidadesRepresentantes = cidades;
          _isLoadingCidadesRepresentantes = false;
        });
      } else {
        setState(() {
          _isLoadingCidadesRepresentantes = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCidadesRepresentantes = false;
      });
      print('Erro ao carregar cidades dos representantes: $e');
    }
  }

  /// Realiza a pesquisa de representantes com os filtros aplicados
  Future<void> _realizarPesquisa() async {
    setState(() {
      _isLoadingPesquisa = true;
      _errorPesquisa = null;
    });

    try {
      final resultados = await SupabaseService.pesquisarRepresentantesComCondominios(
        uf: _ufSelecionadaPesquisa,
        cidade: _cidadeSelecionadaPesquisa,
        textoPesquisa: _pesquisaController.text.trim().isEmpty ? null : _pesquisaController.text.trim(),
      );

      setState(() {
        _resultadosPesquisa = resultados;
        _pesquisaRealizada = true;
        _isLoadingPesquisa = false;
      });
    } catch (e) {
      setState(() {
        _errorPesquisa = 'Erro ao realizar pesquisa: $e';
        _resultadosPesquisa = [];
        _pesquisaRealizada = true;
        _isLoadingPesquisa = false;
      });
      print('Erro na pesquisa de representantes: $e');
    }
  }
  
  // Funções de validação
  void _validateCPF(String value) {
    setState(() {
      if (value.isEmpty) {
        _cpfError = null;
      } else if (value.replaceAll(RegExp(r'[^0-9]'), '').length != 11) {
        _cpfError = 'CPF deve ter 11 dígitos no formato 000.000.000-00';
      } else {
        _cpfError = null;
      }
    });
  }
  
  void _validateTelefone(String value) {
    setState(() {
      if (value.isEmpty) {
        _telefoneError = null;
      } else if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
        _telefoneError = 'Telefone deve ter pelo menos 10 dígitos no formato (00) 00000-0000';
      } else {
        _telefoneError = null;
      }
    });
  }
  
  void _validateCelular(String value) {
    setState(() {
      if (value.isEmpty) {
        _celularError = null;
      } else if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
        _celularError = 'Celular deve ter pelo menos 10 dígitos no formato (00) 00000-0000';
      } else {
        _celularError = null;
      }
    });
  }
  
  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = null;
      } else if (!value.contains('@') || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _emailError = 'Insira um email válido com @';
      } else {
        _emailError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho
            Container(
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
            ),
            // Navegação breadcrumb
            Container(
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
                    'Cadastrar Representante',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Abas
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1E3A8A),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF1E3A8A),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                tabs: const [
                  Tab(text: 'Cadastrar'),
                  Tab(text: 'Pesquisar'),
                ],
              ),
            ),
            // Conteúdo das abas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCadastrarTab(),
                  _buildPesquisarTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCadastrarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dropdown Condomínio
          _buildCondominiosDropdown(),
          const SizedBox(height: 16),
          
          // Campos de texto
          _buildTextField('Nome Completo:', _nomeCompletoController, ''),
          const SizedBox(height: 12),
          _buildTextFieldWithMask(
            'CPF:', 
            _cpfController, 
            '000.000.000-00',
            mask: _cpfMask,
            keyboardType: TextInputType.number,
            onChanged: _validateCPF,
            errorText: _cpfError,
          ),
          const SizedBox(height: 12),
          _buildTextFieldWithMask(
            'Telefone:', 
            _telefoneController, 
            '(00) 00000-0000',
            mask: _telefoneMask,
            keyboardType: TextInputType.phone,
            onChanged: _validateTelefone,
            errorText: _telefoneError,
          ),
          const SizedBox(height: 12),
          _buildTextFieldWithMask(
            'Celular:', 
            _celularController, 
            '(00) 00000-0000',
            mask: _celularMask,
            keyboardType: TextInputType.phone,
            onChanged: _validateCelular,
            errorText: _celularError,
          ),
          const SizedBox(height: 12),
          _buildTextFieldWithMask(
            'E-mail:', 
            _emailController, 
            'exemplo@email.com',
            keyboardType: TextInputType.emailAddress,
            onChanged: _validateEmail,
            errorText: _emailError,
          ),
          const SizedBox(height: 12),
          
          // UF e Cidade
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildDropdownField('UF:', _ufSelecionada, _estadosBrasileiros, (value) {
                  setState(() {
                    _ufSelecionada = value!;
                  });
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildTextField('Cidade:', _cidadeController, 'Digite a cidade'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField('Endereço:', _enderecoController, 'Rua da Figueira'),
          const SizedBox(height: 24),
          
          // Seção Todos
          _buildCheckboxSection('1', 'Todos', _todosMarcado, (value) {
            _updateTodosCheckbox(value!);
          }),
          const SizedBox(height: 16),
          
          // Seção Módulos
          _buildModulosSection(),
          const SizedBox(height: 16),
          
          // Seção Gestão
          _buildGestaoSection(),
          const SizedBox(height: 32),
          
          // Botão Salvar
          Center(
            child: GestureDetector(
              onTap: () {
                _salvarRepresentante();
              },
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text(
                    'Salvar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPesquisarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtros UF e Cidade
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildDropdownFieldDinamico(
                  'UF:', 
                  _ufSelecionadaPesquisa, 
                  _ufsRepresentantes, 
                  _isLoadingUfsRepresentantes,
                  (value) {
                    setState(() {
                      _ufSelecionadaPesquisa = value;
                      _cidadeSelecionadaPesquisa = null;
                    });
                    _carregarCidadesRepresentantes(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildDropdownFieldDinamico(
                  'Cidade:', 
                  _cidadeSelecionadaPesquisa, 
                  _cidadesRepresentantes, 
                  _isLoadingCidadesRepresentantes,
                  (value) {
                    setState(() {
                      _cidadeSelecionadaPesquisa = value;
                    });
                  },
                  enabled: _ufSelecionadaPesquisa != null && !_isLoadingUfsRepresentantes,
                  hintText: _ufSelecionadaPesquisa == null 
                      ? 'Selecione uma UF primeiro' 
                      : _isLoadingCidadesRepresentantes 
                          ? 'Carregando cidades...' 
                          : 'Selecione uma cidade',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Campo de pesquisa
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _pesquisaController,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar condomínio ou representante',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _realizarPesquisa,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _isLoadingPesquisa
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Resultado da pesquisa
          _buildResultadosPesquisa(),
        ],
      ),
    );
  }

  Widget _buildResultadosPesquisa() {
    if (_isLoadingPesquisa) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorPesquisa != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(
          _errorPesquisa!,
          style: TextStyle(
            color: Colors.red.shade700,
            fontSize: 14,
          ),
        ),
      );
    }

    if (!_pesquisaRealizada) {
      return const SizedBox.shrink();
    }

    if (_resultadosPesquisa.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text(
          'Nenhum representante encontrado com os filtros aplicados.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: _resultadosPesquisa.map((resultado) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF87CEEB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resultado['nome_condominio'] ?? 'Nome não informado',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${resultado['condominio_cidade'] ?? 'Cidade não informada'}/${resultado['condominio_estado'] ?? 'UF'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      resultado['nome_completo'] ?? 'Nome não informado',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CNPJ: ${resultado['cnpj'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'CPF: ${resultado['cpf'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: Implementar edição
                    },
                    child: const Icon(
                      Icons.edit,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // TODO: Implementar exclusão
                    },
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTextFieldWithMask(String label, TextEditingController controller, String placeholder, 
      {MaskTextInputFormatter? mask, Function(String)? onChanged, String? errorText, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey.shade300,
              width: errorText != null ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: controller,
            inputFormatters: mask != null ? [mask] : null,
            keyboardType: keyboardType ?? TextInputType.text,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// Widget para dropdown dinâmico com indicador de carregamento para a aba de pesquisa
  Widget _buildDropdownFieldDinamico(
    String label, 
    String? value, 
    List<String> items, 
    bool isLoading,
    ValueChanged<String?> onChanged, {
    bool enabled = true,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
            hint: Text(
              hintText ?? 'Selecione uma opção',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: enabled && !isLoading ? onChanged : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCondominiosDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Condomínio',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ExpansionTile(
            title: Text(
              _getCondominiosDisplayText(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            children: [
              if (_condominiosLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_condominiosError != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _condominiosError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                ..._condominios.map((condominio) {
                  final condominioId = condominio['id'].toString();
                  final isSelected = _condominiosSelecionados.contains(condominioId);
                  
                  return CheckboxListTile(
                    title: Text(
                      '${condominio['nome_condominio']} - ${condominio['cidade']}/${condominio['estado']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _condominiosSelecionados.add(condominioId);
                        } else {
                          _condominiosSelecionados.remove(condominioId);
                        }
                      });
                    },
                    activeColor: const Color(0xFF1E3A8A),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  String _getCondominiosDisplayText() {
    if (_condominiosLoading) {
      return 'Carregando...';
    }
    if (_condominiosError != null) {
      return 'Erro ao carregar';
    }
    if (_condominiosSelecionados.isEmpty) {
      return 'Selecionar Condomínios (opcional)';
    }
    return '${_condominiosSelecionados.length} condomínio(s) selecionado(s)';
  }

  Widget _buildCheckboxSection(String number, String title, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1E3A8A),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1E3A8A),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulosSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade200, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Checkbox(
                value: _modulosSectionMarcado,
                onChanged: (value) {
                  _updateModulosSectionOnly(value!);
                },
                activeColor: const Color(0xFF1E3A8A),
              ),
              const Text(
                'Módulos:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Column(
              children: [
                _buildSubCheckbox('2.1', 'Chat', _chatMarcado, (value) {
                  setState(() {
                    _chatMarcado = value!;
                  });
                  _checkParentSections();
                }),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildSubCheckbox('2.2', 'Reservas', _reservasMarcado, (value) {
                        setState(() {
                          _reservasMarcado = value!;
                        });
                        _checkParentSections();
                      }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSubCheckbox('2.2.1', '(Configurações)', _reservasConfigMarcado, (value) {
                        setState(() {
                          _reservasConfigMarcado = value!;
                        });
                        _checkParentSections();
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildSubCheckbox('2.3', 'Leitura', _leituraMarcado, (value) {
                        setState(() {
                          _leituraMarcado = value!;
                        });
                        _checkParentSections();
                      }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSubCheckbox('2.3.1', '(Configurações)', _leituraConfigMarcado, (value) {
                        setState(() {
                          _leituraConfigMarcado = value!;
                        });
                        _checkParentSections();
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSubCheckbox('2.4', 'Diário/agenda', _diarioAgendaMarcado, (value) {
                  setState(() {
                    _diarioAgendaMarcado = value!;
                  });
                  _checkParentSections();
                }),
                const SizedBox(height: 8),
                _buildSubCheckbox('2.5', 'Documentos', _documentosMarcado, (value) {
                  setState(() {
                    _documentosMarcado = value!;
                  });
                  _checkParentSections();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestaoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade200, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Checkbox(
                value: _gestaoSectionMarcado,
                onChanged: (value) {
                  _updateGestaoSectionOnly(value!);
                },
                activeColor: const Color(0xFF1E3A8A),
              ),
              const Text(
                'Gestão:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSubCheckbox('3.1', 'Condomínio', _condominioGestaoMarcado, (value) {
                        setState(() {
                          _condominioGestaoMarcado = value!;
                        });
                        _checkParentSections();
                      }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSubCheckbox('3.1.1', '(Conf.)', _condominioConfMarcado, (value) {
                        setState(() {
                          _condominioConfMarcado = value!;
                        });
                        _checkParentSections();
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSubCheckbox('3.2', 'Relatórios', _relatoriosMarcado, (value) {
                  setState(() {
                    _relatoriosMarcado = value!;
                  });
                  _checkParentSections();
                }),
                const SizedBox(height: 8),
                _buildSubCheckbox('3.3', 'Portaria', _portariaMarcado, (value) {
                  setState(() {
                    _portariaMarcado = value!;
                  });
                  _checkParentSections();
                }),
                const SizedBox(height: 8),
                // Boleto com sub-opções
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSubCheckbox('3.4', 'Boleto', _boletoMarcado, (value) {
                            setState(() {
                              _boletoMarcado = value!;
                              // Atualizar todos os sub-checkboxes de boleto
                              _boletoGerarMarcado = value;
                              _boletoEnviarMarcado = value;
                              _boletoReceberMarcado = value;
                              _boletoExcluirMarcado = value;
                            });
                            _checkParentSections();
                          }),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSubCheckbox('3.4.1', '(Gerar Boletos)', _boletoGerarMarcado, (value) {
                                  setState(() {
                                    _boletoGerarMarcado = value!;
                                    // Atualizar checkbox pai Boleto
                                    _boletoMarcado = _boletoGerarMarcado && _boletoEnviarMarcado && _boletoReceberMarcado && _boletoExcluirMarcado;
                                  });
                                  _checkParentSections();
                                }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildSubCheckbox('3.4.2', '(Enviar p/ Registro)', _boletoEnviarMarcado, (value) {
                                  setState(() {
                                    _boletoEnviarMarcado = value!;
                                    // Atualizar checkbox pai Boleto
                                    _boletoMarcado = _boletoGerarMarcado && _boletoEnviarMarcado && _boletoReceberMarcado && _boletoExcluirMarcado;
                                  });
                                  _checkParentSections();
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSubCheckbox('3.4.3', '(Receber)', _boletoReceberMarcado, (value) {
                                  setState(() {
                                    _boletoReceberMarcado = value!;
                                    // Atualizar checkbox pai Boleto
                                    _boletoMarcado = _boletoGerarMarcado && _boletoEnviarMarcado && _boletoReceberMarcado && _boletoExcluirMarcado;
                                  });
                                  _checkParentSections();
                                }),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildSubCheckbox('3.4.4', '(Excluir)', _boletoExcluirMarcado, (value) {
                                  setState(() {
                                    _boletoExcluirMarcado = value!;
                                    // Atualizar checkbox pai Boleto
                                    _boletoMarcado = _boletoGerarMarcado && _boletoEnviarMarcado && _boletoReceberMarcado && _boletoExcluirMarcado;
                                  });
                                  _checkParentSections();
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Acordo com sub-opções
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSubCheckbox('3.5', 'Acordo', _acordoMarcado, (value) {
                            setState(() {
                              _acordoMarcado = value!;
                              // Atualizar todos os sub-checkboxes de acordo
                              _acordoGerarMarcado = value;
                              _acordoEnviarMarcado = value;
                            });
                            _checkParentSections();
                          }),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSubCheckbox('3.5.1', '(Gerar Boletos)', _acordoGerarMarcado, (value) {
                            setState(() {
                              _acordoGerarMarcado = value!;
                              // Atualizar checkbox pai Acordo
                              _acordoMarcado = _acordoGerarMarcado && _acordoEnviarMarcado;
                            });
                            _checkParentSections();
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: _buildSubCheckbox('3.5.2', '(Enviar p/ Registro)', _acordoEnviarMarcado, (value) {
                        setState(() {
                          _acordoEnviarMarcado = value!;
                          // Atualizar checkbox pai Acordo
                          _acordoMarcado = _acordoGerarMarcado && _acordoEnviarMarcado;
                        });
                        _checkParentSections();
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Morador/Unid
                Row(
                  children: [
                    Expanded(
                      child: _buildSubCheckbox('3.6', 'Morador/Unid', _moradorUnidMarcado, (value) {
                  setState(() {
                    _moradorUnidMarcado = value!;
                  });
                  _checkParentSections();
                }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSubCheckbox('3.6.1', '(Conf.)', _moradorConfMarcado, (value) {
                        setState(() {
                          _moradorConfMarcado = value!;
                        });
                        _checkParentSections();
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSubCheckbox('3.7', 'E-mail', _emailGestaoMarcado, (value) {
                  setState(() {
                    _emailGestaoMarcado = value!;
                  });
                  _checkParentSections();
                }),
                const SizedBox(height: 8),
                _buildSubCheckbox('3.8', 'Desp/Receita', _despReceitaMarcado, (value) {
                  setState(() {
                    _despReceitaMarcado = value!;
                  });
                  _checkParentSections();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCheckbox(String number, String title, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200, width: 1),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1E3A8A),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares para gerenciar hierarquia dos checkboxes
  void _updateTodosCheckbox(bool value) {
    setState(() {
      _todosMarcado = value;
      // Atualizar todas as seções
      _updateModulosSection(value);
      _updateGestaoSection(value);
    });
  }

  void _updateModulosSection(bool value) {
    setState(() {
      // Seção 2 - Módulos
      _modulosSectionMarcado = value;
      _chatMarcado = value;
      _reservasMarcado = value;
      _reservasConfigMarcado = value;
      _leituraMarcado = value;
      _leituraConfigMarcado = value;
      _diarioAgendaMarcado = value;
      _documentosMarcado = value;
    });
  }

  void _updateModulosSectionOnly(bool value) {
    setState(() {
      _modulosSectionMarcado = value;
      if (value) {
        _updateModulosSection(true);
      } else {
        _updateModulosSection(false);
      }
      _checkParentSections();
    });
  }

  void _updateGestaoSection(bool value) {
    setState(() {
      // Seção 3 - Gestão
      _gestaoSectionMarcado = value;
      _condominioGestaoMarcado = value;
      _condominioConfMarcado = value;
      _relatoriosMarcado = value;
      _portariaMarcado = value;
      _boletoMarcado = value;
      _boletoGerarMarcado = value;
      _boletoEnviarMarcado = value;
      _boletoReceberMarcado = value;
      _boletoExcluirMarcado = value;
      _acordoMarcado = value;
      _acordoGerarMarcado = value;
      _acordoEnviarMarcado = value;
      _moradorUnidMarcado = value;
      _moradorConfMarcado = value;
      _emailGestaoMarcado = value;
      _despReceitaMarcado = value;
    });
  }

  void _updateGestaoSectionOnly(bool value) {
    setState(() {
      _gestaoSectionMarcado = value;
      if (value) {
        _updateGestaoSection(true);
      } else {
        _updateGestaoSection(false);
      }
      _checkParentSections();
    });
  }

  bool _areAllModulosChecked() {
    return _chatMarcado &&
           _reservasMarcado &&
           _reservasConfigMarcado &&
           _leituraMarcado &&
           _leituraConfigMarcado &&
           _diarioAgendaMarcado &&
           _documentosMarcado;
  }

  bool _areAllGestaoChecked() {
    return _condominioGestaoMarcado &&
           _condominioConfMarcado &&
           _relatoriosMarcado &&
           _portariaMarcado &&
           _boletoMarcado &&
           _boletoGerarMarcado &&
           _boletoEnviarMarcado &&
           _boletoReceberMarcado &&
           _boletoExcluirMarcado &&
           _acordoMarcado &&
           _acordoGerarMarcado &&
           _acordoEnviarMarcado &&
           _moradorUnidMarcado &&
           _moradorConfMarcado &&
           _emailGestaoMarcado &&
           _despReceitaMarcado;
  }

  void _checkParentSections() {
    // Verificar se todos os checkboxes de uma seção estão marcados
    bool allModulosChecked = _areAllModulosChecked();
    bool allGestaoChecked = _areAllGestaoChecked();
    
    setState(() {
      _modulosSectionMarcado = allModulosChecked;
      _gestaoSectionMarcado = allGestaoChecked;
      
      // Verificar se todas as seções estão marcadas para marcar o "Todos"
      _todosMarcado = allModulosChecked && allGestaoChecked;
    });
  }

  void _salvarRepresentante() async {
    // Validação dos campos obrigatórios
    if (_nomeCompletoController.text.trim().isEmpty) {
      _showErrorMessage('Nome completo é obrigatório');
      return;
    }
    
    if (_cpfController.text.trim().isEmpty) {
      _showErrorMessage('CPF é obrigatório');
      return;
    }
    
    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('Email é obrigatório');
      return;
    }
    
    if (!_emailController.text.contains('@')) {
      _showErrorMessage('Email deve conter @');
      return;
    }
    
    // Validação removida - condomínios podem ser associados posteriormente
    
    try {
      // Preparar lista de condomínios para salvar no campo condominios_selecionados
      List<String> condominiosParaSalvar = [];
      if (_condominiosSelecionados.isNotEmpty) {
        // Usar condomínios selecionados manualmente
        condominiosParaSalvar = List<String>.from(_condominiosSelecionados);
      } else if (_condominios.isNotEmpty) {
        // Usar primeiro condomínio disponível se nenhum foi selecionado
        condominiosParaSalvar = [_condominios.first['id']];
      }
      
      // Preparar dados do representante
      final representanteData = {
        'nome_completo': _nomeCompletoController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'celular': _celularController.text.trim(),
        'email': _emailController.text.trim(),
        'endereco': _enderecoController.text.trim(),
        'uf': _ufSelecionada,
        'cidade': _cidadeController.text.trim(),
        // Adicionar campo condominios_selecionados com os IDs dos condomínios
        'condominios_selecionados': condominiosParaSalvar,
        
        // Checkboxes de seções principais
        'todos_marcado': _todosMarcado,
        'modulos_section_marcado': _modulosSectionMarcado,
        'gestao_section_marcado': _gestaoSectionMarcado,
        
        // Checkboxes de módulos
        'chat_marcado': _chatMarcado,
        'reservas_marcado': _reservasMarcado,
        'reservas_config_marcado': _reservasConfigMarcado,
        'leitura_marcado': _leituraMarcado,
        'leitura_config_marcado': _leituraConfigMarcado,
        'diario_agenda_marcado': _diarioAgendaMarcado,
        'documentos_marcado': _documentosMarcado,
        
        // Checkboxes de gestão
        'condominio_gestao_marcado': _condominioGestaoMarcado,
        'condominio_conf_marcado': _condominioConfMarcado,
        'relatorios_marcado': _relatoriosMarcado,
        'portaria_marcado': _portariaMarcado,
        'boleto_marcado': _boletoMarcado,
        'boleto_gerar_marcado': _boletoGerarMarcado,
        'boleto_enviar_marcado': _boletoEnviarMarcado,
        'boleto_receber_marcado': _boletoReceberMarcado,
        'boleto_excluir_marcado': _boletoExcluirMarcado,
        'acordo_marcado': _acordoMarcado,
        'acordo_gerar_marcado': _acordoGerarMarcado,
        'acordo_enviar_marcado': _acordoEnviarMarcado,
        'morador_unid_marcado': _moradorUnidMarcado,
        'morador_conf_marcado': _moradorConfMarcado,
        'email_gestao_marcado': _emailGestaoMarcado,
        'desp_receita_marcado': _despReceitaMarcado,
      };
      
      // Salvar representante no Supabase
      final representanteSalvo = await SupabaseService.saveRepresentante(representanteData);
      
      // Associar condomínios ao representante
      if (representanteSalvo != null) {
        final representanteId = representanteSalvo['id'];
        List<String> condominiosParaAssociar = [];
        String mensagemAssociacao = '';
        
        if (_condominiosSelecionados.isNotEmpty) {
          // Usar condomínios selecionados manualmente
          condominiosParaAssociar = _condominiosSelecionados;
          mensagemAssociacao = 'Representante cadastrado e associado aos condomínios selecionados!';
        } else {
          // Associar automaticamente ao primeiro condomínio disponível
          if (_condominios.isNotEmpty) {
            final primeiroCondominio = _condominios.first;
            condominiosParaAssociar = [primeiroCondominio['id']];
            mensagemAssociacao = 'Representante cadastrado e associado automaticamente ao condomínio "${primeiroCondominio['nome_condominio']}"!';
          } else {
            mensagemAssociacao = 'Representante cadastrado com sucesso! Nenhum condomínio disponível para associação automática.';
          }
        }
        
        // Realizar as associações
        for (final condominioId in condominiosParaAssociar) {
          try {
            await SupabaseService.associarRepresentanteCondominio(condominioId, representanteId);
            print('Condomínio $condominioId associado ao representante $representanteId');
          } catch (e) {
            print('Erro ao associar condomínio $condominioId: $e');
          }
        }
        
        // Mostrar mensagem de sucesso personalizada
        _showSuccessMessage(mensagemAssociacao);
      }
      
      // Recarregar lista de condomínios disponíveis
      await _loadCondominios();
      
      // Limpar formulário
      _limparFormulario();
      
    } catch (e) {
      _showErrorMessage('Erro ao salvar representante: ${e.toString()}');
    }
  }
  
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _limparFormulario() {
    setState(() {
      // Limpar controllers
      _nomeCompletoController.clear();
      _cpfController.clear();
      _telefoneController.clear();
      _celularController.clear();
      _emailController.clear();
      _enderecoController.clear();
      _cidadeController.clear();
      
      // Resetar dropdowns
      _ufSelecionada = 'MS';
      _condominiosSelecionados.clear();
      
      // Resetar todos os checkboxes
      _todosMarcado = false;
      _modulosSectionMarcado = false;
      _gestaoSectionMarcado = false;
      _chatMarcado = false;
      _reservasMarcado = false;
      _reservasConfigMarcado = false;
      _leituraMarcado = false;
      _leituraConfigMarcado = false;
      _diarioAgendaMarcado = false;
      _documentosMarcado = false;
      _condominioGestaoMarcado = false;
      _condominioConfMarcado = false;
      _relatoriosMarcado = false;
      _portariaMarcado = false;
      _boletoMarcado = false;
      _boletoGerarMarcado = false;
      _boletoEnviarMarcado = false;
      _boletoReceberMarcado = false;
      _boletoExcluirMarcado = false;
      _acordoMarcado = false;
      _acordoGerarMarcado = false;
      _acordoEnviarMarcado = false;
      _moradorUnidMarcado = false;
      _moradorConfMarcado = false;
      _emailGestaoMarcado = false;
      _despReceitaMarcado = false;
    });
  }
}