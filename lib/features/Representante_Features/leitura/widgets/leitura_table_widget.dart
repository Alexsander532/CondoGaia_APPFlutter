import 'package:flutter/material.dart';
import '../models/leitura_model.dart';
import 'package:intl/intl.dart';

class LeituraTableWidget extends StatelessWidget {
  final List<LeituraModel> leituras;
  final Function(String, bool?) onSelectionChanged;
  final void Function(LeituraModel)? onRowTap;

  const LeituraTableWidget({
    super.key,
    required this.leituras,
    required this.onSelectionChanged,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF0D3B66), // Dark Blue Header
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                // Checkbox Header spacer
                const SizedBox(width: 40),
                Expanded(flex: 2, child: _headerText('UNID/BLOCO')),
                Expanded(flex: 2, child: _headerText('LEITURA ANT')),
                Expanded(flex: 2, child: _headerText('LEITURA ATUAL')),
                Expanded(flex: 2, child: _headerText('VALOR')),
                Expanded(flex: 2, child: _headerText('DATA LEITURA')),
                Expanded(flex: 1, child: _headerText('IMAGEM')),
              ],
            ),
          ),
          // List
          if (leituras.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Nenhuma unidade encontrada.'),
            ),

          ...leituras.map((leitura) {
            final isEven = leituras.indexOf(leitura) % 2 == 0;
            return InkWell(
              onTap: onRowTap != null ? () => onRowTap!(leitura) : null,
              child: Container(
                color: isEven
                    ? Colors.blue.shade50
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Row(
                children: [
                  Checkbox(
                    value: leitura.isSelected,
                    onChanged: (val) =>
                        onSelectionChanged(leitura.unidadeId, val),
                    side: const BorderSide(color: Color(0xFF0D3B66)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${leitura.unidadeNome} / ${leitura.bloco ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF0D3B66),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      leitura.leituraAnterior.toStringAsFixed(3),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0D3B66),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      leitura.id.isEmpty
                          ? '-'
                          : leitura.leituraAtual.toStringAsFixed(
                              3,
                            ), // Only show if saved
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0D3B66),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      leitura.id.isEmpty
                          ? '-'
                          : 'R\$ ${leitura.valor.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0D3B66),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      leitura.id.isEmpty
                          ? '-'
                          : DateFormat(
                              'dd/MM/yyyy',
                            ).format(leitura.dataLeitura),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0D3B66),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child:
                        leitura.imagemUrl != null || leitura.id.isNotEmpty
                            ? const Icon(
                                Icons.image_outlined,
                                color: Color(0xFF0D3B66),
                                size: 20,
                              )
                            : const SizedBox(),
                  ),
                ],
              ),
            ),
          );
          }),
        ],
      ),
    );
  }

  Widget _headerText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
    );
  }
}
