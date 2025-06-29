import '../models/choice_card.dart';
import '../models/player.dart';

/// Базовые игровые данные для работы без Firebase
class DefaultGameData {
  /// Получить базовые карточки выбора
  static List<ChoiceCard> getDefaultChoices() {
    return [
      // Утром проснулся
      ChoiceCard(
        id: 'morning_sleep',
        situation: 'Утром проснулся',
        text: 'Поспать ещё',
        icon: '🛏️',
        effects: ChoiceEffect(money: 0, knowledge: -1, energy: 1),
      ),
      ChoiceCard(
        id: 'morning_exercise',
        situation: 'Утром проснулся',
        text: 'Сделать зарядку',
        icon: '🏃',
        effects: ChoiceEffect(money: 0, knowledge: 0, energy: 1),
      ),
      ChoiceCard(
        id: 'morning_study',
        situation: 'Утром проснулся',
        text: 'Почитать книгу',
        icon: '📖',
        effects: ChoiceEffect(money: 0, knowledge: 1, energy: 0),
      ),
      
      // В школе
      ChoiceCard(
        id: 'school_attention',
        situation: 'В школе на уроке',
        text: 'Слушать учителя',
        icon: '👂',
        effects: ChoiceEffect(money: 0, knowledge: 1, energy: 0),
      ),
      ChoiceCard(
        id: 'school_play',
        situation: 'В школе на уроке',
        text: 'Играть в телефон',
        icon: '📱',
        effects: ChoiceEffect(money: 0, knowledge: -1, energy: 0),
      ),
      ChoiceCard(
        id: 'school_help',
        situation: 'В школе на уроке',
        text: 'Помочь другу',
        icon: '🤝',
        effects: ChoiceEffect(money: 0, knowledge: 0, energy: 1),
      ),
      
      // После школы
      ChoiceCard(
        id: 'after_homework',
        situation: 'После школы',
        text: 'Сделать домашку',
        icon: '📝',
        effects: ChoiceEffect(money: 0, knowledge: 1, energy: -1),
      ),
      ChoiceCard(
        id: 'after_walk',
        situation: 'После школы',
        text: 'Погулять с друзьями',
        icon: '🚶',
        effects: ChoiceEffect(money: 0, knowledge: 0, energy: 1),
      ),
      ChoiceCard(
        id: 'after_tv',
        situation: 'После школы',
        text: 'Смотреть телевизор',
        icon: '📺',
        effects: ChoiceEffect(money: 0, knowledge: -1, energy: 0),
      ),
      
      // На выходных
      ChoiceCard(
        id: 'weekend_course',
        situation: 'На выходных',
        text: 'Пойти на кружок',
        icon: '🎨',
        effects: ChoiceEffect(money: -1, knowledge: 1, energy: 0),
      ),
      ChoiceCard(
        id: 'weekend_work',
        situation: 'На выходных',
        text: 'Помочь родителям',
        icon: '🏠',
        effects: ChoiceEffect(money: 1, knowledge: 0, energy: -1),
      ),
      ChoiceCard(
        id: 'weekend_games',
        situation: 'На выходных',
        text: 'Играть в игры',
        icon: '🎮',
        effects: ChoiceEffect(money: 0, knowledge: -1, energy: 1),
      ),
      
      // С карманными деньгами
      ChoiceCard(
        id: 'money_save',
        situation: 'Получил карманные деньги',
        text: 'Отложить в копилку',
        icon: '🏦',
        effects: ChoiceEffect(money: 1, knowledge: 0, energy: 0),
      ),
      ChoiceCard(
        id: 'money_candy',
        situation: 'Получил карманные деньги',
        text: 'Купить конфеты',
        icon: '🍭',
        effects: ChoiceEffect(money: -1, knowledge: 0, energy: 1),
      ),
      ChoiceCard(
        id: 'money_book',
        situation: 'Получил карманные деньги',
        text: 'Купить книгу',
        icon: '📚',
        effects: ChoiceEffect(money: -1, knowledge: 1, energy: 0),
      ),
      
      // В магазине
      ChoiceCard(
        id: 'shop_compare',
        situation: 'В магазине',
        text: 'Сравнить цены',
        icon: '🔍',
        effects: ChoiceEffect(money: 1, knowledge: 1, energy: 0),
      ),
      ChoiceCard(
        id: 'shop_first',
        situation: 'В магазине',
        text: 'Купить первое понравившееся',
        icon: '💸',
        effects: ChoiceEffect(money: -1, knowledge: 0, energy: 1),
      ),
      ChoiceCard(
        id: 'shop_wait',
        situation: 'В магазине',
        text: 'Подождать скидки',
        icon: '⏰',
        effects: ChoiceEffect(money: 1, knowledge: 0, energy: -1),
      ),
      
      // Перед сном
      ChoiceCard(
        id: 'sleep_early',
        situation: 'Перед сном',
        text: 'Лечь спать вовремя',
        icon: '😴',
        effects: ChoiceEffect(money: 0, knowledge: 0, energy: 1),
      ),
      ChoiceCard(
        id: 'sleep_late',
        situation: 'Перед сном',
        text: 'Ещё немного поиграть',
        icon: '🌙',
        effects: ChoiceEffect(money: 0, knowledge: 0, energy: -1),
      ),
      ChoiceCard(
        id: 'sleep_plan',
        situation: 'Перед сном',
        text: 'Спланировать завтрашний день',
        icon: '📅',
        effects: ChoiceEffect(money: 0, knowledge: 1, energy: 0),
      ),
    ];
  }
  
