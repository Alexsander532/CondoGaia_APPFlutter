import 'package:flutter/material.dart';
import '../cubit/despesa_receita_cubit.dart';
import '../cubit/despesa_receita_state.dart';

// ============================================================
// CORES CONSTANTES
// ============================================================

const Color kPrimaryColor = Color(0xFF0D3B66);
const Color kAccentColor = Color(0xFF1A73E8);

const List<String> kMeses = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

const List<String> kContasContabeis = ['Controle', 'Fundo Reserva', 'Obras'];

// ============================================================
// SELETOR MÊS/ANO
// ============================================================

Widget buildMesAnoSelector(
  DespesaReceitaState state,
  DespesaReceitaCubit cubit,
) {
  final mesNome = kMeses[state.mesSelecionado - 1];
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    decoration: BoxDecoration(
      color: kPrimaryColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kPrimaryColor.withOpacity(0.15)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: kPrimaryColor),
          onPressed: cubit.mesAnterior,
        ),
        const Icon(Icons.calendar_month, size: 20, color: kPrimaryColor),
        const SizedBox(width: 8),
        Text(
          '$mesNome/${state.anoSelecionado}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: kPrimaryColor,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: kPrimaryColor),
          onPressed: cubit.proximoMes,
        ),
      ],
    ),
  );
}

// ============================================================
// CARD DE SEÇÃO COM HEADER COLAPSÁVEL
// ============================================================

Widget buildSectionCard({
  required IconData icon,
  required String title,
  required bool isExpanded,
  required VoidCallback onToggle,
  required Widget child,
  Color? accentColor,
}) {
  final color = accentColor ?? kPrimaryColor;
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: isExpanded
                  ? const BorderRadius.vertical(top: Radius.circular(12))
                  : BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: color,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: child,
          ),
      ],
    ),
  );
}

// ============================================================
// DROPDOWN FIELD
// ============================================================

Widget buildDropdownField({
  required String label,
  required IconData icon,
  required String? value,
  required List<DropdownMenuItem<String>> items,
  required ValueChanged<String?> onChanged,
}) {
  final validValue = items.any((item) => item.value == value) ? value : null;
  return DropdownButtonFormField<String>(
    value: validValue,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    isExpanded: true,
    icon: const Icon(Icons.keyboard_arrow_down),
    items: items,
    onChanged: onChanged,
  );
}

// ============================================================
// FIELD DE DATA COM DATE PICKER
// ============================================================

Widget buildDateField({
  required BuildContext context,
  required String label,
  required DateTime? value,
  required ValueChanged<DateTime?> onChanged,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final dateStr = value != null
      ? '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}'
      : '';

  return GestureDetector(
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: value ?? DateTime.now(),
        firstDate: firstDate ?? DateTime(2000),
        lastDate: lastDate ?? DateTime(2100),
        locale: const Locale('pt', 'BR'),
      );
      if (picked != null) {
        onChanged(picked);
      }
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today, size: 18),
        suffixIcon: value != null
            ? GestureDetector(
                onTap: () => onChanged(null),
                child: const Icon(Icons.clear, size: 18),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      child: Text(
        dateStr.isEmpty ? ' ' : dateStr, // prevent collapsing when empty
        style: const TextStyle(fontSize: 14),
      ),
    ),
  );
}

// ============================================================
// DIALOG DE CONFIRMAÇÃO DE EXCLUSÃO
// ============================================================

Future<bool> showConfirmDeleteDialog(
  BuildContext context, {
  required int quantidade,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 26),
          SizedBox(width: 10),
          Text('Confirmar exclusão', style: TextStyle(fontSize: 16)),
        ],
      ),
      content: Text(
        quantidade == 1
            ? 'Tem certeza que deseja excluir este registro? Esta ação não pode ser desfeita.'
            : 'Tem certeza que deseja excluir $quantidade registros? Esta ação não pode ser desfeita.',
        style: const TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  return result ?? false;
}

// ============================================================
// CAMPO DE RECORRÊNCIA
// ============================================================

Widget buildRecorrenciaSection({
  required bool recorrente,
  required ValueChanged<bool> onRecorrenteChanged,
  required TextEditingController qtdMesesController,
  bool showMeAvisar = false,
  bool meAvisar = false,
  ValueChanged<bool>? onMeAvisarChanged,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.repeat, size: 18, color: kPrimaryColor),
            const SizedBox(width: 8),
            const Text(
              'Recorrente',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const Spacer(),
            Switch(
              value: recorrente,
              onChanged: onRecorrenteChanged,
              activeColor: kPrimaryColor,
            ),
          ],
        ),
        if (recorrente) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: qtdMesesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Qtd. Meses',
                    hintText: '∞ se vazio',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              if (showMeAvisar) ...[
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: meAvisar,
                      onChanged: (v) => onMeAvisarChanged?.call(v ?? false),
                      activeColor: kPrimaryColor,
                      visualDensity: VisualDensity.compact,
                    ),
                    const Text('Me Avisar', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Se não informar a qtd. de meses, será infinito (gera todo mês).',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
