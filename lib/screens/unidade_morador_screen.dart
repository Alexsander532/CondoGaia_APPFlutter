import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:typed_data';
import 'detalhes_unidade_screen.dart';
import '../services/unidade_service.dart';
import '../services/template_service.dart';
import '../models/bloco_com_unidades.dart';
import '../models/bloco.dart';
import '../widgets/editable_text_widget.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/importacao_modal_widget.dart';
import '../widgets/modal_criar_unidade_widget.dart';
import '../services/condominio_init_service.dart';

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
  final CondominioInitService _condominioInitService = CondominioInitService();

  List<BlocoComUnidades> _blocosUnidades = [];
  List<BlocoComUnidades> _blocosUnidadesFiltrados = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _temBlocos = true; // Flag que vem do banco
  bool _atualizandoTemBlocos = false; // Flag para indicar que está atualizando

  // Controle de operações em andamento
  Set<String> _blocosEditando = {};
  Set<String> _unidadesEditando = {};
  Set<String> _blocosExcluindo = {};
  Set<String> _unidadesExcluindo = {};

  @override
  void initState() {
    print('📱 [UnidadeMoradorScreen] initState() chamado');
    print(
      '📱 [UnidadeMoradorScreen] condominioId recebido: ${widget.condominioId}',
    );
    print(
      '📱 [UnidadeMoradorScreen] condominioNome recebido: ${widget.condominioNome}',
    );
    print(
      '📱 [UnidadeMoradorScreen] condominioCnpj recebido: ${widget.condominioCnpj}',
    );
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
    print(
      '📱 [UnidadeMoradorScreen] ===== INICIANDO CARREGAMENTO DE DADOS =====',
    );
    print('📱 [UnidadeMoradorScreen] condominioId: ${widget.condominioId}');
    print('📱 [UnidadeMoradorScreen] condominioNome: ${widget.condominioNome}');

    if (widget.condominioId == null) {
      print('❌ [UnidadeMoradorScreen] ERRO: ID do condomínio é NULL');
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
      print(
        '🔄 [UnidadeMoradorScreen] Chamando listarUnidadesCondominio com ID: ${widget.condominioId!}',
      );

      // Carrega os dados do banco
      final blocosUnidades = await _unidadeService.listarUnidadesCondominio(
        widget.condominioId!,
      );

      // Carrega o flag tem_blocos do condomínio
      final temBlocos = await _carregarTemBlocos();

      print('✅ [UnidadeMoradorScreen] Dados carregados com sucesso!');
      print(
        '📊 [UnidadeMoradorScreen] Total de blocos retornados: ${blocosUnidades.length}',
      );
      print('📊 [UnidadeMoradorScreen] tem_blocos: $temBlocos');

      // Log detalhado de cada bloco
      for (int i = 0; i < blocosUnidades.length; i++) {
        final bloco = blocosUnidades[i];
        print(
          '   Bloco $i: ${bloco.bloco.nome} - ${bloco.unidades.length} unidades',
        );
        for (int j = 0; j < bloco.unidades.length; j++) {
          final unidade = bloco.unidades[j];
          print('      Unidade ${j + 1}: ${unidade.numero} (${unidade.id})');
        }
      }

      setState(() {
        _blocosUnidades = blocosUnidades;
        _blocosUnidadesFiltrados = blocosUnidades;
        _temBlocos = temBlocos;
        _isLoading = false;
      });
      print('✅ [UnidadeMoradorScreen] Estado atualizado com sucesso!');
    } catch (e, stackTrace) {
      print('❌ [UnidadeMoradorScreen] ERRO ao carregar dados: $e');
      print('📋 [UnidadeMoradorScreen] Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'Erro ao carregar dados: $e';
        _isLoading = false;
      });
    }
  }

  /// Carrega o flag tem_blocos do banco de dados
  Future<bool> _carregarTemBlocos() async {
    try {
      if (widget.condominioId == null)
        return true; // Default true se não houver ID

      final condominio = await _unidadeService.obterCondominioById(
        widget.condominioId!,
      );
      return condominio?.temBlocos ?? true; // Default true se não encontrar
    } catch (e) {
      print('⚠️ Erro ao carregar tem_blocos: $e');
      return true; // Fallback para true em caso de erro
    }
  }

  /// Atualiza o flag tem_blocos no banco
  Future<void> _alternarTemBlocos(bool novoValor) async {
    if (widget.condominioId == null) return;

    setState(() {
      _atualizandoTemBlocos = true;
    });

    try {
      print('🔄 Alternando tem_blocos para $novoValor');

      await _condominioInitService.atualizarTemBlocos(
        widget.condominioId!,
        novoValor,
      );

      setState(() {
        _temBlocos = novoValor;
        _atualizandoTemBlocos = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              novoValor
                  ? '✅ Condomínio com blocos ativado'
                  : '✅ Exibição sem blocos ativada',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Erro ao atualizar tem_blocos: $e');
      setState(() {
        _atualizandoTemBlocos = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar configuração: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filtrarUnidades() {
    final termo = _searchController.text.trim().toLowerCase();

    if (termo.isEmpty) {
      setState(() {
        _blocosUnidadesFiltrados = _blocosUnidades;
      });
      return;
    }

    final List<BlocoComUnidades> filtrados = [];

    for (var blocoComUnidades in _blocosUnidades) {
      // Verifica se o nome ou código do bloco contém o termo
      final blocoMatches =
          blocoComUnidades.bloco.nome.toLowerCase().contains(termo) ||
          blocoComUnidades.bloco.codigo.toLowerCase().contains(termo);

      if (blocoMatches) {
        // Se o bloco corresponde ao termo (ex: "Bloco A"), incluímos o bloco inteiro com todas as suas unidades.
        filtrados.add(blocoComUnidades);
      } else {
        // Se o bloco NÃO corresponde, verificamos se alguma unidade interna corresponde (ex: "101")
        final unidadesFiltradas = blocoComUnidades.unidades.where((unidade) {
          return unidade.numero.toLowerCase().contains(termo);
        }).toList();

        // Se houver unidades que correspondem, criamos uma nova instância do bloco contendo APENAS essas unidades
        if (unidadesFiltradas.isNotEmpty) {
          filtrados.add(
            BlocoComUnidades(
              bloco: blocoComUnidades.bloco,
              unidades: unidadesFiltradas,
            ),
          );
        }
      }
    }

    setState(() {
      _blocosUnidadesFiltrados = filtrados;
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
  Future<void> _excluirBloco(
    String blocoId,
    String nomeBloco,
    int quantidadeUnidades,
  ) async {
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

  Future<void> _excluirUnidade(
    String unidadeId,
    String nomeUnidade,
    String nomeBloco,
  ) async {
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

  /// Abre o modal para criar uma nova unidade
  Future<void> _abrirModalCriarUnidade() async {
    if (widget.condominioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID do condomínio não informado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ModalCriarUnidadeWidget(
        condominioId: widget.condominioId!,
        blocosExistentes: _blocosUnidades,
        temBlocos: _temBlocos,
      ),
    );

    if (resultado != null && mounted) {
      _processarCriacaoUnidade(resultado);
    }
  }

  /// Processa a criação da unidade após seleção no modal
  Future<void> _processarCriacaoUnidade(Map<String, dynamic> dados) async {
    try {
      final numero = dados['numero'] as String;
      final bloco = dados['bloco'] as Bloco;

      // Mostrar loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Criando unidade...'),
            ],
          ),
          duration: Duration(minutes: 5), // Mantém até navegar
        ),
      );

      // Criar unidade rápida
      await _unidadeService.criarUnidadeRapida(
        condominioId: widget.condominioId!,
        numero: numero,
        bloco: bloco,
      );

      if (mounted) {
        // Fecha o snackbar de carregamento
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Recarrega os dados para mostrar a nova unidade
        await _carregarDados();

        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Unidade ${numero} criada com sucesso!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar unidade: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Verifica se todas as unidades foram excluídas e oferece reconfiguração
  Future<void> _verificarSeNecessitaReconfiguracao() async {
    if (widget.condominioId == null) return;

    try {
      final existemUnidades = await _unidadeService.verificarSeExistemUnidades(
        widget.condominioId!,
      );

      if (!existemUnidades) {
        final desejaReconfigurar =
            await ConfirmationDialog.showReconfigurationDialog(
              context: context,
            );

        if (desejaReconfigurar) {
          // Remove a configuração atual
          await _unidadeService.removerConfiguracaoCondominio(
            widget.condominioId!,
          );
          // Recarrega a tela para mostrar a opção de configuração
          _carregarDados();
        }
      }
    } catch (e) {
      print('Erro ao verificar necessidade de reconfiguração: $e');
    }
  }

  // Função para download do template da planilha via Supabase
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

      // Carrega o arquivo template ODS dos assets
      final ByteData data = await rootBundle.load(
        'assets/Template_Unidade_Morador_Condogaia_V1.ods',
      );
      final Uint8List bytes = data.buffer.asUint8List();

      // Faz upload para Supabase e obtém URL pública
      final String downloadUrl = await TemplateService.uploadTemplateODS(bytes);

      if (kIsWeb) {
        // Download para Flutter Web - usa URL do Supabase
        await _downloadForWebViaUrl(downloadUrl);
      } else {
        // Download para plataformas móveis - salva no disco
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

  // Método específico para download no Flutter Web via URL do Supabase
  Future<void> _downloadForWebViaUrl(String downloadUrl) async {
    try {
      if (kIsWeb) {
        // Usa url_launcher para abrir a URL do Supabase
        // O navegador faz o download automaticamente
        final Uri uri = Uri.parse(downloadUrl);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Não foi possível abrir a URL');
        }

        // Mostra mensagem de sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Template baixado! Verifique a pasta Downloads.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar arquivo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      print('Erro no download: $e');
    }
  }

  // Método específico para download em plataformas móveis
  Future<void> _downloadForMobile(Uint8List bytes) async {
    try {
      // Verifica se o arquivo não está vazio ou corrompido
      if (bytes.isEmpty) {
        throw Exception('Arquivo template está vazio');
      }

      // Verifica se é um arquivo ODS válido (deve começar com PK)
      if (bytes.length < 4 || bytes[0] != 0x50 || bytes[1] != 0x4B) {
        throw Exception('Arquivo template não é um ODS válido');
      }

      // Obtém o diretório de downloads
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        // Verifica se o diretório de downloads existe
        downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!await downloadsDirectory.exists()) {
          // Tenta diretório alternativo
          downloadsDirectory = Directory('/sdcard/Download');
          if (!await downloadsDirectory.exists()) {
            // Usa diretório de documentos da aplicação
            downloadsDirectory = await getApplicationDocumentsDirectory();
          }
        }
      } else if (Platform.isIOS) {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      } else {
        downloadsDirectory = await getDownloadsDirectory();
      }

      if (downloadsDirectory != null && await downloadsDirectory.exists()) {
        // Gera nome único para evitar sobrescrever
        final String timestamp = DateTime.now().millisecondsSinceEpoch
            .toString();
        final String fileName =
            'Template_Unidade_Morador_Condogaia_V1_$timestamp.ods';
        final File file = File('${downloadsDirectory.path}/$fileName');

        // Escreve o arquivo com verificação de integridade
        await file.writeAsBytes(bytes, flush: true);

        // Verifica se o arquivo foi escrito corretamente
        final savedBytes = await file.readAsBytes();
        if (savedBytes.length != bytes.length) {
          await file.delete();
          throw Exception('Erro na escrita do arquivo - tamanhos diferentes');
        }

        // Mostra mensagem de sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Template baixado com sucesso!\nSalvo em: ${file.path}',
              ),
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
    } catch (e) {
      // Re-lança a exceção para ser tratada no método principal
      throw Exception('Erro no download móvel: $e');
    }
  }

  Future<void> _importarPlanilha() async {
    try {
      // Mostrar o modal de importação como bottom sheet
      final resultado = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return ImportacaoModalWidget(
            condominioId: widget.condominioId ?? 'sem-id',
            condominioNome: widget.condominioNome ?? 'Condomínio',
            cpfsExistentes: const {}, // Todo: implementar cache se necessário
            emailsExistentes: const {},
            onImportarConfirmado: (dados) async {
              // Callback opcional, lógica principal está no modal
            },
          );
        },
      );

      if (resultado == true && mounted) {
        print('✅ Importação concluída, recarregando dados...');
        await _carregarDados();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Dados atualizados com sucesso!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir importação: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Mostra diálogo para edição de unidade
  Future<void> _mostrarDialogoEdicaoUnidade(
    String unidadeId,
    String nomeAtual,
  ) async {
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
    String nomeBloco,
  ) {
    final isEditando = _unidadesEditando.contains(unidadeId);
    final isExcluindo = _unidadesExcluindo.contains(unidadeId);

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: ElevatedButton(
        onPressed: isEditando || isExcluindo
            ? null
            : () async {
                final result = await Navigator.push(
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

                if (result == true) {
                  // Se retornou true, significa que houve alteração (ex: exclusão)
                  print(
                    '🔄 Recarregando lista de unidades após retorno da tela de detalhes...',
                  );
                  _carregarDados();
                }
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

  /// Constrói grid de unidades sem blocos
  Widget _buildUnidadesGridSemBlocos(List<BlocoComUnidades> blocos) {
    // Extrai todas as unidades de todos os blocos
    final todasAsUnidades =
        <(String numero, String blocoId, String unidadeId, String blocoNome)>[];

    for (var blocoComUnidades in blocos) {
      for (var unidade in blocoComUnidades.unidades) {
        todasAsUnidades.add((
          unidade.numero,
          blocoComUnidades.bloco.id,
          unidade.id,
          blocoComUnidades.bloco.nome,
        ));
      }
    }

    // Ordena por número de unidade
    todasAsUnidades.sort((a, b) {
      final numA = int.tryParse(a.$1) ?? 0;
      final numB = int.tryParse(b.$1) ?? 0;
      return numA.compareTo(numB);
    });

    if (todasAsUnidades.isEmpty) {
      return const Center(child: Text('Nenhuma unidade encontrada'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: todasAsUnidades.map((unidadeData) {
          final numero = unidadeData.$1;
          final unidadeId = unidadeData.$3;
          final blocoNome = unidadeData.$4;

          return _buildUnidadeButton(numero, blocoNome, unidadeId, blocoNome);
        }).toList(),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                    icon: const Icon(Icons.more_vert, color: Color(0xFF757575)),
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
                            Text(
                              'Excluir Bloco',
                              style: TextStyle(color: Colors.red),
                            ),
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
              children: unidades
                  .map(
                    (unidade) => _buildUnidadeButton(
                      unidade.numero,
                      bloco.nome,
                      unidade.id,
                      bloco.nome,
                    ),
                  )
                  .toList(),
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
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _downloadTemplate,
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Baixar Template'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _importarPlanilha,
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text('Importar Planilha'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF50C878),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Botões de Ação e Configuração
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  // Botão Adicionar Unidade
                  ElevatedButton.icon(
                    onPressed: _abrirModalCriarUnidade,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('➕ ADICIONAR UNIDADE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Card de Configuração de Blocos
                  _buildConfiguracaoBlocosCard(),
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
                    Expanded(child: _buildConteudoPrincipal()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o card de configuração de blocos
  Widget _buildConfiguracaoBlocosCard() {
    return GestureDetector(
      onTap: _atualizandoTemBlocos
          ? null
          : () => _alternarTemBlocos(!_temBlocos),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _atualizandoTemBlocos ? 0.98 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          decoration: BoxDecoration(
            color: _temBlocos
                ? const Color(0xFF4A90E2).withOpacity(0.06)
                : const Color(0xFFFF9800).withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _temBlocos
                  ? const Color(0xFF4A90E2).withOpacity(0.4)
                  : const Color(0xFFFF9800).withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _temBlocos
                    ? const Color(0xFF4A90E2).withOpacity(0.15)
                    : const Color(0xFFFF9800).withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              // Ícone indicador com gradiente
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _temBlocos
                        ? [
                            const Color(0xFF4A90E2).withOpacity(0.12),
                            const Color(0xFF4A90E2).withOpacity(0.04),
                          ]
                        : [
                            const Color(0xFFFF9800).withOpacity(0.12),
                            const Color(0xFFFF9800).withOpacity(0.04),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _temBlocos
                        ? const Color(0xFF4A90E2).withOpacity(0.2)
                        : const Color(0xFFFF9800).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _temBlocos ? Icons.layers_rounded : Icons.list_alt_rounded,
                  size: 32,
                  color: _temBlocos
                      ? const Color(0xFF4A90E2)
                      : const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 18),
              // Texto explicativo com melhor tipografia
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _temBlocos ? 'Com Blocos' : 'Sem Blocos',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _temBlocos
                            ? const Color(0xFF2E5C9F)
                            : const Color(0xFFE65100),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _temBlocos
                          ? 'Unidades organizadas por blocos'
                          : 'Lista simplificada de unidades',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Status badge com efeito pulse
              if (_atualizandoTemBlocos)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _temBlocos
                        ? const Color(0xFF4A90E2).withOpacity(0.1)
                        : const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _temBlocos
                              ? const Color(0xFF4A90E2)
                              : const Color(0xFFFF9800),
                        ),
                      ),
                    ),
                  ),
                )
              else
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _temBlocos
                          ? [const Color(0xFF4A90E2), const Color(0xFF357ABD)]
                          : [const Color(0xFFFF9800), const Color(0xFFF57C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _temBlocos
                            ? const Color(0xFF4A90E2).withOpacity(0.3)
                            : const Color(0xFFFF9800).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _temBlocos ? Icons.check_circle : Icons.cancel,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _temBlocos ? 'Ativo' : 'Inativo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
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
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
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

    // Se há unidades carregadas, exibir a listagem de blocos e unidades
    if (_blocosUnidadesFiltrados.isNotEmpty) {
      // Filtrar apenas blocos que têm unidades
      final blocoComUnidadesValidas = _blocosUnidadesFiltrados
          .where((bloco) => bloco.unidades.isNotEmpty)
          .toList();

      if (blocoComUnidadesValidas.isNotEmpty) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            child: Column(
              children: _temBlocos
                  ? blocoComUnidadesValidas
                        .map(
                          (blocoComUnidades) =>
                              _buildBlocoSection(blocoComUnidades),
                        )
                        .toList()
                  : [_buildUnidadesGridSemBlocos(blocoComUnidadesValidas)],
            ),
          ),
        );
      }
    }

    // Se não há unidades, exibir template de instrução
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
                    _buildInstructionStep(
                      '2',
                      'Preencha os dados das unidades',
                    ),
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
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ),
        ],
      ),
    );
  }
}
