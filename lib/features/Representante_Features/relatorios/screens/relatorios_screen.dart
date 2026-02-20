import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/relatorios_cubit.dart';
import '../cubit/relatorios_state.dart';
import '../widgets/relatorio_boleto_widget.dart';
import '../widgets/relatorio_despesas_widget.dart';
import '../widgets/relatorio_receitas_widget.dart';
import '../widgets/relatorio_dre_widget.dart';
import '../widgets/relatorio_morador_unid_widget.dart';
import '../widgets/relatorio_acordo_widget.dart';
import '../widgets/relatorio_email_widget.dart';
import '../widgets/relatorio_portaria_widget.dart';
import '../widgets/relatorio_contas_bancarias_widget.dart';
import '../widgets/relatorio_demonstrativo_balancete_widget.dart';
import '../widgets/relatorio_livro_diario_widget.dart';
import '../widgets/relatorio_inadimplencia_widget.dart';

class RelatoriosScreen extends StatelessWidget {
  final String condominioId;

  const RelatoriosScreen({super.key, required this.condominioId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RelatoriosCubit(condominioId: condominioId),
      child: const _RelatoriosView(),
    );
  }
}

class _RelatoriosView extends StatelessWidget {
  static const _primaryColor = Color(0xFF0D3B66);

  const _RelatoriosView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        'Home/Gestão/Relatórios',
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
      body: Column(
        children: [
          // === Dropdown de Relatório ===
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: BlocBuilder<RelatoriosCubit, RelatoriosState>(
              builder: (context, state) {
                return Row(
                  children: [
                    const Text(
                      'Relatório:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: state.tipoRelatorio,
                        isDense: true,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: _primaryColor),
                          ),
                        ),
                        items: RelatoriosCubit.tiposRelatorio
                            .map(
                              (tipo) => DropdownMenuItem(
                                value: tipo,
                                child: Text(
                                  tipo,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            context.read<RelatoriosCubit>().trocarTipoRelatorio(
                              val,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // === Corpo dinâmico ===
          Expanded(
            child: BlocBuilder<RelatoriosCubit, RelatoriosState>(
              builder: (context, state) {
                return _buildCorpoRelatorio(state.tipoRelatorio);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Retorna o widget correspondente ao tipo de relatório selecionado
  Widget _buildCorpoRelatorio(String tipo) {
    switch (tipo) {
      case 'Boleto':
        return const RelatorioBoletoWidget();
      case 'Despesas':
        return const RelatorioDespesasWidget();
      case 'Receitas':
        return const RelatorioReceitasWidget();
      case 'DRE':
        return const RelatorioDreWidget();
      case 'Morador/Unid':
        return const RelatorioMoradorUnidWidget();
      case 'Acordo':
        return const RelatorioAcordoWidget();
      case 'E-Mail':
        return const RelatorioEmailWidget();
      case 'Portaria':
        return const RelatorioPortariaWidget();
      case 'Contas Bancárias':
        return const RelatorioContasBancariasWidget();
      case 'Demonstrativo p/ Balancete':
        return const RelatorioDemonstrativoBalanceteWidget();
      case 'Livro Diário de Lançamento':
        return const RelatorioLivroDiarioWidget();
      case 'Inadimplência':
        return const RelatorioInadimplenciaWidget();
      default:
        return _buildPlaceholder(tipo);
    }
  }

  /// Placeholder para relatórios ainda não implementados
  Widget _buildPlaceholder(String tipo) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Relatório de $tipo',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Em breve',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
