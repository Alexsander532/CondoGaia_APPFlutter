import 'package:flutter/material.dart';
import '../../../../models/condominio.dart';

class TextosCondominioWidget extends StatefulWidget {
  final Condominio? condominio;

  const TextosCondominioWidget({super.key, this.condominio});

  @override
  State<TextosCondominioWidget> createState() => _TextosCondominioWidgetState();
}

class _TextosCondominioWidgetState extends State<TextosCondominioWidget> {
  // Controllers
  final _comunicadoCotaController = TextEditingController();
  final _comunicadoAcordoController = TextEditingController();
  final _textoBoletoTaxaController = TextEditingController();
  final _textoBoletoAcordoController = TextEditingController();

  final _responsavelTecnicoController = TextEditingController();
  final _cpfResponsavelController = TextEditingController();
  final _conselhoController = TextEditingController();
  final _funcoesController = TextEditingController();

  // State
  int _opcaoData = 0; // 0 = Com data, 1 = Sem data

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    // Mock default texts based on image
    const String defaultText =
        'IMPORTANTE: Inadimplência valores a partir 01/04/2016.\nOBS: APÓS 15 DIAS DO VENCIMENTO DO BOLETO PODERÁ SER PROTESTADO E INCLUSO NO SERASA E SPC.';

    _comunicadoCotaController.text = defaultText;
    _comunicadoAcordoController.text = defaultText;
    _textoBoletoTaxaController.text = defaultText;
    _textoBoletoAcordoController.text = defaultText;
  }

  @override
  void dispose() {
    _comunicadoCotaController.dispose();
    _comunicadoAcordoController.dispose();
    _textoBoletoTaxaController.dispose();
    _textoBoletoAcordoController.dispose();
    _responsavelTecnicoController.dispose();
    _cpfResponsavelController.dispose();
    _conselhoController.dispose();
    _funcoesController.dispose();
    super.dispose();
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, top: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0D3B66),
          fontSize: 14,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: const TextStyle(fontSize: 12),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildLabeledInput({
    required String label,
    required TextEditingController controller,
    String? hintText,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: -8, // Move label up to overlap border slightly or sit on top
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel('Texto Comunicado no Boleto da Cota Condominial'),
        _buildTextArea(_comunicadoCotaController),

        _buildSectionLabel('Texto Comunicado no Boleto do Acordo'),
        _buildTextArea(_comunicadoAcordoController),

        _buildSectionLabel('Texto do Boleto da Taxa de Condomínio'),
        _buildTextArea(_textoBoletoTaxaController),

        _buildSectionLabel('Texto do Boleto do Acordo'),
        _buildTextArea(_textoBoletoAcordoController),

        const SizedBox(height: 24),

        // Capa Demonstrativo Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Texto CAPA Demonstrativo',
              style: TextStyle(color: Color(0xFF0D3B66), fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B66),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 0,
                ),
                minimumSize: const Size(0, 30),
              ),
              child: const Text('Ver', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Inputs Responsavel
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: _buildLabeledInput(
            label: 'Nome Responsável Técnico',
            controller: _responsavelTecnicoController,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              flex: 4,
              child: _buildLabeledInput(
                label: 'CPF:',
                controller: _cpfResponsavelController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 5,
              child: _buildLabeledInput(
                label: 'Conselho',
                controller: _conselhoController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildLabeledInput(
          label: 'Funções',
          controller: _funcoesController,
          hintText: 'Separar as Funções com ;',
        ),
        const SizedBox(height: 12),

        // Radio buttons
        Row(
          children: [
            Radio<int>(
              value: 0,
              groupValue: _opcaoData,
              activeColor: const Color(0xFF0D3B66),
              onChanged: (val) => setState(() => _opcaoData = val!),
            ),
            const Text('Com data'),
            const SizedBox(width: 20),
            Radio<int>(
              value: 1,
              groupValue: _opcaoData,
              activeColor: const Color(0xFF0D3B66),
              onChanged: (val) => setState(() => _opcaoData = val!),
            ),
            const Text('Sem data'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
