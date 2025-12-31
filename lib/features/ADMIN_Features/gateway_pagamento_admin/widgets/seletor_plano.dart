import 'package:flutter/material.dart';
import '../models/plano_assinatura_model.dart';

class SeletorPlano extends StatefulWidget {
  final PlanoAssinaturaModel? planoSelecionado;
  final Function(PlanoAssinaturaModel?) onChanged;
  final List<PlanoAssinaturaModel> planos;

  const SeletorPlano({
    Key? key,
    required this.planoSelecionado,
    required this.onChanged,
    required this.planos,
  }) : super(key: key);

  @override
  State<SeletorPlano> createState() => _SeletorPlanoState();
}

class _SeletorPlanoState extends State<SeletorPlano> {
  late List<PlanoAssinaturaModel> _planosExibindo;

  @override
  void initState() {
    super.initState();
    // Filtrar apenas planos Mensal
    _planosExibindo = widget.planos
        .where((plano) => plano.frequencia == 'Mensal')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Plano de assinatura: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<PlanoAssinaturaModel?>(
            value: widget.planoSelecionado,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (value) {
              widget.onChanged(value);
            },
            items: [
              const DropdownMenuItem<PlanoAssinaturaModel?>(
                value: null,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('Selecione um plano'),
                ),
              ),
              ..._planosExibindo.map((plano) {
                return DropdownMenuItem<PlanoAssinaturaModel?>(
                  value: plano,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('${plano.nome} - R\$ ${plano.valor.toStringAsFixed(2)}'),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        if (widget.planoSelecionado != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.planoSelecionado!.nome,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${widget.planoSelecionado!.valor.toStringAsFixed(2)} / ${widget.planoSelecionado!.frequencia}',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
