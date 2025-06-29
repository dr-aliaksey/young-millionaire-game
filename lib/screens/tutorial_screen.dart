import 'package:flutter/material.dart';
import '../main.dart';
import '../models/choice_card.dart';
import '../services/game_service.dart';
import 'game_screen.dart';

/// Экран обучения правилам игры
class TutorialScreen extends StatefulWidget {
  final GameCharacter selectedCharacter;
  
  const TutorialScreen({
    super.key,
    required this.selectedCharacter,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Настройка анимаций
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    // Запуск анимаций
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Начать игру
  Future<void> _startGame() async {
    try {
      final gameService = GameService();
      final success = await gameService.startNewGame(widget.selectedCharacter.id);
      
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GameScreen(),
          ),
        );
      } else {
        _showError('Не удалось начать игру');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
  }

  /// Показать ошибку
  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    child: Column(
                      children: [
                        // Персонаж и приветствие
                        _buildCharacterGreeting(),
                        
                        const SizedBox(height: 32),
                        
                        // Объяснение правил
                        _buildRulesExplanation(),
                        
                        const SizedBox(height: 32),
                        
                        // Демонстрация шкал
                        _buildStatsDemo(),
                        
                        const SizedBox(height: 32),
                        
                        // Пример выбора
                        _buildChoiceExample(),
                      ],
                    ),
                  ),
                ),
                
                // Кнопка "Начать игру"
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Понятно! Начинаем!'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Персонаж и приветствие
  Widget _buildCharacterGreeting() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
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
          // Персонаж
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                widget.selectedCharacter.icon,
                style: const TextStyle(fontSize: 50),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Приветствие
          Text(
            'Привет! Я ${widget.selectedCharacter.name}!',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Давай я расскажу тебе, как играть!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textDark.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Объяснение правил
  Widget _buildRulesExplanation() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
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
            'Делай умные выборы и стань миллионером!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.accentOrange,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'В каждом раунде тебе нужно выбрать одно из действий. Каждый выбор влияет на твои показатели.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Демонстрация шкал
  Widget _buildStatsDemo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
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
            'Следи за своими показателями:',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Шкалы
          _buildStatBar('💰', 'Деньги', 'Финансовая грамотность', AppColors.moneyYellow, 3),
          const SizedBox(height: 12),
          _buildStatBar('📘', 'Знания', 'Умственное развитие', AppColors.knowledgeBlue, 3),
          const SizedBox(height: 12),
          _buildStatBar('💡', 'Энергия', 'Здоровье и настроение', AppColors.energyOrange, 3),
        ],
      ),
    );
  }

  /// Создать шкалу статистики
  Widget _buildStatBar(String icon, String title, String description, Color color, int value) {
    return Row(
      children: [
        // Иконка
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Информация
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textDark.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        
        // Шкала
        Row(
          children: List.generate(5, (index) {
            return Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index < value ? color : color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Пример выбора
  Widget _buildChoiceExample() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
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
            'Пример ситуации:',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"Утром проснулся"',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Варианты выбора
          Row(
            children: [
              Expanded(
                child: _buildExampleChoice(
                  '🛏️',
                  'Поспать ещё',
                  '💡+1 📘-1',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildExampleChoice(
                  '🏃',
                  'Зарядка',
                  '💡+1',
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Каждый выбор изменит твои показатели по-разному!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textDark.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Создать пример выбора
  Widget _buildExampleChoice(String icon, String text, String effect, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            effect,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 