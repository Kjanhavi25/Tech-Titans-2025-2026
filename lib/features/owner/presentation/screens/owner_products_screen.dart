import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../models/product_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/product_provider.dart';
import '../../../../services/qr_service.dart';
import 'owner_add_product_screen.dart';

class OwnerProductsScreen extends StatefulWidget {
  const OwnerProductsScreen({super.key});

  @override
  State<OwnerProductsScreen> createState() => _OwnerProductsScreenState();
}

class _OwnerProductsScreenState extends State<OwnerProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: const Text(
          'Inventory',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
            tooltip: 'Add Product',
            onPressed: () => _navigateToAddProduct(context),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (v) async {
              if (v == 'logout') {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'logout', child: Row(
                children: [
                   Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                   SizedBox(width: 8),
                   Text('Logout'),
                ],
              )),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          final categories = ['All', ...productProvider.getCategories()];

          // Filter
          final filtered = productProvider.products.where((p) {
            final matchSearch = _searchQuery.isEmpty ||
                p.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.productId.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchCat = _selectedCategory == 'All' || p.category == _selectedCategory;
            return matchSearch && matchCat;
          }).toList();

          return Column(
            children: [
              // Search + Filter Bar
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search product name or ID...',
                        hintStyle: TextStyle(color: Colors.white.withAlpha(150)),
                        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white),
                        suffixIcon: _searchQuery.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                        filled: true,
                        fillColor: Colors.white.withAlpha(30),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = categories[i];
                          final isSelected = cat == _selectedCategory;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.white.withAlpha(20),
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Results Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} products found',
                      style: TextStyle(
                        color: Colors.blueGrey.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (productProvider.isLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),

              // Product List
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(isSearch: _searchQuery.isNotEmpty)
                    : RefreshIndicator(
                        onRefresh: () => productProvider.loadProducts(),
                        color: const Color(0xFF6366F1),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            return _ProductListItem(
                              product: filtered[i],
                              onEdit: () => _navigateToEditProduct(context, filtered[i]),
                              onDelete: () => _confirmDelete(context, filtered[i]),
                              onViewQR: () => _showQRDialog(context, filtered[i]),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddProduct(context),
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }

  void _navigateToAddProduct(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OwnerAddProductScreen()),
    );
    if (result == true && mounted) {
      context.read<ProductProvider>().loadProducts();
    }
  }

  void _navigateToEditProduct(BuildContext context, ProductModel product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OwnerAddProductScreen(product: product)),
    );
    if (result == true && mounted) {
      context.read<ProductProvider>().loadProducts();
    }
  }

  void _confirmDelete(BuildContext context, ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Product?'),
        content: Text('This will permanently remove "${product.productName}" from your inventory.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<ProductProvider>().deleteProduct(product.productId);
    }
  }

  void _showQRDialog(BuildContext context, ProductModel product) {
    final qrData = QRService.generateQRData(product);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ID: ${product.productId}',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppUtils.formatCurrency(product.price),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scan to add to cart',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewQR;

  const _ProductListItem({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onViewQR,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              Container(
                width: 100,
                color: Colors.grey.shade50,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _CategoryIcon(category: product.category),
                      )
                    : _CategoryIcon(category: product.category),
              ),
              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.productName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: product.quantity > 0 ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.quantity > 0 ? 'Stock: ${product.quantity}' : 'Out of Stock',
                              style: TextStyle(
                                color: product.quantity > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppUtils.formatCurrency(product.price),
                            style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Row(
                            children: [
                              _ActionButton(
                                icon: Icons.qr_code_rounded,
                                color: const Color(0xFF6366F1),
                                onTap: onViewQR,
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.edit_rounded,
                                color: Colors.teal,
                                onTap: onEdit,
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.delete_outline_rounded,
                                color: Colors.pinkAccent,
                                onTap: onDelete,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String category;
  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    switch (category.toLowerCase()) {
      case 'fruits & vegetables': iconData = Icons.eco_rounded; break;
      case 'dairy & eggs': iconData = Icons.egg_alt_rounded; break;
      case 'bakery': iconData = Icons.bakery_dining_rounded; break;
      case 'beverages': iconData = Icons.local_drink_rounded; break;
      case 'snacks': iconData = Icons.cookie_rounded; break;
      case 'frozen foods': iconData = Icons.ac_unit_rounded; break;
      case 'meat & seafood': iconData = Icons.set_meal_rounded; break;
      default: iconData = Icons.inventory_2_rounded;
    }
    return Icon(iconData, color: Colors.grey.shade300, size: 40);
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearch;
  const _EmptyState({required this.isSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearch ? Icons.search_off_rounded : Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isSearch ? 'No products found' : 'Your inventory is empty',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch ? 'Try a different search term' : 'Start by adding your first product',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
