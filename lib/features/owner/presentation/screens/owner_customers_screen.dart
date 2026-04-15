import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/owner_provider.dart';

class OwnerCustomersScreen extends StatefulWidget {
  const OwnerCustomersScreen({super.key});

  @override
  State<OwnerCustomersScreen> createState() => _OwnerCustomersScreenState();
}

class _OwnerCustomersScreenState extends State<OwnerCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerProvider>().loadCustomers();
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
          'Customers',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<OwnerProvider>().loadCustomers(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<OwnerProvider>(
        builder: (context, ownerProvider, _) {
          if (ownerProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          final customers = ownerProvider.customers.where((c) {
            if (_searchQuery.isEmpty) return true;
            return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.phoneNumber.contains(_searchQuery);
          }).toList();

          return Column(
            children: [
              // Header & Search
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search by name, email, phone...',
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
                  ],
                ),
              ),

              // Statistics Banner (Small)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatBadge(
                        label: 'TRUSTED CLIENTS',
                        value: ownerProvider.totalCustomersCount.toString(),
                        icon: Icons.verified_user_rounded,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBadge(
                        label: 'ACTIVE CARTS',
                        value: ownerProvider.activeTrolleyCount.toString(),
                        icon: Icons.shopping_basket_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),

              // Results Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${customers.length} results',
                      style: TextStyle(
                        color: Colors.blueGrey.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Customer List
              Expanded(
                child: customers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty ? 'No customers yet' : 'No matches found',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF6366F1),
                        onRefresh: () => ownerProvider.loadCustomers(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                          physics: const BouncingScrollPhysics(),
                          itemCount: customers.length,
                          itemBuilder: (context, i) {
                            return _CustomerCompactCard(customer: customers[i]);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
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
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.blueGrey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerCompactCard extends StatelessWidget {
  final UserModel customer;
  const _CustomerCompactCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    final initials = customer.name.isNotEmpty 
      ? customer.name.split(' ').where((s) => s.isNotEmpty).map((s) => s[0].toUpperCase()).take(2).join()
      : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  customer.email,
                  style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (customer.phoneNumber.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      customer.phoneNumber,
                      style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: customer.isActive ? Colors.teal.shade50 : Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  customer.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: customer.isActive ? Colors.teal.shade700 : Colors.blueGrey.shade500,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Since ${AppUtils.formatDate(customer.createdAt)}',
                style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
