import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/receita_model.dart';
import 'shared_widgets.dart';

class ReceitaDetailModal extends StatelessWidget {
  final Receita receita;

  const ReceitaDetailModal({
    super.key,
    required this.receita,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainInfo(),
                    const SizedBox(height: 24),
                    _buildDetailsGrid(),
                    if (receita.recorrente) ...[
                      const SizedBox(height: 24),
                      _buildRecorrenteInfo(),
                    ],
                    const SizedBox(height: 24),
                    _buildTypeIndicator(),
                  ],
                ),
              ),
            ),
            
            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Detalhes da Receita',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getTypeColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getTypeColor().withOpacity(0.5)),
            ),
            child: Text(
              receita.tipo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            receita.descricao ?? 'Sem descrição',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add_circle,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'R\$ ${receita.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildDetailCard(
          icon: Icons.calendar_today,
          label: 'Data do Crédito',
          value: receita.dataCredito != null
              ? _formatDate(receita.dataCredito!)
              : 'Não definida',
          color: Colors.blue,
        ),
        _buildDetailCard(
          icon: Icons.account_balance,
          label: 'Conta',
          value: receita.contaNome ?? 'Não definida',
          color: kPrimaryColor,
        ),
        // REMOVIDOS: Categoria e Subcategoria
        _buildDetailCard(
          icon: Icons.account_balance_wallet,
          label: 'Conta Contábil',
          value: receita.contaContabil ?? 'Não definida',
          color: Colors.orange,
        ),
        _buildDetailCard(
          icon: Icons.schedule,
          label: 'Criado em',
          value: receita.createdAt != null
              ? _formatDate(receita.createdAt!)
              : 'Não informado',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecorrenteInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Receita Recorrente',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (receita.qtdMeses != null)
            Text(
              'Repete por ${receita.qtdMeses} meses',
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeIndicator() {
    Color backgroundColor;
    IconData icon;
    String title;
    String description;

    switch (receita.tipo) {
      case 'AUTOMATICO':
        backgroundColor = Colors.green.withOpacity(0.1);
        icon = Icons.auto_mode;
        title = 'Receita Automática';
        description = 'Gerada automaticamente pelo sistema quando um boleto é pago.';
        break;
      case 'MANUAL':
      default:
        backgroundColor = kPrimaryColor.withOpacity(0.1);
        icon = Icons.edit;
        title = 'Receita Manual';
        description = 'Lançada manualmente pelo síndico ou administrador.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getTypeColor().withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _getTypeColor(), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getTypeColor(),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Fechar',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implementar edição
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Editar',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (receita.tipo) {
      case 'AUTOMATICO':
        return Colors.green;
      case 'MANUAL':
      default:
        return kPrimaryColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
