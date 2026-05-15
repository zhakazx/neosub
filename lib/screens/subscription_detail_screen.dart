import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../models/subscription_status.dart';
import '../providers/subscription_provider.dart';
import '../router/app_router.dart';
import '../utils/brutalist_theme.dart';
import '../utils/currency.dart';
import '../widgets/brutalist_card.dart';
import '../widgets/brutalist_button.dart';

class SubscriptionDetailScreen extends ConsumerWidget {
  final String subscriptionId;

  const SubscriptionDetailScreen({super.key, required this.subscriptionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final theme = Theme.of(context);

    final sub = subscriptions.firstWhere(
      (s) => s.id == subscriptionId,
      orElse: () => Subscription(
        id: '',
        name: 'Not Found',
        price: 0,
        currency: 'IDR',
        billingCycle: 'monthly',
        startDate: DateTime.now(),
        nextBillingDate: DateTime.now(),
        category: 'other',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (sub.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.yellow,
          foregroundColor: AppColors.black,
          title: const Text('NOT FOUND'),
        ),
        body: const Center(child: Text('Subscription not found')),
      );
    }

    final now = DateTime.now();
    final daysRemaining = sub.nextBillingDate.difference(now).inDays;
    final statusColor = AppColors.statusColor(sub.statusEnum);
    final catColor = AppColors.categoryColor(sub.categoryEnum);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.yellow,
        foregroundColor: AppColors.black,
        title: Text(sub.name.toUpperCase()),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: AppColors.black,
            onPressed: () => context.push('/subscription/edit/${sub.id}'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 140,
            child: Stack(
              children: [
                Positioned.fill(
                  child: BrutalistCard(
                    backgroundColor: catColor,
                    borderColor: catColor,
                    shadowOffset: const Offset(6, 6),
                    shadowColor: AppColors.black.withValues(alpha: 0.3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(
                              color: AppColors.black,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              sub.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: catColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sub.name.toUpperCase(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                ..._buildStars(theme),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      border: Border.all(color: AppColors.black, width: 2),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      sub.statusEnum.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor == AppColors.yellow
                            ? AppColors.black
                            : AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('DETAILS', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          BrutalistCard(
            shadowOffset: const Offset(3, 3),
            child: Column(
              children: [
                _DetailRow(
                  label: 'PRICE',
                  value: formatCurrency(sub.price, sub.currency),
                ),
                const Divider(height: 1),
                _DetailRow(
                  label: 'BILLING CYCLE',
                  value: sub.billingCycleEnum.label.toUpperCase(),
                ),
                const Divider(height: 1),
                _DetailRow(
                  label: 'CATEGORY',
                  value: sub.categoryEnum.label.toUpperCase(),
                ),
                const Divider(height: 1),
                _DetailRow(
                  label: 'START DATE',
                  value: DateFormat('MMM d, yyyy').format(sub.startDate),
                ),
                const Divider(height: 1),
                _DetailRow(
                  label: 'NEXT BILLING',
                  value: DateFormat('MMM d, yyyy').format(sub.nextBillingDate),
                ),
                const Divider(height: 1),
                _DetailRow(
                  label: 'DAYS REMAINING',
                  value: daysRemaining >= 0 ? '$daysRemaining days' : 'OVERDUE',
                  valueColor: daysRemaining < 0 ? AppColors.pink : null,
                ),
                if (sub.notes != null && sub.notes!.isNotEmpty) ...[
                  const Divider(height: 1),
                  _DetailRow(label: 'NOTES', value: sub.notes!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('ACTIONS', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          if (sub.statusEnum != SubscriptionStatus.active)
            BrutalistButton(
              label: 'ACTIVATE',
              variant: BrutalistButtonVariant.success,
              onPressed: () {
                ref
                    .read(subscriptionsProvider.notifier)
                    .updateStatus(sub.id, 'active');
              },
            ),
          if (sub.statusEnum != SubscriptionStatus.active)
            const SizedBox(height: 12),
          if (sub.statusEnum != SubscriptionStatus.paused)
            BrutalistButton(
              label: 'PAUSE',
              variant: BrutalistButtonVariant.warning,
              onPressed: () {
                ref
                    .read(subscriptionsProvider.notifier)
                    .updateStatus(sub.id, 'paused');
              },
            ),
          if (sub.statusEnum != SubscriptionStatus.paused)
            const SizedBox(height: 12),
          if (sub.statusEnum != SubscriptionStatus.cancelled)
            BrutalistButton(
              label: 'CANCEL',
              variant: BrutalistButtonVariant.secondary,
              onPressed: () {
                ref
                    .read(subscriptionsProvider.notifier)
                    .updateStatus(sub.id, 'cancelled');
              },
            ),
          if (sub.statusEnum != SubscriptionStatus.cancelled)
            const SizedBox(height: 12),
          BrutalistButton(
            label: 'EDIT SUBSCRIPTION',
            variant: BrutalistButtonVariant.success,
            onPressed: () => context.push('/subscription/edit/${sub.id}'),
          ),
          const SizedBox(height: 12),
          BrutalistButton(
            label: 'DELETE',
            variant: BrutalistButtonVariant.danger,
            onPressed: () => _showDeleteDialog(context, ref, sub),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  List<Widget> _buildStars(ThemeData theme) {
    final random = Random(subscriptionId.hashCode);
    final stars = <Widget>[];
    final starColors = [
      AppColors.yellow,
      AppColors.pink,
      AppColors.green,
      AppColors.purple,
    ];
    final starIcons = [Icons.star, Icons.star_border, Icons.auto_awesome];

    for (int i = 0; i < 5; i++) {
      final top = 8.0 + random.nextDouble() * 60;
      final right = 4.0 + random.nextDouble() * 40;
      final color = starColors[random.nextInt(starColors.length)];
      final icon = starIcons[random.nextInt(starIcons.length)];
      final size = 12.0 + random.nextDouble() * 10;

      stars.add(
        Positioned(
          top: top,
          right: right,
          child: Transform.rotate(
            angle: random.nextDouble() * 0.5 - 0.25,
            child: Icon(icon, color: color, size: size),
          ),
        ),
      );
    }
    return stars;
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Subscription sub,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DELETE SUBSCRIPTION?'),
        content: Text(
          'Are you sure you want to delete "${sub.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(subscriptionsProvider.notifier).delete(sub.id);
              if (context.mounted) {
                context.pop();
                context.pop();
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final rootContext = rootNavigatorKey.currentContext;
                if (rootContext != null) {
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    const SnackBar(
                      content: Text('SUBSCRIPTION DELETED'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              });
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
