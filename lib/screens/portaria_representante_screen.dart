import 'package:flutter/material.dart';
import 'chat_representante_screen.dart';
import '../models/proprietario.dart';
import '../models/inquilino.dart';
import '../models/unidade.dart';
import '../services/supabase_service.dart';

class PortariaRepresentanteScreen extends StatefulWidget {
  final String? condominioId;
  final String? condominioNome;
  final String? condominioCnpj;

  const PortariaRepresentanteScreen({
    super.key,
    this.condominioId,
    this.condominioNome,
    this.condominioCnpj,
  });

  @override
  State<PortariaRepresentanteScreen> createState() => _PortariaRepresentanteScreenState();
}

class _PortariaRepresentanteScreenState extends State<PortariaRepresentanteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Controladores para a seção Visitante
  final TextEditingController _visitanteNomeController = TextEditingController();
  final TextEditingController _visitanteCpfCnpjController = TextEditingController();
  final TextEditingController _visitanteEnderecoController = TextEditingController();
  final TextEditingController _visitanteTelefoneController = TextEditingController();
  final TextEditingController _visitanteCelularController = TextEditingController();
  final TextEditingController _visitanteEmailController = TextEditingController();
  final TextEditingController _visitanteObsController = TextEditingController();
  
  // Controladores para a seção Unidade/Condomínio
  final TextEditingController _unidadeNomeController = TextEditingController();
  final TextEditingController _unidadeBlocoController = TextEditingController();
  final TextEditingController _unidadeObsController = TextEditingController();
  
  // Controladores para a seção Veículo
  final TextEditingController _veiculoCarroMotoController = TextEditingController();
  final TextEditingController _veiculoMarcaController = TextEditingController();
  final TextEditingController _veiculoPlacaController = TextEditingController();
  final TextEditingController _veiculoModeloController = TextEditingController();
  final TextEditingController _veiculoCorController = TextEditingController();
  
  // Estados
  bool _isUnidadeSelecionada = true; // true = Unidade, false = Condomínio
  
  // Estados para controlar expansão/retração das seções
  bool _isVisitanteExpanded = true;
  bool _isUnidadeCondominioExpanded = true;
  bool _isVeiculoExpanded = true;
  
  // Listas para a aba Prop/Inq
  List<Proprietario> _proprietarios = [];
  List<Inquilino> _inquilinos = [];
  List<Unidade> _unidades = [];
  bool _isLoadingPropInq = false;
  
  // Controles de busca e filtro para Prop/Inq
  final TextEditingController _searchController = TextEditingController();
  String _filtroTipo = 'Todos'; // 'Todos', 'Proprietários', 'Inquilinos'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _carregarDadosPropInq();
  }

  @override
  void dispose() {
    _tabController.dispose();
    
    // Dispose dos controladores da seção Visitante
    _visitanteNomeController.dispose();
    _visitanteCpfCnpjController.dispose();
    _visitanteEnderecoController.dispose();
    _visitanteTelefoneController.dispose();
    _visitanteCelularController.dispose();
    _visitanteEmailController.dispose();
    _visitanteObsController.dispose();
    
    // Dispose dos controladores da seção Unidade/Condomínio
    _unidadeNomeController.dispose();
    _unidadeBlocoController.dispose();
    _unidadeObsController.dispose();
    
    // Dispose dos controladores da seção Veículo
    _veiculoCarroMotoController.dispose();
    _veiculoMarcaController.dispose();
    _veiculoPlacaController.dispose();
    _veiculoModeloController.dispose();
    _veiculoCorController.dispose();
    
    // Dispose do controlador de busca
    _searchController.dispose();
    
    super.dispose();
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
                  Image.asset(
                    'assets/images/logo_CondoGaia.png',
                    height: 32,
                  ),
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
            Container(
              height: 1,
              color: const Color(0xFFE0E0E0),
            ),

            // Título da página
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white, // Cor de fundo branca
              child: const Text(
                'Home/Gestão/Portaria',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // TabBar com scroll horizontal
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true, // Permite scroll horizontal
                tabAlignment: TabAlignment.start, // Alinha as abas à esquerda
                labelColor: const Color(0xFF2E3A59),
                unselectedLabelColor: const Color(0xFF9E9E9E),
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: Color(0xFF1976D2),
                    width: 3.0,
                  ),
                ),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
                labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                tabs: const [
                  Tab(text: 'Acessos'),
                  Tab(text: 'Adicionar'),
                  Tab(text: 'Autorizados'),
                  Tab(text: 'Mensagem'),
                  Tab(text: 'Prop/Inq'),
                  Tab(text: 'Encomendas'),
                ],
              ),
            ),
            
            // Linha de separação
            Container(
              height: 1,
              color: const Color(0xFFE0E0E0),
            ),
            
            // Conteúdo das abas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Aba Acessos
                  _buildTabContent('Acessos'),
                  // Aba Adicionar
                  _buildTabContent('Adicionar'),
                  // Aba Autorizados
                  _buildTabContent('Autorizados'),
                  // Aba Mensagem
                  _buildTabContent('Mensagem'),
                  // Aba Prop/Inq
                  _buildTabContent('Prop/Inq'),
                  // Aba Encomendas
                  _buildTabContent('Encomendas'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para chip de filtro
  Widget _buildFiltroChip(String tipo) {
    bool isSelected = _filtroTipo == tipo;
    return FilterChip(
      label: Text(tipo),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filtroTipo = tipo;
        });
      },
      selectedColor: const Color(0xFF1976D2).withOpacity(0.2),
      checkmarkColor: const Color(0xFF1976D2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1976D2) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF1976D2) : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildTabContent(String tabName) {
    if (tabName == 'Adicionar') {
      return _buildAdicionarContent();
    } else if (tabName == 'Mensagem') {
      return _buildMensagemTab();
    } else if (tabName == 'Prop/Inq') {
      return _buildPropInqTab();
    }
    
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aba $tabName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E3A59),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Em desenvolvimento',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdicionarContent() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção Visitante
            _buildVisitanteSection(),
            
            const SizedBox(height: 24),
            
            // Seção Unidade/Condomínio
            _buildUnidadeCondominioSection(),
            
            const SizedBox(height: 24),
            
            // Seção Veículo
            _buildVeiculoSection(),
            
            const SizedBox(height: 32),
            
            // Botão Salvar/Entrar
            _buildSalvarEntrarButton(),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitanteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção com funcionalidade de toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _isVisitanteExpanded = !_isVisitanteExpanded;
              });
            },
            child: Row(
              children: [
                const Icon(
                  Icons.person,
                  color: Color(0xFF2E3A59),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Visitante',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3A59),
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _isVisitanteExpanded ? 0.0 : -0.5,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF666666),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          
          // Conteúdo expansível da seção
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isVisitanteExpanded ? null : 0,
            child: _isVisitanteExpanded ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // Campo Nome
                _buildTextField(
                  label: 'Nome:',
                  controller: _visitanteNomeController,
                  hintText: 'José Marcos da Silva',
                ),
                
                const SizedBox(height: 16),
                
                // Campo CPF/CNPJ
                _buildTextField(
                  label: 'CPF/CNPJ:',
                  controller: _visitanteCpfCnpjController,
                  hintText: '88595-946.2',
                ),
                
                const SizedBox(height: 16),
                
                // Campo Endereço
                _buildTextField(
                  label: 'Endereço:',
                  controller: _visitanteEnderecoController,
                  hintText: 'Rua Almirante Carlos Guedert',
                ),
                
                const SizedBox(height: 16),
                
                // Linha com Telefone e Celular
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Telefone:',
                        controller: _visitanteTelefoneController,
                        hintText: '51 3246-5666',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'Celular:',
                        controller: _visitanteCelularController,
                        hintText: '51 9996-32541',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Campo Email
                _buildTextField(
                  label: 'Email:',
                  controller: _visitanteEmailController,
                  hintText: 'josesilva@gmail.com',
                ),
                
                const SizedBox(height: 16),
                
                // Campo OBS
                _buildTextField(
                  label: 'OBS:',
                  controller: _visitanteObsController,
                  hintText: '',
                  maxLines: 3,
                ),
                
                const SizedBox(height: 16),
                
                // Botão Anexar foto
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF666666),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implementar anexar foto
                      },
                      child: const Text(
                        'Anexar foto',
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildUnidadeCondominioSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção com funcionalidade de toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _isUnidadeCondominioExpanded = !_isUnidadeCondominioExpanded;
              });
            },
            child: Row(
              children: [
                const Icon(
                  Icons.business,
                  color: Color(0xFF2E3A59),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Unidade/Condomínio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3A59),
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _isUnidadeCondominioExpanded ? 0.0 : -0.5,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF666666),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          
          // Conteúdo expansível da seção
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isUnidadeCondominioExpanded ? null : 0,
            child: _isUnidadeCondominioExpanded ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // Toggle Unidade/Condomínio
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isUnidadeSelecionada = true;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            _isUnidadeSelecionada ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: _isUnidadeSelecionada ? const Color(0xFF1976D2) : const Color(0xFF666666),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Unidade',
                            style: TextStyle(
                              fontSize: 14,
                              color: _isUnidadeSelecionada ? const Color(0xFF2E3A59) : const Color(0xFF666666),
                              fontWeight: _isUnidadeSelecionada ? FontWeight.w500 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isUnidadeSelecionada = false;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            !_isUnidadeSelecionada ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: !_isUnidadeSelecionada ? const Color(0xFF1976D2) : const Color(0xFF666666),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Condomínio',
                            style: TextStyle(
                              fontSize: 14,
                              color: !_isUnidadeSelecionada ? const Color(0xFF2E3A59) : const Color(0xFF666666),
                              fontWeight: !_isUnidadeSelecionada ? FontWeight.w500 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Campo de busca
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Pesquisar unidade/bloco ou nome',
                          style: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.search,
                        color: Color(0xFF666666),
                        size: 20,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Campo Nome
                _buildTextField(
                  label: 'Nome:',
                  controller: _unidadeNomeController,
                  hintText: '',
                ),
                
                const SizedBox(height: 16),
                
                // Campo Bloco/Unid.
                _buildTextField(
                  label: 'Bloco/Unid.:',
                  controller: _unidadeBlocoController,
                  hintText: '',
                ),
                
                const SizedBox(height: 16),
                
                // Campo OBS
                _buildTextField(
                  label: 'OBS:',
                  controller: _unidadeObsController,
                  hintText: '',
                  maxLines: 3,
                ),
              ],
            ) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildVeiculoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          GestureDetector(
            onTap: () {
              setState(() {
                _isVeiculoExpanded = !_isVeiculoExpanded;
              });
            },
            child: Row(
              children: [
                const Icon(
                  Icons.directions_car,
                  color: Color(0xFF2E3A59),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Veículo(s)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3A59),
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _isVeiculoExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF666666),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
           
           // Conteúdo expansível da seção
           AnimatedContainer(
             duration: const Duration(milliseconds: 300),
             height: _isVeiculoExpanded ? null : 0,
             child: _isVeiculoExpanded ? Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const SizedBox(height: 16),
                 
                 // Linha com Carro/Moto e Marca
                 Row(
                   children: [
                     Expanded(
                       child: _buildTextField(
                         label: 'Carro/Moto:',
                         controller: _veiculoCarroMotoController,
                         hintText: 'Carro',
                       ),
                     ),
                     const SizedBox(width: 16),
                     Expanded(
                       child: _buildTextField(
                         label: 'Marca:',
                         controller: _veiculoMarcaController,
                         hintText: 'Fiat',
                       ),
                     ),
                   ],
                 ),
                 
                 const SizedBox(height: 16),
                 
                 // Linha com Placa e Modelo
                 Row(
                   children: [
                     Expanded(
                       child: _buildTextField(
                         label: 'Placa:',
                         controller: _veiculoPlacaController,
                         hintText: 'ABC1243',
                       ),
                     ),
                     const SizedBox(width: 16),
                     Expanded(
                       child: _buildTextField(
                         label: 'Modelo:',
                         controller: _veiculoModeloController,
                         hintText: 'Fiat Argo',
                       ),
                     ),
                   ],
                 ),
                 
                 const SizedBox(height: 16),
                 
                 // Campo Cor
                 _buildTextField(
                   label: 'Cor:',
                   controller: _veiculoCorController,
                   hintText: 'Preto',
                 ),
               ],
             ) : const SizedBox.shrink(),
           ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalvarEntrarButton() {
    return Container(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implementar lógica de salvar/entrar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visitante adicionado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E3A59),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Salvar/Entrar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Widget para a aba Mensagem
  Widget _buildMensagemTab() {
    // Dados mockados de mensagens
    final List<Map<String, dynamic>> mensagens = [
      {
        'nome': 'Luana Sichieri',
        'apartamento': 'B/501',
        'data': '25/11/2023 17:20',
        'icone': Icons.person,
        'corFundo': const Color(0xFF2C3E50),
      },
      {
        'nome': 'João Moreira',
        'apartamento': 'A/400',
        'data': '24/11/2023 07:20',
        'icone': Icons.person_outline,
        'corFundo': const Color(0xFF4A90E2),
      },
      {
        'nome': 'Pedro Tebet',
        'apartamento': 'C/200',
        'data': '25/10/2023 17:20',
        'icone': Icons.person_outline,
        'corFundo': const Color(0xFF4A90E2),
      },
      {
        'nome': 'Rui Guerra',
        'apartamento': 'D/301',
        'data': '25/09/2023 17:20',
        'icone': Icons.person_outline,
        'corFundo': const Color(0xFF4A90E2),
      },
    ];

    return Container(
      color: const Color(0xFFF5F5F5),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: mensagens.length,
        itemBuilder: (context, index) {
          final mensagem = mensagens[index];
          return _buildMensagemCard(
            nome: mensagem['nome'],
            apartamento: mensagem['apartamento'],
            data: mensagem['data'],
            icone: mensagem['icone'],
            corFundo: mensagem['corFundo'],
          );
        },
      ),
    );
  }

  // Widget do card de mensagem
  Widget _buildMensagemCard({
    required String nome,
    required String apartamento,
    required String data,
    required IconData icone,
    required Color corFundo,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: corFundo,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icone,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          '$nome  $apartamento',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        subtitle: Text(
          data,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7F8C8D),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRepresentanteScreen(
                nomeContato: nome,
                apartamento: apartamento,
              ),
            ),
          );
        },
      ),
    );
  }

  // Método para carregar dados de proprietários, inquilinos e unidades
  Future<void> _carregarDadosPropInq() async {
    if (widget.condominioId == null) return;
    
    setState(() {
      _isLoadingPropInq = true;
    });

    try {
      // Buscar unidades
      final unidadesResponse = await SupabaseService.client
          .from('unidades')
          .select()
          .eq('condominio_id', widget.condominioId!)
          .eq('ativo', true)
          .order('numero');

      _unidades = unidadesResponse.map<Unidade>((json) => Unidade.fromJson(json)).toList();

      // Buscar proprietários
      final proprietariosResponse = await SupabaseService.client
          .from('proprietarios')
          .select()
          .eq('condominio_id', widget.condominioId!)
          .eq('ativo', true)
          .order('nome');

      _proprietarios = proprietariosResponse.map<Proprietario>((json) => Proprietario.fromJson(json)).toList();

      // Buscar inquilinos
      final inquilinosResponse = await SupabaseService.client
          .from('inquilinos')
          .select()
          .eq('condominio_id', widget.condominioId!)
          .eq('ativo', true)
          .order('nome');

      _inquilinos = inquilinosResponse.map<Inquilino>((json) => Inquilino.fromJson(json)).toList();

    } catch (e) {
      print('Erro ao carregar dados Prop/Inq: $e');
    } finally {
      setState(() {
        _isLoadingPropInq = false;
      });
    }
  }

  // Widget da aba Prop/Inq
  Widget _buildPropInqTab() {
    if (_isLoadingPropInq) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1976D2),
        ),
      );
    }

    // Agrupar pessoas por unidade
    Map<String, List<Map<String, dynamic>>> pessoasPorUnidade = {};
    
    // Filtrar dados baseado na busca e filtro
    List<Proprietario> proprietariosFiltrados = _proprietarios.where((p) {
      bool matchesBusca = _searchController.text.isEmpty ||
          p.nome.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          p.cpfCnpj.contains(_searchController.text);
      bool matchesFiltro = _filtroTipo == 'Todos' || _filtroTipo == 'Proprietários';
      return matchesBusca && matchesFiltro;
    }).toList();
    
    List<Inquilino> inquilinosFiltrados = _inquilinos.where((i) {
      bool matchesBusca = _searchController.text.isEmpty ||
          i.nome.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          i.cpfCnpj.contains(_searchController.text);
      bool matchesFiltro = _filtroTipo == 'Todos' || _filtroTipo == 'Inquilinos';
      return matchesBusca && matchesFiltro;
    }).toList();
    
    // Adicionar proprietários filtrados
    for (var proprietario in proprietariosFiltrados) {
      final unidade = _unidades.firstWhere(
        (u) => u.id == proprietario.unidadeId,
        orElse: () => Unidade(
          id: '',
          numero: 'N/A',
          condominioId: '',
          tipoUnidade: '',
          isencaoNenhum: true,
          isencaoTotal: false,
          isencaoCota: false,
          isencaoFundoReserva: false,
          acaoJudicial: false,
          correios: false,
          nomePagadorBoleto: 'proprietario',
          ativo: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      String chaveUnidade = unidade.bloco != null && unidade.bloco!.isNotEmpty
          ? '${unidade.bloco}/${unidade.numero}'
          : unidade.numero;
      
      if (!pessoasPorUnidade.containsKey(chaveUnidade)) {
        pessoasPorUnidade[chaveUnidade] = [];
      }
      
      pessoasPorUnidade[chaveUnidade]!.add({
        'nome': proprietario.nome,
        'cpf': proprietario.cpfCnpj,
        'fotoPerfil': proprietario.fotoPerfil,
        'tipo': 'Proprietário',
        'tipoIcon': Icons.home,
        'tipoColor': const Color(0xFF4CAF50),
      });
    }
    
    // Adicionar inquilinos filtrados
    for (var inquilino in inquilinosFiltrados) {
      final unidade = _unidades.firstWhere(
        (u) => u.id == inquilino.unidadeId,
        orElse: () => Unidade(
          id: '',
          numero: 'N/A',
          condominioId: '',
          tipoUnidade: '',
          isencaoNenhum: true,
          isencaoTotal: false,
          isencaoCota: false,
          isencaoFundoReserva: false,
          acaoJudicial: false,
          correios: false,
          nomePagadorBoleto: 'proprietario',
          ativo: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      String chaveUnidade = unidade.bloco != null && unidade.bloco!.isNotEmpty
          ? '${unidade.bloco}/${unidade.numero}'
          : unidade.numero;
      
      if (!pessoasPorUnidade.containsKey(chaveUnidade)) {
        pessoasPorUnidade[chaveUnidade] = [];
      }
      
      pessoasPorUnidade[chaveUnidade]!.add({
        'nome': inquilino.nome,
        'cpf': inquilino.cpfCnpj,
        'fotoPerfil': inquilino.fotoPerfil,
        'tipo': 'Inquilino',
        'tipoIcon': Icons.person,
        'tipoColor': const Color(0xFF2196F3),
      });
    }

    // Ordenar as chaves das unidades
    List<String> unidadesOrdenadas = pessoasPorUnidade.keys.toList()..sort();

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Cabeçalho
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.apartment, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Proprietários e Inquilinos por Unidade',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${unidadesOrdenadas.length} unidades',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Barra de busca e filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Campo de busca
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou CPF...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF1976D2)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1976D2)),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Filtros por tipo
                Row(
                  children: [
                    const Text(
                      'Filtrar por:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2E3A59),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFiltroChip('Todos'),
                            const SizedBox(width: 8),
                            _buildFiltroChip('Proprietários'),
                            const SizedBox(width: 8),
                            _buildFiltroChip('Inquilinos'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista expandível por unidade
          Expanded(
            child: unidadesOrdenadas.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum proprietário ou inquilino encontrado',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: unidadesOrdenadas.length,
                    itemBuilder: (context, index) {
                      String unidade = unidadesOrdenadas[index];
                      List<Map<String, dynamic>> pessoas = pessoasPorUnidade[unidade]!;
                      
                      return _buildUnidadeExpandible(unidade, pessoas);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget para unidade expandível
  Widget _buildUnidadeExpandible(String unidade, List<Map<String, dynamic>> pessoas) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.apartment,
            color: Color(0xFF1976D2),
            size: 20,
          ),
        ),
        title: Text(
          'Unidade $unidade',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF2E3A59),
          ),
        ),
        subtitle: Text(
          '${pessoas.length} ${pessoas.length == 1 ? 'pessoa' : 'pessoas'}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${pessoas.length}',
            style: const TextStyle(
              color: Color(0xFF1976D2),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: pessoas.map((pessoa) => _buildPessoaCard(pessoa)).toList(),
      ),
    );
  }

  // Widget para card de pessoa
  Widget _buildPessoaCard(Map<String, dynamic> pessoa) {
    String cpfTresPrimeiros = pessoa['cpf'].length >= 3 
        ? pessoa['cpf'].substring(0, 3) 
        : pessoa['cpf'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: pessoa['fotoPerfil'] != null && pessoa['fotoPerfil'].isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      pessoa['fotoPerfil'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: Colors.grey[600],
                          size: 28,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Colors.grey[600],
                    size: 28,
                  ),
          ),
          
          const SizedBox(width: 12),
          
          // Informações da pessoa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome
                Text(
                  pessoa['nome'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3A59),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // CPF
                Text(
                  'CPF: ${cpfTresPrimeiros}...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Badge do tipo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: pessoa['tipoColor'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  pessoa['tipoIcon'],
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  pessoa['tipo'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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