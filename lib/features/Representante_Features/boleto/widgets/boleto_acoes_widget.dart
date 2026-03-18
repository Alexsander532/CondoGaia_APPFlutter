import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/boleto_cubit.dart';
import '../cubit/boleto_state.dart';
import 'receber_boleto_dialog.dart';

class BoletoAcoesWidget extends StatelessWidget {
  const BoletoAcoesWidget({super.key});

  static const _primaryColor = Color(0xFF0D3B66);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoletoCubit, BoletoState>(
      builder: (context, state) {
        final cubit = context.read<BoletoCubit>();
        final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

        return Column(
          children: [
            // === Botões principais: Receber, Excluir, Agrupar ===
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                // Receber
                ElevatedButton(
                  onPressed: state.itensSelecionados.length == 1
                      ? () {
                          showDialog(
                            context: context,
                            builder: (_) => BlocProvider.value(
                              value: cubit,
                              child: ReceberBoletoDialog(
                                boletoId: state.itensSelecionados.first,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Receber',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),

                // Excluir
                OutlinedButton(
                  onPressed: state.itensSelecionados.isNotEmpty
                      ? () => _confirmarExclusao(context, cubit, state)
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Excluir',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),

                // Agrupar
                ElevatedButton(
                  onPressed: state.itensSelecionados.length >= 2
                      ? () => _confirmarAgrupamento(context, cubit, state)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Agrupar',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // === Qtd e Total ===
            Row(
              children: [
                Text(
                  'Qtnd.:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${state.qtdSelecionada}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  formatter.format(state.totalSelecionado),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // === Botões secundários: Ver PDF, Visualizar, E-mail, Compartilhar ===
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _actionButton(context, 'Ver PDF', Icons.picture_as_pdf),
                _actionButton(context, 'Visualizar', Icons.visibility),
                _actionButton(
                  context,
                  'E-mail',
                  Icons.email,
                  onPressed: () {
                    if (state.itensSelecionados.isNotEmpty) {
                      cubit.enviarBoletosPorEmail();
                    } else {
                      _showSnack(
                        context,
                        'Selecione boletos para enviar por e-mail',
                      );
                    }
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: _primaryColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.share,
                      color: _primaryColor,
                      size: 20,
                    ),
                    onPressed: () =>
                        _showSnack(context, 'Compartilhar — Em breve'),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // === Enviar para Registro (Individual) ===
            if (state.itensSelecionados.length == 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => cubit.registrarBoletoNoAsaas(
                      state.itensSelecionados.first,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Registrar no ASAAS',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),

            // === Verificar Registro / Registro em Lote ===
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.itensSelecionados.isNotEmpty
                    ? () => cubit.enviarParaRegistro()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  state.itensSelecionados.length > 1
                      ? 'Verificar/Registrar em Lote'
                      : 'Verificar Registro no ASAAS',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // === Disparar por E-Mail ===
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: false,
                  onChanged: (_) {
                    _showSnack(context, 'Disparar por E-Mail — Em breve');
                  },
                  activeColor: _primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const Text(
                  'Disparar por E-Mail',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _actionButton(
    BuildContext context,
    String label,
    IconData icon, {
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed ?? () => _showSnack(context, '$label — Em breve'),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _confirmarExclusao(
    BuildContext context,
    BoletoCubit cubit,
    BoletoState state,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja excluir ${state.qtdSelecionada} boleto(s) selecionado(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.excluirSelecionados();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _confirmarAgrupamento(
    BuildContext context,
    BoletoCubit cubit,
    BoletoState state,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Agrupamento'),
        content: Text(
          'Deseja agrupar ${state.qtdSelecionada} boletos selecionados em um acordo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.agruparSelecionados();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Agrupar'),
          ),
        ],
      ),
    );
  }
}
