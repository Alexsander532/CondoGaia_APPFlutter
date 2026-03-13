import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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

        return LayoutBuilder(
          builder: (context, constraints) {
            // Aumentamos a largura mínima para 1000 para dar fôlego em telas desktop
            final double tableWidth = constraints.maxWidth > 1000 ? constraints.maxWidth : 1000.0;
            
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header da tabela
                    _buildTableHeader(cubit, boletos, state),

                    // Linhas da tabela
                    ...boletos.map((boleto) => _buildTableRow(context, boleto, state, cubit)),

                    const SizedBox(height: 16),

                    // Legenda Boleto Registrado
                    _buildLegenda(),
                  ],
                ),
              ),
            );
          },
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
          _headerCell('REG', null, width: 30),
          _headerCell('BL/UNID', 2),
          _headerCell('SACADO', 7),
          _headerCell('REF.', 2),
          _headerCell('DATA VENC.', 3),
          _headerCell('VALOR', 3),
          _headerCell('STATUS', 3),
          _headerCell('PGTO', 2),
          _headerCell('TIPO', 3),
          _headerCell('BAIXA', 3),
          _headerCell('NOSSO Nº', 5),
          _headerCell('VER', null, width: 30),
        ],
      ),
    );
  }

  Widget _headerCell(String text, int? flex, {double? width}) {
    final cell = Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
      overflow: TextOverflow.ellipsis,
    );
    
    if (width != null) {
      return SizedBox(width: width, child: cell);
    }
    
    return Expanded(
      flex: flex ?? 1,
      child: cell,
    );
  }

  Widget _buildTableRow(BuildContext context, Boleto boleto, BoletoState state, BoletoCubit cubit) {
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
          SizedBox(
            width: 30,
            child: InkWell(
              onTap: (boleto.boletoRegistrado == 'NAO' || boleto.boletoRegistrado == 'ERRO') && boleto.id != null
                ? () => cubit.registrarBoletoNoAsaas(boleto.id!)
                : null,
              child: Center(child: regIcon),
            ),
          ),
          _dataCell(boleto.blocoUnidade ?? '', 2),
          _dataCell(boleto.sacadoNome ?? '', 7),
          _dataCell(boleto.referencia ?? '', 2),
          _dataCell(
            boleto.dataVencimento != null
                ? dateFormatter.format(boleto.dataVencimento!)
                : '',
            3,
          ),
          _dataCell(formatter.format(boleto.valor), 3),
          _statusCell(boleto.status, 3), // Vou precisar ajustar o statusCell também
          _dataCell(boleto.pgto ?? '-', 2),
          _dataCell(boleto.classe ?? boleto.tipo, 3),
          _dataCell(boleto.baixa, 3),
          _dataCell(boleto.nossoNumero ?? '', 5),
          SizedBox(
            width: 30,
            child: GestureDetector(
              onTap: () async {
                if (boleto.bankSlipUrl != null && boleto.bankSlipUrl!.isNotEmpty) {
                  final uri = Uri.parse(boleto.bankSlipUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Não foi possível abrir o link do boleto.')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Este boleto ainda não possui link de pagamento.')),
                  );
                }
              },
              child: Icon(
                Icons.qr_code,
                size: 16,
                color: boleto.bankSlipUrl != null ? _primaryColor : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget de dados genérico
  Widget _dataCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, color: Color(0xFF1E293B)),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _statusCell(String status, int flex) {
    Color color;
    switch (status.toUpperCase()) {
      case 'PAGO':
        color = Colors.green;
        break;
      case 'CANCELADO':
        color = Colors.red;
        break;
      case 'REGISTRADO':
        color = Colors.blue;
        break;
      default:
        color = Colors.green; // ATIVO
    }

    return Expanded(
      flex: flex,
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
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
