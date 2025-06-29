import 'package:flutter/material.dart';
import '../main.dart';
import '../models/choice_card.dart';
import '../services/game_service.dart';
import 'tutorial_screen.dart';

/// Экран выбора персонажа
class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  State<CharacterSelectionScreen> createState() => _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final GameService _gameService = GameService();
  List<GameCharacter> _characters = [];
  GameCharacter? _selectedCharacter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Настройка анимаций
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _loadCharacters();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// Загрузить персонажей
  Future<void> _loadCharacters() async {
    try {
      _characters = _gameService.getAvailableCharacters();
      
      // Если персонажи не загружены, создаем базовых
      if (_characters.isEmpty) {
        _characters = _getDefaultCharacters();
      }
      
      setState(() {
        _isLoading = false;
      });
      
      // Запуск анимаций
      _slideController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _scaleController.forward();
      
    } catch (e) {
      print('Ошибка загрузки персонажей: $e');
      setState(() {
        _isLoading = false;
        _characters = _getDefaultCharacters();
      });
    }
  }

  /// Получить базовых персонажей (если Firebase недоступен)
  List<GameCharacter> _getDefaultCharacters() {
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

  /// Выбрать персонажа
  void _selectCharacter(GameCharacter character) {
    setState(() {
      _selectedCharacter = character;
    });
  }

  /// Подтвердить выбор и перейти к обучению
  void _confirmSelection() {
    if (_selectedCharacter == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TutorialScreen(
          selectedCharacter: _selectedCharacter!,
        ),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Text(
                AppTexts.chooseCharacter,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),
            
            // Персонажи
            Expanded(
              flex: 3,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _characters.length,
                    itemBuilder: (context, index) {
                      final character = _characters[index];
                      final isSelected = _selectedCharacter?.id == character.id;
                      
                      return _buildCharacterCard(character, isSelected);
                    },
                  ),
                ),
              ),
            ),
            
            // Описание выбранного персонажа
            if (_selectedCharacter != null) ...[
              Container(
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
                    Text(
                      _selectedCharacter!.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedCharacter!.name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            _selectedCharacter!.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textDark.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
            ],
            
            // Кнопка продолжения
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedCharacter != null ? _confirmSelection : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCharacter != null 
                        ? AppColors.accentOrange 
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(
                    _selectedCharacter != null 
                        ? 'Продолжить с ${_selectedCharacter!.name}'
                        : 'Выбери персонажа',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Создать карточку персонажа
  Widget _buildCharacterCard(GameCharacter character, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectCharacter(character),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.accentOrange : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.accentOrange.withOpacity(0.3)
                  : AppColors.primaryBlue.withOpacity(0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Иконка персонажа
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.accentOrange.withOpacity(0.1)
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Text(
                    character.icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Имя персонажа
            Text(
              character.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                color: isSelected ? AppColors.accentOrange : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Описание
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                character.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textDark.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Кнопка "Выбери меня!"
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppTexts.selectMe,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.textDark.withOpacity(0.3)),
                ),
                child: Text(
                  'Нажми для выбора',
                  style: TextStyle(
                    color: AppColors.textDark.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 