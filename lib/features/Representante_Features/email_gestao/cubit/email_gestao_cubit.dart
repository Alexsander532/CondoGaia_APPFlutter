import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/recipient_model.dart';
import '../services/email_gestao_service.dart';
import 'email_gestao_state.dart';

class EmailGestaoCubit extends Cubit<EmailGestaoState> {
  final EmailGestaoService _service;
  final String condominioId;
  static const int _limit = 10;

  EmailGestaoCubit({
    required EmailGestaoService service,
    required this.condominioId,
  }) : _service = service,
       super(EmailGestaoInitial());

  Future<void> loadRecipients({bool refresh = false}) async {
    try {
      if (refresh || state is EmailGestaoInitial) {
        emit(EmailGestaoLoading());
      }

      // Fetch ALL recipients at once
      final recipients = await _service.fetchRecipients(
        condominioId: condominioId,
      );

      emit(
        EmailGestaoLoaded(
          allRecipients: recipients,
          filteredRecipients: [], // Will be populated by _applyFilters
          page: 1,
        ),
      );

      _applyFilters();
    } catch (e) {
      emit(EmailGestaoError('Erro ao carregar destinatários: $e'));
    }
  }

  void loadMoreRecipients() {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      if (currentState.hasReachedMax) return;

      emit(currentState.copyWith(page: currentState.page + 1));
      _applyFilters();
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
      emit(currentState.copyWith(attachedFile: null));
    }
  }

  void updateFilterText(String text) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      emit(
        currentState.copyWith(filterText: text, page: 1),
      ); // Reset page on filter change
      _applyFilters();
    }
  }

  void updateRecipientFilterType(String type) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      emit(
        currentState.copyWith(recipientFilterType: type, page: 1),
      ); // Reset page on filter change
      _applyFilters();
    }
  }

  void toggleRecipientSelection(String id, bool isSelected) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;

      // Update in the master list
      final updatedAllRecipients = currentState.allRecipients.map((r) {
        if (r.id == id) {
          return r.copyWith(isSelected: isSelected);
        }
        return r;
      }).toList();

      emit(currentState.copyWith(allRecipients: updatedAllRecipients));
      _applyFilters();
    }
  }

  void toggleAllSelection(bool isSelected) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;

      // We only select the CURRENTLY VISIBLE recipients
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

      // 1. Filter by Type
      if (currentState.recipientFilterType == 'PROPRIETARIOS') {
        filtered = filtered.where((r) => r.type == 'P').toList();
      } else if (currentState.recipientFilterType == 'INQUILINOS') {
        filtered = filtered
            .where((r) => r.type == 'I' || r.type == 'T')
            .toList();
      }

      // 2. Filter by Search Text (Name or Unit)
      if (currentState.filterText != null &&
          currentState.filterText!.isNotEmpty) {
        final query = currentState.filterText!.toLowerCase();
        filtered = filtered.where((r) {
          return r.name.toLowerCase().contains(query) ||
              r.unitBlock.toLowerCase().contains(query);
        }).toList();
      }

      // 3. Apply Pagination (Slicing)
      final totalMatches = filtered.length;
      final limit = currentState.page * _limit;
      final hasReachedMax = limit >= totalMatches;

      final displayedRecipients = filtered.take(limit).toList();

      emit(
        currentState.copyWith(
          filteredRecipients: displayedRecipients,
          hasReachedMax: hasReachedMax,
        ),
      );
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

        // Reset
        loadRecipients(refresh: true);
      } catch (e) {
        emit(EmailGestaoError('Falha ao enviar e-mail: $e'));
      }
    }
  }
}
