import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_order/core/constant/apps_contans.dart';
import 'package:food_order/core/widgets/settings/setting_menu_form_widget.dart';
import 'package:intl/intl.dart';
import 'package:food_order/data/models/menu_model.dart';
import 'package:food_order/data/provider/setting_menu_provider.dart';

class SettingMenuItemWidget extends ConsumerWidget {
  final ProductModel product;

  const SettingMenuItemWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
                image: product.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product.imageUrl.isEmpty
                  ? Icon(
                      Icons.restaurant,
                      size: 36,
                      color: Colors.grey.shade400,
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // name & category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // price
                  Text(
                    formatter.format(product.price),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF6C00),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // stock & status
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Stock: ${product.stock}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.isAvailable ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: product.isAvailable
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // actions buttons
                  Row(
                    children: [
                      // edit button
                      Expanded(
                        child: _buildOutlineButton(
                          icon: Icons.edit_outlined,
                          label: 'edit',
                          onTap: () {
                            _showEditDialog(context, ref);
                          },
                        ),
                      ),

                      const SizedBox(width: 8),

                      // toggle inactive/active
                      Expanded(
                        child: _buildToggleButton(
                          context: context,
                          ref: ref,
                          isActive: product.isAvailable,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // delete button
                      _buildDeleteButton(context, ref),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== OUTLINE BUTTON ====================

  Widget _buildOutlineButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TOGGLE BUTTON (Aktifkan/Nonaktifkan) ====================

  Widget _buildToggleButton({
    required BuildContext context,
    required WidgetRef ref,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isActive ? null : AppsColor.primary,
        color: isActive ? Colors.grey.shade300 : null,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isActive
            ? null
            : [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleToggleAvailability(context, ref),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.play_arrow,
                  size: 16,
                  color: isActive ? Colors.grey.shade600 : Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  isActive ? 'Aktif' : 'Aktifkan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.grey.shade600 : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== TOGGLE AVAILABILITY HANDLER ====================

  void _handleToggleAvailability(BuildContext context, WidgetRef ref) async {
    final productActions = ref.read(productActionsProvider);

    try {
      await productActions.toggleAvailability(product.id, product.isAvailable);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              product.isAvailable ? 'Menu dinonaktifkan' : 'Menu diaktifkan',
            ),
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

  // ==================== DELETE BUTTON ====================

  Widget _buildDeleteButton(BuildContext context, WidgetRef ref) {
    return Material(
      child: InkWell(
        onTap: () => _showDeleteDialog(context, ref),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200, width: 1),
          ),
          child: Icon(
            Icons.delete_outline,
            size: 18,
            color: Colors.red.shade600,
          ),
        ),
      ),
    );
  }

  // ==================== DELETE DIALOG ====================

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Menu'),
        content: Text(
          'Yakin ingin menghapus "${product.name}"?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade700)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final productActions = ref.read(productActionsProvider);

              try {
                await productActions.deleteProduct(product.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menu berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EDIT DIALOG (Placeholder) ====================

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingMenuFormWidget(product: product),
    );
  }
}
