import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_settings.dart';
import '../repositories/settings_repository.dart';
import '../services/notification_service.dart';

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

final notificationServiceProvider = Provider((ref) => NotificationService());

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, ReminderSettings>((ref) {
  return SettingsNotifier(
    ref.watch(settingsRepositoryProvider),
  );
});

class SettingsNotifier extends StateNotifier<ReminderSettings> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(_repo.getSettings());

  Future<void> save(ReminderSettings settings) async {
    await _repo.saveSettings(settings);
    state = settings;
  }

  Future<void> toggleNotifications(bool enabled) async {
    final updated = state.copyWith(isEnabled: enabled);
    await save(updated);
  }

  Future<void> toggleDarkMode(bool darkMode) async {
    final updated = state.copyWith(darkMode: darkMode);
    await save(updated);
  }

  Future<void> setPrimaryCurrency(String currency) async {
    final updated = state.copyWith(primaryCurrency: currency);
    await save(updated);
  }

  Future<void> setReminderDays(List<int> days) async {
    final updated = state.copyWith(daysBefore: days);
    await save(updated);
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    final updated = state.copyWith(
      notificationHour: hour,
      notificationMinute: minute,
    );
    await save(updated);
  }
}
