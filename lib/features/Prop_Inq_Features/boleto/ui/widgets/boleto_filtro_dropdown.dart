import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_prop_cubit.dart';
import '../cubit/boleto_prop_state.dart';

/// Dropdown de filtro: "Vencido/ A Vencer" ou "Pago"
class BoletoFiltroDropdown extends StatelessWidget {
  const BoletoFiltroDropdown({super.key});

  static const _primaryColor = Color(0xFF0D3B66);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoletoPropCubit, BoletoPropState>(
      builder: (context, state) {
        final cubit = context.read<BoletoPropCubit>();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: _primaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.filtroSelecionado,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: _primaryColor),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _primaryColor,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Vencido/ A Vencer',
                  child: Text('Vencido/ A Vencer'),
                ),
                DropdownMenuItem(value: 'Pago', child: Text('Pago')),
              ],
              onChanged: (value) {
                if (value != null) {
                  cubit.alterarFiltro(value);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
