import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cobranca_avulsa_cubit.dart';
import '../cubit/cobranca_avulsa_state.dart';


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
  late TextEditingController _qtdMesesController;
  late TextEditingController _linkController;

  // Para valores das unidades na tabela (inline)
  final Map<String, TextEditingController> _valorControllers = {};



  @override
  void initState() {
    super.initState();
    _pesquisaController = TextEditingController();
    _descricaoController = TextEditingController();
    _diaController = TextEditingController();
    _qtdMesesController = TextEditingController();
    _linkController = TextEditingController();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    _descricaoController.dispose();
    _diaController.dispose();
    _qtdMesesController.dispose();
    _linkController.dispose();
    for (var controller in _valorControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // helper to get or create controller for unit
  TextEditingController _getValorController(String unidadeId, double? currentValor) {
    if (!_valorControllers.containsKey(unidadeId)) {
      final initialText = currentValor != null && currentValor > 0 
          ? currentValor.toStringAsFixed(2).replaceAll('.', ',') 
          : '';
      _valorControllers[unidadeId] = TextEditingController(text: initialText);
    }
    return _valorControllers[unidadeId]!;
  }

  Widget _buildStepHeader(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 0.5,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold allows fixed bottom navigation bar/footer
    return Scaffold(
      backgroundColor: Colors.transparent, // mantém o fundo da tela original
      body: BlocBuilder<CobrancaAvulsaCubit, CobrancaAvulsaState>(
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

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ============ 1 — CLASSIFICAÇÃO ============
                        _buildStepHeader('1 — CLASSIFICAÇÃO'),
                        Row(
                          children: [
                            // Conta Contabil (Flex 3)
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: state.contaContabilId,
                                    hint: const Text('Conta Contábil', style: TextStyle(fontSize: 12)),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    items: const [
                                      DropdownMenuItem(value: null, child: Text('Selecione', style: TextStyle(fontSize: 12))),
                                      DropdownMenuItem(value: 'taxa_cond', child: Text('Taxa Condominial', style: TextStyle(fontSize: 12))),
                                      DropdownMenuItem(value: 'multa_infracao', child: Text('Multa por Infração', style: TextStyle(fontSize: 12))),
                                      DropdownMenuItem(value: 'advertencia', child: Text('Advertência', style: TextStyle(fontSize: 12))),
                                      DropdownMenuItem(value: 'controle', child: Text('Controle/Tags', style: TextStyle(fontSize: 12))),
                                      DropdownMenuItem(value: 'manutencao', child: Text('Manutenção/Serviços', style: TextStyle(fontSize: 12))),
                                      DropdownMenuItem(value: 'salao', child: Text('Salão de Festa', style: TextStyle(fontSize: 12))),
                                      DropdownMenuItem(value: 'agua', child: Text('Água', style: TextStyle(fontSize: 12))),
                                      DropdownMenuItem(value: 'gas', child: Text('Gás', style: TextStyle(fontSize: 12))),
                                      DropdownMenuItem(value: 'sinistro', child: Text('Sinistro', style: TextStyle(fontSize: 12))),
                                    ],
                                    onChanged: (val) => cubit.atualizarContaContabil(val),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Mes / Ano (Flex 2)
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${state.mesSelecionado.toString().padLeft(2, '0')}/${state.anoSelecionado}',
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        // TODO: seletor de mes/ano customizado, por hora usar botoes
                                        int novoMes = state.mesSelecionado + 1;
                                        int novoAno = state.anoSelecionado;
                                        if (novoMes > 12) {
                                          novoMes = 1;
                                          novoAno++;
                                        }
                                        context.read<CobrancaAvulsaCubit>().atualizarMes(novoMes);
                                        context.read<CobrancaAvulsaCubit>().atualizarAno(novoAno);
                                      },
                                      child: const Icon(Icons.arrow_drop_down),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descricaoController,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Descrição da cobrança...',
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            isDense: true,
                          ),
                          onChanged: (val) => cubit.atualizarDescricao(val),
                        ),

                        // ============ 2 — FORMA DE COBRANÇA ============
                        _buildStepHeader('2 — FORMA DE COBRANÇA'),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => cubit.atualizarTipoCobranca('Junto a Taxa Cond.'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    color: (state.tipoCobranca == null || state.tipoCobranca == 'Junto a Taxa Cond.')
                                        ? const Color(0xFF185FA5)
                                        : Colors.white,
                                    child: Center(
                                      child: Text(
                                        'Junto à Taxa Cond.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: (state.tipoCobranca == null || state.tipoCobranca == 'Junto a Taxa Cond.')
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => cubit.atualizarTipoCobranca('Boleto Avulso'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    color: state.tipoCobranca == 'Boleto Avulso'
                                        ? const Color(0xFF185FA5)
                                        : Colors.white,
                                    child: Center(
                                      child: Text(
                                        'Boleto Avulso',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: state.tipoCobranca == 'Boleto Avulso'
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        if (state.tipoCobranca == 'Boleto Avulso') ...[
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              text: '★ Boleto Avulso: ',
                              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                              children: const [
                                TextSpan(
                                  text: 'mostra campo de dia do vencimento e botão "Gerar Boleto"',
                                  style: TextStyle(fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Dia de vencimento: ', style: TextStyle(fontSize: 12)),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  controller: _diaController,
                                  style: const TextStyle(fontSize: 13),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: '__',
                                    fillColor: Colors.white,
                                    filled: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
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
                        ],

                        const SizedBox(height: 12),
                        // Toggle Recorrente
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Recorrente', style: TextStyle(fontSize: 13, color: Color(0xFF0D3B66))),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => cubit.atualizarRecorrente(false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: !state.recorrente ? const Color(0xFF185FA5) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Não',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: !state.recorrente ? Colors.white : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () => cubit.atualizarRecorrente(true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: state.recorrente ? const Color(0xFF185FA5) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Sim',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: state.recorrente ? Colors.white : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (state.recorrente) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100, // var(--color-background-secondary)
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Início', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE6F1FB),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          state.dataInicio != null ? DateFormat('MM/yyyy').format(state.dataInicio!) : 'MM/AAAA',
                                          style: const TextStyle(color: Color(0xFF185FA5), fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Fim', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE6F1FB),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          state.dataFim != null ? DateFormat('MM/yyyy').format(state.dataFim!) : 'MM/AAAA',
                                          style: const TextStyle(color: Color(0xFF185FA5), fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Qtd. Meses', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFAEEDA),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              state.qtdMeses?.toString() ?? '0',
                                              style: const TextStyle(color: Color(0xFF854F0B), fontSize: 12, fontWeight: FontWeight.w500),
                                            ),
                                            const Text(
                                              ' meses',
                                              style: TextStyle(color: Color(0xFF854F0B), fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '↑ visível apenas quando Recorrente = Sim',
                            style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                        ],

                        // ============ 3 — SELECIONAR UNIDADES E VALORES ============
                        _buildStepHeader('3 — SELECIONAR UNIDADES E VALORES'),
                        TextFormField(
                          controller: _pesquisaController,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Buscar unidade, bloco ou nome...',
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                            suffixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            isDense: true,
                          ),
                          onChanged: (val) => cubit.atualizarPesquisaUnidade(val),
                        ),
                        const SizedBox(height: 12),

                        // Tabela de unidades
                        if (state.loadingUnidades)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (state.unidadesPesquisadas.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text('Nenhuma unidade encontrada.', style: TextStyle(color: Colors.grey))),
                          )
                        else
                          Column(
                            children: [
                              // Cabeçalho da Tabela
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5)),
                                ),
                                child: Row(
                                  children: const [
                                    SizedBox(width: 32), // space for checkbox
                                    Expanded(flex: 3, child: Text('Unidade', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey))),
                                    Expanded(flex: 3, child: Text('Proprietário', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey))),
                                    SizedBox(width: 80, child: Text('Valor (R\$)', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey))),
                                    SizedBox(width: 8),
                                  ],
                                ),
                              ),
                              // Lista de Unidades
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.unidadesPesquisadas.length,
                                itemBuilder: (context, blocoIndex) {
                                  final bloco = state.unidadesPesquisadas[blocoIndex];
                                  return Column(
                                    children: bloco.unidades.map((unidade) {
                                      final isSelected = state.unidadesSelecionadas.contains(unidade.id);
                                      final currentValor = state.valoresPorUnidade[unidade.id];
                                      final valorController = _getValorController(unidade.id, currentValor);

                                      return Container(
                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFE6F1FB) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5)),
                                        ),
                                        child: Row(
                                          children: [
                                            // Checkbox
                                            SizedBox(
                                              width: 32,
                                              child: Checkbox(
                                                value: isSelected,
                                                activeColor: const Color(0xFF185FA5),
                                                side: BorderSide(color: Colors.grey.shade400, width: 0.5),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                                                onChanged: (val) {
                                                  if (unidade.id.isNotEmpty) {
                                                    cubit.alternarSelecaoUnidade(unidade.id);
                                                    if (val == false) {
                                                      valorController.clear();
                                                      cubit.atualizarValorPorUnidade(unidade.id, 0);
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                            // Unidade
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                '${bloco.bloco.nome} / ${unidade.numero}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isSelected ? const Color(0xFF0D3B66) : Colors.grey.shade700,
                                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            // Proprietário
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Proprietário',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            // Valor
                                            SizedBox(
                                              width: 80,
                                              child: TextFormField(
                                                controller: valorController,
                                                enabled: isSelected,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isSelected ? Colors.black : Colors.grey,
                                                ),
                                                textAlign: TextAlign.right,
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                decoration: InputDecoration(
                                                  hintText: '0,00',
                                                  hintStyle: const TextStyle(color: Colors.grey),
                                                  fillColor: isSelected ? Colors.white : Colors.grey.shade100,
                                                  filled: true,
                                                  isDense: true,
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                    borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                    borderSide: BorderSide(color: Colors.grey.shade300, width: 0.5),
                                                  ),
                                                  disabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                    borderSide: BorderSide(color: Colors.transparent),
                                                  ),
                                                ),
                                                onChanged: (val) {
                                                  final valDouble = double.tryParse(val.replaceAll(',', '.'));
                                                  if (valDouble != null) {
                                                    cubit.atualizarValorPorUnidade(unidade.id, valDouble);
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),

                        const SizedBox(height: 4),
                        const Text(
                          'Valor editável inline por unidade após selecionar',
                          style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
                        ),

                        const SizedBox(height: 24),
                        // ============ BOTÕES DE AÇÃO ============
                        if (state.tipoCobranca == null || state.tipoCobranca == 'Junto a Taxa Cond.') ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF185FA5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                              onPressed: () => cubit.adicionarAoCarrinho(),
                              child: const Text(
                                'Gerar Composição',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF185FA5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                              onPressed: () => cubit.adicionarAoCarrinho(), // ou outra action para "Gerar Boleto"
                              child: const Text(
                                'Gerar Boleto',
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: state.enviarParaRegistro,
                                onChanged: (val) {
                                  // TODO: adicionar método no cubit se necessário, ou mock
                                },
                                activeColor: const Color(0xFF185FA5),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              const Text('Enviar para Registro', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(width: 16),
                              Checkbox(
                                value: state.enviarPorEmail,
                                onChanged: (val) {
                                  // TODO: adicionar método no cubit se necessário
                                },
                                activeColor: const Color(0xFF185FA5),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              const Text('Disparar por E-Mail', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 60), // Space for fixed footer
                      ],
                    ),
                  ),
                ),
              ),

              // ============ RODAPÉ FIXO ============
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Selecionadas',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          '${state.unidadesSelecionadas.length} unid. · R\$ ${() {
                            double totalVal = 0;
                            for (var id in state.unidadesSelecionadas) {
                              totalVal += state.valoresPorUnidade[id] ?? 0.0;
                            }
                            return NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: 2).format(totalVal).trim();
                          }()}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    if (state.unidadesSelecionadas.isNotEmpty)
                      TextButton(
                        onPressed: () => cubit.limparSelecaoUnidades(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFE24B4A),
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Excluir', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}