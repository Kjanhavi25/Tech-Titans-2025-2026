import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class IotProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  fbp.BluetoothDevice? _connectedDevice;
  fbp.BluetoothConnectionState _connectionState = fbp.BluetoothConnectionState.disconnected;
  List<fbp.ScanResult> _scanResults = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _errorMessage;
  final List<String> _logs = [];
  
  fbp.BluetoothCharacteristic? _writeCharacteristic;
  final List<fbp.BluetoothCharacteristic> _writeCharacteristics = [];
  StreamSubscription? _stateSub;
  StreamSubscription? _scanSub;
  StreamSubscription? _adapterSub;

  fbp.BluetoothDevice? get connectedDevice => _connectedDevice;
  fbp.BluetoothConnectionState get connectionState => _connectionState;
  List<fbp.ScanResult> get scanResults => _scanResults;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  String? get errorMessage => _errorMessage;
  List<String> get logs => List.unmodifiable(_logs);

  IotProvider() {
    _initBluetooth();
  }

  void _initBluetooth() {
    _adapterSub = fbp.FlutterBluePlus.adapterState.listen((state) {
      if (state == fbp.BluetoothAdapterState.off) {
        _addLog("ADAPTER OFF");
        disconnect();
      }
      notifyListeners();
    });

    fbp.FlutterBluePlus.isScanning.listen((scanning) {
      _isScanning = scanning;
      notifyListeners();
    });

    _scanSub = fbp.FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      notifyListeners();
    });
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> startScan() async {
    _errorMessage = null;
    notifyListeners();

    final state = await fbp.FlutterBluePlus.adapterState.first;
    if (state != fbp.BluetoothAdapterState.on) {
      _errorMessage = "Please turn on Bluetooth";
      notifyListeners();
      return;
    }

    if (!await requestPermissions()) {
      _errorMessage = "Bluetooth permissions required";
      notifyListeners();
      return;
    }

    try {
      if (kIsWeb) {
        _isScanning = true;
        notifyListeners();
        await Future.delayed(const Duration(seconds: 2));
        _isScanning = false;
        _errorMessage = "Web platform mock: Bluetooth testing requires physical device.";
        notifyListeners();
        return;
      }

      if (fbp.FlutterBluePlus.isScanningNow) {
        await fbp.FlutterBluePlus.stopScan();
      }

      await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      _errorMessage = "Scan Error: $e";
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    await fbp.FlutterBluePlus.stopScan();
  }

  Future<void> connect(fbp.BluetoothDevice device) async {
    await _cancelSubscriptions();
    
    _connectedDevice = device;
    _errorMessage = null;
    _isConnecting = true;
    notifyListeners();

    try {
      if (fbp.FlutterBluePlus.isScanningNow) {
        await fbp.FlutterBluePlus.stopScan();
      }

      await Future.delayed(const Duration(milliseconds: 500));

      await device.connect(
        timeout: const Duration(seconds: 10), 
        autoConnect: false,
        license: fbp.License.free,
      );
      
      _connectionState = fbp.BluetoothConnectionState.connected;
      _addLog("CONNECTED: ${device.platformName}");

      _stateSub = device.connectionState.listen((state) {
        _connectionState = state;
        if (state == fbp.BluetoothConnectionState.disconnected) {
          _onDisconnected();
        }
        notifyListeners();
      });

      await _setupDataListener(device);
      
    } catch (e) {
      _errorMessage = "Connection Failed";
      _onDisconnected();
      _addLog("CONN ERROR: $e");
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  void _onDisconnected() {
    _connectedDevice = null;
    _writeCharacteristic = null;
    _writeCharacteristics.clear();
    _connectionState = fbp.BluetoothConnectionState.disconnected;
    _cancelSubscriptions(keepAdapter: true);
  }

  Future<void> _cancelSubscriptions({bool keepAdapter = false}) async {
    await _stateSub?.cancel();
    if (!keepAdapter) {
      await _adapterSub?.cancel();
      await _scanSub?.cancel();
    }
    _stateSub = null;
  }

  Future<void> _setupDataListener(fbp.BluetoothDevice device) async {
    _writeCharacteristic = null;
    _writeCharacteristics.clear();
    try {
      List<fbp.BluetoothService> services = await device.discoverServices();
      
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          // Notify setup
          if (characteristic.properties.notify || characteristic.properties.indicate) {
            try {
              await Future.delayed(const Duration(milliseconds: 100));
              await characteristic.setNotifyValue(true);
              characteristic.lastValueStream.listen((value) {
                _handleSensorData(value);
              });
              _addLog("RD READY: ${characteristic.uuid.toString().substring(4, 8)}");
            } catch (_) {}
          }
          
          // Writable characteristics detection
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
             _writeCharacteristics.add(characteristic);
            bool isUart = characteristic.uuid.toString().contains('ffe1');
            if (_writeCharacteristic == null || isUart) {
              _writeCharacteristic = characteristic;
            }
            _addLog("WR READY: ${characteristic.uuid.toString().substring(4, 8)} ${isUart ? '[UART]' : ''}");
          }
        }
      }
    } catch (e) {
      _addLog("SETUP ERR: $e");
    }
  }

  void _handleSensorData(List<int> data) async {
    try {
      String rawData = utf8.decode(data);
      _addLog("RX: $rawData");
      
      if (rawData.startsWith('P')) {
         _processProduct(rawData.trim());
      }
    } catch (_) {}
  }

  Function(ProductModel)? onProductDetected;

  Future<void> _processProduct(String productId) async {
    try {
      ProductModel? product = await _firestoreService.getProduct(productId);
      if (product != null && onProductDetected != null) {
        onProductDetected!(product);
      }
    } catch (_) {}
  }

  Future<void> simulateDetection(String productId) async {
    _addLog("SIM: $productId");
    _processProduct(productId);
  }

  Future<void> sendData(String data) async {
    if (_connectionState != fbp.BluetoothConnectionState.connected || _writeCharacteristics.isEmpty) {
      _addLog("TX BLOCKED (Disconnected/No Write Char)");
      return;
    }

    try {
      final terminalData = data.endsWith('\n') ? data : '$data\n';
      final bytes = utf8.encode(terminalData);
      
      // Nuclear Mode: Write to all available writable characteristics
      for (var characteristic in _writeCharacteristics) {
        try {
          await characteristic.write(
            bytes, 
            withoutResponse: characteristic.properties.writeWithoutResponse,
            timeout: 2,
          );
        } catch (_) {}
      }
      
      String label = "";
      final cleanData = data.trim();
      if (cleanData.startsWith('1')) label = " (ADD)";
      if (cleanData.startsWith('2')) label = " (REMOVE)";
      if (cleanData.startsWith('3')) label = " (UPDATE)";
      if (cleanData.startsWith('4')) label = " (CHECKOUT)";
      
      final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      _addLog("TX: '$cleanData'$label [Hex: $hex]");
    } catch (e) {
      _addLog("TX ERR: $e");
    }
  }

  void _addLog(String msg) {
    final time = DateTime.now().toString().split(' ').last.substring(0, 8);
    _logs.insert(0, "[$time] $msg");
    if (_logs.length > 50) _logs.removeLast();
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (_) {}
      _onDisconnected();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
