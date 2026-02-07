import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../cubit/leitura_cubit.dart';
import '../cubit/leitura_state.dart';
import '../services/leitura_service.dart';
import '../widgets/leitura_table_widget.dart';

import 'leitura_configuracao_screen.dart';

class LeituraScreen extends StatefulWidget {
  final String condominioId;

  const LeituraScreen({super.key, required this.condominioId});

  @override
  State<LeituraScreen> createState() => _LeituraScreenState();
}

class _LeituraScreenState extends State<LeituraScreen> {
  final _searchController = TextEditingController();
  final _m3Controller = TextEditingController();
  int _selectedTabIndex = 0;
  File? _selectedImage;

  @override
  void dispose() {
    _searchController.dispose();
    _m3Controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x != null) {
      setState(() => _selectedImage = File(x.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeituraCubit(
        service: LeituraService(),
        condominioId: widget.condominioId,
      )..loadLeituras(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            children: [
              const Text(
                'CondoGaia',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                'Condomínios',
                style: TextStyle(color: Colors.black, fontSize: 10),
              ),
              const SizedBox(height: 4),
              const Text(
                'Home/Gestão/Leitura',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.headset_mic_outlined, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocConsumer<LeituraCubit, LeituraState>(
          listener: (context, state) {
            if (state.status == LeituraStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Erro')),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<LeituraCubit>();

            // Filter Logic (Simple local filter for display)
            final filteredLeituras = state.leituras.where((l) {
              if (state.unidadePesquisa.isEmpty) return true;
              final query = state.unidadePesquisa.toLowerCase();
              return l.unidadeNome.toLowerCase().contains(query) ||
                  (l.bloco?.toLowerCase().contains(query) ?? false);
            }).toList();

            // Total Logic
            final totalValor = filteredLeituras.fold(
              0.0,
              (sum, item) => sum + item.valor,
            );
            final totalQtd = filteredLeituras
                .where((l) => l.leituraAtual > 0 || l.id.isNotEmpty)
                .length;

            return Column(
              children: [
                // Tabs
                Row(
                  children: [
                    Expanded(child: _buildTab('Cadastrar', 0)), // Index 0
                    Expanded(child: _buildTab('Configurar', 1)), // Index 1
                  ],
                ),
                Expanded(
                  child: _selectedTabIndex == 0
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Draft/Config line ?

                              // Tipo Dropdown
                              Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: _inputDecoration(),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: state.selectedTipo,
                                    items: ['Agua', 'Gas']
                                        .map(
                                          (t) => DropdownMenuItem(
                                            value: t,
                                            child: Text('Tipo: $t'),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) cubit.updateTipo(val);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Search
                              TextField(
                                controller: _searchController,
                                onChanged: (val) => cubit.updateSearch(val),
                                decoration: InputDecoration(
                                  hintText: 'Pesquisar Unid/ Bloco/ Cond.',
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  suffixIcon: const Icon(
                                    Icons.search,
                                    color: Color(0xFF0D3B66),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Data Auto
                              _buildReadOnlyField(
                                'Data da Leitura: ${DateFormat('dd/MM/yyyy').format(state.selectedDate)} (Automatica)',
                              ),
                              const SizedBox(height: 12),

                              // M3 Input
                              Container(
                                height: 50,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  controller: _m3Controller,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    prefixText: 'M³: ',
                                    prefixStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Valor Auto
                              _buildReadOnlyField(
                                'Valor base/config: R\$ ${(state.configuracao?.valorBase ?? 0).toStringAsFixed(2)} (faixas na Configurar)',
                              ),

                              const SizedBox(height: 16),

                              // Anexar Foto
                              GestureDetector(
                                onTap: _pickImage,
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        _selectedImage != null
                                            ? Icons.check_circle
                                            : Icons.image_outlined,
                                        size: 40,
                                        color: const Color(0xFF0D3B66),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedImage != null
                                            ? 'Foto anexada'
                                            : 'Anexar foto',
                                        style: const TextStyle(
                                          color: Color(0xFF0D3B66),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Gravar Button
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    String? id;
                                    if (state.selectedUnidadeId != null) {
                                      final l = filteredLeituras
                                          .where((l) =>
                                              l.unidadeId ==
                                              state.selectedUnidadeId)
                                          .toList();
                                      if (l.isNotEmpty) id = l.first.unidadeId;
                                    }
                                    if (id == null &&
                                        filteredLeituras.length == 1) {
                                      id = filteredLeituras.first.unidadeId;
                                    }
                                    if (id == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Selecione uma unidade (toque na linha) ou filtre para uma única'),
                                      ));
                                      return;
                                    }
                                    final leitura =
                                        double.tryParse(_m3Controller.text);
                                    if (leitura == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('Informe o valor em M³'),
                                      ));
                                      return;
                                    }
                                    cubit.gravarLeitura(
                                      unidadeId: id,
                                      leituraAtual: leitura,
                                      imagem: _selectedImage,
                                    );
                                    _m3Controller.clear();
                                    setState(() => _selectedImage = null);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Leitura gravada!')));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D3B66),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'Gravar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // TABLE
                              LeituraTableWidget(
                                leituras: filteredLeituras,
                                onSelectionChanged: (id, val) =>
                                    cubit.toggleSelection(id, val),
                                onRowTap: (leitura) {
                                  cubit.selectUnidade(leitura.unidadeId);
                                  _m3Controller.text =
                                      leitura.leituraAtual > 0
                                          ? leitura.leituraAtual.toString()
                                          : '';
                                },
                              ),

                              const SizedBox(height: 20),

                              // Footer Actions
                              Row(
                                children: [
                                  _buildFooterButton(
                                    'Excluir',
                                    () => cubit.deleteSelected(),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFooterButton(
                                    'Editar',
                                    () {
                                      final sel = filteredLeituras
                                          .where((l) =>
                                              l.isSelected &&
                                              l.id.isNotEmpty)
                                          .toList();
                                      if (sel.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              'Selecione uma leitura para editar'),
                                        ));
                                        return;
                                      }
                                      final l = sel.first;
                                      cubit.selectUnidade(l.unidadeId);
                                      _m3Controller.text =
                                          l.leituraAtual.toString();
                                    },
                                    isDark: true,
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Qtnd.: $totalQtd',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D3B66),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Total: R\$ ${totalValor.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        )
                      : LeituraConfiguracaoScreen(
                          condominioId: widget.condominioId,
                          tipoInicial: state.selectedTipo,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF0D3B66) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? const Color(0xFF0D3B66) : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.grey.shade400),
    );
  }

  Widget _buildReadOnlyField(String text) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _inputDecoration(),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFooterButton(
    String label,
    VoidCallback onPressed, {
    bool isDark = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? const Color(0xFF0D3B66) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0D3B66),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Color(0xFF0D3B66)),
        ),
      ),
      child: Text(label),
    );
  }
}
