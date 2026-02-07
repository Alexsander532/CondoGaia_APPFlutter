import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/condominio.dart';
import '../cubit/conta_bancaria_cubit.dart';
import '../cubit/conta_bancaria_state.dart';
import '../models/conta_bancaria_model.dart';
import '../services/gestao_condominio_service.dart';

class ContaBancariaWidget extends StatelessWidget {
  final Condominio? condominio;

  const ContaBancariaWidget({super.key, required this.condominio});

  @override
  Widget build(BuildContext context) {
    if (condominio == null) return const SizedBox.shrink();

    return BlocProvider(
      create: (context) =>
          ContaBancariaCubit(service: GestaoCondominioService())
            ..carregarContas(condominio!.id),
      child: _ContaBancariaView(condominioId: condominio!.id),
    );
  }
}

class _ContaBancariaView extends StatelessWidget {
  final String condominioId;
  const _ContaBancariaView({required this.condominioId});

  void _mostrarModalEdicao(BuildContext context, {ContaBancaria? conta}) async {
    final cubit = context.read<ContaBancariaCubit>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _ContaBancariaDialog(conta: conta),
    );

    if (result != null) {
      final novaConta = ContaBancaria(
        id: conta?.id,
        condominioId: condominioId,
        nomeTitular: result['nomeTitular'],
        banco: result['banco'],
        agencia: result['agencia'],
        conta: result['conta'],
        isPrincipal: result['isPrincipal'],
      );

      cubit.adicionarOuEditarConta(novaConta);
    }
  }

  void _confirmarExclusao(BuildContext context, ContaBancaria conta) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: Text(
          'Tem certeza que deseja excluir a conta "${conta.nomeTitular}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ContaBancariaCubit>().excluirConta(
                conta.id!,
                conta.condominioId,
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContaBancariaCubit, ContaBancariaState>(
      listener: (context, state) {
        if (state.status == ContaBancariaStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == ContaBancariaStatus.loading &&
            state.contas.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Contas Cadastradas",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0D3B66),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _mostrarModalEdicao(context),
                    icon: const Icon(
                      Icons.add_circle,
                      color: Color(0xFF0D3B66),
                      size: 32,
                    ),
                    tooltip: 'Adicionar nova conta',
                  ),
                ],
              ),
            ),

            if (state.contas.isEmpty)
              _buildEmptyState()
            else
              SizedBox(
                height: 200, // Altura fixa para o carrossel de cartões
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  itemCount: state.contas.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final conta = state.contas[index];
                    return _buildCreditCard(context, conta);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: Colors.black45,
          ),
          const SizedBox(height: 8),
          const Text(
            'Nenhuma conta cadastrada',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Clique no + para adicionar',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCard(BuildContext context, ContaBancaria conta) {
    // Definindo cores baseadas no status (Principal ou não)
    final Color cardColor = conta.isPrincipal
        ? const Color(0xFF0D3B66)
        : Colors.grey.shade800;
    const Color textColor = Colors.white;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardColor, cardColor.withOpacity(0.8)],
        ),
      ),
      child: Stack(
        children: [
          // Background decoration (circles)
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Bank Name + Chip/Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        conta.banco.toUpperCase(),
                        style: const TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (conta.isPrincipal)
                      const Chip(
                        label: Text(
                          'PRINCIPAL',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.amber,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Account Numbers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AGÊNCIA',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          conta.agencia,
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONTA',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          conta.conta,
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bottom Row: Holder Name + Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TITULAR',
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            conta.nomeTitular.toUpperCase(),
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons (Small, circular)
                    Row(
                      children: [
                        if (!conta.isPrincipal)
                          IconButton(
                            icon: const Icon(
                              Icons.star_border,
                              color: Colors.white70,
                            ),
                            onPressed: () => context
                                .read<ContaBancariaCubit>()
                                .definirPrincipal(conta),
                            tooltip: 'Tornar Principal',
                            visualDensity: VisualDensity.compact,
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white70),
                          onPressed: () =>
                              _mostrarModalEdicao(context, conta: conta),
                          tooltip: 'Editar',
                          visualDensity: VisualDensity.compact,
                        ),
                        if (!conta.isPrincipal)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _confirmarExclusao(context, conta),
                            tooltip: 'Excluir',
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContaBancariaDialog extends StatefulWidget {
  final ContaBancaria? conta;

  const _ContaBancariaDialog({this.conta});

  @override
  State<_ContaBancariaDialog> createState() => _ContaBancariaDialogState();
}

class _ContaBancariaDialogState extends State<_ContaBancariaDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titularController;
  late TextEditingController _bancoController;
  late TextEditingController _agenciaController;
  late TextEditingController _contaController;
  bool _isPrincipal = false;

  @override
  void initState() {
    super.initState();
    _titularController = TextEditingController(
      text: widget.conta?.nomeTitular ?? '',
    );
    _bancoController = TextEditingController(text: widget.conta?.banco ?? '');
    _agenciaController = TextEditingController(
      text: widget.conta?.agencia ?? '',
    );
    _contaController = TextEditingController(text: widget.conta?.conta ?? '');
    _isPrincipal = widget.conta?.isPrincipal ?? false;
  }

  @override
  void dispose() {
    _titularController.dispose();
    _bancoController.dispose();
    _agenciaController.dispose();
    _contaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.conta == null ? 'Nova Conta' : 'Editar Conta'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titularController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Titular (Apelido)',
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Ex: Fundo de Reserva',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bancoController,
                decoration: const InputDecoration(
                  labelText: 'Banco (Nome/Código)',
                  prefixIcon: Icon(Icons.account_balance),
                  hintText: 'Ex: 001 - Banco do Brasil',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _agenciaController,
                      decoration: const InputDecoration(labelText: 'Agência'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _contaController,
                      decoration: const InputDecoration(labelText: 'Conta'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.conta == null || !widget.conta!.isPrincipal) ...[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CheckboxListTile(
                    title: const Text('Definir como Principal?'),
                    subtitle: const Text('Essa conta aparecerá nos boletos'),
                    value: _isPrincipal,
                    activeColor: const Color(0xFF0D3B66),
                    onChanged: (val) => setState(() => _isPrincipal = val!),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ] else ...[
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Esta é a conta principal.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'nomeTitular': _titularController.text,
                'banco': _bancoController.text,
                'agencia': _agenciaController.text,
                'conta': _contaController.text,
                'isPrincipal': _isPrincipal,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D3B66),
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
