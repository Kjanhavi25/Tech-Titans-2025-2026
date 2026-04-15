import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../providers/product_provider.dart';
import '../../../../models/product_model.dart';
import 'admin_add_product_screen.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AdminAddProductScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = productProvider.products;

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: AppTheme.lightText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products yet',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdminAddProductScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductListItem(product: product);
            },
          );
        },
      ),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  final ProductModel product;

  const _ProductListItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTheme.paddingSmall),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          child: SizedBox(
            width: 60,
            height: 60,
            child: product.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.dividerColor,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.dividerColor,
                      child: Icon(Icons.image_not_supported,
                          color: AppTheme.lightText),
                    ),
                  )
                : Container(
                    color: AppTheme.dividerColor,
                    child: Icon(Icons.inventory_2_outlined,
                        color: AppTheme.lightText),
                  ),
          ),
        ),
        title: Text(
          product.productName,
          style: Theme.of(context).textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppUtils.formatCurrency(product.price),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              product.category,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppTheme.primaryColor,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AdminAddProductScreen(product: product),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppTheme.errorColor,
              onPressed: () {
                _confirmDelete(context, product);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.productName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final productProvider = context.read<ProductProvider>();
              final success =
                  await productProvider.deleteProduct(product.productId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '${product.productName} deleted'
                          : productProvider.errorMessage ?? 'Delete failed',
                    ),
                    backgroundColor:
                        success ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
