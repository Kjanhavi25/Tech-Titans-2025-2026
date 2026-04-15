import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../models/order_model.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/order_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppTheme.lightText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartProvider.cartItems.length,
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  itemBuilder: (context, index) {
                    final item = cartProvider.cartItems[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppUtils.formatCurrency(item.price),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      cartProvider.decreaseQuantity(item);
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        cartProvider.decreaseQuantity(item);
                                      },
                                      constraints: const BoxConstraints.tightFor(
                                        width: 40,
                                        height: 40,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppTheme.dividerColor,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item.quantity.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        cartProvider.increaseQuantity(item);
                                      },
                                      constraints: const BoxConstraints.tightFor(
                                        width: 40,
                                        height: 40,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                                Text(
                                  AppUtils.formatCurrency(item.totalPrice),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.dividerColor),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Items: ${cartProvider.cartItems.length}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          'Total Weight: ${AppUtils.formatWeight(cartProvider.getTotalWeight())}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount:',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          AppUtils.formatCurrency(cartProvider.totalPrice),
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/payment');
                        },
                        child: const Text('Proceed to Payment'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
