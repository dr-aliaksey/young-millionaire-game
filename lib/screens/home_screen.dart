import 'package:flutter/material.dart';
import '../main.dart';
import '../services/game_service.dart';
import 'character_selection_screen.dart';

/// Главный экран приложения
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;
  
  final GameService _gameService = GameService();

  @override
  void initState() {
    super.initState();
    
    // Настройка анимаций
    _bounceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 15.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    // Запуск анимаций
    _fadeController.forward();
    _bounceController.repeat(reverse: true);
    
    // Проверяем, есть ли сохраненная игра
    _checkSavedGame();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Проверить наличие сохраненной игры
  Future<void> _checkSavedGame() async {
    try {
      final hasGame = await _gameService.loadCurrentGame();
      // TODO: Показать кнопку "Продолжить" если есть сохраненная игра
      print('Сохраненная игра: $hasGame');
    } catch (e) {
      print('Ошибка проверки сохраненной игры: $e');
    }
  }

  /// Начать новую игру
  void _startNewGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CharacterSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const Spacer(flex: 1),
              
              // Заголовок
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
                child: Text(
                  AppTexts.welcomeTitle,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Анимированный персонаж
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_bounceAnimation.value),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '🎮', // Временная иконка, потом заменим на анимацию
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Описание игры
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
                child: Text(
                  'Делай умные выборы и стань миллионером!\nКаждое решение влияет на твой успех.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textDark.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Кнопка "Играть"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startNewGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🎮'),
                        const SizedBox(width: 12),
                        const Text('ИГРАТЬ'),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Дополнительные кнопки (пока скрыты)
              // TODO: Добавить кнопки "Продолжить", "Настройки" в будущих версиях
              
              const Spacer(flex: 1),
              
              // Информационные карточки внизу
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: '💰',
                        title: 'Деньги',
                        description: 'Учись зарабатывать',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: '📘',
                        title: 'Знания',
                        description: 'Развивай свой ум',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: '💡',
                        title: 'Энергия',
                        description: 'Береги здоровье',
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }

  /// Создать информационную карточку
  Widget _buildInfoCard({
    required String icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textDark.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 