import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
// Imports condicionais para web
import 'dart:html' as html show Blob, Url, AnchorElement;
import 'detalhes_unidade_screen.dart';
import '../services/unidade_service.dart';
import '../models/bloco_com_unidades.dart';
import '../widgets/editable_text_widget.dart';
import '../widgets/confirmation_dialog.dart';

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
  String? _errorMessage;
  
  // Controle de operações em andamento
  Set<String> _blocosEditando = {};
  Set<String> _unidadesEditando = {};
  Set<String> _blocosExcluindo = {};
  Set<String> _unidadesExcluindo = {};

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
      // Carrega os dados do banco
      final blocosUnidades = await _unidadeService.listarUnidadesCondominio(widget.condominioId!);
      setState(() {
        _blocosUnidades = blocosUnidades;
        _blocosUnidadesFiltrados = blocosUnidades;
        _isLoading = false;
      });
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



  // Métodos para edição de blocos e unidades
  Future<void> _editarBloco(String blocoId, String novoNome) async {
    setState(() {
      _blocosEditando.add(blocoId);
    });

    try {
      final sucesso = await _unidadeService.editarBloco(blocoId, novoNome);
      if (sucesso) {
        await _carregarDados(); // Recarrega os dados para refletir a mudança
      } else {
        throw Exception('Falha ao editar bloco');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao editar bloco: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _blocosEditando.remove(blocoId);
      });
    }
  }

  Future<void> _editarUnidade(String unidadeId, String novoNome) async {
    setState(() {
      _unidadesEditando.add(unidadeId);
    });

    try {
      final sucesso = await _unidadeService.editarUnidade(unidadeId, novoNome);
      if (sucesso) {
        await _carregarDados(); // Recarrega os dados para refletir a mudança
      } else {
        throw Exception('Falha ao editar unidade');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao editar unidade: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _unidadesEditando.remove(unidadeId);
      });
    }
  }

  // Métodos para exclusão de blocos e unidades
  Future<void> _excluirBloco(String blocoId, String nomeBloco, int quantidadeUnidades) async {
    final confirmado = await ConfirmationDialog.showDeleteBlocoDialog(
      context: context,
      nomeBloco: nomeBloco,
      quantidadeUnidades: quantidadeUnidades,
    );

    if (!confirmado) return;

    setState(() {
      _blocosExcluindo.add(blocoId);
    });

    try {
      final sucesso = await _unidadeService.deletarBloco(blocoId);
      if (sucesso) {
        await _carregarDados();
        await _verificarSeNecessitaReconfiguracao();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bloco excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Falha ao excluir bloco');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir bloco: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _blocosExcluindo.remove(blocoId);
      });
    }
  }

  Future<void> _excluirUnidade(String unidadeId, String nomeUnidade, String nomeBloco) async {
    final confirmado = await ConfirmationDialog.showDeleteUnidadeDialog(
      context: context,
      nomeUnidade: nomeUnidade,
      nomeBloco: nomeBloco,
    );

    if (!confirmado) return;

    setState(() {
      _unidadesExcluindo.add(unidadeId);
    });

    try {
      final sucesso = await _unidadeService.deletarUnidade(unidadeId);
      if (sucesso) {
        await _carregarDados();
        await _verificarSeNecessitaReconfiguracao();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unidade excluída com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Falha ao excluir unidade');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir unidade: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _unidadesExcluindo.remove(unidadeId);
      });
    }
  }

  // Verifica se todas as unidades foram excluídas e oferece reconfiguração
  Future<void> _verificarSeNecessitaReconfiguracao() async {
    if (widget.condominioId == null) return;

    try {
      final existemUnidades = await _unidadeService.verificarSeExistemUnidades(widget.condominioId!);
      
      if (!existemUnidades) {
        final desejaReconfigurar = await ConfirmationDialog.showReconfigurationDialog(
          context: context,
        );

        if (desejaReconfigurar) {
          // Remove a configuração atual
          await _unidadeService.removerConfiguracaoCondominio(widget.condominioId!);
          // Recarrega a tela para mostrar a opção de configuração
          _carregarDados();
        }
      }
    } catch (e) {
      print('Erro ao verificar necessidade de reconfiguração: $e');
    }
  }

  // Função para download do template da planilha
  Future<void> _downloadTemplate() async {
    try {
      // Mostra indicador de carregamento
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Preparando download...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Carrega o arquivo template dos assets
      final ByteData data = await rootBundle.load('Template_Unidade_Morador_Condogaia_V1.xlsx');
      final Uint8List bytes = data.buffer.asUint8List();

      if (kIsWeb) {
        // Download para Flutter Web
        await _downloadForWeb(bytes);
      } else {
        // Download para plataformas móveis
        await _downloadForMobile(bytes);
      }
    } catch (e) {
      // Mostra mensagem de erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar template: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Método específico para download no Flutter Web
  Future<void> _downloadForWeb(Uint8List bytes) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'Template_Unidade_Morador_Condogaia_V1.xlsx')
      ..click();
    html.Url.revokeObjectUrl(url);

    // Mostra mensagem de sucesso
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Template baixado com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  // Método específico para download em plataformas móveis
  Future<void> _downloadForMobile(Uint8List bytes) async {
    // Obtém o diretório de downloads
    Directory? downloadsDirectory;
    if (Platform.isAndroid) {
      downloadsDirectory = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      downloadsDirectory = await getApplicationDocumentsDirectory();
    } else {
      downloadsDirectory = await getDownloadsDirectory();
    }

    if (downloadsDirectory != null) {
      // Cria o arquivo no diretório de downloads
      final String fileName = 'Template_Unidade_Morador_Condogaia_V1.xlsx';
      final File file = File('${downloadsDirectory.path}/$fileName');
      
      await file.writeAsBytes(bytes);

      // Mostra mensagem de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template baixado com sucesso!\nSalvo em: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } else {
      throw Exception('Não foi possível acessar o diretório de downloads');
    }
  }

  // Mostra diálogo para edição de unidade
  Future<void> _mostrarDialogoEdicaoUnidade(String unidadeId, String nomeAtual) async {
    final controller = TextEditingController(text: nomeAtual);
    
    final novoNome = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Unidade'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome da unidade',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nome = controller.text.trim();
              if (nome.isNotEmpty && nome != nomeAtual) {
                Navigator.of(context).pop(nome);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (novoNome != null) {
      await _editarUnidade(unidadeId, novoNome);
    }
    
    controller.dispose();
  }

  Widget _buildUnidadeButton(
    String numero, 
    String bloco, 
    String unidadeId, 
    String nomeBloco
  ) {
    final isEditando = _unidadesEditando.contains(unidadeId);
    final isExcluindo = _unidadesExcluindo.contains(unidadeId);

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: ElevatedButton(
        onPressed: isEditando || isExcluindo ? null : () {
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
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(80, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEditando || isExcluindo)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                numero,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlocoSection(BlocoComUnidades blocoComUnidades) {
    final bloco = blocoComUnidades.bloco;
    final unidades = blocoComUnidades.unidades;
    final isEditandoBloco = _blocosEditando.contains(bloco.id);
    final isExcluindoBloco = _blocosExcluindo.contains(bloco.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do bloco com nome editável e ações
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: EditableTextWidget(
                    initialText: bloco.nome,
                    onSave: (novoNome) => _editarBloco(bloco.id, novoNome),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3A59),
                    ),
                    hintText: 'Nome do bloco',
                    enabled: !isEditandoBloco && !isExcluindoBloco,
                  ),
                ),
                const SizedBox(width: 8),
                // Estatísticas de ocupação
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                const SizedBox(width: 8),
                // Botões de ação do bloco
                if (isEditandoBloco || isExcluindoBloco)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF757575),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'excluir':
                          _excluirBloco(bloco.id, bloco.nome, unidades.length);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'excluir',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir Bloco', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Unidades do bloco
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Wrap(
              children: unidades.map((unidade) => 
                _buildUnidadeButton(
                  unidade.numero, 
                  bloco.nome,
                  unidade.id,
                  bloco.nome,
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

            // Botão de download do template
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _downloadTemplate,
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Baixar Template da Planilha'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo principal
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
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

    // Exibir mensagem informativa em vez dos dados dos blocos e unidades
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.apartment,
                size: 80,
                color: Color(0xFF4A90E2).withOpacity(0.6),
              ),
              const SizedBox(height: 24),
              Text(
                'Gestão de Unidades e Moradores',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E3A59),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Use o template da planilha acima para importar e gerenciar os dados das unidades e moradores do condomínio.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Color(0xFF4A90E2).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFF4A90E2).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF4A90E2),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Como usar:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep('1', 'Baixe o template da planilha'),
                    _buildInstructionStep('2', 'Preencha os dados das unidades'),
                    _buildInstructionStep('3', 'Importe a planilha no sistema'),
                  ],
                ),
              ),
              const SizedBox(height: 24), // Espaçamento adicional no final
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}