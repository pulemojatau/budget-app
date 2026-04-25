import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/goal.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  static const List<String> _emojiOptions = [
    '🎯', '🏠', '✈️', '🚗', '💍', '📱', '💻', '🎓', '🏖️', '💰',
    '🏋️', '🎸', '📷', '🌍', '🛍️', '🐕', '👶', '🏥', '⚡', '🎁',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Savings Goals'),
        backgroundColor: AppTheme.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budget, _) {
          final completed = budget.goals.where((g) => g.isCompleted).length;

          return Column(
            children: [
              if (budget.goals.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: GradientCard(
                    colors: const [Color(0xFF8B2FC9), Color(0xFFFF4D8D)],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Active Goals', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              '${budget.goals.length} goal${budget.goals.length != 1 ? 's' : ''}',
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                            ),
                            if (completed > 0)
                              Text('$completed completed 🎉', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                        const Text('🎯', style: TextStyle(fontSize: 40)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(title: 'Your Goals'),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: budget.goals.isEmpty
                    ? EmptyState(
                        emoji: '🎯',
                        title: 'No goals yet',
                        subtitle: 'Set a savings goal like "Save R2000 for a trip" and track your progress',
                        buttonLabel: 'Create Goal',
                        onButton: () => _showAddGoalDialog(context),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: budget.goals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final goal = budget.goals[index];
                          return _GoalCard(goal: goal, currency: budget.currency);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  static void _showAddGoalDialog(BuildContext context) {
    _showGoalDialog(context, null);
  }

  static void _showEditGoalDialog(BuildContext context, SavingsGoal goal) {
    _showGoalDialog(context, goal);
  }

  static void _showGoalDialog(BuildContext context, SavingsGoal? goal) {
    final isEditing = goal != null;
    final nameController = TextEditingController(text: isEditing ? goal.name : '');
    final targetController = TextEditingController(text: isEditing ? goal.targetAmount.toStringAsFixed(2) : '');
    String selectedEmoji = isEditing ? goal.icon : '🎯';

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textMuted, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 20),
                Text(
                  isEditing ? 'Edit Savings Goal' : 'New Savings Goal',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                const Text('Choose Icon', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _emojiOptions.map((e) => GestureDetector(
                    onTap: () => setSheet(() => selectedEmoji = e),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedEmoji == e ? AppTheme.accentPink.withOpacity(0.2) : AppTheme.surface3,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selectedEmoji == e ? AppTheme.accentPink : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Center(child: Text(e, style: const TextStyle(fontSize: 18))),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Goal Name (e.g. Holiday Fund)'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: targetController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Target Amount',
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
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPink),
                          onPressed: () {
                            final target = double.tryParse(targetController.text) ?? 0;
                            if (nameController.text.isNotEmpty && target > 0) {
                              Provider.of<BudgetProvider>(context, listen: false).editGoal(
                                goal.id,
                                name: nameController.text.trim(),
                                targetAmount: target,
                                icon: selectedEmoji,
                              );
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
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPink),
                      onPressed: () {
                        final target = double.tryParse(targetController.text) ?? 0;
                        if (nameController.text.isNotEmpty && target > 0) {
                          Provider.of<BudgetProvider>(context, listen: false).addGoal(
                            SavingsGoal(
                              name: nameController.text.trim(),
                              targetAmount: target,
                              icon: selectedEmoji,
                            ),
                          );
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('Create Goal'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final String currency;

  const _GoalCard({required this.goal, required this.currency});

  @override
  Widget build(BuildContext context) {
    final color = goal.isCompleted ? AppTheme.accent : AppTheme.accentPink;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderColor: goal.isCompleted ? AppTheme.accent.withOpacity(0.3) : null,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(goal.icon, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(goal.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                        if (goal.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('✅ Done', style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$currency ${goal.savedAmount.toStringAsFixed(0)} of $currency ${goal.targetAmount.toStringAsFixed(0)}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '${(goal.progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PremiumProgressBar(value: goal.progress, color: color, height: 7, showGlow: !goal.isCompleted),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!goal.isCompleted) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showAddSavingsDialog(context, goal),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.25)),
                      ),
                      child: Center(
                        child: Text('+ Add Savings', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              GestureDetector(
                onTap: () => GoalsScreen._showEditGoalDialog(context, goal),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  final confirm = await showConfirmDialog(
                    context,
                    title: 'Delete Goal',
                    message: 'Delete "${goal.name}"?',
                    confirmLabel: 'Delete',
                  );
                  if (confirm == true && context.mounted) {
                    Provider.of<BudgetProvider>(context, listen: false).deleteGoal(goal.id);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddSavingsDialog(BuildContext context, SavingsGoal goal) {
    final amountController = TextEditingController();

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
            Text('Add to ${goal.name}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            Text(
              '${(goal.progress * 100).toStringAsFixed(0)}% complete — ${Provider.of<BudgetProvider>(context, listen: false).currency} ${goal.remaining.toStringAsFixed(0)} to go',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText: 'Amount saved',
                prefixText: '${Provider.of<BudgetProvider>(context, listen: false).currency} ',
                prefixStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 22),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentPink),
                onPressed: () {
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (amount > 0) {
                    Provider.of<BudgetProvider>(context, listen: false).updateGoalSaved(goal.id, amount);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Save Progress'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
