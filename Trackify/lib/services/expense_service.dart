import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';

class ExpenseService extends ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);

  void loadExpenses() {
    final box = Hive.box<Expense>('expenses');
    _expenses = box.values.toList();
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    final box = Hive.box<Expense>('expenses');
    await box.put(expense.id, expense);
    _expenses.insert(0, expense);
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    final box = Hive.box<Expense>('expenses');
    await box.delete(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  List<Expense> getExpensesForMonth(DateTime month) {
    return _expenses
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .toList();
  }

  double getTotalForMonth(DateTime month) {
    return getExpensesForMonth(month).fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> getCategoryTotalsForMonth(DateTime month) {
    final monthExpenses = getExpensesForMonth(month);
    final Map<String, double> totals = {};
    for (final expense in monthExpenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }
}