import 'package:flutter/material.dart';

class RelatorioBoletoWidget extends StatefulWidget {
  const RelatorioBoletoWidget({super.key});

  @override
  State<RelatorioBoletoWidget> createState() => _RelatorioBoletoWidgetState();
}

class _RelatorioBoletoWidgetState extends State<RelatorioBoletoWidget> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _buscaController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();
  final _nossoNumeroController = TextEditingController();

  bool _filtroExpandido = true;
  int _mesVenc = DateTime.now().month;
  int _anoVenc = DateTime.now().year;
  String _tipoEmissao = 'Todos';
  String _situacao = 'Todos';
  String _tipoVisualizacao = 'Sintético'; // Detalhado ou Sintético

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === Barra de Pesquisa ===
          _buildSearchBar(),
          const SizedBox(height: 20),

          // === Mês/Ano ===
          _buildMesAnoSelector(),
          const SizedBox(height: 20),

          // === Filtro colapsável ===
          _buildFiltroSection(),
          const SizedBox(height: 20),

          // === Nosso Número ===
          _buildNossoNumero(),
          const SizedBox(height: 24),

          // === Detalhado / Sintético ===
          _buildTipoVisualizacao(),
          const SizedBox(height: 28),

          // === Botões de Ação ===
          _buildActionButtons(),
        ],
      ),
    );
  }

  // ======================= BARRA DE PESQUISA =======================
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _buscaController,
            decoration: InputDecoration(
              hintText: 'Pesquisar unidade/bloco ou nome',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _primaryColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.search, color: _primaryColor, size: 24),
            onPressed: () {
              // Pesquisa — em breve
            },
          ),
        ),
      ],
    );
  }

  // ======================= MÊS/ANO =======================
  Widget _buildMesAnoSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Mês/Ano',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 24, color: _primaryColor),
          onPressed: () {
            setState(() {
              _mesVenc--;
              if (_mesVenc < 1) {
                _mesVenc = 12;
                _anoVenc--;
              }
            });
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_mesVenc.toString().padLeft(2, '0')} / $_anoVenc',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: _primaryColor,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 24, color: _primaryColor),
          onPressed: () {
            setState(() {
              _mesVenc++;
              if (_mesVenc > 12) {
                _mesVenc = 1;
                _anoVenc++;
              }
            });
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  // ======================= FILTRO =======================
  Widget _buildFiltroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _filtroExpandido = !_filtroExpandido),
          child: Row(
            children: [
              const Text(
                'Filtro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _filtroExpandido
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        const Divider(),
        if (_filtroExpandido) ...[
          const SizedBox(height: 8),

          // Intervalo
          Row(
            children: [
              const Text(
                'Intervalo:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _dataInicioController,
                  decoration: InputDecoration(
                    hintText: 'Início __/__',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('a', style: TextStyle(fontSize: 13)),
              ),
              Expanded(
                child: TextField(
                  controller: _dataFimController,
                  decoration: InputDecoration(
                    hintText: 'Fim __/__',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tipo de Emissão
          Row(
            children: [
              const Text(
                'Tipo de Emissão:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _tipoEmissao,
                  isDense: true,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  items: ['Todos', 'Avulso', 'Mensal', 'Acordo']
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 13)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _tipoEmissao = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Situação
          Row(
            children: [
              const Text(
                'Situação:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _situacao,
                  isDense: true,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  items:
                      [
                            'Todos',
                            'Ativo',
                            'Pago',
                            'Cancelado',
                            'Cancelado por Acordo',
                          ]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _situacao = val);
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ======================= NOSSO NÚMERO =======================
  Widget _buildNossoNumero() {
    return SizedBox(
      width: 220,
      child: TextField(
        controller: _nossoNumeroController,
        decoration: InputDecoration(
          labelText: 'Nosso Número:',
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 14,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _primaryColor),
          ),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  // ======================= DETALHADO / SINTÉTICO =======================
  Widget _buildTipoVisualizacao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio<String>(
          value: 'Detalhado',
          groupValue: _tipoVisualizacao,
          onChanged: (val) =>
              setState(() => _tipoVisualizacao = val ?? 'Sintético'),
          activeColor: _primaryColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const Text(
          'Detalhado',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 24),
        Radio<String>(
          value: 'Sintético',
          groupValue: _tipoVisualizacao,
          onChanged: (val) =>
              setState(() => _tipoVisualizacao = val ?? 'Sintético'),
          activeColor: _primaryColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const Text(
          'Sintético',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ======================= BOTÕES DE AÇÃO =======================
  Widget _buildActionButtons() {
    return Row(
      children: [
        _actionButton('Ver PDF', Icons.picture_as_pdf),
        const SizedBox(width: 10),
        _actionButton('Visualizar', Icons.visibility),
        const SizedBox(width: 10),
        _actionButton('E-mail', Icons.email),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _primaryColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: _primaryColor, size: 20),
            onPressed: () => _showSnack('Compartilhar — Em breve'),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _showSnack('$label — Em breve'),
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
