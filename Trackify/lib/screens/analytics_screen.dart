import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/expense_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        title: const Text('Analytics',
            style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Monthly Trend'),
            Tab(text: 'Day-wise'),
          ],
        ),
      ),
      body: Consumer<ExpenseService>(
        builder: (context, service, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _MonthlyChart(service: service),
              _DailyChart(service: service),
            ],
          );
        },
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  final ExpenseService service;
  const _MonthlyChart({required this.service});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final List<Map<String, dynamic>> monthData = [];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final total = service.getTotalForMonth(month);
      monthData.add({'label': DateFormat('MMM').format(month), 'total': total});
    }
    final maxY = monthData
            .map((e) => e['total'] as double)
            .reduce((a, b) => a > b ? a : b) *
        1.3;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Last 6 Months Spending',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Monthly expense trend',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 24),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY <= 0 ? 1000 : maxY,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF6C63FF),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '₹${NumberFormat('#,##,###').format(rod.toY.round())}',
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= monthData.length)
                                return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(monthData[index]['label'],
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600)),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 52,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '₹${NumberFormat.compact().format(value)}',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600]),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.15),
                            strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: monthData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final total = entry.value['total'] as double;
                        final isCurrentMonth = index == monthData.length - 1;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: total,
                              color: isCurrentMonth
                                  ? const Color(0xFF6C63FF)
                                  : const Color(0xFF6C63FF).withOpacity(0.4),
                              width: 28,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Month Summary',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...monthData.reversed.map((data) {
                  final label = data['label'] as String;
                  final total = data['total'] as double;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(label,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6C63FF))),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 14)),
                          ],
                        ),
                        Text(
                          total > 0
                              ? '₹${NumberFormat('#,##,###.##').format(total)}'
                              : 'No expenses',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: total > 0
                                  ? const Color(0xFF6C63FF)
                                  : Colors.grey[400]),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyChart extends StatelessWidget {
  final ExpenseService service;
  const _DailyChart({required this.service});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final Map<int, double> dailyTotals = {};
    for (final expense in service.getExpensesForMonth(now)) {
      final day = expense.date.day;
      dailyTotals[day] = (dailyTotals[day] ?? 0) + expense.amount;
    }
    final maxY = dailyTotals.values.isEmpty
        ? 1000.0
        : dailyTotals.values.reduce((a, b) => a > b ? a : b) * 1.3;
    final topDays = dailyTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Spending — ${DateFormat('MMMM yyyy').format(now)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text('Tap a bar to see the amount',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 24),
                SizedBox(
                  height: 260,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF45B7D1),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            if (rod.toY == 0) return null;
                            return BarTooltipItem(
                              'Day ${group.x + 1}\n₹${NumberFormat('#,##,###').format(rod.toY.round())}',
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 5,
                            getTitlesWidget: (value, meta) {
                              final day = value.toInt() + 1;
                              if (day % 5 != 0 && day != 1)
                                return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('$day',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600])),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 52,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '₹${NumberFormat.compact().format(value)}',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600]),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.withOpacity(0.15),
                            strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(daysInMonth, (index) {
                        final day = index + 1;
                        final amount = dailyTotals[day] ?? 0.0;
                        final isToday = day == now.day;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: amount,
                              color: isToday
                                  ? const Color(0xFF6C63FF)
                                  : amount > 0
                                      ? const Color(0xFF45B7D1)
                                      : Colors.grey.withOpacity(0.15),
                              width: 7,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Legend(
                        color: const Color(0xFF6C63FF), label: 'Today'),
                    const SizedBox(width: 16),
                    _Legend(
                        color: const Color(0xFF45B7D1),
                        label: 'Has expenses'),
                    const SizedBox(width: 16),
                    _Legend(
                        color: Colors.grey.withOpacity(0.3),
                        label: 'No expenses'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (topDays.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔥 Top Spending Days',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...topDays.take(5).map((entry) {
                    final date =
                        DateTime(now.year, now.month, entry.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF45B7D1)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text('${entry.key}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF45B7D1),
                                          fontSize: 16)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('EEE, dd MMM').format(date),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                          Text(
                            '₹${NumberFormat('#,##,###.##').format(entry.value)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF45B7D1)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }
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
          offset: const Offset(0, 6)),
    ],
  );
}