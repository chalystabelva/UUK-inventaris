import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class DetailItemScreen extends StatefulWidget {
  final String itemId;
  final Map<String, dynamic> item;

  const DetailItemScreen({super.key, required this.itemId, required this.item});

  @override
  State<DetailItemScreen> createState() => _DetailItemScreenState();
}

class _DetailItemScreenState extends State<DetailItemScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;

  Future<void> _borrowItem() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.borrowItem(
        itemId: widget.itemId,
        itemName: widget.item['item_name'] ?? '',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan peminjaman berhasil!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengajukan peminjaman: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final category = item['category'] ?? '';
    final status = item['status'] ?? '-';
    final isAvailable = status == 'Available';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Inventaris',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getItemIcon(category),
                  size: 90,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              item['item_name'] ?? 'Tanpa Nama',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              category,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 16),
            ),

            const SizedBox(height: 24),

            const Text(
              'Informasi Barang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _infoCard('Kode Barang', item['code'] ?? '-'),
            _infoCard('Kategori', category),
            _infoCard('Status', status),

            const SizedBox(height: 24),

            const Text(
              'Spesifikasi Barang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item['spesification'] ?? 'Belum ada spesifikasi.',
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isAvailable && !_isLoading ? _borrowItem : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isAvailable
                            ? 'Ajukan Peminjaman'
                            : 'Barang Tidak Tersedia',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
