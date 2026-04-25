import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../models/income.dart';
import '../models/expense.dart';
import '../models/category.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Step 1 – Income
  final _incomeSourceController = TextEditingController();
  final _incomeAmountController = TextEditingController();
  String _selectedCurrency = 'R';

  // Step 2 – Fixed Expenses (optional)
  final _expenseNameController = TextEditingController();
  final _expenseAmountController = TextEditingController();

  // Step 3 – First Category
  final _catNameController = TextEditingController();
  final _catAmountController = TextEditingController();
  String _catEmoji = '🍔';
  int _catColorIndex = 0;

  static const List<String> _emojiOptions = [
    '🍔', '🛒', '👗', '🎬', '📚', '💊', '✈️', '🚗', '💪', '☕',
    '🎮', '🐾', '🎁', '💰', '📱', '🌱', '🎵', '⚡', '🏠', '🎯',
  ];

  static const List<Map<String, String>> _currencies = [
    {'symbol': 'R', 'label': 'ZAR'},
    {'symbol': '\$', 'label': 'USD'},
    {'symbol': '€', 'label': 'EUR'},
    {'symbol': '£', 'label': 'GBP'},
  ];

  static const List<Map<String, String>> _expenseSuggestions = [
    {'name': 'Rent', 'icon': '🏠'},
    {'name': 'Transport', 'icon': '🚗'},
    {'name': 'WiFi', 'icon': '📶'},
    {'name': 'Gym', 'icon': '💪'},
    {'name': 'Insurance', 'icon': '🛡️'},
    {'name': 'Phone', 'icon': '📱'},
  ];

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
    _pageController.dispose();
    _animController.dispose();
    _incomeSourceController.dispose();
    _incomeAmountController.dispose();
    _expenseNameController.dispose();
    _expenseAmountController.dispose();
    _catNameController.dispose();
    _catAmountController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  Future<void> _finish() async {
    final budget = Provider.of<BudgetProvider>(context, listen: false);

    // Save currency
    budget.setCurrency(_selectedCurrency);

    // Save income (required)
    final incomeAmount = double.tryParse(_incomeAmountController.text) ?? 0;
    if (_incomeSourceController.text.isNotEmpty && incomeAmount > 0) {
      budget.addIncome(Income(
          source: _incomeSourceController.text.trim(), amount: incomeAmount));
    }

    // Save expense (optional)
    final expenseAmount = double.tryParse(_expenseAmountController.text) ?? 0;
    if (_expenseNameController.text.isNotEmpty && expenseAmount > 0) {
      budget.addExpense(Expense(
          name: _expenseNameController.text.trim(), amount: expenseAmount));
    }

    // Save category (optional)
    final catAmount = double.tryParse(_catAmountController.text) ?? 0;
    if (_catNameController.text.isNotEmpty && catAmount > 0) {
      budget.addCategory(BudgetCategory(
        name: _catNameController.text.trim(),
        allocatedAmount: catAmount,
        icon: _catEmoji,
        colorIndex: _catColorIndex,
      ));
    }

    await budget.completeOnboarding();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.accent],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('💜',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'BudgetFlow',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    // Skip
                    if (_currentPage < 2)
                      TextButton(
                        onPressed: _finish,
                        child: const Text('Skip',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 13)),
                      ),
                  ],
                ),
              ),
              // Step indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final active = i == _currentPage;
                    final done = i < _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: done
                            ? AppTheme.accent
                            : active
                                ? AppTheme.primary
                                : AppTheme.textMuted.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                  ],
                ),
              ),
              // Navigation
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: _prevPage,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.surface3,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: const Color(0xFF2A2A4A)),
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: AppTheme.textSecondary),
                          ),
                        ),
                      ),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              _currentPage == 2 ? _finish : _nextPage,
                          child: Text(
                            _currentPage == 0
                                ? 'Continue'
                                : _currentPage == 1
                                    ? 'Continue'
                                    : 'Start Budgeting 🚀',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1: Income ────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💵', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'What\'s your income?',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your main income source to get started. You can add more later.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 28),
          // Currency selector
          const Text('Currency',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: _currencies.map((c) {
              final selected = _selectedCurrency == c['symbol'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCurrency = c['symbol']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary.withOpacity(0.2)
                          : AppTheme.surface3,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary
                            : const Color(0xFF2A2A4A),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          c['symbol']!,
                          style: TextStyle(
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          c['label']!,
                          style: TextStyle(
                            color: selected
                                ? AppTheme.primary.withOpacity(0.7)
                                : AppTheme.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _incomeSourceController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Income source',
              hintText: 'e.g. Salary, Freelance',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _incomeAmountController,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              labelText: 'Monthly amount',
              prefixText: '$_selectedCurrency ',
              prefixStyle: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Step 2: Fixed Expenses ────────────────────────────────────────────────────
  Widget _buildStep2() {
    return StatefulBuilder(
      builder: (context, setLocal) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'Any fixed costs?',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'These are bills that come out every month — rent, transport, subscriptions. This step is optional.',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            // Quick suggestions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _expenseSuggestions
                  .map((s) => GestureDetector(
                        onTap: () => setLocal(
                            () => _expenseNameController.text = s['name']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppTheme.surface3,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF2A2A4A)),
                          ),
                          child: Text(
                            '${s['icon']} ${s['name']}',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _expenseNameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Expense name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _expenseAmountController,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText: 'Monthly amount',
                prefixText: '$_selectedCurrency ',
                prefixStyle: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: const [
                  Text('💡', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can skip this and add fixed expenses later from the dashboard.',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Step 3: First Category ────────────────────────────────────────────────────
  Widget _buildStep3() {
    return StatefulBuilder(
      builder: (context, setLocal) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📂', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'Create your first budget',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Divide your money into categories like Food or Savings. This step is optional.',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            // Emoji picker
            const Text('Icon',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojiOptions
                  .map((e) => GestureDetector(
                        onTap: () => setLocal(() => _catEmoji = e),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _catEmoji == e
                                ? AppTheme.primary.withOpacity(0.2)
                                : AppTheme.surface3,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _catEmoji == e
                                  ? AppTheme.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                              child: Text(e,
                                  style: const TextStyle(fontSize: 18))),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            // Color picker
            const Text('Color',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AppTheme.categoryColors.asMap().entries.map((e) {
                final selected = _catColorIndex == e.key;
                return GestureDetector(
                  onTap: () => setLocal(() => _catColorIndex = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: e.value,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                  color: e.value.withOpacity(0.5),
                                  blurRadius: 6)
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _catNameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                  labelText: 'Category name',
                  hintText: 'e.g. Groceries, Savings'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _catAmountController,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText: 'Budget amount',
                prefixText: '$_selectedCurrency ',
                prefixStyle: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
