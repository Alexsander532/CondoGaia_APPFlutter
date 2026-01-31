import 'package:flutter/material.dart';
import '../models/recipient_model.dart';

class RecipientTableWidget extends StatelessWidget {
  final List<RecipientModel> recipients;
  final Function(String, bool) onSelectionChanged;
  final Function(bool) onSelectAll;
  final bool isAllSelected;

  const RecipientTableWidget({
    super.key,
    required this.recipients,
    required this.onSelectionChanged,
    required this.onSelectAll,
    required this.isAllSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Table Header
        Container(
          height: 40,
          color: const Color(0xFF0D3B66), // Dark Blue
          child: Row(
            children: [
              Checkbox(
                value: isAllSelected,
                onChanged: (val) => onSelectAll(val ?? false),
                activeColor: Colors.white,
                checkColor: const Color(0xFF0D3B66),
                side: const BorderSide(color: Colors.white),
              ),
              const Expanded(
                flex: 4,
                child: Text(
                  'NOME',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Expanded(
                flex: 1,
                child: Text(
                  'T/P/I',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'UNID/BLOCO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Expanded(
                flex: 4,
                child: Text(
                  'EMAIL',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Table Body
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recipients.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, thickness: 0.5),
          itemBuilder: (context, index) {
            final recipient = recipients[index];
            return Container(
              color: index % 2 == 0 ? const Color(0xFFF0F8FF) : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: recipient.isSelected,
                    onChanged: (val) =>
                        onSelectionChanged(recipient.id, val ?? false),
                    activeColor: const Color(0xFF0D3B66),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      recipient.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D3B66),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      recipient.type,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D3B66),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      recipient.unitBlock,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0D3B66),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      recipient.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0D3B66),
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
