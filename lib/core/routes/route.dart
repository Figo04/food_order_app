import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order/core/routes/main_routes.dart';
import 'package:food_order/features/dashboard/home_screen.dart';
import 'package:food_order/features/keranjang/cart_screen.dart';
import 'package:food_order/features/pesanan/pesanan_screen.dart';
import 'package:food_order/features/product/menu_screen.dart';
import 'package:food_order/features/setting/setting_screen.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainRoutes(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'Home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/menu',
            name: 'Menu',
            builder: (context, state) => const MenuScreen(),
          ),
          GoRoute(
            path: '/keranjang',
            name: 'Keranjang',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/pesanan',
            name: 'Pesanan',
            builder: (context, state) => const PesananScreen(),
          ),
          GoRoute(
            path: '/setting',
            name: 'Setting',
            builder: (context, state) => const SettingScreen(),
          ),
        ],
      ),
    ],
  );
});
