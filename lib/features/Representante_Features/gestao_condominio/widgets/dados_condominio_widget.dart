import 'package:flutter/material.dart';
import '../../../../models/condominio.dart';
import '../../../../models/representante.dart';

class DadosCondominioWidget extends StatefulWidget {
  final Condominio? condominio;
  final Representante? representante;

  const DadosCondominioWidget({
    super.key,
    required this.condominio,
    required this.representante,
  });

  @override
  State<DadosCondominioWidget> createState() => _DadosCondominioWidgetState();
}

class _DadosCondominioWidgetState extends State<DadosCondominioWidget> {
  // Controllers
  final _cnpjController = TextEditingController();
  final _nomeController = TextEditingController();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _celularController = TextEditingController();
  final _emailController = TextEditingController();
  final _siteController = TextEditingController();
  final _representanteController = TextEditingController();
  final _cpfController = TextEditingController();
  final _mandatoInicioController = TextEditingController();
  final _mandatoFimController = TextEditingController();

  // State variables for Radio Buttons
  String _tipoCondominio = 'Residencial'; // Default or Mock
  late bool _temBlocos;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  @override
  void didUpdateWidget(covariant DadosCondominioWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.condominio != oldWidget.condominio ||
        widget.representante != oldWidget.representante) {
      _populateFields();
    }
  }

  void _populateFields() {
    if (widget.condominio != null) {
      final c = widget.condominio!;
      _cnpjController.text = c.cnpjFormatado;
      _nomeController.text = c.nomeCondominio;
      _cepController.text = c.cepFormatado;
      _enderecoController.text = c.endereco;
      _numeroController.text = c.numero;
      _bairroController.text = c.bairro;
      _cidadeController.text = c.cidade;
      _estadoController.text = c.estado;
      _temBlocos = c.temBlocos;

      // Mock data for missing fields
      _telefoneController.text = '(51) 3246-5666'; // Mock from image
      _celularController.text = '(51) 99996-3254'; // Mock from image
      _emailController.text = 'josesilva@gmail.com'; // Mock from image
      _siteController.text = '-';
    } else {
      _temBlocos = true;
    }

    if (widget.representante != null) {
      final r = widget.representante!;
      _representanteController.text = r.nomeCompleto;
      _cpfController.text = r.cpfFormatado;
    }
  }

  @override
  void dispose() {
    _cnpjController.dispose();
    _nomeController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _telefoneController.dispose();
    _celularController.dispose();
    _emailController.dispose();
    _siteController.dispose();
    _representanteController.dispose();
    _cpfController.dispose();
    _mandatoInicioController.dispose();
    _mandatoFimController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    double? width,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF757575),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: true, // Read-only for now as requested "pegar dados"
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(color: Color(0xFF535353), fontSize: 14),
            ),
          ),
        ],
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
        _buildTextField(label: 'CNPJ:', controller: _cnpjController),
        _buildTextField(label: 'Nome Condomínio:', controller: _nomeController),
        _buildTextField(label: 'CEP:', controller: _cepController),
        _buildTextField(label: 'Endereço:', controller: _enderecoController),

        Row(
          children: [
            Expanded(
              flex: 4,
              child: _buildTextField(
                label: 'Número:',
                controller: _numeroController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: _buildTextField(
                label: 'Bairro:',
                controller: _bairroController,
              ),
            ),
          ],
        ),

        Row(
          children: [
            Expanded(
              flex: 6,
              child: _buildTextField(
                label: 'Cidade:',
                controller: _cidadeController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: _buildTextField(
                label: 'Estado:',
                controller: _estadoController,
              ),
            ),
          ],
        ),

        _buildTextField(label: 'Telefone:', controller: _telefoneController),
        _buildTextField(label: 'Celular:', controller: _celularController),
        _buildTextField(label: 'E-mail:', controller: _emailController),
        _buildTextField(label: 'Site:', controller: _siteController),
        _buildTextField(
          label: 'Representante*:',
          controller: _representanteController,
        ),
        _buildTextField(label: 'CPF*:', controller: _cpfController),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Mandato   Início:',
                controller: _mandatoInicioController,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                label: 'Fim:',
                controller: _mandatoFimController,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Tipo de Condomínio
        const Text(
          'Tipo de Condomínio',
          style: TextStyle(
            color: Color(0xFF0D3B66),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Row(
          children: [
            Radio<String>(
              value: 'Residencial',
              groupValue: _tipoCondominio,
              activeColor: const Color(0xFF0D3B66),
              onChanged: null, // Read-only
            ),
            const Text('Residencial'),
            const SizedBox(width: 20),
            Radio<String>(
              value: 'Comercial',
              groupValue: _tipoCondominio,
              activeColor: const Color(0xFF0D3B66),
              onChanged: null, // Read-only
            ),
            const Text('Comercial'),
          ],
        ),

        const SizedBox(height: 16),

        // Cond. possui Bloco?
        const Text(
          'Cond. possui Bloco?',
          style: TextStyle(
            color: Color(0xFF0D3B66),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: _temBlocos,
              activeColor: const Color(0xFF0D3B66),
              onChanged: null, // Read-only
            ),
            const Text('Sim'),
            const SizedBox(width: 20),
            Radio<bool>(
              value: false,
              groupValue: _temBlocos,
              activeColor: const Color(0xFF0D3B66),
              onChanged: null, // Read-only
            ),
            const Text('Não'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
