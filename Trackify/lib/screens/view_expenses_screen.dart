import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/expense_service.dart';
import '../models/expense.dart';

class ViewExpensesScreen extends StatelessWidget {
  const ViewExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF12121A) : const Color(0xFFF5F6FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('All Expenses',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ExpenseService>(
        builder: (context, service, _) {
          final expenses = service.expenses;
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 90, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text('No expenses yet',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Add your first expense to get started!',
                      style:
                          TextStyle(color: Colors.grey[400], fontSize: 14)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return _ExpenseTile(
                expense: expense,
                onDelete: () => _confirmDelete(context, service, expense),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, ExpenseService service, Expense expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Expense',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Delete ₹${NumberFormat('#,##,###.##').format(expense.amount)} (${expense.category})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF666666))),
          ),
          TextButton(
            onPressed: () async {
              await service.deleteExpense(expense.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const _ExpenseTile({required this.expense, required this.onDelete});

  static const Map<String, Color> _colors = {
    'Bills': Color(0xFFFF6B6B),
    'Shopping': Color(0xFF4ECDC4),
    'Food': Color(0xFF45B7D1),
    'Transport': Color(0xFF96CEB4),
    'Miscellaneous': Color(0xFFDDA0DD),
  };

  static const Map<String, IconData> _icons = {
    'Bills': Icons.receipt_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Food': Icons.restaurant_outlined,
    'Transport': Icons.directions_car_outlined,
    'Miscellaneous': Icons.category_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final color = _colors[expense.category] ?? Colors.grey;
    final icon = _icons[expense.category] ?? Icons.category_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.category,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(DateFormat('dd MMM yyyy').format(expense.date),
                      style: const TextStyle(
                          color: Color(0xFF999999), fontSize: 12)),
                  if (expense.note != null &&
                      expense.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(expense.note!,
                        style: TextStyle(
                            color: isDark
                                ? Colors.grey[400]
                                : const Color(0xFF777777),
                            fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${NumberFormat('#,##,###.##').format(expense.amount)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.redAccent, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}