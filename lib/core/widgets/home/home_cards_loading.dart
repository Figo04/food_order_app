import 'package:flutter/material.dart';

class HomeCardsLoading extends StatelessWidget {
  const HomeCardsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(flex: 3, child: _buildShimmerCard(height: 140)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerCard(height: 120)),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerCard(height: 120)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange, strokeWidth: 2),
            const SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
