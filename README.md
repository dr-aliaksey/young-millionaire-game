# 🎮 Стань миллионером | Young Millionaire Game

[![Flutter](https://img.shields.io/badge/Flutter-3.32.0-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-integrated-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> 🧒 Образовательная игра для детей 5-9 лет о выборе, последствиях и управлении ресурсами

## 📱 О проекте

**"Стань миллионером"** — это интерактивная образовательная игра, которая учит детей принимать решения и понимать их последствия через увлекательный геймплей. Игра помогает развивать финансовую грамотность, критическое мышление и навыки планирования.

### ✨ Основные возможности

- 🎯 **7 игровых раундов** с различными жизненными ситуациями
- 📊 **3 шкалы ресурсов**: 💰 Деньги, 📘 Знания, 💡 Энергия  
- 👥 **4 игровых персонажа**: Макс, Маша, Лёва-лев, Роби-робот
- 🏆 **Система достижений** с уникальными титулами
- 🎨 **Детский дружелюбный интерфейс** с анимациями
- 🔄 **Локальный + Firebase режимы** работы
- 🌐 **Мультиплатформенность**: Web, iOS, Android, macOS, Windows

## 🎮 Геймплей

1. **Выбор персонажа** - выберите своего героя из 4 доступных
2. **Обучение** - узнайте правила через интерактивный туториал  
3. **7 раундов игры** - принимайте решения в различных ситуациях:
   - 🌅 Утренние ритуалы
   - 🏫 Школьные ситуации  
   - 🏠 После школы
   - 🎭 Выходные активности
   - 💰 Управление деньгами
   - 🛒 Покупки и выбор
   - 🌙 Планирование времени
4. **Получение титула** - узнайте свой результат и достижения

## 🛠 Технологический стек

- **Framework**: Flutter 3.32.0
- **Language**: Dart with null safety
- **Backend**: Firebase (Authentication, Firestore, Analytics)
- **State Management**: Built-in StatefulWidget
- **Architecture**: Service-based with Models
- **Platforms**: Web, iOS, Android, macOS, Windows, Linux

## 🚀 Установка и запуск

### Предварительные требования

- Flutter SDK 3.32.0+
- Dart SDK 3.8.0+
- Firebase проект (для полной функциональности)

### Локальная установка

```bash
# Клонируйте репозиторий
git clone https://github.com/dr-aliaksey/young-millionaire-game.git
cd young-millionaire-game

# Установите зависимости
flutter pub get

# Запустите на веб-платформе
flutter run -d chrome

# Или на эмуляторе/устройстве
flutter run
```

### Firebase настройка (опционально)

1. Создайте проект в [Firebase Console](https://console.firebase.google.com/)
2. Включите Authentication (Anonymous) и Firestore
3. Настройте FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

## 📂 Структура проекта

```
lib/
├── data/                   # Локальные игровые данные
├── models/                 # Модели данных
│   ├── player.dart        # Игрок и статистика  
│   └── choice_card.dart   # Карточки выбора
├── screens/               # Экраны приложения
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── character_selection_screen.dart
│   ├── tutorial_screen.dart
│   ├── game_screen.dart
│   └── result_screen.dart
├── services/              # Бизнес-логика
│   ├── firebase_service.dart
│   └── game_service.dart
└── main.dart             # Точка входа
```

## 🎯 Игровая механика

### Система ресурсов
- **💰 Деньги (1-5)**: Финансовая грамотность и экономия
- **📘 Знания (1-5)**: Обучение и развитие навыков  
- **💡 Энергия (1-5)**: Здоровье и активность

### Система титулов
- 🌟 **Гармоничный Герой**: Баланс всех ресурсов
- 💰 **Король Денег**: Мастер финансов
- 🧠 **Умный Гений**: Эксперт знаний
- ⚡ **Чемпион Энергии**: Энергичный лидер

## 🤝 Участие в разработке

Мы приветствуем вклад в проект! Вот как вы можете помочь:

1. 🍴 Форкните репозиторий
2. 🔧 Создайте ветку для новой функции (`git checkout -b feature/amazing-feature`)
3. 💾 Закоммитьте изменения (`git commit -m 'Add amazing feature'`)
4. 📤 Запушьте в ветку (`git push origin feature/amazing-feature`)
5. 🔄 Создайте Pull Request

### Области для улучшения
- 🎵 Добавление звуковых эффектов
- 🎨 Улучшение анимаций
- 🌍 Локализация на другие языки
- 📱 Оптимизация для планшетов
- 🎯 Новые игровые механики

## 📊 Roadmap

- [ ] 🎵 Звуковые эффекты и музыка
- [ ] 🎨 Анимированные персонажи
- [ ] 👨‍👩‍👧‍👦 Родительская панель
- [ ] 📈 Расширенная аналитика
- [ ] 🌍 Многоязычность (EN, ES, FR)
- [ ] 📱 Мобильные приложения в App Store/Google Play

## 📄 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE) для подробностей.

## 👥 Авторы

- **Dr. Aliaksey** - *Initial work* - [@dr-aliaksey](https://github.com/dr-aliaksey)

## 🙏 Благодарности

- Flutter команде за отличный фреймворк
- Firebase за бэкенд инфраструктуру  
- Всем тестировщикам и детям, которые помогли улучшить игру

## 📞 Поддержка

Если у вас есть вопросы или предложения:
- 📧 Email: 1blazi@gmail.com
- 🐛 [Issues](https://github.com/dr-aliaksey/young-millionaire-game/issues)
- 💬 [Discussions](https://github.com/dr-aliaksey/young-millionaire-game/discussions)

---

⭐ **Поставьте звездочку, если проект понравился!** ⭐
