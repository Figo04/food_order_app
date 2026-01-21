import 'package:food_order/data/models/menu_model.dart';

// ==================== CART ITEM MODEL ====================

class CartItem {
  final ProductModel product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  // Hitung subtotal
  double get subtotal => product.price * quantity;

  // Copywith untuk update quantity
  CartItem copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  // Convert to map
  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'price': product.price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  @override
  String toString() {
    return 'cartItem(product: ${product.name}, quantity: $quantity, subtotal: $subtotal)';
  }
}
