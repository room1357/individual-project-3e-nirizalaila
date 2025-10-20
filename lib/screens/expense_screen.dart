import 'package:flutter/material.dart';
import '../model/expense.dart';
import '/managers/expense_manager.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<Expense> displayedExpenses = ExpenseManager.expenses;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final totalByCategory = ExpenseManager.getTotalByCategory(
      displayedExpenses,
    );
    final highest = ExpenseManager.getHighestExpense(displayedExpenses);
    final average = ExpenseManager.getAverageDaily(displayedExpenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pengeluaran'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Pencarian
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari pengeluaran...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  displayedExpenses = ExpenseManager.searchExpenses(
                    ExpenseManager.expenses,
                    value,
                  );
                });
              },
            ),
            const SizedBox(height: 16),

            // 📊 Info ringkas
            Card(
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("💰 Total per Kategori:"),
                    ...totalByCategory.entries.map(
                      (e) =>
                          Text("- ${e.key}: Rp${e.value.toStringAsFixed(0)}"),
                    ),
                    const SizedBox(height: 8),
                    if (highest != null)
                      Text(
                        "📈 Pengeluaran Tertinggi: ${highest.title} (Rp${highest.amount})",
                      ),
                    Text(
                      "📅 Rata-rata Harian: Rp${average.toStringAsFixed(0)}",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📋 Daftar pengeluaran
            Expanded(
              child: ListView.builder(
                itemCount: displayedExpenses.length,
                itemBuilder: (context, index) {
                  final e = displayedExpenses[index];
                  return Card(
                    child: ListTile(
                      title: Text(e.title),
                      subtitle: Text("${e.category} • ${e.description}"),
                      trailing: Text("Rp${e.amount.toStringAsFixed(0)}"),
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
