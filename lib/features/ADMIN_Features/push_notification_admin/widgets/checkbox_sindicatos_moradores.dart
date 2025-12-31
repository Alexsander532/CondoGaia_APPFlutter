import 'package:flutter/material.dart';

class CheckboxSindicosMoreadores extends StatelessWidget {
  final bool sindicosInclusos;
  final Function(bool) onSindicosChanged;
  final bool temMoradoresSelecionados;

  const CheckboxSindicosMoreadores({
    Key? key,
    required this.sindicosInclusos,
    required this.onSindicosChanged,
    this.temMoradoresSelecionados = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Checkbox Síndicos
        Expanded(
          child: Row(
            children: [
              Checkbox(
                value: sindicosInclusos,
                onChanged: (value) {
                  onSindicosChanged(value ?? false);
                },
                activeColor: Colors.blue,
              ),
              const Expanded(
                child: Text(
                  'Sindicos',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        // Checkbox Moradores
        Expanded(
          child: Row(
            children: [
              Checkbox(
                value: temMoradoresSelecionados,
                onChanged: (_) {}, // Sem ação, apenas exibição do status
                activeColor: Colors.blue,
              ),
              const Expanded(
                child: Text(
                  'Moradores',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
