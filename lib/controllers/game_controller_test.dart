import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game_flutter/controllers/game_controller.dart';
import 'package:memory_game_flutter/models/card_model.dart';

void main() {
  group('GameController Tests', () {
    late GameController gameController;

    setUp(() {
      gameController = GameController();
      gameController.initializeGame();
    });

    test('Initialization sets up correct number of cards', () {
      expect(gameController.cards.length, equals(16)); // 8 pairs
      expect(gameController.matchedPairs, equals(0));
      expect(gameController.level, equals(1));
    });

    test('Card tap updates state correctly', () async {
      final firstCard = gameController.cards.first;
      await gameController.handleCardTap(firstCard);
      
      expect(firstCard.isFaceUp, isTrue);
      expect(gameController.firstSelectedCard, equals(firstCard));
    });

    test('Matching cards works correctly', () async {
      // Find two matching cards
      final firstCard = gameController.cards.first;
      final matchingCard = gameController.cards.firstWhere(
        (card) => card.id == firstCard.id && card != firstCard
      );

      await gameController.handleCardTap(firstCard);
      await gameController.handleCardTap(matchingCard);
      
      expect(firstCard.isMatched, isTrue);
      expect(matchingCard.isMatched, isTrue);
      expect(gameController.matchedPairs, equals(1));
    });

    test('Non-matching cards flip back', () async {
      // Find two different cards
      final firstCard = gameController.cards[0];
      final secondCard = gameController.cards[1];
      if (firstCard.id == secondCard.id) {
        secondCard = gameController.cards[2]; // Ensure they're different
      }

      await gameController.handleCardTap(firstCard);
      await gameController.handleCardTap(secondCard);
      
      expect(firstCard.isFaceUp, isFalse);
      expect(secondCard.isFaceUp, isFalse);
    });

    test('Level completion advances level', () async {
      gameController.level = 1;
      gameController.matchedPairs = 7; // One pair left
      
      // Complete the last pair
      final firstCard = gameController.cards.firstWhere((c) => !c.isMatched);
      final matchingCard = gameController.cards.firstWhere(
        (c) => c.id == firstCard.id && c != firstCard
      );

      await gameController.handleCardTap(firstCard);
      await gameController.handleCardTap(matchingCard);
      
      expect(gameController.level, equals(2));
      expect(gameController.matchedPairs, equals(0));
    });
  });
}