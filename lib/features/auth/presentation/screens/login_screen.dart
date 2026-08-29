import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/device_identity_service.dart';
import '../controllers/auth_notifier.dart';

final _biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(),
);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isBiometricAvailable = false;
  bool _biometricLoading = false;

  @override
  void initState() {
    super.initState();
    _initBiometric();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _initBiometric() async {
    final svc = ref.read(_biometricServiceProvider);
    final deviceAvailable = await svc.isAvailable;
    final enrolled = await svc.isEnrolled;
    if (mounted) {
      setState(() => _isBiometricAvailable = deviceAvailable && enrolled);
    }
  }

  Future<void> _handleBiometric() async {
    setState(() => _biometricLoading = true);
    try {
      final svc = ref.read(_biometricServiceProvider);
      final response = await svc.authenticateAndLogin(
        reason: 'Authentifiez-vous pour accéder à votre compte',
      );
      if (!response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error ?? 'Échec de l\'authentification'),
            ),
          );
        }
        return;
      }

      final ok = await ref
          .read(authNotifierProvider.notifier)
          .loginWithBiometricTokens(response.tokens!);

      if (!mounted) return;
      if (ok) {
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de la connexion biométrique')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'authentification biométrique'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _biometricLoading = false);
    }
  }

  Future<void> _maybeOfferBiometricEnrollment() async {
    final svc = ref.read(_biometricServiceProvider);
    final available = await svc.isAvailable;
    final alreadyEnrolled = await svc.isEnrolled;
    if (!available || alreadyEnrolled) return;
    if (!mounted) return;

    final accept = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Connexion par empreinte'),
            content: const Text(
              'Voulez-vous activer la connexion par empreinte digitale pour les prochaines fois ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Plus tard'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Activer'),
              ),
            ],
          ),
    );
    if (accept != true) return;

    final accessToken = ref.read(authNotifierProvider.notifier).lastAccessToken;
    if (accessToken == null) return;

    final enrolled = await svc.enroll(
      email: _email.text.trim(),
      accessToken: accessToken,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enrolled
              ? 'Connexion par empreinte activée'
              : 'Échec de l\'activation de l\'empreinte',
        ),
      ),
    );
  }

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
                          const SizedBox(height: 40),

                          _buildInputLabel(l10n.emailLabel, context),
                          const SizedBox(height: 8),
                          Focus(
                            onFocusChange:
                                (v) => setState(() => _isEmailFocused = v),
                            child: NeumorphicContainer(
                              isPressed: _isEmailFocused,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: TextField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                          const SizedBox(height: 24),

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
                          ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                          const SizedBox(height: 40),

                          _buildLoginButton(l10n, auth.isLoading),

                          if (_isBiometricAvailable) ...[
                            const SizedBox(height: 26),
                            _buildBiometricButton(),
                          ],

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

  Widget _buildBiometricButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(56)),
      ),
      onPressed: _biometricLoading ? null : _handleBiometric,
      label:
          _biometricLoading
              ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
              : const Icon(Icons.fingerprint_rounded, size: 28),
    ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.2);
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
    final email = _email.text.trim();
    final password = _password.text.trim();

    try {
      final ok = await ref
          .read(authNotifierProvider.notifier)
          .login(email, password);

      if (!mounted) return;
      if (ok) {
        await _maybeOfferBiometricEnrollment();
        if (!mounted) return;
        context.go('/home');
      } else {
        final authError = ref.read(authNotifierProvider).error;
        final message = authError is DeviceMismatchException
            ? authError.message
            : 'Email ou mot de passe incorrect';
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Erreur de connexion, veuillez réessayer'),
        ),
      );
    }
  }
}
