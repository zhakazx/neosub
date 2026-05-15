import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/settings_provider.dart';
import '../providers/subscription_provider.dart';
import '../utils/brutalist_theme.dart';
import '../utils/currency.dart';
import '../widgets/brutalist_card.dart';
import '../widgets/brutalist_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.black,
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('PREFERENCES', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          BrutalistCard(
            shadowOffset: const Offset(3, 3),
            child: Column(
              children: [
                _SettingsTile(
                  label: 'DARK MODE',
                  trailing: _NeoToggle(
                    value: settings.darkMode,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleDarkMode(value);
                    },
                    isDark: isDark,
                  ),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  label: 'PRIMARY CURRENCY',
                  trailing: DropdownButton<String>(
                    value: settings.primaryCurrency,
                    underline: const SizedBox.shrink(),
                    items: supportedCurrencies
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, style: theme.textTheme.bodyLarge),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(settingsProvider.notifier)
                            .setPrimaryCurrency(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('NOTIFICATIONS', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          BrutalistCard(
            shadowOffset: const Offset(3, 3),
            child: Column(
              children: [
                _SettingsTile(
                  label: 'ENABLE REMINDERS',
                  trailing: _NeoToggle(
                    value: settings.isEnabled,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleNotifications(value);
                    },
                    isDark: isDark,
                  ),
                ),
                if (settings.isEnabled) ...[
                  const Divider(height: 1),
                  _SettingsTile(
                    label: 'NOTIFICATION TIME',
                    trailing: TextButton(
                      onPressed: () => _pickTime(context, ref, settings),
                      child: Text(
                        '${settings.notificationHour.toString().padLeft(2, '0')}:${settings.notificationMinute.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REMIND ME BEFORE',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [1, 3, 5, 7, 14].map((days) {
                            final isSelected = settings.daysBefore.contains(
                              days,
                            );
                            return FilterChip(
                              label: Text(
                                'D-$days',
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                  color: isSelected
                                      ? theme
                                                .chipTheme
                                                .secondaryLabelStyle
                                                ?.color ??
                                            theme.colorScheme.onPrimary
                                      : theme.chipTheme.labelStyle?.color ??
                                            theme.colorScheme.onSurface,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                final newDays = List<int>.from(
                                  settings.daysBefore,
                                );
                                if (selected) {
                                  newDays.add(days);
                                } else {
                                  newDays.remove(days);
                                }
                                newDays.sort();
                                ref
                                    .read(settingsProvider.notifier)
                                    .setReminderDays(newDays);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('ABOUT', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          BrutalistCard(
            shadowOffset: const Offset(3, 3),
            child: Column(
              children: [
                _SettingsTile(
                  label: 'APP VERSION',
                  trailing: Text('1.0.0', style: theme.textTheme.bodyLarge),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  label: 'DEVELOPED BY',
                  trailing: Text('@zhakazx', style: theme.textTheme.bodyLarge),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          BrutalistButton(
            label: 'RESET ALL DATA',
            variant: BrutalistButtonVariant.danger,
            onPressed: () => _showResetDialog(context, ref),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    dynamic settings,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.notificationHour,
        minute: settings.notificationMinute,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: const TimePickerThemeData(
              dayPeriodBorderSide: BorderSide(color: AppColors.black, width: 2),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      ref
          .read(settingsProvider.notifier)
          .setNotificationTime(time.hour, time.minute);
    }
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('RESET ALL DATA?'),
        content: const Text(
          'This will delete all subscriptions and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              final subs = ref.read(subscriptionsProvider);
              for (final sub in subs) {
                await ref.read(subscriptionsProvider.notifier).delete(sub.id);
              }
              if (context.mounted) context.pop();
            },
            child: Text(
              'RESET',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final Widget trailing;

  const _SettingsTile({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          trailing,
        ],
      ),
    );
  }
}

class _NeoToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const _NeoToggle({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? AppColors.white : AppColors.black;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.linear,
        width: 48,
        height: 26,
        decoration: BoxDecoration(
          color: value ? AppColors.purple : const Color(0xFFDDDDDD),
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(9999),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
      ),
    );
  }
}
