import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../utils/app_colors.dart';

class EditItemScreen extends StatefulWidget {
  final String itemId;
  final Map<String, dynamic> item;

  const EditItemScreen({super.key, required this.itemId, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _specificationController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  final List<String> _categories = [
    'Komputer',
    'Elektronik',
    'Jaringan',
    'Multimedia',
  ];

  final List<String> _statuses = ['Available', 'Borrowed'];

  String _selectedCategory = 'Komputer';
  String _selectedStatus = 'Available';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.item['item_name'] ?? '';
    _codeController.text = widget.item['code'] ?? '';
    _specificationController.text = widget.item['spesification'] ?? '';

    if (_categories.contains(widget.item['category'])) {
      _selectedCategory = widget.item['category'];
    }

    if (_statuses.contains(widget.item['status'])) {
      _selectedStatus = widget.item['status'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _specificationController.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.updateItem(
        id: widget.itemId,
        itemName: _nameController.text.trim(),
        category: _selectedCategory,
        code: _codeController.text.trim(),
        status: _selectedStatus,
        image: widget.item['image'] ?? '',
        specification: _specificationController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventaris berhasil diperbarui.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui inventaris: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Inventaris',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nama Barang'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama barang wajib diisi.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              const Text('Kategori'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              const Text('Kode Barang'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode barang wajib diisi.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              const Text('Status'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                items: _statuses.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              const Text('Spesifikasi'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _specificationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Spesifikasi wajib diisi.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
