import 'package:flutter/material.dart';
import '../managers/looping_examples.dart';
import '../model/expense.dart';

class LoopingScreen extends StatelessWidget {
  const LoopingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Expense> data = LoopingExamples.expenses;

    final total1 = LoopingExamples.calculateTotalTraditional(data);
    final total2 = LoopingExamples.calculateTotalForIn(data);
    final total3 = LoopingExamples.calculateTotalForEach(data);
    final total4 = LoopingExamples.calculateTotalFold(data);
    final total5 = LoopingExamples.calculateTotalReduce(data);

    final filtered = LoopingExamples.filterByCategoryWhere(data, "Marketing");
    final found = LoopingExamples.findExpenseByTitle(data, "Iklan Instagram");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tes Looping"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "💰 Hasil Total Pengeluaran (berbagai cara):",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text("For Loop Tradisional: Rp ${total1.toStringAsFixed(0)}"),
            Text("For-In Loop: Rp ${total2.toStringAsFixed(0)}"),
            Text("forEach: Rp ${total3.toStringAsFixed(0)}"),
            Text("Fold: Rp ${total4.toStringAsFixed(0)}"),
            Text("Reduce: Rp ${total5.toStringAsFixed(0)}"),

            const SizedBox(height: 20),
            const Divider(),
            const Text(
              "🔍 Filtering (Kategori = Marketing):",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ...filtered.map(
              (e) => ListTile(
                title: Text(e.title),
                subtitle: Text(e.category),
                trailing: Text("Rp ${e.amount.toStringAsFixed(0)}"),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const Text(
              "🔎 Find Expense (title = 'Iklan Instagram'):",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (found != null)
              ListTile(
                title: Text(found.title),
                subtitle: Text(found.description),
                trailing: Text("Rp ${found.amount.toStringAsFixed(0)}"),
              )
            else
              const Text("Tidak ditemukan"),
          ],
        ),
      ),
    );
  }
}
