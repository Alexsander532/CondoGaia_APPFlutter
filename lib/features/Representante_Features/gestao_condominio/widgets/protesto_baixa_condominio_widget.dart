import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/condominio.dart';
import '../models/configuracao_financeira_model.dart';
import '../services/gestao_condominio_service.dart';
import '../cubit/configuracao_financeira_cubit.dart';
import '../cubit/configuracao_financeira_state.dart';

class ProtestoBaixaCondominioWidget extends StatefulWidget {
  final Condominio? condominio;

  const ProtestoBaixaCondominioWidget({super.key, this.condominio});

  @override
  State<ProtestoBaixaCondominioWidget> createState() =>
      _ProtestoBaixaCondominioWidgetState();
}

class _ProtestoBaixaCondominioWidgetState
    extends State<ProtestoBaixaCondominioWidget> {
  final _protestarBoletoController = TextEditingController();
  final _diasBaixaController = TextEditingController();
  bool _isInitialized = false;

  @override
  void dispose() {
    _protestarBoletoController.dispose();
    _diasBaixaController.dispose();
    super.dispose();
  }

  void _populateFields(ConfiguracaoFinanceiraStatus status, var config) {
    if (config != null && !_isInitialized) {
      _protestarBoletoController.text = config.diasProtesto?.toString() ?? '';
      _diasBaixaController.text = config.diasBaixa?.toString() ?? '';
      _isInitialized = true;
    }
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 11),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ConfiguracaoFinanceiraCubit(service: GestaoCondominioService())
            ..carregarConfiguracao(widget.condominio?.id ?? ''),
      child: BlocConsumer<ConfiguracaoFinanceiraCubit, ConfiguracaoFinanceiraState>(
        listener: (context, state) {
          if (state.status == ConfiguracaoFinanceiraStatus.success) {
            _populateFields(state.status, state.configuracao);
          }
          if (state.status == ConfiguracaoFinanceiraStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao carregar configurações')),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<ConfiguracaoFinanceiraCubit>();

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildInput(
                            'Protestar boleto:',
                            _protestarBoletoController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Dias', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildInput(
                            'Dias para Baixa:',
                            _diasBaixaController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Dias', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: state.status == ConfiguracaoFinanceiraStatus.loading
                      ? null
                      : () {
                          if (widget.condominio?.id == null) return;
                          
                          final config = (state.configuracao ??
                                  ConfiguracaoFinanceira(
                                    condominioId: widget.condominio!.id,
                                  ))
                              .copyWith(
                            diasProtesto:
                                int.tryParse(_protestarBoletoController.text),
                            diasBaixa: int.tryParse(_diasBaixaController.text),
                          );
                          cubit.salvarConfiguracao(config);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3B66),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.status == ConfiguracaoFinanceiraStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'SALVAR ALTERAÇÕES',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
