import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/app_colors.dart';
import '../services/firestore_service.dart';
import 'add_item_screen.dart';
import 'edit_item_screen.dart';
import 'detail_item_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  IconData _getItemIcon(String category) {
    switch (category.toLowerCase()) {
      case 'komputer':
        return Icons.computer;

      case 'elektronik':
        return Icons.devices;

      case 'jaringan':
        return Icons.router;

      case 'multimedia':
        return Icons.video_library;

      default:
        return Icons.inventory_2_outlined;
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String itemId,
    String itemName,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Inventaris?'),
          content: Text('Apakah kamu yakin ingin menghapus "$itemName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirestoreService().deleteItem(itemId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventaris berhasil dihapus.')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus inventaris: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Inventaris',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal mengambil data inventaris.'),
            );
          }

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(child: Text('Belum ada data inventaris.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index].data() as Map<String, dynamic>;

              final category = item['category'] ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailItemScreen(
                          itemId: items[index].id,
                          item: item,
                        ),
                      ),
                    );
                  },
                  leading: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getItemIcon(category),
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  title: Text(item['item_name'] ?? 'Tanpa Nama'),
                  subtitle: Text(category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item['status'] ?? '-'),

                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditItemScreen(
                                itemId: items[index].id,
                                item: item,
                              ),
                            ),
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _confirmDelete(
                            context,
                            items[index].id,
                            item['item_name'] ?? 'Barang ini',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
