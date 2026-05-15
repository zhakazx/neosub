import '../models/subscription.dart';
import '../services/hive_service.dart';

class SubscriptionRepository {
  final _hive = HiveService();

  List<Subscription> getAll() {
    return _hive.subscriptionBox.values.toList();
  }

  Subscription? getById(String id) {
    return _hive.subscriptionBox.get(id);
  }

  Future<void> save(Subscription subscription) async {
    await _hive.subscriptionBox.put(subscription.id, subscription);
  }

  Future<void> delete(String id) async {
    await _hive.subscriptionBox.delete(id);
  }

  Future<void> updateNextBillingDate(Subscription subscription) async {
    final nextDate = subscription.calculateNextBillingDate();
    final updated = subscription.copyWith(nextBillingDate: nextDate);
    await save(updated);
  }
}
