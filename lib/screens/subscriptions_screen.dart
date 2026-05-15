import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../models/billing_cycle.dart';
import '../models/subscription_status.dart';
import '../models/category.dart';
import '../providers/subscription_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/currency.dart';
import '../widgets/brutalist_card.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  String _searchQuery = '';
  String? _statusFilter;
  String? _cycleFilter;
  String? _categoryFilter;

  @override
  Widget build(BuildContext context) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    var filtered = subscriptions.where((sub) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!sub.name.toLowerCase().contains(query) &&
            !sub.category.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_statusFilter != null && sub.status != _statusFilter) return false;
      if (_cycleFilter != null && sub.billingCycle != _cycleFilter) return false;
      if (_categoryFilter != null && sub.category != _categoryFilter) return false;
      return true;
    }).toList();

    filtered.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('SUBSCRIPTIONS'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerTheme.color ??
                      (theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black),
                  width: 2,
                ),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'SEARCH SUBSCRIPTIONS...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'ALL',
                        selected: _statusFilter == null &&
                            _cycleFilter == null &&
                            _categoryFilter == null,
                        onSelected: (_) => setState(() {
                          _statusFilter = null;
                          _cycleFilter = null;
                          _categoryFilter = null;
                        }),
                      ),
                      const SizedBox(width: 8),
                      ...SubscriptionStatus.values.map((status) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: status.label.toUpperCase(),
                              selected: _statusFilter == status.name,
                              onSelected: (selected) => setState(() {
                                _statusFilter = selected ? status.name : null;
                              }),
                            ),
                          )),
                      ...BillingCycle.values.map((cycle) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: cycle.label.toUpperCase(),
                              selected: _cycleFilter == cycle.name,
                              onSelected: (selected) => setState(() {
                                _cycleFilter = selected ? cycle.name : null;
                              }),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: Category.values.map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: cat.label.toUpperCase(),
                            selected: _categoryFilter == cat.name,
                            onSelected: (selected) => setState(() {
                              _categoryFilter = selected ? cat.name : null;
                            }),
                          ),
                        )).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'NO SUBSCRIPTIONS FOUND',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final sub = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSubscriptionCard(context, sub, settings.primaryCurrency),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/subscription/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    Subscription sub,
    String primaryCurrency,
  ) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(sub.statusEnum);

    return BrutalistCard(
      onTap: () => context.push('/subscription/${sub.id}'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              border: Border.all(color: statusColor, width: 2),
            ),
            child: Center(
              child: Text(
                sub.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sub.name.toUpperCase(),
                        style: theme.textTheme.titleLarge?.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        sub.statusEnum.label.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${sub.categoryEnum.label} — ${sub.billingCycleEnum.label}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Next: ${DateFormat('MMM d, yyyy').format(sub.nextBillingDate)}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCurrency(sub.price, sub.currency),
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 15),
          ),
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
      ),
    );
  }
}
