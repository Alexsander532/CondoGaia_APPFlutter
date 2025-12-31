import 'package:flutter/material.dart';
import '../models/condominio_model.dart';
import '../models/localizacao_model.dart';
import '../services/push_notification_service.dart';

class SeletorCondominios extends StatefulWidget {
  final List<CondominioModel> condominiosSelecionados;
  final Function(List<CondominioModel>) onChanged;
  final EstadoModel? estadoSelecionado;
  final CidadeModel? cidadeSelecionada;

  const SeletorCondominios({
    Key? key,
    required this.condominiosSelecionados,
    required this.onChanged,
    this.estadoSelecionado,
    this.cidadeSelecionada,
  }) : super(key: key);

  @override
  State<SeletorCondominios> createState() => _SeletorCondominiosState();
}

class _SeletorCondominiosState extends State<SeletorCondominios> {
  final _service = PushNotificationService();
  
  List<CondominioModel> _todosCondominios = [];
  List<CondominioModel> _condominiosExibindo = [];
  bool _carregando = false;
  String _termoBusca = '';

  @override
  void initState() {
    super.initState();
    _carregarCondominios();
  }

  @override
  void didUpdateWidget(SeletorCondominios oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Quando UF ou Cidade mudam, refiltra os condomínios
    if (oldWidget.estadoSelecionado != widget.estadoSelecionado ||
        oldWidget.cidadeSelecionada != widget.cidadeSelecionada) {
      _filtrarCondominios();
    }
  }

  Future<void> _carregarCondominios() async {
    setState(() => _carregando = true);
    try {
      // Carrega condomínios do banco de dados
      final condominios = await _service.obterCondominios();
      
      setState(() {
        _todosCondominios = condominios;
        _filtrarCondominios();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar condomínios: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  void _filtrarCondominios() {
    List<CondominioModel> filtrados = _todosCondominios;

    // Filtrar por UF
    if (widget.estadoSelecionado != null) {
      filtrados = filtrados
          .where((cond) =>
              cond.localizacao.toUpperCase().endsWith(
                  widget.estadoSelecionado!.sigla.toUpperCase()))
          .toList();
    }

    // Filtrar por Cidade
    if (widget.cidadeSelecionada != null) {
      filtrados = filtrados
          .where((cond) =>
              cond.localizacao
                  .toLowerCase()
                  .startsWith(widget.cidadeSelecionada!.nome.toLowerCase()))
          .toList();
    }

    // Filtrar por termo de busca
    if (_termoBusca.isNotEmpty) {
      filtrados = filtrados
          .where((condominio) =>
              condominio.nome
                  .toLowerCase()
                  .contains(_termoBusca.toLowerCase()) ||
              condominio.localizacao
                  .toLowerCase()
                  .contains(_termoBusca.toLowerCase()))
          .toList();
    }

    setState(() {
      _condominiosExibindo = filtrados;
    });
  }

  void _buscar(String termo) {
    setState(() {
      _termoBusca = termo;
    });
    _filtrarCondominios();
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
            ),
          ),
          // Divider
          Divider(height: 1, color: Colors.grey[300]),
          // Lista de condomínios
          if (_carregando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_condominiosExibindo.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.estadoSelecionado == null
                    ? 'Selecione um estado para ver os condomínios'
                    : 'Nenhum condomínio encontrado',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _condominiosExibindo.length,
                itemBuilder: (context, index) {
                  final condominio = _condominiosExibindo[index];
                  final isSelecionado =
                      widget.condominiosSelecionados.contains(condominio);

                  return CheckboxListTile(
                    value: isSelecionado,
                    onChanged: (value) {
                      if (value == true) {
                        widget.onChanged([
                          ...widget.condominiosSelecionados,
                          condominio
                        ]);
                      } else {
                        widget.onChanged(
                          widget.condominiosSelecionados
                              .where((c) => c.id != condominio.id)
                              .toList(),
                        );
                      }
                    },
                    title: Text(condominio.nome),
                    subtitle: Text(condominio.localizacao),
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                  );
                },
              ),
            ),
          // Resumo de seleção
          if (widget.condominiosSelecionados.isNotEmpty)
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
                    '${widget.condominiosSelecionados.length} condomínio(s) selecionado(s)',
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
