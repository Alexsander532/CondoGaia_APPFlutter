import 'package:flutter/material.dart';
import '../models/bloco.dart';
import '../models/bloco_com_unidades.dart';
import '../services/unidade_service.dart';
import 'modal_criar_bloco_widget.dart';

class ModalCriarUnidadeWidget extends StatefulWidget {
  final String condominioId;
  final List<BlocoComUnidades> blocosExistentes;
  final bool temBlocos; // Flag para saber se o condomínio usa blocos

  const ModalCriarUnidadeWidget({
    super.key,
    required this.condominioId,
    required this.blocosExistentes,
    this.temBlocos = true, // Default true para compatibilidade
  });

  @override
  State<ModalCriarUnidadeWidget> createState() =>
      _ModalCriarUnidadeWidgetState();
}

class _ModalCriarUnidadeWidgetState extends State<ModalCriarUnidadeWidget> {
  final TextEditingController _numeroController = TextEditingController();
  final UnidadeService _unidadeService = UnidadeService();

  Bloco? _blocoselecionado;
  List<Bloco> _blocos = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _inicializarBlocos();
  }

  void _inicializarBlocos() {
    // Extrai blocos únicos da lista de BlocoComUnidades
    final blocos = <String, Bloco>{};
    for (var blocoComUn in widget.blocosExistentes) {
      blocos[blocoComUn.bloco.id] = blocoComUn.bloco;
    }
    _blocos = blocos.values.toList();

    // Se não há blocos, define "A" como padrão
    if (_blocos.isEmpty) {
      _blocos = [
        Bloco.novo(
          condominioId: widget.condominioId,
          nome: 'A',
          codigo: 'A',
          ordem: 0,
        ),
      ];
    }

    // Seleciona o primeiro bloco por padrão
    _blocoselecionado = _blocos.first;
  }

  @override
  void dispose() {
    _numeroController.dispose();
    super.dispose();
  }

  Future<void> _validarECriarUnidade() async {
    final numero = _numeroController.text.trim();

    // Validações
    if (numero.isEmpty) {
      setState(() {
        _errorMessage = 'Número da unidade é obrigatório';
      });
      return;
    }

    if (_blocoselecionado == null) {
      setState(() {
        _errorMessage = 'Selecione um bloco';
      });
      return;
    }

    // Validar número duplicado no bloco
    final unidadesNoBloco = widget.blocosExistentes
        .firstWhere(
          (b) => b.bloco.id == _blocoselecionado!.id,
          orElse: () => BlocoComUnidades(bloco: _blocoselecionado!, unidades: []),
        )
        .unidades;

    final jaExiste = unidadesNoBloco.any((u) => u.numero == numero);
    if (jaExiste) {
      setState(() {
        _errorMessage =
            'Já existe uma unidade com número $numero no bloco ${_blocoselecionado!.nome}';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Retornar dados para a tela anterior
      if (mounted) {
        Navigator.of(context).pop({
          'numero': numero,
          'bloco': _blocoselecionado!,
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _abrirModalCriarBloco() async {
    final novoBloco = await showDialog<Bloco>(
      context: context,
      builder: (context) => ModalCriarBlocoWidget(
        condominioId: widget.condominioId,
      ),
    );

    if (novoBloco != null && mounted) {
      setState(() {
        _blocos.add(novoBloco);
        _blocoselecionado = novoBloco;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Criar Nova Unidade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Campo de Número
            TextField(
              controller: _numeroController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Número da Unidade *',
                hintText: 'Ex: 101, 102, 201, 301...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.home),
              ),
              textInputAction: TextInputAction.next,
              inputFormatters: [
                // Permite apenas números e alguns caracteres
              ],
            ),
            const SizedBox(height: 20),

            // Dropdown Bloco - apenas se tem_blocos = true
            if (widget.temBlocos) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecione ou crie um Bloco *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Bloco>(
                    value: _blocoselecionado,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.domain),
                    ),
                    items: [
                      ..._blocos.map((bloco) {
                        return DropdownMenuItem<Bloco>(
                          value: bloco,
                          child: Text(bloco.nome),
                        );
                      }).toList(),
                      // Opção para criar novo bloco
                      DropdownMenuItem<Bloco>(
                        enabled: false,
                        child: GestureDetector(
                          onTap: _abrirModalCriarBloco,
                          child: const Row(
                            children: [
                              Icon(Icons.add, size: 20),
                              SizedBox(width: 8),
                              Text('+ Criar Novo Bloco'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: (bloco) {
                      if (bloco != null) {
                        setState(() {
                          _blocoselecionado = bloco;
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Botão para criar novo bloco (alternativa)
              TextButton.icon(
                onPressed: _isLoading ? null : _abrirModalCriarBloco,
                icon: const Icon(Icons.add),
                label: const Text('+ Criar Novo Bloco'),
              ),
            ] else ...[
              // Informativo quando sem blocos
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF4A90E2),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Color(0xFF4A90E2),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Condomínio sem blocos\nUnidade será criada sem agrupamento',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E3A59),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Mensagem de Erro (se houver)
            if (_errorMessage != null && _errorMessage!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Botões de Ação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('CANCELAR'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _validarECriarUnidade,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue.shade600,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade100,
                              ),
                            ),
                          )
                        : const Text(
                            'PRÓXIMO',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
