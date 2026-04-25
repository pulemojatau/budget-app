import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/budget_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/summary_card.dart';
import '../widgets/app_widgets.dart';
import 'income_screen.dart';
import 'expenses_screen.dart';
import 'categories_screen.dart';
import 'category_detail_screen.dart';
import 'history_screen.dart';
import 'goals_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  PageRoute _route(Widget page) =>
      MaterialPageRoute(builder: (_) => page);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Consumer<BudgetProvider>(
        builder: (context, budget, _) {
          return FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context, budget),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Hero balance card ──────────────────────────────
                      SummaryCard(
                        income: budget.totalIncome,
                        expenses: budget.totalExpenses,
                        allocated: budget.totalAllocated,
                        balance: budget.availableBalance,
                        currency: budget.currency,
                      ),
                      const SizedBox(height: 20),

                      // ── Zero income banner ─────────────────────────────
                      if (budget.totalIncome == 0)
                        _buildNoIncomeBanner(context),

                      // ── Budget health bar ──────────────────────────────
                      if (budget.totalIncome > 0)
                        _buildHealthBar(budget),

                      // ── Setup checklist (shown until fully set up) ─────
                      if (!budget.setupComplete) ...[
                        const SizedBox(height: 20),
                        _buildSetupChecklist(context, budget),
                      ],

                      const SizedBox(height: 20),

                      // ── Quick actions ──────────────────────────────────
                      _buildQuickActions(context),
                      const SizedBox(height: 20),

                      // ── Alerts ─────────────────────────────────────────
                      if (budget.overspentCount > 0) ...[
                        _buildOverspentAlert(budget),
                        const SizedBox(height: 16),
                      ],

                      // ── Insights strip ─────────────────────────────────
                      if (budget.totalSpent > 0) ...[
                        _buildInsightsStrip(budget),
                        const SizedBox(height: 20),
                      ],

                      // ── Pie chart ──────────────────────────────────────
                      if (budget.categories.isNotEmpty) ...[
                        SectionHeader(
                          title: 'Spending Breakdown',
                          actionLabel: 'History',
                          onAction: () => Navigator.push(
                              context, _route(const HistoryScreen())),
                        ),
                        const SizedBox(height: 14),
                        _buildPieChart(budget),
                        const SizedBox(height: 20),
                      ],

                      // ── Goals preview ──────────────────────────────────
                      if (budget.goals.isNotEmpty) ...[
                        SectionHeader(
                          title: 'Savings Goals',
                          actionLabel: 'All Goals',
                          onAction: () => Navigator.push(
                              context, _route(const GoalsScreen())),
                        ),
                        const SizedBox(height: 12),
                        _buildGoalsPreview(budget),
                        const SizedBox(height: 20),
                      ],

                      // ── Categories ─────────────────────────────────────
                      SectionHeader(
                        title: 'Budget Categories',
                        actionLabel: 'Manage',
                        onAction: () => Navigator.push(
                            context, _route(const CategoriesScreen())),
                      ),
                      const SizedBox(height: 12),
                      if (budget.categories.isEmpty)
                        EmptyState(
                          emoji: '📂',
                          title: 'No categories yet',
                          subtitle:
                              'Create budget categories to start tracking your spending',
                          buttonLabel: 'Create Category',
                          onButton: () => Navigator.push(
                              context, _route(const CategoriesScreen())),
                        )
                      else
                        ...budget.categories.map((cat) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CategoryCard(
                                category: cat,
                                currency: budget.currency,
                                onTap: () => Navigator.push(
                                  context,
                                  _route(CategoryDetailScreen(
                                      category: cat)),
                                ),
                              ),
                            )),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, BudgetProvider budget) {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return SliverAppBar(
      backgroundColor: AppTheme.bgDark,
      floating: true,
      pinned: false,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${months[now.month - 1]} ${now.year}',
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500),
          ),
          const Text(
            'BudgetFlow',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.flag_outlined,
              color: AppTheme.textSecondary, size: 22),
          tooltip: 'Goals',
          onPressed: () =>
              Navigator.push(context, _route(const GoalsScreen())),
        ),
        IconButton(
          icon: const Icon(Icons.history_rounded,
              color: AppTheme.textSecondary, size: 22),
          tooltip: 'History',
          onPressed: () =>
              Navigator.push(context, _route(const HistoryScreen())),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined,
              color: AppTheme.textSecondary, size: 22),
          tooltip: 'Settings',
          onPressed: () =>
              Navigator.push(context, _route(const SettingsScreen())),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── No income banner ──────────────────────────────────────────────────────
  Widget _buildNoIncomeBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(context, _route(const IncomeScreen())),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A3E), Color(0xFF2A2060)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.primary.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('💵', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add income to start budgeting',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap here to add your salary or any income source',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.primary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Budget health bar ──────────────────────────────────────────────────────
  Widget _buildHealthBar(BudgetProvider budget) {
    final ratio = budget.allocationRatio;
    final pct = (ratio * 100).toStringAsFixed(0);
    final unallocated = budget.availableBalance;

    Color barColor;
    String statusText;
    if (ratio >= 1.0) {
      barColor = AppTheme.danger;
      statusText = 'Fully allocated — no room left';
    } else if (ratio >= 0.9) {
      barColor = AppTheme.warning;
      statusText = 'Almost full — ${budget.currency} ${unallocated.toStringAsFixed(0)} left to assign';
    } else {
      barColor = AppTheme.accent;
      statusText = '${budget.currency} ${unallocated.toStringAsFixed(0)} unallocated';
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: ratio >= 0.9
          ? (ratio >= 1.0
              ? AppTheme.danger.withOpacity(0.4)
              : AppTheme.warning.withOpacity(0.3))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Budget Allocated',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              Text(
                '$pct%',
                style: TextStyle(
                    color: barColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          PremiumProgressBar(
              value: ratio, color: barColor, height: 7, showGlow: ratio < 0.9),
          const SizedBox(height: 8),
          Text(statusText,
              style: TextStyle(
                  color: ratio >= 0.9
                      ? barColor.withOpacity(0.9)
                      : AppTheme.textMuted,
                  fontSize: 11)),
        ],
      ),
    );
  }

  // ── Setup checklist ────────────────────────────────────────────────────────
  Widget _buildSetupChecklist(BuildContext context, BudgetProvider budget) {
    final steps = [
      _SetupStep(
        done: budget.hasIncome,
        emoji: '💵',
        label: 'Add your income',
        onTap: () =>
            Navigator.push(context, _route(const IncomeScreen())),
      ),
      _SetupStep(
        done: budget.hasExpenses,
        emoji: '🔒',
        label: 'Add fixed expenses',
        onTap: () =>
            Navigator.push(context, _route(const ExpensesScreen())),
      ),
      _SetupStep(
        done: budget.hasCategories,
        emoji: '📂',
        label: 'Create a budget category',
        onTap: () =>
            Navigator.push(context, _route(const CategoriesScreen())),
      ),
    ];

    final doneCount = steps.where((s) => s.done).length;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppTheme.primary.withOpacity(0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Get started',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                '$doneCount / 3 done',
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Complete these steps to start budgeting',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          PremiumProgressBar(
              value: doneCount / 3,
              color: AppTheme.primary,
              height: 4),
          const SizedBox(height: 14),
          ...steps.map((step) => _buildChecklistItem(step)),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(_SetupStep step) {
    return GestureDetector(
      onTap: step.done ? null : step.onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: step.done
                    ? AppTheme.accent.withOpacity(0.15)
                    : AppTheme.surface3,
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.done
                      ? AppTheme.accent
                      : const Color(0xFF2A2A4A),
                ),
              ),
              child: Center(
                child: step.done
                    ? const Icon(Icons.check_rounded,
                        color: AppTheme.accent, size: 14)
                    : Text(step.emoji,
                        style: const TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step.label,
                style: TextStyle(
                  color: step.done
                      ? AppTheme.textMuted
                      : AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  decoration:
                      step.done ? TextDecoration.lineThrough : null,
                  decorationColor: AppTheme.textMuted,
                ),
              ),
            ),
            if (!step.done)
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted, size: 16),
          ],
        ),
      ),
    );
  }

  // ── Quick actions ──────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
          icon: '💵',
          label: 'Income',
          onTap: () =>
              Navigator.push(context, _route(const IncomeScreen()))),
      _QuickAction(
          icon: '🔒',
          label: 'Fixed',
          onTap: () =>
              Navigator.push(context, _route(const ExpensesScreen()))),
      _QuickAction(
          icon: '📂',
          label: 'Budget',
          onTap: () =>
              Navigator.push(context, _route(const CategoriesScreen()))),
      _QuickAction(
          icon: '🎯',
          label: 'Goals',
          onTap: () =>
              Navigator.push(context, _route(const GoalsScreen()))),
    ];

    return Row(
      children: actions
          .map((a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: a.onTap,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        children: [
                          Text(a.icon,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 6),
                          Text(
                            a.label,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  // ── Overspent alert ────────────────────────────────────────────────────────
  Widget _buildOverspentAlert(BudgetProvider budget) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('🚨', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overspending Alert',
                    style: TextStyle(
                        color: AppTheme.danger,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                Text(
                  '${budget.overspentCount} ${budget.overspentCount == 1 ? 'category has' : 'categories have'} exceeded their budget',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Insights strip ─────────────────────────────────────────────────────────
  Widget _buildInsightsStrip(BudgetProvider budget) {
    final top = budget.topSpendingCategory;
    final spentPct = budget.totalAllocated > 0
        ? (budget.totalSpent / budget.totalAllocated * 100)
            .clamp(0.0, 999.0)
            .toStringAsFixed(0)
        : '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'This Month'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatChip(
                label: 'Total Spent',
                value:
                    '${budget.currency} ${budget.totalSpent.toStringAsFixed(0)}',
                color: AppTheme.accentOrange,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatChip(
                label: 'Of Budget Used',
                value: '$spentPct%',
                color: AppTheme.primary,
                icon: Icons.pie_chart_outline_rounded,
              ),
            ),
          ],
        ),
        if (top != null) ...[
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Text(top.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Top spending category',
                          style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                      Text(top.name,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ),
                Text(
                  '${budget.currency} ${top.spentAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Pie chart ──────────────────────────────────────────────────────────────
  // 10 guaranteed-distinct colors cycling for any number of categories
  static const List<Color> _chartColors = [
    Color(0xFF6C63FF), // purple
    Color(0xFF00D4AA), // teal
    Color(0xFFFF6B35), // orange
    Color(0xFFFF4D8D), // pink
    Color(0xFFFFD166), // yellow
    Color(0xFF4FC3F7), // sky blue
    Color(0xFFAB47BC), // violet
    Color(0xFF66BB6A), // green
    Color(0xFFEF5350), // red
    Color(0xFF26C6DA), // cyan
  ];

  // Max slices shown individually — extras are grouped into "Other"
  static const int _maxSlices = 6;

  Widget _buildPieChart(BudgetProvider budget) {
    final allCats = budget.categories;
    final total = budget.totalAllocated;

    // Guard: nothing to show
    if (allCats.isEmpty || total <= 0) return const SizedBox.shrink();

    // Sort by allocated descending so biggest slices come first
    final sorted = [...allCats]
      ..sort((a, b) => b.allocatedAmount.compareTo(a.allocatedAmount));

    // Split into visible + "Other"
    final visible = sorted.take(_maxSlices).toList();
    final overflow = sorted.skip(_maxSlices).toList();
    final otherAmount =
        overflow.fold(0.0, (sum, c) => sum + c.allocatedAmount);
    final hasOther = otherAmount > 0;

    // Build the slice list (visible + optional Other)
    final sliceCount = visible.length + (hasOther ? 1 : 0);

    // Clamp touched index so it never goes out of range
    final safeTouched =
        (_touchedIndex >= 0 && _touchedIndex < sliceCount) ? _touchedIndex : -1;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Donut chart ───────────────────────────────────────────────
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      final idx = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                      // Toggle: tap same slice again to deselect
                      _touchedIndex = (_touchedIndex == idx) ? -1 : idx;
                    });
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 48,
                sections: [
                  // Visible categories
                  ...visible.asMap().entries.map((entry) {
                    final i = entry.key;
                    final cat = entry.value;
                    final isTouched = i == safeTouched;
                    final color = _chartColors[i % _chartColors.length];
                    final pct = (cat.allocatedAmount / total) * 100;

                    return PieChartSectionData(
                      color: color,
                      value: cat.allocatedAmount,
                      title: pct >= 9 ? '${pct.toStringAsFixed(0)}%' : '',
                      radius: isTouched ? 74 : 58,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                              color: Colors.black45,
                              blurRadius: 3,
                              offset: Offset(0, 1))
                        ],
                      ),
                    );
                  }),
                  // "Other" slice if needed
                  if (hasOther)
                    PieChartSectionData(
                      color: const Color(0xFF4A4A6A),
                      value: otherAmount,
                      title: '${((otherAmount / total) * 100).toStringAsFixed(0)}%',
                      radius: safeTouched == visible.length ? 74 : 58,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                        shadows: [
                          Shadow(
                              color: Colors.black45,
                              blurRadius: 3,
                              offset: Offset(0, 1))
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Tapped detail banner ──────────────────────────────────────
          if (safeTouched >= 0) ...[
            const SizedBox(height: 14),
            _buildTouchedBanner(
              safeTouched < visible.length
                  ? _SliceInfo(
                      icon: visible[safeTouched].icon,
                      name: visible[safeTouched].name,
                      allocated: visible[safeTouched].allocatedAmount,
                      spent: visible[safeTouched].spentAmount,
                      color: _chartColors[safeTouched % _chartColors.length],
                      pct: (visible[safeTouched].allocatedAmount / total) * 100,
                    )
                  : _SliceInfo(
                      icon: '📦',
                      name: '${overflow.length} other categories',
                      allocated: otherAmount,
                      spent: overflow.fold(0.0, (s, c) => s + c.spentAmount),
                      color: const Color(0xFF4A4A6A),
                      pct: (otherAmount / total) * 100,
                    ),
              budget.currency,
            ),
          ],

          const SizedBox(height: 16),

          // ── Legend grid — wraps cleanly for any number of categories ──
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...visible.asMap().entries.map((entry) {
                final i = entry.key;
                final cat = entry.value;
                final color = _chartColors[i % _chartColors.length];
                final isTouched = i == safeTouched;

                return GestureDetector(
                  onTap: () =>
                      setState(() => _touchedIndex = isTouched ? -1 : i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isTouched
                          ? color.withOpacity(0.18)
                          : AppTheme.surface3,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isTouched
                            ? color.withOpacity(0.5)
                            : const Color(0xFF2A2A4A),
                        width: isTouched ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${cat.icon} ${cat.name}',
                          style: TextStyle(
                            color: isTouched ? color : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: isTouched
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              // "Other" legend chip
              if (hasOther)
                GestureDetector(
                  onTap: () => setState(() => _touchedIndex =
                      safeTouched == visible.length ? -1 : visible.length),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: safeTouched == visible.length
                          ? const Color(0xFF4A4A6A).withOpacity(0.25)
                          : AppTheme.surface3,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: safeTouched == visible.length
                            ? const Color(0xFF6A6A9A)
                            : const Color(0xFF2A2A4A),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A4A6A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+ ${overflow.length} more',
                          style: TextStyle(
                            color: safeTouched == visible.length
                                ? const Color(0xFF9090C0)
                                : AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTouchedBanner(_SliceInfo info, String currency) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: info.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: info.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(info.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.name,
                  style: TextStyle(
                    color: info.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Spent $currency ${info.spent.toStringAsFixed(0)} of $currency ${info.allocated.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${info.pct.toStringAsFixed(1)}%',
            style: TextStyle(
              color: info.color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ── Goals preview ──────────────────────────────────────────────────────────
  Widget _buildGoalsPreview(BudgetProvider budget) {
    return Column(
      children: budget.goals.take(2).map((goal) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(goal.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(goal.name,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            '${(goal.progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      PremiumProgressBar(
                          value: goal.progress,
                          color: AppTheme.accent,
                          height: 4),
                      const SizedBox(height: 4),
                      Text(
                        '${budget.currency} ${goal.savedAmount.toStringAsFixed(0)} / ${budget.currency} ${goal.targetAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Category card ──────────────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final dynamic category;
  final String currency;
  final VoidCallback onTap;

  const _CategoryCard(
      {required this.category,
      required this.currency,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColors[
        category.colorIndex % AppTheme.categoryColors.length];
    final isOverspent = category.isOverspent as bool;
    final statusColor = isOverspent ? AppTheme.danger : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOverspent
                ? AppTheme.danger.withOpacity(0.35)
                : const Color(0xFF2A2A4A),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Text(category.icon,
                      style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          category.name as String,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isOverspent)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text('Over',
                                  style: TextStyle(
                                      color: AppTheme.danger,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ),
                          Text(
                            '$currency ${(category.remainingBalance as double).abs().toStringAsFixed(0)}',
                            style: TextStyle(
                                color: isOverspent
                                    ? AppTheme.danger
                                    : AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  PremiumProgressBar(
                    value: category.spentPercentage as double,
                    color: statusColor,
                    height: 5,
                    showGlow: !isOverspent,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent $currency ${(category.spentAmount as double).toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11),
                      ),
                      Text(
                        'of $currency ${(category.allocatedAmount as double).toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────
class _QuickAction {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});
}

class _SetupStep {
  final bool done;
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _SetupStep(
      {required this.done,
      required this.emoji,
      required this.label,
      required this.onTap});
}

// Data holder for a pie slice detail banner
class _SliceInfo {
  final String icon;
  final String name;
  final double allocated;
  final double spent;
  final Color color;
  final double pct;
  const _SliceInfo({
    required this.icon,
    required this.name,
    required this.allocated,
    required this.spent,
    required this.color,
    required this.pct,
  });
}
