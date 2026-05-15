enum Category {
  entertainment('Entertainment'),
  productivity('Productivity'),
  cloud('Cloud'),
  aiTools('AI Tools'),
  design('Design'),
  development('Development'),
  healthFitness('Health & Fitness'),
  education('Education'),
  newsMedia('News & Media'),
  other('Other');

  final String label;

  const Category(this.label);

  static Category fromString(String value) {
    return Category.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Category.other,
    );
  }
}
