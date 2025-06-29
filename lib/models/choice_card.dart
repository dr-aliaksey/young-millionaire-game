import 'package:cloud_firestore/cloud_firestore.dart';
import 'player.dart';

/// Карточка выбора - основной элемент игры
class ChoiceCard {
  final String id;
  final String situation;    // Ситуация (например: "Утром проснулся")
  final String text;         // Текст действия (например: "Поспать ещё")
  final String icon;         // Эмодзи или путь к иконке
  final ChoiceEffect effects; // Влияние на шкалы
  final String? audio;       // Путь к аудиофайлу

  ChoiceCard({
    required this.id,
    required this.situation,
    required this.text,
    required this.icon,
    required this.effects,
    this.audio,
  });

  /// Создать из Firebase документа
  factory ChoiceCard.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ChoiceCard(
      id: doc.id,
      situation: data['situation'] ?? '',
      text: data['text'] ?? '',
      icon: data['icon'] ?? '',
      effects: ChoiceEffect.fromMap(data['effects'] ?? {}),
      audio: data['audio'],
    );
  }

  /// Создать из JSON данных
  factory ChoiceCard.fromJson(Map<String, dynamic> json) {
    return ChoiceCard(
      id: json['id'] ?? '',
      situation: json['situation'] ?? '',
      text: json['text'] ?? '',
      icon: json['icon'] ?? '',
      effects: ChoiceEffect.fromMap(json['effects'] ?? {}),
      audio: json['audio'],
    );
  }

  /// Конвертировать в формат для Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'situation': situation,
      'text': text,
      'icon': icon,
      'effects': effects.toMap(),
      'audio': audio,
    };
  }

  /// Конвертировать в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'situation': situation,
      'text': text,
      'icon': icon,
      'effects': effects.toMap(),
      'audio': audio,
    };
  }
}

/// Персонаж игры
class GameCharacter {
  final String id;
  final String name;
  final String icon;
  final String description;
  final Map<String, String> animations; // idle, happy, sad

  GameCharacter({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.animations,
  });

  /// Создать из Firebase документа
  factory GameCharacter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return GameCharacter(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      description: data['description'] ?? '',
      animations: Map<String, String>.from(data['animations'] ?? {}),
    );
  }

  /// Создать из JSON данных
  factory GameCharacter.fromJson(Map<String, dynamic> json) {
    return GameCharacter(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      animations: Map<String, String>.from(json['animations'] ?? {}),
    );
  }

  /// Конвертировать в формат для Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'description': description,
      'animations': animations,
    };
  }
}

/// Титул игрока в конце игры
class GameTitle {
  final String id;
  final String name;
  final String icon;
  final String description;
  final TitleConditions conditions;

  GameTitle({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.conditions,
  });

  /// Создать из Firebase документа
  factory GameTitle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return GameTitle(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      description: data['description'] ?? '',
      conditions: TitleConditions.fromMap(data['conditions'] ?? {}),
    );
  }

  /// Создать из JSON данных
  factory GameTitle.fromJson(Map<String, dynamic> json) {
    return GameTitle(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      conditions: TitleConditions.fromMap(json['conditions'] ?? {}),
    );
  }

  /// Проверить, соответствуют ли статистики условиям титула
  bool matches(PlayerStats stats) {
    return conditions.matches(stats);
  }

  /// Конвертировать в формат для Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'description': description,
      'conditions': conditions.toMap(),
    };
  }
}

/// Условия получения титула
class TitleConditions {
  final int? money;         // Точное значение
  final int? knowledge;     // Точное значение
  final int? energy;        // Точное значение
  final int? moneyMin;      // Минимальное значение
  final int? knowledgeMin;  // Минимальное значение
  final int? energyMin;     // Минимальное значение
  final int? moneyMax;      // Максимальное значение
  final int? knowledgeMax;  // Максимальное значение
  final int? energyMax;     // Максимальное значение

  TitleConditions({
    this.money,
    this.knowledge,
    this.energy,
    this.moneyMin,
    this.knowledgeMin,
    this.energyMin,
    this.moneyMax,
    this.knowledgeMax,
    this.energyMax,
  });

  factory TitleConditions.fromMap(Map<String, dynamic> map) {
    return TitleConditions(
      money: map['money'],
      knowledge: map['knowledge'],
      energy: map['energy'],
      moneyMin: map['money_min'],
      knowledgeMin: map['knowledge_min'],
      energyMin: map['energy_min'],
      moneyMax: map['money_max'],
      knowledgeMax: map['knowledge_max'],
      energyMax: map['energy_max'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'money': money,
      'knowledge': knowledge,
      'energy': energy,
      'money_min': moneyMin,
      'knowledge_min': knowledgeMin,
      'energy_min': energyMin,
      'money_max': moneyMax,
      'knowledge_max': knowledgeMax,
      'energy_max': energyMax,
    };
  }

  /// Проверить, соответствуют ли статистики условиям
  bool matches(PlayerStats stats) {
    // Проверка точных значений
    if (money != null && stats.money != money) return false;
    if (knowledge != null && stats.knowledge != knowledge) return false;
    if (energy != null && stats.energy != energy) return false;

    // Проверка минимальных значений
    if (moneyMin != null && stats.money < moneyMin!) return false;
    if (knowledgeMin != null && stats.knowledge < knowledgeMin!) return false;
    if (energyMin != null && stats.energy < energyMin!) return false;

    // Проверка максимальных значений
    if (moneyMax != null && stats.money > moneyMax!) return false;
    if (knowledgeMax != null && stats.knowledge > knowledgeMax!) return false;
    if (energyMax != null && stats.energy > energyMax!) return false;

    return true;
  }
} 