enum SubscriptionStatus {
  active('Active'),
  paused('Paused'),
  cancelled('Cancelled');

  final String label;

  const SubscriptionStatus(this.label);
}
