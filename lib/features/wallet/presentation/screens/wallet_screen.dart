import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../shared/widgets/containers/neumorphic_container.dart';
import '../controllers/wallet_notifier.dart';
import '../../domain/entities/wallet.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletAsync = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildBackground(isDark),
          SafeArea(
            child: walletAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erreur: $error')),
              data:
                  (wallet) => CustomScrollView(
                    slivers: [
                      _buildAppBar(context),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBalanceCard(context, isDark, wallet),
                              const SizedBox(height: 32),
                              _buildQuickActions(context, isDark),
                              const SizedBox(height: 32),
                              _buildSectionHeader(
                                'Transactions récentes',
                                context,
                              ),
                              const SizedBox(height: 16),
                              _buildTransactionsList(context, isDark),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Positioned(
      top: -100,
      right: -50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.getTextMain(context),
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Portefeuille',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.getTextMain(context),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.history_rounded,
            color: AppColors.getTextMain(context),
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, bool isDark, Wallet? wallet) {
    final balance = wallet?.balances['XOF'] ?? 0.0;
    return NeumorphicContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solde disponible',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${balance.toStringAsFixed(0)} XOF',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextMain(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.accent,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dernière mise à jour: Il y a 2 minutes',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final actions = [
      {
        'icon': Icons.arrow_upward_rounded,
        'label': 'Envoyer',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.arrow_downward_rounded,
        'label': 'Recevoir',
        'color': AppColors.accent,
      },
      {
        'icon': Icons.add_rounded,
        'label': 'Recharger',
        'color': AppColors.secondary,
      },
      {
        'icon': Icons.qr_code_scanner_rounded,
        'label': 'Scanner',
        'color': Colors.orange,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < actions.length - 1 ? 12 : 0,
                    ),
                    child: NeumorphicContainer(
                      onTap: () {
                        if (action['label'] == 'Envoyer') {
                          context.push('/wallet/send');
                        }
                      },
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (action['color'] as Color).withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              action['icon'] as IconData,
                              color: action['color'] as Color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            action['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextMain(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: (200 + index * 50).ms)
                .scale(begin: const Offset(0.8, 0.8));
          }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextMain(context),
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, bool isDark) {
    final transactions = [
      {
        'title': 'Paiement service',
        'subtitle': 'Cours de français',
        'amount': '-5,000',
        'date': 'Aujourd\'hui',
        'type': 'expense',
      },
      {
        'title': 'Recharge',
        'subtitle': 'Mobile Money',
        'amount': '+50,000',
        'date': 'Hier',
        'type': 'income',
      },
      {
        'title': 'Transfert reçu',
        'subtitle': 'De Jean Dupont',
        'amount': '+15,000',
        'date': '2 jours',
        'type': 'income',
      },
      {
        'title': 'Cotisation comité',
        'subtitle': 'Comité des Étudiants',
        'amount': '-2,500',
        'date': '3 jours',
        'type': 'expense',
      },
    ];

    return Column(
      children:
          transactions.asMap().entries.map((entry) {
            final index = entry.key;
            final tx = entry.value;
            final isExpense = tx['type'] == 'expense';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isExpense ? Colors.red : AppColors.accent)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExpense
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: isExpense ? Colors.red : AppColors.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.getTextMain(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tx['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.getTextSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${tx['amount']} XOF',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isExpense ? Colors.red : AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tx['date'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (300 + index * 50).ms).slideX(begin: 0.1);
          }).toList(),
    );
  }
}
