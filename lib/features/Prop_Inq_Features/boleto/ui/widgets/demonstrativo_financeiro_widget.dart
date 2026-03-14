import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_prop_cubit.dart';
import '../cubit/boleto_prop_state.dart';

/// Seletor de mês/ano para o Demonstrativo Financeiro
class DemonstrativoFinanceiroWidget extends StatelessWidget {
  const DemonstrativoFinanceiroWidget({super.key});

  static const _primaryColor = Color(0xFF0D3B66);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoletoPropCubit, BoletoPropState>(
      builder: (context, state) {
        final cubit = context.read<BoletoPropCubit>();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Demonstrativo Financeiro',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                    ),
                  ),
                  const Spacer(),
                  // Setas de navegação < MM / YYYY >
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: _primaryColor),
                    onPressed: () => cubit.mesAnterior(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 22,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${state.mesSelecionado.toString().padLeft(2, '0')} / ${state.anoSelecionado}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: _primaryColor),
                    onPressed: () => cubit.proximoMes(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 22,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Dados do demonstrativo financeiro
              _buildDemonstrativoDados(state),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDemonstrativoDados(BoletoPropState state) {
    final demonstrativo = state.demonstrativoFinanceiro;
    
    if (demonstrativo == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text(
          'Carregando demonstrativo...',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLinhaDemonstrativo('Total de Boletos', '${demonstrativo['quantidadeBoletos'] ?? 0}'),
          const SizedBox(height: 8),
          _buildLinhaDemonstrativo('Boletos Pagos', '${demonstrativo['quantidadePagos'] ?? 0}'),
          const SizedBox(height: 8),
          _buildLinhaDemonstrativo('Boletos em Aberto', '${demonstrativo['quantidadeEmAberto'] ?? 0}'),
          const Divider(height: 16),
          _buildLinhaDemonstrativo('Valor Total', 'R\$ ${(demonstrativo['totalValor'] as double?)?.toStringAsFixed(2) ?? '0,00'}', isBold: true),
          const SizedBox(height: 8),
          _buildLinhaDemonstrativo('Valor Pago', 'R\$ ${(demonstrativo['totalPago'] as double?)?.toStringAsFixed(2) ?? '0,00'}'),
          const SizedBox(height: 8),
          _buildLinhaDemonstrativo('Valor em Aberto', 'R\$ ${(demonstrativo['totalEmAberto'] as double?)?.toStringAsFixed(2) ?? '0,00'}'),
        ],
      ),
    );
  }

  Widget _buildLinhaDemonstrativo(String label, String valor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: _primaryColor,
          ),
        ),
      ],
    );
  }
}
