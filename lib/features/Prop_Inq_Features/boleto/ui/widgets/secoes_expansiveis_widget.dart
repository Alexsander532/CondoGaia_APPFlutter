import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_prop_cubit.dart';
import '../cubit/boleto_prop_state.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return BlocBuilder<BoletoPropCubit, BoletoPropState>(
      builder: (context, state) {
        final composicao = state.composicaoBoleto;
        
        if (composicao == null || composicao.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Text(
              'Composição não disponível.',
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
              if (composicao['cotaCondominial'] != null && composicao['cotaCondominial']! > 0)
                _buildLinhaComposicao('Cota Condominial', 'R\$ ${composicao['cotaCondominial']!.toStringAsFixed(2)}'),
              if (composicao['fundoReserva'] != null && composicao['fundoReserva']! > 0) ...[
                const SizedBox(height: 8),
                _buildLinhaComposicao('Fundo de Reserva', 'R\$ ${composicao['fundoReserva']!.toStringAsFixed(2)}'),
              ],
              if (composicao['rateioAgua'] != null && composicao['rateioAgua']! > 0) ...[
                const SizedBox(height: 8),
                _buildLinhaComposicao('Rateio Água', 'R\$ ${composicao['rateioAgua']!.toStringAsFixed(2)}'),
              ],
              if (composicao['multaInfracao'] != null && composicao['multaInfracao']! > 0) ...[
                const SizedBox(height: 8),
                _buildLinhaComposicao('Multa Infração', 'R\$ ${composicao['multaInfracao']!.toStringAsFixed(2)}'),
              ],
              if (composicao['controle'] != null && composicao['controle']! > 0) ...[
                const SizedBox(height: 8),
                _buildLinhaComposicao('Controle', 'R\$ ${composicao['controle']!.toStringAsFixed(2)}'),
              ],
              if (composicao['desconto'] != null && composicao['desconto']! > 0) ...[
                const SizedBox(height: 8),
                _buildLinhaComposicao('Desconto', 'R\$ -${composicao['desconto']!.toStringAsFixed(2)}'),
              ],
              const Divider(height: 24),
              _buildLinhaComposicao('Total', 'R\$ ${composicao['valorTotal']?.toStringAsFixed(2) ?? '0,00'}', isBold: true),
            ],
          ),
        );
      },
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
    return BlocBuilder<BoletoPropCubit, BoletoPropState>(
      builder: (context, state) {
        final leituras = state.leituras;
        
        if (leituras == null || leituras.isEmpty) {
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
            children: leituras.map((leitura) {
              final dataLeitura = leitura['data_leitura'] as String?;
              final tipoLeitura = leitura['tipo'] as String? ?? 'Não informado';
              final valorLeitura = leitura['valor'] as num?;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$tipoLeitura - ${dataLeitura ?? 'Sem data'}',
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    Text(
                      '${valorLeitura?.toString() ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildBalanceteConteudo() {
    return BlocBuilder<BoletoPropCubit, BoletoPropState>(
      builder: (context, state) {
        final balancete = state.balanceteOnline;
        
        if (balancete == null || balancete.isEmpty) {
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

        final nomeArquivo = balancete['nome_arquivo'] as String? ?? 'Balancete';
        final url = balancete['url'] as String?;
        final linkExterno = balancete['link_externo'] as String?;

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
              Text(
                'Balancete - ${balancete['mes']}/${balancete['ano']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      nomeArquivo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                  if (url != null || linkExterno != null)
                    TextButton.icon(
                      onPressed: () async {
                        final uriString = url ?? linkExterno;
                        if (uriString != null && uriString.isNotEmpty) {
                          final uri = Uri.parse(uriString);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        }
                      },
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Baixar'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLinhaBalancete(String label, String valor, {bool isBold = false}) {
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
