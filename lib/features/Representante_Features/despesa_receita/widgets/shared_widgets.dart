import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../cubit/despesa_receita_cubit.dart';
import '../cubit/despesa_receita_state.dart';
import '../../../../../utils/input_formatters.dart';

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
  final hasItems = items.isNotEmpty;
  final effectiveItems = hasItems
      ? items
      : [
          const DropdownMenuItem<String>(
            value: '',
            child: Text(
              'Nenhuma opção...',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ];

  final validValue = hasItems
      ? (items.any((item) => item.value == value) ? value : null)
      : '';

  return DropdownButtonFormField<String>(
    value: validValue,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: hasItems ? null : Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    isExpanded: true,
    icon: Icon(Icons.keyboard_arrow_down, color: hasItems ? null : Colors.grey),
    items: effectiveItems,
    onChanged: hasItems ? onChanged : null,
  );
}

// ============================================================
// FIELD DE DATA COM DATE PICKER
// ============================================================

Widget buildDateField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required ValueChanged<DateTime?> onChanged,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: [DateInputFormatter()],
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.calendar_today, size: 20),
      suffixIcon: IconButton(
        icon: const Icon(Icons.event, size: 20),
        onPressed: () async {
          // Parse current text to DateTime for initialDate
          DateTime initialDate = DateTime.now();
          if (controller.text.length == 10) {
            try {
              final parts = controller.text.split('/');
              initialDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            } catch (_) {}
          }

          final picked = await showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: firstDate ?? DateTime(2000),
            lastDate: lastDate ?? DateTime(2100),
            locale: const Locale('pt', 'BR'),
          );
          if (picked != null) {
            controller.text =
                '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
            onChanged(picked);
          }
        },
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      isDense: true,
      hintText: 'DD/MM/AAAA',
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    style: const TextStyle(fontSize: 14),
    onChanged: (text) {
      if (text.length == 10) {
        try {
          final parts = text.split('/');
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);

          // Basic validation
          if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
            final date = DateTime(year, month, day);
            onChanged(date);
          }
        } catch (_) {
          onChanged(null);
        }
      } else if (text.isEmpty) {
        onChanged(null);
      }
    },
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
// ============================================================
// VISUALIZADOR DE IMAGEM FULL SCREEN
// ============================================================

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? tag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    this.tag,
  });

  static void show(BuildContext context, String imageUrl, {String? tag}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(imageUrl: imageUrl, tag: tag),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Hero(
          tag: tag ?? imageUrl,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: Colors.white54),
                      SizedBox(height: 16),
                      Text(
                        'Erro ao carregar imagem',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
