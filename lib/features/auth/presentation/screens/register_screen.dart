import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/widgets/containers/glass_container.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../core/localization/app_localizations.dart';
import '../controllers/auth_notifier.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';
import '../../../profile/data/models/public_profile_type_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _dateOfBirth = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  PublicProfileType? _selectedProfileType;
  bool _isFirstNameFocused = false;
  bool _isLastNameFocused = false;
  bool _isEmailFocused = false;
  bool _isPhoneFocused = false;
  bool _isPasswordFocused = false;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _dateOfBirth.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final profileTypesAsync = ref.watch(publicProfileTypesProvider);
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
                                _buildHeader(l10n),
                                const SizedBox(height: 32),

                                _buildInputLabel(l10n.firstNameLabel, context),
                                const SizedBox(height: 8),
                                Focus(
                                  onFocusChange:
                                      (v) => setState(() => _isFirstNameFocused = v),
                                  child: NeumorphicContainer(
                                    isPressed: _isFirstNameFocused,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: TextField(
                                      controller: _firstName,
                                      keyboardType: TextInputType.name,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

                                const SizedBox(height: 20),

                                _buildInputLabel(l10n.lastNameLabel, context),
                                const SizedBox(height: 8),
                                Focus(
                                  onFocusChange:
                                      (v) => setState(() => _isLastNameFocused = v),
                                  child: NeumorphicContainer(
                                    isPressed: _isLastNameFocused,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: TextField(
                                      controller: _lastName,
                                      keyboardType: TextInputType.name,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

                                const SizedBox(height: 20),

                                _buildInputLabel(l10n.dateOfBirthLabel, context),
                                const SizedBox(height: 8),
                                NeumorphicContainer(
                                  isPressed: true,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: TextField(
                                    controller: _dateOfBirth,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      suffixIcon: Icon(Icons.calendar_today_rounded),
                                    ),
                                    onTap: _pickDate,
                                  ),
                                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

                                const SizedBox(height: 20),

                                _buildInputLabel(l10n.emailLabel, context),
                                const SizedBox(height: 8),
                                Focus(
                                  onFocusChange:
                                      (v) => setState(() => _isEmailFocused = v),
                                  child: NeumorphicContainer(
                                    isPressed: _isEmailFocused,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: TextField(
                                      controller: _email,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

                                const SizedBox(height: 20),

                                _buildInputLabel('Pays du profil citoyen', context),
                                const SizedBox(height: 8),
                                profileTypesAsync.when(
                                  data: (types) {
                                    if (_selectedProfileType == null && types.isNotEmpty) {
                                      _selectedProfileType = types.firstWhere(
                                        (t) => t.countryCode == 'TG',
                                        orElse: () => types.first,
                                      );
                                    }
                                    return NeumorphicContainer(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<PublicProfileType>(
                                          isExpanded: true,
                                          value: _selectedProfileType,
                                          items: types.map((type) {
                                            return DropdownMenuItem<PublicProfileType>(
                                              value: type,
                                              child: Row(
                                                children: [
                                                  Text(type.flag, style: const TextStyle(fontSize: 18)),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      '${type.countryName} (${type.phoneIndicatif})',
                                                      style: TextStyle(
                                                        color: AppColors.getTextMain(context),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (newType) {
                                            if (newType != null) {
                                              setState(() => _selectedProfileType = newType);
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  loading: () => const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                  error: (_, __) => const SizedBox.shrink(),
                                ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.1),

                                const SizedBox(height: 20),

                                _buildInputLabel(l10n.phoneHint, context),
                                const SizedBox(height: 8),
                                Focus(
                                  onFocusChange:
                                      (v) => setState(() => _isPhoneFocused = v),
                                  child: NeumorphicContainer(
                                    isPressed: _isPhoneFocused,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      children: [
                                        Text(
                                          _selectedProfileType?.phoneIndicatif ?? '+228',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextField(
                                            controller: _phone,
                                            keyboardType: TextInputType.phone,
                                            decoration: const InputDecoration(
                                              hintText: '90 12 34 56',
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                                const SizedBox(height: 20),

                                _buildInputLabel(l10n.passwordHint, context),
                                const SizedBox(height: 8),
                                Focus(
                                  onFocusChange:
                                      (v) => setState(() => _isPasswordFocused = v),
                                  child: NeumorphicContainer(
                                    isPressed: _isPasswordFocused,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: TextField(
                                      controller: _password,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 450.ms).slideX(begin: -0.1),

                                const SizedBox(height: 40),

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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: now.subtract(const Duration(days: 365 * 16)),
      helpText: 'Sélectionnez votre date de naissance',
      cancelText: 'Annuler',
      confirmText: 'Choisir',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirth.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _handleRegister() async {
    final messenger = ScaffoldMessenger.of(context);
    final firstName = _firstName.text.trim();
    final lastName = _lastName.text.trim();
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    final password = _password.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        _selectedDate == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final indicatif = _selectedProfileType?.phoneIndicatif ?? '+228';
    var cleanPhone = phone.replaceAll(' ', '').replaceAll('-', '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = cleanPhone.substring(1);
    }
    final fullPhone = cleanPhone.startsWith('+') ? cleanPhone : '$indicatif$cleanPhone';

    try {
      final ok = await ref.read(authNotifierProvider.notifier).register(
            phone: fullPhone,
            password: password,
            firstName: firstName,
            lastName: lastName,
            email: email,
            dateOfBirth: _selectedDate!,
            userType: 'CITOYEN',
          );

      if (!mounted) return;
      if (ok) {
        context.go('/auth/verify', extra: <String, String>{'email': email});
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Échec de l\'inscription, veuillez réessayer')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Erreur réseau, veuillez réessayer')),
      );
    }
  }
}