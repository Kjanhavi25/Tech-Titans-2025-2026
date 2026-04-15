import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_utils.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Expanded(
            child: Container(
              color: AppTheme.dividerColor,
              child: product.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image_not_supported,
                        color: AppTheme.lightText,
                      ),
                    )
                  : Icon(
                      Icons.image_outlined,
                      color: AppTheme.lightText,
                    ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  AppUtils.formatCurrency(product.price),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (product.weight != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    AppUtils.formatWeight(product.weight),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final cartProvider = context.read<CartProvider>();
                      final success = await cartProvider.addToCart(product);
                      
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.productName} added to cart'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_shopping_cart, size: 16),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
