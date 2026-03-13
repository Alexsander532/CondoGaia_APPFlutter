import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '../cubit/email_gestao_cubit.dart';
import '../cubit/email_gestao_state.dart';
import '../models/email_modelo_model.dart';
import '../services/email_gestao_service.dart';
import '../widgets/recipient_table_widget.dart';

class EmailGestaoScreen extends StatefulWidget {
  final String condominioId;

  const EmailGestaoScreen({super.key, required this.condominioId});

  @override
  State<EmailGestaoScreen> createState() => _EmailGestaoScreenState();
}

class _EmailGestaoScreenState extends State<EmailGestaoScreen> {
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  final _searchController = TextEditingController();

  final List<String> _topicos = [
    'Cobrança',
    'Comunicado',
    'Assembleia',
    'Advertência(gravado no relatorio unid)',
    'Multa(gravado no relatorio unid)',
    'Convite Perfil',
    'Termo C. D. (acordo)',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── SALVAR MODELO: exibe diálogo para nomear o modelo ──

  void _mostrarDialogSalvarModelo(EmailGestaoCubit cubit) {
    final tituloController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salvar Modelo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dê um nome para identificar este modelo:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tituloController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Ex: Circular de Manutenção',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3B66),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              cubit.salvarModelo(
                titulo: tituloController.text.trim(),
                assunto: _subjectController.text.trim(),
                corpo: _bodyController.text.trim(),
              );
            },
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── EXCLUIR MODELO: confirmação ──

