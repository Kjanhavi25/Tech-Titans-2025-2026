import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../providers/order_provider.dart';
import '../../../../providers/product_provider.dart';
import '../../../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadAllOrders();
      context.read<OrderProvider>().loadTotalRevenue();
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
            onPressed: () {
              Navigator.of(context).pushNamed('/admin-add-product');
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (v) async {
              if (v == 'logout') {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Consumer2<OrderProvider, ProductProvider>(
              builder: (context, orderProvider, productProvider, _) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _StatCard(
                      title: 'Total Orders',
                      value: orderProvider.getTotalOrdersCount().toString(),
                      icon: Icons.shopping_bag_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    _StatCard(
                      title: 'Pending Orders',
                      value: orderProvider.getPendingOrdersCount().toString(),
                      icon: Icons.hourglass_bottom_outlined,
                      color: AppTheme.warningColor,
                    ),
                    _StatCard(
                      title: 'Total Products',
                      value: productProvider.products.length.toString(),
                      icon: Icons.inventory_2_outlined,
                      color: AppTheme.successColor,
                    ),
                    _StatCard(
                      title: 'Revenue',
                      value: AppUtils.formatCurrency(orderProvider.totalRevenue),
                      icon: Icons.trending_up_outlined,
                      color: AppTheme.accentColor,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            // Revenue & Average Order
            Consumer<OrderProvider>(
              builder: (context, orderProvider, _) {
                return Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Revenue',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppUtils.formatCurrency(
                                  orderProvider.totalRevenue,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: AppTheme.primaryColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Avg Order Value',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppUtils.formatCurrency(
                                  orderProvider.getAverageOrderValue(),
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: AppTheme.secondaryColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            // Recent Orders
            Text(
              'Recent Orders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Consumer<OrderProvider>(
              builder: (context, orderProvider, _) {
                final orders = orderProvider.allOrders.take(5).toList();

                if (orders.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      child: Text(
                        'No orders yet',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order ID: ${order.orderId.substring(0, 8)}',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    '${order.items.length} items - ${AppUtils.formatCurrency(order.total)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.status.toString().split('.').last,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            // Manage Products
            Text(
              'Manage Products',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/admin-add-product');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Product'),
              ),
            ),
            const SizedBox(height: 12),
            Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/admin-products');
                    },
                    icon: const Icon(Icons.list),
                    label: Text(
                      'View All Products (${productProvider.products.length})',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
