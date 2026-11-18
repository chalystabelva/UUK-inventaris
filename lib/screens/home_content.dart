import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/app_colors.dart';
import '../services/firestore_service.dart';
import '../widgets/banner_slider.dart';
import '../widgets/custom_search_bar.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'LAB INVENTORY',
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
            CustomSearchBar(
              controller: _searchController,
              hintText: 'Cari alat inventaris...',
              onChanged: (value) {},
            ),

            const SizedBox(height: 24),

            const BannerSlider(),

            const SizedBox(height: 28),

            // Semua Data dari Firestore
            _sectionTitle('Semua Data'),
            const SizedBox(height: 12),

            SizedBox(
              height: 140,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestoreService.getItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Gagal mengambil data inventaris'),
                    );
                  }

                  final items = snapshot.data?.docs ?? [];

                  if (items.isEmpty) {
                    return const Center(
                      child: Text('Belum ada data inventaris'),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index].data() as Map<String, dynamic>;

                      return _itemCard(
                        item['item_name'] ?? 'Tanpa Nama',
                        item['category'] ?? '-',
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // Kategori Peralatan
            _sectionTitle('Kategori Peralatan'),
            const SizedBox(height: 12),

            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(height: 2),
                        Text(
                          'Komputer',
                          style: TextStyle(color: AppColors.textDark),
                        ),
                      ],
                    ),
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),

                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(height: 2),
                        Text(
                          'Elektronik',
                          style: TextStyle(color: AppColors.textDark),
                        ),
                      ],
                    ),
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),

                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(height: 1),
                        Text(
                          'Jaringan',
                          style: TextStyle(color: AppColors.textDark),
                        ),
                      ],
                    ),
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),

                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(height: 2),
                        Text(
                          'Multimedia',
                          style: TextStyle(color: AppColors.textDark),
                        ),
                      ],
                    ),
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Status
            _sectionTitle('Status'),
            const SizedBox(height: 12),

            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _itemCard('Tersedia', 'Status alat'),
                  _itemCard('Dipinjam', 'Status alat'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Judul setiap section
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  // Card inventaris
  Widget _itemCard(String title, String subtitle) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.secondary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
