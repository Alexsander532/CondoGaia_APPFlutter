import 'dart:io';
import 'package:equatable/equatable.dart';
import '../models/recipient_model.dart';

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
  final File? attachedFile;
  final bool isSending;
  final int page;
  final bool hasReachedMax;

  const EmailGestaoLoaded({
    required this.allRecipients,
    required this.filteredRecipients,
    this.selectedTopic = 'NOVO',
    this.filterText,
    this.recipientFilterType = 'TODOS',
    this.attachedFile,
    this.isSending = false,
    this.page = 1,
    this.hasReachedMax = false,
  });

  EmailGestaoLoaded copyWith({
    List<RecipientModel>? allRecipients,
    List<RecipientModel>? filteredRecipients,
    String? selectedTopic,
    String? filterText,
    String? recipientFilterType,
    File? attachedFile,
    bool? isSending,
    int? page,
    bool? hasReachedMax,
  }) {
    return EmailGestaoLoaded(
      allRecipients: allRecipients ?? this.allRecipients,
      filteredRecipients: filteredRecipients ?? this.filteredRecipients,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      filterText: filterText ?? this.filterText,
      recipientFilterType: recipientFilterType ?? this.recipientFilterType,
      attachedFile: attachedFile ?? this.attachedFile,
      isSending: isSending ?? this.isSending,
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
    attachedFile,
    isSending,
    page,
    hasReachedMax,
  ];
}

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
