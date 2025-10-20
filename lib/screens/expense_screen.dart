import 'package:flutter/material.dart';
import '../model/expense.dart';
import '../managers/expense_manager.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<Expense> displayedExpenses = ExpenseManager.expenses;
  String searchQuery = '';
  String? selectedFilter;

  double get total => displayedExpenses.fold(0.0, (sum, e) => sum + e.amount);
  double get average =>
      displayedExpenses.isNotEmpty ? total / displayedExpenses.length : 0.0;

  // ➕ Tambah pengeluaran
  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedCategory;

    final categories = [
      'Operasional',
      'Marketing',
      'Logistik',
      'Hiburan',
      'Lainnya',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tambah Pengeluaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 14),
                _buildInput(titleController, 'Nama Pengeluaran'),
                const SizedBox(height: 10),
                _buildInput(descController, 'Deskripsi'),
                const SizedBox(height: 10),
                _buildInput(
                  amountController,
                  'Jumlah (Rp)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items:
                      categories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (val) => selectedCategory = val,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        final title = titleController.text;
                        final desc = descController.text;
                        final amount =
                            double.tryParse(amountController.text) ?? 0;
                        final category = selectedCategory ?? '';

                        if (title.isEmpty ||
                            desc.isEmpty ||
                            amount <= 0 ||
                            category.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Harap isi semua kolom dengan benar!',
                              ),
                            ),
                          );
                          return;
                        }

                        final newExpense = Expense(
                          title: title,
                          description: desc,
                          amount: amount,
                          date: DateTime.now(),
                          category: category,
                        );

                        ExpenseManager.addExpense(newExpense);

                        setState(() {
                          displayedExpenses = ExpenseManager.expenses;
                        });

                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Simpan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses =
        displayedExpenses.where((e) {
          final matchQuery = e.title.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
          final matchFilter =
              selectedFilter == null || e.category == selectedFilter;
          return matchQuery && matchFilter;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengeluaran'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: Rp ${total.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'Rata-rata: Rp ${average.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 14),

            // 🔍 Search dan Filter
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari pengeluaran...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setState(() => searchQuery = val);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: selectedFilter,
                    hint: const Text('Filter'),
                    items:
                        [
                              'Operasional',
                              'Marketing',
                              'Logistik',
                              'Hiburan',
                              'Lainnya',
                            ]
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => selectedFilter = val),
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 📋 Daftar Pengeluaran
            Expanded(
              child:
                  filteredExpenses.isEmpty
                      ? const Center(child: Text('Belum ada pengeluaran'))
                      : ListView.builder(
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, i) {
                          final e = filteredExpenses[i];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text(e.title),
                              subtitle: Text(
                                '${e.category} • ${e.date.toString().substring(0, 10)}',
                              ),
                              trailing: Text(
                                'Rp ${e.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
