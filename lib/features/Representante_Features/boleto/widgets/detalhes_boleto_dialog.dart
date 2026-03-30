import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/boleto_cubit.dart';
import '../models/boleto_model.dart';

class DetalhesBoletoDialog extends StatefulWidget {
  final Boleto boleto;

  const DetalhesBoletoDialog({super.key, required this.boleto});

  @override
  State<DetalhesBoletoDialog> createState() => _DetalhesBoletoDialogState();
}

class _DetalhesBoletoDialogState extends State<DetalhesBoletoDialog> {
  static const _primaryColor = Color(0xFF0D3B66);
  bool _isEditing = false;
  
  late TextEditingController _valorController;
  late TextEditingController _referenciaController;
  late TextEditingController _dataVencController;
  DateTime? _selectedDate;

  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _valorController = TextEditingController(text: widget.boleto.valor.toStringAsFixed(2));
    _referenciaController = TextEditingController(text: widget.boleto.referencia ?? '');
    _selectedDate = widget.boleto.dataVencimento;
    _dataVencController = TextEditingController(
      text: _selectedDate != null ? _dateFormatter.format(_selectedDate!) : '',
    );
  }

  @override
  void dispose() {
    _valorController.dispose();
    _referenciaController.dispose();
    _dataVencController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dataVencController.text = _dateFormatter.format(picked);
      });
    }
  }

  void _salvar() {
    final double? novoValor = double.tryParse(_valorController.text.replaceAll(',', '.'));
    if (novoValor == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha o valor e a data corretamente.'), backgroundColor: Colors.red),
      );
      return;
    }

    context.read<BoletoCubit>().editarBoleto(
      boletoId: widget.boleto.id!,
      novoValor: novoValor,
      novaDataVencimento: _selectedDate!,
      novaReferencia: _referenciaController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Pode editar apenas se não estiver registrado e tiver ID
    final bool canEdit = (widget.boleto.boletoRegistrado == 'NAO' || widget.boleto.boletoRegistrado == 'ERRO') && widget.boleto.id != null;

    return AlertDialog(
      title: const Text('Detalhes do Boleto', style: TextStyle(color: _primaryColor)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('Sacado', widget.boleto.sacadoNome ?? 'N/A'),
            _buildInfoRow('Unidade/Bloco', widget.boleto.blocoUnidade ?? 'N/A'),
            _buildInfoRow('Nosso Número', widget.boleto.nossoNumero ?? 'Não gerado'),
            _buildInfoRow('Status', widget.boleto.status),
            _buildInfoRow('Registrado ASAAS', widget.boleto.boletoRegistrado),
            const Divider(height: 32),

            if (_isEditing) ...[
              TextField(
                controller: _referenciaController,
                decoration: const InputDecoration(labelText: 'Referência / Descrição'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dataVencController,
                    decoration: const InputDecoration(labelText: 'Data de Vencimento', suffixIcon: Icon(Icons.calendar_month)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Nota: Editar altera o valor total, não o detalhamento.', style: TextStyle(fontSize: 12, color: Colors.orange)),
            ] else ...[
              _buildInfoRow('Referência', widget.boleto.referencia ?? '-'),
              _buildInfoRow('Valor Total', _currencyFormatter.format(widget.boleto.valorTotal)),
              _buildInfoRow('Vencimento', _selectedDate != null ? _dateFormatter.format(_selectedDate!) : '-'),
              
              if (widget.boleto.cotaCondominial > 0 || widget.boleto.fundoReserva > 0) ...[
                const Divider(height: 32),
                const Text('Composição', style: TextStyle(fontWeight: FontWeight.bold)),
                if (widget.boleto.cotaCondominial > 0) _buildInfoRow('Cota Condominial', _currencyFormatter.format(widget.boleto.cotaCondominial)),
                if (widget.boleto.fundoReserva > 0) _buildInfoRow('Fundo Reserva', _currencyFormatter.format(widget.boleto.fundoReserva)),
                if (widget.boleto.multaInfracao > 0) _buildInfoRow('Multa Infração', _currencyFormatter.format(widget.boleto.multaInfracao)),
                if (widget.boleto.rateioAgua > 0) _buildInfoRow('Rateio Água', _currencyFormatter.format(widget.boleto.rateioAgua)),
                if (widget.boleto.desconto > 0) _buildInfoRow('Desconto', _currencyFormatter.format(widget.boleto.desconto)),
                if (widget.boleto.juros > 0) _buildInfoRow('Juros', _currencyFormatter.format(widget.boleto.juros)),
                if (widget.boleto.multa > 0) _buildInfoRow('Multa', _currencyFormatter.format(widget.boleto.multa)),
              ]
            ]
          ],
        ),
      ),
      actions: [
        if (_isEditing) ...[
          TextButton(
            onPressed: () => setState(() => _isEditing = false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
            onPressed: _salvar,
            child: const Text('Salvar'),
          ),
        ] else ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          if (canEdit)
            ElevatedButton.icon(
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Editar'),
              style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ]
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label + ':', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
