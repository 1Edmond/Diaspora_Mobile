import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../core/localization/app_localizations.dart';
import '../controllers/auth_notifier.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _phone = TextEditingController(text: '+228');
  final _password = TextEditingController();
  String _userType = 'BOURSIER';
  bool _isPhoneFocused = false;
  bool _isPasswordFocused = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
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
                          const SizedBox(height: 32),

                          // Phone Field
                          _buildInputLabel(l10n.phoneHint, context),
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
                          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

                          const SizedBox(height: 20),

                          // Password Field
                          _buildInputLabel(l10n.passwordHint, context),
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
                          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                          const SizedBox(height: 20),

                          // User Type Dropdown
                          _buildInputLabel(l10n.userTypeLabel, context),
                          const SizedBox(height: 8),
                          NeumorphicContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _userType,
                                items: [
                                  DropdownMenuItem(
                                    value: 'BOURSIER',
                                    child: Text(l10n.userTypeScholar),
                                  ),
                                  DropdownMenuItem(
                                    value: 'CONTRACTUEL',
                                    child: Text(l10n.userTypeContractor),
                                  ),
                                ],
                                onChanged:
                                    (v) => setState(
                                      () => _userType = v ?? 'BOURSIER',
                                    ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                          const SizedBox(height: 40),

                          // Register Button
                          _buildRegisterButton(l10n, auth.isLoading),

                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: const Text(
                              'Déjà un compte ? Se connecter',
                              style: TextStyle(
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
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
                icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.getTextMain(context),
              ),
              onPressed: () => context.pop(),
            ).animate().fadeIn(delay: 800.ms),
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
            top: -50,
            left: -50,
            child: _buildFloatingCircle(
              200,
              AppColors.secondary.withValues(alpha: 0.2),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: _buildFloatingCircle(
              300,
              AppColors.primary.withValues(alpha: 0.3),
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
        .moveY(begin: 0, end: 30, duration: 4.seconds, curve: Curves.easeInOut);
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: const Icon(
            Icons.person_add_rounded,
            color: Colors.white,
            size: 35,
          ),
        ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text(
          l10n.register,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMain(context),
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildInputLabel(String label, BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.getTextSecondary(context),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(AppLocalizations l10n, bool isLoading) {
    return NeumorphicContainer(
      borderRadius: 16,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shadowColor: Colors.transparent,
        ),
        onPressed: isLoading ? null : _handleRegister,
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
                  l10n.register,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  Future<void> _handleRegister() async {
    await ref
        .read(authNotifierProvider.notifier)
        .register(_phone.text.trim(), _password.text.trim(), _userType);

    if (!mounted) return;
    context.go('/auth/verify');
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
