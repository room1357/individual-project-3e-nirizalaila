import 'package:flutter/material.dart';
import '../model/expense.dart';
import '../managers/expense_manager.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

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

  void _deleteExpense(Expense expense) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Pengeluaran'),
            content: Text(
              'Yakin ingin menghapus pengeluaran "${expense.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    ExpenseManager.expenses.remove(expense);
                    displayedExpenses = ExpenseManager.expenses;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
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
              selectedFilter == null ||
              selectedFilter == 'Semua Pengeluaran' ||
              e.category == selectedFilter;
          return matchQuery && matchFilter;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengeluaran'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Pengeluaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildSummaryCard(
              'Total Pengeluaran',
              'Rp ${total.toStringAsFixed(0)}',
              Icons.summarize,
              Colors.indigo,
            ),
            _buildSummaryCard(
              'Rata-rata Pengeluaran',
              'Rp ${average.toStringAsFixed(0)}',
              Icons.calculate,
              Colors.teal,
            ),

            const SizedBox(height: 20),

            const Text(
              'Manajemen Pengeluaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 🔍 Search, Filter, dan Tambah
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
                              'Semua Pengeluaran',
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
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddExpenseScreen(),
                      ),
                    );

                    if (result != null && result is Expense) {
                      setState(() {
                        ExpenseManager.addExpense(result);
                        displayedExpenses = ExpenseManager.expenses;
                      });
                    }
                  },
                  child: const Text('Tambah'),
                ),
              ],
            ),

            const SizedBox(height: 16),

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
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          e.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${e.category} • ${e.date.toString().substring(0, 10)}',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Rp ${e.amount.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Colors.indigo,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () async {
                                          final updatedExpense =
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          EditExpenseScreen(
                                                            expense: e,
                                                          ),
                                                ),
                                              );

                                          if (updatedExpense != null &&
                                              updatedExpense is Expense) {
                                            setState(() {
                                              final index = ExpenseManager
                                                  .expenses
                                                  .indexOf(e);
                                              if (index != -1) {
                                                ExpenseManager.expenses[index] =
                                                    updatedExpense;
                                              }
                                              displayedExpenses =
                                                  ExpenseManager.expenses;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.blueAccent
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.blueAccent,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () => _deleteExpense(e),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
