import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _ownerId;
  StreamSubscription<List<ProductModel>>? _productsSubscription;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get ownerId => _ownerId;

  ProductProvider() {
    // Initial call might not have ownerId yet if using ProxyProvider
  }

  void setOwnerId(String? id) {
    if (_ownerId == id) return;
    _ownerId = id;
    _initProducts();
  }

  void _initProducts() {
    _productsSubscription?.cancel();
    // Only subscribe if we have an ownerId to prevent loading global data in owner portal
    if (_ownerId != null && _ownerId!.isNotEmpty) {
      _productsSubscription = _firestoreService.getProductsStream(_ownerId).listen((products) {
        _products = products;
        notifyListeners();
      });
    } else {
      _products = [];
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    // If we have an ownerId, we should only load products for that owner.
    // If _ownerId is null, it depends on who is calling. For an owner, this should not return global products.
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // If we are in an owner state and ownerId is null, we return nothing.
      // This prevents race conditions where global or unauthorized products are shown briefly.
      if (_ownerId == null || _ownerId!.isEmpty) {
        _products = [];
      } else {
        _products = await _firestoreService.getAllProducts(_ownerId);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ProductModel?> getProduct(String productId, [String? ownerId]) async {
    try {
      return await _firestoreService.getProduct(productId, ownerId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Explicitly assign ownerId from the provider state
      final productToSave = product.copyWith(
        ownerId: product.ownerId ?? _ownerId,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.addProduct(productToSave);
      
      // OPTIMISTIC UPDATE: Add to local list immediately so user sees it
      // This bypasses any stream lag or filtering issues temporarily
      if (!_products.any((p) => p.productId == productToSave.productId)) {
        _products.insert(0, productToSave);
      } else {
        final index = _products.indexWhere((p) => p.productId == productToSave.productId);
        _products[index] = productToSave;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Ensure ownerId is preserved if not in the update model but we have it in state
      final productToUpdate = product.copyWith(
        ownerId: product.ownerId ?? _ownerId,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateProduct(productToUpdate);
      
      // OPTIMISTIC UPDATE: Update local list immediately
      final index = _products.indexWhere((p) => p.productId == productToUpdate.productId);
      if (index != -1) {
        _products[index] = productToUpdate;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteProduct(productId, _ownerId);
      
      // OPTIMISTIC UPDATE: Deactivate locally
      final index = _products.indexWhere((p) => p.productId == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(isActive: false);
        _products.removeAt(index); // Or just remove if we want it gone
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<ProductModel> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  List<String> getCategories() {
    final categories = <String>{};
    for (var product in _products) {
      categories.add(product.category);
    }
    return categories.toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all product data when user logs out
  void clearAllData() {
    _productsSubscription?.cancel();
    _products = [];
    _isLoading = false;
    _errorMessage = null;
    _ownerId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }
}
