import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/firebase_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Firebase
  await FirebaseService.initialize();
  
  // Настройка ориентации экрана (только портретная)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const YoungMillionaireApp());
}

class YoungMillionaireApp extends StatelessWidget {
  const YoungMillionaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Стань миллионером',
      debugShowCheckedModeBanner: false,
      
      // Тема для детского приложения
      theme: ThemeData(
        // Основные цвета согласно MVP_GAME_SCENARIO.md
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3), // Яркий синий
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2196F3),      // Синий
          secondary: Color(0xFFFF9800),    // Оранжевый для кнопок
          surface: Color(0xFFE3F2FD),      // Светло-голубой фон
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF1976D2),
        ),
        
        // Шрифты (используем стандартные)
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Color(0xFF1976D2),
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Color(0xFF1976D2),
          ),
        ),

        // Кнопки
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800), // Оранжевый
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            minimumSize: const Size(120, 60), // Большие кнопки для детей
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
        ),

        // Карточки
        cardTheme: const CardThemeData(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          margin: EdgeInsets.all(8),
        ),
      ),

      // Стартовый экран
      home: const SplashScreen(),
    );
  }
}

/// Константы цветов для удобства
class AppColors {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color backgroundLight = Color(0xFFE3F2FD);
  static const Color textDark = Color(0xFF1976D2);
  
  // Цвета для шкал ресурсов
  static const Color moneyYellow = Color(0xFFFFC107);
  static const Color knowledgeBlue = Color(0xFF2196F3);
  static const Color energyOrange = Color(0xFFFF5722);
  
  // Дополнительные цвета
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
}

/// Константы размеров
class AppSizes {
  // Отступы
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  // Размеры кнопок
  static const double buttonHeight = 60.0;
  static const double buttonMinWidth = 120.0;
  
  // Иконки
  static const double iconSmall = 24.0;
  static const double iconMedium = 32.0;
  static const double iconLarge = 48.0;
  static const double iconExtraLarge = 64.0;
  
  // Радиусы скругления
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
}

/// Константы текстов
class AppTexts {
  // Общие
  static const String appName = 'Стань миллионером';
  static const String loading = 'Загрузка...';
  static const String error = 'Произошла ошибка';
  static const String retry = 'Попробовать снова';
  static const String next = 'Дальше →';
  static const String back = '← Назад';
  static const String close = 'Закрыть';
  
  // Главный экран
  static const String welcomeTitle = 'Привет! Давай играть!';
  static const String playButton = '🎮 ИГРАТЬ';
  
  // Выбор персонажа
  static const String chooseCharacter = 'Выбери своего героя!';
  static const String selectMe = 'Выбери меня!';
  
  // Игра
  static const String makeChoice = 'Что будешь делать?';
  static const String gameCompleted = 'Игра завершена!';
  
  // Финал
  static const String congratulations = 'Поздравляю!';
  static const String playAgain = '🔄 Играть снова';
  static const String saveResult = '📸 Сохранить результат';
  
  // Реакции персонажа
  static const String goodChoice = 'Отлично! Я становлюсь лучше!';
  static const String badChoice = 'Ой, не очень хорошо получилось...';
  static const String neutralChoice = 'Интересно, что будет дальше?';
}
