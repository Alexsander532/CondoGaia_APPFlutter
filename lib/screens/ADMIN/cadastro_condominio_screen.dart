import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import '../../services/supabase_service.dart';

class CadastroCondominioScreen extends StatefulWidget {
  const CadastroCondominioScreen({super.key});

  @override
  State<CadastroCondominioScreen> createState() => _CadastroCondominioScreenState();
}

class _CadastroCondominioScreenState extends State<CadastroCondominioScreen> {
  final _cnpjController = TextEditingController();
  final _nomeController = TextEditingController();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _planoAssinaturaController = TextEditingController();
  final _pagamentoController = TextEditingController();
  final _vencimentoController = TextEditingController();
  final _valorController = TextEditingController();
  final _instituicaoCondominioController = TextEditingController();
  final _tokenCondominioController = TextEditingController();
  final _instituicaoUnidadeController = TextEditingController();
  final _tokenUnidadeController = TextEditingController();

  // Máscaras de formatação
  final _cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _dateMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Estado selecionado
  String? _estadoSelecionado; // Permitir seleção vazia inicialmente
  bool _isLoading = false;

  // Lista de estados brasileiros
  final List<Map<String, String>> _estados = [
    {'sigla': 'AC', 'nome': 'Acre'},
    {'sigla': 'AL', 'nome': 'Alagoas'},
    {'sigla': 'AP', 'nome': 'Amapá'},
    {'sigla': 'AM', 'nome': 'Amazonas'},
    {'sigla': 'BA', 'nome': 'Bahia'},
    {'sigla': 'CE', 'nome': 'Ceará'},
    {'sigla': 'DF', 'nome': 'Distrito Federal'},
    {'sigla': 'ES', 'nome': 'Espírito Santo'},
    {'sigla': 'GO', 'nome': 'Goiás'},
    {'sigla': 'MA', 'nome': 'Maranhão'},
    {'sigla': 'MT', 'nome': 'Mato Grosso'},
    {'sigla': 'MS', 'nome': 'Mato Grosso do Sul'},
    {'sigla': 'MG', 'nome': 'Minas Gerais'},
    {'sigla': 'PA', 'nome': 'Pará'},
    {'sigla': 'PB', 'nome': 'Paraíba'},
    {'sigla': 'PR', 'nome': 'Paraná'},
    {'sigla': 'PE', 'nome': 'Pernambuco'},
    {'sigla': 'PI', 'nome': 'Piauí'},
    {'sigla': 'RJ', 'nome': 'Rio de Janeiro'},
    {'sigla': 'RN', 'nome': 'Rio Grande do Norte'},
    {'sigla': 'RS', 'nome': 'Rio Grande do Sul'},
    {'sigla': 'RO', 'nome': 'Rondônia'},
    {'sigla': 'RR', 'nome': 'Roraima'},
    {'sigla': 'SC', 'nome': 'Santa Catarina'},
    {'sigla': 'SP', 'nome': 'São Paulo'},
    {'sigla': 'SE', 'nome': 'Sergipe'},
    {'sigla': 'TO', 'nome': 'Tocantins'},
  ];

