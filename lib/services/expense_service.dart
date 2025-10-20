import '../model/expense.dart';

class ExpenseService {
  static final List<Expense> _expenses = [];

  // ambil semua data
  static List<Expense> getAllExpenses() {
    return _expenses;
  }

  // tambah pengeluaran baru
  static Expense addExpense({
    required String title,
    required String description,
    required double amount,
    required String category,
  }) {
    final newExpense = Expense(
      title: title,
      description: description,
      amount: amount,
      category: category,
      date: DateTime.now(),
    );
    _expenses.add(newExpense);
    return newExpense;
  }

  // edit pengeluaran lama
  static Expense updateExpense({
    required Expense oldExpense,
    required String title,
    required String description,
    required double amount,
    required String category,
  }) {
    final index = _expenses.indexOf(oldExpense);
    if (index != -1) {
      final updated = Expense(
        title: title,
        description: description,
        amount: amount,
        category: category,
        date: oldExpense.date,
      );
      _expenses[index] = updated;
      return updated;
    } else {
      // kalau datanya belum ada (misal pertama kali load)
      return Expense(
        title: title,
        description: description,
        amount: amount,
        category: category,
        date: DateTime.now(),
      );
    }
  }
}
