import 'package:condogaiaapp/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CadastroRepresentanteScreen extends StatefulWidget {
  const CadastroRepresentanteScreen({super.key});

  @override
  State<CadastroRepresentanteScreen> createState() =>
      _CadastroRepresentanteScreenState();
}

class _CadastroRepresentanteScreenState
    extends State<CadastroRepresentanteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lista de todos os estados brasileiros
  static const List<String> _estadosBrasileiros = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
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
        final cidades = await SupabaseService.getCidadesFromRepresentantes(
          uf: uf,
        );

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
      final resultados =
          await SupabaseService.pesquisarRepresentantesComCondominios(
            uf: _ufSelecionadaPesquisa,
            cidade: _cidadeSelecionadaPesquisa,
            textoPesquisa: _pesquisaController.text.trim().isEmpty
                ? null
                : _pesquisaController.text.trim(),
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

  // Método para pesquisar/recarregar representantes
  void _pesquisarRepresentantes() {
    _realizarPesquisa();
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
        _telefoneError =
            'Telefone deve ter pelo menos 10 dígitos no formato (00) 00000-0000';
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
        _celularError =
            'Celular deve ter pelo menos 10 dígitos no formato (00) 00000-0000';
      } else {
        _celularError = null;
      }
    });
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = null;
      } else if (!value.contains('@') ||
          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                  const Icon(Icons.menu, size: 24, color: Colors.black),
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
                    style: TextStyle(fontSize: 16, color: Colors.black),
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
                children: [_buildCadastrarTab(), _buildPesquisarTab()],
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
                child: _buildDropdownField(
                  'UF:',
                  _ufSelecionada,
                  _estadosBrasileiros,
                  (value) {
                    setState(() {
                      _ufSelecionada = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  'Cidade:',
                  _cidadeController,
                  'Digite a cidade',
                ),
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
                  enabled:
                      _ufSelecionadaPesquisa != null &&
                      !_isLoadingUfsRepresentantes,
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
                      : const Icon(Icons.search, color: Colors.white, size: 24),
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
      return const Center(child: CircularProgressIndicator());
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
          style: TextStyle(color: Colors.red.shade700, fontSize: 14),
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
          style: TextStyle(color: Colors.grey, fontSize: 14),
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
                      _showEditMenu(context, resultado);
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
                      _showDeleteMenu(context, resultado);
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String placeholder,
  ) {
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
              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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

  Widget _buildTextFieldWithMask(
    String label,
    TextEditingController controller,
    String placeholder, {
    MaskTextInputFormatter? mask,
    Function(String)? onChanged,
    String? errorText,
    TextInputType? keyboardType,
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
              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
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
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
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
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
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
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            children: [
              if (_condominiosLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_condominiosError != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _condominiosError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                )
              else
                ..._condominios.map((condominio) {
                  final condominioId = condominio['id'].toString();
                  final isSelected = _condominiosSelecionados.contains(
                    condominioId,
                  );

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

  Widget _buildCheckboxSection(
    String number,
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
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

  Widget _buildCheckbox(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
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
              style: const TextStyle(fontSize: 14, color: Colors.black87),
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
                      child: _buildSubCheckbox(
                        '2.2',
                        'Reservas',
                        _reservasMarcado,
                        (value) {
                          setState(() {
                            _reservasMarcado = value!;
                          });
                          _checkParentSections();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSubCheckbox(
                        '2.2.1',
                        '(Configurações)',
                        _reservasConfigMarcado,
                        (value) {
                          setState(() {
                            _reservasConfigMarcado = value!;
                          });
                          _checkParentSections();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildSubCheckbox(
                        '2.3',
                        'Leitura',
                        _leituraMarcado,
                        (value) {
                          setState(() {
                            _leituraMarcado = value!;
                          });
                          _checkParentSections();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSubCheckbox(
                        '2.3.1',
                        '(Configurações)',
                        _leituraConfigMarcado,
                        (value) {
                          setState(() {
                            _leituraConfigMarcado = value!;
                          });
                          _checkParentSections();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSubCheckbox(
                  '2.4',
                  'Diário/agenda',
                  _diarioAgendaMarcado,
                  (value) {
                    setState(() {
                      _diarioAgendaMarcado = value!;
                    });
                    _checkParentSections();
                  },
                ),
                const SizedBox(height: 8),
                _buildSubCheckbox('2.5', 'Documentos', _documentosMarcado, (
                  value,
                ) {
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
                      child: _buildSubCheckbox(
                        '3.1',
                        'Condomínio',
                        _condominioGestaoMarcado,
                        (value) {
                          setState(() {
                            _condominioGestaoMarcado = value!;
                          });
                          _checkParentSections();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSubCheckbox(
                        '3.1.1',
                        '(Conf.)',
                        _condominioConfMarcado,
                        (value) {
                          setState(() {
                            _condominioConfMarcado = value!;
                          });
                          _checkParentSections();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSubCheckbox('3.2', 'Relatórios', _relatoriosMarcado, (
                  value,
                ) {
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
                          child: _buildSubCheckbox(
                            '3.4',
                            'Boleto',
                            _boletoMarcado,
                            (value) {
                              setState(() {
                                _boletoMarcado = value!;
                                // Atualizar todos os sub-checkboxes de boleto
                                _boletoGerarMarcado = value;
                                _boletoEnviarMarcado = value;
                                _boletoReceberMarcado = value;
                                _boletoExcluirMarcado = value;
                              });
                              _checkParentSections();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSubCheckbox(
                            '3.4.1',
                            '(Gerar Boletos)',
                            _boletoGerarMarcado,
                            (value) {
                              setState(() {
                                _boletoGerarMarcado = value!;
                                // Atualizar checkbox pai Boleto
                                _boletoMarcado =
                                    _boletoGerarMarcado &&
                                    _boletoEnviarMarcado &&
                                    _boletoReceberMarcado &&
                                    _boletoExcluirMarcado;
                              });
                              _checkParentSections();
                            },
                          ),
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
                                child: _buildSubCheckbox(
                                  '3.4.2',
                                  '(Enviar p/ Registro)',
                                  _boletoEnviarMarcado,
                                  (value) {
                                    setState(() {
                                      _boletoEnviarMarcado = value!;
                                      // Atualizar checkbox pai Boleto
                                      _boletoMarcado =
                                          _boletoGerarMarcado &&
                                          _boletoEnviarMarcado &&
                                          _boletoReceberMarcado &&
                                          _boletoExcluirMarcado;
                                    });
                                    _checkParentSections();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSubCheckbox(
                                  '3.4.3',
                                  '(Receber)',
                                  _boletoReceberMarcado,
                                  (value) {
                                    setState(() {
                                      _boletoReceberMarcado = value!;
                                      // Atualizar checkbox pai Boleto
                                      _boletoMarcado =
                                          _boletoGerarMarcado &&
                                          _boletoEnviarMarcado &&
                                          _boletoReceberMarcado &&
                                          _boletoExcluirMarcado;
                                    });
                                    _checkParentSections();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildSubCheckbox(
                                  '3.4.4',
                                  '(Excluir)',
                                  _boletoExcluirMarcado,
                                  (value) {
                                    setState(() {
                                      _boletoExcluirMarcado = value!;
                                      // Atualizar checkbox pai Boleto
                                      _boletoMarcado =
                                          _boletoGerarMarcado &&
                                          _boletoEnviarMarcado &&
                                          _boletoReceberMarcado &&
                                          _boletoExcluirMarcado;
                                    });
                                    _checkParentSections();
                                  },
                                ),
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
                          child: _buildSubCheckbox(
                            '3.5',
                            'Acordo',
                            _acordoMarcado,
                            (value) {
                              setState(() {
                                _acordoMarcado = value!;
                                // Atualizar todos os sub-checkboxes de acordo
                                _acordoGerarMarcado = value;
                                _acordoEnviarMarcado = value;
                              });
                              _checkParentSections();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSubCheckbox(
                            '3.5.1',
                            '(Gerar Boletos)',
                            _acordoGerarMarcado,
                            (value) {
                              setState(() {
                                _acordoGerarMarcado = value!;
                                // Atualizar checkbox pai Acordo
                                _acordoMarcado =
                                    _acordoGerarMarcado && _acordoEnviarMarcado;
                              });
                              _checkParentSections();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: _buildSubCheckbox(
                        '3.5.2',
                        '(Enviar p/ Registro)',
                        _acordoEnviarMarcado,
                        (value) {
                          setState(() {
                            _acordoEnviarMarcado = value!;
                            // Atualizar checkbox pai Acordo
                            _acordoMarcado =
                                _acordoGerarMarcado && _acordoEnviarMarcado;
                          });
                          _checkParentSections();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Morador/Unid
                Row(
                  children: [
                    Expanded(
                      child: _buildSubCheckbox(
                        '3.6',
                        'Morador/Unid',
                        _moradorUnidMarcado,
                        (value) {
                          setState(() {
                            _moradorUnidMarcado = value!;
                          });
                          _checkParentSections();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSubCheckbox(
                        '3.6.1',
                        '(Conf.)',
                        _moradorConfMarcado,
                        (value) {
                          setState(() {
                            _moradorConfMarcado = value!;
                          });
                          _checkParentSections();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSubCheckbox('3.7', 'E-mail', _emailGestaoMarcado, (
                  value,
                ) {
                  setState(() {
                    _emailGestaoMarcado = value!;
                  });
                  _checkParentSections();
                }),
                const SizedBox(height: 8),
                _buildSubCheckbox('3.8', 'Desp/Receita', _despReceitaMarcado, (
                  value,
                ) {
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

  Widget _buildSubCheckbox(
    String number,
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
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
              style: const TextStyle(fontSize: 14, color: Colors.black87),
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
      final representanteSalvo = await SupabaseService.saveRepresentante(
        representanteData,
      );

      // Associar condomínios ao representante
      if (representanteSalvo != null) {
        final representanteId = representanteSalvo['id'];
        List<String> condominiosParaAssociar = [];
        String mensagemAssociacao = '';

        if (_condominiosSelecionados.isNotEmpty) {
          // Usar condomínios selecionados manualmente
          condominiosParaAssociar = _condominiosSelecionados;
          mensagemAssociacao =
              'Representante cadastrado e associado aos condomínios selecionados!';
        } else {
          // Associar automaticamente ao primeiro condomínio disponível
          if (_condominios.isNotEmpty) {
            final primeiroCondominio = _condominios.first;
            condominiosParaAssociar = [primeiroCondominio['id']];
            mensagemAssociacao =
                'Representante cadastrado e associado automaticamente ao condomínio "${primeiroCondominio['nome_condominio']}"!';
          } else {
            mensagemAssociacao =
                'Representante cadastrado com sucesso! Nenhum condomínio disponível para associação automática.';
          }
        }

        // Realizar as associações
        for (final condominioId in condominiosParaAssociar) {
          try {
            await SupabaseService.associarRepresentanteCondominio(
              condominioId,
              representanteId,
            );
            print(
              'Condomínio $condominioId associado ao representante $representanteId',
            );
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

  // Método para mostrar menu de edição
  void _showEditMenu(BuildContext context, Map<String, dynamic> resultado) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Opções de Edição',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.business, color: Color(0xFF1E3A8A)),
                title: const Text(
                  'Editar Condomínio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEditCondominioModal(context, resultado);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF1E3A8A)),
                title: const Text(
                  'Editar Representante',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEditRepresentanteModal(context, resultado);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Método para mostrar modal de edição de condomínio
  void _showEditCondominioModal(
    BuildContext context,
    Map<String, dynamic> resultado,
  ) {
    // Buscar o ID do condomínio correto
    String? condominioId;

    // Primeiro, tenta buscar o ID do condomínio nos dados do resultado
    if (resultado['condominio_id'] != null) {
      condominioId = resultado['condominio_id'].toString();
    }

    // Se não encontrou, verifica se há um ID direto no resultado (caso seja um condomínio)
    if (condominioId == null &&
        resultado['id'] != null &&
        resultado['nome_condominio'] != null) {
      condominioId = resultado['id'].toString();
    }

    // Se ainda não encontrou o ID, mostra erro
    if (condominioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erro: ID do condomínio não encontrado. Não é possível editar.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Controllers para o modal de edição
    final cnpjController = TextEditingController(text: resultado['cnpj'] ?? '');
    final nomeController = TextEditingController(
      text: resultado['nome_condominio'] ?? '',
    );
    final cepController = TextEditingController(text: resultado['cep'] ?? '');
    final enderecoController = TextEditingController(
      text: resultado['endereco'] ?? '',
    );
    final numeroController = TextEditingController(
      text: resultado['numero']?.toString() ?? '',
    );
    final bairroController = TextEditingController(
      text: resultado['bairro'] ?? '',
    );
    final cidadeController = TextEditingController(
      text: resultado['condominio_cidade'] ?? '',
    );
    final planoController = TextEditingController(
      text: resultado['plano_assinatura'] ?? '',
    );
    final pagamentoController = TextEditingController(
      text: resultado['pagamento'] ?? '',
    );
    final vencimentoController = TextEditingController(
      text: resultado['vencimento'] ?? '',
    );
    final valorController = TextEditingController(
      text: resultado['valor']?.toString() ?? '',
    );
    final instituicaoCondController = TextEditingController(
      text: resultado['instituicao_financeiro_condominio'] ?? '',
    );
    final tokenCondController = TextEditingController(
      text: resultado['token_financeiro_condominio'] ?? '',
    );
    final instituicaoUnidController = TextEditingController(
      text: resultado['instituicao_financeiro_unidade'] ?? '',
    );
    final tokenUnidController = TextEditingController(
      text: resultado['token_financeiro_unidade'] ?? '',
    );

    String estadoSelecionado = resultado['condominio_estado'] ?? 'MS';

    // Máscaras de formatação
    final cnpjMask = MaskTextInputFormatter(
      mask: '##.###.###/####-##',
      filter: {"#": RegExp(r'[0-9]')},
    );

    final cepMask = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
    );

    final dateMask = MaskTextInputFormatter(
      mask: '##/##/####',
      filter: {"#": RegExp(r'[0-9]')},
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Cabeçalho
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Editar Condomínio',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(),
                    // Conteúdo scrollável
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Seção Dados
                            _buildModalSectionTitle('Dados'),
                            const SizedBox(height: 16),
                            _buildModalTextFieldWithMask(
                              'CNPJ:',
                              cnpjController,
                              '19.555.666/0001-69',
                              cnpjMask,
                            ),
                            const SizedBox(height: 12),
                            _buildModalTextField(
                              'Nome Condomínio:',
                              nomeController,
                              'Villas de Córdoba',
                            ),
                            const SizedBox(height: 12),
                            _buildModalTextFieldWithMask(
                              'CEP:',
                              cepController,
                              '11123-456',
                              cepMask,
                            ),
                            const SizedBox(height: 12),
                            _buildModalTextField(
                              'Endereço:',
                              enderecoController,
                              'Rua Almirante Carlos Guedert',
                            ),
                            const SizedBox(height: 12),
                            _buildModalTextField(
                              'Número:',
                              numeroController,
                              '',
                            ),
                            const SizedBox(height: 12),
                            _buildModalTextField(
                              'Bairro:',
                              bairroController,
                              '',
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModalTextField(
                                    'Cidade:',
                                    cidadeController,
                                    '',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModalDropdownField(
                                    'Estado:',
                                    estadoSelecionado,
                                    _estadosBrasileiros,
                                    (value) {
                                      setState(() {
                                        estadoSelecionado = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Seção Financeiro - Condomínio
                            _buildModalSectionTitle('Financeiro - Condomínio'),
                            const SizedBox(height: 16),
                            _buildModalTextField(
                              'Plano de assinatura:',
                              planoController,
                              'Mensal',
                            ),
                            const SizedBox(height: 12),
                            _buildModalTextField(
                              'Pagamento:',
                              pagamentoController,
                              'Boleto',
                            ),
                            const SizedBox(height: 12),
                            _buildModalTextFieldWithMask(
                              'Vencimento:',
                              vencimentoController,
                              '13/03/2024',
                              dateMask,
                            ),
                            const SizedBox(height: 12),
                            _buildModalMoneyField(
                              'Valor:',
                              valorController,
                              'R\$ 300,00',
                            ),
                            const SizedBox(height: 12),
                            _buildModalTextField(
                              'Instituição:',
                              instituicaoCondController,
                              'ASAAS',
                            ),
                            const SizedBox(height: 12),
                            _buildModalTextField(
                              'Token:',
                              tokenCondController,
                              'qjskf4qpbabqs2s1e61611f6v16as1as6',
                            ),
                            const SizedBox(height: 24),
                            // Seção Financeiro - Unidade
                            _buildModalSectionTitle('Financeiro - Unidade'),
                            const SizedBox(height: 16),
                            _buildModalTextField(
                              'Instituição:',
                              instituicaoUnidController,
                              'ASAAS',
                            ),
                            const SizedBox(height: 12),
                            _buildModalTextField(
                              'Token:',
                              tokenUnidController,
                              'qjskf4qpbabqs2s1e61611f6v16as1as6',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botões
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _salvarEdicaoCondominio(
                              context,
                              condominioId,
                              cnpjController,
                              nomeController,
                              cepController,
                              enderecoController,
                              numeroController,
                              bairroController,
                              cidadeController,
                              estadoSelecionado,
                              planoController,
                              pagamentoController,
                              vencimentoController,
                              valorController,
                              instituicaoCondController,
                              tokenCondController,
                              instituicaoUnidController,
                              tokenUnidController,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Salvar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widgets auxiliares para o modal
  Widget _buildModalSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E3A8A),
      ),
    );
  }

  Widget _buildModalTextField(
    String label,
    TextEditingController controller,
    String placeholder,
  ) {
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
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModalTextFieldWithMask(
    String label,
    TextEditingController controller,
    String placeholder,
    MaskTextInputFormatter mask,
  ) {
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
            inputFormatters: [mask],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: placeholder,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModalMoneyField(
    String label,
    TextEditingController controller,
    String placeholder,
  ) {
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
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: placeholder,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixText: 'R\$ ',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModalDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
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
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // Método para construir dropdown modal simples
  Widget _buildModalDropdown(
    String label,
    String? selectedValue,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // Método para salvar edição do condomínio
  void _salvarEdicaoCondominio(
    BuildContext context,
    dynamic condominioId,
    TextEditingController cnpjController,
    TextEditingController nomeController,
    TextEditingController cepController,
    TextEditingController enderecoController,
    TextEditingController numeroController,
    TextEditingController bairroController,
    TextEditingController cidadeController,
    String estadoSelecionado,
    TextEditingController planoController,
    TextEditingController pagamentoController,
    TextEditingController vencimentoController,
    TextEditingController valorController,
    TextEditingController instituicaoCondController,
    TextEditingController tokenCondController,
    TextEditingController instituicaoUnidController,
    TextEditingController tokenUnidController,
  ) async {
    try {
      // Preparar dados para atualização
      final condominioData = {
        'cnpj': cnpjController.text.trim(),
        'nome_condominio': nomeController.text.trim(),
        'cep': cepController.text.trim(),
        'endereco': enderecoController.text.trim(),
        'numero': int.tryParse(numeroController.text.trim()) ?? 0,
        'bairro': bairroController.text.trim(),
        'cidade': cidadeController.text.trim(),
        'estado': estadoSelecionado,
        'plano_assinatura': planoController.text.trim(),
        'pagamento': pagamentoController.text.trim(),
        'vencimento': vencimentoController.text.trim(),
        'valor':
            double.tryParse(valorController.text.trim().replaceAll(',', '.')) ??
            0.0,
        'instituicao_financeiro_condominio': instituicaoCondController.text
            .trim(),
        'token_financeiro_condominio': tokenCondController.text.trim(),
        'instituicao_financeiro_unidade': instituicaoUnidController.text.trim(),
        'token_financeiro_unidade': tokenUnidController.text.trim(),
      };

      // Atualizar no Supabase - converte o ID para string
      await SupabaseService.updateCondominio(
        condominioId.toString(),
        condominioData,
      );

      // Fechar modal
      Navigator.pop(context);

      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Condomínio atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Recarregar pesquisa
      _realizarPesquisa();
    } catch (e) {
      // Mostrar mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar condomínio: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Modal para editar representante
  void _showEditRepresentanteModal(BuildContext context, Map<String, dynamic> resultado) {
    // Verificar se o resultado contém dados válidos
    if (resultado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados do representante não encontrados'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Controllers para o modal de edição
    final nomeCompletoController = TextEditingController(
      text: resultado['nome_completo'] ?? '',
    );
    final cpfController = TextEditingController(text: resultado['cpf'] ?? '');
    final telefoneController = TextEditingController(text: resultado['telefone'] ?? '');
    final celularController = TextEditingController(text: resultado['celular'] ?? '');
    final emailController = TextEditingController(text: resultado['email'] ?? '');
    final enderecoController = TextEditingController(text: resultado['endereco'] ?? '');
    final cidadeController = TextEditingController(text: resultado['cidade'] ?? '');
    final senhaAcessoController = TextEditingController(text: resultado['senha_acesso'] ?? '');
    final fotoPerfilController = TextEditingController(text: resultado['foto_perfil'] ?? '');

    String ufSelecionada = resultado['uf'] ?? 'MS';
    
    // Lista de condomínios selecionados
    List<String> condominiosSelecionados = [];
    if (resultado['condominios_selecionados'] != null) {
      if (resultado['condominios_selecionados'] is List) {
        condominiosSelecionados = List<String>.from(resultado['condominios_selecionados']);
      } else if (resultado['condominios_selecionados'] is String) {
        // Se for string, pode ser um array PostgreSQL como '{id1,id2}'
        String str = resultado['condominios_selecionados'];
        if (str.startsWith('{') && str.endsWith('}')) {
          str = str.substring(1, str.length - 1);
          condominiosSelecionados = str.split(',').where((s) => s.isNotEmpty).toList();
        }
      }
    }

    // Estados dos checkboxes de permissões
    bool todosMarcado = resultado['todos_marcado'] ?? false;
    bool modulosSectionMarcado = resultado['modulos_section_marcado'] ?? false;
    bool gestaoSectionMarcado = resultado['gestao_section_marcado'] ?? false;
    bool chatMarcado = resultado['chat_marcado'] ?? false;
    bool reservasMarcado = resultado['reservas_marcado'] ?? false;
    bool reservasConfigMarcado = resultado['reservas_config_marcado'] ?? false;
    bool leituraMarcado = resultado['leitura_marcado'] ?? false;
    bool leituraConfigMarcado = resultado['leitura_config_marcado'] ?? false;
    bool diarioAgendaMarcado = resultado['diario_agenda_marcado'] ?? false;
    bool documentosMarcado = resultado['documentos_marcado'] ?? false;
    bool condominioGestaoMarcado = resultado['condominio_gestao_marcado'] ?? false;
    bool condominioConfMarcado = resultado['condominio_conf_marcado'] ?? false;
    bool relatoriosMarcado = resultado['relatorios_marcado'] ?? false;
    bool portariaMarcado = resultado['portaria_marcado'] ?? false;
    bool boletoMarcado = resultado['boleto_marcado'] ?? false;
    bool boletoGerarMarcado = resultado['boleto_gerar_marcado'] ?? false;
    bool boletoEnviarMarcado = resultado['boleto_enviar_marcado'] ?? false;
    bool boletoReceberMarcado = resultado['boleto_receber_marcado'] ?? false;
    bool boletoExcluirMarcado = resultado['boleto_excluir_marcado'] ?? false;
    bool acordoMarcado = resultado['acordo_marcado'] ?? false;
    bool acordoGerarMarcado = resultado['acordo_gerar_marcado'] ?? false;
    bool acordoEnviarMarcado = resultado['acordo_enviar_marcado'] ?? false;
    bool moradorUnidMarcado = resultado['morador_unid_marcado'] ?? false;
    bool moradorConfMarcado = resultado['morador_conf_marcado'] ?? false;
    bool emailGestaoMarcado = resultado['email_gestao_marcado'] ?? false;
    bool despReceitaMarcado = resultado['desp_receita_marcado'] ?? false;

    // Máscaras de formatação
    final cpfMask = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {'#': RegExp(r'[0-9]')},
    );
    final telefoneMask = MaskTextInputFormatter(
      mask: '(##) ####-####',
      filter: {'#': RegExp(r'[0-9]')},
    );
    final celularMask = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {'#': RegExp(r'[0-9]')},
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Editar Representante',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dados básicos
                      const Text(
                        'Dados Básicos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildModalTextField('Nome Completo:', nomeCompletoController, 'Digite o nome completo'),
                      const SizedBox(height: 10),
                      _buildModalTextFieldWithMask('CPF:', cpfController, '000.000.000-00', cpfMask),
                      const SizedBox(height: 10),
                      _buildModalTextFieldWithMask('Telefone:', telefoneController, '(00) 0000-0000', telefoneMask),
                      const SizedBox(height: 10),
                      _buildModalTextFieldWithMask('Celular:', celularController, '(00) 00000-0000', celularMask),
                      const SizedBox(height: 10),
                      _buildModalTextField('E-mail:', emailController, 'Digite o e-mail'),
                      const SizedBox(height: 10),
                      _buildModalTextField('Endereço:', enderecoController, 'Digite o endereço'),
                      const SizedBox(height: 10),
                      
                      // UF e Cidade
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: _buildModalDropdown(
                              'UF:',
                              ufSelecionada,
                              ['AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'],
                              (String? value) {
                                setState(() {
                                  ufSelecionada = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: _buildModalTextField('Cidade:', cidadeController, 'Digite a cidade'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Condomínios
                      const Text(
                        'Condomínios Associados',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCondominiosSelector(condominiosSelecionados, setState, representanteId: resultado['id']?.toString()),
                      const SizedBox(height: 20),

                      // Dados de acesso
                      const Text(
                        'Dados de Acesso',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildModalTextField('Senha de Acesso:', senhaAcessoController, 'Digite a senha'),
                      const SizedBox(height: 10),
                      _buildModalTextField('Foto de Perfil (URL):', fotoPerfilController, 'Digite a URL da foto'),
                      const SizedBox(height: 20),

                      // Permissões
                      const Text(
                        'Permissões',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPermissionsSection(
                        todosMarcado: todosMarcado,
                        modulosSectionMarcado: modulosSectionMarcado,
                        gestaoSectionMarcado: gestaoSectionMarcado,
                        chatMarcado: chatMarcado,
                        reservasMarcado: reservasMarcado,
                        reservasConfigMarcado: reservasConfigMarcado,
                        leituraMarcado: leituraMarcado,
                        leituraConfigMarcado: leituraConfigMarcado,
                        diarioAgendaMarcado: diarioAgendaMarcado,
                        documentosMarcado: documentosMarcado,
                        condominioGestaoMarcado: condominioGestaoMarcado,
                        condominioConfMarcado: condominioConfMarcado,
                        relatoriosMarcado: relatoriosMarcado,
                        portariaMarcado: portariaMarcado,
                        boletoMarcado: boletoMarcado,
                        boletoGerarMarcado: boletoGerarMarcado,
                        boletoEnviarMarcado: boletoEnviarMarcado,
                        boletoReceberMarcado: boletoReceberMarcado,
                        boletoExcluirMarcado: boletoExcluirMarcado,
                        acordoMarcado: acordoMarcado,
                        acordoGerarMarcado: acordoGerarMarcado,
                        acordoEnviarMarcado: acordoEnviarMarcado,
                        moradorUnidMarcado: moradorUnidMarcado,
                        moradorConfMarcado: moradorConfMarcado,
                        emailGestaoMarcado: emailGestaoMarcado,
                        despReceitaMarcado: despReceitaMarcado,
                        onChanged: (field, value) {
                          setState(() {
                            switch (field) {
                              case 'todos_marcado':
                                todosMarcado = value;
                                break;
                              case 'modulos_section_marcado':
                                modulosSectionMarcado = value;
                                break;
                              case 'gestao_section_marcado':
                                gestaoSectionMarcado = value;
                                break;
                              case 'chat_marcado':
                                chatMarcado = value;
                                break;
                              case 'reservas_marcado':
                                reservasMarcado = value;
                                break;
                              case 'reservas_config_marcado':
                                reservasConfigMarcado = value;
                                break;
                              case 'leitura_marcado':
                                leituraMarcado = value;
                                break;
                              case 'leitura_config_marcado':
                                leituraConfigMarcado = value;
                                break;
                              case 'diario_agenda_marcado':
                                diarioAgendaMarcado = value;
                                break;
                              case 'documentos_marcado':
                                documentosMarcado = value;
                                break;
                              case 'condominio_gestao_marcado':
                                condominioGestaoMarcado = value;
                                break;
                              case 'condominio_conf_marcado':
                                condominioConfMarcado = value;
                                break;
                              case 'relatorios_marcado':
                                relatoriosMarcado = value;
                                break;
                              case 'portaria_marcado':
                                portariaMarcado = value;
                                break;
                              case 'boleto_marcado':
                                boletoMarcado = value;
                                break;
                              case 'boleto_gerar_marcado':
                                boletoGerarMarcado = value;
                                break;
                              case 'boleto_enviar_marcado':
                                boletoEnviarMarcado = value;
                                break;
                              case 'boleto_receber_marcado':
                                boletoReceberMarcado = value;
                                break;
                              case 'boleto_excluir_marcado':
                                boletoExcluirMarcado = value;
                                break;
                              case 'acordo_marcado':
                                acordoMarcado = value;
                                break;
                              case 'acordo_gerar_marcado':
                                acordoGerarMarcado = value;
                                break;
                              case 'acordo_enviar_marcado':
                                acordoEnviarMarcado = value;
                                break;
                              case 'morador_unid_marcado':
                                moradorUnidMarcado = value;
                                break;
                              case 'morador_conf_marcado':
                                moradorConfMarcado = value;
                                break;
                              case 'email_gestao_marcado':
                                emailGestaoMarcado = value;
                                break;
                              case 'desp_receita_marcado':
                                despReceitaMarcado = value;
                                break;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _salvarEdicaoRepresentante(
                      context,
                      resultado['id'],
                      nomeCompletoController,
                      cpfController,
                      telefoneController,
                      celularController,
                      emailController,
                      enderecoController,
                      ufSelecionada,
                      cidadeController,
                      condominiosSelecionados,
                      senhaAcessoController,
                      fotoPerfilController,
                      todosMarcado,
                      modulosSectionMarcado,
                      gestaoSectionMarcado,
                      chatMarcado,
                      reservasMarcado,
                      reservasConfigMarcado,
                      leituraMarcado,
                      leituraConfigMarcado,
                      diarioAgendaMarcado,
                      documentosMarcado,
                      condominioGestaoMarcado,
                      condominioConfMarcado,
                      relatoriosMarcado,
                      portariaMarcado,
                      boletoMarcado,
                      boletoGerarMarcado,
                      boletoEnviarMarcado,
                      boletoReceberMarcado,
                      boletoExcluirMarcado,
                      acordoMarcado,
                      acordoGerarMarcado,
                      acordoEnviarMarcado,
                      moradorUnidMarcado,
                      moradorConfMarcado,
                      emailGestaoMarcado,
                      despReceitaMarcado,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Widget para seleção de condomínios
  Widget _buildCondominiosSelector(List<String> condominiosSelecionados, StateSetter setState, {String? representanteId}) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: representanteId != null 
          ? SupabaseService.getCondominiosDisponiveisParaRepresentante(representanteId)
          : SupabaseService.getCondominiosDisponiveis(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Text('Erro ao carregar condomínios: ${snapshot.error}');
        }
        
        final condominios = snapshot.data ?? [];
        
        return Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: condominios.length,
            itemBuilder: (context, index) {
              final condominio = condominios[index];
              final condominioId = condominio['id'].toString();
              final isSelected = condominiosSelecionados.contains(condominioId);
              final hasRepresentante = condominio['representante_id'] != null;
              final isCurrentRepresentante = representanteId != null && 
                  condominio['representante_id'] == representanteId;
              
              // Determinar o subtítulo baseado no status do condomínio
              String subtitle = '${condominio['cidade'] ?? 'Cidade não informada'}/${condominio['estado'] ?? 'UF'}';
              if (hasRepresentante && !isCurrentRepresentante) {
                subtitle += ' (Já possui representante)';
              } else if (isCurrentRepresentante) {
                subtitle += ' (Já associado)';
              } else {
                subtitle += ' (Disponível)';
              }
              
              return CheckboxListTile(
                title: Text(condominio['nome_condominio'] ?? 'Nome não informado'),
                subtitle: Text(subtitle),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      condominiosSelecionados.add(condominioId);
                    } else {
                      condominiosSelecionados.remove(condominioId);
                    }
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  /// Widget para seção de permissões
  Widget _buildPermissionsSection({
    required bool todosMarcado,
    required bool modulosSectionMarcado,
    required bool gestaoSectionMarcado,
    required bool chatMarcado,
    required bool reservasMarcado,
    required bool reservasConfigMarcado,
    required bool leituraMarcado,
    required bool leituraConfigMarcado,
    required bool diarioAgendaMarcado,
    required bool documentosMarcado,
    required bool condominioGestaoMarcado,
    required bool condominioConfMarcado,
    required bool relatoriosMarcado,
    required bool portariaMarcado,
    required bool boletoMarcado,
    required bool boletoGerarMarcado,
    required bool boletoEnviarMarcado,
    required bool boletoReceberMarcado,
    required bool boletoExcluirMarcado,
    required bool acordoMarcado,
    required bool acordoGerarMarcado,
    required bool acordoEnviarMarcado,
    required bool moradorUnidMarcado,
    required bool moradorConfMarcado,
    required bool emailGestaoMarcado,
    required bool despReceitaMarcado,
    required Function(String, bool) onChanged,
  }) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            CheckboxListTile(
              title: const Text('Todos'),
              value: todosMarcado,
              onChanged: (value) => onChanged('todos_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Módulos Section'),
              value: modulosSectionMarcado,
              onChanged: (value) => onChanged('modulos_section_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Gestão Section'),
              value: gestaoSectionMarcado,
              onChanged: (value) => onChanged('gestao_section_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Chat'),
              value: chatMarcado,
              onChanged: (value) => onChanged('chat_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Reservas'),
              value: reservasMarcado,
              onChanged: (value) => onChanged('reservas_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Reservas Config'),
              value: reservasConfigMarcado,
              onChanged: (value) => onChanged('reservas_config_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Leitura'),
              value: leituraMarcado,
              onChanged: (value) => onChanged('leitura_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Leitura Config'),
              value: leituraConfigMarcado,
              onChanged: (value) => onChanged('leitura_config_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Diário Agenda'),
              value: diarioAgendaMarcado,
              onChanged: (value) => onChanged('diario_agenda_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Documentos'),
              value: documentosMarcado,
              onChanged: (value) => onChanged('documentos_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Condomínio Gestão'),
              value: condominioGestaoMarcado,
              onChanged: (value) => onChanged('condominio_gestao_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Condomínio Config'),
              value: condominioConfMarcado,
              onChanged: (value) => onChanged('condominio_conf_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Relatórios'),
              value: relatoriosMarcado,
              onChanged: (value) => onChanged('relatorios_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Portaria'),
              value: portariaMarcado,
              onChanged: (value) => onChanged('portaria_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Boleto'),
              value: boletoMarcado,
              onChanged: (value) => onChanged('boleto_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Boleto Gerar'),
              value: boletoGerarMarcado,
              onChanged: (value) => onChanged('boleto_gerar_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Boleto Enviar'),
              value: boletoEnviarMarcado,
              onChanged: (value) => onChanged('boleto_enviar_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Boleto Receber'),
              value: boletoReceberMarcado,
              onChanged: (value) => onChanged('boleto_receber_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Boleto Excluir'),
              value: boletoExcluirMarcado,
              onChanged: (value) => onChanged('boleto_excluir_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Acordo'),
              value: acordoMarcado,
              onChanged: (value) => onChanged('acordo_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Acordo Gerar'),
              value: acordoGerarMarcado,
              onChanged: (value) => onChanged('acordo_gerar_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Acordo Enviar'),
              value: acordoEnviarMarcado,
              onChanged: (value) => onChanged('acordo_enviar_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Morador Unidade'),
              value: moradorUnidMarcado,
              onChanged: (value) => onChanged('morador_unid_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Morador Config'),
              value: moradorConfMarcado,
              onChanged: (value) => onChanged('morador_conf_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Email Gestão'),
              value: emailGestaoMarcado,
              onChanged: (value) => onChanged('email_gestao_marcado', value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Despesa/Receita'),
              value: despReceitaMarcado,
              onChanged: (value) => onChanged('desp_receita_marcado', value ?? false),
            ),
          ],
        ),
      ),
    );
  }

  /// Função para salvar a edição do representante
  Future<void> _salvarEdicaoRepresentante(
    BuildContext context,
    String representanteId,
    TextEditingController nomeCompletoController,
    TextEditingController cpfController,
    TextEditingController telefoneController,
    TextEditingController celularController,
    TextEditingController emailController,
    TextEditingController enderecoController,
    String ufSelecionada,
    TextEditingController cidadeController,
    List<String> condominiosSelecionados,
    TextEditingController senhaAcessoController,
    TextEditingController fotoPerfilController,
    bool todosMarcado,
    bool modulosSectionMarcado,
    bool gestaoSectionMarcado,
    bool chatMarcado,
    bool reservasMarcado,
    bool reservasConfigMarcado,
    bool leituraMarcado,
    bool leituraConfigMarcado,
    bool diarioAgendaMarcado,
    bool documentosMarcado,
    bool condominioGestaoMarcado,
    bool condominioConfMarcado,
    bool relatoriosMarcado,
    bool portariaMarcado,
    bool boletoMarcado,
    bool boletoGerarMarcado,
    bool boletoEnviarMarcado,
    bool boletoReceberMarcado,
    bool boletoExcluirMarcado,
    bool acordoMarcado,
    bool acordoGerarMarcado,
    bool acordoEnviarMarcado,
    bool moradorUnidMarcado,
    bool moradorConfMarcado,
    bool emailGestaoMarcado,
    bool despReceitaMarcado,
  ) async {
    try {
      // Validações básicas
      if (nomeCompletoController.text.trim().isEmpty) {
        _showErrorMessage('Nome completo é obrigatório');
        return;
      }
      
      if (cpfController.text.trim().isEmpty) {
        _showErrorMessage('CPF é obrigatório');
        return;
      }
      
      if (emailController.text.trim().isEmpty) {
        _showErrorMessage('E-mail é obrigatório');
        return;
      }

      // Preparar dados para atualização
      final representanteData = {
        'nome_completo': nomeCompletoController.text.trim(),
        'cpf': cpfController.text.trim(),
        'telefone': telefoneController.text.trim().isEmpty ? null : telefoneController.text.trim(),
        'celular': celularController.text.trim().isEmpty ? null : celularController.text.trim(),
        'email': emailController.text.trim(),
        'endereco': enderecoController.text.trim().isEmpty ? null : enderecoController.text.trim(),
        'uf': ufSelecionada,
        'cidade': cidadeController.text.trim().isEmpty ? null : cidadeController.text.trim(),
        'condominios_selecionados': condominiosSelecionados,
        'senha_acesso': senhaAcessoController.text.trim().isEmpty ? null : senhaAcessoController.text.trim(),
        'foto_perfil': fotoPerfilController.text.trim().isEmpty ? null : fotoPerfilController.text.trim(),
        'todos_marcado': todosMarcado,
        'modulos_section_marcado': modulosSectionMarcado,
        'gestao_section_marcado': gestaoSectionMarcado,
        'chat_marcado': chatMarcado,
        'reservas_marcado': reservasMarcado,
        'reservas_config_marcado': reservasConfigMarcado,
        'leitura_marcado': leituraMarcado,
        'leitura_config_marcado': leituraConfigMarcado,
        'diario_agenda_marcado': diarioAgendaMarcado,
        'documentos_marcado': documentosMarcado,
        'condominio_gestao_marcado': condominioGestaoMarcado,
        'condominio_conf_marcado': condominioConfMarcado,
        'relatorios_marcado': relatoriosMarcado,
        'portaria_marcado': portariaMarcado,
        'boleto_marcado': boletoMarcado,
        'boleto_gerar_marcado': boletoGerarMarcado,
        'boleto_enviar_marcado': boletoEnviarMarcado,
        'boleto_receber_marcado': boletoReceberMarcado,
        'boleto_excluir_marcado': boletoExcluirMarcado,
        'acordo_marcado': acordoMarcado,
        'acordo_gerar_marcado': acordoGerarMarcado,
        'acordo_enviar_marcado': acordoEnviarMarcado,
        'morador_unid_marcado': moradorUnidMarcado,
        'morador_conf_marcado': moradorConfMarcado,
        'email_gestao_marcado': emailGestaoMarcado,
        'desp_receita_marcado': despReceitaMarcado,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Atualizar representante no banco
      await SupabaseService.updateRepresentante(representanteId, representanteData);

      // Fechar modal
      Navigator.pop(context);

      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Representante atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Recarregar dados
      _pesquisarRepresentantes();

    } catch (e) {
      print('Erro ao atualizar representante: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar representante: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Modal para escolher o tipo de exclusão
  void _showDeleteMenu(BuildContext context, Map<String, dynamic> resultado) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Opções de Exclusão',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Escolha o que deseja excluir:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.business, color: Colors.red),
                title: const Text(
                  'Excluir Condomínio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Remove o condomínio e atualiza representantes',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarExclusaoCondominio(context, resultado);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.red),
                title: const Text(
                  'Excluir Representante',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Remove o representante e libera condomínios',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarExclusaoRepresentante(context, resultado);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// Confirma a exclusão do condomínio
  void _confirmarExclusaoCondominio(BuildContext context, Map<String, dynamic> resultado) {
    final nomeCondominio = resultado['nome_condominio'] ?? 'Condomínio';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmar Exclusão',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tem certeza que deseja excluir o condomínio "$nomeCondominio"?'),
              const SizedBox(height: 10),
              const Text(
                'Esta ação irá:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• Remover o condomínio permanentemente'),
              const Text('• Atualizar todos os representantes relacionados'),
              const Text('• Esta ação não pode ser desfeita'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _excluirCondominio(context, resultado);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  /// Confirma a exclusão do representante
  void _confirmarExclusaoRepresentante(BuildContext context, Map<String, dynamic> resultado) {
    final nomeRepresentante = resultado['nome_completo'] ?? 'Representante';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirmar Exclusão',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tem certeza que deseja excluir o representante "$nomeRepresentante"?'),
              const SizedBox(height: 10),
              const Text(
                'Esta ação irá:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• Remover o representante permanentemente'),
              const Text('• Liberar todos os condomínios associados'),
              const Text('• Esta ação não pode ser desfeita'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _excluirRepresentante(context, resultado);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  /// Executa a exclusão do condomínio
  Future<void> _excluirCondominio(BuildContext context, Map<String, dynamic> resultado) async {
    try {
      final condominioId = resultado['condominio_id']?.toString();
      if (condominioId == null) {
        throw Exception('ID do condomínio não encontrado');
      }

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await SupabaseService.deleteCondominioComAtualizacaoRepresentantes(condominioId);

      // Fechar loading
      Navigator.pop(context);

      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Condomínio excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Recarregar dados
      _pesquisarRepresentantes();

    } catch (e) {
      // Fechar loading se estiver aberto
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      print('Erro ao excluir condomínio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir condomínio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Executa a exclusão do representante
  Future<void> _excluirRepresentante(BuildContext context, Map<String, dynamic> resultado) async {
    try {
      final representanteId = resultado['id']?.toString();
      if (representanteId == null) {
        throw Exception('ID do representante não encontrado');
      }

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await SupabaseService.deleteRepresentanteComLiberacaoCondominios(representanteId);

      // Fechar loading
      Navigator.pop(context);

      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Representante excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Recarregar dados
      _pesquisarRepresentantes();

    } catch (e) {
      // Fechar loading se estiver aberto
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      print('Erro ao excluir representante: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir representante: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}