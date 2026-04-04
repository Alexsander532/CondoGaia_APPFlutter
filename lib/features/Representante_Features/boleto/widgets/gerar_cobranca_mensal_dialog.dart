import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/boleto_cubit.dart';
import '../cubit/boleto_state.dart';
import 'selecionar_bloco_unid_dialog.dart';
import '../../gestao_condominio/screens/gestao_condominio_screen.dart';

class GerarCobrancaMensalDialog extends StatefulWidget {
  const GerarCobrancaMensalDialog({super.key});

  @override
  State<GerarCobrancaMensalDialog> createState() =>
      _GerarCobrancaMensalDialogState();
}

class _GerarCobrancaMensalDialogState extends State<GerarCobrancaMensalDialog> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _dataController = TextEditingController();
  final _cotaCondominialController = TextEditingController();
  final _fundoReservaController = TextEditingController();
  final _multaInfracaoController = TextEditingController();
  final _controleController = TextEditingController();
  final _rateioAguaController = TextEditingController();
  final _descontoController = TextEditingController();

  bool _enviarRegistro = false;
  bool _enviarEmail = false;
  List<String> _unidadesSelecionadas = [];
  bool _isInitialized = false;

  void _updateDesconto(BoletoState state) {
    if (state.configuracaoFinanceira == null) return;
    final config = state.configuracaoFinanceira!;
    
    // Se não houver desconto padrão, limpa o campo
    if (config.descontoPadrao <= 0) {
      _descontoController.text = '0,00';
      return;
    }

    // Calcula o número de unidades
    // Se _unidadesSelecionadas estiver vazia, considera TODAS as unidades do condomínio (que estão no state.unidades)
    final int qtdUnidades = _unidadesSelecionadas.isEmpty 
        ? state.unidades.length 
        : _unidadesSelecionadas.length;

    final double totalDesconto = config.descontoPadrao * qtdUnidades;
    
    _descontoController.text = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
    ).format(totalDesconto);
  }

  void _initializeValues(BoletoState state) {
    if (_isInitialized || state.configuracaoFinanceira == null) return;

    final config = state.configuracaoFinanceira!;
    final now = DateTime.now();

    // Data de Vencimento (Próximo mês com o dia configurado)
    int mesVencimento = now.month;
    int anoVencimento = now.year;
    if (mesVencimento == 12) {
      mesVencimento = 1;
      anoVencimento++;
    } else {
      mesVencimento++;
    }

    final diaVenc = config.diaVencimento ?? 10;
    _dataController.text =
        '${diaVenc.toString().padLeft(2, '0')}/${mesVencimento.toString().padLeft(2, '0')}/$anoVencimento';

    // Cota Condominial
    double cota = 0;
    if (config.tipoCobranca == 'FIXO') {
      cota = config.valorCondominioFixo ?? 0;
      _cotaCondominialController.text =
          NumberFormat.currency(locale: 'pt_BR', symbol: '').format(cota);
    }

    // Fundo de Reserva
    double fundoReserva = 0;
    if (config.fundoReservaTipo == 'FIXO') {
      fundoReserva = config.fundoReservaValor ?? 0;
    } else if (config.fundoReservaTipo == 'PERCENTUAL' && cota > 0) {
      fundoReserva = (cota * (config.fundoReservaValor ?? 0)) / 100;
    }
    _fundoReservaController.text =
        NumberFormat.currency(locale: 'pt_BR', symbol: '').format(fundoReserva);

    // Desconto (Total = Unitário * Qtd Unidades)
    _updateDesconto(state);

    _isInitialized = true;
  }

  @override
  void initState() {
    super.initState();
    // Carrega as unidades para garantir que o cálculo do desconto (total = unitario * unidades) funcione
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BoletoCubit>().carregarUnidades();
      }
    });
  }

  @override
  void dispose() {
    _dataController.dispose();
    _cotaCondominialController.dispose();
    _fundoReservaController.dispose();
    _multaInfracaoController.dispose();
    _controleController.dispose();
    _rateioAguaController.dispose();
    _descontoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BoletoCubit, BoletoState>(
      listener: (context, state) {
        if (state.status == BoletoStatus.success) {
          _initializeValues(state);
        }
        // Se as unidades acabaram de carregar e ainda não foram selecionadas unidades manualmente,
        // atualiza o desconto para refletir o total do condomínio.
        if (state.unidades.isNotEmpty && _unidadesSelecionadas.isEmpty) {
          _updateDesconto(state);
        }
      },
      builder: (context, state) {
        final config = state.configuracaoFinanceira;
        final hasConfig = config != null &&
            (config.tipoCobranca != 'FIXO' ||
                (config.valorCondominioFixo ?? 0) > 0);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.receipt_long, color: _primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'GERAR COBRANÇA MENSAL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 24, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (!hasConfig) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Configuração financeira pendente',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Para automatizar a geração, defina a cota e os encargos na tela de Gestão.',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GestaoCondominioScreen(
                                      condominioId: context.read<BoletoCubit>().condominioId,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.settings, size: 18),
                              label: const Text('Configurar agora'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Selecionador Bloco/Unid
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.domain, size: 18, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            Text(
                              _unidadesSelecionadas.isEmpty
                                  ? 'Todos (${state.unidades.length} unidades)'
                                  : '${_unidadesSelecionadas.length} Boletos selecionados',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => BlocProvider.value(
                                value: context.read<BoletoCubit>(),
                                child: SelecionarBlocoUnidDialog(
                                  onConfirm: (ids) {
                                    setState(() {
                                      _unidadesSelecionadas = ids;
                                      _updateDesconto(state);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              'Selecionar',
                              style: TextStyle(color: _primaryColor, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Data
                  Row(
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(
                          'Data Vencimento:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: hasConfig ? const Color(0xFFF1F5F9) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _dataController,
                            readOnly: hasConfig,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                              prefixIconConstraints: BoxConstraints(minWidth: 40, minHeight: 0),
                            ),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      if (!hasConfig) ...[
                        const SizedBox(width: 8),
                        const Text('//editável', style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
                      ]
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildCampoValor('Cota Condominial:', _cotaCondominialController, readOnly: hasConfig && config.tipoCobranca == 'FIXO'),
                  _buildCampoValor('Fundo Reserva:', _fundoReservaController, readOnly: hasConfig),
                  _buildCampoValor('Multa por Infração:', _multaInfracaoController),
                  _buildCampoValor('Controle:', _controleController),
                  _buildCampoValor('Rateio água:', _rateioAguaController),
                  _buildCampoValor('Desconto:', _descontoController, readOnly: hasConfig && config.descontoPadrao > 0),
                  const SizedBox(height: 16),

                  // Checkboxes
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            value: _enviarRegistro,
                            onChanged: (val) => setState(() => _enviarRegistro = val ?? false),
                            title: const Text('Enviar p/ Registro', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            activeColor: _primaryColor,
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            value: _enviarEmail,
                            onChanged: (val) => setState(() => _enviarEmail = val ?? false),
                            title: const Text('Enviar p/ E-Mail', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            activeColor: _primaryColor,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão Gerar Boleto
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: !hasConfig || state.isSaving ? null : () => _gerarBoleto(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state.isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text(
                              'GERAR BOLETOS',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
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

  Widget _buildCampoValor(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: readOnly ? const Color(0xFFF8FAFC) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Text('R\$', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      readOnly: readOnly,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: readOnly ? Colors.grey.shade700 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _gerarBoleto(BuildContext context) {
    final cubit = context.read<BoletoCubit>();
    cubit.gerarCobrancaMensal(
      dataVencimento: _dataController.text,
      cotaCondominial: double.tryParse(_cotaCondominialController.text.replaceAll(',', '.')) ?? 0,
      fundoReserva: double.tryParse(_fundoReservaController.text.replaceAll(',', '.')) ?? 0,
      multaInfracao: double.tryParse(_multaInfracaoController.text.replaceAll(',', '.')) ?? 0,
      controle: double.tryParse(_controleController.text.replaceAll(',', '.')) ?? 0,
      rateioAgua: double.tryParse(_rateioAguaController.text.replaceAll(',', '.')) ?? 0,
      desconto: double.tryParse(_descontoController.text.replaceAll(',', '.')) ?? 0,
      enviarParaRegistro: _enviarRegistro,
      enviarPorEmail: _enviarEmail,
      unidadeIds: _unidadesSelecionadas.isNotEmpty ? _unidadesSelecionadas : null,
    );
    Navigator.pop(context);
  }
}
