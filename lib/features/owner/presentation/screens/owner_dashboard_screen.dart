import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/owner_provider.dart';
import '../../../../providers/product_provider.dart';
import 'owner_add_product_screen.dart';
import 'owner_products_screen.dart';
import 'owner_customers_screen.dart';
import 'owner_order_details_screen.dart';
import '../../../../models/order_model.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _DashboardTab(),
    OwnerProductsScreen(),
    OwnerCustomersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerProvider>().loadDashboardData();
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: Colors.blueGrey.shade400,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              activeIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF6366F1)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded, color: Color(0xFF6366F1)),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_alt_rounded, color: Color(0xFF6366F1)),
              label: 'Customers',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final ownerName = authProvider.currentUser?.name ?? 'Owner';
    final today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: RefreshIndicator(
        color: const Color(0xFF6366F1),
        onRefresh: () async {
          await context.read<OwnerProvider>().loadDashboardData();
          await context.read<ProductProvider>().loadProducts();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AppBar with Greeting
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFF6366F1),
              elevation: 0,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                    onPressed: () {
                      context.read<OwnerProvider>().loadDashboardData();
                      context.read<ProductProvider>().loadProducts();
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    offset: const Offset(0, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    icon: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 22),
                    onSelected: (v) async {
                      if (v == 'logout') {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(40),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withAlpha(60)),
                                    ),
                                    child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'SMART TROLLEY OWNER',
                                          style: TextStyle(
                                            color: Colors.white.withAlpha(180),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Hello, $ownerName',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                today,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Consumer2<OwnerProvider, ProductProvider>(
                builder: (context, ownerProvider, productProvider, _) {
                  if (ownerProvider.isLoading) {
                    return const SizedBox(
                      height: 400,
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                      ),
                    );
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error banner
                        if (ownerProvider.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ownerProvider.errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Performance Highlights
                        _PerformanceSection(
                          dailySales: ownerProvider.dailySalesTotal,
                          dailyOrders: ownerProvider.dailyOrdersCount,
                        ),
                        const SizedBox(height: 24),

                        // Key Metrics Grid
                        const Text(
                          'Business Overview',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.3,
                          children: [
                            _MetricCard(
                              title: 'Revenue',
                              value: AppUtils.formatCurrency(ownerProvider.totalRevenue),
                              icon: Icons.account_balance_wallet_rounded,
                              color: const Color(0xFF6366F1),
                              bgGradient: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                            ),
                            _MetricCard(
                              title: 'Trolleys',
                              value: ownerProvider.activeTrolleyCount.toString(),
                              icon: Icons.shopping_cart_rounded,
                              color: const Color(0xFF10B981),
                              bgGradient: [const Color(0xFF10B981), const Color(0xFF047857)],
                            ),
                            _MetricCard(
                              title: 'Customers',
                              value: ownerProvider.totalCustomersCount.toString(),
                              icon: Icons.people_alt_rounded,
                              color: const Color(0xFFF59E0B),
                              bgGradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                            ),
                            _MetricCard(
                              title: 'Inventory',
                              value: productProvider.products.length.toString(),
                              icon: Icons.inventory_2_rounded,
                              color: const Color(0xFFEC4899),
                              bgGradient: [const Color(0xFFEC4899), const Color(0xFFDB2777)],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Actions Section
                        const Text(
                          'Operation Center',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _DashboardAction(
                                label: 'New Product',
                                icon: Icons.add_box_rounded,
                                color: const Color(0xFF6366F1),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const OwnerAddProductScreen()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _DashboardAction(
                                label: 'Manage Stock',
                                icon: Icons.inventory_rounded,
                                color: const Color(0xFF10B981),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const OwnerProductsScreen()),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _DashboardAction(
                          label: 'Customer Insights',
                          icon: Icons.analytics_rounded,
                          color: const Color(0xFFF59E0B),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OwnerCustomersScreen()),
                          ).then((_) => context.read<OwnerProvider>().loadDashboardData()),
                        ),
                        
                        const SizedBox(height: 30),

                        // Detailed Stats Card
                        _SummaryDetails(
                          totalRevenue: ownerProvider.totalRevenue,
                          totalOrders: ownerProvider.totalOrdersCount,
                        ),
                        const SizedBox(height: 30),

                        // Recent Orders Section
                        _RecentOrdersSection(orders: ownerProvider.recentOrders),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentOrdersSection extends StatelessWidget {
  final List<OrderModel> orders;
  const _RecentOrdersSection({required this.orders});

  @override
  Widget build(BuildContext context) {
    // Only show the 5 most recent for the dashboard
    final recent = orders.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            if (orders.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Link to full orders list if exists
                },
                child: const Text('View All', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long_rounded, size: 40, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No orders placed yet', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          )
        else
          ...recent.map((order) => _OrderDashboardCard(order: order)),
      ],
    );
  }
}

class _OrderDashboardCard extends StatelessWidget {
  final OrderModel order;
  const _OrderDashboardCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => OwnerOrderDetailsScreen(order: order)),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withAlpha(15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.receipt_rounded, color: Color(0xFF6366F1), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.orderId.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM d, hh:mm a').format(order.createdAt),
                        style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppUtils.formatCurrency(order.total),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.items.length == 1 ? '1 item' : '${order.items.length} items',
                      style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: Colors.blueGrey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PerformanceSection extends StatelessWidget {
  final double dailySales;
  final int dailyOrders;
  const _PerformanceSection({required this.dailySales, required this.dailyOrders});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Icon(Icons.trending_up_rounded, color: Colors.green.withAlpha(15), size: 150),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.flash_on_rounded, color: Color(0xFF6366F1), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Today's Velocity",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DAILY SALES',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blueGrey.shade400,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppUtils.formatCurrency(dailySales),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.blueGrey.shade100,
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDERS',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blueGrey.shade400,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dailyOrders.toString(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
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
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final List<Color> bgGradient;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueGrey.shade100),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgGradient[0].withAlpha(40), bgGradient[1].withAlpha(40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withAlpha(30)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color.withAlpha(100), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryDetails extends StatelessWidget {
  final double totalRevenue;
  final int totalOrders;

  const _SummaryDetails({
    required this.totalRevenue,
    required this.totalOrders,
  });

  @override
  Widget build(BuildContext context) {
    final avgOrder = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LIFETIME PERFORMANCE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryMetric(
                label: 'Total Rev',
                value: AppUtils.formatCurrencyShort(totalRevenue),
              ),
              _SummaryMetric(
                label: 'Orders',
                value: totalOrders.toString(),
              ),
              _SummaryMetric(
                label: 'Avg Tick',
                value: AppUtils.formatCurrencyShort(avgOrder),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withAlpha(120),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
