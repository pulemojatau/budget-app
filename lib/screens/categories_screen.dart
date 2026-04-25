import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const List<String> _emojiOptions = [
    '🍔', '🛒', '👗', '🎬', '📚', '💊', '✈️', '🏠', '🚗', '💪',
    '🎮', '☕', '🐾', '🎁', '💰', '📱', '🌱', '🎵', '🏥', '⚡',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Budget Allocation'),
        backgroundColor: AppTheme.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budget, _) {
          final controllable = budget.controllableMoney;
          final allocated = budget.totalAllocated;
          final pct = controllable > 0 ? (allocated / controllable).clamp(0.0, 1.0) : 0.0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Available to Allocate',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${budget.currency} ${budget.availableBalance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: budget.availableBalance < 0 ? AppTheme.danger : AppTheme.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          StatChip(
                            label: 'Allocated',
                            value: '${(pct * 100).toStringAsFixed(0)}%',
                            color: pct >= 1.0 ? AppTheme.danger : AppTheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      PremiumProgressBar(
                        value: pct,
                        color: pct >= 1.0 ? AppTheme.danger : AppTheme.primary,
                        height: 7,
                        showGlow: pct < 1.0,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${budget.currency} ${allocated.toStringAsFixed(0)} allocated',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${budget.currency} ${controllable.toStringAsFixed(0)} total',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: '${budget.categories.length} Categor${budget.categories.length != 1 ? 'ies' : 'y'}',
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: budget.categories.isEmpty
                    ? const EmptyState(
                        emoji: '📂',
                        title: 'No categories yet',
                        subtitle: 'Create categories like Food, Savings, or Entertainment to allocate your budget',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: budget.categories.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final cat = budget.categories[index];
                          final color = AppTheme.categoryColors[cat.colorIndex % AppTheme.categoryColors.length];

                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CategoryDetailScreen(category: cat)),
                            ),
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 20))),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cat.name,
                                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 4),
                                        PremiumProgressBar(value: cat.spentPercentage, color: cat.isOverspent ? AppTheme.danger : color, height: 4),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${budget.currency} ${cat.spentAmount.toStringAsFixed(0)} / ${budget.currency} ${cat.allocatedAmount.toStringAsFixed(0)}',
                                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _showEditCategoryDialog(context, cat),
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
                                        title: 'Delete Category',
                                        message: 'Delete "${cat.name}"? All transactions for this category will also be removed.',
                                        confirmLabel: 'Delete',
                                      );
                                      if (confirm == true && context.mounted) {
                                        Provider.of<BudgetProvider>(context, listen: false).deleteCategory(cat.id);
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
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    _showCategoryDialog(context, null);
  }

  void _showEditCategoryDialog(BuildContext context, BudgetCategory category) {
    _showCategoryDialog(context, category);
  }

  void _showCategoryDialog(BuildContext context, BudgetCategory? category) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: isEditing ? category.name : '');
    final valueController = TextEditingController(text: isEditing ? category.allocatedAmount.toStringAsFixed(2) : '');
    bool isPercentage = false;
    String selectedEmoji = isEditing ? category.icon : '💰';
    int selectedColorIndex = isEditing ? category.colorIndex : 0;

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
                  isEditing ? 'Edit Budget Category' : 'New Budget Category',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                // Emoji picker
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
                        color: selectedEmoji == e ? AppTheme.primary.withOpacity(0.2) : AppTheme.surface3,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selectedEmoji == e ? AppTheme.primary : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Center(child: Text(e, style: const TextStyle(fontSize: 18))),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                // Color picker
                const Text('Color', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: AppTheme.categoryColors.asMap().entries.map((e) => GestureDetector(
                    onTap: () => setSheet(() => selectedColorIndex = e.key),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: e.value,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColorIndex == e.key ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Category Name (e.g. Groceries)'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                // Amount input + type toggle
                const Text('Allocation Type', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                // Segmented toggle: Amount | Percentage
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheet(() => isPercentage = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isPercentage ? AppTheme.primary : AppTheme.surface3,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                            border: Border.all(
                              color: !isPercentage ? AppTheme.primary : const Color(0xFF2A2A4A),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Fixed Amount',
                              style: TextStyle(
                                color: !isPercentage ? Colors.white : AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheet(() => isPercentage = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isPercentage ? AppTheme.primary : AppTheme.surface3,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                            border: Border.all(
                              color: isPercentage ? AppTheme.primary : const Color(0xFF2A2A4A),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '% of Income',
                              style: TextStyle(
                                color: isPercentage ? Colors.white : AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: isPercentage ? 'Enter percentage (e.g. 20)' : 'Enter amount',
                    suffixText: isPercentage ? '%' : Provider.of<BudgetProvider>(context, listen: false).currency,
                    suffixStyle: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
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
                            final budget = Provider.of<BudgetProvider>(context, listen: false);
                            double amount = double.tryParse(valueController.text) ?? 0;
                            if (isPercentage) {
                              amount = (amount / 100) * budget.controllableMoney;
                            }
                            if (nameController.text.isNotEmpty && amount > 0) {
                              final success = budget.editCategory(
                                category.id,
                                name: nameController.text.trim(),
                                allocatedAmount: amount,
                                icon: selectedEmoji,
                                colorIndex: selectedColorIndex,
                              );
                              if (success) {
                                Navigator.pop(ctx);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('⚠️ Not enough available balance!')),
                                );
                              }
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
                        final budget = Provider.of<BudgetProvider>(context, listen: false);
                        double amount = double.tryParse(valueController.text) ?? 0;
                        if (isPercentage) {
                          amount = (amount / 100) * budget.controllableMoney;
                        }
                        if (nameController.text.isNotEmpty && amount > 0) {
                          final success = budget.addCategory(BudgetCategory(
                            name: nameController.text.trim(),
                            allocatedAmount: amount,
                            icon: selectedEmoji,
                            colorIndex: selectedColorIndex,
                          ));
                          if (success) {
                            Navigator.pop(ctx);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('⚠️ Not enough available balance!')),
                            );
                          }
                        }
                      },
                      child: const Text('Create Category'),
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
