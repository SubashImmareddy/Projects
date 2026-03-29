import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/expense_service.dart';
import '../services/budget_service.dart';
import '../widgets/category_progress_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _touchedIndex = -1;

  static const Map<String, Color> categoryColors = {
    'Bills': Color(0xFFFF6B6B),
    'Shopping': Color(0xFF4ECDC4),
    'Food': Color(0xFF45B7D1),
    'Transport': Color(0xFF96CEB4),
    'Miscellaneous': Color(0xFFDDA0DD),
  };

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy').format(now);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF12121A) : const Color(0xFFF5F6FA);

    return Consumer2<ExpenseService, BudgetService>(
      builder: (context, service, budget, _) {
        final total = service.getTotalForMonth(now);
        final monthExpenses = service.getExpensesForMonth(now);
        final categoryTotals = service.getCategoryTotalsForMonth(now);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Trackify',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  monthLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : const Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 14),

                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Spent',
                        value: '₹${NumberFormat('#,##,###.##').format(total)}',
                        icon: Icons.account_balance_wallet_outlined,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Records',
                        value: '${monthExpenses.length}',
                        icon: Icons.receipt_long_outlined,
                        color: const Color(0xFF00C9A7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Budget Cards
                if (budget.salary > 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Can Spend',
                          value: '₹${NumberFormat('#,##,###.##').format(budget.spendableAmount)}',
                          icon: Icons.payments_outlined,
                          color: const Color(0xFF45B7D1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Remaining',
                          value: '₹${NumberFormat('#,##,###.##').format(budget.remainingBudget(total))}',
                          icon: Icons.savings_outlined,
                          color: budget.remainingBudget(total) >= 0
                              ? const Color(0xFF96CEB4)
                              : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBudgetCard(budget, total),
                  const SizedBox(height: 12),
                ],

                if (categoryTotals.isNotEmpty) ...[
                  _buildChartCard(categoryTotals, total),
                  const SizedBox(height: 16),
                  _buildBreakdownCard(categoryTotals, total),
                ] else
                  _buildEmptyState(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBudgetCard(BudgetService budget, double totalSpent) {
    final spendProgress = budget.spendableAmount > 0
        ? (totalSpent / budget.spendableAmount).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = totalSpent > budget.spendableAmount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '💰 Budget Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOverBudget ? '⚠ Over Budget' : '✓ On Track',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isOverBudget ? Colors.redAccent : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BudgetRow(
            label: 'Monthly Salary',
            amount: budget.salary,
            color: const Color(0xFF6C63FF),
          ),
          _BudgetRow(
            label: 'Savings Reserve (${budget.savingsPercent.toStringAsFixed(0)}%)',
            amount: budget.savingsAmount,
            color: const Color(0xFF00C9A7),
          ),
          _BudgetRow(
            label: 'Spendable Budget',
            amount: budget.spendableAmount,
            color: const Color(0xFF45B7D1),
          ),
          _BudgetRow(
            label: 'Already Spent',
            amount: totalSpent,
            color: isOverBudget ? Colors.redAccent : const Color(0xFFFF6B6B),
          ),
          _BudgetRow(
            label: 'Remaining',
            amount: budget.remainingBudget(totalSpent),
            color: isOverBudget ? Colors.redAccent : const Color(0xFF96CEB4),
            isBold: true,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: spendProgress,
              minHeight: 10,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.redAccent : const Color(0xFF6C63FF),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(spendProgress * 100).toStringAsFixed(1)}% of spendable budget used',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(Map<String, double> categoryTotals, double total) {
    final entries = categoryTotals.entries.toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Distribution',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 210,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, PieTouchResponse? resp) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                resp == null ||
                                resp.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = resp.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sections: entries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value.key;
                        final amount = entry.value.value;
                        final pct = total > 0 ? (amount / total * 100) : 0.0;
                        final isTouched = index == _touchedIndex;
                        return PieChartSectionData(
                          color: categoryColors[category] ?? Colors.grey,
                          value: amount,
                          title: '${pct.toStringAsFixed(0)}%',
                          radius: isTouched ? 78 : 62,
                          titleStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 3,
                      centerSpaceRadius: 38,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: categoryColors[e.key] ?? Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            e.key,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF555555),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(Map<String, double> categoryTotals, double total) {
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...sorted.map(
            (entry) => CategoryProgressBar(
              category: entry.key,
              amount: entry.value,
              total: total,
              color: categoryColors[entry.key] ?? Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: _cardDecoration(context),
      child: Column(
        children: [
          Icon(Icons.pie_chart_outline_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No expenses this month',
            style: TextStyle(
                color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap Add to record your first expense',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isBold;

  const _BudgetRow({
    required this.label,
    required this.amount,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold ? null : Colors.grey[600],
                ),
              ),
            ],
          ),
          Text(
            '₹${NumberFormat('#,##,###.##').format(amount.abs())}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}