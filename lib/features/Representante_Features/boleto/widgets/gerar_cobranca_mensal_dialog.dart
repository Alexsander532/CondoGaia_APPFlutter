import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_cubit.dart';
import '../cubit/boleto_state.dart';
import 'selecionar_bloco_unid_dialog.dart';

class GerarCobrancaMensalDialog extends StatefulWidget {
  const GerarCobrancaMensalDialog({super.key});

  @override
  State<GerarCobrancaMensalDialog> createState() =>
      _GerarCobrancaMensalDialogState();
}

class _GerarCobrancaMensalDialogState extends State<GerarCobrancaMensalDialog> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _dataController = TextEditingController();
  final _cotaCondominialController = TextEditingController();
  final _fundoReservaController = TextEditingController();
  final _multaInfracaoController = TextEditingController();
  final _controleController = TextEditingController();
  final _rateioAguaController = TextEditingController();
  final _descontoController = TextEditingController();

  bool _enviarRegistro = false;
  bool _enviarEmail = false;
  List<String> _unidadesSelecionadas = [];
  String _labelUnidades = 'Todos';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dataController.text =
        '10/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  void dispose() {
    _dataController.dispose();
    _cotaCondominialController.dispose();
    _fundoReservaController.dispose();
    _multaInfracaoController.dispose();
    _controleController.dispose();
    _rateioAguaController.dispose();
    _descontoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoletoCubit, BoletoState>(
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'GERAR COBRANÇA MENSAL',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _primaryColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Boletos info + Selecionador Bloco/Unid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_labelUnidades',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => BlocProvider.value(
                              value: context.read<BoletoCubit>(),
                              child: SelecionarBlocoUnidDialog(
                                onConfirm: (ids) {
                                  setState(() {
                                    _unidadesSelecionadas = ids;
                                    _labelUnidades = ids.isEmpty
                                        ? 'Todos'
                                        : '${ids.length} Boletos';
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Bloco/Unid.',
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Data
                  Row(
                    children: [
                      const Text(
                        'Data:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _dataController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '//editável',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Campos financeiros
                  _buildCampoValor(
                    'Cota Condominial:',
                    _cotaCondominialController,
                  ),
                  _buildCampoValor('Fundo Reserva:', _fundoReservaController),
                  _buildCampoValor(
                    'Multa por Infração:',
                    _multaInfracaoController,
                  ),
                  _buildCampoValor('Controle:', _controleController),
                  _buildCampoValor('Rateio água:', _rateioAguaController),
                  _buildCampoValor('Desconto:', _descontoController),
                  const SizedBox(height: 16),

                  // Checkboxes
                  Row(
                    children: [
                      Checkbox(
                        value: _enviarRegistro,
                        onChanged: (val) {
                          setState(() => _enviarRegistro = val ?? false);
                        },
                        activeColor: _primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text(
                        'Enviar p/ Registro',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      Checkbox(
                        value: _enviarEmail,
                        onChanged: (val) {
                          setState(() => _enviarEmail = val ?? false);
                        },
                        activeColor: _primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text(
                        'Enviar p/ E-Mail',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botão Gerar Boleto
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isSaving
                          ? null
                          : () => _gerarBoleto(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'GERAR BOLETO',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCampoValor(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const Text('R\$', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                border: const UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _gerarBoleto(BuildContext context) {
    final cubit = context.read<BoletoCubit>();
    cubit.gerarCobrancaMensal(
      dataVencimento: _dataController.text,
      cotaCondominial: double.tryParse(_cotaCondominialController.text) ?? 0,
      fundoReserva: double.tryParse(_fundoReservaController.text) ?? 0,
      multaInfracao: double.tryParse(_multaInfracaoController.text) ?? 0,
      controle: double.tryParse(_controleController.text) ?? 0,
      rateioAgua: double.tryParse(_rateioAguaController.text) ?? 0,
      desconto: double.tryParse(_descontoController.text) ?? 0,
      enviarParaRegistro: _enviarRegistro,
      enviarPorEmail: _enviarEmail,
      unidadeIds: _unidadesSelecionadas.isNotEmpty
          ? _unidadesSelecionadas
          : null,
    );
    Navigator.pop(context);
  }
}
