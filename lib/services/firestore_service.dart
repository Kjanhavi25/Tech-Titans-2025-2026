import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ PRODUCTS ============

  Future<List<ProductModel>> getAllProducts([String? ownerId]) async {
    try {
      Query query = _firestore.collection('products');
      
      if (ownerId != null && ownerId.isNotEmpty) {
        query = query.where('ownerId', isEqualTo: ownerId.trim());
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          return ProductModel.fromJson(data);
        } catch (e) {
          debugPrint('Error parsing product: $e');
          return null;
        }
      })
      .whereType<ProductModel>()
      .where((p) => p.isActive)
      .toList(); 
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<ProductModel?> getProduct(String productId, [String? ownerId]) async {
    try {
      // 1. Try composite ID (ownerId_productId) for multi-owner isolation
      if (ownerId != null && ownerId.isNotEmpty) {
        final compositeId = "${ownerId.trim()}_${productId.trim()}";
        final doc = await _firestore.collection('products').doc(compositeId).get();
        if (doc.exists) {
          return ProductModel.fromJson(doc.data() as Map<String, dynamic>);
        }
      }

      // 2. Fallback to raw ID (for legacy data or system products)
      final doc = await _firestore.collection('products').doc(productId.trim()).get();
      if (doc.exists) {
        return ProductModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  Stream<List<ProductModel>> getProductsStream([String? ownerId]) {
    Query query = _firestore.collection('products');
    
    if (ownerId != null && ownerId.isNotEmpty) {
      query = query.where('ownerId', isEqualTo: ownerId.trim());
    }

    return query.snapshots().map((snapshot) {
      final List<ProductModel> products = [];
      for (var doc in snapshot.docs) {
        try {
          final product = ProductModel.fromJson(doc.data() as Map<String, dynamic>);
          if (product.isActive) {
            products.add(product);
          }
        } catch (e) {
          debugPrint('Skipping corrupt product: $e');
        }
      }
      return products;
    });
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      // For multi-owner isolation, use ownerId_productId as doc ID
      final docId = (product.ownerId != null && product.ownerId!.isNotEmpty)
          ? "${product.ownerId!.trim()}_${product.productId.trim()}"
          : product.productId.trim();
          
      await _firestore.collection('products').doc(docId).set(product.toJson());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      final docId = (product.ownerId != null && product.ownerId!.isNotEmpty)
          ? "${product.ownerId!.trim()}_${product.productId.trim()}"
          : product.productId.trim();

      await _firestore
          .collection('products')
          .doc(docId)
          .update(product.toJson());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId, [String? ownerId]) async {
    try {
      final docId = (ownerId != null && ownerId.isNotEmpty)
          ? "${ownerId.trim()}_${productId.trim()}"
          : productId.trim();

      await _firestore.collection('products').doc(docId).update({'isActive': false});
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // ============ CART ============

  Stream<List<CartItemModel>> getCartStream(String userId) {
    return _firestore
        .collection('carts')
        .doc(userId)
        .collection('items')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CartItemModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<CartItemModel>> getCart(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();

      return snapshot.docs
          .map((doc) => CartItemModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  Future<void> addToCart(CartItemModel cartItem) async {
    try {
      await _firestore
          .collection('carts')
          .doc(cartItem.userId)
          .collection('items')
          .doc(cartItem.cartItemId)
          .set(cartItem.toJson());
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<void> updateCartItem(CartItemModel cartItem) async {
    try {
      await _firestore
          .collection('carts')
          .doc(cartItem.userId)
          .collection('items')
          .doc(cartItem.cartItemId)
          .update(cartItem.toJson());
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  Future<void> removeFromCart(String userId, String cartItemId) async {
    try {
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(cartItemId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      WriteBatch batch = _firestore.batch();
      QuerySnapshot snapshot = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();

      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // ============ ORDERS ============

  Future<void> createOrder(OrderModel order) async {
    try {
      await _firestore.collection('orders').doc(order.orderId).set(order.toJson());
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('orders').where('userId', isEqualTo: userId);
      
      QuerySnapshot snapshot = await query.get();

      List<OrderModel> orders = snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Sort in-memory to avoid requiring a composite index
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return orders;
    } catch (e) {
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  Future<OrderModel?> getOrder(String orderId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('orders').doc(orderId).get();

      if (!doc.exists) return null;

      return OrderModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  Future<void> updateOrder(OrderModel order) async {
    try {
      await _firestore.collection('orders').doc(order.orderId).update(order.toJson());
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  Future<List<OrderModel>> getAllOrders([String? ownerId]) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('orders');
      
      if (ownerId != null) {
        query = query.where('ownerId', isEqualTo: ownerId);
      }

      QuerySnapshot snapshot = await query.get();

      List<OrderModel> orders = snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      
      // Sort in-memory to avoid requiring a composite index
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return orders;
    } catch (e) {
      throw Exception('Failed to fetch all orders: $e');
    }
  }

  Future<double> getTotalRevenue([String? ownerId]) async {
    try {
      if (ownerId == null || ownerId.isEmpty) return 0.0;
      
      Query<Map<String, dynamic>> query = _firestore.collection('orders')
          .where('ownerId', isEqualTo: ownerId.trim());
      
      QuerySnapshot snapshot = await query.get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['total'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      debugPrint('Error fetching revenue: $e');
      return 0.0;
    }
  }

  // ============ USERS ============

  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  Future<List<String>> getAllUserIds() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Failed to fetch user IDs: $e');
    }
  }
  // ============ ANALYTICS & DAHSBOARD ============

  Future<double> getDailySalesTotal([String? ownerId]) async {
    try {
      if (ownerId == null || ownerId.isEmpty) return 0.0;
      
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      Query<Map<String, dynamic>> query = _firestore.collection('orders')
          .where('ownerId', isEqualTo: ownerId.trim());
      
      QuerySnapshot snapshot = await query.get();
      double total = 0;
      for (var doc in snapshot.docs) {
        final order = OrderModel.fromJson(doc.data() as Map<String, dynamic>);
        if (order.createdAt.isAfter(startOfDay)) {
          total += order.total;
        }
      }
      return total;
    } catch (e) {
      debugPrint('Error fetching daily sales: $e');
      return 0.0;
    }
  }

  Future<int> getDailyOrdersCount([String? ownerId]) async {
    try {
      if (ownerId == null || ownerId.isEmpty) return 0;
      
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      Query<Map<String, dynamic>> query = _firestore.collection('orders')
          .where('ownerId', isEqualTo: ownerId.trim());
      
      QuerySnapshot snapshot = await query.get();
      int count = 0;
      for (var doc in snapshot.docs) {
        final order = OrderModel.fromJson(doc.data() as Map<String, dynamic>);
        if (order.createdAt.isAfter(startOfDay)) {
          count++;
        }
      }
      return count;
    } catch (e) {
      debugPrint('Error fetching daily order count: $e');
      return 0;
    }
  }

  Future<int> getActiveTrolleyCount([String? ownerId]) async {
    try {
      if (ownerId == null) {
        QuerySnapshot carts = await _firestore.collection('carts').get();
        return carts.docs.length;
      }
      
      // Dynamic implementation:
      // Count unique users who have at least ONE product belonging to this owner in their cart.
      final snapshot = await _firestore.collectionGroup('items')
          .where('ownerId', isEqualTo: ownerId)
          .get();
      
      final Set<String> uniqueUserIds = {};
      for (var doc in snapshot.docs) {
        final userId = doc.data()['userId'] as String?;
        if (userId != null) {
          uniqueUserIds.add(userId);
        }
      }
      
      return uniqueUserIds.length;
    } catch (e) {
      debugPrint('Error getting active trolley count: $e');
      return 0;
    }
  }

  Future<List<UserModel>> getOwnerCustomers(String ownerId) async {
    try {
      // 1. Get all orders for this owner
      final query = _firestore.collection('orders').where('ownerId', isEqualTo: ownerId);
      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) return [];
      
      // 2. Extract unique user IDs
      final Set<String> uniqueUserIds = {};
      for (var doc in snapshot.docs) {
        final orderData = doc.data();
        final userId = orderData['userId'] as String?;
        if (userId != null) uniqueUserIds.add(userId);
      }
      
      if (uniqueUserIds.isEmpty) return [];
      
      // 3. Fetch user details for those IDs
      final List<UserModel> customers = [];
      for (var userId in uniqueUserIds) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          customers.add(UserModel.fromJson(userDoc.data() as Map<String, dynamic>));
        }
      }
      
      return customers;
    } catch (e) {
      throw Exception('Failed to fetch owner customers: $e');
    }
  }

  Future<List<UserModel>> getAllCustomers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all customers: $e');
    }
  }

  Stream<List<UserModel>> getCustomersStream([String? ownerId]) {
    if (ownerId == null || ownerId.isEmpty) {
      return Stream.value([]);
    }

    // Since customers are a dynamic list derived from orders for a specific owner,
    // we listen to orders and fetch unique user details.
    return _firestore
        .collection('orders')
        .where('ownerId', isEqualTo: ownerId.trim())
        .snapshots()
        .asyncMap((orderSnapshot) async {
      final Set<String> uniqueUserIds = {};
      for (var doc in orderSnapshot.docs) {
        final userId = doc.data()['userId'] as String?;
        if (userId != null) uniqueUserIds.add(userId);
      }

      if (uniqueUserIds.isEmpty) return [];

      final List<UserModel> customers = [];
      for (var userId in uniqueUserIds) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          customers.add(UserModel.fromJson(userDoc.data() as Map<String, dynamic>));
        }
      }
      return customers;
    });
  }

  Stream<List<OrderModel>> getOrdersStream([String? ownerId]) {
    Query query = _firestore.collection('orders');
    if (ownerId != null && ownerId.isNotEmpty) {
      query = query.where('ownerId', isEqualTo: ownerId.trim());
    }

    return query.snapshots().map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  Future<List<Map<String, dynamic>>> getWeeklySummary(String ownerId) async {
    try {
      final now = DateTime.now();
      final startOfLastWeek = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
      
      final query = _firestore.collection('orders')
          .where('ownerId', isEqualTo: ownerId)
          .where('createdAt', isGreaterThanOrEqualTo: startOfLastWeek.toIso8601String());
          
      final snapshot = await query.get();
      
      final Map<String, Map<String, dynamic>> buckets = {};
      for (int i = 0; i < 7; i++) {
        final date = startOfLastWeek.add(Duration(days: i));
        final key = "${date.year}-${date.month}-${date.day}";
        buckets[key] = {
          'date': date,
          'total': 0.0,
          'count': 0,
        };
      }
      
      for (var doc in snapshot.docs) {
        final order = OrderModel.fromJson(doc.data() as Map<String, dynamic>);
        final date = order.createdAt;
        final key = "${date.year}-${date.month}-${date.day}";
        if (buckets.containsKey(key)) {
          buckets[key]!['total'] += order.total;
          buckets[key]!['count'] += 1;
        }
      }
      
      final result = buckets.values.toList();
      result.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
      return result;
    } catch (e) {
      throw Exception('Failed to fetch weekly summary: $e');
    }
  }
}
