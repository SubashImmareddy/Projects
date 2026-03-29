import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/expense_service.dart';
import '../services/budget_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _salaryController = TextEditingController();
  final _savingsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final budget = context.read<BudgetService>();
    _salaryController.text =
        budget.salary > 0 ? budget.salary.toStringAsFixed(0) : '';
    _savingsController.text = budget.savingsPercent.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _savingsController.dispose();
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
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer2<ThemeService, BudgetService>(
        builder: (context, themeService, budgetService, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),

              // ── Salary & Budget ──
              _SectionHeader(title: 'Salary & Budget'),
              const SizedBox(height: 10),
              _buildBudgetCard(context, budgetService),
              const SizedBox(height: 20),

              // ── Appearance ──
              _SectionHeader(title: 'Appearance'),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                iconColor: const Color(0xFF6C63FF),
                title: 'Dark Mode',
                subtitle: themeService.isDarkMode ? 'Currently ON' : 'Currently OFF',
                trailing: Switch(
                  value: themeService.isDarkMode,
                  activeColor: const Color(0xFF6C63FF),
                  onChanged: (_) => themeService.toggleTheme(),
                ),
              ),
              const SizedBox(height: 10),
              _buildFontSizeCard(context, themeService),
              const SizedBox(height: 20),

              // ── About ──
              _SectionHeader(title: 'About'),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.info_outline,
                iconColor: const Color(0xFF45B7D1),
                title: 'App Name',
                subtitle: 'Trackify',
              ),
              _SettingsTile(
                icon: Icons.tag,
                iconColor: const Color(0xFF96CEB4),
                title: 'Version',
                subtitle: '1.0.0',
              ),
              _SettingsTile(
                icon: Icons.storage_outlined,
                iconColor: const Color(0xFF4ECDC4),
                title: 'Storage',
                subtitle: 'All data saved locally on your device',
              ),
              const SizedBox(height: 20),

              // ── Data ──
              _SectionHeader(title: 'Data'),
              const SizedBox(height: 10),
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                iconColor: Colors.redAccent,
                title: 'Clear All Expenses',
                subtitle: 'Permanently delete all expense records',
                trailing: TextButton(
                  onPressed: () => _confirmClear(context),
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, BudgetService budget) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C9A7).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.savings_outlined,
                    color: Color(0xFF00C9A7), size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Monthly Salary & Savings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _salaryController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration('Enter monthly salary', '₹'),
            onChanged: (v) async {
              final val = double.tryParse(v);
              if (val != null && val > 0) {
                await budget.setSalary(val);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _savingsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration('Savings percentage (e.g. 20)', '%'),
            onChanged: (v) async {
              final val = double.tryParse(v);
              if (val != null && val >= 0 && val <= 100) {
                await budget.setSavingsPercent(val);
              }
            },
          ),
          if (budget.salary > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Monthly Salary',
                    value: '₹${_fmt(budget.salary)}',
                    color: const Color(0xFF6C63FF),
                  ),
                  _InfoRow(
                    label: 'Save (${budget.savingsPercent.toStringAsFixed(0)}%)',
                    value: '₹${_fmt(budget.savingsAmount)}',
                    color: const Color(0xFF00C9A7),
                  ),
                  _InfoRow(
                    label: 'Can Spend',
                    value: '₹${_fmt(budget.spendableAmount)}',
                    color: const Color(0xFF45B7D1),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFontSizeCard(BuildContext context, ThemeService themeService) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDA0DD).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.text_fields,
                    color: Color(0xFFDDA0DD), size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Font Size',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: ['Small', 'Medium', 'Large'].map((size) {
              final isSelected = themeService.fontSize == size;
              return Expanded(
                child: GestureDetector(
                  onTap: () => themeService.setFontSize(size),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFF6C63FF).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        size,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelected ? Colors.white : const Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    final f = v < 0 ? -v : v;
    return f.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{2})+\d$)'),
          (m) => '${m[1]},',
        );
  }

  InputDecoration _inputDecoration(String hint, String suffix) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      suffixText: suffix,
      filled: true,
      fillColor: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF8F8FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Clear All Data',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'This will permanently delete ALL your expenses. This cannot be undone!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF666666))),
          ),
          TextButton(
            onPressed: () async {
              final service = ctx.read<ExpenseService>();
              for (final expense in service.expenses.toList()) {
                await service.deleteExpense(expense.id);
              }
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: const Text('All expenses cleared!'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            child: const Text('Clear All',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;
  const _InfoRow(
      {required this.label,
      required this.value,
      required this.color,
      this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: trailing,
      ),
    );
  }
}