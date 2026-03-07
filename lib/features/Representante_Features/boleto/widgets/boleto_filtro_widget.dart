import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_cubit.dart';
import '../cubit/boleto_state.dart';

class BoletoFiltroWidget extends StatefulWidget {
  const BoletoFiltroWidget({super.key});

  @override
  State<BoletoFiltroWidget> createState() => _BoletoFiltroWidgetState();
}

class _BoletoFiltroWidgetState extends State<BoletoFiltroWidget> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _buscaController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();
  final _nossoNumeroController = TextEditingController();

  @override
  void dispose() {
    _buscaController.dispose();
    _dataInicioController.dispose();
    _dataFimController.dispose();
    _nossoNumeroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoletoCubit, BoletoState>(
      builder: (context, state) {
        final cubit = context.read<BoletoCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Pesquisar unidade/bloco ou nome ===
            _buildSearchBar(cubit),
            const SizedBox(height: 16),

            // === Venc.: < 08 / 2022 > ===
            _buildMesAnoSelector(state, cubit),
            const SizedBox(height: 16),

            // === Filtro v ===
            _buildFiltroHeader(state, cubit),
            const Divider(),

            if (state.filtroExpandido) ...[
              const SizedBox(height: 12),
              // Intervalo de Venc.
              _buildIntervaloVenc(),
              const SizedBox(height: 16),

              // Tipo de Emissão
              _buildDropdownField(
                label: 'Tipo de Emissão',
                value: state.tipoEmissao,
                items: ['Todos', 'Avulso', 'Mensal', 'Acordo'],
                onChanged: (val) => cubit.atualizarFiltros(tipoEmissao: val),
              ),
              const SizedBox(height: 16),

              // Situação
              _buildDropdownField(
                label: 'Situação',
                value: state.situacao,
                items: [
                  'Todos',
                  'Ativo',
                  'A vencer',
                  'Cancelado',
                  'Pago',
                  'Cancelado acordo',
                ],
                onChanged: (val) => cubit.atualizarFiltros(situacao: val),
              ),
              const SizedBox(height: 16),

              // Nosso Número + Detalhar Composição
              _buildNossoNumeroRow(state, cubit),
            ],

            const SizedBox(height: 24),

            // Botão Pesquisar (Pill)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  cubit.atualizarFiltros(
                    pesquisa: _buscaController.text,
                    nossoNumero: _nossoNumeroController.text,
                    dataInicio: _dataInicioController.text,
                    dataFim: _dataFimController.text,
                  );
                  cubit.pesquisar();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _primaryColor,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: const Text(
                  'Pesquisar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BoletoCubit cubit) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _buscaController,
        decoration: InputDecoration(
          hintText: 'Pesquisar unidade/bloco ou nome',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          suffixIcon: const Icon(Icons.search, color: _primaryColor, size: 24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
        ),
        onSubmitted: (val) {
          cubit.atualizarFiltros(pesquisa: val);
          cubit.pesquisar();
        },
      ),
    );
  }

  Widget _buildMesAnoSelector(BoletoState state, BoletoCubit cubit) {
    return Row(
      children: [
        const Text(
          'Venc.:',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_left, color: _primaryColor),
          onPressed: () => cubit.mesAnterior(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${state.mesSelecionado.toString().padLeft(2, '0')} / ${state.anoSelecionado}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: _primaryColor),
          onPressed: () => cubit.proximoMes(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildFiltroHeader(BoletoState state, BoletoCubit cubit) {
    return InkWell(
      onTap: () => cubit.toggleFiltro(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Text(
              'Filtro',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _primaryColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              state.filtroExpandido
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: _primaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervaloVenc() {
    return Row(
      children: [
        const Text(
          'Intervalor de Venc.:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _buildSmallDateField(_dataInicioController)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('a', style: TextStyle(fontSize: 13)),
        ),
        Expanded(child: _buildSmallDateField(_dataFimController)),
      ],
    );
  }

  Widget _buildSmallDateField(TextEditingController controller) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: '__/__/____',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: const TextStyle(fontSize: 13)),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) onChanged(val);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNossoNumeroRow(BoletoState state, BoletoCubit cubit) {
    return Row(
      children: [
        const Text(
          'Nosso Número',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _nossoNumeroController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Checkbox(
              value: state.detalharComposicao,
              onChanged: (_) => cubit.toggleDetalharComposicao(),
              activeColor: _primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const Text(
              'Detalhar Composição',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
