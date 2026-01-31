import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../../models/condominio.dart';
import '../models/documento_status_model.dart';

abstract class AdminDocumentosState extends Equatable {
  const AdminDocumentosState();

  @override
  List<Object?> get props => [];
}

class AdminDocumentosInitial extends AdminDocumentosState {}

class AdminDocumentosLoading extends AdminDocumentosState {}

class AdminDocumentosLoaded extends AdminDocumentosState {
  final List<Condominio> condominios;
  final Condominio? selectedCondominio;
  final File? ataFile;
  final File? cnhFile;
  final File? selfieFile;

  // Status Tab Fields
  final List<DocumentoStatusModel> statusList;
  final DateTime? startDate;
  final DateTime? endDate;
  final Map<StatusDocumento, bool> statusFilters;

  const AdminDocumentosLoaded({
    this.condominios = const [],
    this.selectedCondominio,
    this.ataFile,
    this.cnhFile,
    this.selfieFile,
    this.statusList = const [],
    this.startDate,
    this.endDate,
    this.statusFilters = const {
      StatusDocumento.aprovado: false,
      StatusDocumento.erro: false,
      StatusDocumento.pendente: false,
    },
  });

  AdminDocumentosLoaded copyWith({
    List<Condominio>? condominios,
    Condominio? selectedCondominio,
    File? ataFile,
    File? cnhFile,
    File? selfieFile,
    List<DocumentoStatusModel>? statusList,
    DateTime? startDate,
    DateTime? endDate,
    Map<StatusDocumento, bool>? statusFilters,
  }) {
    return AdminDocumentosLoaded(
      condominios: condominios ?? this.condominios,
      selectedCondominio: selectedCondominio ?? this.selectedCondominio,
      ataFile: ataFile ?? this.ataFile,
      cnhFile: cnhFile ?? this.cnhFile,
      selfieFile: selfieFile ?? this.selfieFile,
      statusList: statusList ?? this.statusList,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      statusFilters: statusFilters ?? this.statusFilters,
    );
  }

  @override
  List<Object?> get props => [
    condominios,
    selectedCondominio,
    ataFile,
    cnhFile,
    selfieFile,
    statusList,
    startDate,
    endDate,
    statusFilters,
  ];
}

class AdminDocumentosSuccess extends AdminDocumentosState {}

class AdminDocumentosError extends AdminDocumentosState {
  final String message;

  const AdminDocumentosError(this.message);

  @override
  List<Object?> get props => [message];
}
