import 'dart:math';
import '../models/player.dart';
import '../models/choice_card.dart';
import '../data/default_game_data.dart';
import 'firebase_service.dart';

/// Сервис игровой логики
class GameService {
  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final Random _random = Random();

  // Игровые настройки
  static const int totalRounds = 7;          // Всего раундов в игре
  static const int choicesPerRound = 3;      // Вариантов на выбор за раунд
  
  // Кешированные данные
  List<ChoiceCard>? _allChoices;
  List<GameCharacter>? _allCharacters;
  List<GameTitle>? _allTitles;

  /// Текущее состояние игры
  Player? _currentPlayer;
  int _currentRound = 0;
  List<String> _usedSituations = [];

  // ========== ИНИЦИАЛИЗАЦИЯ ==========

  /// Инициализировать игровой сервис
  Future<bool> initialize() async {
    try {
      // Загружаем все данные из Firebase
      await _loadGameData();
      return true;
    } catch (e) {
      print('Ошибка инициализации игрового сервиса: $e');
      return false;
    }
  }

  /// Загрузить игровые данные из Firebase или локальных данных
  Future<void> _loadGameData() async {
    try {
      // Пытаемся загрузить из Firebase
      final results = await Future.wait([
        _firebaseService.getChoiceCards(),
        _firebaseService.getCharacters(),
        _firebaseService.getTitles(),
      ]);

      _allChoices = results[0] as List<ChoiceCard>;
      _allCharacters = results[1] as List<GameCharacter>;
      _allTitles = results[2] as List<GameTitle>;
      
      // Если данные пустые, используем локальные
      if (_allChoices!.isEmpty) {
        _allChoices = DefaultGameData.getDefaultChoices();
      }
      if (_allCharacters!.isEmpty) {
        _allCharacters = DefaultGameData.getDefaultCharacters();
      }
      if (_allTitles!.isEmpty) {
        _allTitles = DefaultGameData.getDefaultTitles();
      }
    } catch (e) {
      // При ошибке используем локальные данные
      print('Ошибка загрузки из Firebase, используем локальные данные: $e');
      _allChoices = DefaultGameData.getDefaultChoices();
      _allCharacters = DefaultGameData.getDefaultCharacters();
      _allTitles = DefaultGameData.getDefaultTitles();
    }
  }

  // ========== УПРАВЛЕНИЕ ИГРОЙ ==========

  /// Начать новую игру
  Future<bool> startNewGame(String characterId) async {
    try {
      // Попытка работы с Firebase
      bool firebaseSuccess = false;
      
      try {
        // Анонимная авторизация если нужно
        final user = _firebaseService.currentUser;
        if (user == null) {
          await _firebaseService.signInAnonymously();
        }

        // Создать или сбросить игрока
        final success = await _firebaseService.resetGame(characterId);
        if (success) {
          // Загрузить игрока
          _currentPlayer = await _firebaseService.getPlayer();
          firebaseSuccess = (_currentPlayer != null);
        }
      } catch (e) {
        print('Firebase недоступен, используем локальный режим: $e');
        firebaseSuccess = false;
      }

      // Если Firebase не работает, создаем локального игрока
      if (!firebaseSuccess) {
        _currentPlayer = Player.newPlayer(
          'local_${DateTime.now().millisecondsSinceEpoch}', 
          characterId
        );
      }

      // Сбросить состояние игры
      _currentRound = 0;
      _usedSituations.clear();

      return true;
    } catch (e) {
      print('Ошибка начала новой игры: $e');
      return false;
    }
  }

  /// Загрузить текущую игру
  Future<bool> loadCurrentGame() async {
    try {
      _currentPlayer = await _firebaseService.getPlayer();
      if (_currentPlayer != null) {
        _currentRound = _currentPlayer!.gameHistory.length;
        _usedSituations = _currentPlayer!.gameHistory
            .map((choice) => _getChoiceById(choice.choiceId)?.situation ?? '')
            .where((situation) => situation.isNotEmpty)
            .toList();
        return true;
      }
      return false;
    } catch (e) {
      print('Ошибка загрузки игры: $e');
      return false;
    }
  }

