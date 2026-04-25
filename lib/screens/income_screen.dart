import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/income.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Income Sources'),
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
                  colors: const [Color(0xFF00A878), Color(0xFF00D4AA)],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Monthly Income', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '${budget.currency} ${budget.totalIncome.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('💵', style: TextStyle(fontSize: 24)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: '${budget.incomes.length} Source${budget.incomes.length != 1 ? 's' : ''}',
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: budget.incomes.isEmpty
                    ? const EmptyState(
                        emoji: '💵',
                        title: 'No income added',
                        subtitle: 'Add your salary, freelance income, or any other source',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: budget.incomes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final income = budget.incomes[index];
                          return GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(child: Text('💰', style: TextStyle(fontSize: 18))),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(income.source, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                                      Text('Monthly', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${budget.currency} ${income.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _showEditIncomeDialog(context, income),
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
                                      title: 'Remove Income',
                                      message: 'Remove "${income.source}" from your income sources?',
                                      confirmLabel: 'Remove',
                                    );
                                    if (confirm == true && context.mounted) {
                                      Provider.of<BudgetProvider>(context, listen: false).deleteIncome(income.id);
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
        onPressed: () => _showAddIncomeDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddIncomeDialog(BuildContext context) {
    _showIncomeDialog(context, null);
  }

  void _showEditIncomeDialog(BuildContext context, Income income) {
    _showIncomeDialog(context, income);
  }

  void _showIncomeDialog(BuildContext context, Income? income) {
    final isEditing = income != null;
    final nameController = TextEditingController(text: isEditing ? income.source : '');
    final amountController = TextEditingController(text: isEditing ? income.amount.toStringAsFixed(2) : '');

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
            Text(
              isEditing ? 'Edit Income Source' : 'Add Income Source',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Source (e.g. Salary, Freelance)'),
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
                              .editIncome(income.id, nameController.text.trim(), amount);
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
                          .addIncome(Income(source: nameController.text.trim(), amount: amount));
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add Income'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
