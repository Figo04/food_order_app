import 'package:cloud_firestore/cloud_firestore.dart';

// ==================== ORDER STATUS ENUM ====================

enum OrderStatus {
  pending('Menunggu', 'pending'),
  processing('Diproses', 'processing'),
  ready('Siap', 'ready'),
  completed('Selesai', 'completed');

  final String label;
  final String value;

  const OrderStatus(this.label, this.value);

  // convert string ke enum
  static OrderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'menunggu':
        return OrderStatus.pending;
      case 'diproses':
        return OrderStatus.processing;
      case 'siap':
        return OrderStatus.ready;
      case 'selesai':
        return OrderStatus.completed;
      default:
        return OrderStatus.pending;
    }
  }
}

// ==================== ORDER ITEM MODEL ====================

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double subTotal;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subTotal,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['product_id'] as String? ?? '',
      productName: map['product_name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 0,
      subTotal: (map['sub_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'sub_total': subTotal,
    };
  }
}

// ==================== ORDER MODEL ====================

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final List<OrderItem> items;
  final double subTotal;
  final double total;
  final OrderStatus status;
  final String paymentMethod;
  final String paymentStatus;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.items,
    required this.subTotal,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.completedAt,
  });

  // factory method dari firestore
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      orderNumber: data['order_number'] as String? ?? '',
      customerName: data['customer_name'] as String? ?? 'Guest',
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subTotal: (data['sub_total'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.fromString(data['status'] as String? ?? 'pending'),
      paymentMethod: data['payment_method'] as String? ?? 'cash',
      paymentStatus: data['payment_status'] as String? ?? 'unpaid',
      note: data['note'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completed_at'] as Timestamp?)?.toDate(),
    );
  }
  // convert ke map untuk firestore
  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'customerName': customerName,
      'items': items.map((item) => item.toMap()).toList(),
      'subTotal': subTotal,
      'total': total,
      'status': status.value,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'note': note,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'completed_at': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  // copywith method
  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerName,
    List<OrderItem>? items,
    double? subTotal,
    double? total,
    OrderStatus? status,
    String? paymentMethod,
    String? paymentStatus,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Total items
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  String toString() {
    return 'OrderModel(id: $id, orderNumber: $orderNumber, customerName: $customerName, items: $items, subTotal: $subTotal, total: $total, status: $status, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, completedAt: $completedAt)';
  }
}
