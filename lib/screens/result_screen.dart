import 'package:flutter/material.dart';
import '../main.dart';
import '../models/choice_card.dart';
import '../services/game_service.dart';
import 'character_selection_screen.dart';
import 'home_screen.dart';

/// Экран результатов игры
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _slideController;
  late Animation<double> _celebrationAnimation;
  late Animation<Offset> _slideAnimation;

  final GameService _gameService = GameService();
  
  GameStats? _gameStats;
  GameTitle? _earnedTitle;
  GameCharacter? _character;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Настройка анимаций
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _loadResults();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Загрузить результаты игры
  Future<void> _loadResults() async {
    try {
      _gameStats = _gameService.getGameStats();
      _earnedTitle = await _gameService.getFinalTitle();
      _character = _gameStats?.character;

      setState(() {
        _isLoading = false;
      });

      // Запуск анимаций
      _slideController.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      _celebrationController.forward();

    } catch (e) {
      print('Ошибка загрузки результатов: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Начать новую игру
  void _playAgain() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const CharacterSelectionScreen(),
      ),
      (route) => false,
    );
  }

  /// Вернуться в главное меню
  void _backToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  /// Поделиться результатом (заглушка)
  void _shareResult() {
    if (_earnedTitle == null || _gameStats == null) return;
    
    // TODO: Реализовать функционал шаринга
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция "Поделиться" будет добавлена в следующих версиях!'),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Поздравление
                      _buildCongratulations(),
                      
                      const SizedBox(height: 32),
                      
                      // Титул и медаль
                      _buildTitleCard(),
                      
                      const SizedBox(height: 32),
                      
                      // Финальные статистики
                      _buildFinalStats(),
                      
                      const SizedBox(height: 32),
                      
                      // Достижения и статистика
                      _buildAchievements(),
                    ],
                  ),
                ),
              ),
              
              // Кнопки действий
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Поздравление
  Widget _buildCongratulations() {
    return ScaleTransition(
      scale: _celebrationAnimation,
      child: Column(
        children: [
          // Конфетти эмодзи
          const Text(
            '🎉 🎊 🏆 🎊 🎉',
            style: TextStyle(fontSize: 32),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            AppTexts.congratulations,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.accentOrange,
              fontSize: 32,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _getCongratulatoryMessage(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textDark.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Получить поздравительное сообщение
  String _getCongratulatoryMessage() {
    if (_gameStats == null) return AppTexts.gameCompleted;
    
    final totalScore = _gameStats!.currentStats.totalScore;
    
    if (totalScore >= 13) {
      return 'Отлично! Ты настоящий миллионер!';
    } else if (totalScore >= 10) {
      return 'Хорошо! В следующий раз будет ещё лучше!';
    } else {
      return 'Отлично! Теперь ты знаешь, как играть!';
    }
  }

  /// Карточка титула
  Widget _buildTitleCard() {
    if (_earnedTitle == null || _character == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_celebrationAnimation.value * 0.2),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentOrange,
                  AppColors.accentOrange.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentOrange.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: Text(
                      _character!.icon,
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Иконка титула
                Text(
                  _earnedTitle!.icon,
                  style: const TextStyle(fontSize: 40),
                ),
                
                const SizedBox(height: 8),
                
                // Название титула
                Text(
                  _earnedTitle!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Описание титула
                Text(
                  _earnedTitle!.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Финальные статистики
  Widget _buildFinalStats() {
    if (_gameStats == null) return const SizedBox.shrink();

    final stats = _gameStats!.currentStats;

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
            'Твои итоговые показатели:',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Статистики
          _buildFinalStatRow('💰', 'Деньги', stats.money, AppColors.moneyYellow),
          const SizedBox(height: 16),
          _buildFinalStatRow('📘', 'Знания', stats.knowledge, AppColors.knowledgeBlue),
          const SizedBox(height: 16),
          _buildFinalStatRow('💡', 'Энергия', stats.energy, AppColors.energyOrange),
          
          const SizedBox(height: 20),
          
          // Общий балл
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Общий балл:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${stats.totalScore}/15',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Строка финальной статистики
  Widget _buildFinalStatRow(String icon, String title, int value, Color color) {
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
        
        const SizedBox(width: 16),
        
        // Название
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Значение
        Text(
          '$value/5',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Звезды
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < value ? Icons.star : Icons.star_border,
              color: color,
              size: 20,
            );
          }),
        ),
      ],
    );
  }

  /// Достижения
  Widget _buildAchievements() {
    if (_gameStats == null) return const SizedBox.shrink();

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
            'Статистика игры:',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildAchievementCard(
                  '🎯',
                  'Раундов сыграно',
                  '${_gameStats!.totalRounds}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAchievementCard(
                  '⭐',
                  'Лучший показатель',
                  _gameStats!.bestStat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Карточка достижения
  Widget _buildAchievementCard(String icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textDark.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.accentOrange,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Кнопки действий
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          // Кнопка "Играть снова"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _playAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text(AppTexts.playAgain),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Дополнительные кнопки
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _shareResult,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(AppTexts.saveResult),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: OutlinedButton(
                  onPressed: _backToHome,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side: BorderSide(color: AppColors.textDark.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('В меню'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 