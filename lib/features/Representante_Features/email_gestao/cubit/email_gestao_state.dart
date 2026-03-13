import 'package:equatable/equatable.dart';
import '../models/recipient_model.dart';
import '../models/email_modelo_model.dart';
import '../models/email_attachment_model.dart';

abstract class EmailGestaoState extends Equatable {
  const EmailGestaoState();

  @override
  List<Object?> get props => [];
}

class EmailGestaoInitial extends EmailGestaoState {}

class EmailGestaoLoading extends EmailGestaoState {}

class EmailGestaoLoaded extends EmailGestaoState {
  final List<RecipientModel> allRecipients;
  final List<RecipientModel> filteredRecipients;
  final String selectedTopic;
  final String? filterText;
  final String recipientFilterType; // 'TODOS', 'PROPRIETARIOS', 'INQUILINOS'

  /// Modelos de email salvos (filtrados pelo tópico selecionado)
  final List<EmailModeloModel> modelos;

  /// Modelo atualmente selecionado (preenche assunto e corpo)
  final EmailModeloModel? modeloSelecionado;

  /// Anexo de imagem (cross-platform: Uint8List, não dart:io File)
  final EmailAttachmentModel? attachment;

  final bool isSending;
  final bool isSavingModelo;
  final int page;
  final bool hasReachedMax;

  const EmailGestaoLoaded({
    required this.allRecipients,
    required this.filteredRecipients,
    this.selectedTopic = 'Cobrança',
    this.filterText,
    this.recipientFilterType = 'TODOS',
    this.modelos = const [],
    this.modeloSelecionado,
    this.attachment,
    this.isSending = false,
    this.isSavingModelo = false,
    this.page = 1,
    this.hasReachedMax = false,
  });

  EmailGestaoLoaded copyWith({
    List<RecipientModel>? allRecipients,
    List<RecipientModel>? filteredRecipients,
    String? selectedTopic,
    String? filterText,
    String? recipientFilterType,
    List<EmailModeloModel>? modelos,
    // Use Object() sentinel to allow explicit null
    Object? modeloSelecionado = _keep,
    Object? attachment = _keep,
    bool? isSending,
    bool? isSavingModelo,
    int? page,
    bool? hasReachedMax,
  }) {
    return EmailGestaoLoaded(
      allRecipients: allRecipients ?? this.allRecipients,
      filteredRecipients: filteredRecipients ?? this.filteredRecipients,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      filterText: filterText ?? this.filterText,
      recipientFilterType: recipientFilterType ?? this.recipientFilterType,
      modelos: modelos ?? this.modelos,
      modeloSelecionado: modeloSelecionado == _keep
          ? this.modeloSelecionado
          : modeloSelecionado as EmailModeloModel?,
      attachment: attachment == _keep
          ? this.attachment
          : attachment as EmailAttachmentModel?,
      isSending: isSending ?? this.isSending,
      isSavingModelo: isSavingModelo ?? this.isSavingModelo,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
    allRecipients,
    filteredRecipients,
    selectedTopic,
    filterText,
    recipientFilterType,
    modelos,
    modeloSelecionado,
    attachment,
    isSending,
    isSavingModelo,
    page,
    hasReachedMax,
  ];
}

// Sentinel para distinguir "não passado" de "passado como null"
const Object _keep = Object();

class EmailGestaoSuccess extends EmailGestaoState {
  final String message;
  const EmailGestaoSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class EmailGestaoError extends EmailGestaoState {
  final String message;
  const EmailGestaoError(this.message);
  @override
  List<Object?> get props => [message];
}
