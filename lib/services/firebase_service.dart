import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../models/player.dart';
import '../models/choice_card.dart';

/// Сервис для работы с Firebase
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String choicesCollection = 'choices';
  static const String charactersCollection = 'characters';
  static const String titlesCollection = 'titles';

  /// Инициализация Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  /// Получить текущего пользователя
  User? get currentUser => _auth.currentUser;

  /// Анонимная авторизация
  Future<User?> signInAnonymously() async {
    try {
      final UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      print('Ошибка анонимной авторизации: $e');
      return null;
    }
  }

  /// Выход из системы
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ========== ИГРОКИ ==========

  /// Создать нового игрока
  Future<bool> createPlayer(String characterId) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final player = Player.newPlayer(user.uid, characterId);
      await _firestore
          .collection(usersCollection)
          .doc(user.uid)
          .set(player.toFirestore());
      
      return true;
    } catch (e) {
      print('Ошибка создания игрока: $e');
      return false;
    }
  }

  /// Получить игрока
  Future<Player?> getPlayer() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection(usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return Player.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Ошибка получения игрока: $e');
      return null;
    }
  }

  /// Обновить игрока
  Future<bool> updatePlayer(Player player) async {
    try {
      await _firestore
          .collection(usersCollection)
          .doc(player.id)
          .update(player.toFirestore());
      
      return true;
    } catch (e) {
      print('Ошибка обновления игрока: $e');
      return false;
    }
  }

  /// Сохранить выбор в историю
  Future<bool> saveChoice(String choiceId, ChoiceEffect effect) async {
    try {
      final player = await getPlayer();
      if (player == null) return false;

      final newChoice = GameChoice(
        choiceId: choiceId, 
        effect: effect, 
        timestamp: DateTime.now(),
      );

      final updatedHistory = [...player.gameHistory, newChoice];
      final updatedStats = player.currentStats.applyEffect(effect);
      
      final updatedPlayer = player.copyWith(
        gameHistory: updatedHistory,
        currentStats: updatedStats,
        lastPlayed: DateTime.now(),
      );

      return await updatePlayer(updatedPlayer);
    } catch (e) {
      print('Ошибка сохранения выбора: $e');
      return false;
    }
  }

  /// Сбросить игру (новая игра)
  Future<bool> resetGame(String characterId) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final newPlayer = Player.newPlayer(user.uid, characterId);
      await _firestore
          .collection(usersCollection)
          .doc(user.uid)
          .set(newPlayer.toFirestore());
      
      return true;
    } catch (e) {
      print('Ошибка сброса игры: $e');
      return false;
    }
  }

  // ========== КАРТОЧКИ ВЫБОРА ==========

  /// Получить все карточки выбора
  Future<List<ChoiceCard>> getChoiceCards() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(choicesCollection)
          .get();

      return snapshot.docs
          .map((doc) => ChoiceCard.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Ошибка получения карточек: $e');
      return [];
    }
  }

  /// Получить карточки по ситуации
  Future<List<ChoiceCard>> getChoiceCardsBySituation(String situation) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(choicesCollection)
          .where('situation', isEqualTo: situation)
          .get();

      return snapshot.docs
          .map((doc) => ChoiceCard.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Ошибка получения карточек по ситуации: $e');
      return [];
    }
  }

  /// Добавить карточку выбора (для администрирования)
  Future<bool> addChoiceCard(ChoiceCard card) async {
    try {
      await _firestore
          .collection(choicesCollection)
          .doc(card.id)
          .set(card.toFirestore());
      
      return true;
    } catch (e) {
      print('Ошибка добавления карточки: $e');
      return false;
    }
  }

  // ========== ПЕРСОНАЖИ ==========

  /// Получить всех персонажей
  Future<List<GameCharacter>> getCharacters() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(charactersCollection)
          .get();

      return snapshot.docs
          .map((doc) => GameCharacter.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Ошибка получения персонажей: $e');
      return [];
    }
  }

  /// Получить персонажа по ID
  Future<GameCharacter?> getCharacter(String characterId) async {
    try {
      final doc = await _firestore
          .collection(charactersCollection)
          .doc(characterId)
          .get();

      if (doc.exists) {
        return GameCharacter.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Ошибка получения персонажа: $e');
      return null;
    }
  }

  // ========== ТИТУЛЫ ==========

  /// Получить все титулы
  Future<List<GameTitle>> getTitles() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(titlesCollection)
          .get();

      return snapshot.docs
          .map((doc) => GameTitle.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Ошибка получения титулов: $e');
      return [];
    }
  }

  /// Найти подходящий титул для статистик
  Future<GameTitle?> findTitleForStats(PlayerStats stats) async {
    try {
      final titles = await getTitles();
      
      // Сортируем титулы по приоритету (сначала более специфичные)
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

      return null;
    } catch (e) {
      print('Ошибка поиска титула: $e');
      return null;
    }
  }

  /// Определить специфичность титула (чем больше условий, тем выше приоритет)
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

  // ========== ИМПОРТ ДАННЫХ ==========

  /// Импортировать данные из JSON (для первоначальной настройки)
  Future<bool> importGameData(Map<String, dynamic> gameData) async {
    try {
      // Импорт карточек выбора
      if (gameData['choices'] != null) {
        final List<dynamic> choices = gameData['choices'];
        for (final choiceData in choices) {
          final card = ChoiceCard.fromJson(choiceData);
          await addChoiceCard(card);
        }
      }

      // Импорт персонажей
      if (gameData['characters'] != null) {
        final List<dynamic> characters = gameData['characters'];
        for (final characterData in characters) {
          final character = GameCharacter.fromJson(characterData);
          await _firestore
              .collection(charactersCollection)
              .doc(character.id)
              .set(character.toFirestore());
        }
      }

      // Импорт титулов
      if (gameData['titles'] != null) {
        final List<dynamic> titles = gameData['titles'];
        for (final titleData in titles) {
          final title = GameTitle.fromJson(titleData);
          await _firestore
              .collection(titlesCollection)
              .doc(title.id)
              .set(title.toFirestore());
        }
      }

      return true;
    } catch (e) {
      print('Ошибка импорта данных: $e');
      return false;
    }
  }
} 