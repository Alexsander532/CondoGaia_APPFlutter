import 'package:flutter/material.dart';

class ResumoFinanceiroWidget extends StatefulWidget {
  final double saldoAnterior;
  final double totalCredito;
  final double totalDebito;
  final double saldoAtual;
  final Map<String, double> saldoAnteriorPorConta;
  final Map<String, double> totalCreditoPorConta;
  final Map<String, double> totalDebitoPorConta;
  final Map<String, double> saldoAtualPorConta;

  const ResumoFinanceiroWidget({
    super.key,
    this.saldoAnterior = 0,
    this.totalCredito = 0,
    this.totalDebito = 0,
    this.saldoAtual = 0,
    this.saldoAnteriorPorConta = const {},
    this.totalCreditoPorConta = const {},
    this.totalDebitoPorConta = const {},
    this.saldoAtualPorConta = const {},
  });

  @override
  State<ResumoFinanceiroWidget> createState() => _ResumoFinanceiroWidgetState();
}

class _ResumoFinanceiroWidgetState extends State<ResumoFinanceiroWidget> {
  bool _expanded = false;

  static const _primaryColor = Color(0xFF0D3B66);
  static const _accentColor = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    final saldoCalc = widget.saldoAnterior + widget.totalCredito - widget.totalDebito;
    final saldoFinal = widget.saldoAtual != 0 ? widget.saldoAtual : saldoCalc;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header "Resumo" melhorado
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _expanded ? _primaryColor.withOpacity(0.05) : Colors.transparent,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 16,
                            color: _accentColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Resumo Financeiro',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: _primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: _primaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Conteúdo expandido com animação
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _expanded
                  ? _buildExpandedContent(saldoFinal, isMobile)
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpandedContent(double saldoFinal, bool isMobile) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            // Cards em grid responsivo
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = isMobile ? 2 : 4;
                final childAspectRatio = isMobile ? 1.2 : 1.5;
                
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildModernCard(
                      title: 'Saldo Anterior',
                      subtitle: 'Mês passado',
                      value: widget.saldoAnterior,
                      icon: Icons.history,
                      color: Colors.orange,
                      isNeutral: true,
                      isMobile: isMobile,
                    ),
                    _buildModernCard(
                      title: 'Receitas',
                      subtitle: 'Total recebido',
                      value: widget.totalCredito,
                      icon: Icons.trending_up,
                      color: Colors.green,
                      isNeutral: false,
                      isMobile: isMobile,
                    ),
                    _buildModernCard(
                      title: 'Despesas',
                      subtitle: 'Total gasto',
                      value: widget.totalDebito,
                      icon: Icons.trending_down,
                      color: Colors.red,
                      isNeutral: false,
                      isMobile: isMobile,
                    ),
                    _buildModernCard(
                      title: 'Saldo Atual',
                      subtitle: 'Disponível',
                      value: saldoFinal,
                      icon: Icons.account_balance_wallet,
                      color: saldoFinal >= 0 ? Colors.blue : Colors.red,
                      isNeutral: false,
                      isMobile: isMobile,
                    ),
                  ],
                );
              },
            ),

                      ],
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required String subtitle,
    required double value,
    required IconData icon,
    required Color color,
    required bool isNeutral,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com ícone
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 16 : 20,
                  color: color,
                ),
              ),
              const Spacer(),
              if (!isNeutral)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value >= 0 ? 'Positivo' : 'Negativo',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Valor principal
          Text(
            'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: value >= 0 ? Colors.black87 : Colors.red,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Título
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),

          // Subtítulo
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isMobile ? 10 : 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  }
