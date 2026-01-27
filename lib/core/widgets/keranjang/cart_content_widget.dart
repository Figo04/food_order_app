import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order/core/widgets/keranjang/cart_item_widget.dart';
import 'package:food_order/data/provider/cart_provider.dart';
import 'package:food_order/data/provider/cart_screen_provider.dart';
import 'package:food_order/core/widgets/keranjang/cart_payment_selector_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CartContentWidget extends ConsumerWidget {
  const CartContentWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final isLoading = ref.watch(isCheckoutLoadingProvider);
    final TextEditingController _costumerNameController =
        TextEditingController();
    final TextEditingController _notesController = TextEditingController();

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final total = ref.watch(cartFinalTotalProvider);

    return Stack(
      children: [
        // Scrollable Content
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cart Items list
              ...cart.items.map((item) => CartItemWidget(item: item)),

              const SizedBox(height: 10),

              Text(
                'Nama pelanggan (opsional)',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),

              const SizedBox(height: 9),

              // Customer Name Input )
              TextField(
                controller: _costumerNameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama pelanggan',
                  prefixIcon: Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
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
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Payment Method Selector
              const CartPaymentSelectorWidget(),

              const SizedBox(height: 24),

              // Price Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      'Subtotal',
                      formatter.format(cart.totalPrice),
                    ),
                    const SizedBox(height: 16),

                    _buildSummaryRow(
                      'Total',
                      formatter.format(total),
                      isBold: true,
                      valueColor: Colors.orange,
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // bottom checkout button
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => _handleCheckout(
                                context,
                                ref,
                                _costumerNameController,
                                _notesController,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLoading
                              ? Colors.white
                              : Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 122,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: Colors.black.withOpacity(0.1),
                          disabledBackgroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.orange,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Buat Pesanan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildSummaryRow(
  String label,
  String value, {
  bool isBold = false,
  Color? valueColor,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: isBold ? 16 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: isBold ? 18 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: valueColor ?? Colors.black87,
        ),
      ),
    ],
  );
}

// ==================== CHECKOUT HANDLER ====================

Future<void> _handleCheckout(
  BuildContext context,
  WidgetRef ref,
  TextEditingController _customerNameController,
  TextEditingController _notesController,
) async {
  final cart = ref.read(cartProvider);
  final paymentMethod = ref.read(selectedPaymentMethodProvider);
  final customerName = _customerNameController.text.trim();
  final orderNotes = _notesController.text.trim();

  // set loading
  ref.read(isCheckoutLoadingProvider.notifier).state = true;

  try {
    // generate order number
    final now = DateTime.now();
    final orderNumber =
        'ORD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    // Prepare Order Data
    final orderData = {
      'orderNumber': orderNumber,
      'customerName': customerName.isEmpty ? 'Guest' : customerName,
      'items': cart.items.map((item) => item.toMap()).toList(),
      'subtotal': cart.totalPrice,
      'total': ref.read(cartFinalTotalProvider),
      'status': 'pending',
      'paymentMethod': paymentMethod.label.toLowerCase(),
      'paymentStatus': 'unpaid',
      'orderNotes': orderNotes.isEmpty ? null : orderNotes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Save Order to Firestore
    await FirebaseFirestore.instance.collection('orders').add(orderData);

    // Clear Cart
    ref.read(cartProvider.notifier).clearCart();

    // Reset Customer Name and Notes
    _customerNameController.clear();
    _notesController.clear();

    // Reset Payment Method
    ref.read(selectedPaymentMethodProvider.notifier).state =
        PaymentMethod.tunai;

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan $orderNumber berhasil dibuat!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // navigator back to order screen
      context.go('/pesanan');
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat pesanan: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  } finally {
    ref.read(isCheckoutLoadingProvider.notifier).state = false;
  }
}
