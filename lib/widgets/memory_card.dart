import 'package:flutter/material.dart';
import 'package:memory_game_flutter/models/card_model.dart';

class MemoryCard extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;
  final bool isDisabled;
  final double? size;

  const MemoryCard({
    super.key,
    required this.card,
    required this.onTap,
    this.isDisabled = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = card.id.split('-')[1];
    final cardSize = size ?? MediaQuery.of(context).size.width / 4 - 16;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: cardSize,
        height: cardSize,
        decoration: BoxDecoration(
          color: card.isMatched
              ? Colors.green.withOpacity(0.8)
              : card.isFaceUp
                  ? Colors.blue[300]
                  : Colors.blue[800],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(card.isMatched ? 0.8 : 0.4),
            width: 2,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: card.isFaceUp || card.isMatched
                ? Text(
                    emoji,
                    key: ValueKey('$emoji-${card.isMatched}'),
                    style: TextStyle(
                      fontSize: cardSize * 0.4,
                    ),
                  )
                : const Icon(
                    Icons.question_mark,
                    key: ValueKey('question-mark'),
                    color: Colors.white,
                    size: 24,
                  ),
          ),
        ),
      ),
    );
  }
}