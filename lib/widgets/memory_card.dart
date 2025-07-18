import 'package:flutter/material.dart';
import 'package:memory_game_flutter/models/card_model.dart';

class MemoryCard extends StatefulWidget {
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
  State<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard> {
  @override
  void didUpdateWidget(covariant MemoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.isFaceUp != widget.card.isFaceUp || oldWidget.card.isMatched != widget.card.isMatched) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final emoji = widget.card.id.split('-')[1];
    final cardSize = widget.size ?? MediaQuery.of(context).size.width / 4 - 16;

    return GestureDetector(
      onTap: widget.isDisabled ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: cardSize,
        height: cardSize,
        decoration: BoxDecoration(
          color: widget.card.isMatched
              ? Colors.green.withOpacity(0.8)
              : widget.card.isFaceUp
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
            color: Colors.white.withOpacity(widget.card.isMatched ? 0.8 : 0.4),
            width: 2,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            child: widget.card.isFaceUp || widget.card.isMatched
                ? Text(
                    emoji,
                    key: ValueKey('$emoji-${widget.card.isMatched}'),
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