import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:food_order/data/models/cart_model.dart';
import 'package:food_order/data/models/menu_model.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ==================== CART STATE NOTIFIER ====================

// state untuk cart
class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  // hitung total items
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // hitung total harga
  double get totalPrice => items.fold(0, (sum, item) => sum + item.subtotal);

  // check apakah cart kosong
  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

// cart notifier
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  // Tambah product ke cart
  void addProduct(ProductModel product) {
    final currentItems = List<CartItem>.from(state.items);

    // cek apakah product sudah ada di cart
    final existingIndex = currentItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // jika product sudah ada di cart, tambahkan quantity
      final existingItem = currentItems[existingIndex];
      final newQuantity = existingItem.quantity + 1;

      // cek stock
      if (newQuantity > product.stock) {
        // untuk notifasi stock jika tidak cukup
        return;
      }

      currentItems[existingIndex] = existingItem.copyWith(
        quantity: newQuantity,
      );
    } else {
      // product baru tambahkan ke cart
      if (product.stock < 1) {
        // untuk notifasi stock jika tidak / stock habis
        return;
      }

      currentItems.add(CartItem(product: product, quantity: 1));
    }

    state = state.copyWith(items: currentItems);
  }

  // hapus product dari cart
  void removeProduct(String productId) {
    final currentItems = state.items
        .where((item) => item.product.id != productId)
        .toList();
    state = state.copyWith(items: currentItems);
  }

  // clear cart
  void clearCart() {
    state = CartState();
  }

  // get quantity product di cart
  int getProductQuantity(String productId) {
    final item = state.items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: ProductModel(
          id: '',
          name: '',
          description: '',
          price: 0,
          category: '',
          stock: 0,
          isAvailable: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          imageUrl: '',
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  // Di cart_provider.dart, tambahkan method ini:

  void decreaseProduct(String productId) {
    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index >= 0) {
      final item = currentItems[index];
      if (item.quantity > 1) {
        // Kurangi quantity
        currentItems[index] = item.copyWith(quantity: item.quantity - 1);
      } else {
        // Hapus item jika quantity = 1
        currentItems.removeAt(index);
      }

      state = state.copyWith(items: currentItems);
    }
  }
}

// ==================== CART PROVIDER ====================

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// Provider untuk total items di cart
final cartTotalItemsProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalItems;
});

// provider untuk total harga di cart
final cartTotalPriceProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalPrice;
});
