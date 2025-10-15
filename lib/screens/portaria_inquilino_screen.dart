import 'package:flutter/material.dart';
import 'chat_inquilino_screen.dart';

class PortariaInquilinoScreen extends StatefulWidget {
  final String? condominioId;
  final String? condominioNome;
  final String? condominioCnpj;
  final String? inquilinoId;

  const PortariaInquilinoScreen({
    super.key,
    this.condominioId,
    this.condominioNome,
    this.condominioCnpj,
    this.inquilinoId,
  });

  @override
  State<PortariaInquilinoScreen> createState() => _PortariaInquilinoScreenState();
}

class _PortariaInquilinoScreenState extends State<PortariaInquilinoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controladores para o modal de adicionar autorizado
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _parentescoController = TextEditingController();
  final TextEditingController _carroMotoController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _corController = TextEditingController();

  // Variáveis de estado para o modal
  String _permissaoSelecionada = 'qualquer'; // 'qualquer' ou 'determinado'
  List<bool> _diasSemana = List.filled(7, false); // DOM, SEG, TER, QUA, QUI, SEX, SAB
  String _horarioInicio = '8h';
  String _horarioFim = '18h';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose();
    _cpfController.dispose();
    _parentescoController.dispose();
    _carroMotoController.dispose();
    _marcaController.dispose();
    _placaController.dispose();
    _modeloController.dispose();
    _corController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho superior padronizado
            Container(
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
              color: Colors.grey[300],
            ),

            // Título da página
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

            // TabBar com as três abas - Design igual à imagem
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 3.0,
                    color: Color(0xFF4A90E2),
                  ),
                  insets: EdgeInsets.symmetric(horizontal: 0.0),
                ),
                indicatorColor: const Color(0xFF4A90E2),
                labelColor: const Color(0xFF4A90E2),
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                dividerColor: Colors.grey[300],
                tabs: const [
                  Tab(text: 'Autorizados'),
                  Tab(text: 'Mensagem'),
                  Tab(text: 'Encomendas'),
                ],
              ),
            ),

            // Conteúdo das abas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Aba Autorizados
                  _buildAutorizadosTab(),
                  // Aba Mensagem
                  _buildMensagemTab(),
                  // Aba Encomendas
                  _buildEncomendasTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para a aba Autorizados
  Widget _buildAutorizadosTab() {
    // Dados mockados de pessoas autorizadas
    final List<Map<String, String>> pessoasAutorizadas = [
      {
        'nome': 'João da Silva',
        'parentesco': 'Pai',
      },
      {
        'nome': 'Maria Santos',
        'parentesco': 'Mãe',
      },
      {
        'nome': 'Pedro Silva',
        'parentesco': 'Irmão',
      },
      {
        'nome': 'Ana Costa',
        'parentesco': 'Tia',
      },
    ];

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Botão Adicionar Autorizado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                _showAdicionarAutorizadoModal();
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Adicionar Autorizado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
          
          // Lista de autorizados
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: pessoasAutorizadas.length,
              itemBuilder: (context, index) {
                final pessoa = pessoasAutorizadas[index];
                return _buildAutorizadoCard(
                  nome: pessoa['nome']!,
                  parentesco: pessoa['parentesco']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget do card de pessoa autorizada
  Widget _buildAutorizadoCard({
    required String nome,
    required String parentesco,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Ícone de pessoa
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4A90E2).withOpacity(0.1),
            ),
            child: const Icon(
              Icons.person,
              size: 30,
              color: Color(0xFF4A90E2),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Informações da pessoa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3A59),
                  ),
                ),
                const SizedBox(height: 4),
                // Parentesco
                Row(
                  children: [
                    const Text(
                      'Parentesco: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      parentesco,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E3A59),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Ícones de ação
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone de editar
              GestureDetector(
                onTap: () {
                  // TODO: Implementar edição
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Editar $nome'),
                      backgroundColor: const Color(0xFF4A90E2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Color(0xFF4A90E2),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Ícone de excluir
              GestureDetector(
                onTap: () {
                  // TODO: Implementar exclusão
                  _showDeleteConfirmation(context, nome);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFFE74C3C),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares para o modal de adicionar autorizado
  void _limparCamposModal() {
    try {
      if (_nomeController.text.isNotEmpty) _nomeController.clear();
      if (_cpfController.text.isNotEmpty) _cpfController.clear();
      if (_parentescoController.text.isNotEmpty) _parentescoController.clear();
      if (_carroMotoController.text.isNotEmpty) _carroMotoController.clear();
      if (_marcaController.text.isNotEmpty) _marcaController.clear();
      if (_placaController.text.isNotEmpty) _placaController.clear();
      if (_modeloController.text.isNotEmpty) _modeloController.clear();
      if (_corController.text.isNotEmpty) _corController.clear();
    } catch (e) {
      print('Erro ao limpar controladores: $e');
      // Em caso de erro, recriar os controladores
      _recriarControladores();
    }
  }

  void _recriarControladores() {
    // Como os controladores são final, apenas limpamos o texto
    try {
      _nomeController.text = '';
      _cpfController.text = '';
      _parentescoController.text = '';
      _carroMotoController.text = '';
      _marcaController.text = '';
      _placaController.text = '';
      _modeloController.text = '';
      _corController.text = '';
    } catch (e) {
      print('Erro ao limpar texto dos controladores: $e');
    }
  }

  void _resetarVariaveisEstado() {
    if (mounted) {
      setState(() {
        _permissaoSelecionada = 'qualquer';
        _diasSemana = List.filled(7, false);
        _horarioInicio = '8h';
        _horarioFim = '18h';
      });
    }
  }

  // Método para mostrar o modal de adicionar autorizado
  void _showAdicionarAutorizadoModal() {
    // Limpar campos ao abrir o modal com verificação de segurança
    _limparCamposModal();
    
    // Resetar variáveis de estado
    _resetarVariaveisEstado();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título do modal
                    Row(
                      children: [
                        const Text(
                          'Adicionar Autorizado',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Conteúdo do modal com scroll
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Seção Visitante
                            _buildSectionTitle('Visitante'),
                            const SizedBox(height: 12),
                            
                            _buildTextField(
                              controller: _nomeController,
                              label: 'Nome*',
                              hint: 'José Marcos da Silva',
                            ),
                            const SizedBox(height: 12),
                            
                            _buildTextField(
                              controller: _cpfController,
                              label: 'CPF*',
                              hint: '114.225.999-66',
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'APARECERÁ OS 3 PRIMEIROS DÍGITOS PARA A PORTARIA',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            _buildTextField(
                              controller: _parentescoController,
                              label: 'Parentesco',
                              hint: 'Pai',
                            ),
                            const SizedBox(height: 20),

                            // Seção Permissões
                            _buildSectionTitle('Permissões'),
                            const SizedBox(height: 12),
                            
                            // Radio buttons para permissões
                            Column(
                              children: [
                                RadioListTile<String>(
                                  title: const Text('Permissão em qualquer dia e horário'),
                                  value: 'qualquer',
                                  groupValue: _permissaoSelecionada,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _permissaoSelecionada = value!;
                                    });
                                  },
                                  activeColor: const Color(0xFF4A90E2),
                                ),
                                RadioListTile<String>(
                                  title: const Text('Permissão em dias e horários determinado'),
                                  value: 'determinado',
                                  groupValue: _permissaoSelecionada,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _permissaoSelecionada = value!;
                                    });
                                  },
                                  activeColor: const Color(0xFF4A90E2),
                                ),
                              ],
                            ),

                            // Horários permitidos (só aparece se "determinado" estiver selecionado)
                            if (_permissaoSelecionada == 'determinado') ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Horários permitida a entrada:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Seleção de horários
                              Row(
                                children: [
                                  _buildHorarioButton('8h', setModalState),
                                  const SizedBox(width: 8),
                                  const Text(' - '),
                                  const SizedBox(width: 8),
                                  _buildHorarioButton('12h', setModalState),
                                  const SizedBox(width: 16),
                                  _buildHorarioButton('14h', setModalState),
                                  const SizedBox(width: 8),
                                  const Text(' - '),
                                  const SizedBox(width: 8),
                                  _buildHorarioButton('18h', setModalState),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Dias da semana
                              const Text(
                                'Dias da Semana:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildDiaCheckbox('DOM', 0, setModalState),
                                  _buildDiaCheckbox('SEG', 1, setModalState),
                                  _buildDiaCheckbox('TER', 2, setModalState),
                                  _buildDiaCheckbox('QUA', 3, setModalState),
                                  _buildDiaCheckbox('QUI', 4, setModalState),
                                  _buildDiaCheckbox('SEX', 5, setModalState),
                                  _buildDiaCheckbox('SAB', 6, setModalState),
                                ],
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Seção Veículo
                            _buildSectionTitle('Veículo(s)'),
                            const SizedBox(height: 12),
                            
                            _buildTextField(
                              controller: _carroMotoController,
                              label: 'Carro/Moto',
                              hint: 'Carro',
                            ),
                            const SizedBox(height: 12),
                            
                            _buildTextField(
                              controller: _marcaController,
                              label: 'Marca',
                              hint: 'Fiat',
                            ),
                            const SizedBox(height: 12),
                            
                            _buildTextField(
                              controller: _placaController,
                              label: 'Placa',
                              hint: 'ABC1243',
                            ),
                            const SizedBox(height: 12),
                            
                            _buildTextField(
                              controller: _modeloController,
                              label: 'Modelo',
                              hint: 'Fiat Argo',
                            ),
                            const SizedBox(height: 12),
                            
                            _buildTextField(
                              controller: _corController,
                              label: 'Cor',
                              hint: 'Preto',
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // Botão Salvar fixo na parte inferior
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _salvarAutorizado();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Salvar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

  // Método para mostrar confirmação de exclusão
  void _showDeleteConfirmation(BuildContext context, String nome) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Deseja realmente remover $nome da lista de autorizados?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF666666)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$nome removido da lista de autorizados'),
                    backgroundColor: const Color(0xFFE74C3C),
                  ),
                );
              },
              child: const Text(
                'Excluir',
                style: TextStyle(color: Color(0xFFE74C3C)),
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget para a aba Mensagem
  Widget _buildMensagemTab() {
    // Contato único da portaria
    final Map<String, dynamic> contatoPortaria = {
      'nome': 'Portaria',
      'data': 'Disponível 24h',
      'icone': Icons.security,
      'corFundo': const Color(0xFF2E7D32), // Verde escuro para representar segurança
    };

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _buildMensagemCard(
          nome: contatoPortaria['nome'],
          data: contatoPortaria['data'],
          icone: contatoPortaria['icone'],
          corFundo: contatoPortaria['corFundo'],
        ),
      ),
    );
  }

  // Widget do card de mensagem
  Widget _buildMensagemCard({
    required String nome,
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
          nome,
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
              builder: (context) => ChatInquilinoScreen(
                nomeContato: nome,
                apartamento: nome == 'Portaria' ? 'Central de Segurança' : 'B/501',
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget para a aba Encomendas
  Widget _buildEncomendasTab() {
    // Dados mockados de encomendas baseados na imagem
    final List<Map<String, dynamic>> encomendas = [
      {
        'porteiro': 'José da Silva',
        'data': '25/11/2023',
        'hora': '08:20',
        'status': 'Pendente de Retirada',
        'statusCor': const Color(0xFFFF8C00), // Laranja
        'icone': Icons.inventory_2_outlined,
      },
      {
        'porteiro': 'Pedro de Souza',
        'data': '25/11/2023',
        'hora': '08:20',
        'status': 'Objeto Retirado',
        'statusCor': const Color(0xFF4CAF50), // Verde
        'icone': Icons.inventory_2_outlined,
        'retiradoPor': 'Maria da Silva',
        'dataRetirada': '26/11/2023',
        'horaRetirada': '18:20',
      },
    ];

    return Container(
      color: const Color(0xFFF5F5F5),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: encomendas.length,
        itemBuilder: (context, index) {
          final encomenda = encomendas[index];
          return _buildEncomendaCard(encomenda);
        },
      ),
    );
  }

  // Widget do card de encomenda
  Widget _buildEncomendaCard(Map<String, dynamic> encomenda) {
    final String porteiro = encomenda['porteiro'];
    final String data = encomenda['data'];
    final String hora = encomenda['hora'];
    final String status = encomenda['status'];
    final Color statusCor = encomenda['statusCor'];
    final IconData icone = encomenda['icone'];
    final String? retiradoPor = encomenda['retiradoPor'];
    final String? dataRetirada = encomenda['dataRetirada'];
    final String? horaRetirada = encomenda['horaRetirada'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com porteiro
            Row(
              children: [
                Text(
                  'Porteiro: ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  porteiro,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Conteúdo principal
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícone da encomenda
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Icon(
                    icone,
                    color: const Color(0xFF7F8C8D),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Informações da encomenda
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Data e hora
                      Row(
                        children: [
                          Text(
                            'Data: ',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            data,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Hora: ',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            hora,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusCor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      // Informações de retirada (se aplicável)
                      if (retiradoPor != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          retiradoPor,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Data: ',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                            Text(
                              dataRetirada!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Hora: ',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                            Text(
                              horaRetirada!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares para o modal

  // Widget para título de seção
  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF4A90E2),
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A59),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para campo de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3A59),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4A90E2)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  // Widget para botão de horário
  Widget _buildHorarioButton(String horario, StateSetter setModalState) {
    bool isSelected = (horario == _horarioInicio || horario == _horarioFim);
    
    return GestureDetector(
      onTap: () {
        setModalState(() {
          if (horario == '8h' || horario == '12h') {
            _horarioInicio = horario;
          } else {
            _horarioFim = horario;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A90E2) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          horario,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF2E3A59),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Widget para checkbox de dia da semana
  Widget _buildDiaCheckbox(String dia, int index, StateSetter setModalState) {
    return Column(
      children: [
        Text(
          dia,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E3A59),
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            setModalState(() {
              _diasSemana[index] = !_diasSemana[index];
            });
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _diasSemana[index] ? const Color(0xFF4A90E2) : Colors.white,
              border: Border.all(
                color: _diasSemana[index] ? const Color(0xFF4A90E2) : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _diasSemana[index]
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  // Método para salvar autorizado
  void _salvarAutorizado() {
    // TODO: Implementar salvamento no backend
    // Por enquanto, apenas mostra uma mensagem de sucesso
    
    String nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha o nome do autorizado'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$nome adicionado à lista de autorizados'),
        backgroundColor: const Color(0xFF27AE60),
      ),
    );
  }
}