import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/subscription.dart';
import '../models/reminder_settings.dart';
import '../models/adapters.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  Box<Subscription>? _subscriptionBox;
  Box<ReminderSettings>? _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SubscriptionAdapter());
    Hive.registerAdapter(ReminderSettingsAdapter());

    _subscriptionBox = await Hive.openBox<Subscription>('subscriptions');
    _settingsBox = await Hive.openBox<ReminderSettings>('settings');

    if (_settingsBox!.isEmpty) {
      await _settingsBox!.put('default', ReminderSettings());
    }
  }

  Box<Subscription> get subscriptionBox {
    if (_subscriptionBox == null) {
      throw StateError('HiveService not initialized. Call init() first.');
    }
    return _subscriptionBox!;
  }

  Box<ReminderSettings> get settingsBox {
    if (_settingsBox == null) {
      throw StateError('HiveService not initialized. Call init() first.');
    }
    return _settingsBox!;
  }
}
