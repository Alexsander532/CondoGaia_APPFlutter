import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/acordo_cubit.dart';
import '../cubit/acordo_state.dart';
import '../models/acordo_model.dart';

class NegociarAcordoTab extends StatefulWidget {
  const NegociarAcordoTab({super.key});

  @override
  State<NegociarAcordoTab> createState() => _NegociarAcordoTabState();
}

class _NegociarAcordoTabState extends State<NegociarAcordoTab> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _vencPrimeiraParcelaController = TextEditingController();
  final _numParcelasController = TextEditingController();
  final _jurosController = TextEditingController();
  final _multaController = TextEditingController();
  final _indiceController = TextEditingController();
  final _valorAcrescimosController = TextEditingController();
  final _porcentagemAcrescimosController = TextEditingController();
  final _valorEntradaController = TextEditingController();
  final _dataEntradaController = TextEditingController();
  final _textoBoletoController = TextEditingController();

  String _tipoAcrescimoSelecionado = 'Taxa Adm. Cobrança';
  bool _outrosAcrescimosExpandido = false;
  bool _sobreJurosMulta = false;
  bool _usarPorcentagem = false;
  bool _temEntrada = false;
  bool _textoBoletoExpandido = false;
  String _layoutBoleto = 'Padrão';

  @override
  void dispose() {
    _vencPrimeiraParcelaController.dispose();
    _numParcelasController.dispose();
    _jurosController.dispose();
    _multaController.dispose();
    _indiceController.dispose();
    _valorAcrescimosController.dispose();
    _porcentagemAcrescimosController.dispose();
    _valorEntradaController.dispose();
    _dataEntradaController.dispose();
    _textoBoletoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AcordoCubit, AcordoState>(
      builder: (context, state) {
        final cubit = context.read<AcordoCubit>();
        final selecionados = cubit.acordosSelecionados;
        final totalBase = selecionados.fold<double>(
          0,
          (sum, a) => sum + a.valor,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Cabeçalho Qtnd / Total ===
              Row(
                children: [
                  Text(
                    'Qtnd.: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${selecionados.length}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Spacer(),
                  const Text(
                    'Total: ',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    'R\$',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // === Venc. 1ª Parcela ===
              TextField(
                controller: _vencPrimeiraParcelaController,
                decoration: InputDecoration(
                  labelText: 'Venc. 1ª Parcela:  __ / __ / __',
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 14),

              // === Nº de Parcelas ===
              TextField(
                controller: _numParcelasController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nº de Parcelas:',
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // === Juros | Multa | Índice ===
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Juros
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Juros: 1%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _jurosController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'R\$',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Multa
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Multa: 2%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _multaController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'R\$',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Índice
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Índice: IGPM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _indiceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'R\$',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Valor Total: R\$',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // === Outros Acréscimos ===
              InkWell(
                onTap: () => setState(
                  () =>
                      _outrosAcrescimosExpandido = !_outrosAcrescimosExpandido,
                ),
                child: Row(
                  children: [
                    Text(
                      'Outros Acréscimos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _outrosAcrescimosExpandido
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),

              if (_outrosAcrescimosExpandido) ...[
                // Dropdown
                DropdownButtonFormField<String>(
                  value: _tipoAcrescimoSelecionado,
                  isDense: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  items: ['Taxa Adm. Cobrança', 'Honorários Advocatícios']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 13)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _tipoAcrescimoSelecionado = val);
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Valor / ou / Porcentagem / Sobre Juros
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Valor (R$)
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _valorAcrescimosController,
                        enabled: !_usarPorcentagem,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Valor (R\$):',
                          labelStyle: TextStyle(fontSize: 12),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('ou', style: TextStyle(fontSize: 12)),
                    ),
                    // Porcentagem (%)
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _porcentagemAcrescimosController,
                        enabled: _usarPorcentagem,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Porcentagem (%):',
                          labelStyle: TextStyle(fontSize: 12),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Sobre Juros/Multa checkbox
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _sobreJurosMulta,
                        onChanged: (val) =>
                            setState(() => _sobreJurosMulta = val ?? false),
                        activeColor: _primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Sobre\nJuros/ Multa',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Valor Total: R\$',
                    style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // === Entrada ===
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Entrada',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _temEntrada,
                      onChanged: (val) =>
                          setState(() => _temEntrada = val ?? false),
                      activeColor: _primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _valorEntradaController,
                      enabled: _temEntrada,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Valor R\$',
                        labelStyle: TextStyle(fontSize: 12),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _dataEntradaController,
                      enabled: _temEntrada,
                      decoration: InputDecoration(
                        labelText: 'Data: _ / _ / __',
                        labelStyle: TextStyle(fontSize: 12),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              // Restante: R$
              Padding(
                padding: const EdgeInsets.only(left: 60, top: 4),
                child: Text(
                  'Restante: R\$',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // === Botão Simular ===
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: selecionados.isEmpty
                        ? null
                        : () {
                            final numParcelas =
                                int.tryParse(_numParcelasController.text) ?? 1;
                            final juros =
                                double.tryParse(_jurosController.text) ?? 1;
                            final multa =
                                double.tryParse(_multaController.text) ?? 2;
                            final indicePct =
                                double.tryParse(_indiceController.text) ?? 0;
                            final acrescimos =
                                double.tryParse(
                                  _valorAcrescimosController.text,
                                ) ??
                                0;
                            final entrada =
                                double.tryParse(_valorEntradaController.text) ??
                                0;

                            DateTime primVenc;
                            try {
                              final parts = _vencPrimeiraParcelaController.text
                                  .split('/');
                              primVenc = DateTime(
                                int.parse(parts[2]),
                                int.parse(parts[1]),
                                int.parse(parts[0]),
                              );
                            } catch (_) {
                              primVenc = DateTime.now().add(
                                const Duration(days: 30),
                              );
                            }

                            cubit.simularParcelas(
                              numParcelas: numParcelas,
                              jurosPercent: juros,
                              multaPercent: multa,
                              indicePercent: indicePct,
                              primeiroVencimento: primVenc,
                              outrosAcrescimos: acrescimos,
                              temEntrada: _temEntrada,
                              valorEntrada: entrada,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Simular',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // === Resultado Final ===
              const Text(
                'Resultado Final',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildResultTable(state.parcelas, cubit),
              const SizedBox(height: 12),

              // === Editar / Excluir / Total ===
              _buildResultActions(state.parcelas, cubit),
              const SizedBox(height: 20),

              // === Termo C.D. + Anexar foto ===
              _buildTermoAnexoRow(context),
              const SizedBox(height: 24),

              // === Texto Boleto do Acordo ===
              _buildTextoBoletoSection(),
              const SizedBox(height: 24),

              // === Layout Boleto ===
              Row(
                children: [
                  const Text(
                    'Layout Boleto:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Radio<String>(
                    value: 'Padrão',
                    groupValue: _layoutBoleto,
                    onChanged: (val) =>
                        setState(() => _layoutBoleto = val ?? 'Padrão'),
                    activeColor: _primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Text('Padrão', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 8),
                  Radio<String>(
                    value: 'Carnê',
                    groupValue: _layoutBoleto,
                    onChanged: (val) =>
                        setState(() => _layoutBoleto = val ?? 'Padrão'),
                    activeColor: _primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Text('Carnê', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),

              // === Ações: Gerar PDF / Visualizar / Email / Compartilhar ===
              Row(
                children: [
                  _actionChip('Gerar PDF', Icons.picture_as_pdf),
                  const SizedBox(width: 8),
                  _actionChip('Visualizar', Icons.visibility),
                  const SizedBox(width: 8),
                  _actionChip('Email', Icons.email),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.share, color: _primaryColor),
                    onPressed: () => _showSnack('Compartilhar — Em breve'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // === Gerar Boletos ===
              Center(
                child: SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: () => _showSnack('Gerar Boletos — Em breve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Gerar Boletos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // === Enviar para Registro / Disparar por E-Mail ===
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: false,
                      onChanged: (_) =>
                          _showSnack('Enviar para Registro — Em breve'),
                      activeColor: _primaryColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Enviar para Registro',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: false,
                      onChanged: (_) =>
                          _showSnack('Disparar por E-Mail — Em breve'),
                      activeColor: _primaryColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Disparar por E-Mail',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ======================= TABELA RESULTADO FINAL =======================
  Widget _buildResultTable(List<ParcelaAcordo> parcelas, AcordoCubit cubit) {
    return Column(
      children: [
        // Header
        Container(
          color: _primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                height: 20,
                child: Checkbox(
                  value:
                      parcelas.isNotEmpty &&
                      parcelas.every((p) => p.selecionado),
                  onChanged: (val) {
                    // toggle all
                    for (final p in parcelas) {
                      cubit.toggleSelecionarParcela(p.id!);
                    }
                  },
                  activeColor: Colors.white,
                  checkColor: _primaryColor,
                  side: const BorderSide(color: Colors.white),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              _hCell('BL/UNID'),
              _hCell('PARCELA'),
              _hCell('MÊS/ANO'),
              _hCell('DATA VENC'),
              _hCell('VALOR'),
              _hCell('JUROS'),
              _hCell('MULTA'),
              _hCell('ÍNDICE'),
              _hCell('OUT. ACRESC'),
              _hCell('TOTAL'),
            ],
          ),
        ),
        // Data rows
        ...parcelas.map((p) => _buildParcelaRow(p, cubit)),
        // Empty rows
        ...List.generate(
          (3 - parcelas.length).clamp(0, 3),
          (_) => Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 20,
                  child: Checkbox(
                    value: false,
                    onChanged: null,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _hCell(String text) {
    return Expanded(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildParcelaRow(ParcelaAcordo p, AcordoCubit cubit) {
    final dataStr =
        '${p.dataVencimento.day.toString().padLeft(2, '0')}/ ${p.dataVencimento.month.toString().padLeft(2, '0')}/${p.dataVencimento.year}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      decoration: BoxDecoration(
        color: p.selecionado
            ? _primaryColor.withOpacity(0.06)
            : Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 20,
            child: Checkbox(
              value: p.selecionado,
              onChanged: (_) => cubit.toggleSelecionarParcela(p.id!),
              activeColor: _primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          _dCell(p.blUnid, color: _primaryColor, bold: true),
          _dCell(p.parcela),
          _dCell(p.mesAno),
          _dCell(dataStr),
          _dCell('R\$${p.valor.toStringAsFixed(2)}'),
          _dCell('R\$ ${p.juros.toStringAsFixed(2)}'),
          _dCell('R\$ ${p.multa.toStringAsFixed(2)}'),
          _dCell('R\$ ${p.indice.toStringAsFixed(2)}'),
          _dCell('R\$ ${p.outrosAcrescimos.toStringAsFixed(2)}'),
          _dCell(
            'R\$ ${p.total.toStringAsFixed(2)}',
            color: _primaryColor,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _dCell(String text, {Color? color, bool bold = false}) {
    return Expanded(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          color: color ?? Colors.black87,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ======================= AÇÕES DO RESULTADO =======================
  Widget _buildResultActions(List<ParcelaAcordo> parcelas, AcordoCubit cubit) {
    final selecionadas = parcelas.where((p) => p.selecionado).toList();
    final totalSelecionado = selecionadas.fold<double>(
      0,
      (sum, p) => sum + p.total,
    );

    return Row(
      children: [
        ElevatedButton(
          onPressed: selecionadas.isEmpty
              ? null
              : () => _showSnack('Editar — Em breve'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text(
            'Editar',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: selecionadas.isEmpty
              ? null
              : () {
                  for (final p in selecionadas) {
                    cubit.excluirParcela(p.id!);
                  }
                },
          child: const Text(
            'Excluir',
            style: TextStyle(
              color: Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Total: R\$',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _primaryColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ======================= TERMO + ANEXO =======================
  Widget _buildTermoAnexoRow(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _showSnack('Termo C.D. — Em breve'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Text(
            'Termo C.D.',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: () => _showSnack('Anexar foto — Em breve'),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.image,
                        size: 28,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Anexar foto',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ======================= TEXTO BOLETO =======================
  Widget _buildTextoBoletoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () =>
              setState(() => _textoBoletoExpandido = !_textoBoletoExpandido),
          child: Row(
            children: [
              Text(
                'Texto Boleto do Acordo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _textoBoletoExpandido
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
        if (_textoBoletoExpandido) ...[
          const SizedBox(height: 8),
          // Edit icon
          Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.edit, size: 18, color: _primaryColor),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _textoBoletoController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ],
    );
  }

  // ======================= ACTION CHIPS =======================
  Widget _actionChip(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _showSnack('$label — Em breve'),
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
