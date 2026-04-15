import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import 'iot_provider.dart';

class CartProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  IotProvider? _iotProvider;
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;
  StreamSubscription? _cartSubscription;

  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get cartCount => _cartItems.length;
  double get totalPrice => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  CartProvider();

  void updateIotProvider(IotProvider iot) {
    _iotProvider = iot;
  }

  void setUserId(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _cartSubscription?.cancel();
    _loadCart();
    notifyListeners();
  }

  void _loadCart() {
    if (_userId == null) return;

    _cartSubscription = _firestoreService.getCartStream(_userId!).listen((items) {
      _cartItems = items;
      notifyListeners();
    });
  }

  Future<bool> addToCart(ProductModel product) async {
    if (_userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    // IMMEDIATELY trigger IoT signal '1' for add operation (Responsive)
    Future.delayed(const Duration(milliseconds: 100), () {
      _iotProvider?.sendData('1');
    });

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if product already in cart to increment instead of duplicate
      final existingIndex = _cartItems.indexWhere((item) => item.productId == product.productId);
      
      if (existingIndex != -1) {
        final existingItem = _cartItems[existingIndex];
        final updatedItem = existingItem.copyWith(quantity: existingItem.quantity + 1);
        await _firestoreService.updateCartItem(updatedItem);
      } else {
        final cartItem = CartItemModel.fromProduct(product, _userId!);
        await _firestoreService.addToCart(cartItem);
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

  Future<bool> updateCartItem(CartItemModel cartItem) async {
    // Send IoT signal '3' for quantity update (UPDATE)
    Future.delayed(const Duration(milliseconds: 100), () {
      _iotProvider?.sendData('3');
    });

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateCartItem(cartItem);
      
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

  Future<bool> removeFromCart(String cartItemId) async {
    if (_userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    // Send IoT signal '2' for removal (REMOVE)
    Future.delayed(const Duration(milliseconds: 100), () {
      _iotProvider?.sendData('2');
    });

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.removeFromCart(_userId!, cartItemId);
      
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

  Future<bool> clearCart() async {
    if (_userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.clearCart(_userId!);
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

  Future<bool> increaseQuantity(CartItemModel cartItem) async {
    final updated = cartItem.copyWith(quantity: cartItem.quantity + 1);
    
    // Treat as an ADD movement (signal '1')
    Future.delayed(const Duration(milliseconds: 100), () {
      _iotProvider?.sendData('1');
    });

    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.updateCartItem(updated);
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

  Future<bool> decreaseQuantity(CartItemModel cartItem) async {
    if (cartItem.quantity <= 1) {
      // removeFromCart ALREADY sends signal '2'
      return removeFromCart(cartItem.cartItemId);
    }
    
    // Treat as a REMOVE movement (signal '2') for quantity decrement
    Future.delayed(const Duration(milliseconds: 100), () {
      _iotProvider?.sendData('2');
    });

    final updated = cartItem.copyWith(quantity: cartItem.quantity - 1);
    
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.updateCartItem(updated);
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

  double getTotalWeight() {
    return _cartItems.fold(0, (sum, item) => sum + ((item.weight ?? 0) * item.quantity));
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Send checkout/final count signal to the IoT device
  void sendCheckoutSignal() {
    // Capture the price BEFORE any delay or clearing of the cart
    final capturedPrice = totalPrice.toInt();
    
    // Send checkout signal '4'
    Future.delayed(const Duration(milliseconds: 100), () {
      _iotProvider?.sendData('4');
    });
  }

  /// Send manual update signal '3' for hardware synchronization
  void sendUpdateSignal() {
    _iotProvider?.sendData('3');
  }

  /// Clear all cart data when user logs out
  void clearAllData() {
    _cartItems = [];
    _userId = null;
    _cartSubscription?.cancel();
    _cartSubscription = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}
