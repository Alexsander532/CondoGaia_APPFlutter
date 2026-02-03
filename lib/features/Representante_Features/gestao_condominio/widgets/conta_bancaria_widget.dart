import 'package:flutter/material.dart';
import '../../../../models/condominio.dart';

class ContaBancariaWidget extends StatefulWidget {
  final Condominio? condominio;

  const ContaBancariaWidget({super.key, required this.condominio});

  @override
  State<ContaBancariaWidget> createState() => _ContaBancariaWidgetState();
}

class _ContaBancariaWidgetState extends State<ContaBancariaWidget> {
  // Mock Data
  final List<Map<String, dynamic>> _contas = [
    {
      'nome': 'Conta Corrente',
      'banco': '736 Coop. Sicredi',
      'conta': '12345-6',
      'ag': '0706',
      'principal': true,
    },
    {
      'nome': 'Fundo Reserva',
      'banco': '736 Coop. Sicredi',
      'conta': '12345-6',
      'ag': '0706',
      'principal': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Add Button Row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                // TODO: Implement add account logic
              },
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF0D3B66),
                size: 32,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Headers
        Row(
          children: [
            Expanded(flex: 3, child: _buildHeader('NOME:')),
            Expanded(flex: 3, child: _buildHeader('BANCO:')),
            Expanded(flex: 2, child: _buildHeader('CONTA:')),
            Expanded(flex: 2, child: _buildHeader('AG:')),
            const SizedBox(width: 24), // Space for actions
          ],
        ),
        const Divider(color: Color(0xFF0D3B66), thickness: 1),

        // List
        ..._contas.map((conta) => _buildContaRow(conta)).toList(),
      ],
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 12,
      ),
    );
  }

  Widget _buildContaRow(Map<String, dynamic> conta) {
    final isPrincipal = conta['principal'] == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              conta['nome'],
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              conta['banco'],
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              conta['conta'],
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  conta['ag'],
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                if (isPrincipal) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D3B66),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Principal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Actions
          if (!isPrincipal)
            InkWell(
              onTap: () {},
              child: const Icon(Icons.edit, size: 20, color: Color(0xFF0D3B66)),
            )
          else
            const SizedBox(width: 20), // Placeholder to align
        ],
      ),
    );
  }
}
