import 'package:flutter/material.dart';
import '../../../../models/condominio.dart';

class FinanceiroCondominioWidget extends StatefulWidget {
  final Condominio? condominio;

  const FinanceiroCondominioWidget({super.key, required this.condominio});

  @override
  State<FinanceiroCondominioWidget> createState() =>
      _FinanceiroCondominioWidgetState();
}

class _FinanceiroCondominioWidgetState
    extends State<FinanceiroCondominioWidget> {
  // Controllers
  final _jurosController = TextEditingController();
  final _multaController = TextEditingController();
  final _diaVencimentoController = TextEditingController();
  final _descontoController = TextEditingController();
  final _fundoReservaPorcentagemController = TextEditingController();
  final _fundoReservaValorController = TextEditingController();
  final _valorFixoCondominioController = TextEditingController();

  // State
  bool _fundoReservaPorcentagem = true; // true = %, false = R$
  int _tipoCobrancaCondominio = 1; // 0 = Rateio, 1 = Valor Fixo
  int _refDespesasReceitas = 0; // 0 = 1 mês, 1 = 2 meses

  // Dynamic List for Tipos
  final List<Map<String, dynamic>> _tipos = [
    {'tipo': 'A', 'valor': '500,00'},
    {'tipo': 'B', 'valor': '300,00'},
  ];

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  @override
  void didUpdateWidget(covariant FinanceiroCondominioWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.condominio != oldWidget.condominio) {
      _populateFields();
    }
  }

  void _populateFields() {
    if (widget.condominio != null) {
      final c = widget.condominio!;
      // Populate logic - mapping what we have
      if (c.vencimento != null) {
        _diaVencimentoController.text = c.vencimento!.day.toString();
      }

      // Mocking defaults for fields not in model yet
      _jurosController.text = '2'; // Example default
      _multaController.text = '2'; // Example default

      if (c.valor != null) {
        _valorFixoCondominioController.text = c.valorFormatado.replaceAll(
          'R\$ ',
          '',
        );
        _tipoCobrancaCondominio = 1; // Assume fixed if value exists
      }
    }
  }

  @override
  void dispose() {
    _jurosController.dispose();
    _multaController.dispose();
    _diaVencimentoController.dispose();
    _descontoController.dispose();
    _fundoReservaPorcentagemController.dispose();
    _fundoReservaValorController.dispose();
    _valorFixoCondominioController.dispose();
    super.dispose();
  }

  // Helper widget for rounded input
  Widget _buildRoundedTextField({
    required String label, // Can include prefix like "Juros (%):"
    required TextEditingController controller,
    String? prefixText,
    double? width,
  }) {
    // Split label to get the "Juros (%):" part and handle "Dia __" logic if needed
    // But for simplicity, we'll put the text outside or inside as decoration.
    // The design has a label INSIDE the border for "Juros (%):" which acts as prompt?
    // Actually it looks like "Juros (%): [input]" inside the box.

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '',
                prefixText: prefixText,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0D3B66),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.condominio == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1: Juros e Multa
        Row(
          children: [
            Expanded(
              child: _buildRoundedTextField(
                label: 'Juros (%):',
                controller: _jurosController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoundedTextField(
                label: 'Multa (%):',
                controller: _multaController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Vencimento e Desconto
        Row(
          children: [
            Expanded(
              child: _buildRoundedTextField(
                label: 'Venc. do Boleto*: Dia',
                controller: _diaVencimentoController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoundedTextField(
                label: 'Desconto:',
                controller: _descontoController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tipo de Fundo Reserva
        _buildSectionTitle('Tipo de Fundo Reserva'),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _fundoReservaPorcentagem = true),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Text(
                        'Porcentagem: (%)',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      if (_fundoReservaPorcentagem)
                        Expanded(
                          child: TextField(
                            controller: _fundoReservaPorcentagemController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _fundoReservaPorcentagem = false),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Text(
                        'Valor Fixo: R\$',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          decoration: !_fundoReservaPorcentagem
                              ? TextDecoration.underline
                              : null,
                          decorationColor: const Color(0xFF0D3B66),
                          fontWeight: !_fundoReservaPorcentagem
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!_fundoReservaPorcentagem)
                        Expanded(
                          child: TextField(
                            controller: _fundoReservaValorController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Cobrar Condomínio
        _buildSectionTitle('Cobrar Condomínio'),
        Row(
          children: [
            Radio<int>(
              value: 0,
              groupValue: _tipoCobrancaCondominio,
              activeColor: const Color(0xFF0D3B66),
              onChanged: (val) =>
                  setState(() => _tipoCobrancaCondominio = val!),
            ),
            const Text('Rateio de contas'),
            const SizedBox(width: 12),
            Radio<int>(
              value: 1,
              groupValue: _tipoCobrancaCondominio,
              activeColor: const Color(0xFF0D3B66),
              onChanged: (val) =>
                  setState(() => _tipoCobrancaCondominio = val!),
            ),
            const Text('Valor Fixo'),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _valorFixoCondominioController,
                  enabled: _tipoCobrancaCondominio == 1,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    prefixText: '* R\$ ',
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Dynamic Types List
        ..._tipos.asMap().entries.map((entry) {
          final index = entry.key;
          final tipo = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Text(
                  'Tipo:',
                  style: TextStyle(
                    color: Color(0xFF0D3B66),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                // Tipo Input (A, B...)
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  alignment: Alignment.center,
                  child: TextFormField(
                    initialValue: tipo['tipo'],
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(border: InputBorder.none),
                    onChanged: (val) => tipo['tipo'] = val,
                  ),
                ),
                const SizedBox(width: 12),
                // Valor Input
                Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextFormField(
                    initialValue: tipo['valor']
                        .toString(), // Simplified for mock
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixText: 'R\$ ',
                    ),
                    onChanged: (val) => tipo['valor'] = val,
                  ),
                ),
                const SizedBox(width: 12),
                // Action Button
                if (index == 0)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _tipos.add({'tipo': '', 'valor': ''});
                      });
                    },
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF0D3B66),
                      size: 32,
                    ),
                  )
                else
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _tipos.removeAt(index);
                      });
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 16),

        // Ref. das Despesas/Receitas
        _buildSectionTitle('Ref. das Despesas/Receitas'),
        Row(
          children: [
            Radio<int>(
              value: 0,
              groupValue: _refDespesasReceitas,
              activeColor: const Color(0xFF0D3B66),
              onChanged: (val) => setState(() => _refDespesasReceitas = val!),
            ),
            const Text('1 mês anterior'),
            const SizedBox(width: 20),
            Radio<int>(
              value: 1,
              groupValue: _refDespesasReceitas,
              activeColor: const Color(0xFF0D3B66),
              onChanged: (val) => setState(() => _refDespesasReceitas = val!),
            ),
            const Text('2 meses anteriores'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
