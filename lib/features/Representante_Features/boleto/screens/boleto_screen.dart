import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_cubit.dart';
import '../cubit/boleto_state.dart';
import '../services/boleto_service.dart';
import '../../gestao_condominio/services/gestao_condominio_service.dart';
import '../widgets/boleto_filtro_widget.dart';
import '../widgets/boleto_list_widget.dart';
import '../widgets/boleto_acoes_widget.dart';
import '../widgets/gerar_cobranca_mensal_dialog.dart';
import '../../cobranca_avulsa/ui/screens/cobranca_avulsa_screen.dart';
import '../../despesa_receita/screens/despesa_receita_screen.dart';

class BoletoScreen extends StatefulWidget {
  final String condominioId;

  const BoletoScreen({super.key, required this.condominioId});

  @override
  State<BoletoScreen> createState() => _BoletoScreenState();
}

class _BoletoScreenState extends State<BoletoScreen> {
  static const _primaryColor = Color(0xFF0D3B66);
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BoletoCubit(
        service: BoletoService(),
        gestaoService: GestaoCondominioService(),
        condominioId: widget.condominioId,
      )..carregarDados(),
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
                  // Action Cards no topo (Expansível)
                  _buildExpandableActionCards(context),
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
      ),
    );
  }

  Widget _buildExpandableActionCards(BuildContext context) {
    return Column(
      children: [
        if (!_isExpanded)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionCard(
                icon: Icons.library_add_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CobrancaAvulsaScreen(condominioId: widget.condominioId),
                    ),
                  );
                },
              ),
              _buildActionCard(
                icon: Icons.iso,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DespesaReceitaScreen(condominioId: widget.condominioId),
                    ),
                  );
                },
              ),
              _buildActionCard(
                icon: Icons.segment,
                onTap: () {
                  // Ação: Visualizar Layout e Valores
                },
              ),
              _buildActionCard(
                icon: Icons.add_circle,
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
          )
        else
          Column(
            children: [
              _buildExpandedActionItem(
                context,
                icon: Icons.library_add_outlined,
                label: "Cobrança Avulsa/ Desp. Extraord.",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CobrancaAvulsaScreen(condominioId: widget.condominioId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildExpandedActionItem(
                context,
                icon: Icons.iso,
                label: "Desp/ Receita Manual",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DespesaReceitaScreen(condominioId: widget.condominioId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildExpandedActionItem(
                context,
                icon: Icons.segment,
                label: "Visualizar Layout e Valores",
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildExpandedActionItem(
                context,
                icon: Icons.add_circle,
                label: "Gerar Cobrança Mensal",
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
          ),
        const SizedBox(height: 16),
        // Toggle Expand/Collapse
        Row(
          children: [
            Expanded(
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, _primaryColor],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Icon(
                _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: _primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            size: 45,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
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
                size: 40,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
