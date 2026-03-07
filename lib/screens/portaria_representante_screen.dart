import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_screen.dart';
import 'conversas_simples_screen.dart';
import '../models/proprietario.dart';
import '../models/porteiro.dart';
import '../models/inquilino.dart';
import '../models/unidade.dart';
import '../models/encomenda.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../services/autorizado_inquilino_service.dart';
import '../services/visitante_portaria_service.dart';
import '../services/historico_acesso_service.dart';
import '../services/encomenda_service.dart';
import '../services/photo_picker_service.dart';
import '../services/qr_code_generation_service.dart';
import '../utils/formatters.dart';
import '../widgets/qr_code_display_widget.dart';

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
  final bool temBlocos;

  const PortariaRepresentanteScreen({
    super.key,
    this.condominioId,
    this.condominioNome,
    this.condominioCnpj,
    this.representanteId,
    this.temBlocos = true,
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
  XFile? _fotoVisitante; // Usar XFile em vez de File para compatibilidade web

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
  List<Map<String, dynamic>> _visitantesNoCondominioFiltrados = [];
  bool _isLoadingAcessos = false;

  // Variáveis para visitantes cadastrados
  List<Map<String, dynamic>> _visitantesCadastrados = [];
  bool _isLoadingVisitantesCadastrados = false;
  final TextEditingController _pesquisaVisitanteController =
      TextEditingController();
  final TextEditingController _searchAcessosController =
      TextEditingController();

  // Variáveis para a seção de Encomendas
  // Variável para encomenda selecionada (removendo a antiga)
  // Unidade? _unidadeSelecionadaEncomenda;
  XFile? _imagemEncomenda; // Usar XFile em vez de File para compatibilidade web
  bool _notificarUnidade = false;

  // Variáveis para o histórico de encomendas
  List<Map<String, dynamic>> _historicoEncomendas = [];
  bool _isLoadingHistoricoEncomendas = false;
  String? _errorHistoricoEncomendas;

  // Variável para armazenar dados do representante atual
  dynamic _representanteAtual;
  bool _isLoadingRepresentante = true;

  // Variável para armazenar temBlocos do condomínio
  bool _temBlocos = true;

  @override
  void initState() {
    super.initState();
    debugPrint('═' * 80);
    debugPrint('🔵 [PORTARIA] ═══ INIT STATE ═══');
    debugPrint('═' * 80);
    debugPrint('[PORTARIA] ⚡ initState() CHAMADO');
    debugPrint(
      '[PORTARIA] widget.temBlocos (parâmetro recebido): ${widget.temBlocos}',
    );
    debugPrint(
      '[PORTARIA] Tipo de widget.temBlocos: ${widget.temBlocos.runtimeType}',
    );

    _tabController = TabController(length: 6, vsync: this);
    _encomendasTabController = TabController(length: 2, vsync: this);

    // Carregar temBlocos do parâmetro ou do banco de dados
    debugPrint('[PORTARIA] Definindo _temBlocos = widget.temBlocos');
    _temBlocos = widget.temBlocos;
    debugPrint('[PORTARIA] _temBlocos APÓS atribuição: $_temBlocos');
    debugPrint('[PORTARIA] Chamando _carregarTemBlocos()...');

    _carregarTemBlocos();
    debugPrint('[PORTARIA] _carregarTemBlocos() retornou');
    debugPrint('[PORTARIA] _temBlocos APÓS _carregarTemBlocos(): $_temBlocos');
    debugPrint('═' * 80);

    debugPrint(
      '[PORTARIA] _temBlocos DEPOIS de _carregarTemBlocos: $_temBlocos',
    );
    debugPrint('[PORTARIA] Iniciando carregamento de dados...');
    debugPrint('═' * 80);

    _carregarRepresentanteAtual();
    _carregarDadosPropInq();
    _carregarAutorizados();
    _carregarVisitantesNoCondominio();
    _carregarVisitantesCadastrados();
    _carregarHistoricoEncomendas();

    // ✅ Corrigir URLs duplicadas ao carregar a tela
    _corrigirURLsQRCode();
  }

  /// Corrige URLs duplicadas do QR Code no banco de dados
  void _corrigirURLsQRCode() {
    QrCodeGenerationService.corrigirURLsDuplicadas();
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
    _searchAcessosController.dispose();

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
                  // Botão de voltar ou Sair
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 24),
                    onPressed: () async {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        // Se não tem para onde voltar, é provável que seja logout (Porteiro)
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Sair'),
                            content: const Text('Deseja sair do aplicativo?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Não'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Sim'),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true) {
                          await AuthService().logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      }
                    },
                  ),
                  const Spacer(),
                  // Logo CondoGaia
                  Flexible(
                    child: Image.asset(
                      'assets/images/logo_CondoGaia.png',
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(),
                  // Ícones do lado direito
                  Row(
                    children: [
                      // Botão de Recarregar (Refresh)
                      GestureDetector(
                        onTap: () {
                          _refreshCurrentTab();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.refresh,
                            color: Color(0xFF1976D2),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

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

  // Método para recarregar a aba atual
  Future<void> _refreshCurrentTab() async {
    setState(() {
      _isLoading = true;
      _isLoadingAcessos = true;
      _isLoadingAutorizados = true;
      _isLoadingHistoricoEncomendas = true;
    });

    try {
      final index = _tabController.index;

      if (index == 0) {
        // Acessos
        await _carregarVisitantesNoCondominio();
        await _carregarVisitantesCadastrados();
      } else if (index == 1) {
        // Adicionar
        // Nada a recarregar especificamente, talvez limpar campos
      } else if (index == 2) {
        // Autorizados
        await _carregarAutorizados();
      } else if (index == 3) {
        // Mensagem
        // Recarregar mensagens
      } else if (index == 4) {
        // Prop/Inq
        await _carregarDadosPropInq();
      } else if (index == 5) {
        // Encomendas
        await _carregarHistoricoEncomendas();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados atualizados com sucesso!'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingAcessos = false;
          _isLoadingAutorizados = false;
          _isLoadingHistoricoEncomendas = false;
        });
      }
    }
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
                        // onChanged: _validateEmail, // Removido validação obrigatória
                        // errorText: _emailError,    // Removido erro obrigatório
                        keyboardType: TextInputType.emailAddress,
                        isRequired: false, // Alterado para opcional
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

                      // Seção Foto do Visitante
                      _buildSectionTitle('Foto do Visitante'),
                      const SizedBox(height: 12),

                      // Widget para selecionar/capturar foto
                      GestureDetector(
                        onTap: _mostrarDialogSelecaoFotoVisitante,
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4A90E2),
                              width: 2,
                            ),
                          ),
                          child: _fotoVisitante == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 48,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Toque para tirar foto',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '(ou selecionar da galeria)',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
                              : Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: kIsWeb
                                          ? Image.network(
                                              _fotoVisitante!.path,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(_fotoVisitante!.path),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _fotoVisitante = null;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
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
                                        _temBlocos &&
                                                unidade.bloco != null &&
                                                unidade.bloco!.isNotEmpty
                                            ? '${unidade.bloco}/${unidade.numero}'
                                            : unidade.numero,
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

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A59),
            ),
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
  // Carregar temBlocos do condomínio
  void _carregarTemBlocos() {
    debugPrint('═' * 80);
    debugPrint('🔵 [PORTARIA] ═══ MÉTODO _carregarTemBlocos() ═══');
    debugPrint('═' * 80);
    debugPrint('[PORTARIA] ⚡ _carregarTemBlocos() CHAMADO');
    debugPrint('[PORTARIA] widget.temBlocos recebido: ${widget.temBlocos}');
    debugPrint('[PORTARIA] widget.condominioId: ${widget.condominioId}');
    debugPrint('[PORTARIA] _temBlocos ANTES: $_temBlocos');

    // Sempre usar o valor passado pelo widget (que foi carregado em gestao_screen)
    _temBlocos = widget.temBlocos;
    debugPrint('[PORTARIA] ✓ _temBlocos APÓS atribuição: $_temBlocos');
    debugPrint(
      '[PORTARIA] Este valor veio de: gestao_screen.dart (_carregarTemBlocosDoCondominio)',
    );
    debugPrint('═' * 80);
  }

  /// Helper para formatar unidade respeitando _temBlocos
  /// Se temBlocos=true e tem bloco: "A 101" ou "Bloco A - 101"
  /// Se temBlocos=false: apenas "101"
  String _formatarUnidade({
    String? bloco,
    String? numero,
    bool incluirPrefixo = true,
  }) {
    final blocoStr = (bloco?.isNotEmpty ?? false) ? bloco : null;
    final numeroStr = numero ?? '';

    if (_temBlocos && blocoStr != null) {
      // Com blocos: "A 101"
      return incluirPrefixo
          ? 'Unidade $blocoStr $numeroStr'
          : '$blocoStr $numeroStr';
    } else {
      // Sem blocos: apenas "101"
      return incluirPrefixo ? 'Unidade $numeroStr' : numeroStr;
    }
  }

  /// Helper para formatar chave de unidade (formato "A/101" ou "101")
  /// Retorna a unidade formatada respeitando _temBlocos
  String _formatarChaveUnidade(String chaveUnidade) {
    if (chaveUnidade.contains('/')) {
      final partes = chaveUnidade.split('/');
      final bloco = partes[0];
      final numero = partes[1];
      return _formatarUnidade(
        bloco: bloco,
        numero: numero,
        incluirPrefixo: false,
      );
    } else {
      // Sem barra: apenas número
      return chaveUnidade;
    }
  }

  Future<void> _carregarRepresentanteAtual() async {
    debugPrint('═' * 80);
    debugPrint('🟦 [PORTARIA_REP] ═══ CARREGANDO USUÁRIO ATUAL ═══');
    debugPrint('═' * 80);

    try {
      debugPrint(
        '🔄 [PORTARIA_REP] Chamando AuthService.getCurrentRepresentante()...',
      );
      // Tentar carregar representante
      var representante = await AuthService.getCurrentRepresentante();

      // Se não for representante, tentar carregar porteiro
      if (representante == null) {
        debugPrint(
          '🔄 [PORTARIA_REP] Representante NULL, tentando AuthService.getCurrentPorteiro()...',
        );
        final porteiro = await AuthService.getCurrentPorteiro();
        if (porteiro != null) {
          debugPrint('[PORTARIA_REP] OK: Porteiro obtido com sucesso');
          debugPrint('[PORTARIA_REP] ID: ${porteiro.id}');
          debugPrint('[PORTARIA_REP] Nome: ${porteiro.nomeCompleto}');

          setState(() {
            _representanteAtual = porteiro; // Usando a mesma variável dinâmica
            _isLoadingRepresentante = false;
          });
          return;
        }
      }

      if (representante == null) {
        debugPrint(
          '[PORTARIA_REP] ERROR: AuthService retornou NULL para Rep e Porteiro',
        );
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

      debugPrint('[PORTARIA_REP] OK: Estado atualizado com usuário');
    } catch (e, stackTrace) {
      debugPrint('[PORTARIA_REP] ERROR: ao carregar usuário!');
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
    debugPrint(
      '[PORTARIA_REP] _isLoadingRepresentante: $_isLoadingRepresentante',
    );
    debugPrint('[PORTARIA_REP] _representanteAtual: $_representanteAtual');

    // Se ainda está carregando o representante, mostra loading
    if (_isLoadingRepresentante) {
      debugPrint('[PORTARIA_REP] Ainda está carregando representante...');
      return const Center(child: CircularProgressIndicator());
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
      temBlocos: _temBlocos,
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
        String chaveA = _temBlocos && a.unidadeBloco != 'N/A'
            ? '${a.unidadeNumero}/${a.unidadeBloco}'
            : a.unidadeNumero;
        String chaveB = _temBlocos && b.unidadeBloco != 'N/A'
            ? '${b.unidadeNumero}/${b.unidadeBloco}'
            : b.unidadeNumero;

        final unidadeComparison = chaveA.compareTo(chaveB);
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
      _filtrarAcessos(_searchAcessosController.text);
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

      String chaveUnidade =
          _temBlocos && unidade.bloco != null && unidade.bloco!.isNotEmpty
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

      String chaveUnidade =
          _temBlocos && unidade.bloco != null && unidade.bloco!.isNotEmpty
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
        title: Builder(
          builder: (context) {
            // Se temBlocos = true e tem '/', formata como "Unidade Bloco A - 101"
            // Se temBlocos = false, extrai apenas o número (depois da '/')
            final bool temBlocosCheck = _temBlocos && unidade.contains('/');

            String label;
            if (temBlocosCheck) {
              // Com blocos: "A/101" → "Unidade Bloco A - 101"
              label = 'Unidade Bloco ${unidade.replaceAll('/', ' - ')}';
            } else if (unidade.contains('/')) {
              // Sem blocos mas a unidade tem formato "A/101": extrai apenas "101"
              final partes = unidade.split('/');
              label = 'Unidade ${partes[1]}';
            } else {
              // Sem blocos e sem '/': mostra como está (já é apenas número)
              label = 'Unidade $unidade';
            }

            debugPrint(
              '[PORTARIA] _buildUnidadeExpandible() - Label formatting:',
            );
            debugPrint('[PORTARIA]   - unidade: $unidade');
            debugPrint('[PORTARIA]   - _temBlocos: $_temBlocos');
            debugPrint(
              '[PORTARIA]   - unidade.contains("/"): ${unidade.contains("/")}',
            );
            debugPrint('[PORTARIA]   - temBlocosCheck: $temBlocosCheck');
            debugPrint('[PORTARIA]   - label final: $label');

            return Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF2E3A59),
              ),
            );
          },
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
            onTap:
                pessoa['fotoPerfil'] != null && pessoa['fotoPerfil'].isNotEmpty
                ? () =>
                      _mostrarFotoAmpliada(pessoa['fotoPerfil'], pessoa['nome'])
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
                  pessoa['fotoPerfil'] != null &&
                      pessoa['fotoPerfil'].isNotEmpty
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
                                    _temBlocos && pessoa.unidadeBloco != 'N/A'
                                        ? '${pessoa.unidadeNumero}/${pessoa.unidadeBloco}'
                                        : pessoa.unidadeNumero,
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
                      // Mostrar diálogo com opções de câmera ou galeria
                      final ImageSource? source = await showDialog<ImageSource>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Selecionar Imagem'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text('Câmera'),
                                  onTap: () => Navigator.pop(
                                    context,
                                    ImageSource.camera,
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Galeria'),
                                  onTap: () => Navigator.pop(
                                    context,
                                    ImageSource.gallery,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );

                      if (source != null) {
                        final photoPickerService = PhotoPickerService();
                        try {
                          final XFile? image = source == ImageSource.camera
                              ? await photoPickerService.pickImageFromCamera()
                              : await photoPickerService.pickImage();

                          if (image != null) {
                            setState(() {
                              _imagemEncomenda = image;
                            });
                          }
                        } catch (e) {
                          print('Erro ao selecionar imagem: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao selecionar imagem: $e'),
                              ),
                            );
                          }
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
                              child: kIsWeb
                                  ? Image.network(
                                      _imagemEncomenda!.path,
                                      height: 116,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              height: 116,
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(Icons.broken_image),
                                              ),
                                            );
                                          },
                                    )
                                  : Image.file(
                                      File(_imagemEncomenda!.path),
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
  Future<void> _marcarEncomendaComoRecebida(
    Encomenda encomenda,
    String recebidoPor,
  ) async {
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
    final String registradoPor = encomendaData['registrado_por'] ?? 'Sistema';

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
            if (isRecebida &&
                encomenda.recebidoPor != null &&
                encomenda.recebidoPor!.isNotEmpty) ...[
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
              GestureDetector(
                onTap: () {
                  _mostrarFotoAmpliada(encomenda.fotoUrl!, 'Encomenda');
                },
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          encomenda.fotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Ícone de ampliar no canto inferior direito
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Quem registrou (Registrado por)
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.edit_note, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Registrado por: $registradoPor',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método auxiliar para formatar data com horário local
  String _formatarData(dynamic data) {
    try {
      // Converter para DateTime se for String
      DateTime dateTime = data is String
          ? DateTime.parse(data)
          : data as DateTime;

      // Usar o horário como está (sem conversão)
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
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
            decoration: const BoxDecoration(color: Color(0xFF1976D2)),
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
        title: Builder(
          builder: (context) {
            // Se temBlocos = true e tem '/', formata como "Unidade Bloco A - 101"
            // Se temBlocos = false, extrai apenas o número (depois da '/')
            final bool temBlocosCheck = _temBlocos && unidade.contains('/');

            String label;
            if (temBlocosCheck) {
              // Com blocos: "A/101" → "Unidade Bloco A - 101"
              label = 'Unidade Bloco ${unidade.replaceAll('/', ' - ')}';
            } else if (unidade.contains('/')) {
              // Sem blocos mas a unidade tem formato "A/101": extrai apenas "101"
              final partes = unidade.split('/');
              label = 'Unidade ${partes[1]}';
            } else {
              // Sem blocos e sem '/': mostra como está (já é apenas número)
              label = 'Unidade $unidade';
            }

            debugPrint(
              '[PORTARIA] _buildUnidadeAutorizadosExpandible() - Label formatting:',
            );
            debugPrint('[PORTARIA]   - unidade: $unidade');
            debugPrint('[PORTARIA]   - _temBlocos: $_temBlocos');
            debugPrint(
              '[PORTARIA]   - unidade.contains("/"): ${unidade.contains("/")}',
            );
            debugPrint('[PORTARIA]   - temBlocosCheck: $temBlocosCheck');
            debugPrint('[PORTARIA]   - label final: $label');

            return Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E3A59),
              ),
            );
          },
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
    final String fotoUrl = autorizado['foto_url'] ?? '';
    final String qrCodeUrl = autorizado['qr_code_url'] ?? '';
    final bool temFoto = fotoUrl.isNotEmpty;

    return Column(
      children: [
        Container(
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
                  // Avatar com foto ou ícone
                  GestureDetector(
                    onTap: temFoto
                        ? () => _mostrarFotoAmpliada(
                            fotoUrl,
                            autorizado['nome'] ?? 'Autorizado',
                          )
                        : null,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1976D2).withOpacity(0.1),
                        border: temFoto
                            ? Border.all(
                                color: const Color(0xFF1976D2),
                                width: 2,
                              )
                            : null,
                      ),
                      child: temFoto
                          ? ClipOval(
                              child: Image.network(
                                fotoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.person,
                                      color: Color(0xFF1976D2),
                                      size: 28,
                                    ),
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: Color(0xFF1976D2),
                              size: 28,
                            ),
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
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
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
        ),
        // 🆕 QR Code Display Widget integrado dentro do card
        const SizedBox(height: 16),
        if (qrCodeUrl.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: QrCodeDisplayWidget(
              qrCodeUrl: qrCodeUrl,
              visitanteNome: autorizado['nome'] ?? 'Autorizado',
              visitanteCpf: autorizado['cpf'] ?? '',
              unidade: autorizado['unidade'] ?? '',
            ),
          ),
        const SizedBox(height: 24),
      ],
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

  void _filtrarAcessos(String query) {
    if (query.isEmpty) {
      setState(() {
        _visitantesNoCondominioFiltrados = List.from(_visitantesNoCondominio);
      });
      return;
    }

    final termo = query.toLowerCase();
    setState(() {
      _visitantesNoCondominioFiltrados = _visitantesNoCondominio.where((vis) {
        final nome = (vis['nome'] ?? '').toString().toLowerCase();
        final cpf = (vis['cpf'] ?? vis['documento'] ?? '')
            .toString()
            .toLowerCase();
        final placa = (vis['veiculo_placa'] ?? '').toString().toLowerCase();

        return nome.contains(termo) ||
            cpf.contains(termo) ||
            placa.contains(termo);
      }).toList();
    });
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
                    controller: _searchAcessosController,
                    onChanged: _filtrarAcessos,
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
                        : _visitantesNoCondominioFiltrados.isEmpty
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
                                  1000, // Largura aumentada para melhor espaçamento
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
                                      children: [
                                        SizedBox(
                                          width: 220,
                                          child: Center(
                                            child: Text(
                                              'NOME',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: Center(
                                            child: Text(
                                              'BL/UNID',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 200,
                                          child: Center(
                                            child: Text(
                                              'ENTRADA',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 140,
                                          child: Center(
                                            child: Text(
                                              'PLACA',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: Center(
                                            child: Text(
                                              'FOTO',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: Center(
                                            child: Text(
                                              'SAÍDA',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Lista de acessos
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount:
                                          _visitantesNoCondominioFiltrados
                                              .length,
                                      itemBuilder: (context, index) {
                                        final visitante =
                                            _visitantesNoCondominioFiltrados[index];
                                        final unidadeInfo =
                                            visitante['unidades'] != null
                                            ? _formatarUnidade(
                                                bloco:
                                                    visitante['unidades']['bloco'],
                                                numero:
                                                    visitante['unidades']['numero']
                                                        ?.toString(),
                                                incluirPrefixo: false,
                                              )
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
                                                width: 220,
                                                child: Center(
                                                  child: Text(
                                                    visitante['nome'] ??
                                                        'Nome não informado',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF2E3A59),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: Center(
                                                  child: Text(
                                                    unidadeInfo,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF2E3A59),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 200,
                                                child: Center(
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
                                              ),
                                              SizedBox(
                                                width: 140,
                                                child: Center(
                                                  child: Text(
                                                    visitante['veiculo_placa'] ??
                                                        '',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF2E3A59),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Foto do visitante
                                              SizedBox(
                                                width: 120,
                                                child: Center(
                                                  child: GestureDetector(
                                                    onTap:
                                                        visitante['foto_url'] !=
                                                                null &&
                                                            (visitante['foto_url']
                                                                        as String?)
                                                                    ?.isNotEmpty ==
                                                                true
                                                        ? () => _mostrarFotoAmpliada(
                                                            visitante['foto_url']
                                                                as String,
                                                            visitante['nome'] ??
                                                                'Visitante',
                                                          )
                                                        : null,
                                                    child: Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: const Color(
                                                          0xFF4A90E2,
                                                        ).withOpacity(0.1),
                                                        border:
                                                            visitante['foto_url'] !=
                                                                    null &&
                                                                (visitante['foto_url']
                                                                            as String?)
                                                                        ?.isNotEmpty ==
                                                                    true
                                                            ? Border.all(
                                                                color:
                                                                    const Color(
                                                                      0xFF4A90E2,
                                                                    ),
                                                                width: 2,
                                                              )
                                                            : null,
                                                      ),
                                                      child:
                                                          visitante['foto_url'] !=
                                                                  null &&
                                                              (visitante['foto_url']
                                                                          as String?)
                                                                      ?.isNotEmpty ==
                                                                  true
                                                          ? Stack(
                                                              fit: StackFit
                                                                  .expand,
                                                              children: [
                                                                ClipOval(
                                                                  child: Image.network(
                                                                    visitante['foto_url']
                                                                        as String,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    errorBuilder:
                                                                        (
                                                                          context,
                                                                          error,
                                                                          stackTrace,
                                                                        ) {
                                                                          return const Icon(
                                                                            Icons.person,
                                                                            size:
                                                                                24,
                                                                            color: Color(
                                                                              0xFF4A90E2,
                                                                            ),
                                                                          );
                                                                        },
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  bottom: -2,
                                                                  right: -2,
                                                                  child: Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          2,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: const Color(
                                                                        0xFF4A90E2,
                                                                      ),
                                                                      border: Border.all(
                                                                        color: Colors
                                                                            .white,
                                                                        width:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                    child: const Icon(
                                                                      Icons
                                                                          .zoom_in,
                                                                      size: 8,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : const Icon(
                                                              Icons.person,
                                                              size: 24,
                                                              color: Color(
                                                                0xFF4A90E2,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 120,
                                                child: Center(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      _registrarSaida(
                                                        visitante,
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF1976D2,
                                                          ),
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
    final TextEditingController searchAutorizadosController =
        TextEditingController();
    final TextEditingController searchVisitantesController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            // Lógica de filtro para Autorizados
            Map<String, List<Map<String, dynamic>>> autorizadosFiltrados = {};
            String queryAutorizados = searchAutorizadosController.text
                .toLowerCase();

            if (queryAutorizados.isEmpty) {
              autorizadosFiltrados = _autorizadosPorUnidade;
            } else {
              _autorizadosPorUnidade.forEach((unidade, lista) {
                final listaFiltrada = lista.where((a) {
                  final nome = (a['nome'] ?? '').toString().toLowerCase();
                  final cpf = (a['cpf'] ?? '').toString().toLowerCase();
                  final unidadeNorm = unidade.toLowerCase();

                  return nome.contains(queryAutorizados) ||
                      cpf.contains(queryAutorizados) ||
                      unidadeNorm.contains(queryAutorizados);
                }).toList();

                if (listaFiltrada.isNotEmpty) {
                  autorizadosFiltrados[unidade] = listaFiltrada;
                }
              });
            }

            // Lógica de filtro para Visitantes
            List<Map<String, dynamic>> visitantesFiltrados = [];
            String queryVisitantes = searchVisitantesController.text
                .toLowerCase();

            if (queryVisitantes.isEmpty) {
              visitantesFiltrados = _visitantesCadastrados;
            } else {
              visitantesFiltrados = _visitantesCadastrados.where((v) {
                final nome = (v['nome'] ?? '').toString().toLowerCase();
                final cpf = (v['cpf'] ?? '').toString().toLowerCase();
                return nome.contains(queryVisitantes) ||
                    cpf.contains(queryVisitantes);
              }).toList();
            }

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
                                  _buildAutorizadosSelectionTab(
                                    autorizadosFiltrados,
                                    searchAutorizadosController,
                                    (val) => setStateModal(() {}),
                                  ),
                                  _buildVisitantesCadastradosTab(
                                    visitantesFiltrados,
                                    searchVisitantesController,
                                    (val) => setStateModal(() {}),
                                    onUpdate: () => setStateModal(() {}),
                                  ),
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

  Widget _buildAutorizadosSelectionTab(
    Map<String, List<Map<String, dynamic>>> autorizados,
    TextEditingController controller,
    Function(String) onChanged,
  ) {
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
            controller: controller,
            onChanged: onChanged,
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
              : autorizados.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum autorizado encontrado',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: autorizados.length,
                  itemBuilder: (context, index) {
                    String unidade = autorizados.keys.elementAt(index);
                    List<Map<String, dynamic>> listaAutorizados =
                        autorizados[unidade]!;

                    return ExpansionTile(
                      title: Text(
                        'Unidade ${_formatarChaveUnidade(unidade)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3A59),
                        ),
                      ),
                      children: listaAutorizados.map((autorizado) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Primeira linha: Avatar + Nome + Botão
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Avatar
                                    GestureDetector(
                                      onTap:
                                          autorizado['foto_url'] != null &&
                                              (autorizado['foto_url']
                                                          as String?)
                                                      ?.isNotEmpty ==
                                                  true
                                          ? () => _mostrarFotoAmpliada(
                                              autorizado['foto_url'] as String,
                                              autorizado['nome'] ??
                                                  'Autorizado',
                                            )
                                          : null,
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(
                                            0xFF1976D2,
                                          ).withOpacity(0.2),
                                          border:
                                              autorizado['foto_url'] != null &&
                                                  (autorizado['foto_url']
                                                              as String?)
                                                          ?.isNotEmpty ==
                                                      true
                                              ? Border.all(
                                                  color: const Color(
                                                    0xFF1976D2,
                                                  ),
                                                  width: 2,
                                                )
                                              : null,
                                        ),
                                        child:
                                            autorizado['foto_url'] != null &&
                                                (autorizado['foto_url']
                                                            as String?)
                                                        ?.isNotEmpty ==
                                                    true
                                            ? Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  ClipOval(
                                                    child: Image.network(
                                                      autorizado['foto_url']
                                                          as String,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            loadingProgress,
                                                          ) {
                                                            if (loadingProgress ==
                                                                null)
                                                              return child;
                                                            return Container(
                                                              color:
                                                                  const Color(
                                                                    0xFF1976D2,
                                                                  ).withOpacity(
                                                                    0.2,
                                                                  ),
                                                              child: const Center(
                                                                child: SizedBox(
                                                                  width: 20,
                                                                  height: 20,
                                                                  child: CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                    valueColor:
                                                                        AlwaysStoppedAnimation<
                                                                          Color
                                                                        >(
                                                                          Color(
                                                                            0xFF1976D2,
                                                                          ),
                                                                        ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              color:
                                                                  const Color(
                                                                    0xFF1976D2,
                                                                  ).withOpacity(
                                                                    0.2,
                                                                  ),
                                                              child: const Icon(
                                                                Icons.person,
                                                                size: 24,
                                                                color: Color(
                                                                  0xFF1976D2,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Text(
                                                  autorizado['nome']
                                                          ?.substring(0, 1)
                                                          .toUpperCase() ??
                                                      'A',
                                                  style: const TextStyle(
                                                    color: Color(0xFF1976D2),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Nome e Botão
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            autorizado['nome'] ??
                                                'Nome não informado',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: Color(0xFF2E3A59),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Botão Selecionar
                                    SizedBox(
                                      height: 36,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _showRegistroEntradaDialog(
                                            autorizado,
                                            unidade,
                                            tipoVisitante: 'inquilino',
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2E7D32,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                        ),
                                        child: const Text(
                                          'Selecionar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Informações em coluna única
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoLine(
                                      'CPF:',
                                      autorizado['cpf'] ?? 'N/A',
                                    ),
                                    const SizedBox(height: 6),
                                    _buildInfoLine(
                                      'Criado por:',
                                      autorizado['criado_por'] ?? 'N/A',
                                    ),
                                    const SizedBox(height: 6),
                                    _buildInfoLine(
                                      'Dias:',
                                      autorizado['dias_permitidos'] ?? 'N/A',
                                    ),
                                  ],
                                ),
                              ],
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

  void _mostrarDialogEditarVisitante(
    Map<String, dynamic> visitante, {
    VoidCallback? onSuccess,
  }) {
    final nomeController = TextEditingController(text: visitante['nome']);
    final cpfController = TextEditingController(text: visitante['cpf']);
    final celularController = TextEditingController(text: visitante['celular']);
    final placaController = TextEditingController(
      text: visitante['veiculo_placa'],
    );

    showDialog(
      context: context,
      builder: (contextDialog) => AlertDialog(
        title: const Text('Editar Visitante'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cpfController,
                decoration: const InputDecoration(labelText: 'CPF'),
                inputFormatters: [Formatters.cpfFormatter],
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: celularController,
                decoration: const InputDecoration(labelText: 'Celular'),
                inputFormatters: [Formatters.phoneFormatter],
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: placaController,
                decoration: const InputDecoration(labelText: 'Placa Veículo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextDialog),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Validações básicas
                if (nomeController.text.trim().isEmpty ||
                    cpfController.text.trim().isEmpty ||
                    celularController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha os campos obrigatórios!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Mostrar loading
                showDialog(
                  context: contextDialog,
                  barrierDismissible: false,
                  builder: (ctx) =>
                      const Center(child: CircularProgressIndicator()),
                );

                await VisitantePortariaService.updateVisitante(
                  visitante['id'],
                  {
                    'nome': nomeController.text.trim(),
                    'cpf': cpfController.text.trim(),
                    'celular': celularController.text.trim(),
                    'veiculo_placa': placaController.text.trim().isEmpty
                        ? null
                        : placaController.text.trim().toUpperCase(),
                  },
                );

                // Fechar loading e dialog de edição
                if (mounted) {
                  Navigator.of(contextDialog).pop(); // Fecha loading
                  Navigator.of(contextDialog).pop(); // Fecha dialog edição
                }

                // Recarregar lista e mostrar sucesso
                await _carregarVisitantesCadastrados();

                // Chamar callback de sucesso se existir (para atualizar modal)
                if (onSuccess != null) {
                  onSuccess();
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Visitante atualizado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Fechar loading se erro
                Navigator.of(contextDialog).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao atualizar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
            ),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitantesCadastradosTab(
    List<Map<String, dynamic>> visitantes,
    TextEditingController controller,
    Function(String) onChanged, {
    VoidCallback? onUpdate,
  }) {
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
            controller: controller,
            onChanged: onChanged,
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
              : visitantes.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum visitante cadastrado encontrado',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: visitantes.length,
                  itemBuilder: (context, index) {
                    final visitante = visitantes[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: GestureDetector(
                          onTap:
                              visitante['foto_url'] != null &&
                                  (visitante['foto_url'] as String?)
                                          ?.isNotEmpty ==
                                      true
                              ? () => _mostrarFotoAmpliada(
                                  visitante['foto_url'] as String,
                                  visitante['nome'] ?? 'Visitante',
                                )
                              : null,
                          child: CircleAvatar(
                            backgroundColor: const Color(0xFF1976D2),
                            backgroundImage:
                                visitante['foto_url'] != null &&
                                    (visitante['foto_url'] as String?)
                                            ?.isNotEmpty ==
                                        true
                                ? NetworkImage(visitante['foto_url'] as String)
                                : null,
                            child:
                                visitante['foto_url'] != null &&
                                    (visitante['foto_url'] as String?)
                                            ?.isNotEmpty ==
                                        true
                                ? null
                                : Text(
                                    visitante['nome']
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        'V',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                        title: Text(visitante['nome'] ?? 'Nome não informado'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _mostrarDialogEditarVisitante(
                                visitante,
                                onSuccess: onUpdate,
                              ),
                            ),
                            const Icon(Icons.expand_more, color: Colors.grey),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CPF: ${visitante['cpf'] ?? 'N/A'}'),
                            Text('Telefone: ${visitante['celular'] ?? 'N/A'}'),
                            if (visitante['unidade_numero'] != null)
                              Text(
                                _formatarUnidade(
                                  bloco: visitante['unidade_bloco'],
                                  numero: visitante['unidade_numero'],
                                ),
                              ),
                          ],
                        ),
                        children: [
                          // 🆕 QR Code Display Widget
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                QrCodeDisplayWidget(
                                  qrCodeUrl: visitante['qr_code_url'],
                                  visitanteNome:
                                      visitante['nome'] ?? 'Visitante',
                                  visitanteCpf: visitante['cpf'] ?? '',
                                  unidade:
                                      visitante['unidade_numero']?.toString() ??
                                      '',
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _showRegistroEntradaDialog(
                                        visitante,
                                        'Visitante Cadastrado',
                                        tipoVisitante: 'visitante_portaria',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                    ),
                                    child: const Text(
                                      'Selecionar para Entrada',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showRegistroEntradaDialog(
    Map<String, dynamic> pessoa,
    String unidade, {
    String tipoVisitante = 'visitante_portaria',
  }) {
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

                // Foto + Informações da pessoa
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
                      // Foto + Nome e informações em uma linha
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Foto do visitante (pequena)
                          if (pessoa['foto_url'] != null &&
                              (pessoa['foto_url'] as String?)?.isNotEmpty ==
                                  true)
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: () => _mostrarFotoAmpliada(
                                  pessoa['foto_url'] as String,
                                  pessoa['nome'] ?? 'Visitante',
                                ),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF4A90E2),
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipOval(
                                        child: Image.network(
                                          pessoa['foto_url'] as String,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: Color(0xFF4A90E2),
                                                );
                                              },
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -2,
                                        right: -2,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF4A90E2),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.zoom_in,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // Informações do lado da foto
                          Expanded(
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
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
                            tipoVisitante: tipoVisitante,
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
    String observacoes, {
    String tipoVisitante = 'visitante_portaria',
  }) async {
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
        tipoVisitante: tipoVisitante,
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

      // Fazer upload da foto se houver uma selecionada
      if (_fotoVisitante != null) {
        try {
          print('🔵 Iniciando upload da foto do visitante...');

          // Gerar nome único para a foto
          final String nomeArquivo =
              'visitante_${DateTime.now().millisecondsSinceEpoch}.jpg';

          // Fazer upload para Supabase Storage
          // Bucket: visitante_adicionado_pelo_representante
          final fotoUrlPublica =
              await VisitantePortariaService.uploadFotoVisitante(
                condominioId: widget.condominioId!,
                arquivo: _fotoVisitante!,
                nomeArquivo: nomeArquivo,
              );

          if (fotoUrlPublica != null) {
            visitanteData['foto_url'] = fotoUrlPublica;
            print('✅ Upload da foto realizado com sucesso: $fotoUrlPublica');
          }
        } catch (e) {
          print('⚠️ Erro ao fazer upload da foto: $e');
          // Continuar mesmo se falhar o upload (foto é opcional)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Aviso: Erro ao fazer upload da foto: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

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

    // 🆕 Validar e obter unidade_id
    String? unidadeId;
    if (_isUnidadeSelecionada && _unidadeSelecionadaVisitante != null) {
      unidadeId = _unidadeSelecionadaVisitante!.id;
      print('[Visitante] Unidade selecionada: $unidadeId');
    } else if (_isUnidadeSelecionada && _unidadeSelecionadaVisitante == null) {
      print(
        '❌ [Visitante] ERRO: Unidade marcada como selecionada mas está nula!',
      );
      unidadeId = null;
    } else {
      print('[Visitante] Sem unidade selecionada (Condomínio)');
      unidadeId = null;
    }

    return {
      'condominio_id': widget.condominioId!,
      'unidade_id': unidadeId,
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
      _fotoVisitante = null; // Limpar foto também
    });
  }

  // Mostrar mensagem de sucesso
  Future<void> _mostrarMensagemSucesso() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visitante cadastrado com sucesso!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // ✅ Recarregar a lista de visitantes cadastrados automaticamente
    // Esperar um pouco para garantir que o QR Code foi salvo no banco
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 800));
      _carregarVisitantesCadastrados();
      // ✅ Recarregar também a lista de acessos (visitantes no condomínio)
      _carregarVisitantesNoCondominio();
    }
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

  /// Mostra diálogo para selecionar fonte de foto (câmera ou galeria)
  /// Só funciona em plataformas mobile (Android/iOS)
  Future<void> _mostrarDialogSelecaoFotoVisitante() async {
    // Na web, usar apenas galeria
    if (kIsWeb) {
      await _selecionarFotoVisitanteGaleria();
      return;
    }

    // Em mobile, mostrar diálogo com opções
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Selecionar Foto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A59),
            ),
          ),
          content: const Text(
            'De onde você gostaria de tirar a foto?',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          actions: [
            // Botão Câmera
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _selecionarFotoVisitanteCamera();
              },
              icon: const Icon(
                Icons.camera_alt,
                color: Color(0xFF1976D2),
                size: 24,
              ),
              label: const Text(
                'Câmera',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            // Botão Galeria
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _selecionarFotoVisitanteGaleria();
              },
              icon: const Icon(Icons.image, color: Color(0xFF1976D2), size: 24),
              label: const Text(
                'Galeria',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Tirar foto com a câmera do celular
  Future<void> _selecionarFotoVisitanteCamera() async {
    try {
      final photoPickerService = PhotoPickerService();
      final XFile? image = await photoPickerService.pickImageFromCamera();

      if (image != null) {
        setState(() {
          _fotoVisitante = image;
        });
      }
    } catch (e) {
      print('Erro ao tirar foto da câmera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao tirar foto: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Selecionar foto da galeria
  Future<void> _selecionarFotoVisitanteGaleria() async {
    try {
      final photoPickerService = PhotoPickerService();
      final XFile? image = await photoPickerService.pickImage();

      if (image != null) {
        setState(() {
          _fotoVisitante = image;
        });
      }
    } catch (e) {
      print('Erro ao selecionar foto da galeria: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar foto: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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

  // Método para salvar encomenda
  Future<void> _salvarEncomenda() async {
    if (_pessoaSelecionadaEncomenda == null) return;

    // Obter representante atual
    // Obter usuário atual (Representante ou Porteiro)
    // Já carregado em _representanteAtual
    if (_representanteAtual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Não foi possível identificar o usuário atual'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String usuarioId = _representanteAtual.id;

    // Criar objeto Encomenda
    final now = DateTime.now();

    // Debug: verificar dados da pessoa selecionada
    print('🔍 Debug - Pessoa selecionada:');
    print('  ID: ${_pessoaSelecionadaEncomenda!.id}');
    print('  Tipo: ${_pessoaSelecionadaEncomenda!.tipo}');
    print('  Nome: ${_pessoaSelecionadaEncomenda!.nome}');
    print('  Unidade ID: ${_pessoaSelecionadaEncomenda!.unidadeId}');

    // Debug: verificar usuário atual
    print('🔍 Debug - Usuário atual:');
    print('  ID: $usuarioId');
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

    // Determinar IDs baseados no tipo de usuário
    String? finalRepresentanteId;
    String? finalPorteiroId;

    if (_representanteAtual is Porteiro) {
      finalPorteiroId = usuarioId;
      finalRepresentanteId =
          ''; // Encomenda model espera string vazia para null na conversão
    } else {
      finalRepresentanteId = usuarioId;
      finalPorteiroId = null;
    }

    try {
      final encomenda = Encomenda(
        id: '', // Será gerado pelo Supabase
        condominioId: widget.condominioId!,
        representanteId: finalRepresentanteId ?? '',
        porteiroId: finalPorteiroId,
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
        encomendaId = await _encomendaService.criarEncomendaComFoto(
          encomenda,
          _imagemEncomenda,
        );
      } else {
        encomendaId = await _encomendaService.criarEncomenda(encomenda);
      }

      if (encomendaId.isNotEmpty) {
        print('✅ Encomenda salva com sucesso! ID: $encomendaId');

        // Mostrar mensagem de sucesso
        if (mounted) {
          final unidadeDisplay =
              _temBlocos && _pessoaSelecionadaEncomenda!.unidadeBloco != 'N/A'
              ? '${_pessoaSelecionadaEncomenda!.unidadeNumero}/${_pessoaSelecionadaEncomenda!.unidadeBloco}'
              : _pessoaSelecionadaEncomenda!.unidadeNumero;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Encomenda cadastrada para ${_pessoaSelecionadaEncomenda!.nome} - $unidadeDisplay' +
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

  /// Constrói uma linha de informação com label e valor formatados
  Widget _buildInfoLine(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2E3A59),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Mostra a foto ampliada em um diálogo com zoom
  void _mostrarFotoAmpliada(String fotoUrl, String nome) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              // Foto ampliada com InteractiveViewer
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Image.network(
                        fotoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image_not_supported,
                                color: Colors.white,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Erro ao carregar a foto',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              // Botão fechar (X)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
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
