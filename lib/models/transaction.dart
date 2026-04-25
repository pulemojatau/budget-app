import 'package:uuid/uuid.dart';

enum TransactionType { expense, adjustment }

class TransactionRecord {
  final String id;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final double amount;
  final DateTime date;
  final String note;
  final TransactionType type;

  TransactionRecord({
    String? id,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon = '💰',
    required this.amount,
    required this.date,
    this.note = '',
    required this.type,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'categoryIcon': categoryIcon,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
        'type': type.index,
      };

  factory TransactionRecord.fromJson(Map<String, dynamic> json) => TransactionRecord(
        id: json['id'],
        categoryId: json['categoryId'],
        categoryName: json['categoryName'],
        categoryIcon: json['categoryIcon'] ?? '💰',
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        note: json['note'] ?? '',
        type: TransactionType.values[json['type'] as int],
      );
}
