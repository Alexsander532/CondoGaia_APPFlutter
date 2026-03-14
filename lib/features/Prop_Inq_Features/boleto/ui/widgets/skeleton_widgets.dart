import 'package:flutter/material.dart';

/// Widget de Skeleton para simular loading de boletos
class BoletoSkeleton extends StatelessWidget {
  const BoletoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header skeleton
            Row(
              children: [
                _buildSkeleton(width: 60, height: 40), // Data
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeleton(width: 120, height: 16), // Tipo
                      const SizedBox(height: 4),
                      _buildSkeleton(width: 80, height: 12), // Status
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildSkeleton(width: 80, height: 24), // Valor
              ],
            ),
            const SizedBox(height: 12),
            // Detalhes skeleton
            Row(
              children: [
                _buildSkeleton(width: 100, height: 14), // Sacado
                const Spacer(),
                _buildSkeleton(width: 24, height: 24), // Expand icon
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Widget de Skeleton para seções expansíveis
class SecaoSkeleton extends StatelessWidget {
  const SecaoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSkeleton(width: 150, height: 16), // Título
            const SizedBox(height: 12),
            _buildSkeleton(width: double.infinity, height: 14), // Linha 1
            const SizedBox(height: 8),
            _buildSkeleton(width: 200, height: 14), // Linha 2
            const SizedBox(height: 8),
            _buildSkeleton(width: 120, height: 14), // Linha 3
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Widget de Skeleton para demonstrativo financeiro
class DemonstrativoSkeleton extends StatelessWidget {
  const DemonstrativoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeleton(width: 180, height: 16), // Título
          const SizedBox(height: 12),
          _buildSkeleton(width: 150, height: 14), // Total boletos
          const SizedBox(height: 8),
          _buildSkeleton(width: 120, height: 14), // Boletos pagos
          const SizedBox(height: 8),
          _buildSkeleton(width: 140, height: 14), // Boletos em aberto
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildSkeleton(width: 100, height: 16), // Total
        ],
      ),
    );
  }

  Widget _buildSkeleton({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
