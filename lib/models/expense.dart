import 'package:uuid/uuid.dart';

class Expense {
  final String id;
  final String name;
  final double amount;

  Expense({
    String? id,
    required this.name,
    required this.amount,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'],
        name: json['name'],
        amount: (json['amount'] as num).toDouble(),
      );
}
