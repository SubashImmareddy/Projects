import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BudgetService extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _salaryKey = 'salary';
  static const _savingsKey = 'savingsPct';

  double _salary = 0.0;
  double _savingsPercent = 20.0;

  double get salary => _salary;
  double get savingsPercent => _savingsPercent;

  double get savingsAmount => _salary * (_savingsPercent / 100);
  double get spendableAmount => _salary - savingsAmount;

  double remainingBudget(double totalSpent) {
    return spendableAmount - totalSpent;
  }

  double savingsProgress(double totalSpent) {
    if (_salary <= 0) return 0;
    return (savingsAmount / _salary).clamp(0.0, 1.0);
  }

  void loadBudget() {
    final box = Hive.box(_boxName);
    _salary = box.get(_salaryKey, defaultValue: 0.0);
    _savingsPercent = box.get(_savingsKey, defaultValue: 20.0);
    notifyListeners();
  }

  Future<void> setSalary(double salary) async {
    _salary = salary;
    final box = Hive.box(_boxName);
    await box.put(_salaryKey, salary);
    notifyListeners();
  }

  Future<void> setSavingsPercent(double percent) async {
    _savingsPercent = percent;
    final box = Hive.box(_boxName);
    await box.put(_savingsKey, percent);
    notifyListeners();
  }
}