import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/boleto_cubit.dart';
import '../cubit/boleto_state.dart';
import '../models/boleto_model.dart';

class BoletoListWidget extends StatelessWidget {
  const BoletoListWidget({super.key});

  static const _primaryColor = Color(0xFF0D3B66);
  static const _headerColor = Color(0xFF0D3B66);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoletoCubit, BoletoState>(
      builder: (context, state) {
        final cubit = context.read<BoletoCubit>();
        final boletos = state.boletosFiltrados;

        if (state.status == BoletoStatus.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (boletos.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Nenhum boleto encontrado',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Altere os filtros ou gere uma cobrança mensal',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Header da tabela
            _buildTableHeader(cubit, boletos, state),

            // Linhas da tabela
            ...boletos.map((boleto) => _buildTableRow(boleto, state, cubit)),

            const SizedBox(height: 16),

            // Legenda Boleto Registrado
            _buildLegenda(),
          ],
        );
      },
    );
  }

  Widget _buildTableHeader(
    BoletoCubit cubit,
    List<Boleto> boletos,
    BoletoState state,
  ) {
    return Container(
      color: _headerColor,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          // Checkbox selecionar todos
          SizedBox(
            width: 32,
            child: Checkbox(
              value:
                  boletos.isNotEmpty &&
                  boletos.every((b) => state.itensSelecionados.contains(b.id)),
              onChanged: (_) {
                cubit.selecionarTodos(
                  boletos.where((b) => b.id != null).map((b) => b.id!).toList(),
                );
              },
              activeColor: Colors.white,
              checkColor: _headerColor,
              side: const BorderSide(color: Colors.white),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          _headerCell('REG', 30),
          _headerCell('BL/UNID', 55),
          _headerCell('SACADO', 65),
          _headerCell('REF.', 45),
          _headerCell('DATA VENC.', 70),
          _headerCell('VALOR', 60),
          _headerCell('STATUS', 50),
          _headerCell('PGTO', 35),
          _headerCell('TIPO', 50),
          _headerCell('BAIXA', 55),
          _headerCell('NOSSO Nº', 65),
          _headerCell('VER', 30),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTableRow(Boleto boleto, BoletoState state, BoletoCubit cubit) {
    final isSelected = state.itensSelecionados.contains(boleto.id);
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    // Cor de fundo alternada
    final index = state.boletosFiltrados.indexOf(boleto);
    final bgColor = index.isEven ? Colors.white : const Color(0xFFF0F4FA);

    // Ícone de registro
    Widget regIcon;
    switch (boleto.boletoRegistrado) {
      case 'SIM':
        regIcon = const Icon(Icons.check_circle, color: Colors.green, size: 14);
        break;
      case 'NAO':
        regIcon = const Icon(Icons.cancel, color: Colors.red, size: 14);
        break;
      case 'PENDENTE':
        regIcon = const Icon(Icons.access_time, color: Colors.orange, size: 14);
        break;
      case 'ERRO':
        regIcon = const Icon(Icons.warning, color: Colors.red, size: 14);
        break;
      default:
        regIcon = const SizedBox(width: 14);
    }

    return Container(
      color: isSelected ? const Color(0xFFE3EDF7) : bgColor,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Checkbox(
              value: isSelected,
              onChanged: (_) {
                if (boleto.id != null) cubit.toggleItemSelecionado(boleto.id!);
              },
              activeColor: _primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          SizedBox(width: 30, child: Center(child: regIcon)),
          _dataCell(boleto.blocoUnidade ?? '', 55),
          _dataCell(boleto.sacado ?? '', 65),
          _dataCell(boleto.referencia ?? '', 45),
          _dataCell(
            boleto.dataVencimento != null
                ? dateFormatter.format(boleto.dataVencimento!)
                : '',
            70,
          ),
          _dataCell(formatter.format(boleto.valor), 60),
          _statusCell(boleto.status, 50),
          _dataCell(boleto.pgto ?? '-', 35),
          _dataCell(boleto.classe ?? boleto.tipo, 50),
          _dataCell(boleto.baixa, 55),
          _dataCell(boleto.nossoNumero ?? '', 65),
          SizedBox(
            width: 30,
            child: GestureDetector(
              onTap: () {
                // Ver boleto
                ScaffoldMessenger.of(
                  // ignore: use_build_context_synchronously
                  _getContext(boleto)!,
                ).showSnackBar(
                  const SnackBar(content: Text('Visualizar boleto — Em breve')),
                );
              },
              child: const Icon(Icons.qr_code, size: 16, color: _primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // Helper que retorna null - fallback para contexto
  BuildContext? _getContext(Boleto boleto) => null;

  Widget _dataCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.black87),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _statusCell(String status, double width) {
    Color color;
    switch (status) {
      case 'Ativo':
        color = Colors.green;
        break;
      case 'Pago':
        color = Colors.blue;
        break;
      case 'Cancelado':
        color = Colors.red;
        break;
      case 'Cancelado por Acordo':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return SizedBox(
      width: width,
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildLegenda() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BOLETO REGISTRADO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 14),
              SizedBox(width: 4),
              Text('SIM', style: TextStyle(fontSize: 11)),
              SizedBox(width: 16),
              Icon(Icons.cancel, color: Colors.red, size: 14),
              SizedBox(width: 4),
              Text('NÃO', style: TextStyle(fontSize: 11)),
              SizedBox(width: 16),
              Icon(Icons.access_time, color: Colors.orange, size: 14),
              SizedBox(width: 4),
              Text('PENDENTE', style: TextStyle(fontSize: 11)),
              SizedBox(width: 16),
              Icon(Icons.warning, color: Colors.red, size: 14),
              SizedBox(width: 4),
              Text('ERRO AO REGISTRAR', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
