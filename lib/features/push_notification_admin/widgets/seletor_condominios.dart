import 'package:flutter/material.dart';
import '../models/condominio_model.dart';

class SeletorCondominios extends StatefulWidget {
  final CondominioModel? condominioSelecionado;
  final Function(CondominioModel?) onChanged;

  const SeletorCondominios({
    Key? key,
    required this.condominioSelecionado,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SeletorCondominios> createState() => _SeletorCondominiosState();
}

class _SeletorCondominiosState extends State<SeletorCondominios> {
  // Dados mockados de condominios
  static final List<CondominioModel> _condominios = [
    CondominioModel(
      id: '1',
      nome: 'Cond. Arara',
      localizacao: 'Três Lagoas/MS',
    ),
    CondominioModel(
      id: '2',
      nome: 'Cond. Mansão',
      localizacao: 'São Paulo/SP',
    ),
    CondominioModel(
      id: '3',
      nome: 'Cond. Jardim',
      localizacao: 'Campinas/SP',
    ),
    CondominioModel(
      id: '4',
      nome: 'Cond. Vila Real',
      localizacao: 'Rio de Janeiro/RJ',
    ),
    CondominioModel(
      id: '5',
      nome: 'Cond. Morada do Sol',
      localizacao: 'Belo Horizonte/MG',
    ),
    CondominioModel(
      id: '6',
      nome: 'Cond. Praia Mar',
      localizacao: 'Salvador/BA',
    ),
    CondominioModel(
      id: '7',
      nome: 'Cond. Estação',
      localizacao: 'Porto Alegre/RS',
    ),
    CondominioModel(
      id: '8',
      nome: 'Cond. Luar',
      localizacao: 'Curitiba/PR',
    ),
  ];

  List<CondominioModel> _condominiosExibindo = [];
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _carregarCondominios();
  }

  Future<void> _carregarCondominios() async {
    setState(() => _carregando = true);
    try {
      // Simulando uma chamada à API com delay
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _condominiosExibindo = _condominios;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar condominios: $e')),
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
        _condominiosExibindo = _condominios;
      } else {
        _condominiosExibindo = _condominios
            .where((condominio) =>
                condominio.nome.toLowerCase().contains(termo.toLowerCase()) ||
                condominio.localizacao
                    .toLowerCase()
                    .contains(termo.toLowerCase()))
            .toList();
      }
    });
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
          // Lista de condominios
          if (_carregando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_condominiosExibindo.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Nenhum condominio encontrado',
                style: TextStyle(color: Colors.grey, fontSize: 14),
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

                  return RadioListTile<CondominioModel>(
                    value: condominio,
                    groupValue: widget.condominioSelecionado,
                    onChanged: (value) {
                      widget.onChanged(value);
                    },
                    title: Text(condominio.nome),
                    subtitle: Text(condominio.localizacao),
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  );
                },
              ),
            ),
          // Resumo de seleção
          if (widget.condominioSelecionado != null)
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
                    '${widget.condominioSelecionado!.nome} selecionado',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onChanged(null);
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
