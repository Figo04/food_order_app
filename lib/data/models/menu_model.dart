import 'package:cloud_firestore/cloud_firestore.dart';

// ==================== ENUMS ====================

enum ProductCategory {
  semua('Semua', 'all'),
  makanan('Makanan', 'makanan'),
  minuman('Minuman', 'minuman'),
  cemilan('Snack', 'snack');

  final String label;
  final String value;

  const ProductCategory(this.label, this.value);

  // Convert string to enum
  static ProductCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'all':
        return ProductCategory.semua;
      case 'makanan':
        return ProductCategory.makanan;
      case 'minuman':
        return ProductCategory.minuman;
      case 'snack':
        return ProductCategory.cemilan;
      default:
        return ProductCategory.semua;
    }
  }
}

// ==================== PRODUCT MODEL ====================

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final int stock;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor
  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory Method untuk convert dari firestore
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      stock: data['stock'] as int? ?? 0,
      isAvailable: data['isAvailable'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'stock': stock,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with method untuk udpate data
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    int? stock,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // check apakah stock habis
  bool get isOutOfStock => stock <= 0;

  // check apakah produk aktif dan ready
  bool get isReady => isAvailable && !isOutOfStock;

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, description: $description, price: $price, category: $category, imageUrl: $imageUrl, stock: $stock, isAvailable: $isAvailable, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

