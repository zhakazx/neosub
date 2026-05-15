import 'package:hive/hive.dart';
import 'billing_cycle.dart';
import 'subscription_status.dart';
import 'category.dart';

@HiveType(typeId: 0)
class Subscription extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  String currency;

  @HiveField(4)
  String billingCycle;

  @HiveField(5)
  DateTime startDate;

  @HiveField(6)
  DateTime nextBillingDate;

  @HiveField(7)
  String category;

  @HiveField(8)
  String status;

  @HiveField(9)
  String? notes;

  @HiveField(10)
  String? iconPath;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.startDate,
    required this.nextBillingDate,
    required this.category,
    required this.status,
    this.notes,
    this.iconPath,
    required this.createdAt,
    required this.updatedAt,
  });

  BillingCycle get billingCycleEnum => BillingCycle.values.firstWhere(
    (e) => e.name == billingCycle,
    orElse: () => BillingCycle.monthly,
  );

  SubscriptionStatus get statusEnum => SubscriptionStatus.values.firstWhere(
    (e) => e.name == status,
    orElse: () => SubscriptionStatus.active,
  );

  Category get categoryEnum => Category.fromString(category);

  Subscription copyWith({
    String? id,
    String? name,
    double? price,
    String? currency,
    String? billingCycle,
    DateTime? startDate,
    DateTime? nextBillingDate,
    String? category,
    String? status,
    String? notes,
    String? iconPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      billingCycle: billingCycle ?? this.billingCycle,
      startDate: startDate ?? this.startDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      category: category ?? this.category,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      iconPath: iconPath ?? this.iconPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  DateTime calculateNextBillingDate() {
    final now = DateTime.now();
    var next = nextBillingDate;
    final cycle = billingCycleEnum;

    while (next.isBefore(now) || next.isAtSameMomentAs(now)) {
      switch (cycle) {
        case BillingCycle.weekly:
          next = next.add(const Duration(days: 7));
        case BillingCycle.monthly:
          next = DateTime(next.year, next.month + 1, next.day);
        case BillingCycle.yearly:
          next = DateTime(next.year + 1, next.month, next.day);
      }
    }
    return next;
  }

  bool get isActive => statusEnum == SubscriptionStatus.active;
}
