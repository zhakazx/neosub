enum BillingCycle {
  weekly('Weekly', 7),
  monthly('Monthly', 30),
  yearly('Yearly', 365);

  final String label;
  final int daysApprox;

  const BillingCycle(this.label, this.daysApprox);
}
