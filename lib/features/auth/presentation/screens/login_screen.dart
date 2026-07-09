import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/constants/enums.dart';
import '../controllers/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController(text: '+228');
  final _password = TextEditingController();
  bool _isPhoneFocused = false;
  bool _isPasswordFocused = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient & Abstract Shapes
          _buildBackground(),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: GlassContainer(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(l10n),
                          const SizedBox(height: 40),

                          // Phone Input
                          _buildInputLabel(l10n.phoneHint),
                          const SizedBox(height: 8),
                          Focus(
                            onFocusChange:
                                (v) => setState(() => _isPhoneFocused = v),
                            child: NeumorphicContainer(
                              isPressed: _isPhoneFocused,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: TextField(
                                controller: _phone,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                          const SizedBox(height: 24),

                          // Password Input
                          _buildInputLabel(l10n.passwordHint),
                          const SizedBox(height: 8),
                          Focus(
                            onFocusChange:
                                (v) => setState(() => _isPasswordFocused = v),
                            child: NeumorphicContainer(
                              isPressed: _isPasswordFocused,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: TextField(
                                controller: _password,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                          const SizedBox(height: 40),

                          // Login Button
                          _buildLoginButton(l10n, auth.isLoading),

                          const SizedBox(height: 20),

                          TextButton(
                            onPressed: () => context.push('/auth/register'),
                            child: Text(
                              l10n.createAccount,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ).animate().fadeIn(delay: 700.ms),

                          const SizedBox(height: 12),
                          _buildErrorMessage(auth, l10n),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: _buildFloatingCircle(
              200,
              AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildFloatingCircle(
              250,
              AppColors.secondary.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCircle(double size, Color color) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(begin: 0, end: 20, duration: 3.seconds, curve: Curves.easeInOut);
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: const Icon(
            Icons.lock_person_rounded,
            color: Colors.white,
            size: 40,
          ),
        ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text(
          l10n.login,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n, bool isLoading) {
    return NeumorphicContainer(
      borderRadius: 16,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shadowColor: Colors.transparent,
        ),
        onPressed: isLoading ? null : _handleLogin,
        child:
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  l10n.loginButton,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  Future<void> _handleLogin() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    final ok = await ref
        .read(authNotifierProvider.notifier)
        .login(_phone.text.trim(), _password.text.trim());

    if (!mounted) return;
    if (ok) {
      final user = ref.read(authNotifierProvider).value;
      if (user?.internalProfile.status == ProfileStatus.VALIDATED) {
        context.go('/home');
      } else {
        messenger.showSnackBar(SnackBar(content: Text(l10n.accountPending)));
        context.go('/home');
      }
    }
  }

  Widget _buildErrorMessage(AsyncValue auth, AppLocalizations l10n) {
    return auth.when(
      data: (_) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
      error:
          (e, s) =>
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  '${l10n.errorPrefix}${e.toString()}',
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ).animate().shake(),
    );
  }
}
