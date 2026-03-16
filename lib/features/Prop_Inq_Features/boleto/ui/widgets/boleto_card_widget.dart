import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/boleto_prop_entity.dart';
import '../cubit/boleto_prop_cubit.dart';
import '../cubit/boleto_prop_state.dart';
import 'boleto_acoes_expandidas.dart';

/// Card expansível de um boleto individual
class BoletoCardWidget extends StatelessWidget {
  final BoletoPropEntity boleto;

  const BoletoCardWidget({super.key, required this.boleto});

  static const _primaryColor = Color(0xFF0D3B66);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoletoPropCubit, BoletoPropState>(
      builder: (context, state) {
        final cubit = context.read<BoletoPropCubit>();
        final isExpandido = state.boletoExpandidoId == boleto.id;
        final isPago = boleto.status == 'Pago';
        final dateFormatter = DateFormat('dd/MM/yyyy');
        final currencyFormatter = NumberFormat.currency(
          locale: 'pt_BR',
          symbol: 'R\$',
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isExpandido ? _primaryColor : Colors.grey.shade200,
              width: isExpandido ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header do card (sempre visível)
              InkWell(
                onTap: () => cubit.expandirBoleto(boleto.id),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // Data de vencimento
                      Text(
                        'Venc.: ${dateFormatter.format(boleto.dataVencimento)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: boleto.isVencido
                              ? Colors.red.shade700
                              : Colors.black87,
                        ),
                      ),

                      // Ícone de status (vencido ou pago)
                      if (boleto.isVencido && !isPago) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.flag, color: Colors.red.shade700, size: 18),
                      ],
                      if (isPago) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.thumb_up,
                          color: Colors.green.shade700,
                          size: 18,
                        ),
                      ],

                      const Spacer(),

                      // Valor
                      Text(
                        'Valor: ${currencyFormatter.format(boleto.valor)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: boleto.isVencido
                              ? Colors.red.shade700
                              : _primaryColor,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Ícone expandir/colapsar
                      Icon(
                        isExpandido
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),

              // Conteúdo expandido
              if (isExpandido)
                BoletoAcoesExpandidas(
                  codigoBarras: boleto.identificationField ?? 
                                boleto.barCode ?? 
                                boleto.codigoBarras,
                  boletoId: boleto.id,
                  tipo: boleto.tipo,
                  isVencido: boleto.isVencido,
                ),
            ],
          ),
        );
      },
    );
  }
}
