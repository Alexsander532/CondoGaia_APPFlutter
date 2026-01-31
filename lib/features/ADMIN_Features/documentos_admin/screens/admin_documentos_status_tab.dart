import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/admin_documentos_cubit.dart';
import '../cubit/admin_documentos_state.dart';
import '../models/documento_status_model.dart';
import '../widgets/status_documento_card.dart';

class AdminDocumentosStatusTab extends StatelessWidget {
  const AdminDocumentosStatusTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDocumentosCubit, AdminDocumentosState>(
      builder: (context, state) {
        if (state is! AdminDocumentosLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final cubit = context.read<AdminDocumentosCubit>();
        final dateFormat = DateFormat('dd/MM/yyyy');

        // Logic for "Todos" checkbox state
        final bool allChecked = state.statusFilters.values.every((v) => v);
        // final bool anyChecked = state.statusFilters.values.any((v) => v);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Date Filter Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Data: ', style: TextStyle(fontSize: 16)),
                  GestureDetector(
                    onTap: () => _selectDateRange(context, cubit, state),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        state.startDate != null
                            ? dateFormat.format(state.startDate!)
                            : '01/12/2023',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('a', style: TextStyle(fontSize: 16)),
                  ),
                  GestureDetector(
                    onTap: () => _selectDateRange(context, cubit, state),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        state.endDate != null
                            ? dateFormat.format(state.endDate!)
                            : '28/12/2023',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filters Checkboxes
              // Row might overflow if filters names are long, wrapping or horizontal scroll needed.
              // Design shows single row.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterCheckbox('Todos', allChecked, (val) {
                      cubit.toggleAllFilters(val);
                    }),
                    _buildFilterCheckbox(
                      'Aprovado',
                      state.statusFilters[StatusDocumento.aprovado] ?? false,
                      (val) => cubit.toggleStatusFilter(
                        StatusDocumento.aprovado,
                        val,
                      ),
                    ),
                    _buildFilterCheckbox(
                      'Erro',
                      state.statusFilters[StatusDocumento.erro] ?? false,
                      (val) =>
                          cubit.toggleStatusFilter(StatusDocumento.erro, val),
                    ),
                    _buildFilterCheckbox(
                      'Pendente',
                      state.statusFilters[StatusDocumento.pendente] ?? false,
                      (val) => cubit.toggleStatusFilter(
                        StatusDocumento.pendente,
                        val,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // List of Status Cards
              Expanded(
                child: ListView.builder(
                  itemCount: state.statusList.length,
                  itemBuilder: (context, index) {
                    final doc = state.statusList[index];
                    return StatusDocumentoCard(
                      documento: doc,
                      onCorrigir: () {
                        // Implement logic to edit/correct
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Funcionalidade de correção em breve',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterCheckbox(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Text(label),
        const SizedBox(width: 8),
      ],
    );
  }

  Future<void> _selectDateRange(
    BuildContext context,
    AdminDocumentosCubit cubit,
    AdminDocumentosLoaded state,
  ) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: (state.startDate != null && state.endDate != null)
          ? DateTimeRange(start: state.startDate!, end: state.endDate!)
          : null,
    );

    if (picked != null) {
      cubit.updateDateRange(picked.start, picked.end);
    }
  }
}
