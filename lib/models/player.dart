import 'package:cloud_firestore/cloud_firestore.dart';

/// Модель игрока согласно DATA_MODEL.md
class Player {
  final String id;
  final String character;
  final PlayerStats currentStats;
  final List<GameChoice> gameHistory;
  final DateTime lastPlayed;

  Player({
    required this.id,
    required this.character,
    required this.currentStats,
    required this.gameHistory,
    required this.lastPlayed,
  });

  /// Создать нового игрока с начальными значениями
  factory Player.newPlayer(String uid, String characterId) {
    return Player(
      id: uid,
      character: characterId,
      currentStats: PlayerStats.initial(),
      gameHistory: [],
      lastPlayed: DateTime.now(),
    );
  }

  /// Создать из Firebase документа
  factory Player.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Player(
      id: doc.id,
      character: data['character'] ?? '',
      currentStats: PlayerStats.fromMap(data['currentStats'] ?? {}),
      gameHistory: (data['gameHistory'] as List<dynamic>? ?? [])
          .map((item) => GameChoice.fromMap(item))
          .toList(),
      lastPlayed: (data['lastPlayed'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Конвертировать в формат для Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'character': character,
      'currentStats': currentStats.toMap(),
      'gameHistory': gameHistory.map((choice) => choice.toMap()).toList(),
      'lastPlayed': Timestamp.fromDate(lastPlayed),
    };
  }

  /// Копировать с новыми значениями
  Player copyWith({
    String? character,
    PlayerStats? currentStats,
    List<GameChoice>? gameHistory,
    DateTime? lastPlayed,
  }) {
    return Player(
      id: id,
      character: character ?? this.character,
      currentStats: currentStats ?? this.currentStats,
      gameHistory: gameHistory ?? this.gameHistory,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }
}

/// Статистика игрока (3 шкалы)
class PlayerStats {
  final int money;    // 💰 Деньги (1-5)
  final int knowledge; // 📘 Знания (1-5)
  final int energy;   // 💡 Энергия (1-5)

  PlayerStats({
    required this.money,
    required this.knowledge,
    required this.energy,
  });

  /// Начальные значения: все по 3
  factory PlayerStats.initial() {
    return PlayerStats(money: 3, knowledge: 3, energy: 3);
  }

  /// Создать из Map
  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      money: map['money'] ?? 3,
      knowledge: map['knowledge'] ?? 3,
      energy: map['energy'] ?? 3,
    );
  }

  /// Конвертировать в Map
  Map<String, dynamic> toMap() {
    return {
      'money': money,
      'knowledge': knowledge,
      'energy': energy,
    };
  }

  /// Применить эффект выбора
  PlayerStats applyEffect(ChoiceEffect effect) {
    return PlayerStats(
      money: (money + effect.money).clamp(1, 5),
      knowledge: (knowledge + effect.knowledge).clamp(1, 5),
      energy: (energy + effect.energy).clamp(1, 5),
    );
  }

  /// Получить общий балл
  int get totalScore => money + knowledge + energy;

  /// Копировать с новыми значениями
  PlayerStats copyWith({
    int? money,
    int? knowledge,
    int? energy,
  }) {
    return PlayerStats(
      money: money ?? this.money,
      knowledge: knowledge ?? this.knowledge,
      energy: energy ?? this.energy,
    );
  }
}

/// Выбор в истории игры
class GameChoice {
  final String choiceId;
  final ChoiceEffect effect;
  final DateTime timestamp;

  GameChoice({
    required this.choiceId,
    required this.effect,
    required this.timestamp,
  });

  factory GameChoice.fromMap(Map<String, dynamic> map) {
    return GameChoice(
      choiceId: map['choiceId'] ?? '',
      effect: ChoiceEffect.fromMap(map['effect'] ?? {}),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'choiceId': choiceId,
      'effect': effect.toMap(),
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

/// Эффект выбора на статистику
class ChoiceEffect {
  final int money;
  final int knowledge;
  final int energy;

  ChoiceEffect({
    required this.money,
    required this.knowledge,
    required this.energy,
  });

  factory ChoiceEffect.fromMap(Map<String, dynamic> map) {
    return ChoiceEffect(
      money: map['money'] ?? 0,
      knowledge: map['knowledge'] ?? 0,
      energy: map['energy'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'money': money,
      'knowledge': knowledge,
      'energy': energy,
    };
  }
} 