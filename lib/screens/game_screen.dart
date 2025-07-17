import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memory_game_flutter/controllers/game_controller.dart';
import 'package:memory_game_flutter/widgets/memory_card.dart';
import 'package:memory_game_flutter/screens/home_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int? _lastLevel;
  bool _timerStarted = false;
  String? _buildError;

  @override
  void initState() {
    super.initState();
    // Sadece _lastLevel'i başlatıyoruz, context kullanmıyoruz.
    _lastLevel = null;
    _timerStarted = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameController = Provider.of<GameController>(context, listen: false);
    // Sadece bir kez timer başlatılsın
    if (!_timerStarted) {
      gameController.startLevelTimer(onTimeUpCallback: _onTimeUp);
      _lastLevel = gameController.level;
      _timerStarted = true;
    } else if (_lastLevel != null && gameController.level != _lastLevel) {
      gameController.startLevelTimer(onTimeUpCallback: _onTimeUp);
      _lastLevel = gameController.level;
    }
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final gameController = Provider.of<GameController>(context, listen: false);
    if (_lastLevel != null && gameController.level != _lastLevel) {
      gameController.startLevelTimer(onTimeUpCallback: _onTimeUp);
      _lastLevel = gameController.level;
    }
  }

  void _onTimeUp() {
    // Kaybettiniz ekranına yönlendir
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const _LoseScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    Provider.of<GameController>(context, listen: false).stopTimer();
    super.dispose();
  }

  Future<void> _handleExitAndAddScore(BuildContext context) async {
    final gameController = Provider.of<GameController>(context, listen: false);
    final level = gameController.level - 1;
    // Skor zaten eklenmediyse ekle
    if (gameController.scoreBoard.isEmpty ||
        gameController.scoreBoard.first.level != level ||
        gameController.scoreBoard.first.totalTime != gameController.totalElapsedSeconds) {
      gameController.addScore(level, 0);
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      final gameController = Provider.of<GameController>(context);
      final totalCards = gameController.cards.length;
      final screenSize = MediaQuery.of(context).size;
      final padding = 24.0; // toplam yatay padding
      final spacing = 8.0;
      // Sabit grid ve kart boyutu
      const crossAxisCount = 4;
      const cardSize = 72.0;
      final rows = (totalCards / crossAxisCount).ceil();
      return WillPopScope(
        onWillPop: () async {
          await _handleExitAndAddScore(context);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Ana Menü',
              onPressed: () async {
                await _handleExitAndAddScore(context);
              },
            ),
            title: Text('Seviye ${gameController.level}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            actions: [
              IconButton(
                icon: Icon(gameController.isTimerActive ? Icons.pause : Icons.play_arrow),
                tooltip: gameController.isTimerActive ? 'Durdur' : 'Devam Ettir',
                onPressed: () {
                  setState(() {
                    if (gameController.isTimerActive) {
                      gameController.pauseTimer();
                    } else {
                      gameController.resumeTimer();
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Ayarlar',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const _SettingsDialog(),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${gameController.timeLeft}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${gameController.matchedPairs}/${gameController.totalPairs}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                // Seviye ilerleme barı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: SizedBox(
                    height: 28,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 16,
                      itemBuilder: (context, i) {
                        final isPassed = gameController.level > i;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isPassed ? Colors.green : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: isPassed ? Colors.white : Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: gameController.timeLeft / (gameController.baseTime + (gameController.level - 1) * 5),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: () {
                              final total = gameController.baseTime + (gameController.level - 1) * 5;
                              final left = gameController.timeLeft;
                              if (left <= total * 0.2) {
                                return Colors.red;
                              } else if (left <= total * 0.5) {
                                return Colors.orange;
                              } else {
                                return Colors.green;
                              }
                            }(),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: crossAxisCount * cardSize + (crossAxisCount - 1) * spacing,
                    height: rows * cardSize + (rows - 1) * spacing,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: 1,
                      ),
                      itemCount: totalCards,
                      itemBuilder: (context, index) {
                        final card = gameController.cards[index];
                        return MemoryCard(
                          card: card,
                          onTap: () => gameController.handleCardTap(card),
                          isDisabled: gameController.isProcessing || card.isMatched || !gameController.isTimerActive,
                          size: cardSize,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, stack) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Text('Bir hata oluştu:\n$e'),
        ),
      );
    }
  }
}

class _LoseScreen extends StatelessWidget {
  const _LoseScreen();

  @override
  Widget build(BuildContext context) {
    final gameController = Provider.of<GameController>(context, listen: false);
    final level = gameController.level - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gameController.scoreBoard.isEmpty ||
          gameController.scoreBoard.first.level != level ||
          gameController.scoreBoard.first.totalTime != gameController.totalElapsedSeconds) {
        gameController.addScore(level, 0);
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Kaybettiniz')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text('Süre doldu!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('Ana Menüye Dön butonuna basıldı (LoseScreen)');
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text('Ana Menüye Dön'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDialog extends StatelessWidget {
  const _SettingsDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ayarlar'),
      content: const Text('Buraya oyun ayarları eklenebilir.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}