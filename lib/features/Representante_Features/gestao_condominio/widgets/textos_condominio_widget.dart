import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../models/condominio.dart';
import '../cubit/textos_condominio_cubit.dart';
import '../cubit/textos_condominio_state.dart';
import '../models/textos_condominio_model.dart';
import '../services/gestao_condominio_service.dart';

class TextosCondominioWidget extends StatelessWidget {
  final Condominio? condominio;

  const TextosCondominioWidget({super.key, required this.condominio});

  @override
  Widget build(BuildContext context) {
    if (condominio == null) return const SizedBox.shrink();

    return BlocProvider(
      create: (context) =>
          TextosCondominioCubit(service: GestaoCondominioService())
            ..carregarTextos(condominio!.id),
      child: _TextosCondominioView(condominioId: condominio!.id),
    );
  }
}

class _TextosCondominioView extends StatefulWidget {
  final String condominioId;
  const _TextosCondominioView({required this.condominioId});

  @override
  State<_TextosCondominioView> createState() => _TextosCondominioViewState();
}

class _TextosCondominioViewState extends State<_TextosCondominioView> {
  // Controllers
  final _comunicadoCotaController = TextEditingController();
  final _comunicadoAcordoController = TextEditingController();
  final _textoBoletoTaxaController = TextEditingController();
  final _textoBoletoAcordoController = TextEditingController();

  final _responsavelTecnicoController = TextEditingController();
  final _cpfResponsavelController = TextEditingController();
  final _conselhoController = TextEditingController();
  final _funcoesController = TextEditingController();

  // Masks
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  int _opcaoData = 0; // 0 = Com data, 1 = Sem data
  String? _currentId; // Para update

  @override
  void dispose() {
    _comunicadoCotaController.dispose();
    _comunicadoAcordoController.dispose();
    _textoBoletoTaxaController.dispose();
    _textoBoletoAcordoController.dispose();
    _responsavelTecnicoController.dispose();
    _cpfResponsavelController.dispose();
    _conselhoController.dispose();
    _funcoesController.dispose();
    super.dispose();
  }

  void _atualizarCampos(TextosCondominio textos) {
    _currentId = textos.id;
    _comunicadoCotaController.text = textos.comunicadoBoletoCota;
    _comunicadoAcordoController.text = textos.comunicadoBoletoAcordo;
    _textoBoletoTaxaController.text = textos.textoBoletoTaxa;
    _textoBoletoAcordoController.text = textos.textoBoletoAcordo;

    _responsavelTecnicoController.text = textos.responsavelTecnicoNome;

    // Aplica a mascara ao setar o valor
    var cpf = textos.responsavelTecnicoCpf;
    if (cpf.isNotEmpty) {
      _cpfMask.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: cpf),
      );
      _cpfResponsavelController.text = _cpfMask.getMaskedText();
    } else {
      _cpfResponsavelController.text = '';
    }

    _conselhoController.text = textos.responsavelTecnicoConselho;
    _funcoesController.text = textos.responsavelTecnicoFuncoes;
    _opcaoData = textos.exibirDataDemonstrativo ? 0 : 1;
  }

  void _salvar() {
    final cubit = context.read<TextosCondominioCubit>();
    final textos = TextosCondominio(
      id: _currentId,
      condominioId: widget.condominioId,
      comunicadoBoletoCota: _comunicadoCotaController.text,
      comunicadoBoletoAcordo: _comunicadoAcordoController.text,
      textoBoletoTaxa: _textoBoletoTaxaController.text,
      textoBoletoAcordo: _textoBoletoAcordoController.text,
      responsavelTecnicoNome: _responsavelTecnicoController.text,
      responsavelTecnicoCpf: _cpfMask.getUnmaskedText(), // Salva sem formatação
      responsavelTecnicoConselho: _conselhoController.text,
      responsavelTecnicoFuncoes: _funcoesController.text,
      exibirDataDemonstrativo: _opcaoData == 0,
    );
    cubit.salvarTextos(textos);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TextosCondominioCubit, TextosCondominioState>(
      listener: (context, state) {
        if (state.status == TextosStatus.success) {
          _atualizarCampos(state.textos!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Textos salvos com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == TextosStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Erro ao salvar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == TextosStatus.loading && state.textos == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Listener handles success update, but for initial load where logic might differ slightly or if hot reload messes up
        if (state.status == TextosStatus.success &&
            _comunicadoCotaController.text.isEmpty &&
            state.textos?.comunicadoBoletoCota.isNotEmpty == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (state.textos != null && _currentId != state.textos!.id) {
              _atualizarCampos(state.textos!);
            }
          });
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGroupCard(
                title: 'Comunicados de Boleto',
                icon: Icons.receipt_long,
                children: [
                  _buildSectionLabel('Boleto Cota Condominial'),
                  _buildTextArea(_comunicadoCotaController),

                  _buildSectionLabel('Boleto de Acordo'),
                  _buildTextArea(_comunicadoAcordoController),

                  _buildSectionLabel('Boleto Taxa Extra'),
                  _buildTextArea(_textoBoletoTaxaController),

                  _buildSectionLabel('Boleto Acordo (Texto Extra)'),
                  _buildTextArea(_textoBoletoAcordoController),
                ],
              ),

              const SizedBox(height: 16),

              _buildGroupCard(
                title: 'Capa do Demonstrativo',
                icon: Icons.assignment_ind,
                children: [
                  const Text(
                    'Dados do Responsável Técnico',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLabeledInput(
                    label: 'Nome Completo',
                    controller: _responsavelTecnicoController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildLabeledInput(
                          label: 'CPF',
                          controller: _cpfResponsavelController,
                          inputFormatters: [_cpfMask],
                          icon: Icons.badge_outlined,
                          inputType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: _buildLabeledInput(
                          label: 'Conselho (CRC/OAB)',
                          controller: _conselhoController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildLabeledInput(
                    label: 'Funções (separar por ;)',
                    controller: _funcoesController,
                    hintText: 'Ex: Síndico; Administrador',
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text(
                    'Opções de Exibição',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Radio<int>(
                        value: 0,
                        groupValue: _opcaoData,
                        activeColor: const Color(0xFF0D3B66),
                        onChanged: (val) => setState(() => _opcaoData = val!),
                      ),
                      const Text('Exibir Data', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 16),
                      Radio<int>(
                        value: 1,
                        groupValue: _opcaoData,
                        activeColor: const Color(0xFF0D3B66),
                        onChanged: (val) => setState(() => _opcaoData = val!),
                      ),
                      const Text(
                        'Ocultar Data',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: state.status == TextosStatus.loading
                      ? null
                      : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3B66),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: state.status == TextosStatus.loading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.save),
                  label: state.status == TextosStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Salvar Alterações',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0D3B66)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3B66),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildLabeledInput({
    required String label,
    required TextEditingController controller,
    String? hintText,
    double? width,
    IconData? icon,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? inputType,
  }) {
    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            padding: const EdgeInsets.only(left: 12, right: 12, top: 4),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller,
              inputFormatters: inputFormatters,
              keyboardType: inputType,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                prefixIcon: icon != null
                    ? Icon(icon, size: 18, color: Colors.grey)
                    : null,
                prefixIconConstraints: const BoxConstraints(minWidth: 30),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: -9,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0D3B66),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
