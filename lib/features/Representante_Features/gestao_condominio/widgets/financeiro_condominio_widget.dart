import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/condominio.dart';
import '../cubit/configuracao_financeira_cubit.dart';
import '../cubit/configuracao_financeira_state.dart';
import '../models/configuracao_financeira_model.dart';
import '../services/gestao_condominio_service.dart';

class FinanceiroCondominioWidget extends StatefulWidget {
  final Condominio? condominio;

  const FinanceiroCondominioWidget({super.key, required this.condominio});

  @override
  State<FinanceiroCondominioWidget> createState() =>
      _FinanceiroCondominioWidgetState();
}

class _FinanceiroCondominioWidgetState
    extends State<FinanceiroCondominioWidget> {
  // Controllers
  final _jurosController = TextEditingController();
  final _multaController = TextEditingController();
  final _diaVencimentoController = TextEditingController();
  final _descontoController = TextEditingController();
  final _fundoReservaPorcentagemController = TextEditingController();
  final _fundoReservaValorController = TextEditingController();
  final _valorFixoCondominioController = TextEditingController();

  // Novos Controllers
  final _diasProtestoController = TextEditingController();
  final _diasBaixaController = TextEditingController();
  final _tokenGarantidoraController = TextEditingController();

  // State
  bool _fundoReservaPorcentagem = true; // true = %, false = R$
  int _tipoCobrancaCondominio = 1; // 0 = Rateio, 1 = Valor Fixo
  int _refDespesasReceitas = 0; // 0 = 1 mês, 1 = 2 meses

  // Novo State
  bool _usaGarantidora = false;

  // Dynamic List for Tipos
  List<Map<String, dynamic>> _tipos = [
    {'tipo': 'A', 'valor': '500,00'},
  ];

  @override
  void dispose() {
    _jurosController.dispose();
    _multaController.dispose();
    _diaVencimentoController.dispose();
    _descontoController.dispose();
    _fundoReservaPorcentagemController.dispose();
    _fundoReservaValorController.dispose();
    _valorFixoCondominioController.dispose();
    _diasProtestoController.dispose();
    _diasBaixaController.dispose();
    _tokenGarantidoraController.dispose();
    super.dispose();
  }

  void _populateFields(ConfiguracaoFinanceira config) {
    _jurosController.text = config.jurosMensal.toString();
    _multaController.text = config.multaAtraso.toString();
    _diaVencimentoController.text = config.diaVencimento.toString();
    _descontoController.text = config.descontoPadrao.toString();

    _fundoReservaPorcentagem = config.fundoReservaTipo == 'PERCENTUAL';
    if (_fundoReservaPorcentagem) {
      _fundoReservaPorcentagemController.text = config.fundoReservaValor
          .toString();
      _fundoReservaValorController.text = '';
    } else {
      _fundoReservaPorcentagemController.text = '';
      _fundoReservaValorController.text = config.fundoReservaValor.toString();
    }

    _tipoCobrancaCondominio = config.tipoCobranca == 'RATEIO' ? 0 : 1;
    if (config.valorCondominioFixo != null) {
      _valorFixoCondominioController.text = config.valorCondominioFixo
          .toString();
    }

    _refDespesasReceitas = config.mesesReferenciaDespesas == 1 ? 0 : 1;

    // Novos Campos
    if (config.diasProtesto != null)
      _diasProtestoController.text = config.diasProtesto.toString();
    if (config.diasBaixa != null)
      _diasBaixaController.text = config.diasBaixa.toString();
    _usaGarantidora = config.usaGarantidora;
    if (config.tokenGarantidora != null)
      _tokenGarantidoraController.text = config.tokenGarantidora!;

    if (config.configuracaoTiposUnidades.isNotEmpty) {
      _tipos = config.configuracaoTiposUnidades
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }

  ConfiguracaoFinanceira _collectData(String condominioId, String? existingId) {
    double? fundoVal;
    if (_fundoReservaPorcentagem) {
      fundoVal = double.tryParse(
        _fundoReservaPorcentagemController.text.replaceAll(',', '.'),
      );
    } else {
      fundoVal = double.tryParse(
        _fundoReservaValorController.text.replaceAll(',', '.'),
      );
    }

    return ConfiguracaoFinanceira(
      id: existingId,
      condominioId: condominioId,
      jurosMensal:
          double.tryParse(_jurosController.text.replaceAll(',', '.')) ?? 0,
      multaAtraso:
          double.tryParse(_multaController.text.replaceAll(',', '.')) ?? 0,
      descontoPadrao:
          double.tryParse(_descontoController.text.replaceAll(',', '.')) ?? 0,
      diaVencimento: int.tryParse(_diaVencimentoController.text) ?? 10,
      fundoReservaTipo: _fundoReservaPorcentagem ? 'PERCENTUAL' : 'FIXO',
      fundoReservaValor: fundoVal ?? 0,
      tipoCobranca: _tipoCobrancaCondominio == 0 ? 'RATEIO' : 'FIXO',
      valorCondominioFixo: double.tryParse(
        _valorFixoCondominioController.text.replaceAll(',', '.'),
      ),
      mesesReferenciaDespesas: _refDespesasReceitas == 0 ? 1 : 2,
      // Novos Campos
      diasProtesto: int.tryParse(_diasProtestoController.text),
      diasBaixa: int.tryParse(_diasBaixaController.text),
      usaGarantidora: _usaGarantidora,
      tokenGarantidora: _tokenGarantidoraController.text,
      configuracaoTiposUnidades: _tipos,
    );
  }

  // Helper widget for rounded input
  Widget _buildRoundedTextField({
    required String label,
    required TextEditingController controller,
    String? prefixText,
    double? width,
    String? suffixText,
    bool enabled = true,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: '',
                prefixText: prefixText,
                suffixText: suffixText,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: enabled ? Colors.black : Colors.grey,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0D3B66),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    ConfiguracaoFinanceiraState state,
  ) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: 36,
        child: ElevatedButton.icon(
          onPressed: state.status == ConfiguracaoFinanceiraStatus.loading
              ? null
              : () {
                  final config = _collectData(
                    widget.condominio!.id,
                    state.configuracao?.id,
                  );
                  context
                      .read<ConfiguracaoFinanceiraCubit>()
                      .salvarConfiguracao(config);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D3B66),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: state.status == ConfiguracaoFinanceiraStatus.loading
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save, size: 16, color: Colors.white),
          label: const Text(
            'Salvar',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    BuildContext context,
    ConfiguracaoFinanceiraState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0D3B66),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        _buildSaveButton(context, state),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.condominio == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocProvider(
      create: (context) =>
          ConfiguracaoFinanceiraCubit(service: GestaoCondominioService())
            ..carregarConfiguracao(widget.condominio!.id),
      child: BlocConsumer<ConfiguracaoFinanceiraCubit, ConfiguracaoFinanceiraState>(
        listener: (context, state) {
          if (state.status == ConfiguracaoFinanceiraStatus.success &&
              state.configuracao != null) {
            if (_jurosController.text.isEmpty &&
                _diasProtestoController.text.isEmpty) {
              _populateFields(state.configuracao!);
            }
          }
          if (state.status == ConfiguracaoFinanceiraStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Erro desconhecido'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.status == ConfiguracaoFinanceiraStatus.success &&
              _jurosController.text.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Seção salva com sucesso!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ConfiguracaoFinanceiraStatus.loading &&
              state.configuracao == null) {
            return const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Seção 1: Encargos (Juros/Multa/Vencimento/Desconto)
                _buildSectionHeader('Encargos e Vencimento', context, state),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoundedTextField(
                        label: 'Juros (%):',
                        controller: _jurosController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRoundedTextField(
                        label: 'Multa (%):',
                        controller: _multaController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoundedTextField(
                        label: 'Venc. Boleto (Dia):',
                        controller: _diaVencimentoController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRoundedTextField(
                        label: 'Desconto:',
                        controller: _descontoController,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Seção 2: Fundo de Reserva
                _buildSectionHeader('Tipo de Fundo Reserva', context, state),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _fundoReservaPorcentagem = true),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Text(
                                'Porcentagem: (%)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (_fundoReservaPorcentagem)
                                Expanded(
                                  child: TextField(
                                    controller:
                                        _fundoReservaPorcentagemController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _fundoReservaPorcentagem = false),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Text(
                                'Valor Fixo: R\$',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  decoration: !_fundoReservaPorcentagem
                                      ? TextDecoration.underline
                                      : null,
                                  decorationColor: const Color(0xFF0D3B66),
                                  fontWeight: !_fundoReservaPorcentagem
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (!_fundoReservaPorcentagem)
                                Expanded(
                                  child: TextField(
                                    controller: _fundoReservaValorController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Seção 3: Cobrar Condomínio
                _buildSectionHeader('Cobrar Condomínio', context, state),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Radio<int>(
                      value: 0,
                      groupValue: _tipoCobrancaCondominio,
                      activeColor: const Color(0xFF0D3B66),
                      onChanged: (val) =>
                          setState(() => _tipoCobrancaCondominio = val!),
                    ),
                    const Text('Rateio', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Radio<int>(
                      value: 1,
                      groupValue: _tipoCobrancaCondominio,
                      activeColor: const Color(0xFF0D3B66),
                      onChanged: (val) =>
                          setState(() => _tipoCobrancaCondominio = val!),
                    ),
                    const Text('Fixo', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _valorFixoCondominioController,
                          enabled: _tipoCobrancaCondominio == 1,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            prefixText: 'R\$ ',
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Seção 4: Protesto/Baixa
                _buildSectionHeader('Protesto/Baixa Boleto', context, state),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoundedTextField(
                        label: 'Protestar:',
                        controller: _diasProtestoController,
                        suffixText: 'Dias',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRoundedTextField(
                        label: 'Baixa:',
                        controller: _diasBaixaController,
                        suffixText: 'Dias',
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // Seção 5: Garantidora
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Garantidora',
                      style: TextStyle(
                        color: Color(0xFF0D3B66),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Switch(
                          value: _usaGarantidora,
                          activeColor: const Color(0xFF0D3B66),
                          onChanged: (val) =>
                              setState(() => _usaGarantidora = val),
                        ),
                        const SizedBox(width: 8),
                        _buildSaveButton(context, state),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_usaGarantidora)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Meu Token:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: TextField(
                                      controller: _tokenGarantidoraController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Token Garantidora',
                                        isDense: true,
                                      ),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              children: [
                                const Text(
                                  'Status:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.check_circle,
                                        size: 14,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Conectado',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 32),

                // Seção 6: Tipos de Unidades
                _buildSectionHeader('Tipos de Unidades', context, state),
                const SizedBox(height: 12),
                ..._tipos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tipo = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Text(
                          'Tipo:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 60,
                          height: 36,
                          child: TextFormField(
                            initialValue: tipo['tipo'],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(bottom: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (val) => tipo['tipo'] = val,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 100,
                          height: 36,
                          child: TextFormField(
                            initialValue: tipo['valor'].toString(),
                            decoration: InputDecoration(
                              prefixText: 'R\$ ',
                              contentPadding: const EdgeInsets.only(
                                bottom: 12,
                                left: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (val) => tipo['valor'] = val,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (index == 0)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _tipos.add({'tipo': '', 'valor': ''});
                              });
                            },
                            icon: const Icon(
                              Icons.add_circle,
                              color: Color(0xFF0D3B66),
                            ),
                          )
                        else
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _tipos.removeAt(index);
                              });
                            },
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(height: 32),

                // Seção 7: Ref despesas
                _buildSectionHeader('Ref. Despesas', context, state),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Radio<int>(
                      value: 0,
                      groupValue: _refDespesasReceitas,
                      onChanged: (v) =>
                          setState(() => _refDespesasReceitas = v!),
                    ),
                    const Text('Mês Anterior'),
                    const SizedBox(width: 16),
                    Radio<int>(
                      value: 1,
                      groupValue: _refDespesasReceitas,
                      onChanged: (v) =>
                          setState(() => _refDespesasReceitas = v!),
                    ),
                    const Text('2 Meses Ant.'),
                  ],
                ),

                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }
}
