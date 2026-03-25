import 'package:equatable/equatable.dart';

class ContaContabilModel extends Equatable {
  final String? id;
  final String condominioId;
  final String nome;
  final DateTime? createdAt;

  const ContaContabilModel({
    this.id,
    required this.condominioId,
    required this.nome,
    this.createdAt,
  });

  ContaContabilModel copyWith({
    String? id,
    String? condominioId,
    String? nome,
    DateTime? createdAt,
  }) {
    return ContaContabilModel(
      id: id ?? this.id,
      condominioId: condominioId ?? this.condominioId,
      nome: nome ?? this.nome,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ContaContabilModel.fromJson(Map<String, dynamic> json) {
    return ContaContabilModel(
      id: json['id'] as String?,
      condominioId: json['condominio_id'] as String,
      nome: json['nome'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'condominio_id': condominioId,
      'nome': nome,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, condominioId, nome, createdAt];
}
