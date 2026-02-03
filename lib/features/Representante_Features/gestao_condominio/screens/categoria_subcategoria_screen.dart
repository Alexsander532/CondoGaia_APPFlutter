import 'package:flutter/material.dart';

class CategoriaSubcategoriaScreen extends StatefulWidget {
  final String condominioId;

  const CategoriaSubcategoriaScreen({super.key, required this.condominioId});

  @override
  State<CategoriaSubcategoriaScreen> createState() =>
      _CategoriaSubcategoriaScreenState();
}

class _CategoriaSubcategoriaScreenState
    extends State<CategoriaSubcategoriaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  // Mock Data
  final List<String> _categorias = [
    'Despesa Colaboradores',
    'Despesa bancarias/financeira',
    'Aquisições / Imobilizados',
    'Reformas / benfeitorias',
    'Serviços terceirizados',
    'Impostos',
    'Honorários profissionais / Pró-Labore',
    'Despesas com consumo/ concessionárias',
    'Serviços de manutenção e conservação',
    'Materiais p/ manutenção e conservação',
    'Despesas administrativas/eventuais',
  ];

  final List<Map<String, String>> _subcategorias = [
    {'nome': '13º salário', 'categoria': 'Despesa Colaboradores'},
    {'nome': 'Acordos trabalhistas', 'categoria': 'Despesa Colaboradores'},
    {'nome': 'Adiantamento férias', 'categoria': 'Despesa Colaboradores'},
    {'nome': 'Adiantamento salarial', 'categoria': 'Despesa Colaboradores'},
    {'nome': 'Auxílio Custo-Alimentação', 'categoria': 'Despesa Colaboradores'},
    {
      'nome': 'Auxílio Custo-Transporte/Combustível',
      'categoria': 'Despesa Colaboradores',
    },
    {'nome': 'Contribuições Sindicais', 'categoria': 'Despesa Colaboradores'},
    {
      'nome': 'Convênios para Funcionários',
      'categoria': 'Despesa Colaboradores',
    },
    {
      'nome': 'Empréstimos para Funcionários',
      'categoria': 'Despesa Colaboradores',
    },
    {
      'nome': 'Equipamentos de proteção individual (EPI)',
      'categoria': 'Despesa Colaboradores',
    },
    {'nome': 'Férias', 'categoria': 'Despesa Colaboradores'},
    {'nome': 'Gratificações', 'categoria': 'Despesa Colaboradores'},
    {'nome': 'Horas extras', 'categoria': 'Despesa Colaboradores'},
    {
      'nome': 'Medicina ocupacional PCMSO',
      'categoria': 'Despesa Colaboradores',
    },
    {'nome': 'Provisões 13º / Férias', 'categoria': 'Despesa Colaboradores'},
    {'nome': 'Rescisões', 'categoria': 'Despesa Colaboradores'},
    {'nome': 'Salários', 'categoria': 'Despesa Colaboradores'},
    {'nome': 'Seguros de funcionários', 'categoria': 'Despesa Colaboradores'},
    {
      'nome': 'Substituições de funcionários',
      'categoria': 'Despesa Colaboradores',
    },
    {'nome': 'Uniformes', 'categoria': 'Despesa Colaboradores'},
    {'nome': 'FGTS-Folha de Pagamento', 'categoria': 'Despesa Colaboradores'},
    {'nome': 'INSS- Folha de pagamento', 'categoria': 'Despesa Colaboradores'},
    {'nome': 'IRRF - Folha de pagamento', 'categoria': 'Despesa Colaboradores'},
    {'nome': 'PIS- Folha de pagamento', 'categoria': 'Despesa Colaboradores'},
  ];

  String? _selectedCategoriaForSubcategoria;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCategoriaForSubcategoria = _categorias.first;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog({bool isSubcategoria = false}) {
    final controller = TextEditingController();
    String? selectedCategoria = _categorias.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSubcategoria ? 'Nova Subcategoria' : 'Nova Categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSubcategoria)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  value: selectedCategoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoria Pai',
                    border: OutlineInputBorder(),
                  ),
                  items: _categorias.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) => selectedCategoria = val,
                ),
              ),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: isSubcategoria
                    ? 'Nome da Subcategoria'
                    : 'Nome da Categoria',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  if (isSubcategoria) {
                    _subcategorias.add({
                      'nome': controller.text,
                      'categoria': selectedCategoria!,
                    });
                  } else {
                    _categorias.add(controller.text);
                  }
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3B66),
            ),
            child: const Text(
              'Adicionar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Image.asset('assets/images/logo_CondoGaia.png', height: 30),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Home/Gestão/Categoria-sub',
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              Container(color: Colors.grey.shade300, height: 1.0),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0D3B66),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF0D3B66),
              tabs: const [
                Tab(text: 'Categoria'),
                Tab(text: 'Subcategoria'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildCategoriaTab(), _buildSubcategoriaTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaTab() {
    return Column(
      children: [
        // Add Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: InkWell(
            onTap: () => _showAddDialog(isSubcategoria: false),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3B66),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Adicionar Nova',
                  style: TextStyle(
                    color: Color(0xFF0D3B66),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categorias.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildListItem(
                _categorias[index],
                onEdit: () {},
                onDelete: () {
                  setState(() => _categorias.removeAt(index));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubcategoriaTab() {
    final filtered = _subcategorias
        .where((s) => s['categoria'] == _selectedCategoriaForSubcategoria)
        .toList();

    return Column(
      children: [
        // Category Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecione a Categoria',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategoriaForSubcategoria,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _categorias.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategoriaForSubcategoria = val),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Add Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: InkWell(
            onTap: () => _showAddDialog(isSubcategoria: true),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3B66),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Adicionar Nova',
                  style: TextStyle(
                    color: Color(0xFF0D3B66),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildListItem(
                filtered[index]['nome']!,
                onEdit: () {},
                onDelete: () {
                  setState(() {
                    _subcategorias.removeWhere(
                      (s) => s['nome'] == filtered[index]['nome'],
                    );
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(
    String text, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: onEdit,
            child: const Icon(Icons.edit, size: 20, color: Color(0xFF0D3B66)),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onDelete,
            child: const Icon(
              Icons.delete_outline,
              size: 20,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
