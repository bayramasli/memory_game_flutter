import 'package:flutter/material.dart';
import 'package:memory_game_flutter/screens/home_screen.dart';
import 'package:memory_game_flutter/controllers/game_controller.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameController = Provider.of<GameController>(context);
    final level = gameController.level - 1; // Tamamlanan seviye

    return Scaffold(
      appBar: AppBar(title: const Text('Oyun Sonucu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            Text(
              'Tebrikler!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Seviye $level Tamamlandı',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.replay),
              label: const Text('Tekrar Oyna'),
              onPressed: () {
                gameController.resetGame();
                Navigator.pushReplacementNamed(context, '/game');
              },
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Ana Menü'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}