  /// Получить доступных персонажей
  List<GameCharacter> getAvailableCharacters() {
    return _allCharacters ?? [];
  }

  /// Получить персонажа по ID
  GameCharacter? getCharacterById(String characterId) {
    return _allCharacters?.firstWhere(
      (char) => char.id == characterId,
      orElse: () => _allCharacters!.first,
    );
  }

  /// Получить карточку по ID
  ChoiceCard? _getChoiceById(String choiceId) {
    return _allChoices?.firstWhere(
      (card) => card.id == choiceId,
      orElse: () => _allChoices!.first,
    );
  }

  // ========== ИГРОВЫЕ РАУНДЫ ==========

  /// Проверить, окончена ли игра
  bool get isGameCompleted => _currentRound >= totalRounds;

  /// Получить текущий раунд (0-based)
  int get currentRound => _currentRound;

  /// Получить общее количество раундов
  int get maxRounds => totalRounds;

  /// Получить текущего игрока
  Player? get currentPlayer => _currentPlayer;

  /// Получить карточки для текущего раунда
  List<ChoiceCard> getChoicesForCurrentRound() {
    if (_allChoices == null || _allChoices!.isEmpty) return [];

    // Получаем все уникальные ситуации
    final allSituations = _allChoices!
        .map((card) => card.situation)
        .toSet()
        .toList();

    // Убираем уже использованные ситуации
    final availableSituations = allSituations
        .where((situation) => !_usedSituations.contains(situation))
        .toList();

    // Если все ситуации использованы, берем любые
    final situationsToUse = availableSituations.isNotEmpty 
        ? availableSituations 
        : allSituations;

    // Выбираем случайную ситуацию
    final randomSituation = situationsToUse[_random.nextInt(situationsToUse.length)];

    // Получаем все карточки для этой ситуации
    final situationCards = _allChoices!
        .where((card) => card.situation == randomSituation)
        .toList();

    // Перемешиваем и берем нужное количество
    situationCards.shuffle(_random);
    
    final selectedCards = situationCards.take(choicesPerRound).toList();
    
    // Если карточек меньше чем нужно, добавляем случайные
    while (selectedCards.length < choicesPerRound && selectedCards.length < _allChoices!.length) {
      final remainingCards = _allChoices!
          .where((card) => !selectedCards.contains(card))
          .toList();
      
      if (remainingCards.isEmpty) break;
      
      selectedCards.add(remainingCards[_random.nextInt(remainingCards.length)]);
    }

    return selectedCards;
  }

  /// Сделать выбор
  Future<bool> makeChoice(ChoiceCard selectedCard) async {
    try {
      if (_currentPlayer == null || isGameCompleted) return false;

      // Попытка сохранить в Firebase
      bool firebaseSuccess = false;
      try {
        final success = await _firebaseService.saveChoice(
          selectedCard.id, 
          selectedCard.effects,
        );

        if (success) {
          // Обновляем из Firebase
          _currentPlayer = await _firebaseService.getPlayer();
          firebaseSuccess = true;
        }
      } catch (e) {
        print('Firebase недоступен для сохранения, работаем локально: $e');
        firebaseSuccess = false;
      }

      // Если Firebase не работает, обновляем локально
      if (!firebaseSuccess) {
        // Создаем новый выбор
        final newChoice = GameChoice(
          choiceId: selectedCard.id,
          effect: selectedCard.effects,
          timestamp: DateTime.now(),
        );

        // Обновляем историю
        final updatedHistory = [..._currentPlayer!.gameHistory, newChoice];
        
        // Обновляем статистику
        final updatedStats = _currentPlayer!.currentStats.applyEffect(selectedCard.effects);
        
        // Создаем обновленного игрока
        _currentPlayer = _currentPlayer!.copyWith(
          gameHistory: updatedHistory,
          currentStats: updatedStats,
          lastPlayed: DateTime.now(),
        );
      }

      // Обновляем состояние игры
      _currentRound++;
      
      // Добавляем ситуацию в использованные
      if (!_usedSituations.contains(selectedCard.situation)) {
        _usedSituations.add(selectedCard.situation);
      }
      
      return true;
    } catch (e) {
      print('Ошибка выбора: $e');
      return false;
    }
  }

