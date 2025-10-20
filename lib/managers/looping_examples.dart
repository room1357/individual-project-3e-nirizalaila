import '../model/expense.dart';

class LoopingExamples {
  static List<Expense> expenses = [
    Expense(
      title: "Beli bahan baku",
      description: "Tepung dan gula untuk produksi",
      category: "Operasional",
      amount: 500000,
      date: DateTime(2025, 10, 8),
    ),
    Expense(
      title: "Iklan Instagram",
      description: "Promosi produk di IG Ads",
      category: "Marketing",
      amount: 200000,
      date: DateTime(2025, 10, 9),
    ),
    Expense(
      title: "Ongkos kirim",
      description: "Pengiriman ke pelanggan",
      category: "Logistik",
      amount: 100000,
      date: DateTime(2025, 10, 10),
    ),
  ];

  // 🔹 1. Total pakai berbagai looping
  static double calculateTotalTraditional(List<Expense> expenses) {
    double total = 0;
    for (int i = 0; i < expenses.length; i++) {
      total += expenses[i].amount;
    }
    return total;
  }

  static double calculateTotalForIn(List<Expense> expenses) {
    double total = 0;
    for (Expense e in expenses) {
      total += e.amount;
    }
    return total;
  }

  static double calculateTotalForEach(List<Expense> expenses) {
    double total = 0;
    expenses.forEach((e) => total += e.amount);
    return total;
  }

  static double calculateTotalFold(List<Expense> expenses) {
    return expenses.fold(0, (sum, e) => sum + e.amount);
  }

  static double calculateTotalReduce(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    return expenses.map((e) => e.amount).reduce((a, b) => a + b);
  }

  // 🔹 2. Mencari item tanpa id, pakai title aja
  static Expense? findExpenseByTitle(List<Expense> expenses, String title) {
    try {
      return expenses.firstWhere(
        (e) => e.title.toLowerCase() == title.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // 🔹 3. Filter kategori
  static List<Expense> filterByCategoryManual(
    List<Expense> expenses,
    String category,
  ) {
    List<Expense> result = [];
    for (Expense e in expenses) {
      if (e.category.toLowerCase() == category.toLowerCase()) {
        result.add(e);
      }
    }
    return result;
  }

  static List<Expense> filterByCategoryWhere(
    List<Expense> expenses,
    String category,
  ) {
    return expenses
        .where((e) => e.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
