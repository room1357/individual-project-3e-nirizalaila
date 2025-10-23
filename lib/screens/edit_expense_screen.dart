import 'package:flutter/material.dart';
import '../model/expense.dart';
import '../services/expense_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController amountController;
  late String selectedCategory;

  final categories = [
    'Operasional',
    'Marketing',
    'Logistik',
    'Hiburan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.expense.title);
    descController = TextEditingController(text: widget.expense.description);
    amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );
    selectedCategory = widget.expense.category;
  }

  void _saveChanges() {
    final title = titleController.text.trim();
    final desc = descController.text.trim();
    final amount = double.tryParse(amountController.text.trim()) ?? 0;

    if (title.isEmpty || desc.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom dengan benar!')),
      );
      return;
    }

    final updatedExpense = ExpenseService.updateExpense(
      oldExpense: widget.expense,
      title: title,
      description: desc,
      amount: amount,
      category: selectedCategory,
    );

    Navigator.pop(context, updatedExpense);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pengeluaran'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInput(titleController, 'Nama Pengeluaran'),
              const SizedBox(height: 12),
              _buildInput(descController, 'Deskripsi'),
              const SizedBox(height: 12),
              _buildInput(
                amountController,
                'Jumlah (Rp)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items:
                    categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                onChanged:
                    (val) => setState(() {
                      selectedCategory = val!;
                    }),
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _saveChanges,
                  child: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
}
