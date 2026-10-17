import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/home_back_button.dart';
import '../controllers/profile_providers.dart';

/// Screen allowing the user to view their KYC verification status,
/// upload required country-specific documents, and submit their dossier.
class KycVerificationScreen extends ConsumerStatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  ConsumerState<KycVerificationScreen> createState() =>
      _KycVerificationScreenState();
}

class _KycVerificationScreenState extends ConsumerState<KycVerificationScreen> {
  bool _isLoading = true;
  String? _kycId;
  String _status = 'Draft'; // Draft, Pending, Approved, Rejected
  String? _rejectionReason;
  List<Map<String, dynamic>> _documents = [];
  List<Map<String, dynamic>> _dynamicRequirements = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadKycData();
  }

  Future<void> _loadKycData() async {
    setState(() => _isLoading = true);
    final client = GetIt.instance<DioClient>();
    try {
      final res = await client.get('/kyc/my-verification');
      final data = (res is Map && res['data'] is Map)
          ? res['data'] as Map<String, dynamic>
          : (res is Map<String, dynamic> ? res : <String, dynamic>{});

      setState(() {
        _kycId = (data['id'] ?? data['Id'])?.toString();
        _status = (data['status'] ?? data['Status'] ?? 'Draft').toString();
        _rejectionReason =
            (data['rejectionReason'] ?? data['RejectionReason'])?.toString();
        final rawDocs = data['documents'] ?? data['Documents'];
        _documents = (rawDocs is List)
            ? rawDocs
                .map((d) => Map<String, dynamic>.from(d as Map))
                .toList()
            : [];
      });
    } catch (_) {
      // If no verification exists yet, create one
      try {
        final createRes = await client.post('/kyc', data: {});
        setState(() {
          _kycId = (createRes is Map ? createRes['id'] : 'kyc_default')?.toString();
          _status = 'Draft';
          _documents = [];
        });
      } catch (_) {}
    }

    // Charger les exigences dynamiques par type de profil
    try {
      final profile = ref.read(activeProfileProvider);
      final profileTypeId = profile?.profileTypeId;
      final reqUrl = (profileTypeId != null && profileTypeId.isNotEmpty)
          ? '/kyc/requirements?profileTypeId=$profileTypeId'
          : '/kyc/requirements';
      final reqRes = await client.get(reqUrl);
      if (reqRes is List && reqRes.isNotEmpty) {
        setState(() {
          _dynamicRequirements = reqRes
              .map((r) => Map<String, dynamic>.from(r as Map))
              .toList();
        });
      }
    } catch (_) {}

    setState(() => _isLoading = false);
  }

  IconData _iconForCode(String code) {
    final lower = code.toLowerCase();
    if (lower.contains('id') || lower.contains('identity') || lower.contains('passport') || lower.contains('cni')) {
      return Icons.badge_outlined;
    }
    if (lower.contains('address') || lower.contains('domicile') || lower.contains('residence')) {
      return Icons.home_outlined;
    }
    if (lower.contains('consular') || lower.contains('card') || lower.contains('consulaire')) {
      return Icons.card_membership_outlined;
    }
    if (lower.contains('visa') || lower.contains('stay') || lower.contains('arrival') || lower.contains('sejour')) {
      return Icons.flight_land_outlined;
    }
    return Icons.description_outlined;
  }

  List<_RequirementItem> _getRequirements(String countryCode) {
    if (_dynamicRequirements.isNotEmpty) {
      return _dynamicRequirements.map((req) {
        final code = (req['documentTypeCode'] ?? req['DocumentTypeCode'] ?? 'Document').toString();
        final purpose = (req['purpose'] ?? req['Purpose'] ?? '').toString();
        final isRequired = (req['isRequired'] ?? req['IsRequired'] ?? true) == true;
        return _RequirementItem(
          code: code,
          title: purpose.isNotEmpty ? purpose : code,
          description: isRequired
              ? 'Document requis pour votre pays ($countryCode)'
              : 'Document complémentaire optionnel',
          icon: _iconForCode(code),
        );
      }).toList();
    }

    final code = countryCode.toUpperCase();
    final items = <_RequirementItem>[
      const _RequirementItem(
        code: 'IdentityDocument',
        title: "Pièce d'identité",
        description: 'Passeport ou Carte Nationale d\'Identité en cours de validité',
        icon: Icons.badge_outlined,
      ),
      const _RequirementItem(
        code: 'ProofOfAddress',
        title: 'Justificatif de domicile',
        description: 'Facture d\'électricité, eau ou quittance de loyer (- de 3 mois)',
        icon: Icons.home_outlined,
      ),
    ];

    if (code == 'TG') {
      items.add(
        const _RequirementItem(
          code: 'ConsularCard',
          title: 'Carte consulaire / Justificatif diaspora',
          description: 'Preuve d\'immatriculation consulaire ou certificat de résidence',
          icon: Icons.card_membership_outlined,
        ),
      );
    } else if (code == 'FR') {
      items.add(
        const _RequirementItem(
          code: 'VisaOrStayPermit',
          title: 'Titre de séjour ou Visa',
          description: 'Titre de séjour en cours ou visa d\'entrée',
          icon: Icons.flight_land_outlined,
        ),
      );
    } else {
      items.add(
        const _RequirementItem(
          code: 'ArrivalProof',
          title: 'Preuve d\'arrivée / Séjour',
          description: 'Tampon d\'entrée, visa ou billet d\'avion attestant l\'arrivée',
          icon: Icons.airplane_ticket_outlined,
        ),
      );
    }

    return items;
  }

  Future<void> _uploadDoc(String docType) async {
    if (_kycId == null) return;
    final client = GetIt.instance<DioClient>();
    try {
      if (AppConfig.useMockData) {
        await client.post(
          '/kyc/$_kycId/documents',
          queryParameters: {'documentType': docType},
        );
      } else {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile == null) return;

        final bytes = await pickedFile.readAsBytes();
        final formData = FormData.fromMap({
          'documentType': docType,
          'file': MultipartFile.fromBytes(
            bytes,
            filename: pickedFile.name.isNotEmpty
                ? pickedFile.name
                : '$docType.jpg',
          ),
        });

        await client.post(
          '/kyc/$_kycId/documents',
          data: formData,
          queryParameters: {'documentType': docType},
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document téléversé avec succès')),
      );
      await _loadKycData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de téléversement : $e')),
      );
    }
  }

  Future<void> _submitKyc() async {
    if (_kycId == null) return;
    setState(() => _isSubmitting = true);
    final client = GetIt.instance<DioClient>();
    try {
      await client.post('/kyc/$_kycId/submit');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dossier KYC soumis ! Un modérateur va examiner vos documents.'),
        ),
      );
      await _loadKycData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la soumission : $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeProfile = ref.watch(activeProfileProvider);
    final countryCode = activeProfile?.country ?? 'TG';
    final requirements = _getRequirements(countryCode);

    final uploadedTypes = _documents
        .map((d) => (d['documentType'] ?? d['DocumentType'])?.toString())
        .toSet();

    final allUploaded = requirements.every((r) => uploadedTypes.contains(r.code));

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const HomeBackButton(),
        title: Text(
          'Vérification d\'identité (KYC)',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadKycData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  _buildLevelStepper(activeProfile?.verificationLevel ?? 0, isDark),
                  _buildStatusHero(isDark),
                  const SizedBox(height: 20),
                  Text(
                    'Documents requis (${activeProfile?.country ?? "Général"})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pour obtenir le badge vérifié et débloquer tous les services, fournissez les justificatifs suivants :',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 14),
                  ...requirements.map(
                    (req) => _buildRequirementCard(
                      req: req,
                      isUploaded: uploadedTypes.contains(req.code),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_status == 'Draft' || _status == 'Rejected') ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed:
                            (_isSubmitting || !allUploaded) ? null : _submitKyc,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                allUploaded
                                    ? 'Soumettre mon dossier KYC'
                                    : 'Veuillez téléverser tous les documents',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatusHero(bool isDark) {
    Color bg;
    Color border;
    IconData icon;
    String title;
    String subtitle;

    switch (_status) {
      case 'Approved':
        bg = Colors.green.withValues(alpha: 0.1);
        border = Colors.green.withValues(alpha: 0.3);
        icon = Icons.verified_user_rounded;
        title = 'Profil vérifié';
        subtitle =
            'Félicitations ! Vos documents ont été validés. Le badge vérifié est affiché sur votre profil et vos annonces.';
        break;
      case 'Pending':
        bg = Colors.orange.withValues(alpha: 0.1);
        border = Colors.orange.withValues(alpha: 0.3);
        icon = Icons.hourglass_top_rounded;
        title = 'Dossier en cours d\'examen';
        subtitle =
            'Votre dossier KYC a bien été soumis. Notre équipe procède à la vérification sous 24 à 48 heures.';
        break;
      case 'Rejected':
        bg = Colors.red.withValues(alpha: 0.1);
        border = Colors.red.withValues(alpha: 0.3);
        icon = Icons.error_outline_rounded;
        title = 'Dossier refusé';
        subtitle = _rejectionReason ??
            'Certains documents ne correspondent pas aux critères requis. Veuillez les renouveler.';
        break;
      default:
        bg = AppColors.primary.withValues(alpha: 0.08);
        border = AppColors.primary.withValues(alpha: 0.2);
        icon = Icons.shield_outlined;
        title = 'Non vérifié';
        subtitle =
            'Soumettez vos justificatifs pour obtenir la certification officielle et rassurer vos partenaires.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: border.withValues(alpha: 1.0)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementCard({
    required _RequirementItem req,
    required bool isUploaded,
    required bool isDark,
  }) {
    final canEdit = _status == 'Draft' || _status == 'Rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUploaded
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUploaded
                  ? Colors.green.withValues(alpha: 0.12)
                  : (isDark ? Colors.white10 : Colors.grey[100]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUploaded ? Icons.check_circle_rounded : req.icon,
              size: 24,
              color: isUploaded ? Colors.green : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  req.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUploaded)
            const Text(
              'Ajouté',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            )
          else if (canEdit)
            OutlinedButton(
              onPressed: () => _uploadDoc(req.code),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(60, 32),
              ),
              child: const Text('Ajouter'),
            ),
        ],
      ),
    );
  }

  Widget _buildLevelStepper(int currentLevel, bool isDark) {
    final levels = [
      (0, 'L0', 'Inscrit'),
      (1, 'L1', 'Déclaré'),
      (2, 'L2', 'Vérifié'),
      (3, 'L3', 'Renforcé'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression KYC',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Niveau actuel : L$currentLevel',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: levels.asMap().entries.map((entry) {
              final idx = entry.key;
              final (lvl, code, label) = entry.value;
              final isReached = currentLevel >= lvl;
              final isCurrent = currentLevel == lvl;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isReached
                                  ? (isCurrent ? AppColors.primary : AppColors.success)
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              border: isCurrent
                                  ? Border.all(color: AppColors.primary, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: isReached && !isCurrent
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : Text(
                                      code,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isReached ? Colors.white : Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: isCurrent
                                  ? AppColors.primary
                                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (idx < levels.length - 1)
                      Container(
                        height: 2,
                        width: 14,
                        color: currentLevel > lvl
                            ? AppColors.success
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        margin: const EdgeInsets.only(bottom: 16),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RequirementItem {
  final String code;
  final String title;
  final String description;
  final IconData icon;

  const _RequirementItem({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
  });
}
