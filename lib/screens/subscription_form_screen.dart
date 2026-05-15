import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/subscription.dart';
import '../models/billing_cycle.dart';
import '../models/category.dart';
import '../models/subscription_status.dart';
import '../providers/subscription_provider.dart';
import '../utils/currency.dart';
import '../widgets/brutalist_button.dart';

class SubscriptionFormScreen extends ConsumerStatefulWidget {
  final String? subscriptionId;

  const SubscriptionFormScreen({super.key, this.subscriptionId});

  @override
  ConsumerState<SubscriptionFormScreen> createState() =>
      _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState
    extends ConsumerState<SubscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  String _currency = 'IDR';
  BillingCycle _billingCycle = BillingCycle.monthly;
  DateTime _startDate = DateTime.now();
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  Category _category = Category.entertainment;
  SubscriptionStatus _status = SubscriptionStatus.active;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.subscriptionId != null) {
      final sub = ref
          .read(subscriptionsProvider)
          .firstWhere((s) => s.id == widget.subscriptionId);
      if (sub.id.isNotEmpty) {
        _nameController.text = sub.name;
        _priceController.text = sub.price.toString();
        _notesController.text = sub.notes ?? '';
        _currency = sub.currency;
        _billingCycle = sub.billingCycleEnum;
        _startDate = sub.startDate;
        _nextBillingDate = sub.nextBillingDate;
        _category = sub.categoryEnum;
        _status = sub.statusEnum;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateNextBillingDate() {
    switch (_billingCycle) {
      case BillingCycle.weekly:
        _nextBillingDate = _startDate.add(const Duration(days: 7));
      case BillingCycle.monthly:
        _nextBillingDate = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
      case BillingCycle.yearly:
        _nextBillingDate = DateTime(_startDate.year + 1, _startDate.month, _startDate.day);
    }
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final subscription = Subscription(
      id: widget.subscriptionId ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text),
      currency: _currency,
      billingCycle: _billingCycle.name,
      startDate: _startDate,
      nextBillingDate: _nextBillingDate,
      category: _category.name,
      status: _status.name,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.subscriptionId != null
          ? ref.read(subscriptionsProvider).firstWhere((s) => s.id == widget.subscriptionId).createdAt
          : now,
      updatedAt: now,
    );

    if (widget.subscriptionId != null) {
      await ref.read(subscriptionsProvider.notifier).update(subscription);
    } else {
      await ref.read(subscriptionsProvider.notifier).add(subscription);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _pickDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _nextBillingDate,
      firstDate: isStartDate ? DateTime(2000) : DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _updateNextBillingDate();
        } else {
          _nextBillingDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subscriptionId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'EDIT SUBSCRIPTION' : 'NEW SUBSCRIPTION'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'SERVICE NAME *',
                hintText: 'e.g. Netflix, ChatGPT Plus',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Service name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'PRICE *',
                      hintText: 'e.g. 54000',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Must be positive';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(_currency),
                    initialValue: _currency,
                    decoration: const InputDecoration(
                      labelText: 'CURRENCY *',
                    ),
                    items: supportedCurrencies
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _currency = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BillingCycle>(
              key: ValueKey(_billingCycle),
              initialValue: _billingCycle,
              decoration: const InputDecoration(
                labelText: 'BILLING CYCLE *',
              ),
              items: BillingCycle.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.label),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _billingCycle = value;
                    _updateNextBillingDate();
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'START DATE *',
                    date: _startDate,
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerField(
                    label: 'NEXT BILLING *',
                    date: _nextBillingDate,
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              key: ValueKey(_category),
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'CATEGORY *',
              ),
              items: Category.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.label),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            if (isEditing)
              DropdownButtonFormField<SubscriptionStatus>(
                key: ValueKey(_status),
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'STATUS *',
                ),
                items: SubscriptionStatus.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
            if (isEditing) const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'NOTES',
                hintText: 'Optional description...',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
            BrutalistButton(
              label: isEditing ? 'SAVE CHANGES' : 'ADD SUBSCRIPTION',
              onPressed: _isLoading ? null : _save,
            ),
            const SizedBox(height: 12),
            BrutalistButton(
              label: 'CANCEL',
              isPrimary: false,
              onPressed: () => context.pop(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(date),
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
