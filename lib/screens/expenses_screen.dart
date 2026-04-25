import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  static const List<Map<String, String>> _suggestions = [
    {'name': 'Rent', 'icon': '🏠'},
    {'name': 'Transport', 'icon': '🚗'},
    {'name': 'WiFi', 'icon': '📶'},
    {'name': 'Gym', 'icon': '💪'},
    {'name': 'Insurance', 'icon': '🛡️'},
    {'name': 'Phone', 'icon': '📱'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Fixed Expenses'),
        backgroundColor: AppTheme.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budget, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: GradientCard(
                  colors: const [Color(0xFFCC4400), Color(0xFFFF6B35)],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Fixed Costs', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '${budget.currency} ${budget.totalExpenses.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            budget.totalIncome > 0
                                ? '${((budget.totalExpenses / budget.totalIncome) * 100).toStringAsFixed(0)}% of income'
                                : 'Add income first',
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('🔒', style: TextStyle(fontSize: 24)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: '${budget.expenses.length} Fixed Expense${budget.expenses.length != 1 ? 's' : ''}',
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: budget.expenses.isEmpty
                    ? const EmptyState(
                        emoji: '🔒',
                        title: 'No fixed expenses',
                        subtitle: 'Add recurring costs like rent, transport, and subscriptions',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: budget.expenses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final expense = budget.expenses[index];
                          final icon = _suggestions.firstWhere(
                            (s) => s['name']!.toLowerCase() == expense.name.toLowerCase(),
                            orElse: () => {'icon': '💸'},
                          )['icon']!;

                          return GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentOrange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(expense.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                                      const Text('Fixed monthly', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${budget.currency} ${expense.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _showEditExpenseDialog(context, expense),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 16),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final confirm = await showConfirmDialog(
                                      context,
                                      title: 'Remove Expense',
                                      message: 'Remove "${expense.name}" from fixed expenses?',
                                      confirmLabel: 'Remove',
                                    );
                                    if (confirm == true && context.mounted) {
                                      Provider.of<BudgetProvider>(context, listen: false).deleteExpense(expense.id);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.danger.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    _showExpenseDialog(context, null);
  }

  void _showEditExpenseDialog(BuildContext context, Expense expense) {
    _showExpenseDialog(context, expense);
  }

  void _showExpenseDialog(BuildContext context, Expense? expense) {
    final isEditing = expense != null;
    final nameController = TextEditingController(text: isEditing ? expense.name : '');
    final amountController = TextEditingController(text: isEditing ? expense.amount.toStringAsFixed(2) : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
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
              Text(
                isEditing ? 'Edit Fixed Expense' : 'Add Fixed Expense',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              if (!isEditing) ...[
                const SizedBox(height: 12),
                // Quick suggestions
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestions.map((s) => GestureDetector(
                    onTap: () => setSheet(() => nameController.text = s['name']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surface3,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF2A2A4A)),
                      ),
                      child: Text('${s['icon']} ${s['name']}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Expense Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Monthly Amount',
                  prefixText: '${Provider.of<BudgetProvider>(context, listen: false).currency} ',
                  prefixStyle: const TextStyle(color: AppTheme.textPrimary),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 24),
              if (isEditing)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surface3),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle(color: AppTheme.textPrimary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final amount = double.tryParse(amountController.text) ?? 0;
                          if (nameController.text.isNotEmpty && amount > 0) {
                            Provider.of<BudgetProvider>(context, listen: false)
                                .editExpense(expense.id, nameController.text.trim(), amount);
                            Navigator.pop(ctx);
                          }
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(amountController.text) ?? 0;
                      if (nameController.text.isNotEmpty && amount > 0) {
                        Provider.of<BudgetProvider>(context, listen: false)
                            .addExpense(Expense(name: nameController.text.trim(), amount: amount));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Add Expense'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
