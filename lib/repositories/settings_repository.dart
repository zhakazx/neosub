import '../models/reminder_settings.dart';
import '../services/hive_service.dart';

class SettingsRepository {
  final _hive = HiveService();

  ReminderSettings getSettings() {
    return _hive.settingsBox.get('default') ?? ReminderSettings();
  }

  Future<void> saveSettings(ReminderSettings settings) async {
    await _hive.settingsBox.put('default', settings);
  }
}
