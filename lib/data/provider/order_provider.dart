import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:food_order/data/models/order_model.dart';

// ==================== FIRESTORE PROVIDER ====================

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ==================== ORDERS STREAM PROVIDER ====================

// Provider untuk ambil semua orders dari Firebase (real-time)
// Sorted by createdAt descending (terbaru di atas)
final ordersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('orders')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList();
      });
});

// ==================== FILTER BY STATUS ====================

// StateProvider untuk filter status yang dipilih
final selectedOrdersStatusProvider = StateProvider<OrderStatus?>((ref) {
  return null; // null = semua status
});

// provider untuk filters orders berdasarkan status
final filteredOrdersProvider = Provider<AsyncValue<List<OrderModel>>>((ref) {
  final ordersAsync = ref.watch(ordersStreamProvider);
  final selectedStatus = ref.watch(selectedOrdersStatusProvider);

  return ordersAsync.whenData((orders) {
    if (selectedStatus == null) {
      return orders; // tampilkan semua
    }
    return orders.where((order) => order.status == selectedStatus).toList();
  });
});

// ==================== ORDER STATS ====================

// provider untuk stastistik orders
final orderStatsProvider = Provider<Map<String, int>>((ref) {
  final ordersAsync = ref.watch(ordersStreamProvider);

  return ordersAsync.when(
    data: (orders) {
      return {
        'total': orders.length,
        'pending': orders.where((o) => o.status == OrderStatus.pending).length,
        'processing': orders
            .where((o) => o.status == OrderStatus.processing)
            .length,
        'ready': orders.where((o) => o.status == OrderStatus.ready).length,
        'completed': orders
            .where((o) => o.status == OrderStatus.completed)
            .length,
      };
    },
    loading: () => {
      'total': 0,
      'pending': 0,
      'processing': 0,
      'ready': 0,
      'completed': 0,
    },
    error: (_, __) => {
      'total': 0,
      'pending': 0,
      'processing': 0,
      'ready': 0,
      'completed': 0,
    },
  );
});

// ==================== ORDER ACTIONS ====================

// provider untuk update status
final orderActionsProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);

  return OrderActions(firestore);
});

class OrderActions {
  final FirebaseFirestore _firestore;

  OrderActions(this._firestore);

  // update status order
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final updateData = {
      'status': newStatus.value,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // jika status jadi completed, tambahkan completedAt
    if (newStatus == OrderStatus.completed) {
      updateData['completedAt'] = FieldValue.serverTimestamp();
      updateData['paymentStatus'] = 'paid';
    }

    await _firestore.collection('orders').doc(orderId).update(updateData);
  }

  // delete order
  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).delete();
  }

  // update payment status
  Future<void> updatePaymentStatus(String orderId, String paymentStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'paymentStatus': paymentStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
