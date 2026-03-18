import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_cubit.dart';
import '../cubit/boleto_state.dart';
import '../services/boleto_service.dart';
import '../widgets/boleto_filtro_widget.dart';
import '../widgets/boleto_list_widget.dart';
import '../widgets/boleto_acoes_widget.dart';
import '../widgets/gerar_cobranca_mensal_dialog.dart';
import '../widgets/gerar_cobranca_avulsa_dialog.dart';
import '../../cobranca_avulsa/ui/screens/cobranca_avulsa_screen.dart';

class BoletoScreen extends StatelessWidget {
  final String condominioId;

  const BoletoScreen({super.key, required this.condominioId});

  static const _primaryColor = Color(0xFF0D3B66);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BoletoCubit(service: BoletoService(), condominioId: condominioId)
            ..carregarDados(),
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
              icon: const Icon(Icons.add_circle, color: Colors.grey, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CobrancaAvulsaScreen(condominioId: condominioId),
                  ),
                );
              },
            ),
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
                      const Expanded(
                        child: Text(
                          'Home/Gestão/Boleto',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54, fontSize: 14),
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
        body: BlocConsumer<BoletoCubit, BoletoState>(
          listener: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state.successMessage != null &&
                state.successMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Cards no topo
                  _buildTopActionCards(context),
                  const SizedBox(height: 20),

                  // Filtros
                  const BoletoFiltroWidget(),
                  const SizedBox(height: 20),

                  // Lista de boletos
                  const BoletoListWidget(),
                  const SizedBox(height: 20),

                  // Ações inferiores
                  const BoletoAcoesWidget(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botão Gerar Cobrança Mensal
                FloatingActionButton.extended(
                  heroTag: "mensal",
                  backgroundColor: _primaryColor,
                  icon: const Icon(Icons.calendar_month, color: Colors.white),
                  label: const Text('Mensal', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        value: context.read<BoletoCubit>(),
                        child: const GerarCobrancaMensalDialog(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                // Botão Gerar Cobrança Avulsa
                FloatingActionButton.extended(
                  heroTag: "avulso",
                  backgroundColor: Colors.orange.shade700,
                  icon: const Icon(Icons.description, color: Colors.white),
                  label: const Text('Avulsa', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        value: context.read<BoletoCubit>(),
                        child: const GerarCobrancaAvulsaDialog(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopActionCards(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionCard(
          icon: Icons.note_add_outlined,
          onTap: () {
            // Ação: Novo boleto manual?
          },
        ),
        _buildActionCard(
          icon: Icons.image_search,
          onTap: () {
            // Ação: Filtro/Visualização?
          },
        ),
        _buildActionCard(
          icon: Icons.list_alt_outlined,
          onTap: () {
            // Ação: Lista detalhada?
          },
        ),
        _buildActionCard(
          icon: Icons.add,
          isCircle: true,
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => BlocProvider.value(
                value: context.read<BoletoCubit>(),
                child: const GerarCobrancaMensalDialog(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required VoidCallback onTap,
    bool isCircle = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 32,
            color: isCircle ? Colors.grey : _primaryColor,
          ),
        ),
      ),
    );
  }
}
