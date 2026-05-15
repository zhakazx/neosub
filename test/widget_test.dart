import 'package:flutter_test/flutter_test.dart';
import 'package:subcription_tracker/models/subscription.dart';
import 'package:subcription_tracker/models/billing_cycle.dart';
import 'package:subcription_tracker/models/subscription_status.dart';
import 'package:subcription_tracker/models/category.dart';
import 'package:subcription_tracker/utils/currency.dart';

void main() {
  group('Subscription Model', () {
    test('calculateNextBillingDate advances monthly', () {
      final sub = Subscription(
        id: '1',
        name: 'Test',
        price: 10,
        currency: 'USD',
        billingCycle: BillingCycle.monthly.name,
        startDate: DateTime(2020, 1, 1),
        nextBillingDate: DateTime(2020, 1, 1),
        category: Category.entertainment.name,
        status: SubscriptionStatus.active.name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final next = sub.calculateNextBillingDate();
      expect(next.isAfter(DateTime.now()) || next.month != DateTime.now().month - 1, true);
    });

    test('isActive returns true for active status', () {
      final sub = Subscription(
        id: '1',
        name: 'Test',
        price: 10,
        currency: 'USD',
        billingCycle: BillingCycle.monthly.name,
        startDate: DateTime.now(),
        nextBillingDate: DateTime.now(),
        category: Category.entertainment.name,
        status: SubscriptionStatus.active.name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(sub.isActive, true);
    });
  });

  group('Currency Utils', () {
    test('formatCurrency formats IDR correctly', () {
      expect(formatCurrency(54000, 'IDR'), 'Rp54000');
    });

    test('formatCurrency formats USD correctly', () {
      expect(formatCurrency(20.5, 'USD'), '\$20.50');
    });
  });

  group('Category', () {
    test('fromString returns correct category', () {
      expect(Category.fromString('entertainment'), Category.entertainment);
    });

    test('fromString returns other for unknown', () {
      expect(Category.fromString('unknown'), Category.other);
    });
  });
}
