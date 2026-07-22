import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../core/localization/app_localizations.dart';
import '../controllers/auth_notifier.dart';
import '../controllers/pending_verification_provider.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  final String? email;
  final String? code;
  const PhoneVerificationScreen({super.key, this.email, this.code});

  @override
  ConsumerState<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends ConsumerState<PhoneVerificationScreen> {
  final _code = TextEditingController();
  bool _isCodeFocused = false;
  bool _autoVerified = false;

  String get _email =>
      ref.read(pendingVerificationEmailProvider) ??
      widget.email ??
      (GoRouterState.of(context).extra is String
          ? GoRouterState.of(context).extra as String
          : GoRouterState.of(context).extra is Map
              ? (GoRouterState.of(context).extra as Map)['email'] as String?
              : null) ??
      '';

  @override
  void initState() {
    super.initState();
    if (widget.email != null && widget.code != null && !_autoVerified) {
      _autoVerified = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleVerify());
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
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
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: GlassContainer(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeader(l10n, auth.isLoading),
                              const SizedBox(height: 24),
                              Text(
                                '${l10n.codeSentMessage} $_email',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.getTextSecondary(context),
                                  fontSize: 15,
                                ),
                              ).animate().fadeIn(delay: 400.ms),
                              const SizedBox(height: 32),

                              _buildInputLabel(l10n.codeHint, context),
                              const SizedBox(height: 8),
                              Focus(
                                onFocusChange:
                                    (v) => setState(() => _isCodeFocused = v),
                                child: NeumorphicContainer(
                                  isPressed: _isCodeFocused,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: TextField(
                                    controller: _code,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 8,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                              const SizedBox(height: 48),

                              _buildVerifyButton(l10n, auth.isLoading),

                              const SizedBox(height: 24),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Renvoyer le code',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ).animate().fadeIn(delay: 700.ms),

                              const SizedBox(height: 24),
                              Text(
                                l10n.wrongEmailMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.getTextSecondary(context),
                                  fontSize: 13,
                                ),
                              ).animate().fadeIn(delay: 800.ms),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () async {
                                  await ref
                                      .read(authNotifierProvider.notifier)
                                      .cancelRegistration();
                                  if (!mounted) return;
                                  context.go('/auth/register');
                                },
                                child: Text(
                                  l10n.wrongEmailButton,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ).animate().fadeIn(delay: 900.ms),

                              const SizedBox(height: 12),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(begin: const Offset(0.9, 0.9)),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child:                   IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.getTextMain(context),
                    ),
                    onPressed: null,
                  ).animate().fadeIn(delay: 800.ms),
                ),
              ],
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
            top: 100,
            left: -80,
            child: _buildFloatingCircle(
              200,
              AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -100,
            child: _buildFloatingCircle(
              350,
              AppColors.secondary.withValues(alpha: 0.1),
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
        .moveY(
          begin: 0,
          end: 25,
          duration: 3.5.seconds,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildHeader(AppLocalizations l10n, bool isLoading) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isLoading
                ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                : AppColors.primaryGradient,
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            color: Colors.white,
            size: 35,
          ),
        ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text(
          l10n.verificationTitle,
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

  Widget _buildVerifyButton(AppLocalizations l10n, bool isLoading) {
    return NeumorphicContainer(
      borderRadius: 16,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shadowColor: Colors.transparent,
        ),
        onPressed: isLoading ? null : _handleVerify,
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
                  l10n.verifyButton,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  Future<void> _handleVerify() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final email = _email;
    if (email.isEmpty) return;

    final code = widget.code ?? _code.text.trim();
    if (code.isEmpty) return;

    try {
      final ok = await ref
          .read(authNotifierProvider.notifier)
          .verifyEmail(email, code);

      if (!mounted) return;
      if (ok) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.phoneVerified)));
        context.go('/auth/login');
      } else {
        messenger.showSnackBar(SnackBar(content: Text(l10n.codeInvalid)));
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Erreur réseau, veuillez réessayer')),
      );
    }
  }
}