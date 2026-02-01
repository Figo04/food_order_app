import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:food_order/data/models/order_model.dart';
import 'package:food_order/core/constant/apps_contans.dart';
import 'package:food_order/data/provider/order_provider.dart';

class OrderItemWidget extends ConsumerWidget {
  final OrderModel order;

  const OrderItemWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header: order number & status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppsColor.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Order Number
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormatter.format(order.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ],
                ),

                // Status Badge
                _buildStatusBadge(order.status),
              ],
            ),
          ),

          // body: items & customer
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // customer Name
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.customerName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // items list
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity} x ${item.productName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatter.format(item.subTotal),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      formatter.format(order.total),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Payment info & Actions
                Row(
                  children: [
                    // Left: payment Status & menthod
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Payment Status
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: order.paymentStatus == 'paid'
                                      ? Colors.green
                                      : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                order.paymentStatus == 'paid'
                                    ? 'Sudah Bayar'
                                    : 'Belum Bayar',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: order.paymentStatus == 'paid'
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Payment Method
                          Text(
                            _getPaymentMethodLabel(order.paymentMethod),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right: Bayar & Lanjut Buttons
                    if (order.paymentStatus != 'paid') ...[
                      _buildSmallButton(
                        label: 'Bayar',
                        color: Colors.green,
                        onTap: () => _handlePayment(context, ref, order),
                      ),
                      const SizedBox(width: 8),
                    ],

                    if (order.status != OrderStatus.completed)
                      _buildSmallButton(
                        label: 'Lanjut',
                        gradient: AppsColor.primary,
                        onTap: () => _handleNext(context, ref, order),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Footer: Action Buttons
        ],
      ),
    );
  }
}

// ==================== SMALL BUTTON (Bayar/Lanjut) ====================

Widget _buildSmallButton({
  required String label,
  Color? color,
  Gradient? gradient,
  required VoidCallback onTap,
}) {
  return Container(
    decoration: BoxDecoration(
      gradient: gradient,
      color: gradient == null ? color : null,
      borderRadius: BorderRadius.circular(17),
      boxShadow: [
        BoxShadow(
          color: (color ?? Colors.orange).withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}

// ==================== PAYMENT METHOD LABEL ====================

String _getPaymentMethodLabel(String method) {
  switch (method.toLowerCase()) {
    case 'cash':
    case 'tunai':
      return 'Tunai';
    case 'qris':
      return 'QRIS';
    case 'transfer':
      return 'Transfer Bank';
    default:
      return method;
  }
}

// ==================== PAYMENT HANDLER ====================

void _handlePayment(BuildContext context, WidgetRef ref, dynamic order) async {
  final orderActions = ref.read(orderActionsProvider);

  try {
    // Update payment status to paid
    await orderActions.updatePaymentStatus(order.id, 'paid');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil dikonfirmasi'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

// ==================== NEXT HANDLER ====================

void _handleNext(BuildContext context, WidgetRef ref, dynamic order) async {
  final orderActions = ref.read(orderActionsProvider);

  // Tentukan next status
  OrderStatus nextStatus = OrderStatus.pending;
  switch (order.status) {
    case OrderStatus.pending:
      nextStatus = OrderStatus.processing;
      break;
    case OrderStatus.processing:
      nextStatus = OrderStatus.ready;
      break;
    case OrderStatus.ready:
      nextStatus = OrderStatus.completed;
      break;
    case OrderStatus.completed:
      return; // Sudah selesai
  }

  try {
    await orderActions.updateOrderStatus(order.id, nextStatus);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status diubah menjadi ${nextStatus.label}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

// ==================== STATUS BADGE ====================

Widget _buildStatusBadge(OrderStatus status) {
  Color bgColor;
  Color textColor;

  switch (status) {
    case OrderStatus.pending:
      bgColor = Colors.orange.shade100;
      textColor = Colors.black87;
      break;
    case OrderStatus.processing:
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
      break;
    case OrderStatus.ready:
      bgColor = Colors.blue.shade100;
      textColor = Colors.blue.shade700;
      break;
    case OrderStatus.completed:
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(Icons.access_time, size: 16, color: textColor),
        const SizedBox(width: 4),
        Text(
          status.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}
