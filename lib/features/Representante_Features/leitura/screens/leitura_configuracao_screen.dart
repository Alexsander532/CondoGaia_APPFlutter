import 'package:flutter/material.dart';
import '../models/leitura_configuracao_model.dart';
import '../services/leitura_service.dart';

class LeituraConfiguracaoScreen extends StatefulWidget {
  final String condominioId;
  final String? tipoInicial;

  const LeituraConfiguracaoScreen({
    super.key,
    required this.condominioId,
    this.tipoInicial,
  });

  @override
  State<LeituraConfiguracaoScreen> createState() =>
      _LeituraConfiguracaoScreenState();
}

class _LeituraConfiguracaoScreenState extends State<LeituraConfiguracaoScreen> {
  final LeituraService _service = LeituraService();

  String selectedTipo = 'Agua';
  String unidadeMedida = 'M³';

  List<String> _tipos = ['Agua', 'Gas'];
  List<String> _unidadesMedida = ['M³', 'KG', 'L'];

  final _valorController = TextEditingController();

  final _faixa1FimController = TextEditingController();
  final _faixa1ValorController = TextEditingController();
  final _faixa2InicioController = TextEditingController();
  final _faixa2FimController = TextEditingController();
  final _faixa2ValorController = TextEditingController();
  final _faixa3InicioController = TextEditingController();
  final _faixa3FimController = TextEditingController();
  final _faixa3ValorController = TextEditingController();

