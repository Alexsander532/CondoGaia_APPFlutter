import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../cubit/email_gestao_cubit.dart';
import '../cubit/email_gestao_state.dart';
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

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmailGestaoCubit(
        service: EmailGestaoService(),
        condominioId: widget.condominioId,
      )..loadRecipients(),
      child: Scaffold(
        backgroundColor: Colors.white, // White background
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
                'Home/Gestão/Email',
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
        body: BlocConsumer<EmailGestaoCubit, EmailGestaoState>(
          listener: (context, state) {
            if (state is EmailGestaoSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              _subjectController.clear();
              _bodyController.clear();
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
            if (state is EmailGestaoLoading && state is! EmailGestaoLoaded) {
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
                  // Topic Dropdown
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
                                    value:
                                        [
                                          'NOVO',
                                          'Cobrança',
                                          'Comunicado',
                                          'Assembleia',
                                        ].contains(state.selectedTopic)
                                        ? state.selectedTopic
                                        : 'NOVO', // Safe fallback or update state init logic if needed
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    items:
                                        [
                                          'NOVO',
                                          'Cobrança',
                                          'Comunicado',
                                          'Assembleia',
                                          'Advertência(gravado no relatorio unid)',
                                          'Multa(gravado no relatorio unid)',
                                          'Convite Perfil',
                                          'Termo C. D. (acordo)',
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
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
                  const SizedBox(height: 16),

                  // Assunto Input
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        // Using prefixIcon to force left alignment
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

                  // Body Input
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: TextField(
                      controller: _bodyController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        // For multiline, we put the label as prefix text?
                        // "prefix" widget aligns well with baseline usually.
                        prefix: Text(
                          'Texto: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tags info
                  const Wrap(
                    spacing: 8,
                    children: [
                      Text(
                        '#unid #condominio #proprietario #data',
                        style: TextStyle(
                          color: Color(0xFF0D3B66),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          'VER',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        backgroundColor: Color(0xFF0D3B66),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Buttons Row
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          elevation: 0,
                        ),
                        child: const Text('SALVAR MODELO'),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles();
                          if (result != null &&
                              result.files.single.path != null) {
                            cubit.attachFile(File(result.files.single.path!));
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
                              state.attachedFile != null
                                  ? 'Anexo selecionado'
                                  : 'Anexar foto',
                              style: const TextStyle(
                                color: Color(0xFF0D3B66),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            if (state.attachedFile != null)
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                onPressed: () => cubit.removeAttachment(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Recipient Filter
                  const Text(
                    'Enviar para',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => cubit.updateFilterText(val),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar unidade/bloco ou nome',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ), // Visible border
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: state.recipientFilterType,
                        isExpanded: true,
                        items: ['TODOS', 'PROPRIETARIOS', 'INQUILINOS'].map((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) cubit.updateRecipientFilterType(val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Generate Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Action for "Gerar"? Maybe preview list?
                        // For now just refresh filters which is already done.
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Gerar',
                        style: TextStyle(color: Colors.white),
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
                        icon: const Icon(Icons.share, color: Color(0xFF0D3B66)),
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
                          ? const CircularProgressIndicator(color: Colors.white)
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
}
