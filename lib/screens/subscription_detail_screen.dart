import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../models/subscription_status.dart';
import '../providers/subscription_provider.dart';
import '../router/app_router.dart';
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
        appBar: AppBar(title: const Text('NOT FOUND')),
        body: const Center(child: Text('Subscription not found')),
      );
    }

    final now = DateTime.now();
    final daysRemaining = sub.nextBillingDate.difference(now).inDays;
    final statusColor = _statusColor(sub.statusEnum);

    return Scaffold(
      appBar: AppBar(
        title: Text(sub.name.toUpperCase()),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/subscription/edit/${sub.id}'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BrutalistCard(
            backgroundColor: theme.colorScheme.primary,
            borderColor: theme.colorScheme.primary,
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary,
                    border: Border.all(
                      color: theme.colorScheme.onPrimary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      sub.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  sub.name.toUpperCase(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    sub.statusEnum.label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'DETAILS',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          BrutalistCard(
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
                  valueColor:
                      daysRemaining < 0 ? Colors.red : null,
                ),
                if (sub.notes != null && sub.notes!.isNotEmpty) ...[
                  const Divider(height: 1),
                  _DetailRow(
                    label: 'NOTES',
                    value: sub.notes!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ACTIONS',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          if (sub.statusEnum != SubscriptionStatus.active)
            BrutalistButton(
              label: 'ACTIVATE',
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
              isPrimary: false,
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
              isPrimary: false,
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
            isPrimary: false,
            onPressed: () => context.push('/subscription/edit/${sub.id}'),
          ),
          const SizedBox(height: 12),
          BrutalistButton(
            label: 'DELETE',
            isDestructive: true,
            isPrimary: false,
            onPressed: () => _showDeleteDialog(context, ref, sub),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Color _statusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.paused:
        return Colors.orange;
      case SubscriptionStatus.cancelled:
        return Colors.red;
    }
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
              await ref
                  .read(subscriptionsProvider.notifier)
                  .delete(sub.id);
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
              style: TextStyle(color: Colors.red),
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

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

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
