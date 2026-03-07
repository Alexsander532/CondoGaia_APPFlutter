import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/despesa_receita_cubit.dart';
import '../cubit/despesa_receita_state.dart';
import 'shared_widgets.dart';

class BaseTabWidget<T> extends StatelessWidget {
  final String fabHeroTag;
  final IconData fabIcon;
  final bool isEditing;
  final String titleAdd;
  final String titleEdit;

  final bool filtrosExpandidos;
  final VoidCallback onToggleFiltros;
  final Widget filtrosContent;

  final bool cadastroExpandido;
  final VoidCallback onToggleCadastro;
  final Widget cadastroContent;

  final String tableName;
  final List<T> items;
  final bool isLoading;

  final Widget emptyStateIcon;
  final String emptyStateText;
  final String emptyStateSubtext;

  // Header da tabela
  final Widget tableHeader;

  // Builder das linhas da tabela
  final Widget Function(
    BuildContext context,
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
    T item,
    int index,
  )
  itemBuilder;

  // Rodape da tabela
  final Widget Function(
    BuildContext context,
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
  )
  tableFooterBuilder;

  // Ação de pressionar o FAB
  final VoidCallback onFabPressed;

  const BaseTabWidget({
    super.key,
    required this.fabHeroTag,
    required this.fabIcon,
    required this.isEditing,
    required this.titleAdd,
    required this.titleEdit,
    required this.filtrosExpandidos,
    required this.onToggleFiltros,
    required this.filtrosContent,
    required this.cadastroExpandido,
    required this.onToggleCadastro,
    required this.cadastroContent,
    required this.tableName,
    required this.items,
    required this.isLoading,
    required this.emptyStateIcon,
    required this.emptyStateText,
    required this.emptyStateSubtext,
    required this.tableHeader,
    required this.itemBuilder,
    required this.tableFooterBuilder,
    required this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DespesaReceitaCubit, DespesaReceitaState>(
      builder: (context, state) {
        final cubit = context.read<DespesaReceitaCubit>();

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Seletor Mês/Ano ──
                  buildMesAnoSelector(state, cubit),
                  const SizedBox(height: 16),

                  // ── Card: Filtros ──
                  buildSectionCard(
                    icon: Icons.filter_list,
                    title: 'Filtros',
                    isExpanded: filtrosExpandidos,
                    onToggle: onToggleFiltros,
                    child: filtrosContent,
                  ),
                  const SizedBox(height: 12),

                  // ── Card: Cadastrar / Editar ──
                  buildSectionCard(
                    icon: isEditing ? Icons.edit : Icons.add_circle_outline,
                    title: isEditing ? titleEdit : titleAdd,
                    isExpanded: cadastroExpandido,
                    onToggle: onToggleCadastro,
                    accentColor: isEditing
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                    child: cadastroContent,
                  ),
                  const SizedBox(height: 16),

                  // ── Registros (Tabela) ──
                  _buildRegistrosSection(context, state, cubit),

                  const SizedBox(height: 80), // Espaço pro FAB e Resumo
                ],
              ),
            ),

            // FAB
            if (!cadastroExpandido)
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  heroTag: fabHeroTag,
                  backgroundColor: kPrimaryColor,
                  onPressed: onFabPressed,
                  child: Icon(fabIcon, color: Colors.white, size: 28),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRegistrosSection(
    BuildContext context,
    DespesaReceitaState state,
    DespesaReceitaCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.list_alt, size: 20, color: kPrimaryColor),
            const SizedBox(width: 8),
            Text(
              tableName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${items.length} registro${items.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (items.isEmpty)
          _buildEmptyState()
        else
          _buildTable(state, cubit),

        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          tableFooterBuilder(context, state, cubit),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          emptyStateIcon,
          const SizedBox(height: 12),
          Text(
            emptyStateText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            emptyStateSubtext,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(DespesaReceitaState state, DespesaReceitaCubit cubit) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            tableHeader,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, thickness: 1),
              itemBuilder: (context, index) {
                return itemBuilder(context, state, cubit, items[index], index);
              },
            ),
          ],
        ),
      ),
    );
  }
}
