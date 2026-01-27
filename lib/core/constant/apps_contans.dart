import 'package:flutter/material.dart';
import 'package:food_order/data/models/menu_model.dart';

class AppsColor {
  static const primary = LinearGradient(
    colors: [
      Color(0xFFEF6C00), // Orange shade 800
      Color(0xFFFFAB40), // Orange Accent shade 400
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

IconData categoryIcon(ProductCategory category) {
  switch (category) {
    case ProductCategory.All:
      return Icons.grid_view_outlined;
    case ProductCategory.Makanan:
      return Icons.restaurant_menu_outlined;
    case ProductCategory.Minuman:
      return Icons.local_cafe_outlined;
    case ProductCategory.Cemilan:
      return Icons.cookie_outlined;
  }
}
