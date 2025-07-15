import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memory_game_flutter/controllers/game_controller.dart';

class ScoreBoardScreen extends StatefulWidget {
  const ScoreBoardScreen({super.key});

  @override
  State<ScoreBoardScreen> createState() => _ScoreBoardScreenState();
}

class _ScoreBoardScreenState extends State<ScoreBoardScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<GameController>(context, listen: false).loadScores().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameController = Provider.of<GameController>(context, listen: false);
    final scores = gameController.scoreBoard;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skor Tablosu'),
      ),
      body: scores.isEmpty
          ? const Center(child: Text('Henüz skor yok.'))
          : ListView.builder(
              itemCount: scores.length,
              itemBuilder: (context, index) {
                final score = scores[index];
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text('Seviye: ${score.level}'),
                  subtitle: Text('Süre: ${score.time} sn\nTarih: ${score.date.toString().substring(0, 19)}'),
                );
              },
            ),
    );
  }
} 