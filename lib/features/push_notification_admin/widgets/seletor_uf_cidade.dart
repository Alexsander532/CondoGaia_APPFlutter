import 'package:flutter/material.dart';
import '../models/localizacao_model.dart';
import '../services/push_notification_service.dart';

class SeletorUfCidade extends StatefulWidget {
  final EstadoModel? estadoSelecionado;
  final CidadeModel? cidadeSelecionada;
  final Function(EstadoModel?) onEstadoChanged;
  final Function(CidadeModel?) onCidadeChanged;

  const SeletorUfCidade({
    Key? key,
    required this.estadoSelecionado,
    required this.cidadeSelecionada,
    required this.onEstadoChanged,
    required this.onCidadeChanged,
  }) : super(key: key);

  @override
  State<SeletorUfCidade> createState() => _SeletorUfCidadeState();
}

class _SeletorUfCidadeState extends State<SeletorUfCidade> {
  final _service = PushNotificationService();
  List<EstadoModel> _estados = [];
  List<CidadeModel> _cidades = [];
  bool _carregandoCidades = false;

  @override
  void initState() {
    super.initState();
    _carregarEstados();
  }

  Future<void> _carregarEstados() async {
    try {
      final estados = await _service.obterEstados();
      setState(() => _estados = estados);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar estados: $e')),
        );
      }
    }
  }

  Future<void> _carregarCidades(String estadoSigla) async {
    setState(() => _carregandoCidades = true);
    widget.onCidadeChanged(null); // Reseta a cidade selecionada
    try {
      final cidades = await _service.obterCidadesPorEstado(estadoSigla);
      setState(() => _cidades = cidades);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar cidades: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregandoCidades = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Seletor de UF
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UF',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<EstadoModel>(
                value: widget.estadoSelecionado,
                items: _estados
                    .map((estado) => DropdownMenuItem(
                          value: estado,
                          child: Text(estado.nome),
                        ))
                    .toList(),
                onChanged: (estado) {
                  widget.onEstadoChanged(estado);
                  if (estado != null) {
                    _carregarCidades(estado.sigla);
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  isDense: true,
                ),
                isExpanded: true,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Seletor de Cidade
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cidade :',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CidadeModel>(
                value: widget.cidadeSelecionada,
                items: _cidades
                    .map((cidade) => DropdownMenuItem(
                          value: cidade,
                          child: Text(cidade.nome),
                        ))
                    .toList(),
                onChanged: widget.estadoSelecionado == null
                    ? null
                    : (cidade) {
                        widget.onCidadeChanged(cidade);
                      },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  isDense: true,
                  hintText: _carregandoCidades ? 'Carregando...' : 'Selecione',
                ),
                isExpanded: true,
                disabledHint: const Text('Selecione um estado'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
