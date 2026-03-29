import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  static const List<String> _categories = [
    'Bills', 'Shopping', 'Food', 'Transport', 'Miscellaneous',
  ];

  static const Map<String, IconData> _categoryIcons = {
    'Bills': Icons.receipt_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Food': Icons.restaurant_outlined,
    'Transport': Icons.directions_car_outlined,
    'Miscellaneous': Icons.category_outlined,
  };

  static const Map<String, Color> _categoryColors = {
    'Bills': Color(0xFFFF6B6B),
    'Shopping': Color(0xFF4ECDC4),
    'Food': Color(0xFF45B7D1),
    'Transport': Color(0xFF96CEB4),
    'Miscellaneous': Color(0xFFDDA0DD),
  };

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6C63FF),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.parse(_amountController.text.trim()),
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    await context.read<ExpenseService>().addExpense(expense);
    _amountController.clear();
    _noteController.clear();
    setState(() {
      _selectedCategory = 'Food';
      _selectedDate = DateTime.now();
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Expense saved successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF6C63FF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF12121A) : const Color(0xFFF5F6FA);
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final fillColor = isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF8F8FF);
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final hintColor = isDark ? Colors.grey[600] : Colors.grey[400];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Add Expense',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Amount
              _buildCard(
                cardColor: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Amount (₹)', Icons.currency_rupee),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black),
                      decoration: _inputDecoration(
                        hint: '0.00',
                        prefixText: '₹ ',
                        fillColor: fillColor,
                        borderColor: borderColor,
                        hintColor: hintColor!,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter an amount';
                        final val = double.tryParse(v.trim());
                        if (val == null || val <= 0) return 'Enter a valid positive amount';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Category
              _buildCard(
                cardColor: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Category', Icons.label_outline),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: cardColor,
                      decoration: _inputDecoration(
                        hint: 'Select category',
                        fillColor: fillColor,
                        borderColor: borderColor,
                        hintColor: hintColor,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      items: _categories.map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: (_categoryColors[cat] ?? Colors.grey).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(_categoryIcons[cat], size: 18,
                                  color: _categoryColors[cat] ?? Colors.grey),
                            ),
                            const SizedBox(width: 10),
                            Text(cat),
                          ],
                        ),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Date
              _buildCard(
                cardColor: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Date', Icons.calendar_today_outlined),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: fillColor,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month,
                                color: Color(0xFF6C63FF), size: 20),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('dd MMMM yyyy').format(_selectedDate),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_drop_down,
                                color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Note
              _buildCard(
                cardColor: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Note (Optional)', Icons.note_alt_outlined),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black),
                      decoration: _inputDecoration(
                        hint: 'e.g. Grocery at DMart, Monthly EMI...',
                        fillColor: fillColor,
                        borderColor: borderColor,
                        hintColor: hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF6C63FF).withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: const Color(0xFF6C63FF).withOpacity(0.4),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined, size: 22),
                            SizedBox(width: 10),
                            Text('Save Expense',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, required Color cardColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _fieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF6C63FF)),
        const SizedBox(width: 7),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF555555),
                letterSpacing: 0.2)),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    String? prefixText,
    required Color fillColor,
    required Color borderColor,
    required Color hintColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: hintColor, fontSize: 14),
      prefixText: prefixText,
      prefixStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333)),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}