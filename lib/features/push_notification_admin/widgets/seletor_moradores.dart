import 'package:flutter/material.dart';
import '../models/morador_model.dart';
import '../services/push_notification_service.dart';

class SeletorMoradores extends StatefulWidget {
  final List<MoradorModel> moradoresSelecionados;
  final Function(List<MoradorModel>) onChanged;

  const SeletorMoradores({
    Key? key,
    required this.moradoresSelecionados,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SeletorMoradores> createState() => _SeletorMoradoresState();
}

class _SeletorMoradoresState extends State<SeletorMoradores> {
  final _service = PushNotificationService();
  List<MoradorModel> _todosOsMoradores = [];
  List<MoradorModel> _moradoresExibindo = [];
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _carregarMoradores();
  }

  Future<void> _carregarMoradores() async {
    setState(() => _carregando = true);
    try {
      final moradores = await _service.obterMoradores();
      setState(() {
        _todosOsMoradores = moradores;
        _moradoresExibindo = moradores;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar moradores: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  void _buscar(String termo) {
    setState(() {
      if (termo.isEmpty) {
        _moradoresExibindo = _todosOsMoradores;
      } else {
        _moradoresExibindo = _todosOsMoradores
            .where((morador) =>
                morador.nome.toLowerCase().contains(termo.toLowerCase()) ||
                morador.unidade.contains(termo) ||
                morador.bloco.toLowerCase().contains(termo.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleMorador(MoradorModel morador) {
    final novaLista = List<MoradorModel>.from(widget.moradoresSelecionados);
    
    if (novaLista.any((m) => m.id == morador.id)) {
      novaLista.removeWhere((m) => m.id == morador.id);
    } else {
      novaLista.add(morador);
    }
    
    widget.onChanged(novaLista);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: _buscar,
              decoration: InputDecoration(
                hintText: 'Pesquisar',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
            ),
          ),
          // Divider
          Divider(height: 1, color: Colors.grey[300]),
          // Lista de moradores
          if (_carregando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_moradoresExibindo.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nenhum morador encontrado',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _moradoresExibindo.length,
                itemBuilder: (context, index) {
                  final morador = _moradoresExibindo[index];
                  final estaSelected = widget.moradoresSelecionados
                      .any((m) => m.id == morador.id);

                  return CheckboxListTile(
                    value: estaSelected,
                    onChanged: (_) => _toggleMorador(morador),
                    title: Text(morador.nome),
                    subtitle: Text('Unidade ${morador.unidade}/${morador.bloco}'),
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  );
                },
              ),
            ),
          // Resumo de seleção
          if (widget.moradoresSelecionados.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.moradoresSelecionados.length} morador(es) selecionado(s)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onChanged([]);
                    },
                    child: const Text(
                      'Limpar',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
