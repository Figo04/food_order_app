import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order/core/widgets/home/home_card_widget.dart';
import 'package:food_order/data/provider/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Color(0xFFECECEC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // pull to refresh
            ref.invalidate(homeProvider);
            await Future.delayed(const Duration(seconds: 1));
          },
          color: Colors.orange,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      height: 2,
                    ),
                  ),
                ),
                // home card widget
                const HomeCardWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row headerParts() {
    return Row(
      children: [
        const Text(
          "Food Order",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            height: 3,
          ),
        ),
      ],
    );
  }
}
