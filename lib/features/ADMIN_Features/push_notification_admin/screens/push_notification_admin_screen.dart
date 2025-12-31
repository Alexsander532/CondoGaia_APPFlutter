import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/push_notification_service.dart';
import '../cubit/push_notification_cubit.dart';
import '../cubit/push_notification_state.dart';
import '../widgets/campo_titulo.dart';
import '../widgets/campo_mensagem.dart';
import '../widgets/checkbox_sindicatos_moradores.dart';
import '../widgets/seletor_condominios.dart';
import '../widgets/seletor_uf_cidade.dart';
import '../widgets/botao_enviar.dart';
import '../widgets/admin_header.dart';
import '../../../../services/supabase_service.dart';
import '../../../../screens/login_screen.dart';

class PushNotificationAdminScreen extends StatefulWidget {
  const PushNotificationAdminScreen({super.key});

  @override
  State<PushNotificationAdminScreen> createState() =>
      _PushNotificationAdminScreenState();
}

class _PushNotificationAdminScreenState
    extends State<PushNotificationAdminScreen> {
  late final TextEditingController _tituloController;
  late final TextEditingController _mensagemController;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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

    // Mostrar diálogo de confirmação
    final cubit = context.read<PushNotificationCubit>();
    
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
              cubit.titulo,
            ),
            const SizedBox(height: 12),
            _buildConfirmacaoItem(
              'Mensagem',
              cubit.mensagem,
            ),
            const SizedBox(height: 12),
            _buildConfirmacaoItem(
              'Destinatários',
              cubit.sindicosInclusos
                  ? 'Síndicos + Moradores'
                  : '${cubit.condominiosSelecionados.length} condomínio(s)',
            ),
            const SizedBox(height: 12),
            _buildConfirmacaoItem(
              'Local',
              '${cubit.cidadeSelecionada?.nome} - ${cubit.estadoSelecionado?.sigla}',
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

    // Enviar notificação via cubit
    if (mounted) {
      context.read<PushNotificationCubit>().enviarNotificacao();
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
    return BlocProvider(
      create: (context) =>
          PushNotificationCubit(PushNotificationService()),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: _buildDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              // Cabeçalho
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
                    child: BlocListener<PushNotificationCubit,
                        PushNotificationState>(
                      listener: (context, state) {
                        if (state is PushNotificationEnviada) {
                          // Mostrar sucesso
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              title: const Text('Sucesso!'),
                              content: Text(state.mensagem),
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

                          // Limpar controladores
                          _tituloController.clear();
                          _mensagemController.clear();
                        } else if (state is PushNotificationErro) {
                          // Mostrar erro
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Erro'),
                              content: Text(state.mensagem),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: BlocBuilder<PushNotificationCubit,
                          PushNotificationState>(
                        builder: (context, state) {
                          final cubit =
                              context.read<PushNotificationCubit>();
                          final isLoading =
                              state is PushNotificationLoading;
                          final formularioValido = state
                              is PushNotificationFormularioAtualizado
                              ? state.formularioValido
                              : false;

                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
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
                                onChanged: (value) {
                                  cubit.atualizarTitulo(value);
                                },
                              ),
                              const SizedBox(height: 16),

                              // Campo Mensagem
                              CampoMensagem(
                                controller: _mensagemController,
                                onChanged: (value) {
                                  cubit.atualizarMensagem(value);
                                },
                              ),
                              const SizedBox(height: 20),

                              // Seletor UF/Cidade
                              SeletorUfCidade(
                                estadoSelecionado:
                                    cubit.estadoSelecionado,
                                cidadeSelecionada:
                                    cubit.cidadeSelecionada,
                                onEstadoChanged: (estado) {
                                  cubit.atualizarEstadoSelecionado(
                                      estado);
                                },
                                onCidadeChanged: (cidade) {
                                  cubit.atualizarCidadeSelecionada(
                                      cidade);
                                },
                              ),
                              const SizedBox(height: 20),

                              // Checkboxes Sindicatos/Moradores
                              CheckboxSindicosMoreadores(
                                sindicosInclusos:
                                    cubit.sindicosInclusos,
                                onSindicosChanged: (value) {
                                  cubit.atualizarSindicosInclusos(
                                      value);
                                },
                                temMoradoresSelecionados:
                                    cubit.condominiosSelecionados
                                        .isNotEmpty,
                              ),
                              const SizedBox(height: 20),

                              // Seletor de Condominios
                              SeletorCondominios(
                                condominiosSelecionados:
                                    cubit.condominiosSelecionados,
                                onChanged: (condominios) {
                                  cubit
                                      .atualizarCondominiosSelecionados(
                                          condominios);
                                },
                                estadoSelecionado:
                                    cubit.estadoSelecionado,
                                cidadeSelecionada:
                                    cubit.cidadeSelecionada,
                              ),
                              const SizedBox(height: 20),

                              // Mensagem de erro (se houver)
                              if (state is PushNotificationErro)
                                Container(
                                  padding:
                                      const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    border: Border.all(
                                        color: Colors.red[200]!),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    state.mensagem,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (state is PushNotificationErro)
                                const SizedBox(height: 16),

                              // Botão Enviar
                              BotaoEnviar(
                                onPressed: isLoading
                                    ? null
                                    : _enviarNotificacao,
                                carregando: isLoading,
                                formularioValido: formularioValido,
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
