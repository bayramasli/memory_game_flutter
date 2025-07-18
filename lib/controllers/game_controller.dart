import 'package:flutter/material.dart';
import 'package:memory_game_flutter/models/card_model.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ScoreEntry {
  final int level;
  final int time;
  final int totalTime;
  final DateTime date;
  ScoreEntry({required this.level, required this.time, required this.totalTime, required this.date});

  Map<String, dynamic> toJson() => {
    'level': level,
    'time': time,
    'totalTime': totalTime,
    'date': date.toIso8601String(),
  };
  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
    level: json['level'],
    time: json['time'],
    totalTime: json['totalTime'] ?? 0,
    date: DateTime.parse(json['date']),
  );
}

class GameController extends ChangeNotifier {
  List<CardModel> cards = [];
  int matchedPairs = 0;
  int level = 1;
  int totalPairs = 2; // Başlangıçta 2 çift (4 kart)
  bool isProcessing = false;
  CardModel? firstSelectedCard;
  CardModel? secondSelectedCard;
  int timeLeft = 0;
  int baseTime = 20; // Başlangıç süresi (saniye)
  bool isTimerActive = false;
  VoidCallback? onTimeUp;
  Timer? _timer;
  DateTime? _gameStartTime;
  int _totalElapsedSeconds = 0;

  List<ScoreEntry> scoreBoard = [];

  Future<void> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('scoreBoard');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      scoreBoard = jsonList.map((e) => ScoreEntry.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(scoreBoard.map((e) => e.toJson()).toList());
    await prefs.setString('scoreBoard', data);
  }

  void addScore(int level, int time) {
    print('Skor ekleniyor: level=$level, totalTime=$_totalElapsedSeconds');
    scoreBoard.insert(0, ScoreEntry(level: level, time: time, totalTime: _totalElapsedSeconds, date: DateTime.now()));
    saveScores();
    notifyListeners();
  }

  void clearScores() async {
    scoreBoard.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scoreBoard');
    notifyListeners();
  }

  static const List<String> emojis = [
    '🐶', '🐱', '🦊', '🐻', '🐼', '🐨', '🦁', '🐮',
    '🐵', '🐔', '🐧', '🐦', '🐤', '🦄', '🦋', '🐝',
    '🐠', '🐙', '🦀', '🐬', '🦕', '🦖', '🐢', '🐍',
    '🦒', '🐘', '🦘', '🐄', '🐖', '🐑', '🐇', '🦔'
  ];

  void startLevelTimer({VoidCallback? onTimeUpCallback}) {
    _timer?.cancel();
    timeLeft = baseTime + (level - 1) * 5; // Her seviye +5 sn
    isTimerActive = true;
    onTimeUp = onTimeUpCallback;
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isTimerActive) return;
      timeLeft--;
      _totalElapsedSeconds++;
      notifyListeners();
      if (timeLeft <= 0) {
        isTimerActive = false;
        timer.cancel();
        if (onTimeUp != null) onTimeUp!();
      }
    });
  }

  void pauseTimer() {
    isTimerActive = false;
    notifyListeners();
  }

  void resumeTimer() {
    if (timeLeft > 0 && !isTimerActive) {
      isTimerActive = true;
      notifyListeners();
    }
  }

  void stopTimer() {
    isTimerActive = false;
    _timer?.cancel();
    notifyListeners();
  }

  void initializeGame({bool notify = true}) {
    totalPairs = 2 + (level - 1); // 2 çift ile başla, her seviye +1 çift
    if (totalPairs > 16) totalPairs = 16;
    final usedEmojis = emojis.sublist(0, totalPairs);
    cards = [];
    for (int i = 0; i < totalPairs; i++) {
      cards.add(CardModel(
        value: i,
        id: '$i-${usedEmojis[i]}',
        isFaceUp: false,
        isMatched: false,
      ));
      cards.add(CardModel(
        value: i,
        id: '$i-${usedEmojis[i]}',
        isFaceUp: false,
        isMatched: false,
      ));
    }
    cards.shuffle();
    matchedPairs = 0;
    isProcessing = false;
    firstSelectedCard = null;
    secondSelectedCard = null;
    stopTimer();
    timeLeft = baseTime + (level - 1) * 5;
    _gameStartTime = DateTime.now();
    _totalElapsedSeconds = 0;
    if (notify) notifyListeners();
  }

  Future<void> handleCardTap(CardModel card) async {
    if (!isTimerActive) return;
    if (card.isFaceUp || card.isMatched || isProcessing) return;
    final index = cards.indexOf(card);
    if (index == -1) return;
    cards[index] = card.copyWith(isFaceUp: true);
    cards = List<CardModel>.from(cards);
    notifyListeners();
    if (firstSelectedCard == null) {
      firstSelectedCard = cards[index];
    } else {
      isProcessing = true;
      secondSelectedCard = cards[index];
      notifyListeners();
      if (firstSelectedCard!.id == secondSelectedCard!.id) {
        await Future.delayed(const Duration(milliseconds: 200));
        final firstIndex = cards.indexOf(firstSelectedCard!);
        final secondIndex = cards.indexOf(secondSelectedCard!);
        if (firstIndex != -1) cards[firstIndex] = cards[firstIndex].copyWith(isMatched: true);
        if (secondIndex != -1) cards[secondIndex] = cards[secondIndex].copyWith(isMatched: true);
        cards = List<CardModel>.from(cards);
        matchedPairs++;
        firstSelectedCard = null;
        secondSelectedCard = null;
        isProcessing = false;
        notifyListeners();
        if (matchedPairs == totalPairs) {
          await Future.delayed(const Duration(milliseconds: 300));
          level++;
          initializeGame(notify: true);
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
        final firstIndex = cards.indexOf(firstSelectedCard!);
        final secondIndex = cards.indexOf(secondSelectedCard!);
        if (firstIndex != -1) cards[firstIndex] = cards[firstIndex].copyWith(isFaceUp: false);
        if (secondIndex != -1) cards[secondIndex] = cards[secondIndex].copyWith(isFaceUp: false);
        cards = List<CardModel>.from(cards);
        firstSelectedCard = null;
        secondSelectedCard = null;
        isProcessing = false;
        notifyListeners();
      }
    }
  }

  void resetGame() {
    level = 1;
    matchedPairs = 0;
    _totalElapsedSeconds = 0;
    _gameStartTime = DateTime.now();
    initializeGame(notify: true);
  }

  int get totalElapsedSeconds => _totalElapsedSeconds;
}