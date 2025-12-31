import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../push_notification_admin/widgets/admin_header.dart';
import '../models/instituicao_financeira_model.dart';
import '../models/plano_assinatura_model.dart';
import '../models/tipo_pagamento_model.dart';
import '../services/gateway_pagamento_service.dart';
import '../cubit/gateway_pagamento_cubit.dart';
import '../cubit/gateway_pagamento_state.dart';
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

class _GatewayPagamentoAdminScreenState
    extends State<GatewayPagamentoAdminScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _tokenController = TextEditingController();

  // Listas de dados
  late List<InstituicaoFinanceiraModel> _instituicoes;
  late List<PlanoAssinaturaModel> _planos;
  late List<TipoPagamentoModel> _tiposPagamento;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  void _inicializarDados() {
    final service = GatewayPagamentoService();
    _instituicoes = service.obterInstituicoesSync();
    _planos = service.obterPlanosSync();
    _tiposPagamento = service.obterTiposPagamentoSync();
  }

  Future<void> _handleLogout() async {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
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
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(
              'Excluir conta',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _salvarConfiguracao(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final cubit = context.read<GatewayPagamentoCubit>();

    final confirmou = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Configuração'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmacaoItem(
              'Instituição',
              cubit.instituicaoSelecionada?.nome ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _buildConfirmacaoItem(
              'Plano',
              '${cubit.planoSelecionado?.nome ?? "N/A"} - R\$ ${cubit.planoSelecionado?.valor.toStringAsFixed(2) ?? "0.00"}',
            ),
            const SizedBox(height: 12),
            _buildConfirmacaoItem(
              'Tipo Pagamento',
              cubit.tipoPagamentoSelecionado?.nome ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _buildConfirmacaoItem(
              'Token',
              '${_tokenController.text.replaceRange(5, _tokenController.text.length - 2, '****')}',
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

    cubit.salvarConfiguracao();
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
    return BlocProvider(
      create: (context) => GatewayPagamentoCubit(GatewayPagamentoService()),
      child: BlocListener<GatewayPagamentoCubit, GatewayPagamentoState>(
        listener: (context, state) {
          if (state is GatewayPagamentoSalva) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Sucesso!'),
                content: Text(state.mensagem),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _tokenController.clear();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else if (state is GatewayPagamentoErro) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Erro'),
                content: Text(state.mensagem),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        child: BlocBuilder<GatewayPagamentoCubit, GatewayPagamentoState>(
          builder: (context, state) {
            final cubit = context.read<GatewayPagamentoCubit>();
            final isLoading = state is GatewayPagamentoLoading;
            final formularioValido = state is GatewayPagamentoFormularioAtualizado
                ? state.formularioValido
                : false;

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              drawer: _buildDrawer(),
              body: SafeArea(
                child: Column(
                  children: [
                    AdminHeader(
                      scaffoldKey: _scaffoldKey,
                      title: 'HOME/Financeiro',
                      onLogout: _handleLogout,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Configurar Gateway de Pagamento',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SeletorInstituicao(
                              instituicaoSelecionada:
                                  cubit.instituicaoSelecionada,
                              onChanged: (instituicao) {
                                cubit.atualizarInstituicaoSelecionada(
                                    instituicao);
                              },
                              instituicoes: _instituicoes,
                            ),
                            const SizedBox(height: 20),
                            SeletorPlano(
                              planoSelecionado: cubit.planoSelecionado,
                              onChanged: (plano) {
                                cubit.atualizarPlanoSelecionado(plano);
                              },
                              planos: _planos,
                            ),
                            const SizedBox(height: 20),
                            SeletorTipoPagamento(
                              tipoPagamentoSelecionado:
                                  cubit.tipoPagamentoSelecionado,
                              onChanged: (tipo) {
                                cubit.atualizarTipoPagamentoSelecionado(tipo);
                              },
                              tiposPagamento: _tiposPagamento,
                            ),
                            const SizedBox(height: 20),
                            CampoToken(
                              controller: _tokenController,
                              onChanged: (value) {
                                cubit.atualizarToken(value);
                              },
                            ),
                            const SizedBox(height: 24),
                            if (state is GatewayPagamentoErro)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  border: Border.all(color: Colors.red[200]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  state.mensagem,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            if (state is GatewayPagamentoErro)
                              const SizedBox(height: 16),
                            BotaoSalvarConfiguracao(
                              onPressed: isLoading
                                  ? null
                                  : () => _salvarConfiguracao(context),
                              carregando: isLoading,
                              formularioValido: formularioValido,
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
