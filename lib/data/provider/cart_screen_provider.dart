import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:food_order/data/provider/cart_provider.dart';

// ==================== PAYMENT METHOD ====================

enum PaymentMethod {
  tunai('Tunai', Icons.money),
  transfer('Transfer', Icons.credit_card),
  qris('Qris', Icons.qr_code_2);

  final String label;
  final IconData icon;

  const PaymentMethod(this.label, this.icon);
}

// final untuk paymentMethod yang dipilih
final selectedPaymentMethodProvider = StateProvider<PaymentMethod>((ref) {
  return PaymentMethod.tunai;
});

// ==================== CUSTOMER INFO ====================

// Provider untuk nama pelanggan (optional)
final customerNameProvider = StateProvider<String>((ref) {
  return '';
});

// Provider untuk catatan pesanan (optional)
final orderNotesProvider = StateProvider<String>((ref) {
  return '';
});

// ==================== CART SUMMARY ====================

// provider untuk subtotal harga (dari cartprovider)
final cartSubTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalPrice;
});

// Provider untuk pajak (optional, contoh 10%)
final cartTaxProvider = Provider<double>((ref) {
  final subTotal = ref.watch(cartSubTotalProvider);
  return subTotal * 0.0;
});

// provider untuk diskon (optional)
final cartDiscountProvider = StateProvider<double>((ref) {
  return 0.0;
});

// provider untuk total akhir
final cartFinalTotalProvider = Provider<double>((ref) {
  final subTotal = ref.watch(cartSubTotalProvider);
  final tax = ref.watch(cartTaxProvider);
  final discount = ref.watch(cartDiscountProvider);

  return subTotal + tax - discount;
});

// ==================== VALIDATION ====================

// Provider untuk validasi apakah bisa checkout
final canCheckoutProvider = Provider<bool>((ref) {
  final cart = ref.watch(cartProvider);
  final paymentMethod = ref.watch(selectedPaymentMethodProvider);
  return !cart.isEmpty;
});

// ==================== CHECKOUT LOADING STATE ====================

final isCheckoutLoadingProvider = StateProvider<bool>((ref) {
  return false;
});
