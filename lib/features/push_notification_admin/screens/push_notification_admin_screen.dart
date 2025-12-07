import 'package:flutter/material.dart';
import '../models/localizacao_model.dart';
import '../models/condominio_model.dart';
import '../services/push_notification_service.dart';
import '../widgets/campo_titulo.dart';
import '../widgets/campo_mensagem.dart';
import '../widgets/checkbox_sindicatos_moradores.dart';
import '../widgets/seletor_condominios.dart';
import '../widgets/seletor_uf_cidade.dart';
import '../widgets/botao_enviar.dart';
import '../widgets/admin_header.dart';
import '../../../services/supabase_service.dart';
import '../../../screens/login_screen.dart';

class PushNotificationAdminScreen extends StatefulWidget {
  const PushNotificationAdminScreen({super.key});

  @override
  State<PushNotificationAdminScreen> createState() =>
      _PushNotificationAdminScreenState();
}

class _PushNotificationAdminScreenState
    extends State<PushNotificationAdminScreen> {
  final _service = PushNotificationService();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controladores
  late final TextEditingController _tituloController;
  late final TextEditingController _mensagemController;

  // Estados do formulário
  bool _sindicosInclusos = false;
  CondominioModel? _condominioSelecionado;
  EstadoModel? _estadoSelecionado;
  CidadeModel? _cidadeSelecionada;
  bool _carregando = false;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController();
    _mensagemController = TextEditingController();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  Future<void> _enviarNotificacao() async {
    // Fechar teclado
    FocusScope.of(context).unfocus();

    // Validar formulário
    final erros = _service.validarNotificacao(
      titulo: _tituloController.text,
      mensagem: _mensagemController.text,
      sindicosInclusos: _sindicosInclusos,
      moradoresSelecionados: [],
      estadoSelecionado: _estadoSelecionado,
      cidadeSelecionada: _cidadeSelecionada,
    );

    if (erros.isNotEmpty) {
      setState(() {
        _mensagemErro = erros.join('\n');
      });

      // Mostrar diálogo de erro
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Atenção'),
            content: Text(erros.join('\n')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Mostrar diálogo de confirmação
    if (!mounted) return;
    final confirmou = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Envio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmacaoItem(
              'Título',
              _tituloController.text,
            ),
            const SizedBox(height: 12),
            _buildConfirmacaoItem(
              'Mensagem',
              _mensagemController.text,
            ),
            const SizedBox(height: 12),
            _buildConfirmacaoItem(
              'Destinatários',
              _sindicosInclusos
                  ? 'Síndicos + Condominio'
                  : '${_condominioSelecionado?.nome ?? "N/A"}',
            ),
            const SizedBox(height: 12),
            _buildConfirmacaoItem(
              'Local',
              '${_cidadeSelecionada?.nome} - ${_estadoSelecionado?.sigla}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
            ),
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmou != true || !mounted) return;

    // Enviar notificação
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final sucesso = await _service.enviarNotificacao(
        titulo: _tituloController.text,
        mensagem: _mensagemController.text,
        sindicosInclusos: _sindicosInclusos,
        moradoresSelecionados: [],
        estadoSelecionado: _estadoSelecionado,
        cidadeSelecionada: _cidadeSelecionada,
      );

      if (mounted) {
        if (sucesso) {
          // Mostrar sucesso
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Sucesso!'),
              content: const Text(
                'Notificação enviada com sucesso para todos os destinatários.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fecha diálogo
                    Navigator.pop(context); // Volta para tela anterior
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );

          // Limpar formulário
          _tituloController.clear();
          _mensagemController.clear();
          setState(() {
            _sindicosInclusos = false;
            _condominioSelecionado = null;
            _estadoSelecionado = null;
            _cidadeSelecionada = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mensagemErro = 'Erro ao enviar notificação: $e';
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erro'),
            content: Text('Erro ao enviar notificação: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Widget _buildConfirmacaoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho (igual ao da HomeScreen)
            AdminHeader(
              scaffoldKey: _scaffoldKey,
              title: 'HOME/PUSH',
              onLogout: _handleLogout,
            ),
            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título da seção
                      const Text(
                        'Enviar Notificação',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campo Título
                      CampoTitulo(
                        controller: _tituloController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Campo Mensagem
                      CampoMensagem(
                        controller: _mensagemController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),

                      // Seletor UF/Cidade (FILTRO - deve vir primeiro)
                      SeletorUfCidade(
                        estadoSelecionado: _estadoSelecionado,
                        cidadeSelecionada: _cidadeSelecionada,
                        onEstadoChanged: (estado) {
                          setState(() => _estadoSelecionado = estado);
                        },
                        onCidadeChanged: (cidade) {
                          setState(() => _cidadeSelecionada = cidade);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Checkboxes Sindicatos/Moradores
                      CheckboxSindicosMoreadores(
                        sindicosInclusos: _sindicosInclusos,
                        onSindicosChanged: (value) {
                          setState(() => _sindicosInclusos = value);
                        },
                        temMoradoresSelecionados: _condominioSelecionado != null,
                      ),
                      const SizedBox(height: 20),

                      // Seletor de Condominios (Pesquisar - filtrado pela UF/Cidade acima)
                      SeletorCondominios(
                        condominioSelecionado: _condominioSelecionado,
                        onChanged: (condominio) {
                          setState(() => _condominioSelecionado = condominio);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Mensagem de erro (se houver)
                      if (_mensagemErro != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            border: Border.all(color: Colors.red[200]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _mensagemErro!,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (_mensagemErro != null) const SizedBox(height: 16),

                      // Botão Enviar
                      BotaoEnviar(
                        onPressed: _enviarNotificacao,
                        carregando: _carregando,
                        desabilitado: _tituloController.text.isEmpty ||
                            _mensagemController.text.isEmpty ||
                            (!_sindicosInclusos && _condominioSelecionado == null) ||
                            _estadoSelecionado == null ||
                            _cidadeSelecionada == null,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Deseja realmente sair da sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  await SupabaseService.client.auth.signOut();
                  
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao sair: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeleteAccount() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Conta'),
          content: const Text(
            'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao excluir conta: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawer() {
    final header = AdminHeader(
      scaffoldKey: _scaffoldKey,
      title: 'HOME/PUSH',
      onLogout: _handleLogout,
      onDeleteAccount: _handleDeleteAccount,
    );
    return header.buildDrawer(context);
  }
}
