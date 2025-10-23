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
        backgroundColor: Colors.indigo,
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
                                  // 🧾 Info Pengeluaran
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

                                  // 💰 Nominal dan Tombol Edit
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
                                            color: Colors.indigo.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.indigo,
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

      // ➕ Tambah Pengeluaran
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );

          if (result != null && result is Expense) {
            setState(() {
              ExpenseManager.addExpense(result);
              displayedExpenses = ExpenseManager.expenses;
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
