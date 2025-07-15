import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memory_game_flutter/controllers/game_controller.dart';
import 'package:memory_game_flutter/widgets/memory_card.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameController = Provider.of<GameController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Seviye ${gameController.level}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${gameController.matchedPairs}/${gameController.totalPairs}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _calculateCrossAxisCount(context, gameController.totalPairs),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: gameController.cards.length,
        itemBuilder: (context, index) {
          final card = gameController.cards[index];
          return MemoryCard(
            card: card,
            onTap: () => gameController.handleCardTap(card),
            isDisabled: gameController.isProcessing || card.isMatched,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.home),
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context, int totalPairs) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 6;
    if (totalPairs <= 8) return 4;
    if (totalPairs <= 12) return 5;
    return 6;
  }
}