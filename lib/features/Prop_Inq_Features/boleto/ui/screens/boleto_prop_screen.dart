import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_prop_cubit.dart';
import '../cubit/boleto_prop_state.dart';
import '../../data/datasources/boleto_prop_remote_datasource.dart';
import '../../data/repositories/boleto_prop_repository_impl.dart';
import '../../domain/usecases/boleto_prop_usecases.dart';
import '../widgets/boleto_filtro_dropdown.dart';
import '../widgets/boleto_card_widget.dart';
import '../widgets/demonstrativo_financeiro_widget.dart';
import '../widgets/secoes_expansiveis_widget.dart';
import '../widgets/skeleton_widgets.dart';
import '../widgets/empty_state_widgets.dart';

class BoletoPropScreen extends StatelessWidget {
  final String condominioId;
  final String moradorId;

  const BoletoPropScreen({
    super.key, 
    required this.condominioId,
    required this.moradorId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // Criar dependências
        final dataSource = BoletoPropRemoteDataSourceImpl();
        final repository = BoletoPropRepositoryImpl(remoteDataSource: dataSource);
        final obterBoletosUseCase = ObterBoletosPropUseCase(repository: repository);
        final obterComposicaoUseCase = ObterComposicaoBoletoUseCase(repository: repository);
        final obterDemonstrativoUseCase = ObterDemonstrativoFinanceiroUseCase(repository: repository);
        final obterLeiturasUseCase = ObterLeiturasUseCase(repository: repository);
        final obterBalanceteOnlineUseCase = ObterBalanceteOnlineUseCase(repository: repository);
        final sincronizarBoletoUseCase = SincronizarBoletoUseCase(repository: repository);
        
        return BoletoPropCubit(
          obterBoletos: obterBoletosUseCase,
          obterComposicao: obterComposicaoUseCase,
          obterDemonstrativo: obterDemonstrativoUseCase,
          obterLeituras: obterLeiturasUseCase,
          obterBalanceteOnline: obterBalanceteOnlineUseCase,
          sincronizarBoleto: sincronizarBoletoUseCase,
          moradorId: moradorId,
          condominioId: condominioId,
        )..carregarBoletos();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 28),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          title: Image.asset('assets/images/logo_CondoGaia.png', height: 30),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Image.asset(
                'assets/images/Sino_Notificacao.png',
                width: 24,
                height: 24,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Image.asset(
                'assets/images/Fone_Ouvido_Cabecalho.png',
                width: 24,
                height: 24,
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: Column(
              children: [
                // Breadcrumb
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text(
                              'Home/Gestão/Boleto',
                              style: TextStyle(color: Colors.black54, fontSize: 14),
                            ),
                            Positioned(
                              right: 0,
                              child: BlocBuilder<BoletoPropCubit, BoletoPropState>(
                                builder: (context, state) {
                                  return IconButton(
                                    icon: state.status == BoletoPropStatus.loading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.refresh,
                                            size: 24,
                                            color: Colors.blue,
                                          ),
                                    onPressed: state.status == BoletoPropStatus.loading
                                        ? null
                                        : () => context.read<BoletoPropCubit>().carregarBoletos(),
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Recarregar tela',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
                Container(color: Colors.grey.shade300, height: 1.0),
              ],
            ),
          ),
        ),
        body: BlocConsumer<BoletoPropCubit, BoletoPropState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
              context.read<BoletoPropCubit>().limparMensagens();
            }
            if (state.successMessage != null &&
                state.successMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<BoletoPropCubit>().limparMensagens();
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<BoletoPropCubit>().carregarBoletos();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ============================================
                    // DROPDOWN FILTRO (Vencido/A Vencer ou Pago)
                    // ============================================
                    const BoletoFiltroDropdown(),
                    const SizedBox(height: 20),

                    // ============================================
                    // CONTEÚDO DINÂMICO (Loading, Error, Empty, ou Lista)
                    // ============================================
                    _buildConteudoDinamico(context, state),
                    const SizedBox(height: 24),

                    // ============================================
                    // DEMONSTRATIVO FINANCEIRO (apenas seletor de mês/ano)
                    // ============================================
                    if (state.status != BoletoPropStatus.loading)
                      const DemonstrativoFinanceiroWidget(),
                    if (state.status != BoletoPropStatus.loading) ...[
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                    ],

                    // ============================================
                    // SEÇÕES EXPANSÍVEIS
                    // ============================================
                    if (state.status != BoletoPropStatus.loading)
                      const SecoesExpansiveisWidget(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConteudoDinamico(BuildContext context, BoletoPropState state) {
    final boletos = state.boletosFiltrados;

    // Loading state com skeletons
    if (state.status == BoletoPropStatus.loading) {
      return Column(
        children: [
          // Skeletons para boletos
          ...List.generate(3, (index) => const BoletoSkeleton()),
          const SizedBox(height: 24),
          // Skeletons para seções
          const DemonstrativoSkeleton(),
          const SizedBox(height: 16),
          const SecaoSkeleton(),
        ],
      );
    }

    // Error state
    if (state.status == BoletoPropStatus.error) {
      return ErrorStateWidget(
        message: state.errorMessage ?? 'Ocorreu um erro ao carregar os boletos.',
        onRetry: () => context.read<BoletoPropCubit>().carregarBoletos(),
      );
    }

    // Empty state
    if (boletos.isEmpty) {
      return EmptyStateWidget(
        message: state.filtroSelecionado == 'Pago'
            ? 'Não há boletos pagos para exibir.\nTente alterar o filtro para "Vencido/ A Vencer".'
            : 'Não há boletos em aberto para exibir.\nTente alterar o filtro para "Pago".',
        onRefresh: () => context.read<BoletoPropCubit>().carregarBoletos(),
      );
    }

    // Lista de boletos
    return Column(
      children: boletos
          .map((boleto) => BoletoCardWidget(boleto: boleto))
          .toList(),
    );
  }
}
