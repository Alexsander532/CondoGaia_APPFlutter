import 'package:flutter/material.dart';

class PesquisaCondominiosScreen extends StatefulWidget {
  const PesquisaCondominiosScreen({super.key});

  @override
  State<PesquisaCondominiosScreen> createState() => _PesquisaCondominiosScreenState();
}

class _PesquisaCondominiosScreenState extends State<PesquisaCondominiosScreen> {
  String? _ufSelecionada;
  String? _cidadeSelecionada;
  String _statusSelecionado = 'Ativos';

  final List<String> _ufs = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
    'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
    'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];

  final List<String> _cidades = [
    'São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Salvador',
    'Brasília', 'Fortaleza', 'Curitiba', 'Recife', 'Porto Alegre'
  ];

  // Dados mockados dos condomínios
  final List<Map<String, dynamic>> _condominiosMock = [
    {
      'nome': 'Cond. Palmeiras',
      'cnpj': '19.666.555/0001-66',
      'mensalidade': 300.00,
      'sindico': 'José da Silva Viana'
    },
    {
      'nome': 'Cond. Duetto',
      'cnpj': '19.666.555/0001-66',
      'mensalidade': 450.00,
      'sindico': 'Maria Santos'
    },
    {
      'nome': 'Cond. Córdoba',
      'cnpj': '19.666.555/0001-66',
      'mensalidade': 380.00,
      'sindico': 'João Oliveira'
    },
    {
      'nome': 'Cond. Arara',
      'cnpj': '19.666.555/0001-66',
      'mensalidade': 520.00,
      'sindico': 'Ana Costa'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildBreadcrumb(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFilters(),
                    const SizedBox(height: 20),
                    _buildStatusRadio(),
                    const SizedBox(height: 20),
                    _buildSearchButton(),
                    const SizedBox(height: 20),
                    _buildTotal(),
                    const SizedBox(height: 20),
                    _buildCondominiosList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
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
            'Home/Pesquisar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UF:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonFormField<String>(
                  value: _ufSelecionada,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  hint: const Text('Selecione'),
                  isExpanded: true,
                  items: _ufs.map((uf) {
                    return DropdownMenuItem(
                      value: uf,
                      child: Text(uf),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _ufSelecionada = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cidade:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonFormField<String>(
                  value: _cidadeSelecionada,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  hint: const Text('Selecione'),
                  isExpanded: true,
                  items: _cidades.map((cidade) {
                    return DropdownMenuItem(
                      value: cidade,
                      child: Text(cidade),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _cidadeSelecionada = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRadio() {
    return Row(
      children: [
        Radio<String>(
          value: 'Ativos',
          groupValue: _statusSelecionado,
          onChanged: (value) {
            setState(() {
              _statusSelecionado = value!;
            });
          },
        ),
        const Text('Ativos'),
        const SizedBox(width: 20),
        Radio<String>(
          value: 'Desativados',
          groupValue: _statusSelecionado,
          onChanged: (value) {
            setState(() {
              _statusSelecionado = value!;
            });
          },
        ),
        const Text('Desativados'),
      ],
    );
  }

  Widget _buildSearchButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () {
          // Implementar lógica de pesquisa
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesquisa realizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        icon: const Icon(Icons.search, color: Colors.white),
        label: const Text(
          'Pesquisar',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTotal() {
    double total = _condominiosMock.fold(0.0, (sum, condo) => sum + condo['mensalidade']);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Center(
        child: Text(
          'TOTAL: R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildCondominiosList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: _condominiosMock.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> condo = entry.value;
          bool isLast = index == _condominiosMock.length - 1;
          return _buildCondominioCard(condo, isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildCondominioCard(Map<String, dynamic> condominio, [bool isLast = false]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      condominio['nome'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CNPJ: ${condominio['cnpj']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[200],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                     'Mensalidade R\$ ${condominio['mensalidade'].toStringAsFixed(2).replaceAll('.', ',')}',
                   ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[200],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Cadastro Síndico(a) ${condominio['sindico']}',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}