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

  // State local
  String? _selectedCategoriaForSubcategoriaId;
  String _searchQuery = '';

  static const _primaryColor = Color(0xFF0D3B66);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════
  // DIALOG: ADICIONAR
  // ══════════════════════════════════════════════════════

  void _showAddDialog(BuildContext context, {bool isSubcategoria = false}) {
    final controller = TextEditingController();
    final cubit = context.read<CategoriaSubcategoriaCubit>();
    final state = cubit.state;

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
                      initialValue: selectedCategoriaId,
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
                          selectedCategoriaId!,
                          controller.text,
                        );
                      }
                    } else {
                      cubit.adicionarCategoria(controller.text);
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
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

  // ══════════════════════════════════════════════════════
  // DIALOG: EDITAR
  // ══════════════════════════════════════════════════════

  void _showEditDialog(
    BuildContext context, {
    required String nomeAtual,
    required String id,
    bool isSubcategoria = false,
    String? categoriaId,
  }) {
    final controller = TextEditingController(text: nomeAtual);
    final cubit = context.read<CategoriaSubcategoriaCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isSubcategoria ? 'Editar Subcategoria' : 'Editar Categoria',
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: isSubcategoria
                ? 'Nome da Subcategoria'
                : 'Nome da Categoria',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final novoNome = controller.text.trim();
              if (novoNome.isNotEmpty && novoNome != nomeAtual) {
                if (isSubcategoria && categoriaId != null) {
                  cubit.editarSubcategoria(id, categoriaId, novoNome);
                } else {
                  cubit.editarCategoria(id, novoNome);
                }
              }
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // DIALOG: EXCLUIR COM PROTEÇÃO
  // ══════════════════════════════════════════════════════

  Future<void> _handleDeleteCategoria(
    BuildContext context,
    CategoriaFinanceira categoria,
  ) async {
    final cubit = context.read<CategoriaSubcategoriaCubit>();
    final count = await cubit.contarDespesasPorCategoria(categoria.id!);

    if (!context.mounted) return;

    if (count == 0) {
      // Sem vínculos — confirmação simples
      _showConfirmDeleteDialog(
        context,
        nome: categoria.nome,
        onConfirm: () {
          cubit.excluirCategoria(categoria.id!);
        },
      );
    } else {
      // Com vínculos — dialog de reatribuição
      _showReassignDeleteDialog(
        context,
        nome: categoria.nome,
        count: count,
        tipo: 'categoria',
        opcoes: cubit.state.categorias
            .where((c) => c.id != categoria.id)
            .toList(),
        onReassignAndDelete: (novaId) {
          cubit.reatribuirEExcluirCategoria(categoria.id!, novaId);
        },
      );
    }
  }

  Future<void> _handleDeleteSubcategoria(
    BuildContext context,
    SubcategoriaFinanceira sub,
  ) async {
    final cubit = context.read<CategoriaSubcategoriaCubit>();
    final count = await cubit.contarDespesasPorSubcategoria(sub.id!);

    if (!context.mounted) return;

    if (count == 0) {
      _showConfirmDeleteDialog(
        context,
        nome: sub.nome,
        onConfirm: () {
          cubit.excluirSubcategoria(sub.id!);
        },
      );
    } else {
      // Encontrar subcategorias da mesma categoria, excluindo a atual
      final categoriaPai = cubit.state.categorias.firstWhere(
        (c) => c.id == sub.categoriaId,
        orElse: () => CategoriaFinanceira(nome: ''),
      );
      final subcategoriasDisponiveis = categoriaPai.subcategorias
          .where((s) => s.id != sub.id)
          .toList();

      _showReassignDeleteDialog(
        context,
        nome: sub.nome,
        count: count,
        tipo: 'subcategoria',
        opcoes: subcategoriasDisponiveis,
        onReassignAndDelete: (novaId) {
          cubit.reatribuirEExcluirSubcategoria(sub.id!, novaId);
        },
      );
    }
  }

  void _showConfirmDeleteDialog(
    BuildContext context, {
    required String nome,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir "$nome"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReassignDeleteDialog(
    BuildContext context, {
    required String nome,
    required int count,
    required String tipo,
    required List<dynamic> opcoes,
    required void Function(String novaId) onReassignAndDelete,
  }) {
    String? selectedId;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Atenção — Vinculação Existente'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(text: 'A $tipo '),
                      TextSpan(
                        text: '"$nome"',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            ' possui $count despesa${count > 1 ? 's' : ''} vinculada${count > 1 ? 's' : ''}.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (opcoes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Não há outra $tipo disponível para reatribuição. Crie uma nova $tipo antes de excluir.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Text(
                    'Selecione para onde mover as despesas:',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedId,
                    decoration: InputDecoration(
                      labelText: 'Nova $tipo',
                      border: const OutlineInputBorder(),
                    ),
                    items: opcoes.map((item) {
                      final id = tipo == 'categoria'
                          ? (item as CategoriaFinanceira).id
                          : (item as SubcategoriaFinanceira).id;
                      final name = tipo == 'categoria'
                          ? (item as CategoriaFinanceira).nome
                          : (item as SubcategoriaFinanceira).nome;
                      return DropdownMenuItem(
                        value: id,
                        child: Text(name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setStateDialog(() {
                        selectedId = val;
                      });
                    },
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              if (opcoes.isNotEmpty)
                ElevatedButton(
                  onPressed: selectedId != null
                      ? () {
                          Navigator.pop(dialogContext);
                          onReassignAndDelete(selectedId!);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'Reatribuir e Excluir',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CategoriaSubcategoriaCubit(service: GestaoCondominioService())
            ..carregarCategorias(),
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
        body:
            BlocConsumer<
              CategoriaSubcategoriaCubit,
              CategoriaSubcategoriaState
            >(
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
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Pesquisar',
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : const Icon(Icons.search),
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
                        labelColor: _primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: _primaryColor,
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

  // ══════════════════════════════════════════════════════
  // TAB: CATEGORIAS
  // ══════════════════════════════════════════════════════

  Widget _buildCategoriaTab(
    BuildContext context,
    CategoriaSubcategoriaState state,
  ) {
    // Aplicar filtro de pesquisa
    final categoriasFiltradas = _searchQuery.isEmpty
        ? state.categorias
        : state.categorias
              .where((c) => c.nome.toLowerCase().contains(_searchQuery))
              .toList();

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
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Adicionar Nova',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),

        // Lista
        Expanded(
          child: categoriasFiltradas.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isNotEmpty
                        ? 'Nenhuma categoria encontrada para "$_searchQuery"'
                        : 'Nenhuma categoria cadastrada.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categoriasFiltradas.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final categoria = categoriasFiltradas[index];
                    return _buildListItem(
                      categoria.nome,
                      onEdit: () {
                        _showEditDialog(
                          context,
                          nomeAtual: categoria.nome,
                          id: categoria.id!,
                          isSubcategoria: false,
                        );
                      },
                      onDelete: () {
                        _handleDeleteCategoria(context, categoria);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  // TAB: SUBCATEGORIAS
  // ══════════════════════════════════════════════════════

  Widget _buildSubcategoriaTab(
    BuildContext context,
    CategoriaSubcategoriaState state,
  ) {
    // Seleção de categoria
    if (_selectedCategoriaForSubcategoriaId == null &&
        state.categorias.isNotEmpty) {
      _selectedCategoriaForSubcategoriaId = state.categorias.first.id;
    }

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

    List<SubcategoriaFinanceira> subcategorias = [];
    if (_selectedCategoriaForSubcategoriaId != null) {
      final selectedCat = state.categorias.firstWhere(
        (c) => c.id == _selectedCategoriaForSubcategoriaId,
        orElse: () => CategoriaFinanceira(nome: ''),
      );
      subcategorias = selectedCat.subcategorias;
    }

    // Aplicar filtro de pesquisa
    final subcategoriasFiltradas = _searchQuery.isEmpty
        ? subcategorias
        : subcategorias
              .where((s) => s.nome.toLowerCase().contains(_searchQuery))
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
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Adicionar Nova',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),

        // Lista
        Expanded(
          child: subcategoriasFiltradas.isEmpty
              ? Center(
                  child: Text(
                    _selectedCategoriaForSubcategoriaId == null
                        ? 'Selecione uma categoria'
                        : _searchQuery.isNotEmpty
                        ? 'Nenhuma subcategoria encontrada para "$_searchQuery"'
                        : 'Nenhuma subcategoria.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: subcategoriasFiltradas.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final sub = subcategoriasFiltradas[index];
                    return _buildListItem(
                      sub.nome,
                      onEdit: () {
                        _showEditDialog(
                          context,
                          nomeAtual: sub.nome,
                          id: sub.id!,
                          isSubcategoria: true,
                          categoriaId: sub.categoriaId,
                        );
                      },
                      onDelete: () {
                        _handleDeleteSubcategoria(context, sub);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  // ITEM DA LISTA
  // ══════════════════════════════════════════════════════

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
            child: const Icon(Icons.edit, size: 20, color: _primaryColor),
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
