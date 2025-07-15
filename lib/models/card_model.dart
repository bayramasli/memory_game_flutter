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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}