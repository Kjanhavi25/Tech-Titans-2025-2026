import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class OwnerProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  double _dailySalesTotal = 0;
  int _dailyOrdersCount = 0;
  double _totalRevenue = 0;
  int _totalOrdersCount = 0;
  int _activeTrolleyCount = 0;
  List<UserModel> _customers = [];
  List<OrderModel> _recentOrders = [];
  List<Map<String, dynamic>> _weeklySummary = [];

  String? _ownerId;
  bool _isLoading = false;
  String? _errorMessage;

  String? get ownerId => _ownerId;
  double get dailySalesTotal => _dailySalesTotal;
  int get dailyOrdersCount => _dailyOrdersCount;
  double get totalRevenue => _totalRevenue;
  int get totalOrdersCount => _totalOrdersCount;
  int get activeTrolleyCount => _activeTrolleyCount;
  List<UserModel> get customers => _customers;
  List<OrderModel> get recentOrders => _recentOrders;
  List<Map<String, dynamic>> get weeklySummary => _weeklySummary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalCustomersCount => _customers.length;

  StreamSubscription<List<UserModel>>? _customersSubscription;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  void setOwnerId(String id) {
    if (_ownerId == id) return;
    _ownerId = id;
    loadDashboardData();
    _initStreams();
  }

  void _initStreams() {
    _customersSubscription?.cancel();
    _ordersSubscription?.cancel();
    
    if (_ownerId != null) {
      _customersSubscription = _firestoreService.getCustomersStream(_ownerId).listen((customers) {
        _customers = customers;
        notifyListeners();
      });

      _ordersSubscription = _firestoreService.getOrdersStream(_ownerId).listen((orders) {
        // We only keep the 10 most recent for the dashboard logic if needed, 
        // or the whole list for sub-screens.
        _recentOrders = orders;
        _totalOrdersCount = orders.length;
        notifyListeners();
      });
    }
  }

  Future<void> loadDashboardData() async {
    if (_ownerId == null) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _firestoreService.getDailySalesTotal(_ownerId),
        _firestoreService.getDailyOrdersCount(_ownerId),
        _firestoreService.getTotalRevenue(_ownerId),
        _firestoreService.getActiveTrolleyCount(_ownerId), 
        _firestoreService.getOwnerCustomers(_ownerId!), // Dynamic per owner
        _firestoreService.getAllOrders(_ownerId),
      ]);

      _dailySalesTotal = results[0] as double;
      _dailyOrdersCount = results[1] as int;
      _totalRevenue = results[2] as double;
      _activeTrolleyCount = results[3] as int;
      _customers = results[4] as List<UserModel>;
      _totalOrdersCount = (results[5] as List).length;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCustomers() async {
    if (_ownerId == null) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _customers = await _firestoreService.getOwnerCustomers(_ownerId!);
      _activeTrolleyCount = await _firestoreService.getActiveTrolleyCount(_ownerId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadWeeklySummary() async {
    if (_ownerId == null) return;
    
    _isLoading = true;
    notifyListeners();
    try {
      _weeklySummary = await _firestoreService.getWeeklySummary(_ownerId!);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }



  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all owner data when user logs out or switches user
  void clearAllData() {
    _customersSubscription?.cancel();
    _ordersSubscription?.cancel();
    _dailySalesTotal = 0;
    _dailyOrdersCount = 0;
    _totalRevenue = 0;
    _totalOrdersCount = 0;
    _activeTrolleyCount = 0;
    _customers = [];
    _recentOrders = [];
    _isLoading = false;
    _errorMessage = null;
    _ownerId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _customersSubscription?.cancel();
    super.dispose();
  }
}
