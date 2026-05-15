const List<String> supportedCurrencies = [
  'IDR',
  'USD',
  'EUR',
  'GBP',
  'SGD',
  'JPY',
  'AUD',
  'CAD',
];

const Map<String, String> currencySymbols = {
  'IDR': 'Rp',
  'USD': '\$',
  'EUR': '€',
  'GBP': '£',
  'SGD': 'S\$',
  'JPY': '¥',
  'AUD': 'A\$',
  'CAD': 'C\$',
};

String formatCurrency(double amount, String currency) {
  final symbol = currencySymbols[currency] ?? currency;
  final formatted = amount.toStringAsFixed(
    amount.truncateToDouble() == amount ? 0 : 2,
  );
  return '$symbol$formatted';
}
