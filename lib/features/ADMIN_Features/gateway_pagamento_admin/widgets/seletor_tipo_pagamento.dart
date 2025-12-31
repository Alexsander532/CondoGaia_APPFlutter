import 'package:flutter/material.dart';
import '../models/tipo_pagamento_model.dart';

class SeletorTipoPagamento extends StatefulWidget {
  final TipoPagamentoModel? tipoPagamentoSelecionado;
  final Function(TipoPagamentoModel?) onChanged;
  final List<TipoPagamentoModel> tiposPagamento;

  const SeletorTipoPagamento({
    Key? key,
    required this.tipoPagamentoSelecionado,
    required this.onChanged,
    required this.tiposPagamento,
  }) : super(key: key);

  @override
  State<SeletorTipoPagamento> createState() => _SeletorTipoPagamentoState();
}

class _SeletorTipoPagamentoState extends State<SeletorTipoPagamento> {
  late List<TipoPagamentoModel> _tiposExibindo;

  @override
  void initState() {
    super.initState();
    // Filtrar apenas Boleto
    _tiposExibindo = widget.tiposPagamento
        .where((tipo) => tipo.ativo && tipo.nome == 'Boleto')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Pagamento: ',
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
          child: DropdownButton<TipoPagamentoModel?>(
            value: widget.tipoPagamentoSelecionado,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (value) {
              widget.onChanged(value);
            },
            items: [
              const DropdownMenuItem<TipoPagamentoModel?>(
                value: null,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('Selecione um tipo'),
                ),
              ),
              ..._tiposExibindo.map((tipo) {
                return DropdownMenuItem<TipoPagamentoModel?>(
                  value: tipo,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(tipo.nome),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        if (widget.tipoPagamentoSelecionado != null) ...[
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
                      widget.tipoPagamentoSelecionado!.nome,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.tipoPagamentoSelecionado!.descricao,
                  style: TextStyle(fontSize: 11, color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
