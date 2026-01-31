import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/recipient_model.dart';
import '../services/email_gestao_service.dart';
import 'email_gestao_state.dart';

class EmailGestaoCubit extends Cubit<EmailGestaoState> {
  final EmailGestaoService _service;
  final String condominioId;

  EmailGestaoCubit({
    required EmailGestaoService service,
    required this.condominioId,
  }) : _service = service,
       super(EmailGestaoInitial());

  Future<void> loadRecipients() async {
    try {
      emit(EmailGestaoLoading());
      final recipients = await _service.fetchRecipients(condominioId);
      emit(
        EmailGestaoLoaded(
          allRecipients: recipients,
          filteredRecipients: recipients,
        ),
      );
    } catch (e) {
      emit(EmailGestaoError('Erro ao carregar destinatários: $e'));
    }
  }

  void updateTopic(String topic) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      emit(currentState.copyWith(selectedTopic: topic));
    }
  }

  void attachFile(File file) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      emit(currentState.copyWith(attachedFile: file));
    }
  }

  void removeAttachment() {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      // We pass null properly, but copyWith needs to handle nullable value if not distinct from 'undefined'
      // Since my simple copyWith uses ??, I can't pass null to clear it if the field is nullable.
      // I will recreate the state to be safe or update copyWith logic.
      // Actually, standard copyWith usually ignores null.
      // Let's implement a specific copyWith logic or just re-emit.
      emit(
        EmailGestaoLoaded(
          allRecipients: currentState.allRecipients,
          filteredRecipients: currentState.filteredRecipients,
          selectedTopic: currentState.selectedTopic,
          filterText: currentState.filterText,
          recipientFilterType: currentState.recipientFilterType,
          attachedFile: null, // Explicitly null
          isSending: currentState.isSending,
        ),
      );
    }
  }

  void updateFilterText(String text) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      emit(currentState.copyWith(filterText: text));
      _applyFilters();
    }
  }

  void updateRecipientFilterType(String type) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      emit(currentState.copyWith(recipientFilterType: type));
      _applyFilters();
    }
  }

  void toggleRecipientSelection(String id, bool isSelected) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;

      final updatedAllRecipients = currentState.allRecipients.map((r) {
        if (r.id == id) {
          return r.copyWith(isSelected: isSelected);
        }
        return r;
      }).toList();

      // We modify allRecipients, then apply filters again to update filtered list state
      emit(currentState.copyWith(allRecipients: updatedAllRecipients));
      _applyFilters();
    }
  }

  void toggleAllSelection(bool isSelected) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;

      // Select/Deselect ONLY visible filtered items OR all items?
      // Usually "Select All" affects the visible list.
      // If I select all, I expect visible items to be checked.

      // Let's update ALL recipients based on filter matches?
      // Or just update the displayed ones in the 'allRecipients' list.

      final visibleIds = currentState.filteredRecipients
          .map((e) => e.id)
          .toSet();

      final updatedAllRecipients = currentState.allRecipients.map((r) {
        if (visibleIds.contains(r.id)) {
          return r.copyWith(isSelected: isSelected);
        }
        return r;
      }).toList();

      emit(currentState.copyWith(allRecipients: updatedAllRecipients));
      _applyFilters();
    }
  }

  void _applyFilters() {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;

      List<RecipientModel> filtered = currentState.allRecipients;

      // Filter by Type
      if (currentState.recipientFilterType == 'PROPRIETARIOS') {
        filtered = filtered.where((r) => r.type == 'P').toList();
      } else if (currentState.recipientFilterType == 'INQUILINOS') {
        filtered = filtered
            .where((r) => r.type == 'I' || r.type == 'T')
            .toList(); // Assuming T=Tenant, I=Inquilino? Image shows T/P/I.
      }

      // Filter by Text (Name or Unit)
      if (currentState.filterText != null &&
          currentState.filterText!.isNotEmpty) {
        final query = currentState.filterText!.toLowerCase();
        filtered = filtered.where((r) {
          return r.name.toLowerCase().contains(query) ||
              r.unitBlock.toLowerCase().contains(query);
        }).toList();
      }

      emit(currentState.copyWith(filteredRecipients: filtered));
    }
  }

  Future<void> sendEmail({
    required String subject,
    required String body,
  }) async {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;

      final selectedRecipients = currentState.allRecipients
          .where((r) => r.isSelected)
          .toList();

      if (selectedRecipients.isEmpty) {
        // Warning: no recipient selected
        // We can emit a side-effect or just ignore.
        // Ideally we shouldn't fail silently effectively.
        // For now, I'll allow treating this as error state transiently or handling in UI
        return;
      }

      emit(currentState.copyWith(isSending: true));

      try {
        await _service.sendEmail(
          subject: subject,
          body: body,
          topic: currentState.selectedTopic,
          recipients: selectedRecipients,
          attachment: currentState.attachedFile,
        );
        emit(const EmailGestaoSuccess('E-mail enviado com sucesso!'));

        // Return to Loaded state after success?
        // Usually we'd pop or reset.
        // Let's reload to reset selection
        loadRecipients();
      } catch (e) {
        emit(EmailGestaoError('Falha ao enviar e-mail: $e'));
        // Restore loaded state?
        // emit(currentState.copyWith(isSending: false));
      }
    }
  }
}
