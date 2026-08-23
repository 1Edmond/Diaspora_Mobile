import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/entities/profile.dart';
import '../controllers/profile_providers.dart';

class ProfileCreationFlow extends ConsumerStatefulWidget {
  const ProfileCreationFlow({super.key});

  @override
  ConsumerState<ProfileCreationFlow> createState() =>
      _ProfileCreationFlowState();
}

class _ProfileCreationFlowState extends ConsumerState<ProfileCreationFlow> {
  int _currentStep = 0;
  String _selectedType = '';
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _subtitleController = TextEditingController();

  final List<Map<String, dynamic>> _profileTypes = [
    {'type': 'Internal', 'icon': Icons.school, 'label': 'Interne', 'color': const Color(0xFF0033A0)},
    {'type': 'External', 'icon': Icons.business, 'label': 'Externe', 'color': const Color(0xFF006B3F)},
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _createProfile() {
    if (_selectedType.isEmpty || _firstNameController.text.isEmpty) return;

    final color = _selectedType == 'Internal'
        ? const Color(0xFF0033A0)
        : const Color(0xFF006B3F);

    final now = DateTime.now();
    final newProfile = Profile(
      id: now.millisecondsSinceEpoch.toString(),
      userId: 'local_${now.millisecondsSinceEpoch}',
      profileType: _selectedType,
      profileTypeId: '',
      firstName: _firstNameController.text,
      lastName: _lastNameController.text.isNotEmpty ? _lastNameController.text : '',
      status: ProfileStatus.VALIDATED,
      createdAt: now,
      universityOrCompany: _subtitleController.text.isNotEmpty ? _subtitleController.text : null,
      profileColor: color,
    );

    final currentProfiles = ref.read(profileListProvider).valueOrNull ?? [];
    ref.read(profileListProvider.notifier).setProfiles([...currentProfiles, newProfile]);
    ref.read(activeProfileIdProvider.notifier).setActiveProfileId(newProfile.id);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: _buildCurrentStep(),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _previousStep,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentStep == 0
                      ? 'Ajouter un profil'
                      : _currentStep == 1
                          ? 'Personnaliser'
                          : 'Confirmer',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextMain(context),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Étape ${_currentStep + 1} sur 3',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildTypeSelection();
      case 1:
        return _buildPersonalization();
      case 2:
        return _buildConfirmation();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisir un type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextMain(context),
          ),
        ),
        const SizedBox(height: 16),
        ...(_profileTypes.map((type) {
          final isSelected = _selectedType == type['type'];
          final color = type['color'] as Color;

          return GestureDetector(
            onTap: () => setState(() => _selectedType = type['type']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.1)
                    : AppColors.getTextSecondary(context).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppColors.getTextSecondary(context).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      type['icon'] as IconData,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    type['label'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.getTextMain(context),
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Icon(Icons.check_circle, color: color),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.1),
          );
        })),
      ],
    );
  }

  Widget _buildPersonalization() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personnaliser le profil',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextMain(context),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _firstNameController,
          decoration: InputDecoration(
            labelText: 'Prénom',
            hintText: 'Ex: Koffi',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.getTextSecondary(context).withValues(alpha: 0.05),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _lastNameController,
          decoration: InputDecoration(
            labelText: 'Nom',
            hintText: 'Ex: Togolais',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.getTextSecondary(context).withValues(alpha: 0.05),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _subtitleController,
          decoration: InputDecoration(
            labelText: 'Organisation',
            hintText: 'Ex: Université de Lomé',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.getTextSecondary(context).withValues(alpha: 0.05),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1);
  }

  Widget _buildConfirmation() {
    final color = _selectedType == 'Internal'
        ? const Color(0xFF0033A0)
        : const Color(0xFF006B3F);

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _firstNameController.text.isNotEmpty
                  ? _firstNameController.text.substring(0, 1)
                  : '?',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 24),
        Text(
          '${_firstNameController.text} ${_lastNameController.text}'.trim(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextMain(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedType == 'Internal' ? 'Interne' : 'Externe',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.getTextSecondary(context),
          ),
        ),
        if (_subtitleController.text.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            _subtitleController.text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(context),
            ),
          ),
        ],
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Profil créé avec succès !',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1);
  }

  Widget _buildBottomBar() {
    final canProceed = _currentStep == 0
        ? _selectedType.isNotEmpty
        : _currentStep == 1
            ? _firstNameController.text.isNotEmpty
            : true;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: canProceed
              ? () {
                  if (_currentStep < 2) {
                    _nextStep();
                  } else {
                    _createProfile();
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor: AppColors.getTextSecondary(context).withValues(alpha: 0.3),
          ),
          child: Text(
            _currentStep < 2 ? 'Continuer' : 'Créer le profil',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
