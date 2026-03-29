import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../services/leitura_service.dart';
import '../models/leitura_model.dart';
import '../../../../models/unidade.dart';

class LeituraRelatorioScreen extends StatefulWidget {
  final String condominioId;
  final LeituraService service;

  const LeituraRelatorioScreen({
    super.key,
    required this.condominioId,
    required this.service,
  });

  @override
  State<LeituraRelatorioScreen> createState() => _LeituraRelatorioScreenState();
}

class _LeituraRelatorioScreenState extends State<LeituraRelatorioScreen> {
  bool _isLoading = false;
  String _selectedTipo = 'Agua';
  Unidade? _selectedUnidade;
  List<Unidade> _unidades = [];
  List<LeituraModel> _historico = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      _unidades = await widget.service.fetchUnidades(widget.condominioId);
      // Pega uma unidade inicial, se houver
      if (_unidades.isNotEmpty) {
        _selectedUnidade = _unidades.first;
      }
      await _loadHistorico();
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Erro ao carregar dados: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadHistorico() async {
    if (_selectedUnidade == null) return;
    setState(() => _isLoading = true);
    try {
      final list = await widget.service.getHistoricoConsumo(
        condominioId: widget.condominioId,
        tipo: _selectedTipo,
        unidadeId: _selectedUnidade!.id,
      );
      // Inverte para ficar cronológico (antigo -> novo) se veio descencente
      setState(() {
        _historico = list.reversed.toList();
        _errorMessage = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Erro ao carregar histórico: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Select Tipo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTipo,
                items: const [
                  DropdownMenuItem(value: 'Agua', child: Text('Água')),
                  DropdownMenuItem(value: 'Gas', child: Text('Gás')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedTipo = val);
                    _loadHistorico();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Select Unidade
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Unidade>(
                value: _selectedUnidade,
                hint: const Text('Selecione uma unidade'),
                isExpanded: true,
                items: _unidades.map((u) {
                  final bloco = u.bloco != null && u.bloco!.isNotEmpty
                      ? 'Bloco ${u.bloco} - '
                      : '';
                  return DropdownMenuItem(
                    value: u,
                    child: Text('$bloco${u.numero}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedUnidade = val);
                    _loadHistorico();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (_historico.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Nenhum histórico encontrado para esta unidade.'),
              ),
            )
          else
            _buildChart(),

          const SizedBox(height: 24),
          if (!_isLoading && _historico.isNotEmpty) _buildResumo(),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _historico.fold<double>(
                0,
                (max, e) => e.consumo > max ? e.consumo : max,
              ) * 1.2, // Um pouco de margem em cima
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(1)} m³\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'R\$ ${_historico[group.x].valor.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= _historico.length) return const SizedBox();
                  final date = _historico[index].dataLeitura;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MMM').format(date).toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: _historico.asMap().entries.map((e) {
            final index = e.key;
            final leitura = e.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: leitura.consumo,
                  color: const Color(0xFF0D3B66), // Azul normal validado
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResumo() {
    double totalMeses = _historico.length.toDouble();
    double totalConsumo = _historico.fold(0, (sum, i) => sum + i.consumo);
    double media = totalMeses > 0 ? totalConsumo / totalMeses : 0;
    
    double maiorConsumo = _historico.fold(0, (max, e) => e.consumo > max ? e.consumo : max);
    double mesAtualConsumo = _historico.isNotEmpty ? _historico.last.consumo : 0;

    return Row(
      children: [
        Expanded(child: _buildCard('Média', '${media.toStringAsFixed(1)} m³')),
        const SizedBox(width: 8),
        Expanded(child: _buildCard('Pico', '${maiorConsumo.toStringAsFixed(1)} m³')),
        const SizedBox(width: 8),
        Expanded(child: _buildCard('Último', '${mesAtualConsumo.toStringAsFixed(1)} m³')),
      ],
    );
  }

  Widget _buildCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D3B66)),
          ),
        ],
      ),
    );
  }
}
