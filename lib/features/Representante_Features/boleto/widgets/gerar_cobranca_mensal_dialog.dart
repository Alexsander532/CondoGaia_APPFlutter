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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 420),
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
                        'GERAR COBRANÇA MENSAL',
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
                  const SizedBox(height: 8),

                  if (!hasConfig) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Configuração financeira não definida ou incompleta.',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Para automatizar a geração, defina a cota e os encargos na tela de Gestão.',
                            style: TextStyle(fontSize: 12, color: Colors.black87),
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
                                      condominioId: context
                                          .read<BoletoCubit>()
                                          .condominioId,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.settings),
                              label: const Text('Configurar agora'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Boletos info + Selecionador Bloco/Unid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _unidadesSelecionadas.isEmpty
                            ? 'Todos (${state.unidades.length})'
                            : '${_unidadesSelecionadas.length} Boletos',
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
                                    _updateDesconto(state);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Bloco/Unid.',
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

                  // Data
                  Row(
                    children: [
                      const Text(
                        'Data:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _dataController,
                          readOnly: hasConfig,
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
                            filled: hasConfig,
                            fillColor: hasConfig ? Colors.grey.shade100 : null,
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '//editável',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildCampoValor(
                    'Cota Condominial:',
                    _cotaCondominialController,
                    readOnly: hasConfig && config.tipoCobranca == 'FIXO',
                  ),
                  _buildCampoValor(
                    'Fundo Reserva:',
                    _fundoReservaController,
                    readOnly: hasConfig,
                  ),
                  _buildCampoValor(
                    'Multa por Infração:',
                    _multaInfracaoController,
                  ),
                  _buildCampoValor('Controle:', _controleController),
                  _buildCampoValor('Rateio água:', _rateioAguaController),
                  _buildCampoValor(
                    'Desconto:',
                    _descontoController,
                    readOnly: hasConfig && config.descontoPadrao > 0,
                  ),
                  const SizedBox(height: 16),

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
                      onPressed: !hasConfig || state.isSaving
                          ? null
                          : () => _gerarBoleto(context),
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
                              'GERAR BOLETO',
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

  Widget _buildCampoValor(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const Text('R\$', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              readOnly: readOnly,
              decoration: InputDecoration(
                isDense: true,
                filled: readOnly,
                fillColor: readOnly ? Colors.grey.shade100 : null,
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
    );
  }

  void _gerarBoleto(BuildContext context) {
    final cubit = context.read<BoletoCubit>();
    cubit.gerarCobrancaMensal(
      dataVencimento: _dataController.text,
      cotaCondominial: double.tryParse(
              _cotaCondominialController.text.replaceAll(',', '.')) ??
          0,
      fundoReserva:
          double.tryParse(_fundoReservaController.text.replaceAll(',', '.')) ??
              0,
      multaInfracao:
          double.tryParse(_multaInfracaoController.text.replaceAll(',', '.')) ??
              0,
      controle:
          double.tryParse(_controleController.text.replaceAll(',', '.')) ?? 0,
      rateioAgua:
          double.tryParse(_rateioAguaController.text.replaceAll(',', '.')) ?? 0,
      desconto:
          double.tryParse(_descontoController.text.replaceAll(',', '.')) ?? 0,
      enviarParaRegistro: _enviarRegistro,
      enviarPorEmail: _enviarEmail,
      unidadeIds: _unidadesSelecionadas.isNotEmpty
          ? _unidadesSelecionadas
          : null,
    );
    Navigator.pop(context);
  }
}
