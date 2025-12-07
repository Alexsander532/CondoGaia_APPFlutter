import 'package:flutter/material.dart';
import '../models/instituicao_financeira_model.dart';

class SeletorInstituicao extends StatefulWidget {
  final InstituicaoFinanceiraModel? instituicaoSelecionada;
  final Function(InstituicaoFinanceiraModel?) onChanged;
  final List<InstituicaoFinanceiraModel> instituicoes;

  const SeletorInstituicao({
    Key? key,
    required this.instituicaoSelecionada,
    required this.onChanged,
    required this.instituicoes,
  }) : super(key: key);

  @override
  State<SeletorInstituicao> createState() => _SeletorInstituicaoState();
}

class _SeletorInstituicaoState extends State<SeletorInstituicao> {
  late List<InstituicaoFinanceiraModel> _instituicoesExibindo;

  @override
  void initState() {
    super.initState();
    _instituicoesExibindo = widget.instituicoes;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instituição Financeira:',
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
          child: DropdownButton<InstituicaoFinanceiraModel?>(
            value: widget.instituicaoSelecionada,
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: (value) {
              widget.onChanged(value);
            },
            items: [
              const DropdownMenuItem<InstituicaoFinanceiraModel?>(
                value: null,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('Selecione uma instituição'),
                ),
              ),
              ..._instituicoesExibindo.map((instituicao) {
                return DropdownMenuItem<InstituicaoFinanceiraModel?>(
                  value: instituicao,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(instituicao.nome),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        if (widget.instituicaoSelecionada != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Selecionado: ${widget.instituicaoSelecionada!.nome}',
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
