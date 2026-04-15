import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../models/order_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/order_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        elevation: 0,
      ),
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cartProvider, authProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartProvider.cartItems.length,
                          separatorBuilder: (context, index) => Divider(
                            color: AppTheme.dividerColor,
                          ),
                          itemBuilder: (context, index) {
                            final item = cartProvider.cartItems[index];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName),
                                      Text(
                                        '${item.quantity} × ${AppUtils.formatCurrency(item.price)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  AppUtils.formatCurrency(item.totalPrice),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Divider(color: AppTheme.dividerColor),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Payment Method
                Text(
                  'Payment Method',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    child: Column(
                      children: [
                        Icon(
                          Icons.qr_code_2,
                          size: 100,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Scan to Pay via UPI',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please scan the QR code using any UPI app to complete payment',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Placeholder for actual QR code
                        Container(
                          padding: const EdgeInsets.all(AppTheme.paddingMedium),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.dividerColor),
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium,
                            ),
                          ),
                          child:Column(
                            children: [
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: QrImageView(
                                    data: "upi://pay?pa=merchant@upi&pn=SmartTrolley&am=${cartProvider.totalPrice}&cu=INR",
                                    version: QrVersions.auto,
                                    size: 200.0,
                                    foregroundColor: AppTheme.primaryColor,
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Text(
                                'UPI ID: merchant@upi',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Amount to Pay
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount to Pay:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        AppUtils.formatCurrency(cartProvider.totalPrice),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Confirm Payment Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(context, cartProvider, authProvider);
                    },
                    child: const Text('Confirm Payment'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    CartProvider cartProvider,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount: ${AppUtils.formatCurrency(cartProvider.totalPrice)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Items will be delivered after successful payment confirmation.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final orderProvider = context.read<OrderProvider>();
              final orderId = const Uuid().v4();

              final orderItems = cartProvider.cartItems
                  .map(
                    (item) => OrderItemModel(
                      productId: item.productId,
                      productName: item.productName,
                      price: item.price,
                      quantity: item.quantity,
                      weight: item.weight,
                    ),
                  )
                  .toList();

              // Find the first valid ownerId from the items in the cart
              String? orderOwnerId;
              for (final item in cartProvider.cartItems) {
                if (item.ownerId != null && item.ownerId!.isNotEmpty) {
                  orderOwnerId = item.ownerId;
                  break;
                }
              }

              final order = OrderModel(
                orderId: orderId,
                userId: authProvider.currentUser?.uid ?? '',
                items: orderItems,
                total: cartProvider.totalPrice,
                status: OrderStatus.confirmed,
                paymentStatus: PaymentStatus.paid,
                createdAt: DateTime.now(),
                ownerId: orderOwnerId ?? 'SYSTEM',
              );

              final success = await orderProvider.createOrder(order);

              if (success) {
                // Only send checkout signal AFTER successful payment
                cartProvider.sendCheckoutSignal();
                await cartProvider.clearCart();

                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: const Text('Payment Successful'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.successColor,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text('Order ID: $orderId'),
                          const SizedBox(height: 8),
                          const Text(
                            'Your order has been placed successfully!',
                          ),
                        ],
                      ),
                      actions: [
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context)
                              ..pop() // Close success dialog
                              ..pop() // Close payment screen
                              ..pop(); // Back to home
                          },
                          child: const Text('Back to Home'),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        orderProvider.errorMessage ?? 'Failed to create order',
                      ),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Complete Payment'),
          ),
        ],
      ),
    );
  }
}
