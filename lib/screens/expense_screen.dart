import 'dart:io' show Platform, File;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

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

  Future<void> exportToCSV() async {
    final csvBuffer = StringBuffer();
    csvBuffer.writeln('Nama Pengeluaran,Deskripsi,Kategori,Nominal,Tanggal');

    for (var e in displayedExpenses) {
      csvBuffer.writeln(
        '"${e.title}","${e.description}","${e.category}",'
        '"${e.amount}","${e.date.toIso8601String()}"',
      );
    }

    final csvData = csvBuffer.toString();

    try {
      if (kIsWeb) {
        final bytes = utf8.encode(csvData);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute('download', 'expense_data.csv')
              ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/expense_data.csv';
        final file = File(path);
        await file.writeAsString(csvData);
        await OpenFile.open(path);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil diekspor ke CSV')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengekspor CSV: $e')));
    }
  }

  Future<void> exportToPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Laporan Pengeluaran',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: [
                    'Nama Pengeluaran',
                    'Kategori',
                    'Nominal',
                    'Tanggal',
                  ],
                  data:
                      displayedExpenses
                          .map(
                            (e) => [
                              e.title,
                              e.category,
                              'Rp ${e.amount.toStringAsFixed(0)}',
                              e.date.toString().substring(0, 10),
                            ],
                          )
                          .toList(),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.indigo100,
                  ),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.centerLeft,
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                  },
                ),
              ],
            ),
      ),
    );

    try {
      if (kIsWeb) {
        final bytes = await pdf.save();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute('download', 'expense_data.pdf')
              ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/expense_data.pdf';
        final file = File(path);
        await file.writeAsBytes(await pdf.save());
        await OpenFile.open(path);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil diekspor ke PDF')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengekspor PDF: $e')));
    }
  }

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
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_present, size: 18),
                  label: const Text('CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 14,
                    ),
                  ),
                  onPressed: exportToCSV,
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 14,
                    ),
                  ),
                  onPressed: exportToPDF,
                ),
                const SizedBox(width: 6),
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
