import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order/data/provider/cart_screen_provider.dart';

class CartPaymentSelectorWidget extends ConsumerWidget {
  const CartPaymentSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(selectedPaymentMethodProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih metode pembayaran',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Payment Methods List
        Row(
          children: PaymentMethod.values.map((method) {
            final isSelected = method == selectedMethod;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _PaymentMethodCard(
                  method: method,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(selectedPaymentMethodProvider.notifier).state =
                        method;
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ==================== PAYMENT METHOD CARD ====================

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PaymentMethodCard({
    required this.method,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.orange.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                method.icon,
                color: isSelected ? Colors.orange : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              method.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.orange : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
