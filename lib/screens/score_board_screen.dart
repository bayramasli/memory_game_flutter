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
    final gameController = Provider.of<GameController>(context); // dinleyici olarak
    final scores = gameController.scoreBoard;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skor Tablosu'),
      ),
      body: scores.isEmpty
          ? const Center(child: Text('Henüz skor yok.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Expanded(child: Text('Sıra', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Seviye', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Toplam Süre', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Tarih', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: scores.length,
                      itemBuilder: (context, index) {
                        final score = scores[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: index % 2 == 0 ? Colors.deepPurple.shade50 : Colors.deepPurple.shade200.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text('${index + 1}')),
                              Expanded(child: Text('${score.level}')),
                              Expanded(child: Text('${score.totalTime} sn')),
                              Expanded(child: Text(score.date.toString().substring(0, 19))),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 