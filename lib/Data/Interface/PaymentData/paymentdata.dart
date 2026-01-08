import 'dart:ui';

class Plan {
  final String id;
  final String name;
  final String description;
  final int price;
  final String period;
  final int limit;
  final int used;
  final List<String> features;
  final List<Color> gradient;
  final bool popular;

  Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.period,
    required this.limit,
    required this.used,
    required this.features,
    required this.gradient,
    this.popular = false,
  });
}
