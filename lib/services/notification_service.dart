import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/subscription.dart';
import '../models/reminder_settings.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final androidPermission = await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final iosPermission = await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return androidPermission == true || iosPermission == true;
  }

  Future<void> scheduleSubscriptionReminders(
    Subscription subscription,
    ReminderSettings settings,
  ) async {
    if (!settings.isEnabled || !subscription.isActive) return;

    await cancelSubscriptionReminders(subscription.id);

    final nextBilling = subscription.calculateNextBillingDate();

    for (final days in settings.daysBefore) {
      final reminderDate = DateTime(
        nextBilling.year,
        nextBilling.month,
        nextBilling.day,
        settings.notificationHour,
        settings.notificationMinute,
      ).subtract(Duration(days: days));

      if (reminderDate.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: '${subscription.id}_$days'.hashCode,
          title: 'Upcoming Renewal',
          body:
              '${subscription.name} renews in $days ${days == 1 ? 'day' : 'days'} — ${subscription.currency}${subscription.price.toStringAsFixed(0)}',
          scheduledDate: reminderDate,
        );
      }
    }

    final billingDayNotification = DateTime(
      nextBilling.year,
      nextBilling.month,
      nextBilling.day,
      settings.notificationHour,
      settings.notificationMinute,
    );

    if (billingDayNotification.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: '${subscription.id}_today'.hashCode,
        title: 'Renewal Today',
        body:
            '${subscription.name} renews today — ${subscription.currency}${subscription.price.toStringAsFixed(0)}',
        scheduledDate: billingDayNotification,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'subscription_reminders',
          'Subscription Reminders',
          channelDescription:
              'Notifications for upcoming subscription renewals',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelSubscriptionReminders(String subscriptionId) async {
    final ids = [
      '${subscriptionId}_1'.hashCode,
      '${subscriptionId}_3'.hashCode,
      '${subscriptionId}_5'.hashCode,
      '${subscriptionId}_7'.hashCode,
      '${subscriptionId}_14'.hashCode,
      '${subscriptionId}_today'.hashCode,
    ];
    for (final id in ids) {
      await _notifications.cancel(id);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
