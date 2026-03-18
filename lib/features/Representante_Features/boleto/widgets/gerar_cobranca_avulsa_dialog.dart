import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_cubit.dart';
import '../cubit/boleto_state.dart';
import 'selecionar_bloco_unid_dialog.dart';

class GerarCobrancaAvulsaDialog extends StatefulWidget {
  const GerarCobrancaAvulsaDialog({super.key});

  @override
  State<GerarCobrancaAvulsaDialog> createState() =>
      _GerarCobrancaAvulsaDialogState();
}

class _GerarCobrancaAvulsaDialogState extends State<GerarCobrancaAvulsaDialog> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _dataController = TextEditingController();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _unidadeController = TextEditingController();

  bool _enviarRegistro = false;
  bool _enviarEmail = false;
  bool _constarRelatorio = false;
  List<String> _unidadesSelecionadas = [];
  String _labelUnidades = 'Todos';

  // Lista de contas contábeis
  final List<Map<String, dynamic>> _contasContabeis = [
    {'id': 'todos', 'nome': 'Todos', 'constarRelatorio': false},
    {'id': 'taxa_condominal', 'nome': 'Taxa Condominal', 'constarRelatorio': false},
    {'id': 'multa_infracao', 'nome': 'Multa por Infração', 'constarRelatorio': true},
    {'id': 'advertencia', 'nome': 'Advertência', 'constarRelatorio': true},
    {'id': 'controle_tags', 'nome': 'Controle/ Tags', 'constarRelatorio': false},
    {'id': 'manutencao_servicos', 'nome': 'Manutenção/ Serviços', 'constarRelatorio': false},
    {'id': 'salao_festa', 'nome': 'Salão de Festa/ Churrasqueira', 'constarRelatorio': false},
    {'id': 'agua', 'nome': 'Água', 'constarRelatorio': false},
    {'id': 'gas', 'nome': 'Gás', 'constarRelatorio': false},
    {'id': 'sinistro', 'nome': 'Sinistro', 'constarRelatorio': false},
  ];

  String _contaSelecionada = 'agua';
  String _contaNome = 'Água';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dataController.text =
        '10/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  void dispose() {
    _dataController.dispose();
    _valorController.dispose();
    _descricaoController.dispose();
    _unidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoletoCubit, BoletoState>(
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'GERAR COBRANÇA AVULSA/DESP. EXTRAORD.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _primaryColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Conta Contábil
                  Row(
                    children: [
                      const Text(
                        'Conta Contábil:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _contaSelecionada,
                              isExpanded: true,
                              items: _contasContabeis.map((conta) {
                                return DropdownMenuItem<String>(
                                  value: conta['id'],
                                  child: Text(
                                    conta['nome'],
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _contaSelecionada = value!;
                                  final conta = _contasContabeis.firstWhere(
                                    (c) => c['id'] == value,
                                  );
                                  _contaNome = conta['nome'];
                                  _constarRelatorio = conta['constarRelatorio'];
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Unidades selecionadas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_labelUnidades',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => BlocProvider.value(
                              value: context.read<BoletoCubit>(),
                              child: SelecionarBlocoUnidDialog(
                                onConfirm: (ids) {
                                  setState(() {
                                    _unidadesSelecionadas = ids;
                                    _labelUnidades = ids.isEmpty
                                        ? 'Todos'
                                        : '${ids.length} Unidades';
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Unidade/Bloco/Nome',
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Mês/Ano
                  Row(
                    children: [
                      const Text(
                        'Mês/Ano:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _dataController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _unidadesSelecionadas = [];
                            _labelUnidades = 'Todos';
                            _valorController.clear();
                            _descricaoController.clear();
                          });
                        },
                        child: const Text(
                          'Pesquisar',
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Valor
                  Row(
                    children: [
                      const Text(
                        'Valor:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(r'R$', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: _valorController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            border: const UnderlineInputBorder(),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Descrição
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Descrição:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descricaoController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          hintText: 'Descrição da cobrança avulsa...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Checkbox Constar no Relatório
                  if (_constarRelatorio)
                    Row(
                      children: [
                        Checkbox(
                          value: _constarRelatorio,
                          onChanged: (val) {
                            setState(() => _constarRelatorio = val ?? false);
                          },
                          activeColor: _primaryColor,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        const Text(
                          'Constar no Relatório',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  if (_constarRelatorio) const SizedBox(height: 12),

                  // Checkboxes
                  Row(
                    children: [
                      Checkbox(
                        value: _enviarRegistro,
                        onChanged: (val) {
                          setState(() => _enviarRegistro = val ?? false);
                        },
                        activeColor: _primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text(
                        'Enviar p/ Registro',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      Checkbox(
                        value: _enviarEmail,
                        onChanged: (val) {
                          setState(() => _enviarEmail = val ?? false);
                        },
                        activeColor: _primaryColor,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text(
                        'Enviar p/ E-Mail',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botão Gerar Boleto
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isSaving
                          ? null
                          : () => _gerarBoletoAvulso(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'GERAR BOLETO AVULSO',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _gerarBoletoAvulso(BuildContext context) {
    final cubit = context.read<BoletoCubit>();
    
    final valor = double.tryParse(_valorController.text) ?? 0;
    if (valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe um valor válido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    cubit.gerarCobrancaAvulsa(
      contaContabil: _contaSelecionada,
      contaNome: _contaNome,
      dataVencimento: _dataController.text,
      valor: valor,
      descricao: _descricaoController.text.trim(),
      constarRelatorio: _constarRelatorio,
      enviarParaRegistro: _enviarRegistro,
      enviarPorEmail: _enviarEmail,
      unidadeIds: _unidadesSelecionadas.isNotEmpty
          ? _unidadesSelecionadas
          : null,
    );
    Navigator.pop(context);
  }
}
