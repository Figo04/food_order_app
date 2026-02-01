import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order/core/helper/cloudinary_service.dart';
import 'package:food_order/data/models/menu_model.dart';
import 'package:food_order/data/provider/setting_menu_provider.dart';

class SettingMenuFormWidget extends ConsumerStatefulWidget {
  final ProductModel? product; // null = add, ada value = edit

  const SettingMenuFormWidget({super.key, this.product});

  @override
  ConsumerState<SettingMenuFormWidget> createState() =>
      _SettingMenuFormWidgetState();
}

class _SettingMenuFormWidgetState extends ConsumerState<SettingMenuFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  late String _selectedCategory;
  late bool _isAvailable;

  // State untuk image upload
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );

    _selectedCategory = widget.product?.category ?? 'Makanan';
    _isAvailable = widget.product?.isAvailable ?? true;

    // Kalau edit, simpan URL gambar yang sudah ada
    _uploadedImageUrl = widget.product?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  /// Pick dan upload gambar ke Cloudinary
  Future<void> _pickAndUploadImage() async {
    final File? image = await _cloudinaryService.pickImage();
    if (image == null) return; // user batalkan

    setState(() {
      _selectedImage = image;
      _isUploadingImage = true;
    });

    try {
      final String? url = await _cloudinaryService.uploadImage(image);

      setState(() {
        _uploadedImageUrl = url;
        _isUploadingImage = false;
      });
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Hapus gambar (reset ke kosong)
  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _uploadedImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final isLoading = ref.watch(isSettingLoadingProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // header
              Row(
                children: [
                  Text(
                    isEdit ? 'Edit Menu' : 'Tambah Menu',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Nama menu
              _buildTextField(
                controller: _nameController,
                label: 'Nama Menu',
                hint: 'Masukkan nama menu',
                icon: Icons.restaurant_menu,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama menu wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Deskripsi
              _buildTextField(
                controller: _descriptionController,
                label: 'Deskripsi',
                hint: 'Masukkan deskripsi',
                icon: Icons.description,
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // harga & stock
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Harga',
                      hint: 'Masukkan harga',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga wajib diisi';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Harga tidak valid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _stockController,
                      label: 'Stock',
                      hint: 'Masukkan stock',
                      icon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stock wajib diisi';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Stock tidak valid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category Dropdown
              _buildCategoryDropdown(),

              const SizedBox(height: 16),

              // Image Upload (menggantikan URL input)
              _buildImagePicker(),

              const SizedBox(height: 16),

              // Status Switch
              _buildStatusSwitch(),

              const SizedBox(height: 24),

              // Submit button (dengan gradient)
              _buildSubmitButton(context, isEdit, isLoading),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TEXT FIELD ====================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF6C00), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== IMAGE PICKER ====================

  Widget _buildImagePicker() {
    final bool hasImage = _selectedImage != null || _uploadedImageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gambar Menu (Opsional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isUploadingImage ? null : _pickAndUploadImage,
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(
                color: hasImage
                    ? const Color(0xFFEF6C00)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Tampilkan gambar atau placeholder
                  if (_selectedImage != null)
                    // Gambar baru yang dipilih dari device
                    Image.file(_selectedImage!, fit: BoxFit.cover)
                  else if (_uploadedImageUrl != null &&
                      _uploadedImageUrl!.isNotEmpty)
                    // Gambar dari URL (edit mode)
                    Image.network(
                      _uploadedImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(),
                    )
                  else
                    // Placeholder kosong
                    _buildImagePlaceholder(),

                  // Overlay: loading / tombol ganti / tombol hapus
                  if (_isUploadingImage)
                    // Loading state
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 8),
                            Text(
                              'Uploading...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (hasImage)
                    // Overlay untuk ganti/hapus gambar
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        color: Colors.black54,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tap untuk ganti',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: _removeImage,
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Status upload berhasil
        if (!_isUploadingImage && _uploadedImageUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 6),
                Text(
                  'Gambar siap',
                  style: TextStyle(color: Colors.green, fontSize: 13),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Placeholder kosong saat belum ada gambar
  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 40,
            color: Colors.grey,
          ),
          SizedBox(height: 6),
          Text(
            'Tap untuk upload gambar',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ==================== CATEGORY DROPDOWN ====================

  Widget _buildCategoryDropdown() {
    final categories = ['Makanan', 'Minuman', 'Snack'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // ==================== STATUS SWITCH ====================

  Widget _buildStatusSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.toggle_on,
                color: _isAvailable ? const Color(0xFFEF6C00) : Colors.grey,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Menu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _isAvailable ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _isAvailable,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
            },
            activeColor: const Color(0xFFEF6C00),
          ),
        ],
      ),
    );
  }

  // ==================== SUBMIT BUTTON (GRADIENT) ====================

  Widget _buildSubmitButton(BuildContext context, bool isEdit, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEF6C00), Color(0xFFFFAB40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : () => _handleSubmit(context, isEdit),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Text(
                      isEdit ? 'Update Menu' : 'Tambah Menu',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== SUBMIT HANDLER ====================

  Future<void> _handleSubmit(BuildContext context, bool isEdit) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref.read(isSettingLoadingProvider.notifier).state = true;

    try {
      final productActions = ref.read(productActionsProvider);

      final product = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory,
        imageUrl: _uploadedImageUrl ?? '', // URL dari Cloudinary
        stock: int.parse(_stockController.text.trim()),
        isAvailable: _isAvailable,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEdit) {
        await productActions.updateProduct(product.id, product);
      } else {
        await productActions.createProduct(product);
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit ? 'Menu berhasil diupdate' : 'Menu berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      ref.read(isSettingLoadingProvider.notifier).state = false;
    }
  }
}
