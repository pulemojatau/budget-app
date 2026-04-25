import 'package:uuid/uuid.dart';

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final String icon;
  final DateTime? targetDate;

  SavingsGoal({
    String? id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0.0,
    this.icon = '🎯',
    this.targetDate,
  }) : id = id ?? const Uuid().v4();

  double get progress => targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => savedAmount >= targetAmount;
  double get remaining => (targetAmount - savedAmount).clamp(0.0, double.infinity);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'icon': icon,
        'targetDate': targetDate?.toIso8601String(),
      };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
        id: json['id'],
        name: json['name'],
        targetAmount: (json['targetAmount'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num).toDouble(),
        icon: json['icon'] ?? '🎯',
        targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      );

  SavingsGoal copyWith({
    String? name,
    double? targetAmount,
    double? savedAmount,
    String? icon,
    DateTime? targetDate,
  }) {
    return SavingsGoal(
      id: id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      icon: icon ?? this.icon,
      targetDate: targetDate ?? this.targetDate,
    );
  }
}
