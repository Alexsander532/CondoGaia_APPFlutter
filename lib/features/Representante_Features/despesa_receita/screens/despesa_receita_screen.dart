import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/despesa_receita_cubit.dart';
import '../cubit/despesa_receita_state.dart';
import '../services/despesa_receita_service.dart';
import '../widgets/despesas_tab_widget.dart';
import '../widgets/receitas_tab_widget.dart';
import '../widgets/transferencia_tab_widget.dart';

class DespesaReceitaScreen extends StatelessWidget {
  final String condominioId;

  const DespesaReceitaScreen({super.key, required this.condominioId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DespesaReceitaCubit(
        service: DespesaReceitaService(),
        condominioId: condominioId,
      )..carregarDados(),
      child: const _DespesaReceitaView(),
    );
  }
}

class _DespesaReceitaView extends StatefulWidget {
  const _DespesaReceitaView();

  @override
  State<_DespesaReceitaView> createState() => _DespesaReceitaViewState();
}

class _DespesaReceitaViewState extends State<_DespesaReceitaView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black, size: 28),
          onPressed: () {},
        ),
        title: Column(
          children: [
            Image.asset('assets/images/logo_CondoGaia.png', height: 30),
          ],
        ),
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
          preferredSize: const Size.fromHeight(80.0),
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
                        'Home/Gestão/Despesas-Receitas',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
              Container(color: Colors.grey.shade300, height: 1.0),
              // TabBar
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF0D3B66),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF0D3B66),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Despesas'),
                  Tab(text: 'Receitas'),
                  Tab(text: 'Transferência'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<DespesaReceitaCubit, DespesaReceitaState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == DespesaReceitaStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: const [
              DespesasTabWidget(),
              ReceitasTabWidget(),
              TransferenciaTabWidget(),
            ],
          );
        },
      ),
    );
  }
}
