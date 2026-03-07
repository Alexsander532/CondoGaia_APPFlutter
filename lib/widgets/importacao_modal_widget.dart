import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:condogaiaapp/services/importacao_service.dart';
import 'package:condogaiaapp/models/importacao_row.dart';

/// Modal multi-step para importação de planilha
/// Passos:
/// 1. Seleção de arquivo
/// 2. Preview e validação
/// 3. Confirmação
/// 4. Progresso de inserção (quando implementado)
/// 5. Resultado final
class ImportacaoModalWidget extends StatefulWidget {
  final String condominioId;
  final String condominioNome;
  final Set<String> cpfsExistentes;
  final Set<String> emailsExistentes;

  /// Callback quando importação é confirmada
  /// Retorna Map com dados mapeados prontos para inserção
  final Future<void> Function(Map<String, dynamic>)? onImportarConfirmado;

  const ImportacaoModalWidget({
    Key? key,
    required this.condominioId,
    required this.condominioNome,
    required this.cpfsExistentes,
    required this.emailsExistentes,
    this.onImportarConfirmado,
  }) : super(key: key);

  @override
  State<ImportacaoModalWidget> createState() => _ImportacaoModalWidgetState();
}

class _ImportacaoModalWidgetState extends State<ImportacaoModalWidget> {
  // Controle do passo (1-5)
  int _passoAtual = 1;

  // Dados
  Uint8List? _arquivoBytes;
  String? _nomeArquivo;
  List<ImportacaoRow>? _rowsValidadas;
  Map<String, dynamic>? _dadosMapeados;

  // Estados
  bool _carregando = false;
  String? _mensagemErro;
  
  // Logs detalhados
  List<String> _logs = [];
  final ScrollController _logsScrollController = ScrollController();

  // Resultado da importação
  Map<String, dynamic>? _resultadoImportacao;
  bool _importacaoEmAndamento = false;

  // Separar válidas e com erro
  List<ImportacaoRow> get _rowsValidas =>
      _rowsValidadas?.where((r) => !r.temErros).toList() ?? [];

  List<ImportacaoRow> get _rowsComErro =>
      _rowsValidadas?.where((r) => r.temErros).toList() ?? [];

  /// Adiciona um log à lista e faz scroll automático
  void _adicionarLog(String mensagem) {
    setState(() {
      _logs.add(mensagem);
    });
    // Scroll automático para o final
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_logsScrollController.hasClients) {
        _logsScrollController.animateTo(
          _logsScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Passo 1: Seleção do arquivo
  Future<void> _selecionarArquivo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'ods'],
        withData: true,
      );

      if (result == null) return;

      setState(() {
        _arquivoBytes = result.files.first.bytes;
        _nomeArquivo = result.files.first.name;
        _mensagemErro = null;
        _logs.clear();
      });

      _adicionarLog('📁 Arquivo selecionado: ${result.files.first.name}');

