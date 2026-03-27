import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/boleto_cubit.dart';
import '../cubit/boleto_state.dart';

class SelecionarBlocoUnidDialog extends StatefulWidget {
  final void Function(List<String> unidadeIds) onConfirm;

  const SelecionarBlocoUnidDialog({super.key, required this.onConfirm});

  @override
  State<SelecionarBlocoUnidDialog> createState() =>
      _SelecionarBlocoUnidDialogState();
}

class _SelecionarBlocoUnidDialogState extends State<SelecionarBlocoUnidDialog> {
  static const _primaryColor = Color(0xFF0D3B66);

  final _buscaController = TextEditingController();
  final Set<String> _selecionados = {};

  @override
  void initState() {
    super.initState();
    // Carrega as unidades ao abrir
    Future.microtask(() {
      context.read<BoletoCubit>().carregarUnidades();
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoletoCubit, BoletoState>(
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bloco/Unid.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Busca
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _buscaController,
                        decoration: InputDecoration(
                          hintText: 'Pesquisar unidade/bloco ou nome',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
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
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: _primaryColor,
                        size: 22,
                      ),
                      onPressed: () {
                        context.read<BoletoCubit>().carregarUnidades(
                          pesquisa: _buscaController.text,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Header da tabela
                Container(
                  color: _primaryColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: Row(
                    children: const [
                      SizedBox(width: 32),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'BL/UNID',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'NOME',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de unidades
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.unidades.length,
                    itemBuilder: (context, index) {
                      final unidade = state.unidades[index];
                      final id = unidade['id'] as String;
                      final bloco = unidade['bloco'] ?? '';
                      final unid = unidade['numero'] ?? '';
                      final blocoUnidade = bloco.isNotEmpty
                          ? '$bloco-$unid'
                          : unid;
                      final props = unidade['proprietarios'];
                      String nome = 'Morador';
                      if (props != null) {
                        if (props is List && props.isNotEmpty) {
                          nome = props[0]['nome'] ?? 'Morador';
                        } else if (props is Map) {
                          nome = props['nome'] ?? 'Morador';
                        }
                      }
                      final isSelected = _selecionados.contains(id);

                      return Container(
                        color: isSelected
                            ? const Color(0xFFE3EDF7)
                            : (index.isEven
                                  ? Colors.white
                                  : const Color(0xFFF8F9FA)),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32,
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (_) {
                                  setState(() {
                                    if (isSelected) {
                                      _selecionados.remove(id);
                                    } else {
                                      _selecionados.add(id);
                                    }
                                  });
                                },
                                activeColor: _primaryColor,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                blocoUnidade,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                nome,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Botão confirmar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onConfirm(_selecionados.toList());
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _selecionados.isEmpty
                          ? 'Selecionar Todos'
                          : 'Confirmar (${_selecionados.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
