import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/categoria_subcategoria_cubit.dart';
import '../cubit/categoria_subcategoria_state.dart';
import '../models/categoria_financeira_model.dart';
import '../services/gestao_condominio_service.dart';

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

  // State local apenas para seleção na UI
  String? _selectedCategoriaForSubcategoriaId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog(BuildContext context, {bool isSubcategoria = false}) {
    final controller = TextEditingController();

    // Precisamos acessar o cubit e o estado atual para o dropdown
    final cubit = context.read<CategoriaSubcategoriaCubit>();
    final state = cubit.state;

    // Default selection logic
    String? selectedCategoriaId = _selectedCategoriaForSubcategoriaId;
    if (state.categorias.isNotEmpty && selectedCategoriaId == null) {
      selectedCategoriaId = state.categorias.first.id;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(
              isSubcategoria ? 'Nova Subcategoria' : 'Nova Categoria',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSubcategoria)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategoriaId,
                      decoration: const InputDecoration(
                        labelText: 'Categoria Pai',
                        border: OutlineInputBorder(),
                      ),
                      items: state.categorias.map((cat) {
                        return DropdownMenuItem(
                          value: cat.id,
                          child: Text(
                            cat.nome,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() {
                          selectedCategoriaId = val;
                        });
                      },
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
                    if (isSubcategoria) {
                      if (selectedCategoriaId != null) {
                        cubit.adicionarSubcategoria(
                          widget.condominioId,
                          selectedCategoriaId!,
                          controller.text,
                        );
                      }
                    } else {
                      cubit.adicionarCategoria(
                        widget.condominioId,
                        controller.text,
                      );
                    }
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CategoriaSubcategoriaCubit(service: GestaoCondominioService())
            ..carregarCategorias(widget.condominioId),
      child: Scaffold(
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
        body: BlocConsumer<CategoriaSubcategoriaCubit, CategoriaSubcategoriaState>(
          listener: (context, state) {
            if (state.status == CategoriaSubcategoriaStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Erro inesperado'),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == CategoriaSubcategoriaStatus.loading &&
                state.categorias.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Search Bar (Visual Only for now, filtering requires logic update)
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
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
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
                    children: [
                      _buildCategoriaTab(context, state),
                      _buildSubcategoriaTab(context, state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoriaTab(
    BuildContext context,
    CategoriaSubcategoriaState state,
  ) {
    return Column(
      children: [
        // Add Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: InkWell(
            onTap: () => _showAddDialog(context, isSubcategoria: false),
            child: Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D3B66),
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
          child: state.categorias.isEmpty
              ? const Center(child: Text('Nenhuma categoria cadastrada.'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.categorias.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final categoria = state.categorias[index];
                    return _buildListItem(
                      categoria.nome,
                      onEdit: () {
                        // TODO: Implementar edição
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edição em breve')),
                        );
                      },
                      onDelete: () {
                        context
                            .read<CategoriaSubcategoriaCubit>()
                            .excluirCategoria(
                              widget.condominioId,
                              categoria.id!,
                            );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSubcategoriaTab(
    BuildContext context,
    CategoriaSubcategoriaState state,
  ) {
    // Determine selected category logic
    if (_selectedCategoriaForSubcategoriaId == null &&
        state.categorias.isNotEmpty) {
      _selectedCategoriaForSubcategoriaId = state.categorias.first.id;
    }

    // Safety check if selected ID still exists in list, if not reset
    if (_selectedCategoriaForSubcategoriaId != null) {
      final exists = state.categorias.any(
        (c) => c.id == _selectedCategoriaForSubcategoriaId,
      );
      if (!exists && state.categorias.isNotEmpty) {
        _selectedCategoriaForSubcategoriaId = state.categorias.first.id;
      } else if (!exists) {
        _selectedCategoriaForSubcategoriaId = null;
      }
    }

    List<SubcategoriaFinanceira> subcategoriasFiltered = [];
    if (_selectedCategoriaForSubcategoriaId != null) {
      final selectedCat = state.categorias.firstWhere(
        (c) => c.id == _selectedCategoriaForSubcategoriaId,
        orElse: () => CategoriaFinanceira(condominioId: '', nome: ''), // dummy
      );
      subcategoriasFiltered = selectedCat.subcategorias;
    }

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
                    value: _selectedCategoriaForSubcategoriaId,
                    isExpanded: true,
                    hint: const Text('Selecione...'),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: state.categorias.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(
                          cat.nome,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      // precisely setState of the widget to update selection
                      // Since we are inside BlocBuilder, rebuilding is fine, but we need to trigger rebuild
                      // Actually this widget is Stateless part of the build, but logic is in state
                      // We can just rely on BlocBuilder rebuilding if we emit??
                      // No, selection is local state. We need to call setState of the StatefulWidget.
                      // But this method _buildSubcategoriaTab is outside build scope? No it's a method of State.
                      setState(() {
                        _selectedCategoriaForSubcategoriaId = val;
                      });
                    },
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
            onTap: () {
              if (state.categorias.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Crie uma categoria antes de adicionar subcategorias.',
                    ),
                  ),
                );
                return;
              }
              _showAddDialog(context, isSubcategoria: true);
            },
            child: Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D3B66),
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
          child: subcategoriasFiltered.isEmpty
              ? Center(
                  child: Text(
                    _selectedCategoriaForSubcategoriaId == null
                        ? 'Selecione uma categoria'
                        : 'Nenhuma subcategoria.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: subcategoriasFiltered.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final sub = subcategoriasFiltered[index];
                    return _buildListItem(
                      sub.nome,
                      onEdit: () {
                        // TODO
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edição em breve')),
                        );
                      },
                      onDelete: () {
                        context
                            .read<CategoriaSubcategoriaCubit>()
                            .excluirSubcategoria(widget.condominioId, sub.id!);
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
