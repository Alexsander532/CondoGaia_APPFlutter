import 'package:flutter/material.dart';
import '../models/ambiente_model.dart';

class SeletorAmbiente extends StatefulWidget {
  final AmbienteModel? ambienteSelecionado;
  final Function(AmbienteModel?) onChanged;
  final List<AmbienteModel> ambientes;

  const SeletorAmbiente({
    Key? key,
    required this.ambienteSelecionado,
    required this.onChanged,
    required this.ambientes,
  }) : super(key: key);

  @override
  State<SeletorAmbiente> createState() => _SeletorAmbienteState();
}

class _SeletorAmbienteState extends State<SeletorAmbiente> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Ambiente',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<AmbienteModel?>(
            value: widget.ambienteSelecionado,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: widget.onChanged,
            items: [
              const DropdownMenuItem<AmbienteModel?>(
                value: null,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('Selecione um ambiente'),
                ),
              ),
              ...widget.ambientes.map((ambiente) {
                return DropdownMenuItem<AmbienteModel?>(
                  value: ambiente,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('${ambiente.nome} (Capacidade: ${ambiente.capacidadeMaxima})'),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        if (widget.ambienteSelecionado != null) ...[
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
                      widget.ambienteSelecionado!.nome,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.ambienteSelecionado!.descricao,
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
