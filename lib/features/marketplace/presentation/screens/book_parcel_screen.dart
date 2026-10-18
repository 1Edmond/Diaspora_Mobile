import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/design_system.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/marketplace_dtos.dart';
import '../../data/models/payment_policy_model.dart';
import '../../domain/entities/enums.dart';
import '../controllers/marketplace_providers.dart';
import '../../../profile/presentation/controllers/profile_providers.dart';

class BookParcelScreen extends ConsumerStatefulWidget {
  final String listingId;
  final ListingModel? listing;
  final AllowedSettlementPolicy? policy;

  const BookParcelScreen({
    super.key,
    required this.listingId,
    this.listing,
    this.policy,
  });

  @override
  ConsumerState<BookParcelScreen> createState() => _BookParcelScreenState();
}

class _BookParcelScreenState extends ConsumerState<BookParcelScreen> {
  late TextEditingController _weightController;
  late TextEditingController _declaredValueController;
  late TextEditingController _messageController;

  PaymentSettlementType _selectedSettlementType = PaymentSettlementType.walletEscrow;
  DirectCashTiming _selectedCashTiming = DirectCashTiming.atPickup;
  PaymentPolicyModel? _paymentPolicy;

  AllowedSettlementPolicy get _effectivePolicy {
    if (widget.policy != null) return widget.policy!;
    return _paymentPolicy?.allowedPolicy ?? AllowedSettlementPolicy.both;
  }

  double get _platformDirectFee {
    if (_paymentPolicy == null) return 0.0;
    return _paymentPolicy!.calculateDirectPlatformFee(_travelerAmount);
  }

  String _selectedNature = 'Vêtements & Textiles';
  bool _isLoading = false;
  String? _weightError;

  static const List<String> _parcelNatures = [
    'Vêtements & Textiles',
    'Documents & Livres',
    'Nourriture sèche & Épices',
    'Électronique & Accessoires',
    'Cosmétiques & Soins',
    'Artisanat & Souvenirs',
    'Autre',
  ];