  int cobrancaTipo = 1;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.tipoInicial != null) {
      selectedTipo = _uiTipoToDb(widget.tipoInicial!);
    }
    _loadConfig();
  }

  String _dbTipoToUi(String db) =>
      db == 'Agua' ? 'Água' : db == 'Gas' ? 'Gás' : db;

  String _uiTipoToDb(String ui) =>
      ui == 'Água' ? 'Agua' : ui == 'Gás' ? 'Gas' : ui;

  Future<void> _loadConfig() async {
    setState(() => _loading = true);
    try {
      final config = await _service.fetchConfiguracao(
        condominioId: widget.condominioId,
        tipo: selectedTipo,
      );
      final tipos = await _service.fetchTodasConfiguracoes(widget.condominioId);
      if (tipos.isNotEmpty) {
        _tipos = tipos.map((c) => c.tipo).toSet().toList();
        if (!_tipos.contains(selectedTipo)) _tipos.add(selectedTipo);
      }

      if (config != null) {
        _valorController.text = config.valorBase.toString();
        unidadeMedida = config.unidadeMedida;
        cobrancaTipo = config.cobrancaTipo;

        _faixa1FimController.clear();
        _faixa1ValorController.clear();
        _faixa2InicioController.clear();
        _faixa2FimController.clear();
        _faixa2ValorController.clear();
        _faixa3InicioController.clear();
        _faixa3FimController.clear();
        _faixa3ValorController.clear();

        if (config.faixas.isNotEmpty) {
          _faixa1FimController.text =
              config.faixas[0].fim.toString().replaceAll('.0', '');
          _faixa1ValorController.text =
              config.faixas[0].valor.toString().replaceAll('.0', '');
        }
        if (config.faixas.length > 1) {
          _faixa2InicioController.text =
              config.faixas[1].inicio.toString().replaceAll('.0', '');
          _faixa2FimController.text =
              config.faixas[1].fim.toString().replaceAll('.0', '');
          _faixa2ValorController.text =
              config.faixas[1].valor.toString().replaceAll('.0', '');
        }
        if (config.faixas.length > 2) {
          _faixa3InicioController.text =
              config.faixas[2].inicio.toString().replaceAll('.0', '');
          _faixa3FimController.text =
              config.faixas[2].fim.toString().replaceAll('.0', '');
          _faixa3ValorController.text =
              config.faixas[2].valor.toString().replaceAll('.0', '');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _gravar() async {
    final valorBase = double.tryParse(_valorController.text) ?? 0;

    final faixas = <FaixaLeitura>[];
    final f1f = double.tryParse(_faixa1FimController.text) ?? 0;
    final f1v = double.tryParse(_faixa1ValorController.text) ?? 0;
    if (f1f > 0 || f1v > 0) {
      faixas.add(FaixaLeitura(inicio: 0, fim: f1f, valor: f1v));
    }
    final f2i = double.tryParse(_faixa2InicioController.text) ?? 0;
    final f2f = double.tryParse(_faixa2FimController.text) ?? 0;
    final f2v = double.tryParse(_faixa2ValorController.text) ?? 0;
    if (f2f > f2i) {
      faixas.add(FaixaLeitura(inicio: f2i, fim: f2f, valor: f2v));
    }
    final f3i = double.tryParse(_faixa3InicioController.text) ?? 0;
    final f3f = double.tryParse(_faixa3FimController.text) ?? 0;
    final f3v = double.tryParse(_faixa3ValorController.text) ?? 0;
    if (f3f > f3i) {
      faixas.add(FaixaLeitura(inicio: f3i, fim: f3f, valor: f3v));
    }

    final config = LeituraConfiguracaoModel(
      condominioId: widget.condominioId,
      tipo: selectedTipo,
      unidadeMedida: unidadeMedida,
      valorBase: valorBase,
      faixas: faixas,
      cobrancaTipo: cobrancaTipo,
    );

    setState(() => _saving = true);
    try {
      await _service.saveConfiguracao(config);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuração gravada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gravar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _faixa1FimController.dispose();
    _faixa1ValorController.dispose();
    _faixa2InicioController.dispose();
    _faixa2FimController.dispose();
    _faixa2ValorController.dispose();
    _faixa3InicioController.dispose();
    _faixa3FimController.dispose();
    _faixa3ValorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDropdownField(
            label: 'Tipo:',
            value: selectedTipo,
            items: _tipos,
            onChanged: (val) {
              if (val != null) {
                setState(() => selectedTipo = val);
                _loadConfig();
              }
            },
            onEdit: () => _showEditModal(
              label: 'Inserir Tipo:',
              onSave: (newVal) {
                if (newVal.isNotEmpty) {
                  final db = _uiTipoToDb(newVal);
                  if (!_tipos.contains(db)) {
                    setState(() {
                      _tipos.add(db);
                      selectedTipo = db;
                    });
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          _buildDropdownField(
            label: 'Unidade de Medida:',
            value: unidadeMedida,
            items: _unidadesMedida,
            onChanged: (val) => setState(() => unidadeMedida = val ?? 'M³'),
            onEdit: () => _showEditModal(
              label: 'Inserir Medida:',
              onSave: (newVal) {
                if (newVal.isNotEmpty && !_unidadesMedida.contains(newVal)) {
                  setState(() {
                    _unidadesMedida.add(newVal);
                    unidadeMedida = newVal;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          Container(
            height: 50,
            decoration: _inputDecoration(),
            child: TextField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'Valor por 1 $unidadeMedida: ',
                prefixStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Faixa de valores',
            style: TextStyle(
              color: Color(0xFF0D3B66),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),

          _buildFaixaRow('0', _faixa1FimController, _faixa1ValorController),
          const SizedBox(height: 12),
          _buildFaixaRowWithStart(
            _faixa2InicioController,
            _faixa2FimController,
            _faixa2ValorController,
          ),
          const SizedBox(height: 12),
          _buildFaixaRowWithStart(
            _faixa3InicioController,
            _faixa3FimController,
            _faixa3ValorController,
          ),

          const SizedBox(height: 24),
          const Text(
            'Cobrar:',
            style: TextStyle(
              color: Color(0xFF0D3B66),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Radio(
                value: 1,
                groupValue: cobrancaTipo,
                onChanged: (val) => setState(() => cobrancaTipo = val!),
                activeColor: const Color(0xFF0D3B66),
              ),
              const Text(
                'Junto com a\nTaxa de Cond.',
                style: TextStyle(fontSize: 12),
              ),
              const Spacer(),
              Radio(
                value: 2,
                groupValue: cobrancaTipo,
                onChanged: (val) => setState(() => cobrancaTipo = val!),
                activeColor: const Color(0xFF0D3B66),
              ),
              const Text(
                'Avulso',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 8),
            ],
          ),

          const SizedBox(height: 32),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _gravar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B66),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Gravar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditModal({
    required String label,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      onSave(controller.text.trim());
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3B66),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'SALVAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required VoidCallback onEdit,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _inputDecoration(),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.contains(value) ? value : items.first,
                isExpanded: true,
                items: items
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t == 'Agua' ? 'Água' : t == 'Gas' ? 'Gás' : t),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          InkWell(
            onTap: onEdit,
            child: const Icon(Icons.edit, color: Color(0xFF0D3B66), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFaixaRow(
    String startVal,
    TextEditingController endCtrl,
    TextEditingController valorCtrl,
  ) {
    return Row(
      children: [
        _buildBox(startVal + ' $unidadeMedida'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'à',
            style: TextStyle(
              color: Color(0xFF0D3B66),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildInputBox(endCtrl, suffix: ' $unidadeMedida'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '=',
            style: TextStyle(
              color: Color(0xFF0D3B66),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildInputBox(valorCtrl, prefix: 'R\$ '),
      ],
    );
  }

  Widget _buildFaixaRowWithStart(
    TextEditingController startCtrl,
    TextEditingController endCtrl,
    TextEditingController valorCtrl,
  ) {
    return Row(
      children: [
        _buildInputBox(startCtrl, suffix: ' $unidadeMedida'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'à',
            style: TextStyle(
              color: Color(0xFF0D3B66),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildInputBox(endCtrl, suffix: ' $unidadeMedida'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '=',
            style: TextStyle(
              color: Color(0xFF0D3B66),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildInputBox(valorCtrl, prefix: 'R\$ '),
      ],
    );
  }

  Widget _buildBox(String text) {
    return Expanded(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInputBox(
    TextEditingController ctrl, {
    String? prefix,
    String? suffix,
  }) {
    return Expanded(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(bottom: 8),
            prefixText: prefix,
            suffixText: suffix,
            hintText: suffix != null ? '___' : null,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade400),
    );
  }
}
