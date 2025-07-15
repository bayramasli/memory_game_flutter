import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memory_game_flutter/controllers/game_controller.dart';

class ScoreBoardScreen extends StatelessWidget {
  const ScoreBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameController = Provider.of<GameController>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyun Sonu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tamamlanan Seviye:  {gameController.level - 1}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                gameController.resetGame();
                Navigator.pop(context);
              },
              child: const Text('Ana Menü'),
            ),
          ],
        ),
      ),
    );
  }
} 