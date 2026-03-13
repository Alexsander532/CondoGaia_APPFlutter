import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/condominio.dart';
import '../models/configuracao_financeira_model.dart';
import '../services/gestao_condominio_service.dart';
import '../cubit/configuracao_financeira_cubit.dart';
import '../cubit/configuracao_financeira_state.dart';

class GarantidoraCondominioWidget extends StatefulWidget {
  final Condominio? condominio;

  const GarantidoraCondominioWidget({super.key, this.condominio});

  @override
  State<GarantidoraCondominioWidget> createState() =>
      _GarantidoraCondominioWidgetState();
}

class _GarantidoraCondominioWidgetState
    extends State<GarantidoraCondominioWidget> {
  final _tokenGarantidoraController = TextEditingController();
  bool _usaGarantidora = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _tokenGarantidoraController.dispose();
    super.dispose();
  }

  void _populateFields(ConfiguracaoFinanceiraStatus status, var config) {
    if (config != null && !_isInitialized) {
      _tokenGarantidoraController.text = config.tokenGarantidora ?? '';
      _usaGarantidora = config.usaGarantidora;
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.only(bottom: 2),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.configuracao?.tokenGarantidora != null &&
                  state.configuracao!.tokenGarantidora!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Meu Token: ${state.configuracao!.tokenGarantidora}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildInput(
                      'Token Garantidora:',
                      _tokenGarantidoraController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: Text('Status:', style: TextStyle(fontSize: 13)),
                        ),
                        Row(
                          children: [
                            ScaleTransition(
                              scale: const AlwaysStoppedAnimation(0.8),
                              child: Switch(
                                value: _usaGarantidora,
                                onChanged: (val) =>
                                    setState(() => _usaGarantidora = val),
                                activeThumbColor: const Color(0xFFC6925F),
                                activeTrackColor: const Color(0xFFC6925F).withOpacity(0.5),
                              ),
                            ),
                            Text(
                              _usaGarantidora ? 'Conectado' : 'Desconectado',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
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
                            tokenGarantidora: _tokenGarantidoraController.text,
                            usaGarantidora: _usaGarantidora,
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
