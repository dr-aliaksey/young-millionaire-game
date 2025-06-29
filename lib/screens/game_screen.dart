import 'package:flutter/material.dart';
import '../main.dart';
import '../models/choice_card.dart';
import '../models/player.dart';
import '../services/game_service.dart';
import 'result_screen.dart';

/// Основной игровой экран
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  final GameService _gameService = GameService();
  
  GameCharacter? _character;
  Player? _currentPlayer;
  List<ChoiceCard> _currentChoices = [];
  bool _isLoading = true;
  bool _isProcessingChoice = false;

  @override
  void initState() {
    super.initState();
    
    // Настройка анимаций
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
    
    _loadGameData();
    _bounceController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  /// Загрузить данные игры
  Future<void> _loadGameData() async {
    try {
      _currentPlayer = _gameService.currentPlayer;
      
      if (_currentPlayer == null) {
        _showError('Игрок не найден');
        return;
      }

      _character = _gameService.getCharacterById(_currentPlayer!.character);
      _currentChoices = _gameService.getChoicesForCurrentRound();

      setState(() {
        _isLoading = false;
      });

      // Запуск анимации появления карточек
      _slideController.forward();

    } catch (e) {
      print('Ошибка загрузки игры: $e');
      _showError('Ошибка загрузки: $e');
    }
  }

  /// Сделать выбор
  Future<void> _makeChoice(ChoiceCard choice) async {
    if (_isProcessingChoice) return;

    setState(() {
      _isProcessingChoice = true;
    });

    try {
      final success = await _gameService.makeChoice(choice);
      
      if (success) {
        // Обновляем данные
        _currentPlayer = _gameService.currentPlayer;
        
        // Показываем реакцию персонажа
        await _showChoiceReaction(choice);
        
        // Проверяем, завершена ли игра
        if (_gameService.isGameCompleted) {
          _navigateToResults();
        } else {
          // Переходим к следующему раунду
          _loadNextRound();
        }
      } else {
        _showError('Не удалось сохранить выбор');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }

    setState(() {
      _isProcessingChoice = false;
    });
  }

  /// Показать реакцию на выбор
  Future<void> _showChoiceReaction(ChoiceCard choice) async {
    final hasPositiveEffect = choice.effects.money > 0 || 
                             choice.effects.knowledge > 0 || 
                             choice.effects.energy > 0;
    final hasNegativeEffect = choice.effects.money < 0 || 
                             choice.effects.knowledge < 0 || 
                             choice.effects.energy < 0;
    
    String reactionText;
    if (hasPositiveEffect && !hasNegativeEffect) {
      reactionText = AppTexts.goodChoice;
    } else if (hasNegativeEffect && !hasPositiveEffect) {
      reactionText = AppTexts.badChoice;
    } else {
      reactionText = AppTexts.neutralChoice;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ChoiceReactionDialog(
        character: _character!,
        reactionText: reactionText,
        effects: choice.effects,
        newStats: _currentPlayer!.currentStats,
      ),
    );
  }

  /// Загрузить следующий раунд
  void _loadNextRound() {
    _currentChoices = _gameService.getChoicesForCurrentRound();
    setState(() {});
    
    // Перезапуск анимации
    _slideController.reset();
    _slideController.forward();
  }

  /// Перейти к результатам
  void _navigateToResults() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ResultScreen(),
      ),
    );
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

    if (_currentPlayer == null || _character == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка загрузки игры',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Вернуться в меню'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок с прогрессом
            _buildHeader(),
            
            // Персонаж и статистики
            _buildCharacterStats(),
            
            // Ситуация
            _buildSituation(),
            
            // Варианты выбора
            Expanded(
              child: _buildChoiceCards(),
            ),
          ],
        ),
      ),
    );
  }

  /// Создать заголовок с прогрессом
  Widget _buildHeader() {
    final progress = _gameService.getGameProgress() / 100;
    
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          // Прогресс
          Row(
            children: [
              Text(
                _gameService.getProgressDescription(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(_gameService.getGameProgress()).round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.accentOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Полоса прогресса
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  /// Создать блок персонажа и статистик
  Widget _buildCharacterStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
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
      child: Row(
        children: [
          // Персонаж
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_bounceAnimation.value),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Text(
                      _character!.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 16),
          
          // Статистики
          Expanded(
            child: Column(
              children: [
                _buildStatRow('💰', 'Деньги', _currentPlayer!.currentStats.money, AppColors.moneyYellow),
                const SizedBox(height: 8),
                _buildStatRow('📘', 'Знания', _currentPlayer!.currentStats.knowledge, AppColors.knowledgeBlue),
                const SizedBox(height: 8),
                _buildStatRow('💡', 'Энергия', _currentPlayer!.currentStats.energy, AppColors.energyOrange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Создать строку статистики
  Widget _buildStatRow(String icon, String title, int value, Color color) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            return Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: index < value ? color : color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Создать блок ситуации
  Widget _buildSituation() {
    if (_currentChoices.isEmpty) return const SizedBox.shrink();
    
    final situation = _currentChoices.first.situation;
    
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingLarge),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.accentOrange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            situation,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.accentOrange,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppTexts.makeChoice,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textDark.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Создать карточки выбора
  Widget _buildChoiceCards() {
    if (_currentChoices.isEmpty) {
      return const Center(
        child: Text('Нет доступных выборов'),
      );
    }

    return SlideTransition(
      position: _slideAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        itemCount: _currentChoices.length,
        itemBuilder: (context, index) {
          final choice = _currentChoices[index];
          return _buildChoiceCard(choice);
        },
      ),
    );
  }

  /// Создать карточку выбора
  Widget _buildChoiceCard(ChoiceCard choice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: InkWell(
          onTap: _isProcessingChoice ? null : () => _makeChoice(choice),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Row(
              children: [
                // Иконка
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      choice.icon,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Текст и эффекты
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        choice.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildEffectsDisplay(choice.effects),
                    ],
                  ),
                ),
                
                // Стрелка
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textDark.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Создать отображение эффектов
  Widget _buildEffectsDisplay(ChoiceEffect effects) {
    final effectWidgets = <Widget>[];
    
    if (effects.money != 0) {
      effectWidgets.add(_buildEffectChip('💰', effects.money, AppColors.moneyYellow));
    }
    if (effects.knowledge != 0) {
      effectWidgets.add(_buildEffectChip('📘', effects.knowledge, AppColors.knowledgeBlue));
    }
    if (effects.energy != 0) {
      effectWidgets.add(_buildEffectChip('💡', effects.energy, AppColors.energyOrange));
    }
    
    return Wrap(
      spacing: 8,
      children: effectWidgets,
    );
  }

  /// Создать чип эффекта
  Widget _buildEffectChip(String icon, int value, Color color) {
    final isPositive = value > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '${isPositive ? '+' : ''}$value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// Диалог реакции на выбор
class _ChoiceReactionDialog extends StatelessWidget {
  final GameCharacter character;
  final String reactionText;
  final ChoiceEffect effects;
  final PlayerStats newStats;

  const _ChoiceReactionDialog({
    required this.character,
    required this.reactionText,
    required this.effects,
    required this.newStats,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Персонаж
            Text(
              character.icon,
              style: const TextStyle(fontSize: 60),
            ),
            
            const SizedBox(height: 16),
            
            // Реакция
            Text(
              reactionText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Изменения статистик
            if (effects.money != 0 || effects.knowledge != 0 || effects.energy != 0) ...[
              const Text('Изменения:'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (effects.money != 0)
                    _buildStatChange('💰', effects.money),
                  if (effects.knowledge != 0)
                    _buildStatChange('📘', effects.knowledge),
                  if (effects.energy != 0)
                    _buildStatChange('💡', effects.energy),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Кнопка продолжения
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppTexts.next),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChange(String icon, int change) {
    final isPositive = change > 0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          '${isPositive ? '+' : ''}$change',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPositive ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }
} 