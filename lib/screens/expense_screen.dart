import 'package:flutter/material.dart';
import '../model/expense.dart';
import '../managers/expense_manager.dart';
import 'add_expense_screen.dart';

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
        onPressed: () async {
          // Navigasi ke halaman tambah pengeluaran
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );

          // Jika ada hasil (pengeluaran baru)
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
