import '../model/expense.dart';

class ExpenseManager {
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

  static void addExpense(Expense expense) {
    expenses.add(expense);
  }

  static Map<String, double> getTotalByCategory(List<Expense> expenses) {
    Map<String, double> result = {};
    for (var expense in expenses) {
      result[expense.category] =
          (result[expense.category] ?? 0) + expense.amount;
    }
    return result;
  }

  static Expense? getHighestExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  static List<Expense> searchExpenses(List<Expense> expenses, String keyword) {
    String lowerKeyword = keyword.toLowerCase();
    return expenses
        .where(
          (expense) =>
              expense.title.toLowerCase().contains(lowerKeyword) ||
              expense.description.toLowerCase().contains(lowerKeyword) ||
              expense.category.toLowerCase().contains(lowerKeyword),
        )
        .toList();
  }

  static double getAverageDaily(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;

    double total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    Set<String> uniqueDays =
        expenses
            .map((e) => '${e.date.year}-${e.date.month}-${e.date.day}')
            .toSet();

    return total / uniqueDays.length;
  }
}
