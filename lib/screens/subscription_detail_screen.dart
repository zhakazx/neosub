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
          elevation: 0,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(3),
            child: SizedBox(height: 3, child: ColoredBox(color: AppColors.black)),
          ),
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3),
          child: SizedBox(height: 3, child: ColoredBox(color: AppColors.black)),
        ),
        title: Text(
          sub.name.toUpperCase(),
          style: const TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: AppColors.black,
            ),
            onPressed: () => context.push('/subscription/edit/${sub.id}'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Stack(
            children: [
              BrutalistCard(
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: catColor,
                        border: Border.all(color: AppColors.black, width: 3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          sub.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.name.toUpperCase(),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              border: Border.all(
                                color: AppColors.black,
                                width: 3,
                              ),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ..._buildStars(theme),
            ],
          ),
          const SizedBox(height: 24),
          Text('DETAILS', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          BrutalistCard(
            child: Column(
              children: [
                _DetailRow(
                  label: 'Price',
                  value: formatCurrency(sub.price, sub.currency),
                ),
                const Divider(height: 3, thickness: 3),
                _DetailRow(
                  label: 'Billing Cycle',
                  value: sub.billingCycleEnum.label,
                ),
                const Divider(height: 3, thickness: 3),
                _DetailRow(
                  label: 'Category',
                  value: sub.categoryEnum.label,
                ),
                const Divider(height: 3, thickness: 3),
                _DetailRow(
                  label: 'Start Date',
                  value: DateFormat('MMM d, yyyy').format(sub.startDate),
                ),
                const Divider(height: 3, thickness: 3),
                _DetailRow(
                  label: 'Next Billing',
                  value: DateFormat('MMM d, yyyy').format(sub.nextBillingDate),
                ),
                const Divider(height: 3, thickness: 3),
                _DetailRow(
                  label: 'Days Remaining',
                  value: daysRemaining >= 0 ? '$daysRemaining days' : 'OVERDUE',
                  valueColor: daysRemaining < 0
                      ? AppColors.pink
                      : AppColors.purple,
                ),
                if (sub.notes != null && sub.notes!.isNotEmpty) ...[
                  const Divider(height: 3, thickness: 3),
                  _DetailRow(label: 'Notes', value: sub.notes!),
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
              backgroundColor: AppColors.orange,
              foregroundColor: AppColors.black,
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
