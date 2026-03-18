import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cobranca_avulsa_cubit.dart';
import '../cubit/cobranca_avulsa_state.dart';
import 'package:condogaiaapp/models/bloco_com_unidades.dart';

class CadastrarCobrancaTab extends StatefulWidget {
  const CadastrarCobrancaTab({super.key});

  @override
  State<CadastrarCobrancaTab> createState() => _CadastrarCobrancaTabState();
}

class _CadastrarCobrancaTabState extends State<CadastrarCobrancaTab> {
  final _formKey = GlobalKey<FormState>();
  
  // ============ CONTROLLERS ============
  late TextEditingController _pesquisaController;
  late TextEditingController _descricaoController;
  late TextEditingController _diaController;
  late TextEditingController _valorController;
  late TextEditingController _qtdMesesController;
  late TextEditingController _dataInicioController;
  late TextEditingController _dataFimController;

  @override
  void initState() {
    super.initState();
    _pesquisaController = TextEditingController();
    _descricaoController = TextEditingController();
    _diaController = TextEditingController();
    _valorController = TextEditingController();
    _qtdMesesController = TextEditingController();
    _dataInicioController = TextEditingController();
    _dataFimController = TextEditingController();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    _descricaoController.dispose();
    _diaController.dispose();
    _valorController.dispose();
    _qtdMesesController.dispose();
    _dataInicioController.dispose();
    _dataFimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CobrancaAvulsaCubit, CobrancaAvulsaState>(
      builder: (context, state) {
        final cubit = context.read<CobrancaAvulsaCubit>();

        // Mostrar erro quando houver
        if (state.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Fechar',
                  textColor: Colors.white,
                  onPressed: () => cubit.limparErro(),
                ),
              ),
            );
          });
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============ SEÇÃO 1: CONTA CONTÁBIL ============
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
                        value: state.contaContabilId,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Selecione')),
                          DropdownMenuItem(value: 'taxa_cond', child: Text('Taxa Condominial')),
                          DropdownMenuItem(value: 'multa_infracao', child: Text('Multa por Infração')),
                          DropdownMenuItem(value: 'advertencia', child: Text('Advertência')),
                          DropdownMenuItem(value: 'controle', child: Text('Controle/Tags')),
                          DropdownMenuItem(value: 'manutencao', child: Text('Manutenção/Serviços')),
                          DropdownMenuItem(value: 'salao', child: Text('Salão de Festa')),
                          DropdownMenuItem(value: 'agua', child: Text('Água')),
                          DropdownMenuItem(value: 'gas', child: Text('Gás')),
                          DropdownMenuItem(value: 'sinistro', child: Text('Sinistro')),
                        ],
                        onChanged: (val) => cubit.atualizarContaContabil(val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF0D3B66)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF0D3B66)),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ============ SEÇÃO 2: PESQUISA DE UNIDADE ============
                TextFormField(
                  controller: _pesquisaController,
                  decoration: const InputDecoration(
                    labelText: 'Pesquisar unidade/bloco ou nome',
                    suffixIcon: Icon(Icons.search, color: Color(0xFF0D3B66)),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (val) => cubit.atualizarPesquisaUnidade(val),
                ),
                const SizedBox(height: 8),

                if (state.loadingUnidades)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.unidadesPesquisadas.isNotEmpty)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.unidadesPesquisadas.length,
                      itemBuilder: (context, index) {
                        final bloco = state.unidadesPesquisadas[index];
                        return ExpansionTile(
                          title: Text(bloco.bloco.nome),
                          initiallyExpanded: true,
                          children: bloco.unidades.map((unidade) {
                            final isSelected = state.unidadesSelecionadas.contains(unidade.id);
                            return CheckboxListTile(
                              title: Text('Unidade ${unidade.numero}'),
                              value: isSelected,
                              activeColor: const Color(0xFF0D3B66),
                              onChanged: (val) {
                                if (unidade.id.isNotEmpty) {
                                  cubit.alternarSelecaoUnidade(unidade.id);
                                }
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),

                // ============ SEÇÃO 3: MÊS/ANO ============
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
                        context.read<CobrancaAvulsaCubit>().atualizarMes(novoMes);
                        context.read<CobrancaAvulsaCubit>().atualizarAno(novoAno);
                      },
                    ),
                    Container(
                      width: 80,
                      alignment: Alignment.center,
                      child: Text(
                        '${state.mesSelecionado.toString().padLeft(2, '0')}/${state.anoSelecionado}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        context.read<CobrancaAvulsaCubit>().atualizarMes(novoMes);
                        context.read<CobrancaAvulsaCubit>().atualizarAno(novoAno);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ============ SEÇÃO 4: DESCRIÇÃO ============
                TextFormField(
                  controller: _descricaoController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descrição:',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => cubit.atualizarDescricao(val),
                ),
                const SizedBox(height: 16),

                // ============ SEÇÃO 5: COBRAR + DIA ============
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Cobrar',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        value: state.tipoCobranca,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Selecione')),
                          DropdownMenuItem(value: 'Junto a Taxa Cond.', child: Text('Junto a Taxa Cond.')),
                          DropdownMenuItem(value: 'Boleto Avulso', child: Text('Boleto Avulso')),
                        ],
                        onChanged: (val) => cubit.atualizarTipoCobranca(val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _diaController,
                        decoration: const InputDecoration(
                          labelText: 'Dia',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          final dia = int.tryParse(val);
                          cubit.atualizarDia(dia);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ============ SEÇÃO 6: VALOR + RECORRENTE ============
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _valorController,
                        decoration: const InputDecoration(
                          labelText: r'Valor por Unid. R$',
                          labelStyle: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          final valor = double.tryParse(val.replaceAll(',', '.'));
                          cubit.atualizarValorPorUnidade(valor);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('Recorrente'),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: state.recorrente,
                      onChanged: (val) => cubit.atualizarRecorrente(val ?? false),
                    ),
                  ],
                ),

                // ============ SEÇÃO 7: CAMPOS RECORRÊNCIA (CONDICIONAL) ============
                if (state.recorrente) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _qtdMesesController,
                          decoration: const InputDecoration(
                            labelText: 'Qntd. Meses',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            final qtd = int.tryParse(val);
                            cubit.atualizarQtdMeses(qtd);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _dataInicioController,
                          decoration: const InputDecoration(
                            labelText: 'Início MM/DD',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onTap: () => _selecionarData(context, true),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _dataFimController,
                          decoration: const InputDecoration(
                            labelText: 'Fim MM/DD',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onTap: () => _selecionarData(context, false),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // ============ SEÇÃO 8: UPLOAD DE FOTO ============
                Center(
                  child: GestureDetector(
                    onTap: () => cubit.selecionarImagem(),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 40,
                            color: Color(0xFF0D3B66),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (state.imagemArquivo != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                const Text(
                                  'Foto selecionada',
                                  style: TextStyle(color: Colors.green, fontSize: 12),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => cubit.removerImagem(),
                                  child: const Text(
                                    'Remover',
                                    style: TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Text(
                            'Anexar foto',
                            style: TextStyle(color: Colors.blue, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const SizedBox(height: 24),

                // ============ SEÇÃO 9: BOTÃO DE ADICIONAR AO CARRINHO ============
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B66),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => cubit.adicionarAoCarrinho(),
                      child: Text(
                        state.unidadesSelecionadas.isEmpty
                            ? 'ADICIONAR AO CARRINHO'
                            : 'ADICIONAR (${state.unidadesSelecionadas.length}) AO CARRINHO',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selecionarData(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year, 1, 1),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
    );
    if (picked != null) {
      if (!mounted) return;
      final cubit = context.read<CobrancaAvulsaCubit>();
      final String formatted = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}";
      if (isStart) {
        _dataInicioController.text = formatted;
        cubit.atualizarDataInicio(picked);
      } else {
        _dataFimController.text = formatted;
        cubit.atualizarDataFim(picked);
      }
    }
  }
}