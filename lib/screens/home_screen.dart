import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/currency.dart';
import '../widgets/brutalist_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    final activeSubs = subscriptions.where((s) => s.isActive).toList();
    final now = DateTime.now();
    final thisMonth = now.month;
    final thisYear = now.year;

    final monthlyTotal = activeSubs
        .where((s) =>
            s.nextBillingDate.month == thisMonth &&
            s.nextBillingDate.year == thisYear)
        .fold(0.0, (sum, s) => sum + s.price);

    final weeklyRenewals = activeSubs
        .where((s) {
          final diff = s.nextBillingDate.difference(now).inDays;
          return diff >= 0 && diff <= 7;
        })
        .toList()
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));

    final sortedActive = List<Subscription>.from(activeSubs)
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));

    Subscription? nearest;
    if (sortedActive.isNotEmpty) {
      nearest = sortedActive.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SUBTRACK'),
      ),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        backgroundColor: theme.scaffoldBackgroundColor,
        onRefresh: () async {
          ref.read(subscriptionsProvider.notifier).load();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'DASHBOARD',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMMM yyyy').format(now).toUpperCase(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            BrutalistCard(
              backgroundColor: theme.colorScheme.primary,
              borderColor: theme.colorScheme.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL THIS MONTH',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(monthlyTotal, settings.primaryCurrency),
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACTIVE',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              '${activeSubs.length}',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DUE THIS WEEK',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                '${weeklyRenewals.length}',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (nearest != null) ...[
              BrutalistCard(
                borderColor: Colors.orange,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NEAREST BILL',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nearest.name,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat('MMM d').format(nearest.nextBillingDate)} — ${formatCurrency(nearest.price, nearest.currency)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: Text(
                        '${nearest.nextBillingDate.difference(now).inDays}d',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (weeklyRenewals.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RENEWALS THIS WEEK',
                    style: theme.textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () => context.go('/subscriptions'),
                    child: const Text('SEE ALL'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...weeklyRenewals.map((sub) => _buildSubscriptionItem(context, sub)),
              const SizedBox(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ACTIVE SUBSCRIPTIONS',
                  style: theme.textTheme.headlineMedium,
                ),
                TextButton(
                  onPressed: () => context.go('/subscriptions'),
                  child: const Text('SEE ALL'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (sortedActive.isEmpty)
              BrutalistCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'NO ACTIVE SUBSCRIPTIONS',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              )
            else
              ...sortedActive.take(5).map((sub) => _buildSubscriptionItem(context, sub)),
            if (sortedActive.length > 5) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/subscriptions'),
                  child: Text(
                    '+ ${sortedActive.length - 5} MORE',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/subscription/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSubscriptionItem(BuildContext context, Subscription sub) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isToday = sub.nextBillingDate.year == now.year &&
        sub.nextBillingDate.month == now.month &&
        sub.nextBillingDate.day == now.day;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BrutalistCard(
        onTap: () => context.push('/subscription/${sub.id}'),
        borderColor: isToday ? Colors.orange : null,
        borderWidth: isToday ? 3 : 2,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  sub.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub.name.toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${sub.categoryEnum.label} — ${DateFormat('MMM d').format(sub.nextBillingDate)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(sub.price, sub.currency),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 15,
                  ),
                ),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
