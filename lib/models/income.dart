import 'package:uuid/uuid.dart';

class Income {
  final String id;
  final String source;
  final double amount;

  Income({
    String? id,
    required this.source,
    required this.amount,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'amount': amount,
      };

  factory Income.fromJson(Map<String, dynamic> json) => Income(
        id: json['id'],
        source: json['source'],
        amount: (json['amount'] as num).toDouble(),
      );
}
