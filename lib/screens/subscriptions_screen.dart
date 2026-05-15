import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../models/subscription_status.dart';
import '../models/category.dart';
import '../providers/subscription_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/brutalist_theme.dart';
import '../utils/currency.dart';
import '../widgets/brutalist_card.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  String _searchQuery = '';
  String? _statusFilter;
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
      if (_categoryFilter != null && sub.category != _categoryFilter) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.yellow,
        foregroundColor: AppColors.black,
        elevation: 0,
        title: const Text(
          'SUBSCRIPTIONS',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3),
          child: SizedBox(height: 3, child: ColoredBox(color: AppColors.black)),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.brightness == Brightness.dark
                      ? AppColors.white
                      : AppColors.black,
                  width: 3,
                ),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search subscriptions...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
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
                      _StatusFilterChip(
                        label: 'ALL',
                        selected: _statusFilter == null && _categoryFilter == null,
                        selectedColor: AppColors.purple,
                        onSelected: (_) => setState(() {
                          _statusFilter = null;
                          _categoryFilter = null;
                        }),
                      ),
                      const SizedBox(width: 8),
                      ...SubscriptionStatus.values.map(
                        (status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _StatusFilterChip(
                            label: status.label.toUpperCase(),
                            selected: _statusFilter == status.name,
                            onSelected: (selected) => setState(() {
                              _statusFilter = selected ? status.name : null;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: Category.values
                        .map(
                          (cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _CategoryFilterChip(
                              label: cat.label.toUpperCase(),
                              categoryColor: AppColors.categoryColor(cat),
                              selected: _categoryFilter == cat.name,
                              onSelected: (selected) => setState(() {
                                _categoryFilter = selected ? cat.name : null;
                              }),
                            ),
                          ),
                        )
                        .toList(),
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
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
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
                        child: _buildSubscriptionCard(
                          context,
                          sub,
                          settings.primaryCurrency,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/subscription/new'),
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.black, width: 3),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    Subscription sub,
    String primaryCurrency,
  ) {
    final theme = Theme.of(context);
    final statusColor = AppColors.statusColor(sub.statusEnum);
    final catColor = AppColors.categoryColor(sub.categoryEnum);

    return BrutalistCard(
      onTap: () => context.push('/subscription/${sub.id}'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: catColor,
              border: Border.all(color: AppColors.black, width: 3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                sub.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
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
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        border: Border.all(color: AppColors.black, width: 3),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        sub.statusEnum.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: statusColor == AppColors.yellow
                              ? AppColors.black
                              : AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${sub.categoryEnum.label} • ${sub.billingCycleEnum.label}',
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
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right,
            color: AppColors.black,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? selectedColor;
  final ValueChanged<bool> onSelected;

  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.white : AppColors.black;

    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (selectedColor ?? (isDark ? AppColors.white : AppColors.black))
              : (isDark ? AppColors.darkGrey : AppColors.white),
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              offset: const Offset(2, 2),
              color: isDark ? AppColors.white.withValues(alpha: 0.2) : AppColors.black,
            ),
          ],
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            color: selected
                ? (selectedColor != null
                    ? AppColors.white
                    : (isDark ? AppColors.black : AppColors.white))
                : (isDark ? AppColors.white : AppColors.black),
          ),
        ),
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final Color categoryColor;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _CategoryFilterChip({
    required this.label,
    required this.categoryColor,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.white : AppColors.black;

    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? categoryColor : (isDark ? AppColors.darkGrey : AppColors.white),
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              offset: const Offset(2, 2),
              color: isDark ? AppColors.white.withValues(alpha: 0.2) : AppColors.black,
            ),
          ],
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            color: selected
                ? AppColors.white
                : (isDark ? AppColors.white : AppColors.black),
          ),
        ),
      ),
    );
  }
}
