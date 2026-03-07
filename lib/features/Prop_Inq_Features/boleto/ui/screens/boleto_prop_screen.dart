import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_prop_cubit.dart';
import '../cubit/boleto_prop_state.dart';
import '../widgets/boleto_filtro_dropdown.dart';
import '../widgets/boleto_card_widget.dart';
import '../widgets/demonstrativo_financeiro_widget.dart';
import '../widgets/secoes_expansiveis_widget.dart';

class BoletoPropScreen extends StatelessWidget {
  final String condominioId;

  const BoletoPropScreen({super.key, required this.condominioId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BoletoPropCubit()..carregarBoletos(),
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
        body: BlocConsumer<BoletoPropCubit, BoletoPropState>(
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
            if (state.status == BoletoPropStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
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
                  // LISTA DE BOLETOS (Cards expansíveis)
                  // ============================================
                  _buildListaBoletos(state),
                  const SizedBox(height: 24),

                  // ============================================
                  // DEMONSTRATIVO FINANCEIRO
                  // ============================================
                  const DemonstrativoFinanceiroWidget(),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // ============================================
                  // SEÇÕES EXPANSÍVEIS
                  // ============================================
                  const SecoesExpansiveisWidget(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildListaBoletos(BoletoPropState state) {
    final boletos = state.boletosFiltrados;

    if (boletos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Nenhum boleto encontrado',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: boletos
          .map((boleto) => BoletoCardWidget(boleto: boleto))
          .toList(),
    );
  }
}
