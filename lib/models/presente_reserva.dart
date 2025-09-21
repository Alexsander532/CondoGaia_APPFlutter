import 'package:flutter/material.dart';

class PresenteReserva {
  final String id;
  final String reservaId;
  final String nomePresente;
  final int ordem; // Para manter a ordem na lista
  final DateTime createdAt;
  final DateTime updatedAt;

  const PresenteReserva({
    required this.id,
    required this.reservaId,
    required this.nomePresente,
    required this.ordem,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor para criar a partir de JSON
  factory PresenteReserva.fromJson(Map<String, dynamic> json) {
    return PresenteReserva(
      id: json['id'] ?? '',
      reservaId: json['reserva_id'] ?? '',
      nomePresente: json['nome_presente'] ?? '',
      ordem: json['ordem'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reserva_id': reservaId,
      'nome_presente': nomePresente,
      'ordem': ordem,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Método para criar uma cópia com alterações
  PresenteReserva copyWith({
    String? id,
    String? reservaId,
    String? nomePresente,
    int? ordem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PresenteReserva(
      id: id ?? this.id,
      reservaId: reservaId ?? this.reservaId,
      nomePresente: nomePresente ?? this.nomePresente,
      ordem: ordem ?? this.ordem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Método para validação
  bool isValid() {
    return nomePresente.trim().isNotEmpty && reservaId.isNotEmpty;
  }

  // Método para formatação de exibição
  String get displayName {
    return '${ordem + 1}. $nomePresente';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PresenteReserva &&
        other.id == id &&
        other.reservaId == reservaId &&
        other.nomePresente == nomePresente &&
        other.ordem == ordem;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        reservaId.hashCode ^
        nomePresente.hashCode ^
        ordem.hashCode;
  }

  @override
  String toString() {
    return 'PresenteReserva(id: $id, reservaId: $reservaId, nomePresente: $nomePresente, ordem: $ordem)';
  }
}

// Classe para gerenciar a lista de presentes
class ListaPresentesReserva {
  final List<PresenteReserva> presentes;

  const ListaPresentesReserva({
    this.presentes = const [],
  });

  // Adicionar presente
  ListaPresentesReserva adicionarPresente(PresenteReserva presente) {
    final novosPresentes = List<PresenteReserva>.from(presentes);
    novosPresentes.add(presente);
    return ListaPresentesReserva(presentes: novosPresentes);
  }

  // Remover presente
  ListaPresentesReserva removerPresente(String presenteId) {
    final novosPresentes = presentes.where((p) => p.id != presenteId).toList();
    return ListaPresentesReserva(presentes: novosPresentes);
  }

  // Atualizar presente
  ListaPresentesReserva atualizarPresente(PresenteReserva presente) {
    final novosPresentes = presentes.map((p) {
      return p.id == presente.id ? presente : p;
    }).toList();
    return ListaPresentesReserva(presentes: novosPresentes);
  }

  // Reordenar presentes
  ListaPresentesReserva reordenarPresentes() {
    final presentesOrdenados = List<PresenteReserva>.from(presentes);
    presentesOrdenados.sort((a, b) => a.ordem.compareTo(b.ordem));
    
    final novosPresentes = <PresenteReserva>[];
    for (int i = 0; i < presentesOrdenados.length; i++) {
      novosPresentes.add(presentesOrdenados[i].copyWith(ordem: i));
    }
    
    return ListaPresentesReserva(presentes: novosPresentes);
  }

  // Converter para lista de strings (para compatibilidade)
  List<String> toStringList() {
    return presentes.map((p) => p.nomePresente).toList();
  }

  // Criar a partir de lista de strings
  static ListaPresentesReserva fromStringList(List<String> nomes, String reservaId) {
    final presentes = <PresenteReserva>[];
    for (int i = 0; i < nomes.length; i++) {
      presentes.add(PresenteReserva(
        id: '', // Será gerado pelo banco
        reservaId: reservaId,
        nomePresente: nomes[i],
        ordem: i,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    return ListaPresentesReserva(presentes: presentes);
  }

  int get length => presentes.length;
  bool get isEmpty => presentes.isEmpty;
  bool get isNotEmpty => presentes.isNotEmpty;
}