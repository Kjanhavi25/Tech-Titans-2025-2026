import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<OrderModel> _orders = [];
  List<OrderModel> _allOrders = [];
  double _totalRevenue = 0;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;
  String? _ownerId;

  List<OrderModel> get orders => _orders;
  List<OrderModel> get allOrders => _allOrders;
  double get totalRevenue => _totalRevenue;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  OrderProvider();

  void setUserId(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    notifyListeners();
  }

  void setOwnerId(String? ownerId) {
    if (_ownerId == ownerId) return;
    _ownerId = ownerId;
    // Auto-refresh when owner context changes
    if (ownerId != null) {
      loadAllOrders();
      loadTotalRevenue();
    }
    notifyListeners();
  }

  Future<bool> createOrder(OrderModel order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.createOrder(order);
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

  Future<void> loadUserOrders() async {
    if (_userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _firestoreService.getUserOrders(_userId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Use the ownerId to filter orders globally
      _allOrders = await _firestoreService.getAllOrders(_ownerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTotalRevenue() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _totalRevenue = await _firestoreService.getTotalRevenue(_ownerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> getOrder(String orderId) async {
    try {
      return await _firestoreService.getOrder(orderId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateOrder(OrderModel order) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateOrder(order);
      // Refresh orders
      await loadAllOrders();
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

  int getTotalOrdersCount() => _allOrders.length;

  int getPendingOrdersCount() =>
      _allOrders.where((o) => o.status == OrderStatus.pending).length;

  double getAverageOrderValue() {
    if (_allOrders.isEmpty) return 0;
    return _totalRevenue / _allOrders.length;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all order data when user logs out
  void clearAllData() {
    _orders = [];
    _allOrders = [];
    _totalRevenue = 0;
    _userId = null;
    _ownerId = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
