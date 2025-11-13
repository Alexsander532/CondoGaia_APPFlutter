import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'conversas_simples_screen.dart';
import '../models/proprietario.dart';
import '../models/inquilino.dart';
import '../models/unidade.dart';
import '../models/encomenda.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../services/autorizado_inquilino_service.dart';
import '../services/visitante_portaria_service.dart';
import '../services/historico_acesso_service.dart';
import '../services/encomenda_service.dart';
import '../utils/formatters.dart';

// Classe para unificar proprietários e inquilinos
class PessoaUnidade {
  final String id;
  final String nome;
  final String unidadeId;
  final String unidadeNumero;
  final String unidadeBloco;
  final String tipo; // 'P' para proprietário, 'I' para inquilino
  final String? fotoPerfil; // URL ou base64

  PessoaUnidade({
    required this.id,
    required this.nome,
    required this.unidadeId,
    required this.unidadeNumero,
    required this.unidadeBloco,
    required this.tipo,
    this.fotoPerfil,
  });
}

class PortariaRepresentanteScreen extends StatefulWidget {
  final String? condominioId;
  final String? condominioNome;
  final String? condominioCnpj;
  final String? representanteId;

  const PortariaRepresentanteScreen({
    super.key,
    this.condominioId,
    this.condominioNome,
    this.condominioCnpj,
    this.representanteId,
  });

  @override
  State<PortariaRepresentanteScreen> createState() =>
      _PortariaRepresentanteScreenState();
}

