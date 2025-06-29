const admin = require('firebase-admin');

// Инициализация Firebase Admin SDK
admin.initializeApp({
  projectId: 'young-millionaire'
});

const db = admin.firestore();

// Игровые персонажи
const characters = [
  {
    id: 'boy_max',
    name: 'Макс',
    icon: '👦',
    description: 'Весёлый мальчик',
    animations: {}
  },
  {
    id: 'girl_masha',
    name: 'Маша',
    icon: '👧',
    description: 'Умная девочка',
    animations: {}
  },
  {
    id: 'lion_leva',
    name: 'Лёва',
    icon: '🦁',
    description: 'Смелый лев',
    animations: {}
  },
  {
    id: 'robot_robi',
    name: 'Роби',
    icon: '🤖',
    description: 'Умный робот',
    animations: {}
  }
];

// Карточки выбора
const choices = [
  // Утром проснулся
  {
    id: 'morning_sleep',
    situation: 'Утром проснулся',
    text: 'Поспать ещё',
    icon: '🛏️',
    effects: { money: 0, knowledge: -1, energy: 1 }
  },
  {
    id: 'morning_exercise',
    situation: 'Утром проснулся',
    text: 'Сделать зарядку',
    icon: '🏃',
    effects: { money: 0, knowledge: 0, energy: 1 }
  },
  {
    id: 'morning_study',
    situation: 'Утром проснулся',
    text: 'Почитать книгу',
    icon: '📖',
    effects: { money: 0, knowledge: 1, energy: 0 }
  },
  
  // В школе
  {
    id: 'school_attention',
    situation: 'В школе на уроке',
    text: 'Слушать учителя',
    icon: '👂',
    effects: { money: 0, knowledge: 1, energy: 0 }
  },
  {
    id: 'school_play',
    situation: 'В школе на уроке',
    text: 'Играть в телефон',
    icon: '📱',
    effects: { money: 0, knowledge: -1, energy: 0 }
  },
  {
    id: 'school_help',
    situation: 'В школе на уроке',
    text: 'Помочь другу',
    icon: '🤝',
    effects: { money: 0, knowledge: 0, energy: 1 }
  },
  
  // После школы
  {
    id: 'after_homework',
    situation: 'После школы',
    text: 'Сделать домашку',
    icon: '📝',
    effects: { money: 0, knowledge: 1, energy: -1 }
  },
  {
    id: 'after_walk',
    situation: 'После школы',
    text: 'Погулять с друзьями',
    icon: '🚶',
    effects: { money: 0, knowledge: 0, energy: 1 }
  }
];

// Титулы
const titles = [
  {
    id: 'balanced_hero',
    name: 'Гармоничный Герой',
    icon: '⭐',
    description: 'Ты нашёл идеальный баланс!',
    conditions: {
      money_min: 3,
      knowledge_min: 3,
      energy_min: 3
    }
  },
  {
    id: 'money_master',
    name: 'Король Денег',
    icon: '💰',
    description: 'Отлично управляешь финансами!',
    conditions: {
      money_min: 4
    }
  },
  {
    id: 'smart_genius',
    name: 'Умный Гений',
    icon: '🧠',
    description: 'Знания - твоя сила!',
    conditions: {
      knowledge_min: 4
    }
  },
  {
    id: 'energy_champion',
    name: 'Чемпион Энергии',
    icon: '⚡',
    description: 'У тебя неиссякаемая энергия!',
    conditions: {
      energy_min: 4
    }
  }
];

// Функция загрузки данных
async function uploadGameData() {
  try {
    console.log('🚀 Начинаем загрузку игровых данных...');
    
    // Загружаем персонажей
    console.log('📋 Загружаем персонажей...');
    for (const character of characters) {
      await db.collection('characters').doc(character.id).set(character);
      console.log(`✅ Персонаж ${character.name} загружен`);
    }
    
    // Загружаем карточки выбора
    console.log('🎴 Загружаем карточки выбора...');
    for (const choice of choices) {
      await db.collection('choices').doc(choice.id).set(choice);
      console.log(`✅ Карточка "${choice.text}" загружена`);
    }
    
    // Загружаем титулы
    console.log('🏆 Загружаем титулы...');
    for (const title of titles) {
      await db.collection('titles').doc(title.id).set(title);
      console.log(`✅ Титул "${title.name}" загружен`);
    }
    
    console.log('🎉 Все данные успешно загружены в Firestore!');
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Ошибка загрузки данных:', error);
    process.exit(1);
  }
}

// Запуск загрузки
uploadGameData(); 