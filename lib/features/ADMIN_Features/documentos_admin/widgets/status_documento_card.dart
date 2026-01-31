import 'package:flutter/material.dart';
import '../models/documento_status_model.dart';

class StatusDocumentoCard extends StatelessWidget {
  final DocumentoStatusModel documento;
  final VoidCallback? onCorrigir;

  const StatusDocumentoCard({
    super.key,
    required this.documento,
    this.onCorrigir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Azul com informações
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF81C7F5), // Azul claro do design
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Nome:', documento.nome),
                  const SizedBox(height: 4),
                  _buildInfoRow('RG/CNH/CNPJ:', documento.rgCnhCnpj),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Usando Expanded para evitar overflow se cidade for longa
                      Expanded(
                        child: _buildInfoRow('Cidade:', documento.cidade),
                      ),
                      const SizedBox(width: 8),
                      _buildInfoRow('UF:', documento.uf),
                    ],
                  ),

                  if (documento.status == StatusDocumento.erro &&
                      documento.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Erro: ${documento.errorMessage}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  // Seta para baixo centralizada na parte inferior (efeito visual do design)
                  const SizedBox(height: 4),
                  const Center(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Lado direito: Badge de status ou Botão Corrigir
          Column(
            children: [
              _buildStatusBadge(),
              if (documento.status == StatusDocumento.erro) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 30,
                  width: 80, // Largura fixa para alinhar
                  child: OutlinedButton(
                    onPressed: onCorrigir,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Corrigir',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 13),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (documento.status) {
      case StatusDocumento.aprovado:
        color = const Color(0xFF00A84D); // Verde
        text = 'Aprovado';
        break;
      case StatusDocumento.pendente:
        color = const Color(0xFFFF5722); // Laranja avermelhado
        text = 'Pendente';
        break;
      case StatusDocumento.erro:
        color = const Color(0xFFD50000); // Vermelho
        text = 'Erro';
        break;
    }

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
