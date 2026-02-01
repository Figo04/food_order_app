import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:food_order/data/models/menu_model.dart';
import 'package:food_order/data/provider/order_provider.dart';

// ==================== FIRESTORE PROVIDER ====================

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ==================== PRODUCTS STREAM (untuk Kelola Menu) ====================

// Provider untuk Mengambil semua products (untuk setting)
final settingProductsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
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

// ==================== SEARCH QUERY ====================

final settingSearcQueryProvider = StateProvider<String>((ref) {
  return '';
});

// ==================== CATEGORY FILTER ====================

final settingSelectedCategoryProvider = StateProvider<ProductCategory?>((ref) {
  return null;
});

// ==================== FILTERED PRODUCTS ====================

final settingFilteredProductsProvider =
    Provider<AsyncValue<List<ProductModel>>>((ref) {
      final productsAsync = ref.watch(settingProductsStreamProvider);
      final searchQuery = ref.watch(settingSearcQueryProvider).toLowerCase();
      final selectedCategory = ref.watch(settingSelectedCategoryProvider);

      return productsAsync.whenData((products) {
        var filtered = products;

        // filter by category
        if (selectedCategory != null) {
          filtered = filtered
              .where(
                (p) =>
                    p.category.toLowerCase() ==
                    selectedCategory.label.toLowerCase(),
              )
              .toList();
        }

        // filter by search
        if (searchQuery.isNotEmpty) {
          filtered = filtered
              .where((p) => p.name.toLowerCase().contains(searchQuery))
              .toList();
        }

        return filtered;
      });
    });

// ==================== PRODUCT ACTIONS ====================

final productActionsProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ProductActions(firestore);
});

class ProductActions {
  final FirebaseFirestore _firestore;

  ProductActions(this._firestore);

  // Create product
  Future<void> createProduct(ProductModel product) async {
    final data = product.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('products').add(data);
  }

  // Update Product
  Future<void> updateProduct(String productId, ProductModel product) async {
    final data = product.toMap();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('products').doc(productId).update(data);
  }

    //Delete product
    Future<void> deleteProduct(String productId) async {
      await _firestore.collection('products').doc(productId).delete();
    }

    // Toggle availability
    Future<void> toggleAvailability(
      String productId,
      bool currentStatus,
    ) async {
      await _firestore.collection('products').doc(productId).update({
        'isAvailable': !currentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // Update stock
    Future<void> updateStock(String productId, int newStock) async {
      await _firestore.collection('products').doc(productId).update({
        'stock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

//==================== LOADING STATE ====================

final isSettingLoadingProvider = StateProvider<bool>((ref) {
  return false;
});