  // ========== ЗАВЕРШЕНИЕ ИГРЫ ==========

  /// Получить финальный титул для текущего игрока
  Future<GameTitle?> getFinalTitle() async {
    if (_currentPlayer == null || _allTitles == null) return null;

    try {
      final stats = _currentPlayer!.currentStats;
      
      // Сортируем титулы по приоритету (сначала более специфичные)
      final titles = List<GameTitle>.from(_allTitles!);
      titles.sort((a, b) {
        int aSpecificity = _getTitleSpecificity(a.conditions);
        int bSpecificity = _getTitleSpecificity(b.conditions);
        return bSpecificity.compareTo(aSpecificity);
      });

      // Находим первый подходящий титул
      for (final title in titles) {
        if (title.matches(stats)) {
          return title;
        }
      }

      // Если ничего не подошло, возвращаем базовый титул
      return titles.last;
    } catch (e) {
      print('Ошибка получения титула: $e');
      return null;
    }
  }

  /// Определить специфичность титула
  int _getTitleSpecificity(TitleConditions conditions) {
    int specificity = 0;
    if (conditions.money != null) specificity += 3;
    if (conditions.knowledge != null) specificity += 3;
    if (conditions.energy != null) specificity += 3;
    if (conditions.moneyMin != null) specificity += 1;
    if (conditions.knowledgeMin != null) specificity += 1;
    if (conditions.energyMin != null) specificity += 1;
    if (conditions.moneyMax != null) specificity += 1;
    if (conditions.knowledgeMax != null) specificity += 1;
    if (conditions.energyMax != null) specificity += 1;
    return specificity;
  }

  /// Получить статистику игры
  GameStats getGameStats() {
    if (_currentPlayer == null) {
      return GameStats.empty();
    }

    return GameStats(
      totalRounds: _currentRound,
      maxRounds: totalRounds,
      currentStats: _currentPlayer!.currentStats,
      choiceHistory: _currentPlayer!.gameHistory,
      character: getCharacterById(_currentPlayer!.character),
    );
  }

  // ========== УТИЛИТЫ ==========

  /// Получить прогресс игры в процентах
  double getGameProgress() {
    return (_currentRound / totalRounds * 100).clamp(0, 100);
  }

  /// Получить описание текущего состояния
  String getProgressDescription() {
    if (isGameCompleted) {
      return "Игра завершена!";
    }
    return "Раунд ${_currentRound + 1} из $totalRounds";
  }

  /// Можно ли сделать следующий ход
  bool get canMakeMove => !isGameCompleted && _currentPlayer != null;

  /// Очистить состояние (для выхода из игры)
  void clearState() {
    _currentPlayer = null;
    _currentRound = 0;
    _usedSituations.clear();
  }
}

/// Статистика игры
class GameStats {
  final int totalRounds;
  final int maxRounds;
  final PlayerStats currentStats;
  final List<GameChoice> choiceHistory;
  final GameCharacter? character;

  GameStats({
    required this.totalRounds,
    required this.maxRounds,
    required this.currentStats,
    required this.choiceHistory,
    this.character,
  });

  factory GameStats.empty() {
    return GameStats(
      totalRounds: 0,
      maxRounds: 0,
      currentStats: PlayerStats.initial(),
      choiceHistory: [],
      character: null,
    );
  }

  /// Игра завершена
  bool get isCompleted => totalRounds >= maxRounds;

  /// Прогресс в процентах
  double get progressPercent => (totalRounds / maxRounds * 100).clamp(0, 100);

  /// Лучший параметр
  String get bestStat {
    final stats = currentStats;
    if (stats.money >= stats.knowledge && stats.money >= stats.energy) {
      return "💰 Деньги";
    } else if (stats.knowledge >= stats.energy) {
      return "📘 Знания";
    } else {
      return "💡 Энергия";
    }
  }

  /// Худший параметр  
  String get worstStat {
    final stats = currentStats;
    if (stats.money <= stats.knowledge && stats.money <= stats.energy) {
      return "💰 Деньги";
    } else if (stats.knowledge <= stats.energy) {
      return "📘 Знания";
    } else {
      return "💡 Энергия";
    }
  }
} 