  void _confirmarExclusaoModelo(
    EmailGestaoCubit cubit,
    EmailModeloModel modelo,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Modelo'),
        content: Text(
          'Tem certeza que deseja excluir o modelo "${modelo.titulo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              cubit.excluirModelo(modelo.id);
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── SELECIONAR MODELO: preenche campos automaticamente ──

  void _aoSelecionarModelo(
    EmailGestaoCubit cubit,
    EmailModeloModel? modelo,
  ) {
    if (modelo == null) {
      cubit.limparModeloSelecionado();
      _subjectController.clear();
      _bodyController.clear();
    } else {
      cubit.selecionarModelo(modelo);
      _subjectController.text = modelo.assunto;
      _bodyController.text = modelo.corpo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmailGestaoCubit(
        service: EmailGestaoService(),
        condominioId: widget.condominioId,
      )..loadRecipients(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          title: Column(
            children: [
              Image.asset('assets/images/logo_CondoGaia.png', height: 30),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Image.asset(
                'assets/images/Sino_Notificacao.png',
                width: 24,
                height: 24,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Image.asset(
                'assets/images/Fone_Ouvido_Cabecalho.png',
                width: 24,
                height: 24,
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Expanded(
                        child: Text(
                          'Home/Gestão/Email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
                Container(color: Colors.grey.shade300, height: 1.0),
              ],
            ),
          ),
        ),
        body: BlocConsumer<EmailGestaoCubit, EmailGestaoState>(
          listener: (context, state) {
            if (state is EmailGestaoSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              // Limpar campos somente após envio de email, não após salvar modelo
              if (state.message.contains('enviado')) {
                _subjectController.clear();
                _bodyController.clear();
              }
            } else if (state is EmailGestaoError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if ((state is EmailGestaoLoading || state is EmailGestaoInitial) &&
                state is! EmailGestaoLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is! EmailGestaoLoaded) {
              return const Center(child: Text('Algo deu errado'));
            }

            final cubit = context.read<EmailGestaoCubit>();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Tópico Dropdown ──
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Tópico: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _topicos.contains(state.selectedTopic)
                                        ? state.selectedTopic
                                        : _topicos.first,
                                    isExpanded: true,
                                    icon:
                                        const Icon(Icons.keyboard_arrow_down),
                                    items: _topicos.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) cubit.updateTopic(val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.delete_outline, color: Colors.red),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Dropdown de Modelos Salvos ──
                  if (state.modelos.isNotEmpty) ...[
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF0D3B66).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bookmark_outlined,
                            color: Color(0xFF0D3B66),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Modelo: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF0D3B66),
                            ),
                          ),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<EmailModeloModel?>(
                                value: state.modeloSelecionado,
                                isExpanded: true,
                                hint: const Text(
                                  'Selecionar modelo salvo...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFF0D3B66),
                                ),
                                items: [
                                  const DropdownMenuItem<EmailModeloModel?>(
                                    value: null,
                                    child: Text(
                                      '-- Nenhum --',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  ...state.modelos.map((m) {
                                    return DropdownMenuItem<EmailModeloModel?>(
                                      value: m,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              m.titulo,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                              _confirmarExclusaoModelo(
                                                cubit,
                                                m,
                                              );
                                            },
                                            child: const Icon(
                                              Icons.delete_outline,
                                              size: 16,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (modelo) =>
                                    _aoSelecionarModelo(cubit, modelo),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Assunto Input ──
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: TextField(
                      controller: _subjectController,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Assunto:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Body Input ──
                  Container(
                    height: 150,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Texto: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _bodyController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tags info
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: const Text(
                          'VER',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        backgroundColor: const Color(0xFF0D3B66),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Botões: SALVAR MODELO + Anexar foto ──
                  Row(
                    children: [
                      // SALVAR MODELO
                      ElevatedButton.icon(
                        onPressed: state.isSavingModelo
                            ? null
                            : () => _mostrarDialogSalvarModelo(cubit),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          elevation: 0,
                        ),
                        icon: state.isSavingModelo
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined, size: 16),
                        label: const Text(
                          'SALVAR MODELO',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const Spacer(),

                      // Anexar foto
                      GestureDetector(
                        onTap: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            withData: true, // garante bytes para web + mobile
                          );
                          if (result != null &&
                              result.files.single.bytes != null) {
                            final file = result.files.single;
                            cubit.attachBytes(
                              bytes: file.bytes!,
                              filename: file.name,
                              mimeType: _mimeFromExtension(
                                file.extension ?? 'jpg',
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              color: Color(0xFF0D3B66),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              state.attachment != null
                                  ? state.attachment!.filename
                                  : 'Anexar foto',
                              style: const TextStyle(
                                color: Color(0xFF0D3B66),
                                decoration: TextDecoration.underline,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (state.attachment != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(${state.attachment!.sizeFormatted})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => cubit.removeAttachment(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Preview da imagem anexada
                  if (state.attachment != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        state.attachment!.bytes,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // ── Enviar para ──
                  const Text(
                    'Enviar para',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => cubit.updateFilterText(val),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar unidade/bloco ou nome',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.blue.shade900,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.blue.shade900,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.blue.shade900,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Dropdown
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border:
                                Border.all(color: Colors.grey.shade400),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: state.recipientFilterType,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: [
                                'TODOS',
                                'PROPRIETARIOS',
                                'INQUILINOS',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style:
                                        const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  cubit.updateRecipientFilterType(val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Gerar button
                  Center(
                    child: SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          cubit.updateFilterText(_searchController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Gerar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recipients Table
                  RecipientTableWidget(
                    recipients: state.filteredRecipients,
                    isAllSelected:
                        state.filteredRecipients.isNotEmpty &&
                        state.filteredRecipients.every((r) => r.isSelected),
                    onSelectAll: (val) => cubit.toggleAllSelection(val),
                    onSelectionChanged: (id, val) =>
                        cubit.toggleRecipientSelection(id, val),
                  ),

                  if (!state.hasReachedMax)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Center(
                        child: TextButton(
                          onPressed: () => cubit.loadMoreRecipients(),
                          child: const Text('Carregar mais'),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Bottom Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D3B66),
                        ),
                        child: const Text(
                          'Gerar PDF',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D3B66),
                        ),
                        child: const Text(
                          'Visualizar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.share,
                          color: Color(0xFF0D3B66),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Send Email Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isSending
                          ? null
                          : () {
                              cubit.sendEmail(
                                subject: _subjectController.text,
                                body: _bodyController.text,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B66),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: state.isSending
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Enviar E-mail',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _mimeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg';
    }
  }
}
