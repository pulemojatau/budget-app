import 'package:uuid/uuid.dart';

class BudgetCategory {
  final String id;
  final String name;
  final double allocatedAmount;
  final double spentAmount;
  final String icon;
  final int colorIndex;

  BudgetCategory({
    String? id,
    required this.name,
    required this.allocatedAmount,
    this.spentAmount = 0.0,
    this.icon = '💰',
    this.colorIndex = 0,
  }) : id = id ?? const Uuid().v4();

  double get remainingBalance => allocatedAmount - spentAmount;
  double get spentPercentage => allocatedAmount > 0 ? (spentAmount / allocatedAmount).clamp(0.0, 1.0) : 0.0;
  bool get isOverspent => remainingBalance < 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'allocatedAmount': allocatedAmount,
        'spentAmount': spentAmount,
        'icon': icon,
        'colorIndex': colorIndex,
      };

  factory BudgetCategory.fromJson(Map<String, dynamic> json) => BudgetCategory(
        id: json['id'],
        name: json['name'],
        allocatedAmount: (json['allocatedAmount'] as num).toDouble(),
        spentAmount: (json['spentAmount'] as num).toDouble(),
        icon: json['icon'] ?? '💰',
        colorIndex: json['colorIndex'] ?? 0,
      );

  BudgetCategory copyWith({
    String? name,
    double? allocatedAmount,
    double? spentAmount,
    String? icon,
    int? colorIndex,
  }) {
    return BudgetCategory(
      id: id,
      name: name ?? this.name,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      icon: icon ?? this.icon,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
}
