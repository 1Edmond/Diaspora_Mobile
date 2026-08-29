import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../controllers/auth_restore_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Bienvenue sur Diaspora',
      description:
          'La plateforme tout-en-un pour la communauté togolaise à l\'étranger.',
      icon: Icons.public_rounded,
      color: AppColors.primary,
    ),
    OnboardingData(
      title: 'Gérez vos Finances',
      description:
          'Transférez de l\'argent en toute sécurité et gérez votre portefeuille multi-devises.',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.secondary,
    ),
    OnboardingData(
      title: 'Restez Connecté',
      description:
          'Échangez avec vos proches et participez aux événements de la communauté.',
      icon: Icons.forum_rounded,
      color: AppColors.accent,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await markOnboardingSeen();
    if (!mounted) return;
    GoRouter.of(context).go('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  onPageChanged: (v) => setState(() => _currentPage = v),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) => _buildPage(_pages[index]),
                ),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedContainer(
      duration: 500.ms,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _pages[_currentPage].color.withValues(alpha: 0.1),
            AppColors.getBackground(context),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: AppShadows.neumorphic(),
              ),
              child: Icon(data.icon, size: 80, color: data.color),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .rotate(begin: -0.1, end: 0),
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextMain(context),
                  ),
                ).animate().fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 16),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.getTextSecondary(context),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 50,
      left: 30,
      right: 30,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: 300.ms,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color:
                      _currentPage == index
                          ? AppColors.primary
                          : AppColors.getTextSecondary(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _finishOnboarding(),
                  child: Text(
                    'Passer',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: NeumorphicContainer(
                  borderRadius: 16,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _controller.nextPage(
                          duration: 500.ms,
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Commencer'
                          : 'Suivant',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}