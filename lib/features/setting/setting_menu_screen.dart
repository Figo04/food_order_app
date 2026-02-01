import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order/core/constant/apps_contans.dart';
import 'package:food_order/core/widgets/settings/setting_menu_form_widget.dart';
import 'package:food_order/core/widgets/settings/setting_menu_item_widget.dart';
import 'package:food_order/data/models/menu_model.dart';
import 'package:food_order/data/provider/setting_menu_provider.dart';

class SettingMenuScreen extends ConsumerStatefulWidget {
  const SettingMenuScreen({super.key});

  @override
  ConsumerState<SettingMenuScreen> createState() => _SettingMenuScreenState();
}

class _SettingMenuScreenState extends ConsumerState<SettingMenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProductsAsync = ref.watch(settingFilteredProductsProvider);
    final selectedCategory = ref.watch(settingSelectedCategoryProvider);

    return Scaffold(
      backgroundColor: Color(0xFFECECEC),
      appBar: AppBar(
        backgroundColor: Color(0xFFECECEC),
        elevation: 0,
        toolbarHeight: 90,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Setting Menu',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // button add
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          ref.read(settingSearcQueryProvider.notifier).state =
                              value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari Menu...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                            .read(
                                              settingSearcQueryProvider
                                                  .notifier,
                                            )
                                            .state =
                                        '';
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Button add
                    _buildAddButton(context),
                  ],
                ),

                const SizedBox(height: 12),

                // Category Filter
                _buildCategoryFilter(selectedCategory, ref),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: filteredProductsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(settingProductsStreamProvider);
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  color: const Color(0xFFEF6C00),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return SettingMenuItemWidget(product: product);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFEF6C00)),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat menu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(settingProductsStreamProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF6C00),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ADD BUTTON (GRADIENT) ====================

Widget _buildAddButton(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      gradient: AppsColor.primary,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.orange.withOpacity(0.3),
          offset: const Offset(0, 3),
          blurRadius: 8,
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAddMenuForm(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Row(
            children: [
              Icon(Icons.add, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Tambah',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ==================== CATEGORY FILTER ====================

Widget _buildCategoryFilter(ProductCategory? selectedCategory, WidgetRef ref) {
  final categories = [
    null, // Semua
    ProductCategory.Makanan,
    ProductCategory.Minuman,
    ProductCategory.Cemilan,
  ];

  return SizedBox(
    height: 40,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category == selectedCategory;
        final label = category?.label ?? 'Semua';

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              ref.read(settingSelectedCategoryProvider.notifier).state =
                  category;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppsColor.primary : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

// ==================== EMPTY STATE ====================

Widget _buildEmptyState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.restaurant_menu,
            size: 80,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Belum Ada Menu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tambahkan menu pertama Anda',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),
        _buildAddMenuButton(context),
      ],
    ),
  );
}

// ==================== ADD MENU BUTTON (Empty State) ====================

Widget _buildAddMenuButton(BuildContext context) {
  return Container(
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
        onTap: () => _showAddMenuForm(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Tambah Menu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

//==================== SHOW ADD MENU FORM ====================

void _showAddMenuForm(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const SettingMenuFormWidget(),
  );
}
