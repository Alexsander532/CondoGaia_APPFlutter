import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../cubit/leitura_cubit.dart';
import '../cubit/leitura_state.dart';
import '../services/leitura_service.dart';
import '../widgets/leitura_table_widget.dart';

import 'leitura_configuracao_screen.dart';
import 'leitura_relatorio_screen.dart';
import '../../../../services/photo_picker_service.dart';

class LeituraScreen extends StatefulWidget {
  final String condominioId;
  final LeituraService? service;

  const LeituraScreen({super.key, required this.condominioId, this.service});

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
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0D3B66)),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF0D3B66),
              ),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final photoPickerService = PhotoPickerService();
    XFile? x;
    
    if (source == ImageSource.camera) {
      x = await photoPickerService.pickImageFromCamera(
        maxWidth: 1024,
        imageQuality: 85,
      );
    } else {
      x = await photoPickerService.pickImage(
        maxWidth: 1024,
        imageQuality: 85,
      );
    }

    if (x != null) {
      setState(() => _selectedImage = File(x!.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeituraCubit(
        service: widget.service ?? LeituraService(),
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
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF0D3B66)),
                tooltip: 'Recarregar dados',
                onPressed: () {
                  context.read<LeituraCubit>().loadLeituras();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recarregando dados...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
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
                    Expanded(child: _buildTab('Cadastrar', 0)),
                    Expanded(child: _buildTab('Relatório', 1)),
                    Expanded(child: _buildTab('Configurar', 2)),
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
                                    value:
                                        state.tiposDisponiveis.contains(
                                          state.selectedTipo,
                                        )
                                        ? state.selectedTipo
                                        : (state.tiposDisponiveis.isNotEmpty
                                              ? state.tiposDisponiveis.first
                                              : null),
                                    items: state.tiposDisponiveis
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
                                'Data da Leitura: ${DateFormat('dd/MM/yyyy').format(state.selectedDate)}',
                              ),
                              const SizedBox(height: 12),

                              // M3 Input
                              Container(
                                height: 50,
                                decoration: _inputDecoration(),
                                child: TextField(
                                  controller: _m3Controller,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9,]'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 8,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${state.configuracao?.unidadeMedida ?? 'M³'}: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                      minWidth: 0,
                                      minHeight: 0,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
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
                                            ? 'Foto anexada (toque para trocar)'
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

                              // Preview da foto selecionada
                              if (_selectedImage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Center(
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            _selectedImage!,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => setState(
                                            () => _selectedImage = null,
                                          ),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(2),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
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
                                          .where(
                                            (l) =>
                                                l.unidadeId ==
                                                state.selectedUnidadeId,
                                          )
                                          .toList();
                                      if (l.isNotEmpty) id = l.first.unidadeId;
                                    }
                                    if (id == null &&
                                        filteredLeituras.length == 1) {
                                      id = filteredLeituras.first.unidadeId;
                                    }
                                    if (id == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Selecione uma unidade (toque na linha) ou filtre para uma única',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    final valStr = _m3Controller.text
                                        .replaceAll(',', '.');
                                    final leitura = double.tryParse(valStr);
                                    if (leitura == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Informe o valor em M³',
                                          ),
                                        ),
                                      );
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
                                        content: Text('Leitura gravada!'),
                                      ),
                                    );
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
                                  _m3Controller.text = leitura.leituraAtual > 0
                                      ? leitura.leituraAtual
                                            .toString()
                                            .replaceAll(RegExp(r'\.0$'), '')
                                            .replaceAll('.', ',')
                                      : '';
                                },
                              ),

                              const SizedBox(height: 20),

                              // Footer Actions
                              Row(
                                children: [
                                  _buildFooterButton('Excluir', () async {
                                    final selected = filteredLeituras
                                        .where(
                                          (l) =>
                                              l.isSelected && l.id.isNotEmpty,
                                        )
                                        .toList();
                                    if (selected.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Selecione leituras gravadas para excluir',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Confirmar exclusão'),
                                        content: Text(
                                          'Excluir ${selected.length} leitura(s) selecionada(s)?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Excluir'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      cubit.deleteSelected();
                                    }
                                  }),
                                  const SizedBox(width: 8),
                                  _buildFooterButton('Editar', () {
                                    final sel = filteredLeituras
                                        .where(
                                          (l) =>
                                              l.isSelected && l.id.isNotEmpty,
                                        )
                                        .toList();
                                    if (sel.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Selecione uma leitura para editar',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    final l = sel.first;
                                    cubit.selectUnidade(l.unidadeId);
                                    _m3Controller.text = l.leituraAtual
                                        .toString()
                                        .replaceAll(RegExp(r'\.0$'), '')
                                        .replaceAll('.', ',');
                                  }, isDark: true),
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
                      : _selectedTabIndex == 1
                          ? LeituraRelatorioScreen(
                              condominioId: widget.condominioId,
                              service: widget.service ?? LeituraService(),
                            )
                          : LeituraConfiguracaoScreen(
                              condominioId: widget.condominioId,
                              tipoInicial: state.selectedTipo,
                              service: widget.service,
                              onConfigSaved: () {
                                // Recarregar dados após salvar configuração
                                cubit.loadLeituras();
                              },
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
