import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:food_order/data/models/menu_model.dart';

// ==================== FIRESTORE PROVIDER ====================

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ==================== PRODUCTS STREAM PROVIDER ====================

// Provider untuk mengambil data produk dari firestore/Firebase (secara real-time)
final productsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('products')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList();
      });
});

// ==================== CATEGORY FILTER ====================

// StateProvider untuk menyimpan kategori yang dipilih
final selectedCategoryProvider = StateProvider<ProductCategory>((ref) {
  return ProductCategory.semua;
});

// ==================== SEARCH QUERY ====================

// StateProvider untuk menyimpan search query
final searchQueryProvider = StateProvider<String>((ref) {
  return ''; // default kosong
});

// ==================== FILTERED PRODUCTS ====================

// Provider untuk filter products berdasarkan kategori dan search query
final filteredProductsProvider = Provider<AsyncValue<List<ProductModel>>>((
  ref,
) {
  final productsAsync = ref.watch(productsStreamProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return productsAsync.whenData((products) {
    // filter berdasarkan category
    var filtered = products;

    if (selectedCategory != ProductCategory.semua) {
      filtered = filtered
          .where(
            (p) =>
                p.category.toLowerCase() ==
                selectedCategory.value.toLowerCase(),
          )
          .toList();
    }

    // filter berdasarkan search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(searchQuery))
          .toList();
    }
    return filtered;
  });
});
