import 'package:flutter/material.dart';
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
            // 🔍 Search dan Tambah
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

            // 📋 Daftar Kategori
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
