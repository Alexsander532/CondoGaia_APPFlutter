import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_documentos_cubit.dart';
import '../cubit/admin_documentos_state.dart';
import '../services/admin_documents_service.dart';
import '../widgets/document_upload_card.dart';
import '../../../../models/condominio.dart';
import 'admin_documentos_status_tab.dart';

class AdminDocumentosScreen extends StatelessWidget {
  const AdminDocumentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminDocumentosCubit(AdminDocumentsService())..loadCondominios(),
      child: const _AdminDocumentosView(),
    );
  }
}

class _AdminDocumentosView extends StatefulWidget {
  const _AdminDocumentosView();

  @override
  State<_AdminDocumentosView> createState() => _AdminDocumentosViewState();
}

class _AdminDocumentosViewState extends State<_AdminDocumentosView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Home/documentos',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        titleSpacing: 0,
      ),
      body: BlocConsumer<AdminDocumentosCubit, AdminDocumentosState>(
        listener: (context, state) {
          if (state is AdminDocumentosSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Documentos enviados com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            // Opcional: navegar de volta ou resetar
            // Navigator.pop(context);
          } else if (state is AdminDocumentosError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminDocumentosLoading &&
              state is! AdminDocumentosLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final cubit = context.read<AdminDocumentosCubit>();

          List<Condominio> condominios = [];
          Condominio? selectedCondominio;

          if (state is AdminDocumentosLoaded) {
            condominios = state.condominios;
            selectedCondominio = state.selectedCondominio;
          }

          return Column(
            children: [
              // Barra de navegação interna (Cadastrar / Status)
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Cadastrar'),
                    Tab(text: 'Status'),
                  ],
                ),
              ),

              // Conteúdo
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Aba Cadastrar
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Dropdown Condomínio
                          const Text(
                            'Nome do Condomínio',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Condominio>(
                                isExpanded: true,
                                value: selectedCondominio,
                                hint: const Text('Selecione um condomínio'),
                                items: condominios.map((Condominio condom) {
                                  return DropdownMenuItem<Condominio>(
                                    value: condom,
                                    child: Text(condom.nomeCondominio),
                                  );
                                }).toList(),
                                onChanged: (Condominio? newValue) {
                                  if (newValue != null) {
                                    cubit.selectCondominio(newValue);
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Documentos',
                            style: TextStyle(
                              color: Color(0xFF1976D2), // Azul padrão do app
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(color: Color(0xFF1976D2), thickness: 1),
                          const SizedBox(height: 16),

                          // Cards de Documentos
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DocumentUploadCard(
                                  title: 'Ata do síndico',
                                  selectedFile: state is AdminDocumentosLoaded
                                      ? state.ataFile
                                      : null,
                                  onFileSelected: (file) =>
                                      cubit.selectFile('ata', file),
                                  onFileRemoved: () => cubit.removeFile('ata'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DocumentUploadCard(
                                  title: 'CNH fren/ver...',
                                  selectedFile: state is AdminDocumentosLoaded
                                      ? state.cnhFile
                                      : null,
                                  onFileSelected: (file) =>
                                      cubit.selectFile('cnh', file),
                                  onFileRemoved: () => cubit.removeFile('cnh'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DocumentUploadCard(
                                  title: 'Selfie com CNH',
                                  selectedFile: state is AdminDocumentosLoaded
                                      ? state.selfieFile
                                      : null,
                                  onFileSelected: (file) =>
                                      cubit.selectFile('selfie', file),
                                  onFileRemoved: () =>
                                      cubit.removeFile('selfie'),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Botão Enviar
                          ElevatedButton(
                            onPressed: (state is AdminDocumentosLoading)
                                ? null
                                : () => cubit.submitDocuments(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF0D3B66,
                              ), // Azul escuro do botão
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: (state is AdminDocumentosLoading)
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'ENVIAR',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // Aba Status
                    const AdminDocumentosStatusTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