class _PortariaRepresentanteScreenState
    extends State<PortariaRepresentanteScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _encomendasTabController;

  // Controladores para a seção Visitante
  final TextEditingController _visitanteNomeController =
      TextEditingController();
  final TextEditingController _visitanteCpfCnpjController =
      TextEditingController();
  final TextEditingController _visitanteEnderecoController =
      TextEditingController();
  final TextEditingController _visitanteTelefoneController =
      TextEditingController();
  final TextEditingController _visitanteCelularController =
      TextEditingController();
  final TextEditingController _visitanteEmailController =
      TextEditingController();
  final TextEditingController _visitanteObsController = TextEditingController();

  // Controladores para a seção Unidade/Condomínio
  final TextEditingController _unidadeNomeController = TextEditingController();
  final TextEditingController _unidadeBlocoController = TextEditingController();
  final TextEditingController _unidadeObsController = TextEditingController();
  final TextEditingController _unidadeSearchController =
      TextEditingController();
  final TextEditingController _quemAutorizouController =
      TextEditingController();

  // Controladores para a seção Veículo
  final TextEditingController _veiculoCarroMotoController =
      TextEditingController();
  final TextEditingController _veiculoMarcaController = TextEditingController();
  final TextEditingController _veiculoPlacaController = TextEditingController();
  final TextEditingController _veiculoModeloController =
      TextEditingController();
  final TextEditingController _veiculoCorController = TextEditingController();

  // Estados
  bool _isUnidadeSelecionada = true; // true = Unidade, false = Condomínio
  bool _isLoading =
      false; // Estado de carregamento para o cadastro de visitante

  // Variáveis de erro para validação
  String? _cpfError;
  String? _celularError;
  String? _emailError;

  // Estados para controlar expansão/retração das seções
  bool _isVisitanteExpanded = true;
  bool _isUnidadeCondominioExpanded = true;
  bool _isVeiculoExpanded = true;

  // Listas para a aba Prop/Inq
  List<Proprietario> _proprietarios = [];
  List<Inquilino> _inquilinos = [];
  List<Unidade> _unidades = [];
  List<Unidade> _unidadesFiltradas = [];
  Unidade? _unidadeSelecionadaVisitante;
  bool _isLoadingPropInq = false;

  // Lista unificada de pessoas (proprietários e inquilinos) para encomendas
  List<PessoaUnidade> _pessoasUnidade = [];
  PessoaUnidade? _pessoaSelecionadaEncomenda;

  // Variáveis para a aba Autorizados
  Map<String, List<Map<String, dynamic>>> _autorizadosPorUnidade = {};
  bool _isLoadingAutorizados = false;

  // Variáveis para controle de acessos
  final HistoricoAcessoService _historicoAcessoService =
      HistoricoAcessoService();
  final EncomendaService _encomendaService = EncomendaService();
  List<Map<String, dynamic>> _visitantesNoCondominio = [];
  bool _isLoadingAcessos = false;

  // Variáveis para visitantes cadastrados
  List<Map<String, dynamic>> _visitantesCadastrados = [];
  bool _isLoadingVisitantesCadastrados = false;
  final TextEditingController _pesquisaVisitanteController =
      TextEditingController();

  // Variáveis para a seção de Encomendas
  // Variável para encomenda selecionada (removendo a antiga)
  // Unidade? _unidadeSelecionadaEncomenda;
  File? _imagemEncomenda;
  bool _notificarUnidade = false;
  
  // Variáveis para o histórico de encomendas
  List<Map<String, dynamic>> _historicoEncomendas = [];
  bool _isLoadingHistoricoEncomendas = false;
  String? _errorHistoricoEncomendas;

  // Variável para armazenar dados do representante atual
  dynamic _representanteAtual;
  bool _isLoadingRepresentante = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _encomendasTabController = TabController(length: 2, vsync: this);
    _carregarRepresentanteAtual();
    _carregarDadosPropInq();
    _carregarAutorizados();
    _carregarVisitantesNoCondominio();
    _carregarVisitantesCadastrados();
    _carregarHistoricoEncomendas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _encomendasTabController.dispose();

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
    _unidadeSearchController.dispose();
    _quemAutorizouController.dispose();

    // Dispose dos controladores da seção Veículo
    _veiculoCarroMotoController.dispose();
    _veiculoMarcaController.dispose();
    _veiculoPlacaController.dispose();
    _veiculoModeloController.dispose();
    _veiculoCorController.dispose();

    // Dispose do controlador de pesquisa de visitantes
    _pesquisaVisitanteController.dispose();

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
                  borderSide: BorderSide(color: Color(0xFF1976D2), width: 3.0),
                ),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
            Container(height: 1, color: const Color(0xFFE0E0E0)),

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

  Widget _buildTabContent(String tabName) {
    if (tabName == 'Adicionar') {
      return _buildAdicionarContent();
    } else if (tabName == 'Mensagem') {
      return _buildMensagemTab();
    } else if (tabName == 'Prop/Inq') {
      return _buildPropInqTab();
    } else if (tabName == 'Encomendas') {
      return _buildEncomendasTab();
    } else if (tabName == 'Autorizados') {
      return _buildAutorizadosTab();
    } else if (tabName == 'Acessos') {
      return _buildAcessosTab();
    }

    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
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
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                const Icon(Icons.person, color: Color(0xFF2E3A59), size: 20),
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
            child: _isVisitanteExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Campo Nome
                      _buildTextField(
                        label: 'Nome:',
                        controller: _visitanteNomeController,
                        hintText: 'José Marcos da Silva',
                        isRequired: true,
                      ),

                      const SizedBox(height: 16),

                      // Campo CPF/CNPJ
                      _buildTextField(
                        label: 'CPF/CNPJ:',
                        controller: _visitanteCpfCnpjController,
                        hintText: '000.000.000-00',
                        onChanged: _validateCPF,
                        errorText: _cpfError,
                        mask: Formatters.cpfFormatter,
                        keyboardType: TextInputType.number,
                        isRequired: true,
                      ),

                      const SizedBox(height: 16),

                      // Campo Endereço
                      _buildTextField(
                        label: 'Endereço:',
                        controller: _visitanteEnderecoController,
                        hintText: 'Rua Almirante Carlos Guedert',
                        isRequired: true,
                      ),

                      const SizedBox(height: 16),

                      // Linha com Telefone e Celular
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Telefone:',
                              controller: _visitanteTelefoneController,
                              hintText: '(00) 00000-0000',
                              mask: Formatters.phoneFormatter,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Celular:',
                              controller: _visitanteCelularController,
                              hintText: '(00) 00000-0000',
                              onChanged: _validateCelular,
                              errorText: _celularError,
                              mask: Formatters.phoneFormatter,
                              keyboardType: TextInputType.phone,
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Campo Email
                      _buildTextField(
                        label: 'Email:',
                        controller: _visitanteEmailController,
                        hintText: 'email@endereco.com',
                        onChanged: _validateEmail,
                        errorText: _emailError,
                        keyboardType: TextInputType.emailAddress,
                        isRequired: true,
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
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                              ),
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
                  )
                : const SizedBox.shrink(),
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
                const Icon(Icons.business, color: Color(0xFF2E3A59), size: 20),
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
            child: _isUnidadeCondominioExpanded
                ? Column(
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
                                _unidadeSelecionadaVisitante = null;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  _isUnidadeSelecionada
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: _isUnidadeSelecionada
                                      ? const Color(0xFF1976D2)
                                      : const Color(0xFF666666),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Unidade',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _isUnidadeSelecionada
                                        ? const Color(0xFF2E3A59)
                                        : const Color(0xFF666666),
                                    fontWeight: _isUnidadeSelecionada
                                        ? FontWeight.w500
                                        : FontWeight.w400,
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
                                _unidadeSelecionadaVisitante = null;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  !_isUnidadeSelecionada
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: !_isUnidadeSelecionada
                                      ? const Color(0xFF1976D2)
                                      : const Color(0xFF666666),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Condomínio',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: !_isUnidadeSelecionada
                                        ? const Color(0xFF2E3A59)
                                        : const Color(0xFF666666),
                                    fontWeight: !_isUnidadeSelecionada
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Conteúdo condicional baseado na seleção
                      if (_isUnidadeSelecionada) ...[
                        // Campo de busca para unidades
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: TextField(
                            controller: _unidadeSearchController,
                            onChanged: _filtrarUnidadesVisitante,
                            decoration: const InputDecoration(
                              hintText: 'Pesquisar unidade/bloco...',
                              hintStyle: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Color(0xFF666666),
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 0,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Lista de unidades disponíveis
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _unidadesFiltradas.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhuma unidade encontrada',
                                    style: TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _unidadesFiltradas.length,
                                  itemBuilder: (context, index) {
                                    final unidade = _unidadesFiltradas[index];
                                    final isSelected =
                                        _unidadeSelecionadaVisitante?.id ==
                                        unidade.id;

                                    return ListTile(
                                      dense: true,
                                      leading: Icon(
                                        isSelected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: isSelected
                                            ? const Color(0xFF1976D2)
                                            : const Color(0xFF666666),
                                        size: 20,
                                      ),
                                      title: Text(
                                        '${unidade.bloco != null && unidade.bloco!.isNotEmpty ? "${unidade.bloco}/" : ""}${unidade.numero}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w500
                                              : FontWeight.w400,
                                          color: isSelected
                                              ? const Color(0xFF2E3A59)
                                              : const Color(0xFF666666),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if (_unidadeSelecionadaVisitante
                                                  ?.id ==
                                              unidade.id) {
                                            _unidadeSelecionadaVisitante = null;
                                          } else {
                                            _unidadeSelecionadaVisitante =
                                                unidade;
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 16),
                      ],

                      // Campos condicionais baseados na seleção
                      if (!_isUnidadeSelecionada) ...[
                        // Campo "Quem autorizou" (apenas no modo Condomínio)
                        _buildTextField(
                          label: 'Quem autorizou:',
                          controller: _quemAutorizouController,
                          hintText: 'Nome de quem autorizou a visita...',
                        ),

                        const SizedBox(height: 16),
                      ],

                      // Campo OBS (sempre visível)
                      _buildTextField(
                        label: 'OBS:',
                        controller: _unidadeObsController,
                        hintText: _isUnidadeSelecionada
                            ? 'Observações sobre a visita à unidade...'
                            : 'Observações sobre a visita ao condomínio...',
                        maxLines: 3,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
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
            child: _isVeiculoExpanded
                ? Column(
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
                  )
                : const SizedBox.shrink(),
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
    Function(String)? onChanged,
    String? errorText,
    mask,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText != null ? Colors.red : const Color(0xFFE0E0E0),
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: onChanged,
            keyboardType: keyboardType,
            inputFormatters: mask != null ? [mask] : null,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF999999),
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
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildSalvarEntrarButton() {
    return Container(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _cadastrarVisitante,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E3A59),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Salvar/Entrar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  // Widget para a aba Mensagem - INTEGRADA COM DADOS REAIS
  /// Carrega dados do representante atual autenticado
  Future<void> _carregarRepresentanteAtual() async {
    debugPrint('═' * 80);
    debugPrint('🟦 [PORTARIA_REP] ═══ CARREGANDO REPRESENTANTE ═══');
    debugPrint('═' * 80);
    
    try {
      debugPrint('🔄 [PORTARIA_REP] Chamando AuthService.getCurrentRepresentante()...');
      final representante = await AuthService.getCurrentRepresentante();
      
      if (representante == null) {
        debugPrint('[PORTARIA_REP] ERROR: AuthService retornou NULL');
        setState(() {
          _isLoadingRepresentante = false;
        });
        return;
      }
      
      debugPrint('[PORTARIA_REP] OK: Representante obtido com sucesso');
      debugPrint('[PORTARIA_REP] ID: ${representante.id}');
      debugPrint('[PORTARIA_REP] Nome: ${representante.nomeCompleto}');
      debugPrint('[PORTARIA_REP] CPF: ${representante.cpf}');
      
      if (representante.id.isEmpty) {
        debugPrint('[PORTARIA_REP] ERROR: ID está VAZIO!');
        setState(() {
          _isLoadingRepresentante = false;
        });
        return;
      }
      
      setState(() {
        _representanteAtual = representante;
        _isLoadingRepresentante = false;
      });
      
      debugPrint('[PORTARIA_REP] OK: Estado atualizado com representante');
    } catch (e, stackTrace) {
      debugPrint('[PORTARIA_REP] ERROR: ao carregar representante!');
      debugPrint('[PORTARIA_REP] Erro: $e');
      debugPrint('[PORTARIA_REP] Stack: $stackTrace');
      
      setState(() {
        _isLoadingRepresentante = false;
      });
    }
  }

  Widget _buildMensagemTab() {
    debugPrint('═' * 80);
    debugPrint('[PORTARIA_REP] BUILD MENSAGEM TAB');
    debugPrint('[PORTARIA_REP] _isLoadingRepresentante: $_isLoadingRepresentante');
    debugPrint('[PORTARIA_REP] _representanteAtual: $_representanteAtual');
    
    // Se ainda está carregando o representante, mostra loading
    if (_isLoadingRepresentante) {
      debugPrint('[PORTARIA_REP] Ainda está carregando representante...');
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Se não conseguiu carregar o representante, mostra erro
    if (_representanteAtual == null) {
      debugPrint('[PORTARIA_REP] ERROR: _representanteAtual é NULL!');
      return const Center(
        child: Text('Erro ao carregar dados do representante'),
      );
    }

    final repId = _representanteAtual.id;
    final repNome = _representanteAtual.nomeCompleto;
    
    debugPrint('[PORTARIA_REP] OK: Representante carregado com sucesso');
    debugPrint('[PORTARIA_REP] ID a passar para ConversasSimples: $repId');
    debugPrint('[PORTARIA_REP] Nome a passar para ConversasSimples: $repNome');
    debugPrint('[PORTARIA_REP] Condominio ID: ${widget.condominioId}');

    // Retorna o ConversasSimples com UI simplificada (apenas busca, sem filtros)
    // Usa dados reais do representante autenticado
    return ConversasSimples(
      condominioId: widget.condominioId!,
      representanteId: repId,
      representanteName: repNome,
    );
  }

  // Método para carregar dados de proprietários, inquilinos e unidades
  Future<void> _carregarDadosPropInq() async {
    if (widget.condominioId == null) return;

    setState(() {
      _isLoadingPropInq = true;
    });

    try {
      // Buscar todas as unidades ativas
      final unidadesResponse = await SupabaseService.client
          .from('unidades')
          .select()
          .eq('condominio_id', widget.condominioId!)
          .eq('ativo', true)
          .order('numero');

      // Buscar proprietários ativos para filtrar unidades
      final proprietariosAtivos = await SupabaseService.client
          .from('proprietarios')
          .select('unidade_id')
          .eq('condominio_id', widget.condominioId!)
          .eq('ativo', true);

      // Criar set de IDs de unidades que têm proprietários ativos
      final unidadesComProprietarios = proprietariosAtivos
          .map((p) => p['unidade_id'] as String)
          .toSet();

      // Filtrar apenas unidades que têm proprietários ativos
      _unidades = unidadesResponse
          .where((json) => unidadesComProprietarios.contains(json['id']))
          .map<Unidade>((json) => Unidade.fromJson(json))
          .toList();
      _unidadesFiltradas = List.from(_unidades);

      // Buscar proprietários
      final proprietariosResponse = await SupabaseService.client
          .from('proprietarios')
          .select()
          .eq('condominio_id', widget.condominioId!)
          .eq('ativo', true)
          .order('nome');

      _proprietarios = proprietariosResponse
          .map<Proprietario>((json) => Proprietario.fromJson(json))
          .toList();

      // Buscar inquilinos
      final inquilinosResponse = await SupabaseService.client
          .from('inquilinos')
          .select()
          .eq('condominio_id', widget.condominioId!)
          .eq('ativo', true)
          .order('nome');

      _inquilinos = inquilinosResponse
          .map<Inquilino>((json) => Inquilino.fromJson(json))
          .toList();

      // Criar lista unificada de pessoas para encomendas
      _pessoasUnidade.clear();

      // Adicionar proprietários
      for (final proprietario in _proprietarios) {
        final unidade = _unidades.firstWhere(
          (u) => u.id == proprietario.unidadeId,
          orElse: () => Unidade(
            id: proprietario.unidadeId ?? '',
            condominioId: widget.condominioId!,
            numero: 'N/A',
            bloco: 'N/A',
            ativo: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        _pessoasUnidade.add(
          PessoaUnidade(
            id: proprietario.id,
            nome: proprietario.nome,
            unidadeId: proprietario.unidadeId ?? '',
            unidadeNumero: unidade.numero,
            unidadeBloco: unidade.bloco ?? 'N/A',
            tipo: 'P',
            fotoPerfil: proprietario.fotoPerfil,
          ),
        );
      }

      // Adicionar inquilinos
      for (final inquilino in _inquilinos) {
        final unidade = _unidades.firstWhere(
          (u) => u.id == inquilino.unidadeId,
          orElse: () => Unidade(
            id: inquilino.unidadeId,
            condominioId: widget.condominioId!,
            numero: 'N/A',
            bloco: 'N/A',
            ativo: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        _pessoasUnidade.add(
          PessoaUnidade(
            id: inquilino.id,
            nome: inquilino.nome,
            unidadeId: inquilino.unidadeId,
            unidadeNumero: unidade.numero,
            unidadeBloco: unidade.bloco ?? 'N/A',
            tipo: 'I',
            fotoPerfil: inquilino.fotoPerfil,
          ),
        );
      }

      // Ordenar por unidade e depois por nome
      _pessoasUnidade.sort((a, b) {
        final unidadeComparison = '${a.unidadeNumero}/${a.unidadeBloco}'
            .compareTo('${b.unidadeNumero}/${b.unidadeBloco}');
        if (unidadeComparison != 0) return unidadeComparison;
        return a.nome.compareTo(b.nome);
      });
    } catch (e) {
      print('Erro ao carregar dados Prop/Inq: $e');
    } finally {
      setState(() {
        _isLoadingPropInq = false;
      });
    }
  }

  // Método para carregar autorizados agrupados por unidade
  Future<void> _carregarAutorizados() async {
    if (widget.condominioId == null) return;

    setState(() {
      _isLoadingAutorizados = true;
    });

    try {
      print(
        '🔍 DEBUG: Carregando autorizados para condomínio: ${widget.condominioId}',
      );

      final autorizados =
          await AutorizadoInquilinoService.getAutorizadosAgrupadosPorUnidade(
            widget.condominioId!,
          );

      print('🔍 DEBUG: Autorizados carregados: ${autorizados.length} unidades');
      print('🔍 DEBUG: Dados dos autorizados: $autorizados');

      setState(() {
        _autorizadosPorUnidade = autorizados;
      });
    } catch (e) {
      print('❌ ERRO ao carregar autorizados: $e');
    } finally {
      setState(() {
        _isLoadingAutorizados = false;
      });
    }
  }

  // Carregar visitantes atualmente no condomínio
  Future<void> _carregarVisitantesNoCondominio() async {
    if (widget.condominioId == null) return;

    setState(() {
      _isLoadingAcessos = true;
    });

    try {
      final visitantes = await _historicoAcessoService
          .getVisitantesNoCondominio(widget.condominioId!);

      setState(() {
        _visitantesNoCondominio = visitantes;
      });
    } catch (e) {
      print('❌ ERRO ao carregar visitantes no condomínio: $e');
    } finally {
      setState(() {
        _isLoadingAcessos = false;
      });
    }
  }

  Future<void> _carregarVisitantesCadastrados() async {
    if (widget.condominioId == null) return;

    setState(() {
      _isLoadingVisitantesCadastrados = true;
    });

    try {
      final visitantes = await _historicoAcessoService.getVisitantesCadastrados(
        widget.condominioId!,
      );

      setState(() {
        _visitantesCadastrados = visitantes;
      });
    } catch (e) {
      print('❌ ERRO ao carregar visitantes cadastrados: $e');
    } finally {
      setState(() {
        _isLoadingVisitantesCadastrados = false;
      });
    }
  }

  void _pesquisarVisitantesCadastrados(String termo) async {
    if (widget.condominioId == null) return;

    setState(() {
      _isLoadingVisitantesCadastrados = true;
    });

    try {
      final visitantes = await _historicoAcessoService.getVisitantesCadastrados(
        widget.condominioId!,
        filtroNome: termo.isNotEmpty ? termo : null,
      );

      setState(() {
        _visitantesCadastrados = visitantes;
      });
    } catch (e) {
      print('❌ ERRO ao pesquisar visitantes cadastrados: $e');
    } finally {
      setState(() {
        _isLoadingVisitantesCadastrados = false;
      });
    }
  }

  // Widget da aba Prop/Inq
  Widget _buildPropInqTab() {
    if (_isLoadingPropInq) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1976D2)),
      );
    }

    // Agrupar pessoas por unidade
    Map<String, List<Map<String, dynamic>>> pessoasPorUnidade = {};

    // Adicionar proprietários
    for (var proprietario in _proprietarios) {
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

    // Adicionar inquilinos
    for (var inquilino in _inquilinos) {
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
                Flexible(
                  child: Text(
                    'Proprietários e Inquilinos por Unidade',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${unidadesOrdenadas.length}',
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

          // Lista expandível por unidade
          Expanded(
            child: unidadesOrdenadas.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum proprietário ou inquilino encontrado',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
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
                      List<Map<String, dynamic>> pessoas =
                          pessoasPorUnidade[unidade]!;

                      return _buildUnidadeExpandible(unidade, pessoas);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget para unidade expandível
  Widget _buildUnidadeExpandible(
    String unidade,
    List<Map<String, dynamic>> pessoas,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
          // Avatar - com opção de ampliar ao clicar
          GestureDetector(
            onTap: pessoa['fotoPerfil'] != null && pessoa['fotoPerfil'].isNotEmpty
                ? () => _mostrarFotoAmpliada(pessoa['fotoPerfil'], pessoa['nome'])
                : null,
            child: Container(
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
              child:
                  pessoa['fotoPerfil'] != null && pessoa['fotoPerfil'].isNotEmpty
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
                  : Icon(Icons.person, color: Colors.grey[600], size: 28),
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
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                Icon(pessoa['tipoIcon'], color: Colors.white, size: 14),
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

  // Método para construir a aba de Encomendas
  Widget _buildEncomendasTab() {
    // Verifica se o controller foi inicializado
    if (!mounted) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Sub-TabBar para Encomendas
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _encomendasTabController,
            labelColor: const Color(0xFF2E3A59),
            unselectedLabelColor: const Color(0xFF9E9E9E),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: Color(0xFF1976D2), width: 2.0),
            ),
            tabs: const [
              Tab(text: 'Cadastro'),
              Tab(text: 'Histórico'),
            ],
          ),
        ),

        // Linha de separação
        Container(height: 1, color: const Color(0xFFE0E0E0)),

        // Conteúdo das sub-abas
        Expanded(
          child: TabBarView(
            controller: _encomendasTabController,
            children: [
              _buildCadastroEncomendaTab(),
              _buildHistoricoEncomendaTab(),
            ],
          ),
        ),
      ],
    );
  }

  // Aba Cadastro de Encomenda
  Widget _buildCadastroEncomendaTab() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lista de Unidades
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Cabeçalho da lista
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E3A59),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'UNID/BLOCO ou COND.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 52),
                            child: Text(
                              'P/I',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'NOME',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lista de unidades
                  if (_isLoadingPropInq)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_pessoasUnidade.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Nenhuma pessoa encontrada',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _pessoasUnidade.length,
                      itemBuilder: (context, index) {
                        final pessoa = _pessoasUnidade[index];
                        final isSelected =
                            _pessoaSelecionadaEncomenda?.id == pessoa.id;

                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _pessoaSelecionadaEncomenda = pessoa;
                                  } else {
                                    _pessoaSelecionadaEncomenda = null;
                                  }
                                });
                              },
                              activeColor: const Color(0xFF1976D2),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${pessoa.unidadeNumero}/${pessoa.unidadeBloco}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    pessoa.tipo,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: pessoa.tipo == 'P'
                                          ? Colors.blue
                                          : Colors.green,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    pessoa.nome,
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                if (_pessoaSelecionadaEncomenda?.id ==
                                    pessoa.id) {
                                  _pessoaSelecionadaEncomenda = null;
                                } else {
                                  _pessoaSelecionadaEncomenda = pessoa;
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Seção de anexar imagem
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      // Implementar seleção de imagem
                      final ImagePicker picker = ImagePicker();
                      try {
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,
                          maxWidth: 800,
                          maxHeight: 600,
                          imageQuality: 80,
                        );
                        
                        if (image != null) {
                          setState(() {
                            _imagemEncomenda = File(image.path);
                          });
                        }
                      } catch (e) {
                        print('Erro ao selecionar imagem: $e');
                        // Fallback para galeria se câmera falhar
                        try {
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 800,
                            maxHeight: 600,
                            imageQuality: 80,
                          );
                          
                          if (image != null) {
                            setState(() {
                              _imagemEncomenda = File(image.path);
                            });
                          }
                        } catch (e2) {
                          print('Erro ao selecionar da galeria: $e2');
                        }
                      }
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _imagemEncomenda == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Anexar imagem',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                _imagemEncomenda!,
                                height: 116,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Checkbox para notificar unidade
                  Row(
                    children: [
                      Checkbox(
                        value: _notificarUnidade,
                        onChanged: (bool? value) {
                          setState(() {
                            _notificarUnidade = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF1976D2),
                      ),
                      const Text(
                        'Notificar Unidade',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _pessoaSelecionadaEncomenda != null
                          ? () async {
                              // Salvar encomenda usando o EncomendaService
                              await _salvarEncomenda();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E3A59),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Salvar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para mostrar diálogo de quem recebeu a encomenda
  Future<void> _mostrarDialogoRecebidoPor(Encomenda encomenda) async {
    final TextEditingController recebidoPorController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registrar Recebimento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quem recebeu esta encomenda?'),
                const SizedBox(height: 16),
                TextField(
                  controller: recebidoPorController,
                  decoration: const InputDecoration(
                    labelText: 'Nome de quem recebeu',
                    hintText: 'Ex: João Silva',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                final recebidoPor = recebidoPorController.text.trim();
                if (recebidoPor.isNotEmpty) {
                  Navigator.of(context).pop();
                  _marcarEncomendaComoRecebida(encomenda, recebidoPor);
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  // Método para marcar encomenda como recebida
  Future<void> _marcarEncomendaComoRecebida(Encomenda encomenda, String recebidoPor) async {
    try {
      await _encomendaService.marcarComoRecebida(
        encomenda.id,
        recebidoPor: recebidoPor,
      );
      
      // Recarregar o histórico
      await _carregarHistoricoEncomendas();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Encomenda marcada como recebida!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao marcar encomenda: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método para desmarcar encomenda como recebida
  Future<void> _desmarcarEncomendaComoRecebida(Encomenda encomenda) async {
    try {
      await _encomendaService.marcarComoPendente(encomenda.id);
      
      // Recarregar o histórico
      await _carregarHistoricoEncomendas();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Encomenda desmarcada como recebida!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao desmarcar encomenda: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método para carregar histórico de encomendas
  Future<void> _carregarHistoricoEncomendas() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingHistoricoEncomendas = true;
      _errorHistoricoEncomendas = null;
    });

    try {
      final encomendas = await _encomendaService.listarEncomendasComNomes(
        condominioId: widget.condominioId!,
      );
      
      if (mounted) {
        setState(() {
          _historicoEncomendas = encomendas;
          _isLoadingHistoricoEncomendas = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorHistoricoEncomendas = 'Erro ao carregar histórico: $e';
          _isLoadingHistoricoEncomendas = false;
        });
      }
    }
  }

  // Aba Recebimento de Encomenda (placeholder)
  // Aba Histórico de Encomenda (placeholder)
  // Widget para exibir card de encomenda no histórico
  Widget _buildEncomendaCard(Map<String, dynamic> encomendaData) {
    // Converte os dados para objeto Encomenda para manter compatibilidade
    final encomenda = Encomenda.fromJson(encomendaData);
    final String nomeDestinatario = encomendaData['nome_destinatario'] ?? 'N/A';
    
    final bool isRecebida = encomenda.recebido;
    final String statusText = isRecebida ? 'RECEBIDA' : 'PENDENTE';
    final Color statusColor = isRecebida ? Colors.green : Colors.orange;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do card
            Row(
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // Checkbox para marcar/desmarcar como recebida
                Checkbox(
                  value: isRecebida,
                  onChanged: (bool? value) {
                    if (value == true && !isRecebida) {
                      // Marcar como recebida - mostrar diálogo
                      _mostrarDialogoRecebidoPor(encomenda);
                    } else if (value == false && isRecebida) {
                      // Desmarcar como recebida
                      _desmarcarEncomendaComoRecebida(encomenda);
                    }
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Informações do destinatário
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Destinatário: $nomeDestinatario',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Data de cadastro
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Cadastrada em: ${_formatarData(encomenda.createdAt)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            
            // Data de recebimento (se recebida)
            if (isRecebida && encomenda.dataRecebimento != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Recebida em: ${_formatarData(encomenda.dataRecebimento!)}',
                    style: const TextStyle(fontSize: 14, color: Colors.green),
                  ),
                ],
              ),
            ],
            
            // Quem recebeu (se disponível)
            if (isRecebida && encomenda.recebidoPor != null && encomenda.recebidoPor!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recebida por: ${encomenda.recebidoPor}',
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
            
            // Foto da encomenda (se disponível)
            if (encomenda.fotoUrl != null && encomenda.fotoUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    encomenda.fotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Método auxiliar para formatar data
  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildHistoricoEncomendaTab() {
    if (_isLoadingHistoricoEncomendas) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1976D2)),
      );
    }

    if (_errorHistoricoEncomendas != null) {
      return Container(
        color: const Color(0xFFF5F5F5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar histórico',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3A59),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorHistoricoEncomendas!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarHistoricoEncomendas,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_historicoEncomendas.isEmpty) {
      return Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nenhuma encomenda encontrada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3A59),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Não há encomendas cadastradas neste condomínio',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Cabeçalho
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Histórico de Encomendas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _carregarHistoricoEncomendas,
                ),
              ],
            ),
          ),
          // Lista de encomendas
          Expanded(
            child: RefreshIndicator(
              onRefresh: _carregarHistoricoEncomendas,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _historicoEncomendas.length,
                itemBuilder: (context, index) {
                  final encomenda = _historicoEncomendas[index];
                  return _buildEncomendaCard(encomenda);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }



  // Widget da aba Autorizados
  Widget _buildAutorizadosTab() {
    if (_isLoadingAutorizados) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1976D2)),
      );
    }

    if (_autorizadosPorUnidade.isEmpty) {
      return Container(
        color: Colors.grey[50],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_disabled, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nenhum autorizado encontrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2E3A59),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Não há autorizados cadastrados neste condomínio',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Ordenar as chaves das unidades
    List<String> unidadesOrdenadas = _autorizadosPorUnidade.keys.toList()
      ..sort();

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
                const Icon(Icons.verified_user, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Autorizados por Unidade',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${unidadesOrdenadas.length} ${unidadesOrdenadas.length == 1 ? 'unidade' : 'unidades'}',
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

          // Lista de unidades
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: unidadesOrdenadas.length,
              itemBuilder: (context, index) {
                String unidade = unidadesOrdenadas[index];
                List<Map<String, dynamic>> autorizados =
                    _autorizadosPorUnidade[unidade]!;
                return _buildUnidadeAutorizadosExpandible(unidade, autorizados);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget para unidade expansível com autorizados
  Widget _buildUnidadeAutorizadosExpandible(
    String unidade,
    List<Map<String, dynamic>> autorizados,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3A59),
          ),
        ),
        subtitle: Text(
          '${autorizados.length} ${autorizados.length == 1 ? 'autorizado' : 'autorizados'}',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${autorizados.length}',
            style: const TextStyle(
              color: Color(0xFF1976D2),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: autorizados
            .map((autorizado) => _buildAutorizadoCard(autorizado))
            .toList(),
      ),
    );
  }

  // Widget para card de autorizado
  Widget _buildAutorizadoCard(Map<String, dynamic> autorizado) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha principal com nome e CPF
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1976D2).withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF1976D2),
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              // Informações principais
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome do autorizado
                    Text(
                      autorizado['nome'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E3A59),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // CPF (3 primeiros dígitos)
                    if (autorizado['cpfTresPrimeiros'].isNotEmpty)
                      Text(
                        'CPF: ${autorizado['cpfTresPrimeiros']}***',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Informações adicionais
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do criador (inquilino/proprietário)
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Criado por:',
                  value: autorizado['nomeCriador'],
                ),

                const SizedBox(height: 8),

                // Dias e horários
                _buildInfoRow(
                  icon: Icons.schedule,
                  label: 'Acesso:',
                  value: autorizado['diasHorarios'],
                ),

                // Parentesco (se houver)
                if (autorizado['parentesco'] != null &&
                    autorizado['parentesco'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.family_restroom,
                    label: 'Parentesco:',
                    value: autorizado['parentesco'],
                  ),
                ],

                // Veículo (se houver)
                if (autorizado['veiculo'] != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.directions_car,
                    label: 'Veículo:',
                    value: autorizado['veiculo'],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para linha de informação
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2E3A59)),
          ),
        ),
      ],
    );
  }

  Widget _buildAcessosTab() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Barra de pesquisa e botões principais
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Column(
              children: [
                // Campo de pesquisa
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Pesquisar CPF ou Nome do Visitante',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Botões principais
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showAdicionarVisitanteDialog();
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Adicionar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showEntrarVisitanteDialog();
                        },
                        icon: const Icon(Icons.login, color: Colors.white),
                        label: const Text(
                          'Entrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de acessos ativos
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: Column(
                children: [
                  // Tabela com cabeçalho e conteúdo sincronizados
                  Expanded(
                    child: _isLoadingAcessos
                        ? const Center(child: CircularProgressIndicator())
                        : _visitantesNoCondominio.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum visitante no condomínio no momento',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width:
                                  800, // Largura mínima para garantir espaço adequado
                              child: Column(
                                children: [
                                  // Cabeçalho da tabela
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1976D2),
                                    ),
                                    child: Row(
                                      children: const [
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            'NOME',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            'BL/UNID',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            'ENTRADA',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            'HORA',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Text(
                                            'PLACA',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            'FOTO',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            'SAÍDA',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Lista de acessos
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _visitantesNoCondominio.length,
                                      itemBuilder: (context, index) {
                                        final visitante =
                                            _visitantesNoCondominio[index];
                                        final unidadeInfo =
                                            visitante['unidades'] != null
                                            ? '${visitante['unidades']['bloco'] ?? ''}/${visitante['unidades']['numero'] ?? ''}'
                                            : 'N/A';

                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey[300]!,
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 200,
                                                child: Text(
                                                  visitante['nome'] ??
                                                      'Nome não informado',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF2E3A59),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Text(
                                                  unidadeInfo,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF2E3A59),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: Text(
                                                  visitante['hora_entrada_real'] !=
                                                          null
                                                      ? _formatarData(
                                                          visitante['hora_entrada_real'],
                                                        )
                                                      : 'N/A',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF2E3A59),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Text(
                                                  visitante['hora_entrada_real'] !=
                                                          null
                                                      ? _formatarHora(
                                                          visitante['hora_entrada_real'],
                                                        )
                                                      : 'N/A',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF2E3A59),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: Text(
                                                  visitante['veiculo_placa'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF2E3A59),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 80,
                                                child: Text(
                                                  '',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF2E3A59),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _registrarSaida(visitante);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF1976D2),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    minimumSize: const Size(
                                                      60,
                                                      30,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'SAIR',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdicionarVisitanteDialog() {
    // Navegar automaticamente para a aba "Adicionar" (índice 1)
    _tabController.animateTo(1);
  }

  void _showEntrarVisitanteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Registrar Entrada',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3A59),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Abas de seleção
                DefaultTabController(
                  length: 2,
                  child: Expanded(
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: const Color(0xFF1976D2),
                          unselectedLabelColor: Colors.grey[600],
                          indicatorColor: const Color(0xFF1976D2),
                          tabs: const [
                            Tab(text: 'Autorizados'),
                            Tab(text: 'Visitantes Cadastrados'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildAutorizadosSelectionTab(),
                              _buildVisitantesCadastradosTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _registrarSaida(Map<String, dynamic> visitante) async {
    try {
      // Mostrar dialog de confirmação com campos para observações
      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (context) => _buildSaidaDialog(visitante),
      );

      if (result != null) {
        setState(() {
          _isLoadingAcessos = true;
        });

        // Registrar saída no histórico
        await _historicoAcessoService.registrarSaida(
          visitanteId:
              visitante['visitante_id'], // Usar visitante_id em vez de id
          condominioId: widget.condominioId!,
          observacoes: result['observacoes'],
          registradoPor: 'Portaria',
        );

        // Recarregar lista de visitantes no condomínio
        await _carregarVisitantesNoCondominio();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saída registrada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingAcessos = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar saída: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSaidaDialog(Map<String, dynamic> visitante) {
    final observacoesController = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Confirmar Saída',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A59),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informações do visitante
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nome: ${visitante['nome'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unidade: ${visitante['unidades'] != null ? '${visitante['unidades']['bloco']}/${visitante['unidades']['numero']}' : 'N/A'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Entrada: ${visitante['hora_entrada_real'] != null ? DateTime.parse(visitante['hora_entrada_real']).toLocal().toString().substring(0, 16) : 'N/A'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (visitante['veiculo_placa'] != null &&
                      visitante['veiculo_placa'].isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Placa: ${visitante['veiculo_placa']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Campo de observações
            const Text(
              'Observações (opcional):',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E3A59),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: observacoesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Digite observações sobre a saída...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 24),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop({'observacoes': observacoesController.text.trim()});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirmar Saída',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutorizadosSelectionTab() {
    return Column(
      children: [
        // Campo de pesquisa
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Pesquisar autorizado...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Lista de autorizados
        Expanded(
          child: _isLoadingAutorizados
              ? const Center(child: CircularProgressIndicator())
              : _autorizadosPorUnidade.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum autorizado encontrado',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _autorizadosPorUnidade.length,
                  itemBuilder: (context, index) {
                    String unidade = _autorizadosPorUnidade.keys.elementAt(
                      index,
                    );
                    List<Map<String, dynamic>> autorizados =
                        _autorizadosPorUnidade[unidade]!;

                    return ExpansionTile(
                      title: Text(
                        unidade,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3A59),
                        ),
                      ),
                      children: autorizados.map((autorizado) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1976D2),
                            child: Text(
                              autorizado['nome']
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  'A',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            autorizado['nome'] ?? 'Nome não informado',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Criado por: ${autorizado['criado_por'] ?? 'N/A'}',
                              ),
                              Text(
                                'Dias permitidos: ${autorizado['dias_permitidos'] ?? 'N/A'}',
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showRegistroEntradaDialog(autorizado, unidade);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                            ),
                            child: const Text(
                              'Selecionar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVisitantesCadastradosTab() {
    return Column(
      children: [
        // Campo de pesquisa
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: _pesquisaVisitanteController,
            onChanged: _pesquisarVisitantesCadastrados,
            decoration: InputDecoration(
              hintText: 'Pesquisar visitante cadastrado...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Lista de visitantes cadastrados
        Expanded(
          child: _isLoadingVisitantesCadastrados
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1976D2)),
                )
              : _visitantesCadastrados.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum visitante cadastrado encontrado',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _visitantesCadastrados.length,
                  itemBuilder: (context, index) {
                    final visitante = _visitantesCadastrados[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1976D2),
                          child: Text(
                            visitante['nome']?.substring(0, 1).toUpperCase() ??
                                'V',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(visitante['nome'] ?? 'Nome não informado'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CPF: ${visitante['cpf'] ?? 'N/A'}'),
                            Text('Telefone: ${visitante['celular'] ?? 'N/A'}'),
                            if (visitante['unidade_numero'] != null)
                              Text(
                                'Unidade: ${visitante['unidade_bloco'] ?? ''}${visitante['unidade_numero']}',
                              ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showRegistroEntradaDialog(
                              visitante,
                              'Visitante Cadastrado',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                          child: const Text(
                            'Selecionar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showRegistroEntradaDialog(Map<String, dynamic> pessoa, String unidade) {
    final TextEditingController placaController = TextEditingController();
    final TextEditingController observacoesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Confirmar Entrada',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3A59),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Informações da pessoa
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nome: ${pessoa['nome'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E3A59),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Unidade: $unidade',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2E3A59),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Data/Hora: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} - ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2E3A59),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Campo de placa
                const Text(
                  'Placa do Veículo (opcional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3A59),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: placaController,
                  decoration: InputDecoration(
                    hintText: 'Ex: ABC-1234',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de observações
                const Text(
                  'Observações (opcional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3A59),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: observacoesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Observações sobre a entrada...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botões
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _confirmarEntrada(
                            pessoa,
                            unidade,
                            placaController.text,
                            observacoesController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Confirmar Entrada',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmarEntrada(
    Map<String, dynamic> pessoa,
    String unidade,
    String placa,
    String observacoes,
  ) async {
    try {
      setState(() {
        _isLoadingAcessos = true;
      });

      // Registrar entrada no histórico
      await _historicoAcessoService.registrarEntrada(
        visitanteId: pessoa['id'],
        condominioId: widget.condominioId!,
        placaVeiculo: placa.isNotEmpty ? placa : null,
        observacoes: observacoes.isNotEmpty ? observacoes : null,
        registradoPor: 'Portaria',
      );

      // Recarregar lista de visitantes no condomínio
      await _carregarVisitantesNoCondominio();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entrada registrada para ${pessoa['nome']}'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingAcessos = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar entrada: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método para cadastrar visitante na aba "Adicionar"
  Future<void> _cadastrarVisitante() async {
    // Validar campos obrigatórios
    if (!_validarCamposObrigatorios()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Preparar dados do visitante
      final visitanteData = _prepararDadosVisitante();

      // Inserir no banco de dados
      final visitante = await VisitantePortariaService.insertVisitante(
        visitanteData,
      );

      if (visitante != null) {
        // Sucesso - mostrar mensagem e limpar campos
        _mostrarMensagemSucesso();
        _limparCampos();
      } else {
        _mostrarMensagemErro('Erro ao cadastrar visitante. Tente novamente.');
      }
    } catch (e) {
      print('Erro ao cadastrar visitante: $e');
      _mostrarMensagemErro(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Validar campos obrigatórios
  bool _validarCamposObrigatorios() {
    final nome = _visitanteNomeController.text.trim();
    final cpf = _visitanteCpfCnpjController.text.trim();
    final celular = _visitanteCelularController.text.trim();

    if (nome.isEmpty) {
      _mostrarMensagemErro('Nome é obrigatório');
      return false;
    }

    if (cpf.isEmpty) {
      _mostrarMensagemErro('CPF é obrigatório');
      return false;
    }

    if (celular.isEmpty) {
      _mostrarMensagemErro('Celular é obrigatório');
      return false;
    }

    if (widget.condominioId == null || widget.condominioId!.isEmpty) {
      _mostrarMensagemErro('Condomínio não identificado');
      return false;
    }

    // Validar lógica de negócio baseada no tipo de autorização
    if (_isUnidadeSelecionada) {
      if (_unidadeSelecionadaVisitante == null) {
        _mostrarMensagemErro('Selecione uma unidade');
        return false;
      }
    } else {
      final quemAutorizou = _quemAutorizouController.text.trim();
      if (quemAutorizou.isEmpty) {
        _mostrarMensagemErro(
          'Campo "Quem autorizou" é obrigatório para autorização do condomínio',
        );
        return false;
      }
    }

    return true;
  }

  // Preparar dados do visitante para inserção
  Map<String, dynamic> _prepararDadosVisitante() {
    final now = DateTime.now();

    return {
      'condominio_id': widget.condominioId!,
      'unidade_id': _isUnidadeSelecionada
          ? _unidadeSelecionadaVisitante?.id
          : null,
      'nome': _visitanteNomeController.text.trim(),
      'cpf': VisitantePortariaService.formatarCPF(
        _visitanteCpfCnpjController.text.trim(),
      ),
      'celular': VisitantePortariaService.formatarCelular(
        _visitanteCelularController.text.trim(),
      ),
      'tipo_autorizacao': _isUnidadeSelecionada ? 'unidade' : 'condominio',
      'quem_autorizou': _isUnidadeSelecionada
          ? null
          : _quemAutorizouController.text.trim(),
      'observacoes': _visitanteObsController.text.trim().isEmpty
          ? null
          : _visitanteObsController.text.trim(),
      'data_visita': now.toIso8601String().split('T')[0], // Apenas a data
      'status_visita': 'agendado',
      'veiculo_tipo': _veiculoCarroMotoController.text.trim().isEmpty
          ? null
          : _veiculoCarroMotoController.text.trim(),
      'veiculo_marca': _veiculoMarcaController.text.trim().isEmpty
          ? null
          : _veiculoMarcaController.text.trim(),
      'veiculo_modelo': _veiculoModeloController.text.trim().isEmpty
          ? null
          : _veiculoModeloController.text.trim(),
      'veiculo_cor': _veiculoCorController.text.trim().isEmpty
          ? null
          : _veiculoCorController.text.trim(),
      'veiculo_placa': _veiculoPlacaController.text.trim().isEmpty
          ? null
          : _veiculoPlacaController.text.trim().toUpperCase(),
      'ativo': true,
    };
  }

  // Limpar todos os campos do formulário
  void _limparCampos() {
    _visitanteNomeController.clear();
    _visitanteCpfCnpjController.clear();
    _visitanteEnderecoController.clear();
    _visitanteTelefoneController.clear();
    _visitanteCelularController.clear();
    _visitanteEmailController.clear();
    _visitanteObsController.clear();
    _quemAutorizouController.clear();
    _veiculoCarroMotoController.clear();
    _veiculoMarcaController.clear();
    _veiculoPlacaController.clear();
    _veiculoModeloController.clear();
    _veiculoCorController.clear();

    setState(() {
      _unidadeSelecionadaVisitante = null;
      _isUnidadeSelecionada = true;
    });
  }

  // Mostrar mensagem de sucesso
  void _mostrarMensagemSucesso() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visitante cadastrado com sucesso!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Mostrar mensagem de erro
  void _mostrarMensagemErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Validação de CPF em tempo real
  void _validateCPF(String value) {
    setState(() {
      if (value.isEmpty) {
        _cpfError = null;
      } else if (!Formatters.isValidCPF(value)) {
        _cpfError =
            'CPF inválido. Digite um CPF válido no formato 000.000.000-00';
      } else {
        _cpfError = null;
      }
    });
  }

  // Validação de celular em tempo real
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

  // Validação de email em tempo real
  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = null;
      } else if (!Formatters.isValidEmail(value)) {
        _emailError =
            'Email inválido. Digite um email válido como email@endereco.com';
      } else {
        _emailError = null;
      }
    });
  }

  // Método para filtrar unidades na seção de visitante
  void _filtrarUnidadesVisitante(String query) {
    setState(() {
      if (query.isEmpty) {
        _unidadesFiltradas = List.from(_unidades);
      } else {
        _unidadesFiltradas = _unidades.where((unidade) {
          final numero = unidade.numero.toLowerCase();
          final bloco = unidade.bloco?.toLowerCase() ?? '';
          final searchTerm = query.toLowerCase();

          return numero.contains(searchTerm) || bloco.contains(searchTerm);
        }).toList();
      }
    });
  }

  // Método para formatar hora no padrão HH:MM
  String _formatarHora(String dataHora) {
    try {
      // Parse da string ISO e conversão para horário local
      final dateTime = DateTime.parse(dataHora);
      // Se a data já está em UTC, converte para local, senão usa como está
      final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
      return '${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  // Método para salvar encomenda
  Future<void> _salvarEncomenda() async {
    if (_pessoaSelecionadaEncomenda == null) return;

    // Obter representante atual
    final representanteAtual = await AuthService.getCurrentRepresentante();
    if (representanteAtual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Não foi possível identificar o representante atual'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Criar objeto Encomenda
    final now = DateTime.now();
    
    // Debug: verificar dados da pessoa selecionada
    print('🔍 Debug - Pessoa selecionada:');
    print('  ID: ${_pessoaSelecionadaEncomenda!.id}');
    print('  Tipo: ${_pessoaSelecionadaEncomenda!.tipo}');
    print('  Nome: ${_pessoaSelecionadaEncomenda!.nome}');
    print('  Unidade ID: ${_pessoaSelecionadaEncomenda!.unidadeId}');
    
    // Debug: verificar representante atual
    print('🔍 Debug - Representante atual:');
    print('  ID: ${representanteAtual.id}');
    //print('  Nome: ${representanteAtual.nome}');
    //print('  Email: ${representanteAtual.email}');
    
    // Debug: verificar parâmetros do widget
    print('🔍 Debug - Parâmetros do widget:');
    print('  Condomínio ID: ${widget.condominioId}');
    print('  Representante ID (widget): ${widget.representanteId}');
    
    final proprietarioId = _pessoaSelecionadaEncomenda!.tipo == 'P' 
        ? _pessoaSelecionadaEncomenda!.id 
        : null;
    final inquilinoId = _pessoaSelecionadaEncomenda!.tipo == 'I' 
        ? _pessoaSelecionadaEncomenda!.id 
        : null;
        
    print('  Proprietário ID: $proprietarioId');
    print('  Inquilino ID: $inquilinoId');
    print('  Notificar Unidade: $_notificarUnidade');
    
    try {
      final encomenda = Encomenda(
        id: '', // Será gerado pelo Supabase
        condominioId: widget.condominioId!,
        representanteId: representanteAtual.id, // Usar ID do representante atual
        unidadeId: _pessoaSelecionadaEncomenda!.unidadeId,
        proprietarioId: proprietarioId,
        inquilinoId: inquilinoId,
        notificarUnidade: _notificarUnidade,
        recebido: false,
        dataCadastro: now,
        ativo: true,
        createdAt: now,
        updatedAt: now,
      );
      
      print('✅ Encomenda criada com sucesso!');
      print('🚀 Iniciando salvamento da encomenda...');
      print('📦 Dados da encomenda: ${encomenda.toJson()}');

      // Salvar encomenda (com ou sem foto)
      String? encomendaId;
      if (_imagemEncomenda != null) {
        print('📸 Iniciando upload de foto da encomenda...');
        encomendaId = await _encomendaService.criarEncomendaComFoto(encomenda, _imagemEncomenda);
      } else {
        encomendaId = await _encomendaService.criarEncomenda(encomenda);
      }

      if (encomendaId.isNotEmpty) {
        print('✅ Encomenda salva com sucesso! ID: $encomendaId');
        
        // Mostrar mensagem de sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Encomenda cadastrada para ${_pessoaSelecionadaEncomenda!.nome} - ${_pessoaSelecionadaEncomenda!.unidadeNumero}/${_pessoaSelecionadaEncomenda!.unidadeBloco}' +
                    (_notificarUnidade ? ' - Unidade notificada' : ''),
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Limpar seleções
          setState(() {
            _pessoaSelecionadaEncomenda = null;
            _imagemEncomenda = null;
            _notificarUnidade = false;
          });
        }
      } else {
        throw Exception('Falha ao salvar encomenda - retorno nulo');
      }
    } catch (e) {
      print('❌ Erro ao salvar encomenda: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar encomenda: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Mostra a foto ampliada em um diálogo
  void _mostrarFotoAmpliada(String fotoUrl, String nome) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabeçalho com nome
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF1976D2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Foto ampliada
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 500,
                  ),
                  child: Image.network(
                    fotoUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Erro ao carregar a foto',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

