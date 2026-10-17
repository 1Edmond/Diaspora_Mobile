import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../controllers/wallet_notifier.dart';
import '../../domain/entities/currency.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<String?> _promptPinDialog({required bool isPinSet}) async {
    final pinController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          isPinSet
              ? 'Code PIN Portefeuille'
              : 'Créer un code PIN Portefeuille',
        ),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: InputDecoration(
            labelText: isPinSet
                ? 'Saisissez votre PIN à 4 chiffres'
                : 'Choisissez un PIN à 4 chiffres',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = pinController.text.trim();
              if (text.length == 4) {
                Navigator.of(ctx).pop(text);
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final amountText = _amountController.text.trim();
    final recipient = _recipientController.text.trim();
    if (amountText.isEmpty || recipient.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir le montant et le destinataire'),
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Montant invalide')));
      return;
    }

    final notifier = ref.read(walletProvider.notifier);
    final pinSet = await notifier.isPinSet();
    final canBio = await notifier.canCheckBiometrics();

    bool useBiometrics = false;
    String? pin;

    if (canBio && pinSet) {
      useBiometrics = true;
    } else {
      if (!mounted) return;
      pin = await _promptPinDialog(isPinSet: pinSet);
      if (pin == null || pin.isEmpty) {
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      await notifier.transferWithAuth(
        recipient,
        amount,
        Currency(
          code: 'XOF',
          symbol: 'CFA',
          name: 'XOF',
          flag: '',
        ),
        pin: pin,
        useBiometrics: useBiometrics,
        note: _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transfert réussi !')));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Envoyer de l\'argent')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            NeumorphicContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _recipientController,
                    decoration: InputDecoration(
                      labelText: 'Destinataire (ID)',
                      hintText: 'ex: user_123',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Montant',
                      suffixText: 'XOF',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Note (optionnel)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Confirmer le transfert',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
