import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshop/controllers/auth_controller.dart';
import 'package:petshop/models/product.dart';
import 'package:petshop/services/product_firestore_service.dart';
import 'package:petshop/view/admin/screens/add_edit_product_screen.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    if (!auth.isAdmin) return const Center(child: Text('Not authorized'));

    return StreamBuilder<List<Product>>(
      stream: ProductFirestoreService.getAllProductsAdminStream(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Error loading products'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snap.data!;
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(() => const AddEditProductScreen());
            },
            child: const Icon(Icons.add),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final p = items[i];

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: buildProductImage(p.primaryImage),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${p.category} • ${p.price.toStringAsFixed(0)} ${p.currency}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.isActive ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(
                              fontSize: 12,
                              color: p.isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Get.to(() => AddEditProductScreen(product: p));
                      },
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () async {
                        final ok = await ProductFirestoreService.deleteProduct(
                          p.id,
                        );
                        if (!ok) Get.snackbar('Error', 'Failed to delete');
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildProductImage(String path, {double size = 56}) {
    final isUrl = path.startsWith('http://') || path.startsWith('https://');

    if (isUrl) {
      return Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: Colors.black12,
          child: const Icon(Icons.image_not_supported),
        ),
      );
    }

    // asset
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: size,
        height: size,
        color: Colors.black12,
        child: const Icon(Icons.image_not_supported),
      ),
    );
  }
}
