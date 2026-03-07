import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_cubit.dart';
import '../cubit/boleto_state.dart';

class ReceberBoletoDialog extends StatefulWidget {
  final String boletoId;

  const ReceberBoletoDialog({super.key, required this.boletoId});

  @override
  State<ReceberBoletoDialog> createState() => _ReceberBoletoDialogState();
}

class _ReceberBoletoDialogState extends State<ReceberBoletoDialog> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _dataPagamentoController = TextEditingController();
  final _jurosController = TextEditingController(text: '0');
  final _multaController = TextEditingController(text: '0');
  final _outrosAcrescController = TextEditingController(text: '0');
  final _valorTotalController = TextEditingController();
  final _obsController = TextEditingController();

  String? _contaSelecionadaId;

  @override
  void dispose() {
    _dataPagamentoController.dispose();
    _jurosController.dispose();
    _multaController.dispose();
    _outrosAcrescController.dispose();
    _valorTotalController.dispose();
    _obsController.dispose();
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
            constraints: const BoxConstraints(maxWidth: 400),
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
                        'RECEBER BOLETO',
                        style: TextStyle(
                          fontSize: 16,
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
                  const SizedBox(height: 12),

                  // Conta Bancária
                  const Text(
                    'Conta Bancária:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _contaSelecionadaId,
                    isDense: true,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    items: state.contasBancarias
                        .map(
                          (conta) => DropdownMenuItem<String>(
                            value: conta['id'] as String,
                            child: Text(
                              conta['banco'] as String? ?? 'Conta',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() => _contaSelecionadaId = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Data do Pagamento
                  _buildTextField(
                    'Data do Pagamento:',
                    _dataPagamentoController,
                    hint: '__/__/____',
                  ),
                  const SizedBox(height: 14),

                  // Juros, Multa, Out. Acresc.
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Juros:',
                          _jurosController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTextField(
                          'Multa:',
                          _multaController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTextField(
                          'Out. Acresc:',
                          _outrosAcrescController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Valor Total
                  _buildTextField(
                    'Valor Total (R\$):',
                    _valorTotalController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),

                  // Obs
                  _buildTextField('Obs.:', _obsController, maxLines: 2),
                  const SizedBox(height: 20),

                  // Botão Pagar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isSaving ? null : () => _pagar(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
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
                              'PAGAR',
                              style: TextStyle(
                                fontSize: 16,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _primaryColor),
            ),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  void _pagar(BuildContext context) {
    if (_contaSelecionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma conta bancária')),
      );
      return;
    }

    final cubit = context.read<BoletoCubit>();
    cubit.receberBoleto(
      boletoId: widget.boletoId,
      contaBancariaId: _contaSelecionadaId!,
      dataPagamento: _dataPagamentoController.text,
      juros: double.tryParse(_jurosController.text) ?? 0,
      multa: double.tryParse(_multaController.text) ?? 0,
      outrosAcrescimos: double.tryParse(_outrosAcrescController.text) ?? 0,
      valorTotal: double.tryParse(_valorTotalController.text) ?? 0,
      obs: _obsController.text.isNotEmpty ? _obsController.text : null,
    );

    Navigator.pop(context);
  }
}
