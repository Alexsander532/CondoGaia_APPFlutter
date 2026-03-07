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
  bool _expanded =
      true; // Start expanded as requested/implied by "Resumo ^" usually

  static const _primaryColor = Color(0xFF0D3B66);

  @override
  Widget build(BuildContext context) {
    // Calculando saldo atual se vier zerado (opcional, dependendo da lógica de negócio)
    final saldoCalc =
        widget.saldoAnterior + widget.totalCredito - widget.totalDebito;
    final saldoFinal = widget.saldoAtual != 0 ? widget.saldoAtual : saldoCalc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header "Resumo" com seta
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF2196F3),
                  width: 2,
                ), // Blue underline like image
              ),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Wrap content to look like the image label
              children: [
                const Text(
                  'Resumo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: _primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (_expanded)
          Column(
            children: [
              _buildSummarySection(
                title: 'SALDO ANTERIOR (DO MES PASSADO)',
                totalValue: widget.saldoAnterior,
                accounts: widget.saldoAnteriorPorConta,
              ),
              const SizedBox(height: 12),
              _buildSummarySection(
                title: 'TOTAL RECEITA',
                totalValue: widget.totalCredito,
                accounts: widget.totalCreditoPorConta,
              ),
              const SizedBox(height: 12),
              _buildSummarySection(
                title: 'TOTAL DESPESA',
                totalValue: widget.totalDebito,
                accounts: widget.totalDebitoPorConta,
              ),
              const SizedBox(height: 12),
              _buildSummarySection(
                title: 'SALDO ATUAL',
                totalValue: saldoFinal,
                accounts: widget.saldoAtualPorConta,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSummarySection({
    required String title,
    required double totalValue,
    required Map<String, double> accounts,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: TITLE ...... Total Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight
                      .w400, // Regular weight as per image, maybe slight bold
                  color:
                      _primaryColor, // Or black, image looks blackish/dark grey
                ),
              ),
              Text(
                'R\$ ${totalValue.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          if (accounts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                left: 16,
              ), // Indent accounts
              child: Column(
                children: accounts.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.key,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(
                              0xFF0D3B66,
                            ), // Dark blue for account names? Or black
                          ),
                        ),
                        Text(
                          'R\$ ${e.value.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16),
              child: const Text(
                'Sem dados de contas',
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
