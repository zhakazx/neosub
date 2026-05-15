import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class ReminderSettings extends HiveObject {
  @HiveField(0)
  List<int> daysBefore;

  @HiveField(1)
  int notificationHour;

  @HiveField(2)
  int notificationMinute;

  @HiveField(3)
  bool isEnabled;

  @HiveField(4)
  String primaryCurrency;

  @HiveField(5)
  bool darkMode;

  ReminderSettings({
    this.daysBefore = const [1, 7],
    this.notificationHour = 9,
    this.notificationMinute = 0,
    this.isEnabled = true,
    this.primaryCurrency = 'IDR',
    this.darkMode = false,
  });

  ReminderSettings copyWith({
    List<int>? daysBefore,
    int? notificationHour,
    int? notificationMinute,
    bool? isEnabled,
    String? primaryCurrency,
    bool? darkMode,
  }) {
    return ReminderSettings(
      daysBefore: daysBefore ?? this.daysBefore,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      isEnabled: isEnabled ?? this.isEnabled,
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
