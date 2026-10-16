import 'package:flutter/material.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/service_request_model.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/listing.dart';
import '../widgets/otp_code_display_dialog.dart';
import '../widgets/otp_code_input_dialog.dart';

class ParcelTrackingScreen extends StatefulWidget {
  final String requestId;
  final ServiceRequestModel? request;
  final bool isTravelerRole;

  const ParcelTrackingScreen({
    super.key,
    required this.requestId,
    this.request,
    this.isTravelerRole = false,
  });

  @override
  State<ParcelTrackingScreen> createState() => _ParcelTrackingScreenState();
}

class _ParcelTrackingScreenState extends State<ParcelTrackingScreen> {
  late ParcelTrackingStep _currentStep;
  late bool _isInDispute;
  String? _pickupProof;
  String? _deliveryProof;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.request?.trackingStep ?? ParcelTrackingStep.bookingConfirmed;
    _isInDispute = widget.request?.isInDispute ?? false;
  }

  void _showPickupOtpDisplay() {
    final code = widget.request?.pickupOtpCode ?? '482915';
    showDialog(
      context: context,
      builder: (_) => OtpCodeDisplayDialog(
        otpCode: code,
        title: 'Votre code secret de remise',
        subtitle: 'À présenter au voyageur lors de la prise en charge physique',
        warningMessage:
            'Ne donnez ce code au voyageur qu\'au moment précis où il réceptionne physiquement et pèse votre colis.',
      ),
    );
  }

  void _showDeliveryOtpDisplay() {
    final code = widget.request?.deliveryOtpCode ?? '739104';
    showDialog(
      context: context,
      builder: (_) => OtpCodeDisplayDialog(
        otpCode: code,
        title: 'Votre code secret de livraison',
        subtitle: 'À présenter au voyageur lors de la remise finale',
        warningMessage:
            'Ne donnez ce code au voyageur qu\'après avoir vérifié le bon état du colis réceptionné.',
      ),
    );
  }

  void _showPickupOtpInput() {
    showDialog<bool>(
      context: context,
      builder: (_) => OtpCodeInputDialog(
        title: 'Prise en charge du colis',
        subtitle: 'Saisissez le code OTP à 6 chiffres fourni par l\'expéditeur',
        actionLabel: 'Confirmer la prise en charge',
        onConfirm: (code, proofUrl) async {
          setState(() {
            _currentStep = ParcelTrackingStep.parcelHandedOver;
            _pickupProof = proofUrl;
          });
        },
      ),
    );
  }

  void _showDeliveryOtpInput() {
    showDialog<bool>(
      context: context,
      builder: (_) => OtpCodeInputDialog(
        title: 'Livraison finale du colis',
        subtitle: 'Saisissez le code OTP à 6 chiffres fourni par le destinataire',
        actionLabel: 'Confirmer la livraison & libérer fonds',
        onConfirm: (code, proofUrl) async {
          setState(() {
            _currentStep = ParcelTrackingStep.delivered;
            _deliveryProof = proofUrl;
          });
        },
      ),
    );
  }

  void _openDisputeDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.report_problem_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text('Signaler un litige', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'L\'ouverture d\'un litige gèle immédiatement la libération des fonds sous séquestre jusqu\'à arbitrage.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Motif du litige',
                hintText: 'Retard injustifié, colis endommagé, absence du voyageur...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _isInDispute = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Litige enregistré. Le séquestre est gelé en attente de médiation.'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer le litige'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final req = widget.request;

    final depFlag = req?.departureCountryCode != null
        ? Listing.countryCodeToEmoji(req!.departureCountryCode!)
        : '🇹🇬';
    final arrFlag = req?.arrivalCountryCode != null
        ? Listing.countryCodeToEmoji(req!.arrivalCountryCode!)
        : '🇷🇺';
    final depCity = req?.departureCity ?? 'Lomé';
    final arrCity = req?.arrivalCity ?? 'Moscou';
    final weight = req?.parcelWeightKg ?? 5.0;
    final contactName = widget.isTravelerRole ? (req?.requesterName ?? 'Expéditeur') : (req?.providerName ?? 'Voyageur');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suivi de livraison Colis',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context, isDark, depFlag, arrFlag, depCity, arrCity, weight, contactName),
              if (_isInDispute) ...[
                const SizedBox(height: 16),
                _buildDisputeAlertBanner(context),
              ],
              const SizedBox(height: 24),
              _buildTimelineSection(context, isDark),
              const SizedBox(height: 24),
              _buildActionCard(context, isDark),
              const SizedBox(height: 24),
              _buildContactAndDisputeRow(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    bool isDark,
    String depFlag,
    String arrFlag,
    String depCity,
    String arrCity,
    double weight,
    String contactName,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(depFlag, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Text(
                depCity,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.grey),
              ),
              Text(arrFlag, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Text(
                arrCity,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${weight.toStringAsFixed(weight == weight.toInt() ? 0 : 1)} kg',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  contactName.isNotEmpty ? contactName[0].toUpperCase() : 'C',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contactName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      widget.isTravelerRole ? 'Expéditeur du colis' : 'Voyageur certifié',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Séquestre actif',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeAlertBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Litige en cours : Le paiement sous séquestre est gelé. L\'équipe Diaspora examine le dossier.',
              style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context, bool isDark) {
    final steps = [
      (
        step: ParcelTrackingStep.bookingConfirmed,
        title: 'Réservation confirmée & Paiement sous séquestre',
        subtitle: 'Les fonds sont bloqués en sécurité. Le voyageur est notifié.',
        icon: Icons.check_circle_rounded,
      ),
      (
        step: ParcelTrackingStep.parcelHandedOver,
        title: 'Colis remis au voyageur (validé par Code Remise OTP)',
        subtitle: 'Le voyageur a réceptionné et pesé le colis en main propre.',
        icon: Icons.inventory_2_rounded,
      ),
      (
        step: ParcelTrackingStep.inTransit,
        title: 'En transit (vol/transport)',
        subtitle: 'Le voyageur effectue son trajet vers la destination.',
        icon: Icons.flight_takeoff_rounded,
      ),
      (
        step: ParcelTrackingStep.arrivedAtDestination,
        title: 'Arrivé dans la ville de destination',
        subtitle: 'Le voyageur est arrivé et s\'apprête à livrer le colis.',
        icon: Icons.flight_land_rounded,
      ),
      (
        step: ParcelTrackingStep.delivered,
        title: 'Colis livré au destinataire (validé par Code Livraison OTP)',
        subtitle: 'Livraison confirmée. Les fonds sont libérés au voyageur.',
        icon: Icons.task_alt_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Étapes d\'acheminement',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isPast = item.step.index < _currentStep.index;
          final isCurrent = item.step == _currentStep;
          final isLast = index == steps.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isPast
                            ? Colors.green
                            : (isCurrent
                                ? AppColors.primary
                                : (isDark ? Colors.grey[800] : Colors.grey[300])),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isPast
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isCurrent || isPast ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isPast
                              ? Colors.green
                              : (isDark ? Colors.grey[800] : Colors.grey[300]),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                            color: isCurrent
                                ? (isDark ? Colors.amber[300] : AppColors.primary)
                                : (isPast ? (isDark ? Colors.white : Colors.black87) : Colors.grey[500]),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, bool isDark) {
    if (_isInDispute) return const SizedBox.shrink();

    // Expéditeur Actions
    if (!widget.isTravelerRole) {
      if (_currentStep == ParcelTrackingStep.bookingConfirmed) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Remise physique en attente',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 6),
              const Text(
                'Lors de votre rencontre avec le voyageur, fournissez-lui votre code secret de remise.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                key: const Key('view_pickup_otp_button'),
                onPressed: _showPickupOtpDisplay,
                icon: const Icon(Icons.key_rounded, size: 18),
                label: const Text('Voir le code de remise OTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      }

      if (_currentStep == ParcelTrackingStep.arrivedAtDestination) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Colis arrivé à destination !',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 6),
              const Text(
                'Transmettez votre code de livraison au voyageur ou à votre destinataire pour confirmer la remise.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                key: const Key('view_delivery_otp_button'),
                onPressed: _showDeliveryOtpDisplay,
                icon: const Icon(Icons.verified_rounded, size: 18),
                label: const Text('Voir le code de livraison OTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      }
    }

    // Voyageur Actions
    if (widget.isTravelerRole) {
      if (_currentStep == ParcelTrackingStep.bookingConfirmed) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Prise en charge du colis',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 6),
              const Text(
                'Demandez le code secret de remise à l\'expéditeur après avoir vérifié et pesé le colis.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                key: const Key('enter_pickup_otp_button'),
                onPressed: _showPickupOtpInput,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                label: const Text('Saisir le code remise OTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      }

      if (_currentStep == ParcelTrackingStep.parcelHandedOver) {
        return ElevatedButton.icon(
          onPressed: () => setState(() => _currentStep = ParcelTrackingStep.inTransit),
          icon: const Icon(Icons.flight_takeoff_rounded),
          label: const Text('Marquer en transit (vol démarré)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      }

      if (_currentStep == ParcelTrackingStep.inTransit) {
        return ElevatedButton.icon(
          onPressed: () => setState(() => _currentStep = ParcelTrackingStep.arrivedAtDestination),
          icon: const Icon(Icons.flight_land_rounded),
          label: const Text('Confirmer l\'arrivée dans la ville'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      }

      if (_currentStep == ParcelTrackingStep.arrivedAtDestination) {
        return ElevatedButton.icon(
          key: const Key('enter_delivery_otp_button'),
          onPressed: _showDeliveryOtpInput,
          icon: const Icon(Icons.task_alt_rounded),
          label: const Text('Saisir le code livraison OTP'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      }
    }

    if (_currentStep == ParcelTrackingStep.delivered) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Livraison réussie et validée ! Les fonds séquestrés ont été libérés au voyageur.',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.green),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildContactAndDisputeRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            key: const Key('contact_chat_button'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ouverture de la messagerie instantanée sécurisée...'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('Chat'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextButton.icon(
            key: const Key('open_dispute_button'),
            onPressed: _openDisputeDialog,
            icon: const Icon(Icons.report_problem_outlined, size: 18, color: Colors.red),
            label: const Text('Signaler litige', style: TextStyle(color: Colors.red)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}
