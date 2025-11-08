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

      // Avançar para resultado
      _avancarPasso();
    } catch (e) {
      _adicionarLog('❌ ERRO ao mapear: $e');
      setState(() {
        _carregando = false;
        _mensagemErro = 'Erro ao mapear dados: $e';
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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

          // Conteúdo do passo atual
          Expanded(
            child: _buildConteudoPasso(),
          ),

          // Footer com botões
          _buildFooter(),
        ],
      ),
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

  /// Passo 3: Preview com validações
  Widget _buildPasso3Preview() {
    return Column(
      children: [
        // Header section
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
                  Icons.preview,
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
                      'Visualizar Dados',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Revise os dados antes de confirmar',
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

        // Summary Statistics
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.06),
              border: Border.all(
                color: const Color(0xFF4A90E2).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildStatsRow(
                  label: 'Total de linhas:',
                  value: '${_rowsValidadas?.length ?? 0}',
                  isHighlight: false,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                  ),
                ),
                _buildStatsRow(
                  label: '✅ Linhas válidas:',
                  value: '${_rowsValidas.length}',
                  isHighlight: true,
                  color: Colors.green,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                  ),
                ),
                _buildStatsRow(
                  label: '❌ Linhas com erro:',
                  value: '${_rowsComErro.length}',
                  isHighlight: true,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),

        // Errors section (if any)
        if (_rowsComErro.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '❌ Erros Encontrados',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              itemCount: _rowsComErro.length,
              itemBuilder: (context, index) {
                final row = _rowsComErro[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[200]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Linha ${row.linhaNumero}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...row.errosValidacao.map(
                        (erro) => Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            '• ${erro.replaceFirst('Linha ${row.linhaNumero}: ', '')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
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
        ] else ...[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 56,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '✅ Dados Validados!',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Todas as ${_rowsValidas.length} linhas estão válidas',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
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

  /// Passo 4: Confirmação
  Widget _buildPasso4Confirmacao() {
    return Column(
      children: [
        // Header section
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
                  Icons.done_outline,
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
                      'Confirmar Importação',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Revise os detalhes antes de prosseguir',
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
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info,
                    size: 48,
                    color: Color(0xFF4A90E2),
                  ),
                ),
                const SizedBox(height: 16),

                // Main message
                Text(
                  'Confirmar Dados',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Summary container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.06),
                    border: Border.all(
                      color: const Color(0xFF4A90E2).withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildConfirmationRow(
                        label: '🏢 Condomínio:',
                        value: widget.condominioNome,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          color: const Color(0xFF4A90E2).withOpacity(0.1),
                        ),
                      ),
                      _buildConfirmationRow(
                        label: '✅ Linhas a importar:',
                        value: '${_rowsValidas.length}',
                        highlight: true,
                        color: Colors.green,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          color: const Color(0xFF4A90E2).withOpacity(0.1),
                        ),
                      ),
                      _buildConfirmationRow(
                        label: '❌ Linhas ignoradas:',
                        value: '${_rowsComErro.length}',
                        highlight: _rowsComErro.isNotEmpty,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Confirmation message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    border: Border.all(color: Colors.amber[300]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Deseja prosseguir com a importação?',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Colors.amber[900],
                                fontWeight: FontWeight.w500,
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

  /// Passo 5: Resultado final
  Widget _buildPasso5Resultado() {
    if (_dadosMapeados == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final proprietarios = _dadosMapeados!['proprietarios'] as List?;
    final inquilinos = _dadosMapeados!['inquilinos'] as List?;
    final blocos = _dadosMapeados!['blocos'] as List?;
    final imobiliarias = _dadosMapeados!['imobiliarias'] as List?;

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
                  Icons.check_circle,
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
                      'Importação Preparada',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dados validados e prontos',
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
              children: [
                // Success icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 56,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  '✅ Dados Prontos para Salvar',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Summary container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(
                      color: Colors.green[200]!,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildResultRow(
                        icon: '👤',
                        label: 'Proprietários:',
                        value: '${proprietarios?.length ?? 0}',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          color: Colors.green[200],
                        ),
                      ),
                      _buildResultRow(
                        icon: '🏠',
                        label: 'Inquilinos:',
                        value: '${inquilinos?.length ?? 0}',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          color: Colors.green[200],
                        ),
                      ),
                      _buildResultRow(
                        icon: '🏘️',
                        label: 'Blocos:',
                        value: '${blocos?.length ?? 0}',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          height: 1,
                          color: Colors.green[200],
                        ),
                      ),
                      _buildResultRow(
                        icon: '🏢',
                        label: 'Imobiliárias:',
                        value: '${imobiliarias?.length ?? 0}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Note about passwords
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    border: Border.all(color: Colors.amber[300]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'As senhas serão geradas e exibidas após a conclusão.',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Colors.amber[900],
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

  /// Helper method to build result row
  Widget _buildResultRow({
    required String icon,
    required String label,
    required String value,
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
            color: Colors.green[700],
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              onPressed: () async {
                if (widget.onImportarConfirmado != null && _dadosMapeados != null) {
                  await widget.onImportarConfirmado!(_dadosMapeados!);
                }
              },
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Importar Agora'),
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