  /// Получить базовых персонажей
  static List<GameCharacter> getDefaultCharacters() {
    return [
      GameCharacter(
        id: 'boy_max',
        name: 'Макс',
        icon: '👦',
        description: 'Весёлый мальчик',
        animations: {},
      ),
      GameCharacter(
        id: 'girl_masha',
        name: 'Маша',
        icon: '👧',
        description: 'Умная девочка',
        animations: {},
      ),
      GameCharacter(
        id: 'lion_leva',
        name: 'Лёва',
        icon: '🦁',
        description: 'Смелый лев',
        animations: {},
      ),
      GameCharacter(
        id: 'robot_robi',
        name: 'Роби',
        icon: '🤖',
        description: 'Умный робот',
        animations: {},
      ),
    ];
  }
  
  /// Получить базовые титулы
  static List<GameTitle> getDefaultTitles() {
    return [
      GameTitle(
        id: 'money_master',
        name: 'Финансовый гений',
        icon: '💰',
        description: 'Отлично управляешь деньгами!',
        conditions: TitleConditions(moneyMin: 4),
      ),
      GameTitle(
        id: 'knowledge_master',
        name: 'Учёная сова',
        icon: '🦉',
        description: 'Любишь учиться и знать больше!',
        conditions: TitleConditions(knowledgeMin: 4),
      ),
      GameTitle(
        id: 'energy_master',
        name: 'Энерджайзер',
        icon: '⚡',
        description: 'Полон энергии и жизни!',
        conditions: TitleConditions(energyMin: 4),
      ),
      GameTitle(
        id: 'balanced',
        name: 'Гармоничная личность',
        icon: '⚖️',
        description: 'Умеешь всё совмещать!',
        conditions: TitleConditions(moneyMin: 3, knowledgeMin: 3, energyMin: 3),
      ),
      GameTitle(
        id: 'millionaire',
        name: 'Юный миллионер',
        icon: '🏆',
        description: 'Настоящий миллионер во всём!',
        conditions: TitleConditions(moneyMin: 5, knowledgeMin: 4, energyMin: 4),
      ),
      GameTitle(
        id: 'beginner',
        name: 'Начинающий мудрец',
        icon: '🌟',
        description: 'Отличное начало пути!',
        conditions: TitleConditions(moneyMin: 2),
      ),
      GameTitle(
        id: 'dreamer',
        name: 'Большой мечтатель',
        icon: '☁️',
        description: 'Главное - не останавливаться!',
        conditions: TitleConditions(),
      ),
    ];
  }
} 