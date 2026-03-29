import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cobranca_avulsa_cubit.dart';
import '../cubit/cobranca_avulsa_state.dart';

class PesquisarCobrancaTab extends StatefulWidget {
  const PesquisarCobrancaTab({super.key});

  @override
  State<PesquisarCobrancaTab> createState() => _PesquisarCobrancaTabState();
}

class _PesquisarCobrancaTabState extends State<PesquisarCobrancaTab> {
  @override
  void initState() {
    super.initState();
    // Carregar cobranças inicialmente com o filtro de data padrão (mês seguinte)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CobrancaAvulsaCubit>().carregarCobrancas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CobrancaAvulsaCubit, CobrancaAvulsaState>(
      builder: (context, state) {
        final cubit = context.read<CobrancaAvulsaCubit>();
        
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Row 1: Conta Contábil + Plus Icon
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'CONTA CONTÁBIL',
                                    labelStyle: TextStyle(fontSize: 12),
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  value: state.contaContabilPesquisaId,
                                  items: const [
          DropdownMenuItem(value: null, child: Text('Selecione')),
          DropdownMenuItem(value: 'todos', child: Text('Todos')),
          DropdownMenuItem(value: 'taxa_condominal', child: Text('Taxa Condominial')),
          DropdownMenuItem(value: 'multa_infracao', child: Text('Multa por Infração')),
          DropdownMenuItem(value: 'advertencia', child: Text('Advertência')),
          DropdownMenuItem(value: 'controle_tags', child: Text('Controle/Tags')),
          DropdownMenuItem(value: 'manutencao_servicos', child: Text('Manutenção/Serviços')),
          DropdownMenuItem(value: 'salao_festa', child: Text('Salão de Festa')),
          DropdownMenuItem(value: 'agua', child: Text('Água')),
          DropdownMenuItem(value: 'gas', child: Text('Gás')),
          DropdownMenuItem(value: 'sinistro', child: Text('Sinistro')),
        ],
                                  onChanged: (val) => cubit.atualizarContaContabilPesquisa(val),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Row 2: Search field
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Pesquisar unidade/bloco ou nome',
                              suffixIcon: Icon(Icons.search, color: Color(0xFF0D3B66)),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (val) => cubit.atualizarPesquisaUnidade(val),
                          ),
                          const SizedBox(height: 16),
                          // Row 3: Mês/Ano + Pesquisar button
                          Row(
                            children: [
                              const Text('Mês/Ano:', style: TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.chevron_left, color: Color(0xFF0D3B66)),
                                onPressed: () {
                                  int novoMes = state.mesSelecionado - 1;
                                  int novoAno = state.anoSelecionado;
                                  if (novoMes < 1) {
                                    novoMes = 12;
                                    novoAno--;
                                  }
                                  cubit.atualizarMes(novoMes);
                                  cubit.atualizarAno(novoAno);
                                },
                              ),
                              Container(
                                width: 80,
                                alignment: Alignment.center,
                                child: Text(
                                  '${state.mesSelecionado.toString().padLeft(2, '0')}/${state.anoSelecionado}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, color: Color(0xFF0D3B66)),
                                onPressed: () {
                                  int novoMes = state.mesSelecionado + 1;
                                  int novoAno = state.anoSelecionado;
                                  if (novoMes > 12) {
                                    novoMes = 1;
                                    novoAno++;
                                  }
                                  cubit.atualizarMes(novoMes);
                                  cubit.atualizarAno(novoAno);
                                },
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 40,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF0D3B66)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => cubit.carregarCobrancas(),
                                  child: const Text('Pesquisar', style: TextStyle(color: Color(0xFF0D3B66), fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Table Header
                    Container(
                      color: const Color(0xFF0D3B66),
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      child: Row(
                        children: [
                          Theme(
                            data: ThemeData(unselectedWidgetColor: Colors.white),
                            child: SizedBox(
                              width: 24,
                              child: Checkbox(
                                value: state.cobrancasCarregadas.isNotEmpty &&
                                    state.itemsSelecionados.length == state.cobrancasCarregadas.length,
                                onChanged: (val) => cubit.alternarSelecaoTodos(val ?? false),
                                activeColor: Colors.white,
                                checkColor: const Color(0xFF0D3B66),
                                side: const BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const _TableHeaderCell('NOME', flex: 3),
                          const _TableHeaderCell('BL/UND', flex: 2),
                          const _TableHeaderCell('DATA VENC', flex: 2),
                          const _TableHeaderCell('VALOR', flex: 2),
                          const _TableHeaderCell('STATUS', flex: 2),
                        ],
                      ),
                    ),
                    _buildList(state, cubit),
                  ],
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: state.itemsSelecionados.isEmpty ? Colors.grey : Colors.red),
                    ),
                    onPressed: state.itemsSelecionados.isEmpty ? null : () => cubit.excluirSelecionados(),
                    child: Text('Excluir', style: TextStyle(color: state.itemsSelecionados.isEmpty ? Colors.grey : Colors.red)),
                  ),
                  const Spacer(),
                  const Text('Qtidade:', style: TextStyle(color: Color(0xFF0D3B66), fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(width: 4),
                  Text('${state.cobrancasCarregadas.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(width: 12),
                  const Text('Total ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(
                    'R\$ ${state.valorTotalCarregadas.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(CobrancaAvulsaState state, CobrancaAvulsaCubit cubit) {
    if (state.status == CobrancaAvulsaStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.cobrancasCarregadas.isEmpty) {
      return const Center(child: Text('Nenhuma cobrança encontrada.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.cobrancasCarregadas.length,
      itemBuilder: (context, index) {
        final cobranca = state.cobrancasCarregadas[index];
        final isEven = index % 2 == 0;
        final isSelected = state.itemsSelecionados.contains(cobranca.id);
        
        return Container(
          decoration: BoxDecoration(
            color: isEven ? Colors.white : const Color(0xFFF5F9FF),
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            children: [
               SizedBox(
                 width: 24,
                 child: Checkbox(
                   value: isSelected,
                   onChanged: (val) {
                     if (cobranca.id != null) cubit.alternarSelecaoItem(cobranca.id!);
                   },
                   activeColor: const Color(0xFF0D3B66),
                 ),
               ),
               const SizedBox(width: 8),
               Expanded(flex: 3, child: Text(cobranca.moradorId ?? cobranca.descricao ?? 'N/A', style: const TextStyle(fontSize: 10))),
               Expanded(flex: 2, child: Text(cobranca.unidadeId ?? 'N/A', style: const TextStyle(fontSize: 10))),
               Expanded(flex: 2, child: Text(cobranca.dataVencimento?.toIso8601String().split('T')[0] ?? 'N/A', style: const TextStyle(fontSize: 10))),
               Expanded(flex: 2, child: Text(r'R$ ' + cobranca.valor.toStringAsFixed(2), style: const TextStyle(fontSize: 10, color: Color(0xFF0D3B66), fontWeight: FontWeight.bold))),
               const SizedBox(width: 4),
               Expanded(
                 flex: 2, 
                 child: Row(
                   children: [
                     Expanded(
                       child: Text(
                         cobranca.status, 
                         style: const TextStyle(fontSize: 10, color: Colors.blue),
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                     if (cobranca.status != 'Pago' && cobranca.id != null)
                       IconButton(
                         icon: const Icon(Icons.sync, size: 14, color: Color(0xFF0D3B66)),
                         padding: EdgeInsets.zero,
                         constraints: const BoxConstraints(),
                         onPressed: () => cubit.sincronizarStatus(cobranca.id!),
                         tooltip: 'Sincronizar com ASAAS',
                       ),
                   ],
                 ),
               ),
            ],
          ),
        );
      },
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  const _TableHeaderCell(this.text, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
