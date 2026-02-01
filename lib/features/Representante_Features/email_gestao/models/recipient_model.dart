class RecipientModel {
  final String id;
  final String name;
  final String
  type; // T (Tenant), P (Proprietor), I (Inquilino) - using T/P/I as per image
  final String unitBlock; // e.g. "102 / B"
  final String email;
  final bool isSelected;

  final String? block;
  final String? unit;

  const RecipientModel({
    required this.id,
    required this.name,
    required this.type,
    required this.unitBlock,
    required this.email,
    this.isSelected = false,
    this.block,
    this.unit,
  });

  RecipientModel copyWith({
    String? id,
    String? name,
    String? type,
    String? unitBlock,
    String? email,
    bool? isSelected,
    String? block,
    String? unit,
  }) {
    return RecipientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      unitBlock: unitBlock ?? this.unitBlock,
      email: email ?? this.email,
      isSelected: isSelected ?? this.isSelected,
      block: block ?? this.block,
      unit: unit ?? this.unit,
    );
  }
}
