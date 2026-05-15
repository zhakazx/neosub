import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../utils/currency.dart';
import '../widgets/brutalist_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final subscriptions = ref.watch(subscriptionsProvider);
    final theme = Theme.of(context);

    final events = <DateTime, List<Subscription>>{};
    for (final sub in subscriptions.where((s) => s.isActive)) {
      final date = DateTime(
        sub.nextBillingDate.year,
        sub.nextBillingDate.month,
        sub.nextBillingDate.day,
      );
      events.putIfAbsent(date, () => []).add(sub);
    }

    final selectedSubs = _selectedDay != null
        ? events[DateTime(
              _selectedDay!.year,
              _selectedDay!.month,
              _selectedDay!.day,
            )] ??
            []
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CALENDAR'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                width: 2,
              ),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: 'MONTH',
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronIcon: const Icon(Icons.chevron_left, size: 28),
                rightChevronIcon: const Icon(Icons.chevron_right, size: 28),
                titleTextStyle: theme.textTheme.headlineMedium!,
                headerPadding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      width: 2,
                    ),
                  ),
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: theme.textTheme.labelLarge!,
                weekendStyle: theme.textTheme.labelLarge!.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                cellPadding: EdgeInsets.zero,
                cellMargin: const EdgeInsets.all(2),
                defaultDecoration: const BoxDecoration(),
                weekendDecoration: const BoxDecoration(),
                holidayDecoration: const BoxDecoration(),
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                todayTextStyle: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  border: Border.all(
                    color: theme.colorScheme.secondary,
                    width: 2,
                  ),
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
                markerDecoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.rectangle,
                ),
                markerSize: 6,
                markersMaxCount: 3,
                markersAlignment: Alignment.bottomCenter,
                markerMargin: const EdgeInsets.only(top: 2),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.take(3).map((_) {
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            border: Border.all(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              eventLoader: (day) {
                return events[DateTime(day.year, day.month, day.day)] ?? [];
              },
            ),
          ),
          const Divider(height: 2, thickness: 2),
          Expanded(
            child: selectedSubs.isEmpty
                ? Center(
                    child: Text(
                      _selectedDay == null
                          ? 'SELECT A DATE'
                          : 'NO RENEWALS ON THIS DATE',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedSubs.length,
                    itemBuilder: (context, index) {
                      final sub = selectedSubs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BrutalistCard(
                          onTap: () => context.push('/subscription/${sub.id}'),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  border: Border.all(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    sub.name.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub.name.toUpperCase(),
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(fontSize: 14),
                                    ),
                                    Text(
                                      '${sub.categoryEnum.label} — ${sub.billingCycleEnum.label}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formatCurrency(sub.price, sub.currency),
                                style: theme.textTheme.titleLarge
                                    ?.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
