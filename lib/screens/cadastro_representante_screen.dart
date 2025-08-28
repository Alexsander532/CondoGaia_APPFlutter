import 'package:flutter/material.dart';

class CadastroRepresentanteScreen extends StatefulWidget {
  const CadastroRepresentanteScreen({super.key});

  @override
  State<CadastroRepresentanteScreen> createState() => _CadastroRepresentanteScreenState();
}

class _CadastroRepresentanteScreenState extends State<CadastroRepresentanteScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Controllers para os campos de texto
  final _nomeCompletoController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _celularController = TextEditingController();
  final _emailController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _pesquisaController = TextEditingController();
  
  // Valores dos dropdowns
  String _condominioSelecionado = 'Cond. Ecoville';
  String _ufSelecionada = 'MS';
  String _cidadeSelecionada = 'Selvíria';
  
  // Estados dos checkboxes
  bool _todosMarcado = false;
  
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
  bool _boletoGerarMarcado = false;
  bool _boletoEnviarMarcado = false;
  bool _boletoReceberMarcado = false;
  bool _boletoExcluirMarcado = false;
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
    super.dispose();
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
          _buildDropdownField('Condomínio', _condominioSelecionado, ['Cond. Ecoville'], (value) {
            setState(() {
              _condominioSelecionado = value!;
            });
          }),
          const SizedBox(height: 16),
          
          // Campos de texto
          _buildTextField('Nome Completo:', _nomeCompletoController, ''),
          const SizedBox(height: 12),
          _buildTextField('CPF:', _cpfController, ''),
          const SizedBox(height: 12),
          _buildTextField('Telefone:', _telefoneController, '51 3246-5666'),
          const SizedBox(height: 12),
          _buildTextField('Celular:', _celularController, '51 9996-32541'),
          const SizedBox(height: 12),
          _buildTextField('E-mail:', _emailController, 'josesilva@gmail.com'),
          const SizedBox(height: 12),
          
          // UF e Cidade
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildDropdownField('UF:', _ufSelecionada, ['MS'], (value) {
                  setState(() {
                    _ufSelecionada = value!;
                  });
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildDropdownField('Cidade:', _cidadeSelecionada, ['Selvíria'], (value) {
                  setState(() {
                    _cidadeSelecionada = value!;
                  });
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField('Endereço:', _enderecoController, 'Rua da Figueira'),
          const SizedBox(height: 24),
          
          // Seção Todos
          _buildCheckboxSection('Todos', _todosMarcado, (value) {
            setState(() {
              _todosMarcado = value!;
            });
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
                child: _buildDropdownField('UF:', 'MS', ['MS'], (value) {}),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildDropdownField('Cidade:', 'Selvíria', ['Selvíria'], (value) {}),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Resultado da pesquisa (card azul)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF87CEEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cond. Ecoville',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Cidade/UF',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'José da Silva',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CNPJ: 123.456/0001-00',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'CPF: 123.456.789-00',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.black54,
                          size: 20,
                        ),
                        SizedBox(height: 8),
                        Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildCheckboxSection(String title, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF1E3A8A),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildModulosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (value) {},
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
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Column(
            children: [
              _buildSubCheckbox('Chat', _chatMarcado, (value) {
                setState(() {
                  _chatMarcado = value!;
                });
              }),
              Row(
                children: [
                  Expanded(
                    child: _buildSubCheckbox('Reservas', _reservasMarcado, (value) {
                      setState(() {
                        _reservasMarcado = value!;
                      });
                    }),
                  ),
                  Expanded(
                    child: _buildSubCheckbox('(Configurações)', _reservasConfigMarcado, (value) {
                      setState(() {
                        _reservasConfigMarcado = value!;
                      });
                    }),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildSubCheckbox('Leitura', _leituraMarcado, (value) {
                      setState(() {
                        _leituraMarcado = value!;
                      });
                    }),
                  ),
                  Expanded(
                    child: _buildSubCheckbox('(Configurações)', _leituraConfigMarcado, (value) {
                      setState(() {
                        _leituraConfigMarcado = value!;
                      });
                    }),
                  ),
                ],
              ),
              _buildSubCheckbox('Diário/agenda', _diarioAgendaMarcado, (value) {
                setState(() {
                  _diarioAgendaMarcado = value!;
                });
              }),
              _buildSubCheckbox('Documentos', _documentosMarcado, (value) {
                setState(() {
                  _documentosMarcado = value!;
                });
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGestaoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (value) {},
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
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSubCheckbox('Condomínio', _condominioGestaoMarcado, (value) {
                      setState(() {
                        _condominioGestaoMarcado = value!;
                      });
                    }),
                  ),
                  Expanded(
                    child: _buildSubCheckbox('(Conf.)', _condominioConfMarcado, (value) {
                      setState(() {
                        _condominioConfMarcado = value!;
                      });
                    }),
                  ),
                ],
              ),
              _buildSubCheckbox('Relatórios', _relatoriosMarcado, (value) {
                setState(() {
                  _relatoriosMarcado = value!;
                });
              }),
              _buildSubCheckbox('Portaria', _portariaMarcado, (value) {
                setState(() {
                  _portariaMarcado = value!;
                });
              }),
              // Boleto com sub-opções
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSubCheckbox('Boleto', false, (value) {}),
                      ),
                      Expanded(
                        child: _buildSubCheckbox('(Gerar Boletos)', _boletoGerarMarcado, (value) {
                          setState(() {
                            _boletoGerarMarcado = value!;
                          });
                        }),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildSubCheckbox('(Enviar p/ Registro)', _boletoEnviarMarcado, (value) {
                                setState(() {
                                  _boletoEnviarMarcado = value!;
                                });
                              }),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSubCheckbox('(Receber)', _boletoReceberMarcado, (value) {
                                setState(() {
                                  _boletoReceberMarcado = value!;
                                });
                              }),
                            ),
                            Expanded(
                              child: _buildSubCheckbox('(Excluir)', _boletoExcluirMarcado, (value) {
                                setState(() {
                                  _boletoExcluirMarcado = value!;
                                });
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Acordo com sub-opções
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSubCheckbox('Acordo', false, (value) {}),
                      ),
                      Expanded(
                        child: _buildSubCheckbox('(Gerar Boletos)', _acordoGerarMarcado, (value) {
                          setState(() {
                            _acordoGerarMarcado = value!;
                          });
                        }),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: _buildSubCheckbox('(Enviar p/ Registro)', _acordoEnviarMarcado, (value) {
                      setState(() {
                        _acordoEnviarMarcado = value!;
                      });
                    }),
                  ),
                ],
              ),
              // Morador/Unid
              Row(
                children: [
                  Expanded(
                    child: _buildSubCheckbox('Morador/Unid', _moradorUnidMarcado, (value) {
                      setState(() {
                        _moradorUnidMarcado = value!;
                      });
                    }),
                  ),
                  Expanded(
                    child: _buildSubCheckbox('(Conf.)', _moradorConfMarcado, (value) {
                      setState(() {
                        _moradorConfMarcado = value!;
                      });
                    }),
                  ),
                ],
              ),
              _buildSubCheckbox('E-mail', _emailGestaoMarcado, (value) {
                setState(() {
                  _emailGestaoMarcado = value!;
                });
              }),
              _buildSubCheckbox('Desp/Receita', _despReceitaMarcado, (value) {
                setState(() {
                  _despReceitaMarcado = value!;
                });
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubCheckbox(String title, bool value, ValueChanged<bool?> onChanged) {
    return Row(
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
    );
  }

  void _salvarRepresentante() {
    // Por enquanto apenas mostra um snackbar
    // Futuramente será implementada a integração com Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de salvar será implementada em breve'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}