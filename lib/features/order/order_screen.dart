import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order/core/constant/apps_contans.dart';
import 'package:food_order/core/widgets/order/order_empty_widget.dart';
import 'package:food_order/core/widgets/order/order_item_widget.dart';
import 'package:food_order/data/models/order_model.dart';
import 'package:food_order/data/provider/order_provider.dart';

class OrderScreen extends ConsumerWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredOrdersAsync = ref.watch(filteredOrdersProvider);
    final selectedStatus = ref.watch(selectedOrdersStatusProvider);
    final stats = ref.watch(orderStatsProvider);

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
              'Pesanan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (stats['total']! > 0)
              Text(
                '${stats['total']} total pesanan',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // filter tabs
          if (stats['total']! > 0) _buildFilterTabs(ref, selectedStatus, stats),

          // Order list
          Expanded(
            child: filteredOrdersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return const OrderEmptyWidget();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(ordersStreamProvider);
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  color: const Color(0xFFEF6C00),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderItemWidget();
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFEF6C00)),
              ),
              error: (error, stackTrace) => Center(
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
                      'Gagal memuat pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(ordersStreamProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF6C00),
                      ),
                      child: const Text('coba lagi'),
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

// ==================== FILTER TABS ====================

Widget _buildFilterTabs(
  WidgetRef ref,
  OrderStatus? selectedStatus,
  Map<String, int> stats,
) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            ref: ref,
            label: 'Semua',
            count: stats['total']!,
            status: null,
            isSelected: selectedStatus == null,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            ref: ref,
            label: 'Pending',
            count: stats['pending']!,
            status: OrderStatus.pending,
            isSelected: selectedStatus == OrderStatus.pending,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            ref: ref,
            label: 'Diproses',
            count: stats['processing']!,
            status: OrderStatus.processing,
            isSelected: selectedStatus == OrderStatus.processing,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            ref: ref,
            label: 'Ready',
            count: stats['ready']!,
            status: OrderStatus.ready,
            isSelected: selectedStatus == OrderStatus.ready,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            ref: ref,
            label: 'Selesai',
            count: stats['completed']!,
            status: OrderStatus.completed,
            isSelected: selectedStatus == OrderStatus.completed,
          ),
        ],
      ),
    ),
  );
}

Widget _buildFilterChip({
  required WidgetRef ref,
  required String label,
  required int count,
  required OrderStatus? status,
  required bool isSelected,
}) {
  return GestureDetector(
    onTap: () {
      ref.read(selectedOrdersStatusProvider.notifier).state = status;
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: isSelected ? AppsColor.primary : null,
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}
