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
import '../router/app_router.dart';
import '../utils/brutalist_theme.dart';
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
        _nextBillingDate = DateTime(
          _startDate.year,
          _startDate.month + 1,
          _startDate.day,
        );
      case BillingCycle.yearly:
        _nextBillingDate = DateTime(
          _startDate.year + 1,
          _startDate.month,
          _startDate.day,
        );
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
          ? ref
                .read(subscriptionsProvider)
                .firstWhere((s) => s.id == widget.subscriptionId)
                .createdAt
          : now,
      updatedAt: now,
    );

    if (widget.subscriptionId != null) {
      await ref.read(subscriptionsProvider.notifier).update(subscription);
    } else {
      await ref.read(subscriptionsProvider.notifier).add(subscription);
    }

    setState(() => _isLoading = false);

    final message = widget.subscriptionId != null
        ? 'SUBSCRIPTION UPDATED'
        : 'SUBSCRIPTION ADDED SUCCESSFULLY';

    if (mounted) {
      context.pop();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rootContext = rootNavigatorKey.currentContext;
      if (rootContext != null) {
        ScaffoldMessenger.of(rootContext).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
        backgroundColor: AppColors.purple,
        title: Text(isEditing ? 'EDIT SUBSCRIPTION' : 'NEW SUBSCRIPTION'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInputField(
              controller: _nameController,
              label: 'SERVICE NAME *',
              hint: 'e.g. Netflix, ChatGPT Plus',
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
                  child: _buildInputField(
                    controller: _priceController,
                    label: 'PRICE *',
                    hint: 'e.g. 54000',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                  child: _buildDropdownField<String>(
                    value: _currency,
                    label: 'CURRENCY *',
                    items: supportedCurrencies,
                    onChanged: (v) => setState(() => _currency = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdownField<BillingCycle>(
              value: _billingCycle,
              label: 'BILLING CYCLE *',
              items: BillingCycle.values,
              itemLabel: (c) => c.label,
              onChanged: (v) {
                setState(() {
                  _billingCycle = v;
                  _updateNextBillingDate();
                });
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
            _buildDropdownField<Category>(
              value: _category,
              label: 'CATEGORY *',
              items: Category.values,
              itemLabel: (c) => c.label,
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 16),
            if (isEditing)
              _buildDropdownField<SubscriptionStatus>(
                value: _status,
                label: 'STATUS *',
                items: SubscriptionStatus.values,
                itemLabel: (s) => s.label,
                onChanged: (v) => setState(() => _status = v),
              ),
            if (isEditing) const SizedBox(height: 16),
            _buildInputField(
              controller: _notesController,
              label: 'NOTES',
              hint: 'Optional description...',
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            BrutalistButton(
              label: isEditing ? 'SAVE CHANGES' : 'ADD SUBSCRIPTION',
              onPressed: _isLoading ? null : _save,
            ),
            const SizedBox(height: 12),
            BrutalistButton(
              label: 'CANCEL',
              variant: BrutalistButtonVariant.secondary,
              onPressed: () => context.pop(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
      keyboardType: keyboardType,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.words,
      validator: validator,
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required String label,
    required List<T> items,
    String Function(T)? itemLabel,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                itemLabel != null ? itemLabel(item) : item.toString(),
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
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
