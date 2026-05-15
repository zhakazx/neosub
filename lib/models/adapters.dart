import 'package:hive/hive.dart';
import 'subscription.dart';
import 'reminder_settings.dart';

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 0;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as double,
      currency: fields[3] as String,
      billingCycle: fields[4] as String,
      startDate: fields[5] as DateTime,
      nextBillingDate: fields[6] as DateTime,
      category: fields[7] as String,
      status: fields[8] as String,
      notes: fields[9] as String?,
      iconPath: fields[10] as String?,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.billingCycle)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.nextBillingDate)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.iconPath)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderSettingsAdapter extends TypeAdapter<ReminderSettings> {
  @override
  final int typeId = 1;

  @override
  ReminderSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderSettings(
      daysBefore: (fields[0] as List).cast<int>(),
      notificationHour: fields[1] as int,
      notificationMinute: fields[2] as int,
      isEnabled: fields[3] as bool,
      primaryCurrency: fields[4] as String,
      darkMode: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.daysBefore)
      ..writeByte(1)
      ..write(obj.notificationHour)
      ..writeByte(2)
      ..write(obj.notificationMinute)
      ..writeByte(3)
      ..write(obj.isEnabled)
      ..writeByte(4)
      ..write(obj.primaryCurrency)
      ..writeByte(5)
      ..write(obj.darkMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
