import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../repositories/subscription_repository.dart';
import '../services/notification_service.dart';
import 'settings_provider.dart';

final subscriptionRepositoryProvider = Provider(
  (ref) => SubscriptionRepository(),
);

final subscriptionsProvider =
    StateNotifierProvider<SubscriptionNotifier, List<Subscription>>((ref) {
      return SubscriptionNotifier(
        ref.watch(subscriptionRepositoryProvider),
        ref.watch(notificationServiceProvider),
        ref,
      );
    });

class SubscriptionNotifier extends StateNotifier<List<Subscription>> {
  final SubscriptionRepository _repo;
  final NotificationService _notifications;
  final Ref _ref;

  SubscriptionNotifier(this._repo, this._notifications, this._ref) : super([]) {
    load();
  }

  void load() {
    final subs = _repo.getAll();
    state = subs;
  }

  Future<void> add(Subscription subscription) async {
    await _repo.save(subscription);
    try {
      final settings = _ref.read(settingsProvider);
      await _notifications.scheduleSubscriptionReminders(
        subscription,
        settings,
      );
    } catch (_) {}
    load();
  }

  Future<void> update(Subscription subscription) async {
    final updated = subscription.copyWith(updatedAt: DateTime.now());
    await _repo.save(updated);
    try {
      final settings = _ref.read(settingsProvider);
      await _notifications.scheduleSubscriptionReminders(updated, settings);
    } catch (_) {}
    load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    try {
      await _notifications.cancelSubscriptionReminders(id);
    } catch (_) {}
    load();
  }

  Future<void> updateStatus(String id, String status) async {
    final sub = _repo.getById(id);
    if (sub == null) return;
    final updated = sub.copyWith(status: status, updatedAt: DateTime.now());
    await _repo.save(updated);
    try {
      final settings = _ref.read(settingsProvider);
      if (status == 'active') {
        await _notifications.scheduleSubscriptionReminders(updated, settings);
      } else {
        await _notifications.cancelSubscriptionReminders(id);
      }
    } catch (_) {}
    load();
  }

  Future<void> refreshNotifications() async {
    final settings = _ref.read(settingsProvider);
    if (!settings.isEnabled) {
      await _notifications.cancelAllNotifications();
      return;
    }
    for (final sub in state.where((s) => s.isActive)) {
      await _notifications.scheduleSubscriptionReminders(sub, settings);
    }
  }
}
