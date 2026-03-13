import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/recipient_model.dart';
import '../models/email_modelo_model.dart';
import '../models/email_attachment_model.dart';
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

  // ─────────────────────────────────────────────────────────
  //  Recipients
  // ─────────────────────────────────────────────────────────

  Future<void> loadRecipients({bool refresh = false}) async {
    try {
      if (refresh || state is EmailGestaoInitial) {
        emit(EmailGestaoLoading());
      }

      final recipients = await _service.fetchRecipients(
        condominioId: condominioId,
      );

      emit(
        EmailGestaoLoaded(
          allRecipients: recipients,
          filteredRecipients: [],
          page: 1,
        ),
      );

      _applyFilters();

      // Carregar modelos do tópico padrão ('Cobrança')
      await carregarModelos(topico: 'Cobrança');
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
      // Ao mudar tópico, limpar modelo selecionado e recarregar modelos
      emit(currentState.copyWith(
        selectedTopic: topic,
        modeloSelecionado: null,
      ));
      carregarModelos(topico: topic);
    }
  }

  void updateFilterText(String text) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      emit(currentState.copyWith(filterText: text, page: 1));
      _applyFilters();
    }
  }

  void updateRecipientFilterType(String type) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      emit(currentState.copyWith(recipientFilterType: type, page: 1));
      _applyFilters();
    }
  }

  void toggleRecipientSelection(String id, bool isSelected) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      final updated = currentState.allRecipients.map((r) {
        return r.id == id ? r.copyWith(isSelected: isSelected) : r;
      }).toList();
      emit(currentState.copyWith(allRecipients: updated));
      _applyFilters();
    }
  }

  void toggleAllSelection(bool isSelected) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      final visibleIds = currentState.filteredRecipients.map((e) => e.id).toSet();
      final updated = currentState.allRecipients.map((r) {
        return visibleIds.contains(r.id) ? r.copyWith(isSelected: isSelected) : r;
      }).toList();
      emit(currentState.copyWith(allRecipients: updated));
      _applyFilters();
    }
  }

  void _applyFilters() {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      List<RecipientModel> filtered = currentState.allRecipients;

      if (currentState.recipientFilterType == 'PROPRIETARIOS') {
        filtered = filtered.where((r) => r.type == 'P').toList();
      } else if (currentState.recipientFilterType == 'INQUILINOS') {
        filtered = filtered.where((r) => r.type == 'I' || r.type == 'T').toList();
      }

      if (currentState.filterText != null && currentState.filterText!.isNotEmpty) {
        final query = currentState.filterText!.toLowerCase();
        filtered = filtered.where((r) {
          return r.name.toLowerCase().contains(query) ||
              r.unitBlock.toLowerCase().contains(query);
        }).toList();
      }

      final totalMatches = filtered.length;
      final limit = currentState.page * _limit;
      final hasReachedMax = limit >= totalMatches;

      emit(currentState.copyWith(
        filteredRecipients: filtered.take(limit).toList(),
        hasReachedMax: hasReachedMax,
      ));
    }
  }

  // ─────────────────────────────────────────────────────────
  //  Attachment (cross-platform: Uint8List, não dart:io File)
  // ─────────────────────────────────────────────────────────

  void attachBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      final attachment = EmailAttachmentModel(
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
        sizeBytes: bytes.length,
      );

      if (!attachment.isValidSize) {
        emit(EmailGestaoError(
          'Arquivo muito grande: ${attachment.sizeFormatted}. Máximo permitido: 5MB.',
        ));
        // Restaura estado anterior
        emit(currentState);
        return;
      }

      emit(currentState.copyWith(attachment: attachment));
    }
  }

  void removeAttachment() {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      emit(currentState.copyWith(attachment: null));
    }
  }

  // ─────────────────────────────────────────────────────────
  //  Modelos de Email (CRUD via Supabase)
  // ─────────────────────────────────────────────────────────

  Future<void> carregarModelos({String? topico}) async {
    if (state is! EmailGestaoLoaded) return;
    final currentState = state as EmailGestaoLoaded;
    final topicoFiltro = topico ?? currentState.selectedTopic;

    try {
      final modelos = await _service.fetchModelos(
        condominioId: condominioId,
        topico: topicoFiltro,
      );
      emit(currentState.copyWith(modelos: modelos));
    } catch (_) {
      // Silently ignore — modelos are optional
    }
  }

  void selecionarModelo(EmailModeloModel modelo) {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      emit(currentState.copyWith(modeloSelecionado: modelo));
    }
  }

  void limparModeloSelecionado() {
    if (state is EmailGestaoLoaded) {
      final currentState = state as EmailGestaoLoaded;
      emit(currentState.copyWith(modeloSelecionado: null));
    }
  }

  Future<void> salvarModelo({
    required String titulo,
    required String assunto,
    required String corpo,
  }) async {
    if (state is! EmailGestaoLoaded) return;
    final currentState = state as EmailGestaoLoaded;

    if (titulo.trim().isEmpty || assunto.trim().isEmpty || corpo.trim().isEmpty) {
      emit(EmailGestaoError('Preencha título, assunto e corpo antes de salvar.'));
      emit(currentState);
      return;
    }

    emit(currentState.copyWith(isSavingModelo: true));

    try {
      await _service.salvarModelo(
        condominioId: condominioId,
        topico: currentState.selectedTopic,
        titulo: titulo.trim(),
        assunto: assunto.trim(),
        corpo: corpo.trim(),
      );

      // Recarregar lista de modelos
      final modelos = await _service.fetchModelos(
        condominioId: condominioId,
        topico: currentState.selectedTopic,
      );

      emit(currentState.copyWith(
        isSavingModelo: false,
        modelos: modelos,
      ));

      emit(const EmailGestaoSuccess('Modelo salvo com sucesso!'));
      emit(currentState.copyWith(modelos: modelos, isSavingModelo: false));
    } catch (e) {
      emit(EmailGestaoError('Erro ao salvar modelo: $e'));
      emit(currentState.copyWith(isSavingModelo: false));
    }
  }

  Future<void> excluirModelo(String modeloId) async {
    if (state is! EmailGestaoLoaded) return;
    final currentState = state as EmailGestaoLoaded;

    try {
      await _service.excluirModelo(modeloId);

      final modelos = currentState.modelos.where((m) => m.id != modeloId).toList();
      final modeloAtual = currentState.modeloSelecionado?.id == modeloId
          ? null
          : currentState.modeloSelecionado;

      emit(currentState.copyWith(
        modelos: modelos,
        modeloSelecionado: modeloAtual,
      ));
    } catch (e) {
      emit(EmailGestaoError('Erro ao excluir modelo: $e'));
      emit(currentState);
    }
  }

  // ─────────────────────────────────────────────────────────
  //  Send
  // ─────────────────────────────────────────────────────────

  Future<void> sendEmail({
    required String subject,
    required String body,
  }) async {
    if (state is! EmailGestaoLoaded) return;
    final currentState = state as EmailGestaoLoaded;

    final selectedRecipients = currentState.allRecipients
        .where((r) => r.isSelected)
        .toList();

    if (selectedRecipients.isEmpty) return;

    emit(currentState.copyWith(isSending: true));

    try {
      await _service.sendEmail(
        subject: subject,
        body: body,
        topic: currentState.selectedTopic,
        recipients: selectedRecipients,
        attachment: currentState.attachment,
      );
      emit(const EmailGestaoSuccess('E-mail enviado com sucesso!'));
      loadRecipients(refresh: true);
    } catch (e) {
      emit(EmailGestaoError('Falha ao enviar e-mail: $e'));
    }
  }
}
