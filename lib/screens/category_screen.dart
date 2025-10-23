import 'dart:io' show Platform, File;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../model/category.dart';
import 'edit_category_screen.dart';
import 'add_category_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<Category> _categories = [
    Category(
      name: 'Operasional',
      description: 'Biaya untuk kegiatan operasional',
    ),
    Category(
      name: 'Marketing',
      description: 'Pengeluaran untuk promosi dan iklan',
    ),
    Category(
      name: 'Logistik',
      description: 'Transportasi dan distribusi barang',
    ),
    Category(name: 'Hiburan', description: 'Acara dan kegiatan non-produktif'),
    Category(
      name: 'Lainnya',
      description: 'Kategori tambahan sesuai kebutuhan',
    ),
  ];

  String searchQuery = '';

  List<Category> get filteredCategories {
    return _categories.where((cat) {
      final query = searchQuery.toLowerCase();
      return cat.name.toLowerCase().contains(query) ||
          cat.description.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> exportToCSV() async {
    final csvBuffer = StringBuffer();
    csvBuffer.writeln('Nama Kategori,Deskripsi');

    for (var cat in filteredCategories) {
      csvBuffer.writeln('"${cat.name}","${cat.description}"');
    }

    final csvData = csvBuffer.toString();

    try {
      if (kIsWeb) {
        final bytes = utf8.encode(csvData);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute('download', 'category_data.csv')
              ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/category_data.csv';
        final file = File(path);
        await file.writeAsString(csvData);
        await OpenFile.open(path);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data kategori berhasil diekspor ke CSV')),
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
                  'Daftar Kategori',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ['Nama Kategori', 'Deskripsi'],
                  data:
                      filteredCategories
                          .map((cat) => [cat.name, cat.description])
                          .toList(),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.indigo100,
                  ),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.centerLeft,
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(5),
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
              ..setAttribute('download', 'category_data.pdf')
              ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/category_data.pdf';
        final file = File(path);
        await file.writeAsBytes(await pdf.save());
        await OpenFile.open(path);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data kategori berhasil diekspor ke PDF')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengekspor PDF: $e')));
    }
  }

  Future<void> _addCategory() async {
    final newCategory = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
    );

    if (newCategory != null && newCategory is Category) {
      setState(() {
        _categories.add(newCategory);
      });
    }
  }

  Future<void> _editCategory(int index) async {
    final updatedCategory = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditCategoryScreen(category: _categories[index]),
      ),
    );

    if (updatedCategory != null && updatedCategory is Category) {
      setState(() {
        _categories[index] = updatedCategory;
      });
    }
  }

  void _deleteCategory(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Kategori'),
            content: Text(
              'Yakin ingin menghapus kategori "${_categories[index].name}"?',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _categories.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesToShow = filteredCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search dan Tombol Ekspor
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari kategori...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => searchQuery = val),
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
                  onPressed: _addCategory,
                  child: const Text('Tambah'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child:
                  categoriesToShow.isEmpty
                      ? const Center(child: Text('Belum ada kategori'))
                      : ListView.builder(
                        itemCount: categoriesToShow.length,
                        itemBuilder: (context, index) {
                          final category = categoriesToShow[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                category.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                category.description,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap:
                                        () => _editCategory(
                                          _categories.indexOf(category),
                                        ),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
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
                                    onTap:
                                        () => _deleteCategory(
                                          _categories.indexOf(category),
                                        ),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
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
