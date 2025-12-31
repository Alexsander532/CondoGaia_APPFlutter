import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/reserva_cubit.dart';
import '../cubit/reserva_state.dart';
import '../services/reserva_service.dart';
import '../widgets/seletor_ambiente.dart';
import '../widgets/campo_descricao.dart';
import '../widgets/botao_criar_reserva.dart';

class ReservaScreen extends StatefulWidget {
  final String condominioId;
  final String usuarioId;

  const ReservaScreen({
    Key? key,
    required this.condominioId,
    required this.usuarioId,
  }) : super(key: key);

  @override
  State<ReservaScreen> createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  final TextEditingController _descricaoController = TextEditingController();
  late ReservaCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ReservaCubit(ReservaService());
    _cubit.carregarReservas(widget.condominioId);
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _criarReserva() async {
    FocusScope.of(context).unfocus();
    _cubit.criarReserva(
      condominioId: widget.condominioId,
      usuarioId: widget.usuarioId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocListener<ReservaCubit, ReservaState>(
        listener: (context, state) {
          if (state is ReservaCriada) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensagem),
                backgroundColor: Colors.green,
              ),
            );
            _descricaoController.clear();
          } else if (state is ReservaErro) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensagem),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<ReservaCubit, ReservaState>(
          builder: (context, state) {
            final cubit = context.read<ReservaCubit>();
            final isLoading = state is ReservaLoading;
            final formularioValido = state is ReservaFormularioAtualizado
                ? state.formularioValido
                : false;

            if (state is ReservaLoading && cubit.reservas.isEmpty) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Reservas'),
                backgroundColor: Colors.blue[900],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção de Criação de Reserva
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Criar Nova Reserva',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SeletorAmbiente(
                              ambienteSelecionado: cubit.ambienteSelecionado,
                              onChanged: (ambiente) {
                                cubit.atualizarAmbienteSelecionado(ambiente);
                              },
                              ambientes: cubit.ambientes,
                            ),
                            const SizedBox(height: 20),
                            CampoDescricao(
                              controller: _descricaoController,
                              onChanged: (value) {
                                cubit.atualizarDescricao(value);
                              },
                            ),
                            const SizedBox(height: 20),
                            // Seletor de Data de Início
                            _buildDateSelector(
                              context,
                              'Data de Início *',
                              cubit.dataInicio,
                              (data) {
                                cubit.atualizarDataInicio(data);
                              },
                            ),
                            const SizedBox(height: 20),
                            // Seletor de Data de Fim
                            _buildDateSelector(
                              context,
                              'Data de Fim *',
                              cubit.dataFim,
                              (data) {
                                cubit.atualizarDataFim(data);
                              },
                            ),
                            const SizedBox(height: 24),
                            BotaoCriarReserva(
                              onPressed: isLoading ? null : _criarReserva,
                              carregando: isLoading,
                              formularioValido: formularioValido,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Lista de Reservas
                    const Text(
                      'Minhas Reservas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (cubit.reservas.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Nenhuma reserva criada'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cubit.reservas.length,
                        itemBuilder: (context, index) {
                          final reserva = cubit.reservas[index];
                          return Card(
                            child: ListTile(
                              title: Text(reserva.descricao),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Início: ${reserva.dataInicio.toString().split('.')[0]}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Fim: ${reserva.dataFim.toString().split('.')[0]}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Status: ${reserva.status}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: reserva.status == 'confirmed'
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  cubit.cancelarReserva(reserva.id);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime? dataAtual,
    Function(DateTime?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final data = await showDatePicker(
              context: context,
              initialDate: dataAtual ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
            );
            if (data != null) {
              onChanged(data);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dataAtual != null
                      ? '${dataAtual.day}/${dataAtual.month}/${dataAtual.year}'
                      : 'Selecione uma data',
                  style: TextStyle(
                    color: dataAtual != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
