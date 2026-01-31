import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/condominio.dart';
import '../models/documento_status_model.dart';
import '../services/admin_documents_service.dart';
import 'admin_documentos_state.dart';

class AdminDocumentosCubit extends Cubit<AdminDocumentosState> {
  final AdminDocumentsService _service;

  // Cache para lista original antes de filtros
  List<DocumentoStatusModel> _originalStatusList = [];

  AdminDocumentosCubit(this._service) : super(AdminDocumentosInitial());

  Future<void> loadCondominios() async {
    try {
      emit(AdminDocumentosLoading());
      final condominios = await _service.fetchCondominios();

      // Gerar lista de status baseada nos condomínios carregados
      _generateStatusFromCondominios(condominios);

      if (condominios.isEmpty) {
        // Se vazia, mantemos vazia ou sugerimos mocks se fosse dev
        emit(
          AdminDocumentosLoaded(
            condominios: [],
            statusList: _originalStatusList,
          ),
        );
      } else {
        emit(
          AdminDocumentosLoaded(
            condominios: condominios,
            statusList: _originalStatusList,
          ),
        );
      }
    } catch (e) {
      emit(AdminDocumentosError('Erro ao carregar condomínios: $e'));
    }
  }

  void _generateStatusFromCondominios(List<Condominio> condominios) {
    // Aqui simulamos o status para cada condomínio real trazido do banco
    // Em produção, isso viria de uma tabela 'documentos_status' ou similar

    _originalStatusList = condominios.asMap().entries.map((entry) {
      final index = entry.key;
      final condo = entry.value;

      // Simulação: Alternar status baseado no index
      StatusDocumento status;
      String? errorMsg;

      if (index % 3 == 0) {
        status = StatusDocumento.aprovado;
      } else if (index % 3 == 1) {
        status = StatusDocumento.pendente;
      } else {
        status = StatusDocumento.erro;
        errorMsg = 'Documento ilegível ou vencido';
      }

      return DocumentoStatusModel(
        id: condo.id, // Usando ID real do condomínio
        nome: condo.nomeCondominio,
        rgCnhCnpj: condo.cnpj,
        cidade: condo.cidade,
        uf: condo.estado,
        status: status,
        errorMessage: errorMsg,
        dataEnvio: DateTime.now().subtract(
          Duration(days: index * 2),
        ), // Datas variadas
      );
    }).toList();
  }

  void selectCondominio(Condominio condominio) {
    if (state is AdminDocumentosLoaded) {
      final currentState = state as AdminDocumentosLoaded;
      emit(currentState.copyWith(selectedCondominio: condominio));
    }
  }

  void selectFile(String fileType, File file) {
    if (state is AdminDocumentosLoaded) {
      final currentState = state as AdminDocumentosLoaded;

      switch (fileType) {
        case 'ata':
          emit(currentState.copyWith(ataFile: file));
          break;
        case 'cnh':
          emit(currentState.copyWith(cnhFile: file));
          break;
        case 'selfie':
          emit(currentState.copyWith(selfieFile: file));
          break;
      }
    }
  }

  void removeFile(String fileType) {
    if (state is AdminDocumentosLoaded) {
      final currentState = state as AdminDocumentosLoaded;

      File? newAta = currentState.ataFile;
      File? newCnh = currentState.cnhFile;
      File? newSelfie = currentState.selfieFile;

      switch (fileType) {
        case 'ata':
          newAta = null;
          break;
        case 'cnh':
          newCnh = null;
          break;
        case 'selfie':
          newSelfie = null;
          break;
      }

      emit(
        AdminDocumentosLoaded(
          condominios: currentState.condominios,
          selectedCondominio: currentState.selectedCondominio,
          ataFile: newAta,
          cnhFile: newCnh,
          selfieFile: newSelfie,
          statusList: currentState.statusList,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
          statusFilters: currentState.statusFilters,
        ),
      );
    }
  }

  Future<void> submitDocuments() async {
    if (state is! AdminDocumentosLoaded) return;

    final currentState = state as AdminDocumentosLoaded;

    if (currentState.selectedCondominio == null) {
      emit(const AdminDocumentosError('Selecione um condomínio'));
      emit(currentState);
      return;
    }

    try {
      emit(AdminDocumentosLoading());

      final files = <String, File>{};
      if (currentState.ataFile != null) files['ata'] = currentState.ataFile!;
      if (currentState.cnhFile != null) files['cnh'] = currentState.cnhFile!;
      if (currentState.selfieFile != null)
        files['selfie'] = currentState.selfieFile!;

      await _service.uploadDocuments(
        condominioId: currentState.selectedCondominio!.id,
        files: files,
      );

      emit(AdminDocumentosSuccess());
    } catch (e) {
      emit(AdminDocumentosError(e.toString()));
      emit(currentState);
    }
  }

  void reset() {
    loadCondominios();
  }

  // --- Status Tab Logic ---

  void updateDateRange(DateTime? start, DateTime? end) {
    if (state is AdminDocumentosLoaded) {
      final currentState = state as AdminDocumentosLoaded;
      emit(currentState.copyWith(startDate: start, endDate: end));
      _applyFilters();
    }
  }

  void toggleStatusFilter(StatusDocumento status, bool? value) {
    if (state is AdminDocumentosLoaded) {
      final currentState = state as AdminDocumentosLoaded;
      final newFilters = Map<StatusDocumento, bool>.from(
        currentState.statusFilters,
      );
      newFilters[status] = value ?? false;

      emit(currentState.copyWith(statusFilters: newFilters));
      _applyFilters();
    }
  }

  void toggleAllFilters(bool? value) {
    if (state is AdminDocumentosLoaded) {
      final currentState = state as AdminDocumentosLoaded;
      final newFilters = {
        StatusDocumento.aprovado: value ?? false,
        StatusDocumento.erro: value ?? false,
        StatusDocumento.pendente: value ?? false,
      };

      emit(currentState.copyWith(statusFilters: newFilters));
      _applyFilters();
    }
  }

  void _applyFilters() {
    if (state is AdminDocumentosLoaded) {
      final currentState = state as AdminDocumentosLoaded;

      List<DocumentoStatusModel> filtered = _originalStatusList;

      // Filter by Date
      if (currentState.startDate != null && currentState.endDate != null) {
        filtered = filtered.where((doc) {
          // Normalize to start of day for comparison
          return doc.dataEnvio.isAfter(
                currentState.startDate!.subtract(const Duration(days: 1)),
              ) &&
              doc.dataEnvio.isBefore(
                currentState.endDate!.add(const Duration(days: 1)),
              );
        }).toList();
      }

      // Filter by Status
      // If at least one filter is true, show only selected. If all are false, show all (or none? usually show all if no filter active, but design has specific checkboxes. Let's assume unchecked = hidden)
      // Actually common pattern: if "Todos" is used or individual checks.
      // Logic: If any checkbox is checked, show only those. If none checked, show all (or empty? Design shows checkboxes).
      // Let's implement: Only show if status is checked. EXCEPT if 'Todos' logic is handled by UI separately, generally we iterate over checked statuses.

      bool anyFilterActive = currentState.statusFilters.values.any((v) => v);
      if (anyFilterActive) {
        filtered = filtered.where((doc) {
          return currentState.statusFilters[doc.status] == true;
        }).toList();
      }

      emit(currentState.copyWith(statusList: filtered));
    }
  }
}