  @override
  void dispose() {
    _cnpjController.dispose();
    _nomeController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _planoAssinaturaController.dispose();
    _pagamentoController.dispose();
    _vencimentoController.dispose();
    _valorController.dispose();
    _instituicaoCondominioController.dispose();
    _tokenCondominioController.dispose();
    _instituicaoUnidadeController.dispose();
    _tokenUnidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  // Menu hamburger
                  const Icon(
                    Icons.menu,
                    size: 24,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 16),
                  // Logo
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_CondoGaia.png',
                        height: 40,
                      ),
                    ),
                  ),
                  // Ícones do lado direito
                  Image.asset(
                    'assets/images/Sino_Notificacao.png',
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 12),
                  Image.asset(
                    'assets/images/Fone_Ouvido_Cabecalho.png',
                    height: 24,
                    width: 24,
                  ),
                ],
              ),
            ),
            // Navegação breadcrumb
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Home/Cadastrar Condomínio',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção Dados
                    _buildSectionTitle('Dados'),
                    const SizedBox(height: 16),
                    _buildTextFieldWithMask('CNPJ:', _cnpjController, '19.555.666/0001-69', _cnpjMask, required: true),
                    const SizedBox(height: 12),
                    _buildTextField('Nome Condomínio:', _nomeController, 'Villas de Córdoba', required: true),
                    const SizedBox(height: 12),
                    _buildTextFieldWithMask('CEP:', _cepController, '11123-456', _cepMask, required: true),
                    const SizedBox(height: 12),
                    _buildTextField('Endereço:', _enderecoController, 'Rua Almirante Carlos Guedert', required: true),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildTextField('Número:', _numeroController, '', required: true),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildTextField('Bairro:', _bairroController, '', required: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField('Estado:', _estadoSelecionado, _estados, required: true),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField('Cidade:', _cidadeController, '', required: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Seção Financeiro - Condomínio
                    _buildSectionTitle('Financeiro - Condomínio'),
                    const SizedBox(height: 16),
                    _buildTextField('Plano de assinatura:', _planoAssinaturaController, 'Mensal'),
                    const SizedBox(height: 12),
                    _buildTextField('Pagamento:', _pagamentoController, 'Boleto'),
                    const SizedBox(height: 12),
                    _buildTextFieldWithMask('Vencimento:', _vencimentoController, '13/03/2024', _dateMask),
                    const SizedBox(height: 12),
                    _buildMoneyField('Valor:', _valorController, 'R\$ 300,00'),
                    const SizedBox(height: 12),
                    _buildTextField('Instituição:', _instituicaoCondominioController, 'ASAAS'),
                    const SizedBox(height: 12),
                    _buildTextField('Token:', _tokenCondominioController, 'qjskf4qpbabqs2s1e61611f6v16as1as6'),
                    const SizedBox(height: 24),
                    // Seção Financeiro - Unidade
                    _buildSectionTitle('Financeiro - Unidade'),
                    const SizedBox(height: 16),
                    _buildTextField('Instituição:', _instituicaoUnidadeController, 'ASAAS'),
                    const SizedBox(height: 12),
                    _buildTextField('Token:', _tokenUnidadeController, 'qjskf4qpbabqs2s1e61611f6v16as1as6'),
                    const SizedBox(height: 32),
                    // Botão Salvar
                    Center(
                      child: GestureDetector(
                        onTap: _isLoading ? null : () {
                          // Implementar funcionalidade de salvar
                          _salvarCondominio();
                        },
                        child: Container(
                          width: 200,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _isLoading ? Colors.grey : const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'SALVAR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String placeholder, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithMask(String label, TextEditingController controller, String placeholder, MaskTextInputFormatter mask, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: controller,
            inputFormatters: [mask],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoneyField(String label, TextEditingController controller, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _MoneyInputFormatter(),
            ],
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? selectedValue, List<Map<String, String>> options, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            isExpanded: true,
            hint: Text(
              'Selecione um estado',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: options.map((estado) {
              return DropdownMenuItem<String>(
                value: estado['sigla'],
                child: Text(
                  '${estado['sigla']} - ${estado['nome']}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _estadoSelecionado = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 1,
          width: double.infinity,
          color: const Color(0xFF1E3A8A),
        ),
      ],
    );
  }

  Future<void> _salvarCondominio() async {
    // Validar apenas os campos da seção Dados (obrigatórios)
    if (_cnpjController.text.isEmpty ||
        _nomeController.text.isEmpty ||
        _cepController.text.isEmpty ||
        _enderecoController.text.isEmpty ||
        _numeroController.text.isEmpty ||
        _bairroController.text.isEmpty ||
        _cidadeController.text.isEmpty ||
        _estadoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios da seção Dados.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar formato do CNPJ
    if (_cnpjController.text.length != 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CNPJ deve ter o formato: 00.000.000/0001-00'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar formato do CEP
    if (_cepController.text.length != 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CEP deve ter o formato: 00000-000'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Converter valor monetário para decimal (opcional)
      double valor = 0.0;
      if (_valorController.text.isNotEmpty) {
        String valorText = _valorController.text
            .replaceAll('R\u0024 ', '')
            .replaceAll('.', '')
            .replaceAll(',', '.');
        valor = double.parse(valorText);
      }

      // Converter data para formato ISO (opcional)
      String? isoDate;
      if (_vencimentoController.text.isNotEmpty) {
        if (_vencimentoController.text.length == 10) {
          List<String> dateParts = _vencimentoController.text.split('/');
          isoDate = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';
        }
      }

      // Preparar dados para inserção
      Map<String, dynamic> condominioData = {
        'cnpj': _cnpjController.text,
        'nome_condominio': _nomeController.text,
        'cep': _cepController.text,
        'endereco': _enderecoController.text,
        'numero': _numeroController.text,
        'bairro': _bairroController.text,
        'cidade': _cidadeController.text,
        'estado': _estadoSelecionado,
        'plano_assinatura': _planoAssinaturaController.text.isEmpty ? null : _planoAssinaturaController.text,
        'pagamento': _pagamentoController.text.isEmpty ? null : _pagamentoController.text,
        'vencimento': isoDate,
        'valor': valor > 0 ? valor : null,
        'instituicao_financeiro_condominio': _instituicaoCondominioController.text.isEmpty ? null : _instituicaoCondominioController.text,
        'token_financeiro_condominio': _tokenCondominioController.text.isEmpty ? null : _tokenCondominioController.text,
        'instituicao_financeiro_unidade': _instituicaoUnidadeController.text.isEmpty ? null : _instituicaoUnidadeController.text,
        'token_financeiro_unidade': _tokenUnidadeController.text.isEmpty ? null : _tokenUnidadeController.text,
      };

      // Inserir no Supabase
      await SupabaseService.insertCondominio(condominioData);

      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Condomínio cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Limpar formulário
      _limparFormulario();

    } catch (e) {
      // Mostrar mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar condomínio: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _limparFormulario() {
    _cnpjController.clear();
    _nomeController.clear();
    _cepController.clear();
    _enderecoController.clear();
    _numeroController.clear();
    _bairroController.clear();
    _cidadeController.clear();
    _planoAssinaturaController.clear();
    _pagamentoController.clear();
    _vencimentoController.clear();
    _valorController.clear();
    _instituicaoCondominioController.clear();
    _tokenCondominioController.clear();
    _instituicaoUnidadeController.clear();
    _tokenUnidadeController.clear();
    setState(() {
      _estadoSelecionado = null;
    });
  }
}

class _MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove todos os caracteres não numéricos
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Converte para double e formata
    double value = double.parse(digitsOnly) / 100;
    String formatted = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\u0024 ',
      decimalDigits: 2,
    ).format(value);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}