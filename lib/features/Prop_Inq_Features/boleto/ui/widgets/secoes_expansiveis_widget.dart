import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_prop_cubit.dart';
import '../cubit/boleto_prop_state.dart';

/// Seções expansíveis: Composição do Boleto, Leituras, Balancete Online
class SecoesExpansiveisWidget extends StatelessWidget {
  const SecoesExpansiveisWidget({super.key});

  static const _primaryColor = Color(0xFF0D3B66);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoletoPropCubit, BoletoPropState>(
      builder: (context, state) {
        final cubit = context.read<BoletoPropCubit>();

        return Column(
          children: [
            // Composição do Boleto
            _buildSecaoExpansivel(
              titulo: 'Composição do Boleto',
              isExpanded: state.composicaoBoletoExpandida,
              onTap: () => cubit.toggleComposicaoBoleto(),
              conteudo: _buildComposicaoConteudo(),
            ),
            const Divider(height: 1),

            // Leituras
            _buildSecaoExpansivel(
              titulo: 'Leituras',
              isExpanded: state.leiturasExpandida,
              onTap: () => cubit.toggleLeituras(),
              conteudo: _buildLeiturasConteudo(),
            ),
            const Divider(height: 1),

            // Balancete Online
            _buildSecaoExpansivel(
              titulo: 'Balancete Online',
              isExpanded: state.balanceteOnlineExpandido,
              onTap: () => cubit.toggleBalanceteOnline(),
              conteudo: _buildBalanceteConteudo(),
            ),
            const Divider(height: 1),
          ],
        );
      },
    );
  }

  Widget _buildSecaoExpansivel({
    required String titulo,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget conteudo,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: _primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: conteudo,
          ),
      ],
    );
  }

  Widget _buildComposicaoConteudo() {
    // TODO: Conectar com dados reais
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
          _buildLinhaComposicao('Cota Condominial', 'R\$ 300,00'),
          const SizedBox(height: 8),
          _buildLinhaComposicao('Fundo de Reserva', 'R\$ 50,00'),
          const SizedBox(height: 8),
          _buildLinhaComposicao('Rateio Água', 'R\$ 50,00'),
          const Divider(height: 24),
          _buildLinhaComposicao('Total', 'R\$ 400,00', isBold: true),
        ],
      ),
    );
  }

  Widget _buildLinhaComposicao(
    String label,
    String valor, {
    bool isBold = false,
  }) {
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

  Widget _buildLeiturasConteudo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Text(
        'Nenhuma leitura disponível para este período.',
        style: TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }

  Widget _buildBalanceteConteudo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Text(
        'Balancete online não disponível para este período.',
        style: TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }
}
