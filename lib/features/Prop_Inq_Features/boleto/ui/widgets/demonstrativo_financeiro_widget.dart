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
          child: Row(
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
        );
      },
    );
  }
}
