import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game_flutter/models/card_model.dart';
import 'package:memory_game_flutter/widgets/memory_card.dart';

void main() {
  group('MemoryCard Widget Tests', () {
    testWidgets('Kapalı kart doğru şekilde gösteriliyor', (tester) async {
      final card = CardModel(
        value: 1,
        id: '1-🐶',
        isFaceUp: false,
        isMatched: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemoryCard(
              card: card,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.question_mark), findsOneWidget);
      expect(find.text('🐶'), findsNothing);
    });

    testWidgets('Açık kart doğru şekilde gösteriliyor', (tester) async {
      final card = CardModel(
        value: 1,
        id: '1-🐶',
        isFaceUp: true,
        isMatched: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemoryCard(
              card: card,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('🐶'), findsOneWidget);
      expect(find.byIcon(Icons.question_mark), findsNothing);
    });

    testWidgets('Eşleşmiş kart doğru şekilde gösteriliyor', (tester) async {
      final card = CardModel(
        value: 1,
        id: '1-🐶',
        isFaceUp: true,
        isMatched: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemoryCard(
              card: card,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('🐶'), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container).first);
      expect((container.decoration as BoxDecoration).color, equals(Colors.green.withOpacity(0.8)));
    });

    testWidgets('Tıklama callback doğru çalışıyor', (tester) async {
      bool tapped = false;
      final card = CardModel(
        value: 1,
        id: '1-🐶',
        isFaceUp: false,
        isMatched: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MemoryCard(
              card: card,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MemoryCard));
      expect(tapped, isTrue);
    });
  });
}