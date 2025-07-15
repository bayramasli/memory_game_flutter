import 'package:flutter/material.dart';
import 'package:memory_game_flutter/models/card_model.dart';

class GameController extends ChangeNotifier {
  List<CardModel> cards = [];
  int matchedPairs = 0;
  int level = 1;
  int totalPairs = 8;
  bool isProcessing = false;
  CardModel? firstSelectedCard;
  CardModel? secondSelectedCard;

  static const List<String> emojis = [
    '🐶', '🐱', '🦊', '🐻', '🐼', '🐨', '🦁', '🐮',
    '🐵', '🐔', '🐧', '🐦', '🐤', '🦄', '🦋', '🐝',
    '🐠', '🐙', '🦀', '🐬', '🦕', '🦖', '🐢', '🐍',
    '🦒', '🐘', '🦘', '🐄', '🐖', '🐑', '🐇', '🦔'
  ];

  void initializeGame() {
    totalPairs = 8 + (level - 1) * 2;
    if (totalPairs > 16) totalPairs = 16;

    final usedEmojis = emojis.sublist(0, totalPairs);
    cards = [];

    for (int i = 0; i < totalPairs; i++) {
      cards.add(CardModel(
        value: i,
        id: '$i-${usedEmojis[i]}',
        isFaceUp: false,
        isMatched: false,
      ));
      cards.add(CardModel(
        value: i,
        id: '$i-${usedEmojis[i]}',
        isFaceUp: false,
        isMatched: false,
      ));
    }

    cards.shuffle();
    matchedPairs = 0;
    isProcessing = false;
    firstSelectedCard = null;
    secondSelectedCard = null;
    notifyListeners();
  }

  Future<void> handleCardTap(CardModel card) async {
    if (card.isFaceUp || card.isMatched || isProcessing) return;

    card.isFaceUp = true;
    notifyListeners();

    if (firstSelectedCard == null) {
      firstSelectedCard = card;
    } else {
      isProcessing = true;
      secondSelectedCard = card;
      notifyListeners();

      if (firstSelectedCard!.id == secondSelectedCard!.id) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        firstSelectedCard!.isMatched = true;
        secondSelectedCard!.isMatched = true;
        matchedPairs++;
        firstSelectedCard = null;
        secondSelectedCard = null;
        isProcessing = false;
        notifyListeners();

        if (matchedPairs == totalPairs) {
          await Future.delayed(const Duration(milliseconds: 1000));
          level++;
          initializeGame();
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 1000));
        
        firstSelectedCard!.isFaceUp = false;
        secondSelectedCard!.isFaceUp = false;
        firstSelectedCard = null;
        secondSelectedCard = null;
        isProcessing = false;
        notifyListeners();
      }
    }
  }

  void resetGame() {
    level = 1;
    initializeGame();
  }
}