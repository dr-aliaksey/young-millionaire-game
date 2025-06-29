import 'package:flutter/material.dart';
import '../main.dart';
import '../services/game_service.dart';
import 'home_screen.dart';

/// Экран загрузки и инициализации
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  String _statusText = AppTexts.loading;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    
    // Настройка анимаций
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    // Запуск анимации и инициализации
    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Инициализация приложения
  Future<void> _initializeApp() async {
    try {
      setState(() {
        _statusText = 'Загружаем игровые данные...';
      });

      // Инициализация игрового сервиса
      final gameService = GameService();
      final success = await gameService.initialize();
      
      if (!success) {
        throw Exception('Не удалось загрузить игровые данные');
      }

      setState(() {
        _statusText = 'Подготавливаем игру...';
      });

      // Дополнительная задержка для показа анимации
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        // Переход на главный экран
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
      
    } catch (e) {
      setState(() {
        _hasError = true;
        _statusText = 'Ошибка загрузки: ${e.toString()}';
      });
      
      print('Ошибка инициализации: $e');
    }
  }

  /// Повторить инициализацию
  void _retry() {
    setState(() {
      _hasError = false;
      _statusText = AppTexts.loading;
    });
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            
            // Логотип и анимация
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Иконка приложения
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentOrange.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Название игры
                        Text(
                          AppTexts.appName,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Подзаголовок
                        Text(
                          'Обучающая игра для детей',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textDark.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const Spacer(flex: 2),
            
            // Индикатор загрузки или ошибка
            if (!_hasError) ...[
              // Индикатор загрузки
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
                strokeWidth: 4,
              ),
              
              const SizedBox(height: 16),
              
              // Текст статуса
              Text(
                _statusText,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ] else ...[
              // Ошибка и кнопка повтора
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _statusText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _retry,
                child: const Text(AppTexts.retry),
              ),
            ],
            
            const Spacer(flex: 1),
            
            // Информация о версии
            Text(
              'Версия 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textDark.withOpacity(0.5),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 