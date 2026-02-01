import 'package:flutter/material.dart';

class LeituraConfiguracaoScreen extends StatefulWidget {
  final String condominioId;

  const LeituraConfiguracaoScreen({super.key, required this.condominioId});

  @override
  State<LeituraConfiguracaoScreen> createState() =>
      _LeituraConfiguracaoScreenState();
}

class _LeituraConfiguracaoScreenState extends State<LeituraConfiguracaoScreen> {
  String selectedTipo = 'Água';
  String unidadeMedida = 'M³';

  List<String> _tipos = ['Água', 'Gás'];
  List<String> _unidadesMedida = ['M³', 'KG', 'L'];

  final _valorController = TextEditingController();

  // Taxas
  final _faixa1FimController = TextEditingController();
  final _faixa1ValorController = TextEditingController();
  final _faixa2InicioController = TextEditingController();
  final _faixa2FimController = TextEditingController();
  final _faixa2ValorController = TextEditingController();
  final _faixa3InicioController = TextEditingController();
  final _faixa3FimController = TextEditingController();
  final _faixa3ValorController = TextEditingController();

  int cobrancaTipo = 1; // 1 = Junto com taxa, 2 = Avulso

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tipo
          _buildDropdownField(
            label: 'Tipo:',
            value: selectedTipo,
            items: _tipos,
            onChanged: (val) => setState(() => selectedTipo = val!),
            onEdit: () => _showEditModal(
              label: 'Inserir Tipo:',
              onSave: (newVal) {
                if (newVal.isNotEmpty && !_tipos.contains(newVal)) {
                  setState(() {
                    _tipos.add(newVal);
                    selectedTipo = newVal;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // Unidade de Medida
          _buildDropdownField(
            label: 'Unidade de Medida:',
            value: unidadeMedida,
            items: _unidadesMedida,
            onChanged: (val) => setState(() => unidadeMedida = val!),
            onEdit: () => _showEditModal(
              label: 'Inserir Medida:',
              onSave: (newVal) {
                if (newVal.isNotEmpty && !_unidadesMedida.contains(newVal)) {
                  setState(() {
                    _unidadesMedida.add(newVal);
                    unidadeMedida = newVal;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // Valor por 1 M3
          Container(
            height: 50,
            decoration: _inputDecoration(),
            child: TextField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'Valor por 1 $unidadeMedida: ',
                prefixStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Faixa de valores',
            style: TextStyle(
              color: Color(0xFF0D3B66),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          // Faixas
          _buildFaixaRow('0', _faixa1FimController, _faixa1ValorController),
          const SizedBox(height: 12),
          _buildFaixaRowWithStart(
            _faixa2InicioController,
            _faixa2FimController,
            _faixa2ValorController,
          ),
          const SizedBox(height: 12),
          _buildFaixaRowWithStart(
            _faixa3InicioController,
            _faixa3FimController,
            _faixa3ValorController,
          ),

          const SizedBox(height: 24),
          const Text(
            'Cobrar:',
            style: TextStyle(
              color: Color(0xFF0D3B66),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Radio Buttons
          Row(
            children: [
              Radio(
                value: 1,
                groupValue: cobrancaTipo,
                onChanged: (val) => setState(() => cobrancaTipo = val!),
                activeColor: const Color(0xFF0D3B66),
              ),
              const Text(
                'Junto com a\nTaxa de Cond.',
                style: TextStyle(fontSize: 12),
              ),

              const Spacer(),

              Radio(
                value: 2,
                groupValue: cobrancaTipo,
                onChanged: (val) => setState(() => cobrancaTipo = val!),
                activeColor: const Color(0xFF0D3B66),
              ),
              const Text(
                'Avulso Venc: __/__/__',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 8),
            ],
          ),

          const SizedBox(height: 32),

          // Gravar Button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Save Logic Mock
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuração gravada!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B66),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Gravar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditModal({
    required String label,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      onSave(controller.text.trim());
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3B66),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'SALVAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required VoidCallback onEdit,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _inputDecoration(),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          InkWell(
            onTap: onEdit,
            child: const Icon(Icons.edit, color: Color(0xFF0D3B66), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFaixaRow(
    String startVal,
    TextEditingController endCtrl,
    TextEditingController valorCtrl,
  ) {
    return Row(
      children: [
        _buildBox(startVal + ' $unidadeMedida'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'à',
            style: TextStyle(
              color: Color(0xFF0D3B66),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildInputBox(endCtrl, suffix: ' $unidadeMedida'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '=',
            style: TextStyle(
              color: Color(0xFF0D3B66),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildInputBox(valorCtrl, prefix: 'R\$ '),
      ],
    );
  }

  Widget _buildFaixaRowWithStart(
    TextEditingController startCtrl,
    TextEditingController endCtrl,
    TextEditingController valorCtrl,
  ) {
    return Row(
      children: [
        _buildInputBox(startCtrl, suffix: ' $unidadeMedida'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'à',
            style: TextStyle(
              color: Color(0xFF0D3B66),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildInputBox(endCtrl, suffix: ' $unidadeMedida'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '=',
            style: TextStyle(
              color: Color(0xFF0D3B66),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildInputBox(valorCtrl, prefix: 'R\$ '),
      ],
    );
  }

  Widget _buildBox(String text) {
    return Expanded(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInputBox(
    TextEditingController ctrl, {
    String? prefix,
    String? suffix,
  }) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(bottom: 8),
            prefixText: prefix,
            suffixText: suffix,
            hintText: suffix != null ? '___' : null,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade400),
    );
  }
}
