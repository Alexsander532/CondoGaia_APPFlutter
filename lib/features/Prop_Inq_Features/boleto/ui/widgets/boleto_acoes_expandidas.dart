import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_prop_cubit.dart';

/// Widget com ações expandidas: Ver Boleto, Copiar Código de Barras, Compartilhar
class BoletoAcoesExpandidas extends StatelessWidget {
  final String? codigoBarras;
  final String boletoId;
  final String tipo;
  final bool isVencido;

  const BoletoAcoesExpandidas({
    super.key,
    required this.codigoBarras,
    required this.boletoId,
    required this.tipo,
    required this.isVencido,
  });

  static const _primaryColor = Color(0xFF0D3B66);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BoletoPropCubit>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        children: [
          // Tipo do boleto (Taxa Condominial, Acordo, Avulso)
          Text(
            tipo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Ações: Ver Boleto, Copiar Código de Barras, Compartilhar
          if (!isVencido || codigoBarras != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAcaoItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Ver Boleto',
                  onTap: () {
                    cubit.verBoleto(boletoId);
                  },
                ),
                _buildAcaoItem(
                  icon: Icons.copy_outlined,
                  label: 'Copiar Código\nde Barras',
                  onTap: () {
                    cubit.copiarCodigoBarras(boletoId);
                  },
                ),
                _buildAcaoItem(
                  icon: Icons.share_outlined,
                  label: 'Compartilhar',
                  onTap: () {
                    cubit.compartilharBoleto(boletoId);
                  },
                ),
              ],
            ),
            if (codigoBarras != null && codigoBarras!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Código de Barras (Linha Digitável):',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            codigoBarras!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w500,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20, color: _primaryColor),
                          onPressed: () => cubit.copiarCodigoBarras(boletoId),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Copiar código',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],

          // Mensagem para boletos vencidos sem código de barras
          if (isVencido && codigoBarras == null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                children: [
                  Text(
                    '2ª Via entrar em contato com a Administração',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAcaoItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primaryColor, width: 1.5),
              ),
              child: Icon(icon, color: _primaryColor, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
