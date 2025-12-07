import 'package:flutter/material.dart';
import '../../../push_notification_admin/widgets/admin_header.dart';
import '../models/instituicao_financeira_model.dart';
import '../models/plano_assinatura_model.dart';
import '../models/tipo_pagamento_model.dart';
import '../services/gateway_pagamento_service.dart';
import '../widgets/seletor_instituicao.dart';
import '../widgets/seletor_plano.dart';
import '../widgets/seletor_tipo_pagamento.dart';
import '../widgets/campo_token.dart';
import '../widgets/botao_salvar_configuracao.dart';

class GatewayPagamentoAdminScreen extends StatefulWidget {
  const GatewayPagamentoAdminScreen({Key? key}) : super(key: key);

  @override
  State<GatewayPagamentoAdminScreen> createState() => _GatewayPagamentoAdminScreenState();
}

class _GatewayPagamentoAdminScreenState extends State<GatewayPagamentoAdminScreen> {
  final GatewayPagamentoService _service = GatewayPagamentoService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tokenController = TextEditingController();

  // Estados dos campos
  InstituicaoFinanceiraModel? _instituicaoSelecionada;
  PlanoAssinaturaModel? _planoSelecionado;
  TipoPagamentoModel? _tipoPagamentoSelecionado;

  // Listas mockadas
  late List<InstituicaoFinanceiraModel> _instituicoes;
  late List<PlanoAssinaturaModel> _planos;
  late List<TipoPagamentoModel> _tiposPagamento;

  bool _carregando = false;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  void _inicializarDados() {
    // Carrega os dados mockados diretamente do service
    _instituicoes = _service.obterInstituicoesSync();
    _planos = _service.obterPlanosSync();
    _tiposPagamento = _service.obterTiposPagamentoSync();
  }

  Future<void> _handleLogout() async {
    // TODO: Implementar logout real com Supabase
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header do drawer
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_CondoGaia.png',
                  height: 40,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Botão Sair da conta
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sair da conta',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
              _handleLogout();
            },
          ),
          const Divider(),
          // Botão Excluir conta
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Excluir conta',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implementar exclusão de conta
            },
          ),
        ],
      ),
    );
  }

  Future<void> _salvarConfiguracao() async {
    // Validar formulário
    final erros = _service.validarConfiguracao(
      instituicaoSelecionada: _instituicaoSelecionada,
      planoSelecionado: _planoSelecionado,
      tipoPagamentoSelecionado: _tipoPagamentoSelecionado,
      token: _tokenController.text,
    );

    if (erros.isNotEmpty) {
      setState(() => _mensagemErro = erros.join('\n'));
      return;
    }

    // Mostrar diálogo de confirmação
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Configuração'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmacaoItem('Instituição', _instituicaoSelecionada?.nome ?? 'N/A'),
            const SizedBox(height: 12),
            _buildConfirmacaoItem(
              'Plano',
              '${_planoSelecionado?.nome ?? "N/A"} - R\$ ${_planoSelecionado?.valor.toStringAsFixed(2) ?? "0.00"}',
            ),
            const SizedBox(height: 12),
            _buildConfirmacaoItem('Tipo Pagamento', _tipoPagamentoSelecionado?.nome ?? 'N/A'),
            const SizedBox(height: 12),
            _buildConfirmacaoItem(
              'Token',
              '${_tokenController.text.replaceRange(5, _tokenController.text.length - 2, '****')}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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

    // Salvar configuração
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final sucesso = await _service.salvarConfiguracao(
        instituicao: _instituicaoSelecionada!,
        plano: _planoSelecionado!,
        tipoPagamento: _tipoPagamentoSelecionado!,
        token: _tokenController.text,
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
                'Configuração do gateway salva com sucesso.',
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
          _tokenController.clear();
          setState(() {
            _instituicaoSelecionada = null;
            _planoSelecionado = null;
            _tipoPagamentoSelecionado = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mensagemErro = 'Erro ao salvar configuração: $e';
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erro'),
            content: Text('Erro ao salvar configuração: $e'),
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
              title: 'HOME/Financeiro',
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
                        'Configurar Gateway de Pagamento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Seletor de Instituição
                      SeletorInstituicao(
                        instituicaoSelecionada: _instituicaoSelecionada,
                        onChanged: (instituicao) {
                          setState(() => _instituicaoSelecionada = instituicao);
                        },
                        instituicoes: _instituicoes,
                      ),
                      const SizedBox(height: 20),

                      // Seletor de Plano
                      SeletorPlano(
                        planoSelecionado: _planoSelecionado,
                        onChanged: (plano) {
                          setState(() => _planoSelecionado = plano);
                        },
                        planos: _planos,
                      ),
                      const SizedBox(height: 20),

                      // Seletor de Tipo de Pagamento
                      SeletorTipoPagamento(
                        tipoPagamentoSelecionado: _tipoPagamentoSelecionado,
                        onChanged: (tipo) {
                          setState(() => _tipoPagamentoSelecionado = tipo);
                        },
                        tiposPagamento: _tiposPagamento,
                      ),
                      const SizedBox(height: 20),

                      // Campo Token
                      CampoToken(
                        controller: _tokenController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 24),

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

                      // Botão Salvar
                      BotaoSalvarConfiguracao(
                        onPressed: _salvarConfiguracao,
                        carregando: _carregando,
                        desabilitado: _instituicaoSelecionada == null ||
                            _planoSelecionado == null ||
                            _tipoPagamentoSelecionado == null ||
                            _tokenController.text.isEmpty,
                      ),
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

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }
}
