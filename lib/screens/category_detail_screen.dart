import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class CategoryDetailScreen extends StatelessWidget {
  final BudgetCategory category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Consumer<BudgetProvider>(
        builder: (context, budget, _) {
          final cat = budget.categories.firstWhere((c) => c.id == category.id, orElse: () => category);
          final color = AppTheme.categoryColors[cat.colorIndex % AppTheme.categoryColors.length];
          final catTxs = budget.transactions.where((t) => t.categoryId == cat.id).toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppTheme.bgDark,
                expandedHeight: 220,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.3), AppTheme.bgDark],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: color.withOpacity(0.4)),
                                  ),
                                  child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 26))),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(cat.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
                                      if (cat.isOverspent)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.danger.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text('🚨 Overspent', style: TextStyle(color: AppTheme.danger, fontSize: 11, fontWeight: FontWeight.w700)),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Status card
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      borderColor: cat.isOverspent ? AppTheme.danger.withOpacity(0.3) : null,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatBox(
                                  label: 'Allocated',
                                  value: '${budget.currency} ${cat.allocatedAmount.toStringAsFixed(2)}',
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatBox(
                                  label: 'Spent',
                                  value: '${budget.currency} ${cat.spentAmount.toStringAsFixed(2)}',
                                  color: AppTheme.accentOrange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatBox(
                                  label: cat.isOverspent ? 'Over by' : 'Remaining',
                                  value: '${budget.currency} ${cat.remainingBalance.abs().toStringAsFixed(2)}',
                                  color: cat.isOverspent ? AppTheme.danger : AppTheme.accent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          PremiumProgressBar(
                            value: cat.spentPercentage,
                            color: cat.isOverspent ? AppTheme.danger : color,
                            height: 8,
                            showGlow: !cat.isOverspent,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(cat.spentPercentage * 100).toStringAsFixed(0)}% used',
                                style: TextStyle(
                                  color: cat.isOverspent ? AppTheme.danger : AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                cat.isOverspent ? 'Budget exceeded' : '${(100 - cat.spentPercentage * 100).toStringAsFixed(0)}% remaining',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: '➖',
                            label: 'Add Spending',
                            color: AppTheme.danger,
                            onTap: () => _showTransactionDialog(context, cat, isExpense: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: '➕',
                            label: 'Add Funds',
                            color: AppTheme.accent,
                            onTap: () => _showTransactionDialog(context, cat, isExpense: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Transaction history
                    SectionHeader(
                      title: 'Transactions',
                      actionLabel: catTxs.isNotEmpty ? '${catTxs.length} total' : null,
                    ),
                    const SizedBox(height: 12),
                    if (catTxs.isEmpty)
                      const EmptyState(
                        emoji: '📋',
                        title: 'No transactions yet',
                        subtitle: 'Tap "Add Spending" to record your first transaction',
                      )
                    else
                      ...catTxs.map((tx) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _TransactionTile(tx: tx, currency: budget.currency),
                          )),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, BudgetCategory cat, {required bool isExpense}) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textMuted, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(isExpense ? '➖' : '➕', style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Text(
                  isExpense ? 'Record Spending' : 'Add Funds',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(cat.name, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '${Provider.of<BudgetProvider>(context, listen: false).currency} ',
                prefixStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 22),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. Woolworths groceries',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isExpense ? AppTheme.danger : AppTheme.accent,
                ),
                onPressed: () {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount > 0) {
                    final adjustment = isExpense ? amount : -amount;
                    Provider.of<BudgetProvider>(context, listen: false)
                        .updateCategorySpent(cat.id, adjustment, note: noteController.text.trim());
                    Navigator.pop(ctx);
                  }
                },
                child: Text(isExpense ? 'Record Spending' : 'Add Funds'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionRecord tx;
  final String currency;

  const _TransactionTile({required this.tx, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isExpense = tx.type == TransactionType.expense;
    final color = isExpense ? AppTheme.danger : AppTheme.accent;

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppTheme.danger, size: 22),
      ),
      confirmDismiss: (_) => showConfirmDialog(
        context,
        title: 'Delete Transaction',
        message: 'Remove this transaction? The amount will be reversed from the category balance.',
        confirmLabel: 'Delete',
      ),
      onDismissed: (_) {
        Provider.of<BudgetProvider>(context, listen: false)
            .deleteTransaction(tx.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      },
      child: GestureDetector(
        onTap: () => _showEditSheet(context),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    isExpense
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: color,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.note.isNotEmpty ? tx.note : (isExpense ? 'Spending' : 'Funds added'),
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat('MMM d, h:mm a').format(tx.date),
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${isExpense ? '-' : '+'}$currency ${tx.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit_outlined,
                  color: AppTheme.textMuted, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    final amountController = TextEditingController(
        text: tx.amount.abs().toStringAsFixed(2));
    final noteController = TextEditingController(text: tx.note);
    final currency =
        Provider.of<BudgetProvider>(context, listen: false).currency;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface2,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.textMuted,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Text('✏️', style: TextStyle(fontSize: 22)),
                SizedBox(width: 10),
                Text('Edit Transaction',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 6),
            Text(tx.categoryName,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '$currency ',
                prefixStyle: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 22),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. Woolworths groceries',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Delete button
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    final confirm = await showConfirmDialog(
                      context,
                      title: 'Delete Transaction',
                      message:
                          'Remove this transaction? The amount will be reversed from the category balance.',
                      confirmLabel: 'Delete',
                    );
                    if (confirm == true && context.mounted) {
                      Provider.of<BudgetProvider>(context, listen: false)
                          .deleteTransaction(tx.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Transaction deleted')),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.danger.withOpacity(0.25)),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppTheme.danger, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                // Save button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final newAmount =
                          double.tryParse(amountController.text) ?? 0;
                      if (newAmount > 0) {
                        // Preserve sign: expenses stay positive, adjustments negative
                        final signed = tx.amount < 0 ? -newAmount : newAmount;
                        Provider.of<BudgetProvider>(context, listen: false)
                            .editTransaction(
                                tx.id, signed, noteController.text.trim());
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('✅ Transaction updated')),
                        );
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
