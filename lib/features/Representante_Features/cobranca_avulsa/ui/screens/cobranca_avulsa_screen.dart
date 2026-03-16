import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cobranca_avulsa_cubit.dart';
import '../../data/repositories/cobranca_avulsa_repository.dart';
import '../tabs/pesquisar_cobranca_tab.dart';
import '../tabs/cadastrar_cobranca_tab.dart';

class CobrancaAvulsaScreen extends StatelessWidget {
  const CobrancaAvulsaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CobrancaAvulsaCubit(CobrancaAvulsaRepository()),
      child: const _CobrancaAvulsaView(),
    );
  }
}

class _CobrancaAvulsaView extends StatelessWidget {
  const _CobrancaAvulsaView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
            preferredSize: const Size.fromHeight(110.0),
            child: Column(
              children: [
                // Breadcrumb e Título Interno
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const Expanded(
                            child: Text(
                              'Home/Financeiro/Cobrança Avulsa',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                      const Text(
                        'Gerar Cobrança Avulsa/ Desp. Extraord.',
                        style: TextStyle(
                          color: Color(0xFF0D3B66),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(color: Colors.grey.shade300, height: 1.0),
                const TabBar(
                  indicatorColor: Color(0xFF0D3B66),
                  indicatorWeight: 3,
                  labelColor: Color(0xFF0D3B66),
                  unselectedLabelColor: Colors.black54,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    Tab(text: 'Pesquisar'),
                    Tab(text: 'Cadastrar'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            PesquisarCobrancaTab(),
            CadastrarCobrancaTab(),
          ],
        ),
      ),
    );
  }
}
