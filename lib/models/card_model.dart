class CardModel {
  final int value;
  final String id; // Format: "index-emoji"
  bool isFaceUp;
  bool isMatched;

  CardModel({
    required this.value,
    required this.id,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  CardModel copyWith({
    bool? isFaceUp,
    bool? isMatched,
    int? value,
    String? id,
  }) {
    return CardModel(
      value: value ?? this.value,
      id: id ?? this.id,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}