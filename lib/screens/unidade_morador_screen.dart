import 'package:flutter/material.dart';
import 'detalhes_unidade_screen.dart';
import 'configuracao_condominio_screen.dart';
import '../services/unidade_service.dart';
import '../models/bloco_com_unidades.dart';
import '../models/condominio.dart';

class UnidadeMoradorScreen extends StatefulWidget {
  final String? condominioId;
  final String? condominioNome;
  final String? condominioCnpj;

  const UnidadeMoradorScreen({
    super.key,
    this.condominioId,
    this.condominioNome,
    this.condominioCnpj,
  });

  @override
  State<UnidadeMoradorScreen> createState() => _UnidadeMoradorScreenState();
}

class _UnidadeMoradorScreenState extends State<UnidadeMoradorScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UnidadeService _unidadeService = UnidadeService();
  
  List<BlocoComUnidades> _blocosUnidades = [];
  List<BlocoComUnidades> _blocosUnidadesFiltrados = [];
  bool _isLoading = true;
  bool _condominioConfigurado = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _searchController.addListener(_filtrarUnidades);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrarUnidades);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    if (widget.condominioId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'ID do condomínio não informado';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verifica se o condomínio já foi configurado
      final jaConfigurado = await _unidadeService.condominioJaConfigurado(widget.condominioId!);
      
      if (jaConfigurado) {
        // Carrega os dados do banco
        final blocosUnidades = await _unidadeService.listarUnidadesCondominio(widget.condominioId!);
        setState(() {
          _blocosUnidades = blocosUnidades;
          _blocosUnidadesFiltrados = blocosUnidades;
          _condominioConfigurado = true;
          _isLoading = false;
        });
      } else {
        // Condomínio não configurado
        setState(() {
          _condominioConfigurado = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados: $e';
        _isLoading = false;
      });
    }
  }

  void _filtrarUnidades() {
    final termo = _searchController.text.trim();
    
    if (termo.isEmpty) {
      setState(() {
        _blocosUnidadesFiltrados = _blocosUnidades;
      });
      return;
    }

    setState(() {
      _blocosUnidadesFiltrados = _blocosUnidades.where((blocoComUnidades) {
        // Verifica se o nome do bloco contém o termo
        final blocoCorresponde = blocoComUnidades.bloco.nome.toLowerCase().contains(termo.toLowerCase()) ||
                                blocoComUnidades.bloco.codigo.toLowerCase().contains(termo.toLowerCase());

        // Verifica se alguma unidade contém o termo
        final unidadesCorrespondem = blocoComUnidades.unidades.any((unidade) =>
            unidade.numero.toLowerCase().contains(termo.toLowerCase()));

        return blocoCorresponde || unidadesCorrespondem;
      }).toList();
    });
  }

  Future<void> _navegarParaConfiguracao() async {
    if (widget.condominioId == null || widget.condominioNome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados do condomínio não disponíveis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final condominio = Condominio(
      id: widget.condominioId!,
      nomeCondominio: widget.condominioNome!,
      cnpj: widget.condominioCnpj ?? '',
      cep: '',
      endereco: '',
      numero: '',
      bairro: '',
      cidade: '',
      estado: '',
      ativo: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ConfiguracaoCondominioScreen(condominio: condominio),
      ),
    );

    // Se a configuração foi bem-sucedida, recarrega os dados
    if (resultado == true) {
      _carregarDados();
    }
  }

  Widget _buildUnidadeButton(String numero, String bloco, {bool temMoradores = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesUnidadeScreen(
                condominioId: widget.condominioId,
                condominioNome: widget.condominioNome,
                condominioCnpj: widget.condominioCnpj,
                bloco: bloco,
                unidade: numero,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: temMoradores ? const Color(0xFF4A90E2) : const Color(0xFFE0E0E0),
          foregroundColor: temMoradores ? Colors.white : const Color(0xFF757575),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              numero,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (temMoradores) ...[
              const SizedBox(width: 4),
              const Icon(Icons.person, size: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBlocoSection(BlocoComUnidades blocoComUnidades) {
    final bloco = blocoComUnidades.bloco;
    final unidades = blocoComUnidades.unidades;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do bloco com estatísticas
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Row(
              children: [
                Text(
                  bloco.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3A59),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${blocoComUnidades.totalUnidadesOcupadas}/${unidades.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Unidades do bloco
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              children: unidades.map((unidade) => 
                _buildUnidadeButton(
                  unidade.numero, 
                  bloco.nome,
                  temMoradores: unidade.temMoradores,
                )
              ).toList(),
            ),
          ),
        ],
      ),
    );
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
            
            // Breadcrumb
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Center(
                child: Text(
                  'Home/Gestão/Unid-Morador',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            // Conteúdo principal
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // Botão de ação principal
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Center(
                        child: SizedBox(
                          width: 220,
                          child: ElevatedButton(
                          onPressed: _condominioConfigurado ? null : _navegarParaConfiguracao,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _condominioConfigurado 
                              ? const Color(0xFF4CAF50) 
                              : const Color(0xFF007AFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 1,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _condominioConfigurado ? Icons.check : Icons.settings,
                                  color: _condominioConfigurado 
                                    ? const Color(0xFF4CAF50) 
                                    : const Color(0xFF007AFF),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _condominioConfigurado 
                                  ? 'Condomínio Configurado' 
                                  : 'Configurar Condomínio',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          ),
                        ),
                      ),
                    ),

                    // Campo de pesquisa
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Pesquisar unidade/bloco ou nome',
                          hintStyle: const TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 16,
                          ),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF999999),
                            size: 24,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: Color(0xFFDDDDDD),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: Color(0xFF007AFF),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Lista de blocos e unidades
                    Expanded(
                      child: _buildConteudoPrincipal(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudoPrincipal() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            ),
            SizedBox(height: 16),
            Text(
              'Carregando dados...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarDados,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (!_condominioConfigurado) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.settings,
              size: 64,
              color: Color(0xFF4A90E2),
            ),
            const SizedBox(height: 16),
            const Text(
              'Condomínio não configurado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A59),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure os blocos e unidades\npara começar a usar o sistema',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _navegarParaConfiguracao,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Configurar Agora'),
            ),
          ],
        ),
      );
    }

    if (_blocosUnidadesFiltrados.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Color(0xFF999999),
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma unidade encontrada',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: _blocosUnidadesFiltrados
            .map((blocoComUnidades) => _buildBlocoSection(blocoComUnidades))
            .toList(),
      ),
    );
  }
}