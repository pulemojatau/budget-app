import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  String _filter = 'All'; // All, Spending, Adjustments

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: AppTheme.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budget, _) {
          var txs = budget.transactions;

          // Filter
          if (_filter == 'Spending') {
            txs = txs.where((t) => t.type == TransactionType.expense).toList();
          } else if (_filter == 'Adjustments') {
            txs = txs.where((t) => t.type == TransactionType.adjustment).toList();
          }

          // Search
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            txs = txs.where((t) =>
              t.categoryName.toLowerCase().contains(q) ||
              t.note.toLowerCase().contains(q)
            ).toList();
          }

          // Group by date
          final grouped = <String, List<TransactionRecord>>{};
          for (final tx in txs) {
            final key = _dateKey(tx.date);
            grouped.putIfAbsent(key, () => []).add(tx);
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: TextField(
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(height: 12),
              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: ['All', 'Spending', 'Adjustments'].map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _filter == f ? AppTheme.primary : AppTheme.surface3,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _filter == f ? AppTheme.primary : const Color(0xFF2A2A4A),
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            color: _filter == f ? Colors.white : AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Summary row
              if (budget.transactions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      StatChip(
                        label: 'Total Spent',
                        value: '${budget.currency} ${budget.totalSpent.toStringAsFixed(0)}',
                        color: AppTheme.danger,
                        icon: Icons.arrow_upward_rounded,
                      ),
                      const SizedBox(width: 10),
                      StatChip(
                        label: 'Transactions',
                        value: '${budget.transactions.length}',
                        color: AppTheme.primary,
                        icon: Icons.receipt_long_rounded,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: txs.isEmpty
                    ? EmptyState(
                        emoji: '📋',
                        title: _searchQuery.isNotEmpty ? 'No results' : 'No transactions yet',
                        subtitle: _searchQuery.isNotEmpty
                            ? 'Try a different search term'
                            : 'Your spending history will appear here',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: grouped.length,
                        itemBuilder: (context, i) {
                          final dateKey = grouped.keys.elementAt(i);
                          final dayTxs = grouped[dateKey]!;
                          final dayTotal = dayTxs
                              .where((t) => t.type == TransactionType.expense)
                              .fold(0.0, (sum, t) => sum + t.amount);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10, top: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(dateKey, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                    if (dayTotal > 0)
                                      Text(
                                        '-${budget.currency} ${dayTotal.toStringAsFixed(0)}',
                                        style: const TextStyle(color: AppTheme.danger, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                  ],
                                ),
                              ),
                              ...dayTxs.map((tx) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _TxTile(tx: tx, currency: budget.currency),
                                  )),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _dateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(date);
  }
}

class _TxTile extends StatelessWidget {
  final TransactionRecord tx;
  final String currency;

  const _TxTile({required this.tx, required this.currency});

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
        message:
            'Remove this transaction? The amount will be reversed from the category balance.',
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                    child: Text(tx.categoryIcon,
                        style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.categoryName,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                    Text(
                      tx.note.isNotEmpty
                          ? tx.note
                          : DateFormat('h:mm a').format(tx.date),
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isExpense ? '-' : '+'}$currency ${tx.amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                  Text(
                    DateFormat('h:mm a').format(tx.date),
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(Icons.edit_outlined,
                  color: AppTheme.textMuted, size: 13),
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
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final newAmount =
                          double.tryParse(amountController.text) ?? 0;
                      if (newAmount > 0) {
                        final signed =
                            tx.amount < 0 ? -newAmount : newAmount;
                        Provider.of<BudgetProvider>(context, listen: false)
                            .editTransaction(tx.id, signed,
                                noteController.text.trim());
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
