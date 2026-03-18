import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/despesa_model.dart';
import '../cubit/despesa_receita_cubit.dart';
import 'shared_widgets.dart';

class DespesaDetailModal extends StatelessWidget {
  final Despesa despesa;

  const DespesaDetailModal({
    super.key,
    required this.despesa,
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainInfo(),
                    const SizedBox(height: 20),
                    _buildDetailsList(),
                    if (despesa.link != null && despesa.link!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildLinkSection(context),
                    ],
                    if (despesa.fotoUrl != null && despesa.fotoUrl!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildImageSection(),
                    ],
                    if (despesa.recorrente) ...[
                      const SizedBox(height: 20),
                      _buildRecorrenteInfo(),
                    ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.8)],
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
                  Icons.account_balance_wallet_outlined,
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
            'Detalhes da Despesa',
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
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Text(
              despesa.tipo,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            despesa.descricao ?? 'Sem descrição',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'R\$ ${despesa.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  color: Colors.red,
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

  Widget _buildDetailsList() {
    return Column(
      children: [
        _buildDetailListItem(
          icon: Icons.calendar_today,
          label: 'Vencimento',
          value: despesa.dataVencimento != null
              ? _formatDate(despesa.dataVencimento!)
              : 'Não definido',
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildDetailListItem(
          icon: Icons.account_balance,
          label: 'Conta',
          value: despesa.contaNome ?? 'Não definida',
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildDetailListItem(
          icon: Icons.info_outline,
          label: 'Tipo',
          value: despesa.tipo,
          color: kPrimaryColor,
        ),
        const SizedBox(height: 12),
        _buildDetailListItem(
          icon: Icons.schedule,
          label: 'Criado em',
          value: despesa.createdAt != null
              ? _formatDate(despesa.createdAt!)
              : 'Não informado',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildDetailListItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Link/Boleto',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    despesa.link!,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => _copyToClipboard(despesa.link!, context),
                  icon: Icon(Icons.copy, size: 18, color: Colors.blue),
                  tooltip: 'Copiar link',
                ),
                IconButton(
                  onPressed: () => _launchUrl(despesa.link!, context),
                  icon: Icon(Icons.open_in_new, size: 18, color: Colors.blue),
                  tooltip: 'Abrir link',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Comprovante',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              despesa.fotoUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 48, color: Colors.grey.shade600),
                      const SizedBox(height: 8),
                      Text(
                        'Erro ao carregar imagem',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
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
                'Despesa Recorrente',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (despesa.qtdMeses != null)
            Text(
              'Repete por ${despesa.qtdMeses} meses',
              style: const TextStyle(fontSize: 12),
            ),
          if (despesa.meAvisar) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.notifications_active, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  'Notificação ativada',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final cubit = context.read<DespesaReceitaCubit>();
    
    return Container(
      padding: const EdgeInsets.all(20),
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
                side: BorderSide(color: kPrimaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Fechar',
                style: TextStyle(
                  color: kPrimaryColor,
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
                // Iniciar edição da despesa
                cubit.iniciarEdicaoDespesa(despesa);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link copiado!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir o link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