      // Avançar para próximo passo
      _avancarPasso();
    } catch (e) {
      setState(() => _mensagemErro = 'Erro ao selecionar arquivo: $e');
    }
  }

  /// Passo 2: Fazer parsing e validação
  Future<void> _fazerParsingEValidacao() async {
    if (_arquivoBytes == null) return;

    setState(() => _carregando = true);

    try {
      _adicionarLog('⏳ Iniciando parsing do arquivo...');
      
      final rows = await ImportacaoService.parsarEValidarArquivo(
        _arquivoBytes!,
        cpfsExistentesNoBanco: widget.cpfsExistentes,
        emailsExistenteNoBanco: widget.emailsExistentes,
        enableLogging: true,  // ✅ HABILITANDO LOGGING
      );

      _adicionarLog('✅ Parsing concluído: ${rows.length} linhas encontradas');
      _adicionarLog('📊 Separando válidas de inválidas...');

      setState(() {
        _rowsValidadas = rows;
        _carregando = false;
        _mensagemErro = null;
      });

      _adicionarLog('✅ Total de linhas válidas: ${_rowsValidas.length}');
      _adicionarLog('❌ Total de linhas com erro: ${_rowsComErro.length}');

      // Avançar para preview
      _avancarPasso();
    } catch (e) {
      _adicionarLog('❌ ERRO: $e');
      setState(() {
        _carregando = false;
        _mensagemErro = 'Erro ao processar arquivo: $e';
      });
    }
  }

  /// Passo 3: Mapear dados (preparar para inserção)
  Future<void> _mapearDados() async {
    if (_rowsValidas.isEmpty) {
      _adicionarLog('❌ Nenhuma linha válida para importar');
      setState(() => _mensagemErro = 'Nenhuma linha válida para importar');
      return;
    }

    setState(() => _carregando = true);

    try {
      _adicionarLog('🔄 Iniciando mapeamento de dados...');
      
      final mapeado = await ImportacaoService.mapearParaEntidades(
        _rowsValidas,
        condominioId: widget.condominioId,
      );

      _adicionarLog('✅ Mapeamento concluído!');
      
      // Exibir resumo do mapeamento
      final proprietarios = mapeado['proprietarios'] as Map?;
      final inquilinos = mapeado['inquilinos'] as Map?;
      final blocos = mapeado['blocos'] as Map?;
      
      _adicionarLog('👥 Proprietários: ${proprietarios?.length ?? 0}');
      _adicionarLog('🏠 Inquilinos: ${inquilinos?.length ?? 0}');
      _adicionarLog('🏘️  Blocos: ${blocos?.length ?? 0}');

      setState(() {
        _dadosMapeados = mapeado;
        _carregando = false;
        _mensagemErro = null;
      });

      // Avançar para Passo 4 (Preview dos dados mapeados)
      // User deve clicar "Confirmar Importação" para executar de verdade
      _avancarPasso();
      
    } catch (e) {
      _adicionarLog('❌ ERRO ao mapear: $e');
      setState(() {
        _carregando = false;
        _mensagemErro = 'Erro ao mapear dados: $e';
      });
    }
  }

  /// Executa a importação completa via Supabase
  Future<void> _executarImportacaoCompleta() async {
    if (_rowsValidas.isEmpty) return;

    setState(() {
      _importacaoEmAndamento = true;
      _resultadoImportacao = null;
    });

    _adicionarLog('\n╔════════════════════════════════════════════════════╗');
    _adicionarLog('║     INICIANDO IMPORTAÇÃO PARA SUPABASE             ║');
    _adicionarLog('╚════════════════════════════════════════════════════╝\n');

    try {
      final resultado = await ImportacaoService.executarImportacaoCompleta(
        _arquivoBytes!,
        condominioId: widget.condominioId,
        cpfsExistentes: widget.cpfsExistentes,
        emailsExistentes: widget.emailsExistentes,
      );

      // Processar resultado
      setState(() {
        _resultadoImportacao = resultado;
        _importacaoEmAndamento = false;
      });

      // Exibir log do resultado
      _adicionarLog('\n╔════════════════════════════════════════════════════╗');
      _adicionarLog('║              RESUMO DA IMPORTAÇÃO                 ║');
      _adicionarLog('╚════════════════════════════════════════════════════╝\n');

      _adicionarLog('✅ Linhas com sucesso: ${resultado['linhasComSucesso'] ?? 0}');
      _adicionarLog('❌ Linhas com erro: ${resultado['linhasComErro'] ?? 0}');
      _adicionarLog('📊 Total processado: ${resultado['linhasProcessadas'] ?? 0}');
      _adicionarLog('⏱️  Tempo total: ${resultado['tempo'] ?? 0}s\n');

      // Exibir senhas se existirem
      final senhas = resultado['senhas'] as List?;
      if (senhas != null && senhas.isNotEmpty) {
        _adicionarLog('🔐 SENHAS TEMPORÁRIAS GERADAS:\n');
        for (final senha in senhas) {
          final linhaNum = senha['linhaNumero'] ?? 'N/A';
          final senhaProp = senha['senhaProprietario'] ?? '—';
          final senhaInq = senha['senhaInquilino'];
          
          _adicionarLog('Linha $linhaNum:');
          _adicionarLog('  📱 Proprietário: $senhaProp');
          if (senhaInq != null) {
            _adicionarLog('  👤 Inquilino: $senhaInq');
          }
        }
      }

      // Exibir erros detalhados se houver
      final resultados = resultado['resultados'] as List?;
      if (resultados != null) {
        final erros = resultados.where((r) => r['sucesso'] != true).toList();
        if (erros.isNotEmpty) {
          _adicionarLog('\n⚠️  LINHAS COM ERRO:\n');
          for (final erro in erros) {
            final linhaNum = erro['linhaNumero'] ?? 'N/A';
            final erroMsg = erro['erro'] ?? 'Erro desconhecido';
            final errosLista = erro['erros'] as List?;
            
            _adicionarLog('❌ Linha $linhaNum: $erroMsg');
            if (errosLista != null) {
              for (final e in errosLista) {
                _adicionarLog('   • $e');
              }
            }
          }
        }
      }

      // Avançar para Passo 5 (Resultado)
      _adicionarLog('\n✅ Importação finalizada! Exibindo resultado...\n');
      setState(() => _passoAtual = 5);

    } catch (e) {
      _adicionarLog('❌ ERRO GERAL NA IMPORTAÇÃO: $e\n');
      setState(() {
        _importacaoEmAndamento = false;
        _mensagemErro = 'Erro na importação: $e';
      });
    }
  }

  /// Avançar para próximo passo
  void _avancarPasso() {
    if (_passoAtual < 5) {
      setState(() => _passoAtual++);

      // Auto-executar algumas ações ao mudar de passo
      if (_passoAtual == 2 && _arquivoBytes != null) {
        _fazerParsingEValidacao();
      }
    }
  }

  /// Voltar para passo anterior
  void _voltarPasso() {
    if (_passoAtual > 1) {
      setState(() => _passoAtual--);
    }
  }

  /// Fechar modal
  void _fechar() {
    final bool sucesso = _resultadoImportacao != null;
    Navigator.pop(context, sucesso);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header com título e progresso
              _buildHeader(),

              // Conteúdo do passo atual (com scroll automático)
              Expanded(
                child: _buildConteudoPasso(),
              ),

              // Footer com botões
              _buildFooter(),
            ],
          ),
        ),
        
        // Overlay de Loading durante a importação
        if (_importacaoEmAndamento)
          Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Importando dados...\nPor favor, aguarde.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Build header com título e indicador de progresso
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90E2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.upload_file,
                            color: Color(0xFF4A90E2),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Importar Planilha',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Passo $_passoAtual de 5 • ${_obterNomePasso()}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey[600]),
                onPressed: _fechar,
                tooltip: 'Fechar',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Indicador de progresso visual
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _passoAtual / 5,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            ),
          ),
        ],
      ),
    );
  }

  /// Retorna o nome do passo atual
  String _obterNomePasso() {
    switch (_passoAtual) {
      case 1:
        return 'Selecionar Arquivo';
      case 2:
        return 'Processamento';
      case 3:
        return 'Visualização';
      case 4:
        return 'Confirmação';
      case 5:
        return 'Resultado';
      default:
        return 'Desconhecido';
    }
  }

  /// Build conteúdo do passo atual
  Widget _buildConteudoPasso() {
    if (_carregando) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_obterMensagemCarregamento()),
          ],
        ),
      );
    }

    if (_mensagemErro != null) {
      return _buildErro();
    }

    switch (_passoAtual) {
      case 1:
        return _buildPasso1Selecao();
      case 2:
        return _buildPasso2Processamento();
      case 3:
        return _buildPasso3Preview();
      case 4:
        return _buildPasso4Confirmacao();
      case 5:
        return _buildPasso5Resultado();
      default:
        return const SizedBox();
    }
  }

  /// Passo 1: Seleção de arquivo
  Widget _buildPasso1Selecao() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // Ícone animado
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(80),
            ),
            child: Icon(
              Icons.cloud_upload_outlined,
              size: 80,
              color: const Color(0xFF4A90E2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Título
          Text(
            'Selecione o Arquivo',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Descrição
          Text(
            'Escolha um arquivo Excel (.xlsx, .xls) ou OpenDocument (.ods) com os dados de proprietários e inquilinos para importar.',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Arquivo selecionado (se houver)
          if (_nomeArquivo != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Arquivo Selecionado:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _nomeArquivo!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Passo 2: Processamento com logs em tempo real
  Widget _buildPasso2Processamento() {
    return Column(
      children: [
        // Header descritivo
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.hourglass_bottom,
                      color: Color(0xFF4A90E2),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Processando arquivo...',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Validando dados e detectando erros',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Logs em tempo real
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aguardando processamento...',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _logsScrollController,
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      final isSuccess = log.startsWith('✅');
                      final isError = log.startsWith('❌');
                      
                      Color getLogColor() {
                        if (isSuccess) return Colors.greenAccent;
                        if (isError) return Colors.redAccent;
                        return Colors.white70;
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          log,
                          style: TextStyle(
                            color: getLogColor(),
                            fontSize: 12,
                            fontFamily: 'Courier',
                            height: 1.5,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  /// Passo 3: Preview DETALHADO com validações e resumo estrutural
  Widget _buildPasso3Preview() {
    // Processar dados para estatísticas
    final blocosIdentificados = <String>{};
    final unidadesPorBloco = <String, Set<String>>{}; // ✅ USAR SET PARA EVITAR DUPLICATAS NA VISUALIZAÇÃO
    final cpfsProprietarios = <String>{};
    final nomesProprietarios = <String, String>{};
    int totalInquilinos = 0;
    int totalImobiliarias = 0;

    for (var row in _rowsValidas) {
      final nomeBloco = (row.bloco != null && row.bloco!.isNotEmpty) 
          ? row.bloco! 
          : 'Sem Bloco';
      
      blocosIdentificados.add(nomeBloco);
      
      if (!unidadesPorBloco.containsKey(nomeBloco)) {
        unidadesPorBloco[nomeBloco] = <String>{};
      }
      if (row.unidade != null) {
        unidadesPorBloco[nomeBloco]!.add(row.unidade!);
      }

      if (row.proprietarioCpf != null) {
        cpfsProprietarios.add(row.proprietarioCpf!);
        nomesProprietarios[row.proprietarioCpf!] = row.proprietarioNomeCompleto ?? '';
      }

      if (row.inquilinoNomeCompleto != null && row.inquilinoNomeCompleto!.isNotEmpty) {
        totalInquilinos++;
      }

      if (row.nomeImobiliaria != null && row.nomeImobiliaria!.isNotEmpty) {
        totalImobiliarias++;
      }
    }

    // Calcular total real de unidades únicas (soma dos tamanhos dos sets)
    int totalUnidadesUnicas = 0;
    for (var unidades in unidadesPorBloco.values) {
      totalUnidadesUnicas += unidades.length;
    }

    final blocosOrdenados = blocosIdentificados.toList()..sort();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.08),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF4A90E2).withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: Color(0xFF4A90E2),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resultado da Validação',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Confira os dados identificados na planilha',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ════════════════════════════════════════════════════════════════
          // SEÇÃO 1: CARDS DE ESTATÍSTICAS PRINCIPAIS
          // ════════════════════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pie_chart_outline, color: Colors.grey[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Resumo da Planilha',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Cards de estatísticas
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.home_work,
                          color: Colors.blue,
                          label: 'Unidades',
                          value: '$totalUnidadesUnicas', // ✅ USAR TOTAL ÚNICO
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.view_module,
                          color: Colors.orange,
                          label: 'Blocos',
                          value: '${blocosIdentificados.length}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.person,
                          color: Colors.green,
                          label: 'Proprietários',
                          value: '${cpfsProprietarios.length}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.people,
                          color: Colors.purple,
                          label: 'Inquilinos',
                          value: '$totalInquilinos',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.business,
                          color: Colors.teal,
                          label: 'Imobiliárias',
                          value: '$totalImobiliarias',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: _rowsComErro.isEmpty ? Icons.check_circle : Icons.error,
                          color: _rowsComErro.isEmpty ? Colors.green : Colors.red,
                          label: 'Erros',
                          value: '${_rowsComErro.length}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ════════════════════════════════════════════════════════════════
          // SEÇÃO 2: ESTRUTURA DOS BLOCOS E UNIDADES
          // ════════════════════════════════════════════════════════════════
          if (blocosOrdenados.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.apartment, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Estrutura do Condomínio',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Estes blocos e unidades serão criados automaticamente no condomínio.',
                            style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista de blocos
                  ...blocosOrdenados.map((bloco) {
                    final unidadesSet = unidadesPorBloco[bloco] ?? <String>{};
                    final unidades = unidadesSet.toList()..sort();
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ExpansionTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              bloco.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: Colors.blue[700],
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          'Bloco $bloco',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        subtitle: Text(
                          '${unidades.length} unidade${unidades.length != 1 ? 's' : ''}',
                          style: TextStyle(color: Colors.green[700], fontSize: 13),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: unidades.map((u) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Text(
                                  u,
                                  style: TextStyle(fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w500),
                                ),
                              )).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ════════════════════════════════════════════════════════════════
          // SEÇÃO 3: LISTA DE PROPRIETÁRIOS ÚNICOS
          // ════════════════════════════════════════════════════════════════
          if (cpfsProprietarios.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people_alt, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Proprietários Identificados (${cpfsProprietarios.length})',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: cpfsProprietarios.take(5).map((cpf) {
                        final nome = nomesProprietarios[cpf] ?? '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.green[100],
                                child: Icon(Icons.person, size: 18, color: Colors.green[700]),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nome.isNotEmpty ? nome : '(Nome não informado)',
                                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      cpf,
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (cpfsProprietarios.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+ ${cpfsProprietarios.length - 5} proprietário(s) adicional(is)',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ════════════════════════════════════════════════════════════════
          // SEÇÃO 4: ERROS ENCONTRADOS (se houver)
          // ════════════════════════════════════════════════════════════════
          if (_rowsComErro.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700], size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${_rowsComErro.length} linha(s) com problema(s)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Estas linhas NÃO serão importadas. Corrija os erros na planilha ou prossiga sem elas.',
                          style: TextStyle(fontSize: 13, color: Colors.red[700]),
                        ),
                        const SizedBox(height: 16),
                        ..._rowsComErro.map((row) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Linha ${row.linhaNumero}',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red[800]),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Bloco ${row.bloco ?? "-"} | Unidade ${row.unidade ?? "-"}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...row.errosValidacao.map((erro) => Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('• ', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
                                      Expanded(
                                        child: Text(
                                          erro.replaceFirst('Linha ${row.linhaNumero}: ', ''),
                                          style: TextStyle(fontSize: 12, color: Colors.red[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            // Sucesso total
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Todos os dados estão válidos!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_rowsValidas.length} linha(s) pronta(s) para importação.',
                            style: TextStyle(fontSize: 13, color: Colors.green[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Card de estatística para o passo 3
  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Helper method to build stats row in preview
  Widget _buildStatsRow({
    required String label,
    required String value,
    required bool isHighlight,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
            color: isHighlight ? (color ?? Colors.grey[800]) : Colors.grey[800],
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isHighlight ? (color ?? Colors.grey[800]) : Colors.grey[800],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Build preview fields for a row
  List<Widget> _buildRowPreviewFields(ImportacaoRow row) {
    return [
      _buildPreviewField('🏠 Bloco', row.bloco ?? '—'),
      _buildPreviewField('🚪 Unidade', row.unidade ?? '—'),
      _buildPreviewField('📊 Fração Ideal', row.fracaoIdeal ?? '—'),
      const Divider(height: 12),
      _buildPreviewField('👤 Proprietário', row.proprietarioNomeCompleto ?? '—'),
      _buildPreviewField('📱 CPF Proprietário', row.proprietarioCpf ?? '—'),
      _buildPreviewField('📧 Email Proprietário', row.proprietarioEmail ?? '—'),
      const Divider(height: 12),
      if (row.inquilinoNomeCompleto != null) ...[
        _buildPreviewField('👤 Inquilino', row.inquilinoNomeCompleto!),
        _buildPreviewField('📱 CPF Inquilino', row.inquilinoCpf ?? '—'),
        _buildPreviewField('📧 Email Inquilino', row.inquilinoEmail ?? '—'),
      ],
      if (row.nomeImobiliaria != null) ...[
        const Divider(height: 12),
        _buildPreviewField('🏢 Imobiliária', row.nomeImobiliaria!),
        _buildPreviewField('📋 CNPJ Imobiliária', row.cnpjImobiliaria ?? '—'),
      ],
    ];
  }

  /// Build a preview field with label and value
  Widget _buildPreviewField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  /// Passo 4: Confirmação DETALHADA - O que será criado
  Widget _buildPasso4Confirmacao() {
    // Calcular estatísticas para exibição
    final blocosIdentificados = <String>{};
    final unidadesPorBloco = <String, Set<String>>{}; // ✅ USAR SET
    final cpfsProprietarios = <String>{};
    final cpfsInquilinos = <String>{};
    final imobiliarias = <String>{};

    for (var row in _rowsValidas) {
      final nomeBloco = (row.bloco != null && row.bloco!.isNotEmpty) 
          ? row.bloco! 
          : 'Sem Bloco';
      
      blocosIdentificados.add(nomeBloco);
      
      if (!unidadesPorBloco.containsKey(nomeBloco)) {
        unidadesPorBloco[nomeBloco] = <String>{};
      }
      if (row.unidade != null) {
        unidadesPorBloco[nomeBloco]!.add(row.unidade!);
      }

      if (row.proprietarioCpf != null) {
        cpfsProprietarios.add(row.proprietarioCpf!);
      }

      if (row.inquilinoCpf != null) {
        cpfsInquilinos.add(row.inquilinoCpf!);
      }

      if (row.nomeImobiliaria != null && row.nomeImobiliaria!.isNotEmpty) {
        imobiliarias.add(row.nomeImobiliaria!);
      }
    }

    // Calcular total real de unidades únicas
    int totalUnidadesUnicas = 0;
    for (var unidades in unidadesPorBloco.values) {
      totalUnidadesUnicas += unidades.length;
    }

    // Preparar lista ordenada de blocos para exibição
    final blocosOrdenados = blocosIdentificados.toList()..sort();

    return Column(
      children: [
        // Header section
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            border: Border(
              bottom: BorderSide(
                color: Colors.green.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.playlist_add_check,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pronto para Importar',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Confira o que será criado no sistema',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══════════════════════════════════════════════════════════
                // CARD: DESTINO DA IMPORTAÇÃO
                // ═══════════════════════════════════════════════════════════
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[800]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.apartment, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Importando para:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.condominioNome,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════
                // TÍTULO: O que será criado
                // ═══════════════════════════════════════════════════════════
                Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.green[700], size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'O que será criado:',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildCreationItem(
                  icon: Icons.view_module,
                  color: Colors.orange,
                  title: '${blocosIdentificados.length} Bloco(s)',
                  subtitle: blocosIdentificados.join(', '),
                ),
                _buildCreationItem(
                  icon: Icons.home_work,
                  color: Colors.blue,
                  title: '$totalUnidadesUnicas Unidade(s)',
                  subtitle: 'Distribuídas nos blocos acima',
                ),
                // ... (outros itens do resumo mantidos acima, se houver)

                const SizedBox(height: 32),

                // ═══════════════════════════════════════════════════════════
                // DETALHAMENTO POR BLOCO
                // ═══════════════════════════════════════════════════════════
                Row(
                  children: [
                    Icon(Icons.list_alt, color: Colors.blue[800], size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Detalhamento por Unidade',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Iterar Blocos
                ...blocosOrdenados.map((bloco) {
                  // Filtrar linhas deste bloco
                  final rowsBloco = _rowsValidas.where((r) => 
                    (r.bloco != null && r.bloco!.isNotEmpty ? r.bloco! : 'Sem Bloco') == bloco
                  ).toList();

                  // Agrupar por Unidade (Set para garantir ordem e unicidade de visualização)
                  final unidadesDoBloco = rowsBloco
                      .map((r) => r.unidade ?? '')
                      .where((u) => u.isNotEmpty)
                      .toSet()
                      .toList()..sort();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      shape: const Border(), // Remove borda interna do ExpansionTile
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          bloco.isNotEmpty ? bloco.substring(0, 1).toUpperCase() : '?',
                          style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        'Bloco $bloco',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text('${unidadesDoBloco.length} unidades'),
                      children: unidadesDoBloco.map((unidade) {
                        // Pegar rows desta unidade
                        final rowsUnidade = rowsBloco.where((r) => r.unidade == unidade).toList();
                        // Pegar o primeiro proprietário (ou iterar se houver múltiplos distintos)
                        final rowPrincipal = rowsUnidade.first; 

                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey[200]!),
                            ),
                            color: Colors.grey[50], // Fundo leve para diferenciar
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cabeçalho da Unidade
                              Row(
                                children: [
                                  Icon(Icons.door_front_door, size: 20, color: Colors.blue[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Unidade $unidade',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Detalhes da Unidade (Proprietário, etc)
                              // Se houver multi-proprietários distintos na mesma unidade, listar todos
                              ...rowsUnidade.map((row) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildEntityDetail(
                                      'Proprietário',
                                      row.proprietarioNomeCompleto,
                                      row.proprietarioCpf,
                                      row.proprietarioEmail,
                                      Icons.person,
                                      Colors.blue,
                                    ),
                                    if (row.inquilinoNomeCompleto != null)
                                      _buildEntityDetail(
                                        'Inquilino',
                                        row.inquilinoNomeCompleto,
                                        row.inquilinoCpf,
                                        row.inquilinoEmail,
                                        Icons.person_outline,
                                        Colors.purple,
                                      ),
                                    if (row.nomeImobiliaria != null)
                                      _buildEntityDetail(
                                        'Imobiliária',
                                        row.nomeImobiliaria,
                                        row.cnpjImobiliaria,
                                        row.emailImobiliaria,
                                        Icons.business,
                                        Colors.teal,
                                      ),
                                     const SizedBox(height: 8), // Espaçamento entre registros da mesma unidade
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════
                // INFO BOX: CREDENCIAIS (Mantido)
                // ═══════════════════════════════════════════════════════════
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.key, color: Colors.blue[700], size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Credenciais de Acesso',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Senhas temporárias serão geradas automaticamente para cada proprietário e inquilino.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[600], size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'As senhas serão exibidas no resultado da importação. Salve ou anote elas!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ═══════════════════════════════════════════════════════════
                // WARNING BOX: LINHAS IGNORADAS (se houver)
                // ═══════════════════════════════════════════════════════════
                if (_rowsComErro.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_rowsComErro.length} linha(s) serão ignoradas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Essas linhas contêm erros e não serão importadas.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════
                // CONFIRMAÇÃO FINAL
                // ═══════════════════════════════════════════════════════════
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tudo pronto!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Clique em "Importar Agora" para iniciar o processo.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Widget para item da lista de criação
  Widget _buildCreationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green[400], size: 22),
        ],
      ),
    );
  }

  /// Helper method to build confirmation info row
  Widget _buildConfirmationRow({
    required String label,
    required String value,
    bool highlight = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
            color: highlight ? (color ?? Colors.grey[800]) : Colors.grey[800],
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: highlight ? (color ?? Colors.grey[800]) : Colors.grey[800],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Passo 5: Resultado final da importação
  Widget _buildPasso5Resultado() {
    // Se importação ainda está em andamento
    if (_importacaoEmAndamento || _resultadoImportacao == null) {
      return Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              border: Border(
                bottom: BorderSide(
                  color: Colors.blue.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Importação em Andamento',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Processando dados no Supabase...',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Logs
          Expanded(
            child: SingleChildScrollView(
              controller: _logsScrollController,
              padding: const EdgeInsets.all(20),
              child: Text(
                _logs.join('\n'),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Importação concluída - mostrar resultado
    final sucesso = _resultadoImportacao!['sucesso'] as bool? ?? false;
    final linhasComSucesso = _resultadoImportacao!['linhasComSucesso'] as int? ?? 0;
    final linhasComErro = _resultadoImportacao!['linhasComErro'] as int? ?? 0;
    final tempo = _resultadoImportacao!['tempo'] as int? ?? 0;
    final senhas = _resultadoImportacao!['senhas'] as List? ?? [];
    final resultados = _resultadoImportacao!['resultados'] as List? ?? [];

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: sucesso ? Colors.green.withOpacity(0.08) : Colors.orange.withOpacity(0.08),
            border: Border(
              bottom: BorderSide(
                color: sucesso ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: sucesso ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  sucesso ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: sucesso ? Colors.green : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sucesso ? 'Importação Concluída' : 'Importação Concluída com Erros',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: sucesso ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sucesso
                          ? 'Todos os dados foram importados com sucesso'
                          : '$linhasComErro linhas com erro(s) durante importação',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: sucesso ? Colors.green[50] : Colors.orange[50],
                    border: Border.all(
                      color: sucesso ? Colors.green[200]! : Colors.orange[200]!,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildResultRow(
                        icon: '✅',
                        label: 'Com Sucesso:',
                        value: '$linhasComSucesso',
                        color: Colors.green,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          color: sucesso ? Colors.green[200] : Colors.orange[200],
                        ),
                      ),
                      _buildResultRow(
                        icon: '❌',
                        label: 'Com Erro:',
                        value: '$linhasComErro',
                        color: Colors.red,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          color: sucesso ? Colors.green[200] : Colors.orange[200],
                        ),
                      ),
                      _buildResultRow(
                        icon: '⏱️',
                        label: 'Tempo Total:',
                        value: '${tempo}s',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Senhas geradas
                if (senhas.isNotEmpty) ...[
                  Text(
                    '🔐 Senhas Temporárias Geradas',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      border: Border.all(color: Colors.blue[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: senhas.length,
                      itemBuilder: (context, index) {
                        final senha = senhas[index] as Map;
                        final linhaNum = senha['linhaNumero'] ?? 'N/A';
                        final senhaProp = senha['senhaProprietario'] ?? '—';
                        final senhaInq = senha['senhaInquilino'];
                        
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: index < senhas.length - 1
                                ? Border(
                              bottom: BorderSide(
                                color: Colors.blue[100]!,
                              ),
                            )
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Linha $linhaNum',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildSenhaField('Proprietário:', senhaProp),
                              if (senhaInq != null) ...[
                                const SizedBox(height: 4),
                                _buildSenhaField('Inquilino:', senhaInq),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Erros (se houver)
                if (linhasComErro > 0) ...[
                  Text(
                    '⚠️ Linhas com Erro',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: resultados.length,
                      itemBuilder: (context, index) {
                        final resultado = resultados[index] as Map;
                        final temErro = resultado['sucesso'] != true;
                        
                        if (!temErro) return const SizedBox.shrink();

                        final linhaNum = resultado['linhaNumero'] ?? 'N/A';
                        final erro = resultado['erro'] ?? 'Erro desconhecido';
                        final erros = resultado['erros'] as List?;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: index < resultados.length - 1
                                ? Border(
                              bottom: BorderSide(
                                color: Colors.red[100]!,
                              ),
                            )
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Linha $linhaNum: $erro',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.red,
                                ),
                              ),
                              if (erros != null && erros.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ...(erros.cast<String>()).map((e) => Padding(
                                  padding: const EdgeInsets.only(left: 8, top: 4),
                                  child: Text(
                                    '• $e',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                )),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Logs
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📋 Logs Detalhados',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: SingleChildScrollView(
                          controller: _logsScrollController,
                          child: Text(
                            _logs.join('\n'),
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              color: Colors.grey[700],
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
        ),
      ],
    );
  }

  /// Helper para exibir campo de senha
  Widget _buildSenhaField(String label, String senha) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.blue[100]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  senha,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper method to build result row
  Widget _buildResultRow({
    required String icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: 13,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.green[700],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Build tela de erro
  Widget _buildErro() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            'Erro ao processar',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.red,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _mensagemErro ?? 'Erro desconhecido',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Build footer com botões de ação
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão Voltar (esquerda)
          if (_passoAtual > 1 && _passoAtual < 5)
            TextButton.icon(
              onPressed: _voltarPasso,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            )
          else if (_passoAtual < 5)
            SizedBox(
              width: 100,
              child: TextButton.icon(
                onPressed: _fechar,
                icon: const Icon(Icons.close),
                label: const Text('Fechar'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            )
          else
            const SizedBox(width: 100),

          // Espaço flexível
          Expanded(
            child: SizedBox.shrink(),
          ),

          // Botão principal (direita)
          if (_passoAtual == 1)
            ElevatedButton.icon(
              onPressed: _selecionarArquivo,
              icon: const Icon(Icons.folder_open),
              label: const Text('Selecionar Arquivo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            )
          else if (_passoAtual == 3)
            ElevatedButton.icon(
              onPressed: _rowsValidas.isEmpty ? null : _mapearDados,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Prosseguir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _rowsValidas.isEmpty ? Colors.grey : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            )
          else if (_passoAtual == 4)
            ElevatedButton.icon(
              onPressed: _dadosMapeados == null ? null : _executarImportacaoCompleta,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Confirmar Importação'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _dadosMapeados == null ? Colors.grey : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            )
          else if (_passoAtual == 5)
            ElevatedButton.icon(
              onPressed: _fechar,
              icon: const Icon(Icons.done),
              label: const Text('Concluir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            )
          else
            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: _passoAtual == 2 ? null : null,
                icon: const Icon(Icons.hourglass_bottom),
                label: const Text('Processando...'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Helper para construir detalhe de entidade
  Widget _buildEntityDetail(
    String label,
    String? nome,
    String? doc,
    String? email,
    IconData icon,
    MaterialColor color,
  ) {
    if (nome == null || nome.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color[700]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color[700],
                  ),
                ),
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (doc != null && doc.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      doc,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                if (email != null && email.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                        decoration: TextDecoration.underline,
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

  /// Mensagem de carregamento dinâmica
  String _obterMensagemCarregamento() {
    switch (_passoAtual) {
      case 2:
        return 'Validando dados...';
      case 3:
        return 'Detectando duplicatas...';
      case 4:
        return 'Mapeando entidades...';
      default:
        return 'Processando...';
    }
  }
}
