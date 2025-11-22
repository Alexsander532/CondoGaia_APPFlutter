import 'package:flutter/material.dart';
import 'package:condogaiaapp/models/cidade.dart';
import 'package:condogaiaapp/services/ibge_service.dart';

class CidadeDropdown extends StatefulWidget {
  final String label;
  final Cidade? selectedCidade;
  final String? estadoSelecionado;
  final ValueChanged<Cidade?> onChanged;
  final bool required;

  const CidadeDropdown({
    Key? key,
    required this.label,
    required this.selectedCidade,
    required this.estadoSelecionado,
    required this.onChanged,
    this.required = false,
  }) : super(key: key);

  @override
  State<CidadeDropdown> createState() => _CidadeDropdownState();
}

class _CidadeDropdownState extends State<CidadeDropdown> {
  List<Cidade> _cidades = [];
  bool _isLoading = false;
  String? _lastUF;

  @override
  void initState() {
    super.initState();
    if (widget.estadoSelecionado != null && widget.estadoSelecionado!.isNotEmpty) {
      _carregarCidades(widget.estadoSelecionado!);
    }
  }

  @override
  void didUpdateWidget(CidadeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.estadoSelecionado != widget.estadoSelecionado && 
        widget.estadoSelecionado != null && 
        widget.estadoSelecionado!.isNotEmpty) {
      _carregarCidades(widget.estadoSelecionado!);
    }
  }

  Future<void> _carregarCidades(String uf) async {
    if (_lastUF == uf && _cidades.isNotEmpty) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      final cidades = await IBGEService.buscarCidades(uf);
      setState(() {
        _cidades = cidades;
        _lastUF = uf;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _cidades = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.required)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: _isLoading
              ? Container(
                  padding: const EdgeInsets.all(12),
                  child: const Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Carregando cidades...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonFormField<Cidade>(
                  value: widget.selectedCidade,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  hint: Text(
                    widget.estadoSelecionado == null || widget.estadoSelecionado!.isEmpty
                        ? 'Selecione um estado primeiro'
                        : 'Selecione uma cidade',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  isExpanded: true,
                  items: _cidades.map((cidade) {
                    return DropdownMenuItem<Cidade>(
                      value: cidade,
                      child: Text(
                        cidade.nome,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: widget.estadoSelecionado == null || widget.estadoSelecionado!.isEmpty
                      ? null
                      : (Cidade? cidade) {
                          widget.onChanged(cidade);
                        },
                ),
        ),
        if (widget.estadoSelecionado == null || widget.estadoSelecionado!.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Selecione um estado primeiro',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