  static const double _platformFeeRate = 0.10; // 10% platform service commission

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: '2');
    _declaredValueController = TextEditingController(text: '20000');
    _messageController = TextEditingController();

    if (widget.policy == AllowedSettlementPolicy.directHandoverOnly) {
      _selectedSettlementType = PaymentSettlementType.directHandover;
    } else {
      _selectedSettlementType = PaymentSettlementType.walletEscrow;
    }

    _fetchPaymentPolicy();
  }

  Future<void> _fetchPaymentPolicy() async {
    if (widget.policy != null) return;
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final profileTypeId = widget.listing?.providerProfileId;
      final countryCode = widget.listing?.arrivalCountryCode ??
          widget.listing?.country ??
          widget.listing?.providerCountryCode;
      final policy = await repo.getPaymentPolicy(
        profileTypeId: profileTypeId,
        countryCode: countryCode,
      );
      if (!mounted) return;
      setState(() {
        _paymentPolicy = policy;
        if (policy.allowedPolicy == AllowedSettlementPolicy.directHandoverOnly) {
          _selectedSettlementType = PaymentSettlementType.directHandover;
        } else if (policy.allowedPolicy == AllowedSettlementPolicy.walletEscrowOnly) {
          _selectedSettlementType = PaymentSettlementType.walletEscrow;
        }
        if (policy.defaultCashTiming != DirectCashTiming.freeChoice) {
          _selectedCashTiming = policy.defaultCashTiming;
        }
      });
    } catch (_) {}
  }

  @override
  void didUpdateWidget(BookParcelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.policy != oldWidget.policy) {
      if (widget.policy == AllowedSettlementPolicy.directHandoverOnly) {
        _selectedSettlementType = PaymentSettlementType.directHandover;
      } else if (widget.policy == AllowedSettlementPolicy.walletEscrowOnly) {
        _selectedSettlementType = PaymentSettlementType.walletEscrow;
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _declaredValueController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  double get _requestedWeight {
    return double.tryParse(_weightController.text.trim()) ?? 0.0;
  }

  double get _pricePerKg {
    if (widget.listing != null) {
      return widget.listing!.pricePerKg ?? widget.listing!.price ?? 5000.0;
    }
    return 5000.0;
  }

  double get _remainingKg {
    if (widget.listing != null) {
      return widget.listing!.remainingKg ?? widget.listing!.capacityKg ?? 20.0;
    }
    return 20.0;
  }

  String get _currency {
    return widget.listing?.currency ?? 'XOF';
  }

  double get _travelerAmount {
    return _requestedWeight * _pricePerKg;
  }

  double get _platformFee {
    return _travelerAmount * _platformFeeRate;
  }

  double get _totalEscrowAmount {
    return _travelerAmount + _platformFee;
  }

  String _formatAmount(double amount) {
    final s = amount.toStringAsFixed(amount == amount.toInt() ? 0 : 2);
    final parts = s.split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
    if (parts.length > 1) {
      return '$integerPart.${parts[1]}';
    }
    return integerPart;
  }

  void _incrementWeight() {
    final current = _requestedWeight;
    if (current + 1 <= _remainingKg) {
      setState(() {
        _weightController.text = (current + 1).toStringAsFixed(0);
        _weightError = null;
      });
    }
  }

  void _decrementWeight() {
    final current = _requestedWeight;
    if (current - 1 >= 1) {
      setState(() {
        _weightController.text = (current - 1).toStringAsFixed(0);
        _weightError = null;
      });
    }
  }

  bool _validateInputs() {
    final weight = _requestedWeight;
    if (weight <= 0) {
      setState(() => _weightError = 'Veuillez renseigner un poids supérieur à 0 kg');
      return false;
    }
    if (weight > _remainingKg) {
      setState(() => _weightError = 'Le poids demandé ($weight kg) dépasse les ${_remainingKg.toStringAsFixed(0)} kg disponibles');
      return false;
    }
    setState(() => _weightError = null);
    return true;
  }

  Future<void> _submitBooking() async {
    final activeProfile = ref.read(activeProfileProvider);
    if (activeProfile == null || !activeProfile.isValidated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seuls les profils actifs et validés peuvent réserver un colis.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final declaredVal = double.tryParse(_declaredValueController.text.trim()) ?? 0.0;
      final isEscrow = _selectedSettlementType == PaymentSettlementType.walletEscrow;

      final message = isEscrow
          ? 'Réservation colis : ${_requestedWeight} kg ($_selectedNature). '
            'Valeur déclarée : ${_formatAmount(declaredVal)} $_currency. '
            '${_messageController.text.trim()}'
          : 'Réservation colis (Règlement direct en espèces) : ${_requestedWeight} kg ($_selectedNature). '
            'Moment règlement : ${_selectedCashTiming == DirectCashTiming.atDelivery ? "À la livraison" : "À la remise"}. '
            'Valeur déclarée : ${_formatAmount(declaredVal)} $_currency. '
            '${_messageController.text.trim()}';

      final created = await repo.createRequest(
        CreateServiceRequestDto(
          listingId: widget.listingId,
          message: message,
          weightKg: _requestedWeight,
          declaredValue: declaredVal,
          packageContentCategory: _selectedNature,
          packageDescription: _messageController.text.trim(),
          agreedPrice: isEscrow ? _totalEscrowAmount : _travelerAmount,
          agreedCurrency: _currency,
          settlementType: _selectedSettlementType,
          cashTiming: !isEscrow ? _selectedCashTiming : null,
          platformDirectFeeAmount: !isEscrow ? _platformDirectFee : 0.0,
        ),
      );

      if (!AppConfig.useMockData && created.id.isNotEmpty && isEscrow) {
        await repo.payRequest(created.id);
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                isEscrow ? Icons.shield_rounded : Icons.payments_rounded,
                color: isEscrow ? Colors.green : Colors.amber[800],
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                isEscrow ? 'Séquestre confirmé !' : 'Réservation directe confirmée !',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEscrow
                    ? 'Votre réservation pour ${_requestedWeight} kg est enregistrée. Le montant de ${_formatAmount(_totalEscrowAmount)} $_currency est placé sous séquestre sécurisé.'
                    : 'Votre réservation pour ${_requestedWeight} kg en règlement direct en espèces est enregistrée. Montant en espèces à remettre au voyageur : ${_formatAmount(_travelerAmount)} $_currency.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isEscrow ? Colors.green : Colors.amber).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (isEscrow ? Colors.green : Colors.amber).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isEscrow
                      ? '💡 Un code secret OTP unique de remise vous a été attribué. Communiquez-le au voyageur uniquement lorsqu\'il prendra votre colis en charge.'
                      : '💡 Les codes secrets OTP restent actifs ! Communiquez votre code de remise au voyageur lors de la prise en charge physique du colis.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isEscrow ? Colors.green : Colors.amber[900],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/marketplace/requests');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Accéder à mes demandes'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la réservation : $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeProfile = ref.watch(activeProfileProvider);
    final isProfileActive = activeProfile != null && activeProfile.isValidated;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Réserver un espace colis',
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
              if (!isProfileActive) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Votre profil doit être actif et validé pour réserver un envoi de colis.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              _buildListingSummaryCard(context, isDark),
              const SizedBox(height: 24),
              _buildWeightSelector(context, isDark),
              const SizedBox(height: 24),
              _buildParcelDetails(context, isDark),
              const SizedBox(height: 24),
              _buildSettlementSelector(context, isDark),
              const SizedBox(height: 24),
              _buildPriceBreakdownCard(context, isDark),
              const SizedBox(height: 16),
              _buildEscrowSecurityBanner(context, isDark),
              const SizedBox(height: 32),
              _buildConfirmButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingSummaryCard(BuildContext context, bool isDark) {
    final listing = widget.listing;
    final depFlag = listing?.departureCountryFlag ?? '🇹🇬';
    final arrFlag = listing?.arrivalCountryFlag ?? '🇷🇺';
    final depCity = listing?.departureCity ?? 'Lomé';
    final arrCity = listing?.arrivalCity ?? 'Moscou';
    final providerName = listing?.providerName ?? 'Voyageur vérifié';
    final dateStr = listing?.departureDate != null
        ? DateFormat('dd/MM/yyyy').format(listing!.departureDate!)
        : 'Bientôt';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252525) : Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(depFlag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 6),
              Text(
                depCity,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
              ),
              Text(arrFlag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 6),
              Text(
                arrCity,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
                  providerName.isNotEmpty ? providerName[0].toUpperCase() : 'V',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          providerName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        if (listing?.providerIsVerified ?? true) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF0033A0)),
                        ],
                      ],
                    ),
                    Text(
                      'Vol prévu le $dateStr',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_remainingKg.toStringAsFixed(0)} kg dispo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSelector(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kilos souhaités',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Indiquez le poids estimé de votre colis (max ${_remainingKg.toStringAsFixed(0)} kg)',
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: _decrementWeight,
              icon: const Icon(Icons.remove_rounded),
              tooltip: 'Moins de kilos',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                key: const Key('requested_weight_field'),
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  suffixText: 'kg',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (_) {
                  setState(() => _weightError = null);
                },
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filledTonal(
              onPressed: _incrementWeight,
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Plus de kilos',
            ),
          ],
        ),
        if (_weightError != null) ...[
          const SizedBox(height: 8),
          Text(
            _weightError!,
            style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }

  Widget _buildParcelDetails(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détails du colis',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),

        // Nature Dropdown
        const Text('Nature du contenu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          key: const Key('parcel_nature_dropdown'),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedNature,
              isExpanded: true,
              items: _parcelNatures.map((n) {
                return DropdownMenuItem<String>(
                  value: n,
                  child: Text(n, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedNature = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Declared Value
        const Text('Valeur déclarée estimée', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          key: const Key('declared_value_field'),
          controller: _declaredValueController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ex: 25000',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixText: _currency,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 16),

        // Sender message
        const Text('Message / Consignes pour le voyageur', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          key: const Key('sender_message_field'),
          controller: _messageController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Précisez la nature exacte des objets, le point de remise souhaité ou toute consigne utile...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildSettlementSelector(BuildContext context, bool isDark) {
    final allowEscrow = _effectivePolicy != AllowedSettlementPolicy.directHandoverOnly;
    final allowDirect = _effectivePolicy != AllowedSettlementPolicy.walletEscrowOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mode de règlement',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Choisissez le mode de paiement convenu pour cette expédition',
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[600]),
        ),
        const SizedBox(height: 12),

        // Option A: Séquestre Sécurisé Diaspora
        if (allowEscrow) ...[
          InkWell(
            key: const Key('settlement_option_wallet_escrow'),
            onTap: () {
              setState(() {
                _selectedSettlementType = PaymentSettlementType.walletEscrow;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _selectedSettlementType == PaymentSettlementType.walletEscrow
                    ? (isDark ? const Color(0xFF0F291E) : const Color(0xFFECFDF5))
                    : (isDark ? const Color(0xFF252525) : Colors.grey[50]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedSettlementType == PaymentSettlementType.walletEscrow
                      ? Colors.green
                      : Colors.grey.withValues(alpha: 0.25),
                  width: _selectedSettlementType == PaymentSettlementType.walletEscrow ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedSettlementType == PaymentSettlementType.walletEscrow
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: _selectedSettlementType == PaymentSettlementType.walletEscrow
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Séquestre Sécurisé Diaspora',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Protection Diaspora 100%',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 34),
                    child: Text(
                      'Vos fonds sont bloqués en toute sécurité sur votre portefeuille et ne sont libérés qu\'après validation de la livraison par code secret OTP.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Option B: Règlement Direct en Espèces
        if (allowDirect) ...[
          InkWell(
            key: const Key('settlement_option_direct_handover'),
            onTap: () {
              setState(() {
                _selectedSettlementType = PaymentSettlementType.directHandover;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _selectedSettlementType == PaymentSettlementType.directHandover
                    ? (isDark ? const Color(0xFF2E2405) : const Color(0xFFFFFBEB))
                    : (isDark ? const Color(0xFF252525) : Colors.grey[50]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedSettlementType == PaymentSettlementType.directHandover
                      ? Colors.amber[700]!
                      : Colors.grey.withValues(alpha: 0.25),
                  width: _selectedSettlementType == PaymentSettlementType.directHandover ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedSettlementType == PaymentSettlementType.directHandover
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: _selectedSettlementType == PaymentSettlementType.directHandover
                            ? Colors.amber[800]
                            : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Règlement Direct en Espèces',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Paiement en main propre',
                          style: TextStyle(
                            color: Colors.amber[900],
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 34),
                    child: Text(
                      'Vous remettrez le montant convenu directement au voyageur en espèces lors de la prise en charge physique du colis.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Direct Cash Timing options if Direct Handover is selected
        if (_selectedSettlementType == PaymentSettlementType.directHandover) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 16, color: Colors.amber),
                    SizedBox(width: 6),
                    Text(
                      'Moment de remise des espèces :',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        key: const Key('cash_timing_pickup'),
                        onTap: () => setState(() => _selectedCashTiming = DirectCashTiming.atPickup),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          decoration: BoxDecoration(
                            color: _selectedCashTiming == DirectCashTiming.atPickup
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedCashTiming == DirectCashTiming.atPickup
                                  ? AppColors.primary
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'À la prise en charge\n(Expéditeur)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: _selectedCashTiming == DirectCashTiming.atPickup
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedCashTiming == DirectCashTiming.atPickup
                                  ? AppColors.primary
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        key: const Key('cash_timing_delivery'),
                        onTap: () => setState(() => _selectedCashTiming = DirectCashTiming.atDelivery),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          decoration: BoxDecoration(
                            color: _selectedCashTiming == DirectCashTiming.atDelivery
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _selectedCashTiming == DirectCashTiming.atDelivery
                                  ? AppColors.primary
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'À la livraison\n(Destinataire)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: _selectedCashTiming == DirectCashTiming.atDelivery
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedCashTiming == DirectCashTiming.atDelivery
                                  ? AppColors.primary
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceBreakdownCard(BuildContext context, bool isDark) {
    final isEscrow = _selectedSettlementType == PaymentSettlementType.walletEscrow;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isEscrow ? Icons.receipt_long_rounded : Icons.payments_outlined,
                color: isEscrow ? const Color(0xFF4338CA) : Colors.amber[800],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isEscrow
                    ? 'Récapitulatif financier transparent'
                    : 'Récapitulatif financier (Règlement direct)',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isEscrow) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Montant voyageur (${_requestedWeight.toStringAsFixed(_requestedWeight == _requestedWeight.toInt() ? 0 : 1)} kg × ${_formatAmount(_pricePerKg)} $_currency/kg)',
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.grey[700]),
                ),
                Text(
                  '${_formatAmount(_travelerAmount)} $_currency',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Frais de service plateforme (10%)',
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    const Tooltip(
                      message: 'Couvre le séquestre bancaire, la vérification KYC et la garantie litige',
                      child: Icon(Icons.info_outline_rounded, size: 14, color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  '${_formatAmount(_platformFee)} $_currency',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total sous séquestre sécurisé',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                Text(
                  '${_formatAmount(_totalEscrowAmount)} $_currency',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: isDark ? Colors.amber[300] : AppColors.primary,
                  ),
                ),
              ],
            ),
          ] else ...[
            if (_platformDirectFee > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Frais de réservation plateforme débités maintenant :',
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.grey[700]),
                  ),
                  Text(
                    '${_formatAmount(_platformDirectFee)} $_currency',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Frais de réservation :',
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.grey[700]),
                  ),
                  Text(
                    '0 $_currency',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Montant en espèces à remettre au voyageur :',
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.grey[700]),
                  ),
                ),
                Text(
                  '${_formatAmount(_travelerAmount)} $_currency',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total prélevé sur Wallet',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                Text(
                  '${_formatAmount(_platformDirectFee)} $_currency',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Montant en espèces au voyageur',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.amber),
                ),
                Text(
                  '${_formatAmount(_travelerAmount)} $_currency',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEscrowSecurityBanner(BuildContext context, bool isDark) {
    final isEscrow = _selectedSettlementType == PaymentSettlementType.walletEscrow;

    if (isEscrow) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F291E) : const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.security_rounded, color: Colors.green, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Vos fonds restent sécurisés sous séquestre. Le voyageur ne percevra sa rémunération qu\'après validation définitive de la livraison par votre code OTP secret.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.green[200] : Colors.green[900],
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2E2405) : const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.amber[800], size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Règlement direct en espèces : Les codes secrets OTP de remise et de livraison restent 100% obligatoires pour valider formellement la prise en charge et sécuriser le suivi de votre colis.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.amber[200] : Colors.amber[900],
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildConfirmButton(BuildContext context) {
    final activeProfile = ref.watch(activeProfileProvider);
    final isProfileActive = activeProfile != null && activeProfile.isValidated;
    final isEscrow = _selectedSettlementType == PaymentSettlementType.walletEscrow;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        key: const Key('confirm_escrow_booking_button'),
        onPressed: _isLoading || !isProfileActive ? null : _submitBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEscrow ? AppColors.primary : Colors.amber[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                isEscrow
                    ? 'Confirmer et bloquer sous séquestre'
                    : 'Confirmer la réservation directe',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}
