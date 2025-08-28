class Administrator {
  final String id;
  final String email;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime updatedAt;

  Administrator({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Administrator.fromJson(Map<String, dynamic> json) {
    return Administrator(
      id: json['id'] as String,
      email: json['email'] as String,
      passwordHash: json['password_hash'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Administrator{id: $id, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Administrator &&
        other.id == id &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}