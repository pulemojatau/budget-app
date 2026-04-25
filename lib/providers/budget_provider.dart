import 'package:flutter/material.dart';
import '../models/income.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../services/storage_service.dart';

class BudgetProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<Income> _incomes = [];
  List<Expense> _expenses = [];
  List<BudgetCategory> _categories = [];
  List<TransactionRecord> _transactions = [];
  List<SavingsGoal> _goals = [];
  String _currency = 'R';
  bool _onboardingComplete = false;

  List<Income> get incomes => List.unmodifiable(_incomes);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<BudgetCategory> get categories => List.unmodifiable(_categories);
  List<TransactionRecord> get transactions => List.unmodifiable(_transactions);
  List<SavingsGoal> get goals => List.unmodifiable(_goals);
  String get currency => _currency;
  bool get onboardingComplete => _onboardingComplete;

  // ── Computed values ───────────────────────────────────────────────────────────
  double get totalIncome => _incomes.fold(0.0, (sum, i) => sum + i.amount);
  double get totalExpenses => _expenses.fold(0.0, (sum, e) => sum + e.amount);
  double get totalAllocated => _categories.fold(0.0, (sum, c) => sum + c.allocatedAmount);
  double get totalSpent => _categories.fold(0.0, (sum, c) => sum + c.spentAmount);
  double get availableBalance => totalIncome - totalExpenses - totalAllocated;
  double get controllableMoney => totalIncome - totalExpenses;

  /// 0.0–1.0 how much of controllable money is allocated
  double get allocationRatio =>
      controllableMoney > 0 ? (totalAllocated / controllableMoney).clamp(0.0, 1.0) : 0.0;

  int get overspentCount => _categories.where((c) => c.isOverspent).length;

  /// Top spending category by spentAmount (null if no transactions)
  BudgetCategory? get topSpendingCategory {
    if (_categories.isEmpty) return null;
    final sorted = [..._categories]..sort((a, b) => b.spentAmount.compareTo(a.spentAmount));
    return sorted.first.spentAmount > 0 ? sorted.first : null;
  }

  /// Onboarding checklist state
  bool get hasIncome => _incomes.isNotEmpty;
  bool get hasExpenses => _expenses.isNotEmpty;
  bool get hasCategories => _categories.isNotEmpty;
  bool get setupComplete => hasIncome && hasCategories;

  // ── Load ──────────────────────────────────────────────────────────────────────
  Future<void> loadData() async {
    _incomes = await _storageService.loadIncomes();
    _expenses = await _storageService.loadExpenses();
    _categories = await _storageService.loadCategories();
    _transactions = await _storageService.loadTransactions();
    _goals = await _storageService.loadGoals();
    _currency = await _storageService.loadCurrency();
    _onboardingComplete = await _storageService.isOnboardingComplete();
    notifyListeners();
  }

  // ── Onboarding ────────────────────────────────────────────────────────────────
  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    await _storageService.setOnboardingComplete();
    notifyListeners();
  }

  // ── Currency ──────────────────────────────────────────────────────────────────
  void setCurrency(String symbol) {
    _currency = symbol;
    _storageService.saveCurrency(symbol);
    notifyListeners();
  }

  // ── Income ────────────────────────────────────────────────────────────────────
  void addIncome(Income income) {
    _incomes = [..._incomes, income];
    _storageService.saveIncomes(_incomes);
    notifyListeners();
  }

  void editIncome(String id, String newSource, double newAmount) {
    final index = _incomes.indexWhere((i) => i.id == id);
    if (index == -1) return;
    final updated = List<Income>.from(_incomes);
    updated[index] = Income(id: id, source: newSource, amount: newAmount);
    _incomes = updated;
    _storageService.saveIncomes(_incomes);
    notifyListeners();
  }

  void deleteIncome(String id) {
    _incomes = _incomes.where((i) => i.id != id).toList();
    _storageService.saveIncomes(_incomes);
    notifyListeners();
  }

  // ── Expenses ──────────────────────────────────────────────────────────────────
  void addExpense(Expense expense) {
    _expenses = [..._expenses, expense];
    _storageService.saveExpenses(_expenses);
    notifyListeners();
  }

  void editExpense(String id, String newName, double newAmount) {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final updated = List<Expense>.from(_expenses);
    updated[index] = Expense(id: id, name: newName, amount: newAmount);
    _expenses = updated;
    _storageService.saveExpenses(_expenses);
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses = _expenses.where((e) => e.id != id).toList();
    _storageService.saveExpenses(_expenses);
    notifyListeners();
  }

  // ── Categories ────────────────────────────────────────────────────────────────
  bool addCategory(BudgetCategory category) {
    if (category.allocatedAmount > (availableBalance + 0.01)) return false;
    _categories = [..._categories, category];
    _storageService.saveCategories(_categories);
    notifyListeners();
    return true;
  }

  /// Edit a category. If the allocated amount changes, validates against available balance.
  bool editCategory(String id, {
    required String name,
    required double allocatedAmount,
    required String icon,
    required int colorIndex,
  }) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return false;
    final old = _categories[index];
    // Available balance + old allocation = headroom for new allocation
    final headroom = availableBalance + old.allocatedAmount;
    if (allocatedAmount > headroom + 0.01) return false;
    final updated = List<BudgetCategory>.from(_categories);
    updated[index] = old.copyWith(
      name: name,
      allocatedAmount: allocatedAmount,
      icon: icon,
      colorIndex: colorIndex,
    );
    _categories = updated;
    
    // Update all transactions that reference this category to reflect new name/icon
    if (name != old.name || icon != old.icon) {
      final updatedTxs = _transactions.map((tx) {
        if (tx.categoryId == id) {
          return TransactionRecord(
            id: tx.id,
            categoryId: tx.categoryId,
            categoryName: name,
            categoryIcon: icon,
            amount: tx.amount,
            date: tx.date,
            note: tx.note,
            type: tx.type,
          );
        }
        return tx;
      }).toList();
      _transactions = updatedTxs;
      _storageService.saveTransactions(_transactions);
    }
    
    _storageService.saveCategories(_categories);
    notifyListeners();
    return true;
  }

  void deleteCategory(String id) {
    _categories = _categories.where((c) => c.id != id).toList();
    _transactions = _transactions.where((t) => t.categoryId != id).toList();
    _storageService.saveCategories(_categories);
    _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  void updateCategorySpent(String id, double amount, {String note = ''}) {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final category = _categories[index];
    final updated = List<BudgetCategory>.from(_categories);
    updated[index] = category.copyWith(spentAmount: category.spentAmount + amount);
    _categories = updated;

    final transaction = TransactionRecord(
      categoryId: id,
      categoryName: category.name,
      categoryIcon: category.icon,
      amount: amount,
      date: DateTime.now(),
      note: note,
      type: amount > 0 ? TransactionType.expense : TransactionType.adjustment,
    );
    _transactions = [transaction, ..._transactions];

    _storageService.saveCategories(_categories);
    _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  /// Edit an existing transaction — reverses the old amount, applies the new one.
  void editTransaction(String txId, double newAmount, String newNote) {
    final txIndex = _transactions.indexWhere((t) => t.id == txId);
    if (txIndex == -1) return;

    final tx = _transactions[txIndex];
    final catIndex = _categories.indexWhere((c) => c.id == tx.categoryId);

    // Reverse old amount from category, apply new amount
    if (catIndex != -1) {
      final cat = _categories[catIndex];
      final updatedCats = List<BudgetCategory>.from(_categories);
      // Remove old, add new
      final correctedSpent = cat.spentAmount - tx.amount + newAmount;
      updatedCats[catIndex] = cat.copyWith(spentAmount: correctedSpent);
      _categories = updatedCats;
    }

    // Replace transaction record with updated values
    final updatedTxs = List<TransactionRecord>.from(_transactions);
    updatedTxs[txIndex] = TransactionRecord(
      id: tx.id,
      categoryId: tx.categoryId,
      categoryName: tx.categoryName,
      categoryIcon: tx.categoryIcon,
      amount: newAmount,
      date: tx.date,
      note: newNote,
      type: newAmount > 0 ? TransactionType.expense : TransactionType.adjustment,
    );
    _transactions = updatedTxs;

    _storageService.saveCategories(_categories);
    _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  /// Delete a single transaction and reverse its effect on the category balance.
  void deleteTransaction(String txId) {
    final txIndex = _transactions.indexWhere((t) => t.id == txId);
    if (txIndex == -1) return;

    final tx = _transactions[txIndex];
    final catIndex = _categories.indexWhere((c) => c.id == tx.categoryId);

    // Reverse the amount from the category
    if (catIndex != -1) {
      final cat = _categories[catIndex];
      final updatedCats = List<BudgetCategory>.from(_categories);
      updatedCats[catIndex] = cat.copyWith(spentAmount: cat.spentAmount - tx.amount);
      _categories = updatedCats;
    }

    _transactions = _transactions.where((t) => t.id != txId).toList();

    _storageService.saveCategories(_categories);
    _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  // ── Goals ─────────────────────────────────────────────────────────────────────
  void addGoal(SavingsGoal goal) {
    _goals = [..._goals, goal];
    _storageService.saveGoals(_goals);
    notifyListeners();
  }

  void updateGoalSaved(String id, double amount) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;
    final goal = _goals[index];
    final updated = List<SavingsGoal>.from(_goals);
    updated[index] = goal.copyWith(
      savedAmount: (goal.savedAmount + amount).clamp(0.0, goal.targetAmount),
    );
    _goals = updated;
    _storageService.saveGoals(_goals);
    notifyListeners();
  }

  void editGoal(String id, {
    required String name,
    required double targetAmount,
    required String icon,
    DateTime? targetDate,
  }) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;
    final goal = _goals[index];
    final updated = List<SavingsGoal>.from(_goals);
    // If new target is less than saved amount, clamp saved amount to new target
    final adjustedSavedAmount = goal.savedAmount > targetAmount ? targetAmount : goal.savedAmount;
    updated[index] = goal.copyWith(
      name: name,
      targetAmount: targetAmount,
      savedAmount: adjustedSavedAmount,
      icon: icon,
      targetDate: targetDate,
    );
    _goals = updated;
    _storageService.saveGoals(_goals);
    notifyListeners();
  }

  void deleteGoal(String id) {
    _goals = _goals.where((g) => g.id != id).toList();
    _storageService.saveGoals(_goals);
    notifyListeners();
  }

  // ── Reset / Clear ─────────────────────────────────────────────────────────────
  void resetMonthlyData() {
    _categories = _categories.map((c) => c.copyWith(spentAmount: 0.0)).toList();
    _transactions = [];
    _storageService.saveCategories(_categories);
    _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  void clearAllData() {
    _incomes = [];
    _expenses = [];
    _categories = [];
    _transactions = [];
    _goals = [];
    _storageService.clearAll();
    notifyListeners();
  }
}
