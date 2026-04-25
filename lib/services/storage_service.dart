import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/income.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/goal.dart';

class StorageService {
  static const String _incomeKey = 'incomes';
  static const String _expenseKey = 'expenses';
  static const String _categoryKey = 'categories';
  static const String _transactionKey = 'transactions';
  static const String _goalKey = 'goals';
  static const String _currencyKey = 'currency';
  static const String _onboardingKey = 'onboarding_complete';

  // ── Income ──────────────────────────────────────────────────────────────────
  Future<void> saveIncomes(List<Income> incomes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_incomeKey, jsonEncode(incomes.map((i) => i.toJson()).toList()));
    } catch (_) {}
  }

  Future<List<Income>> loadIncomes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(_incomeKey);
      if (encoded == null || encoded.isEmpty) return [];
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return [];
      return decoded.map((i) => Income.fromJson(i as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Expenses ─────────────────────────────────────────────────────────────────
  Future<void> saveExpenses(List<Expense> expenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_expenseKey, jsonEncode(expenses.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<List<Expense>> loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(_expenseKey);
      if (encoded == null || encoded.isEmpty) return [];
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return [];
      return decoded.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Categories ───────────────────────────────────────────────────────────────
  Future<void> saveCategories(List<BudgetCategory> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_categoryKey, jsonEncode(categories.map((c) => c.toJson()).toList()));
    } catch (_) {}
  }

  Future<List<BudgetCategory>> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(_categoryKey);
      if (encoded == null || encoded.isEmpty) return [];
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return [];
      return decoded.map((c) => BudgetCategory.fromJson(c as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Transactions ─────────────────────────────────────────────────────────────
  Future<void> saveTransactions(List<TransactionRecord> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_transactionKey, jsonEncode(transactions.map((t) => t.toJson()).toList()));
    } catch (_) {}
  }

  Future<List<TransactionRecord>> loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(_transactionKey);
      if (encoded == null || encoded.isEmpty) return [];
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return [];
      return decoded.map((t) => TransactionRecord.fromJson(t as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Goals ────────────────────────────────────────────────────────────────────
  Future<void> saveGoals(List<SavingsGoal> goals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_goalKey, jsonEncode(goals.map((g) => g.toJson()).toList()));
    } catch (_) {}
  }

  Future<List<SavingsGoal>> loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(_goalKey);
      if (encoded == null || encoded.isEmpty) return [];
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return [];
      return decoded.map((g) => SavingsGoal.fromJson(g as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Currency ─────────────────────────────────────────────────────────────────
  Future<void> saveCurrency(String symbol) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, symbol);
    } catch (_) {}
  }

  Future<String> loadCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_currencyKey) ?? 'R';
    } catch (_) {
      return 'R';
    }
  }

  // ── Onboarding ───────────────────────────────────────────────────────────────
  Future<void> setOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (_) {}
  }

  Future<bool> isOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  // ── Clear ────────────────────────────────────────────────────────────────────
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Preserve onboarding flag so user doesn't see it again after clearing data
      await prefs.remove(_incomeKey);
      await prefs.remove(_expenseKey);
      await prefs.remove(_categoryKey);
      await prefs.remove(_transactionKey);
      await prefs.remove(_goalKey);
      // Keep currency preference
    } catch (_) {}
  }
}
