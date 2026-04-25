import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SummaryCard extends StatelessWidget {
  final double income;
  final double expenses;
  final double allocated;
  final double balance;
  final String currency;

  const SummaryCard({
    super.key,
    required this.income,
    required this.expenses,
    required this.allocated,
    required this.balance,
    this.currency = 'R',
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = balance < 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNegative
              ? [const Color(0xFF8B0000), const Color(0xFFCC2936)]
              : [const Color(0xFF3D2C8D), const Color(0xFF6C63FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (isNegative ? AppTheme.danger : AppTheme.primary).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'This Month',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$currency ${_fmt(balance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          if (isNegative)
            const Text(
              '⚠️ You\'ve over-allocated your budget',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            )
          else if (income == 0)
            const Text(
              'Add income to see your available balance',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            )
          else
            Text(
              'Unallocated funds ready to assign',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStat('Income', income, const Color(0xFF00D4AA), Icons.arrow_downward_rounded),
              const SizedBox(width: 12),
              _buildStat('Fixed', expenses, const Color(0xFFFF6B35), Icons.lock_outline_rounded),
              const SizedBox(width: 12),
              _buildStat('Budgeted', allocated, const Color(0xFF9B8FFF), Icons.pie_chart_outline_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, double value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 11, color: color),
                const SizedBox(width: 4),
                Text(label, style: TextStyle(color: color.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$currency ${_fmt(value)}',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v.abs() >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)}k';
    }
    return v.toStringAsFixed(0);
  }
}
