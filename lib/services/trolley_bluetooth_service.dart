import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class TrolleyBluetoothService {
  static final TrolleyBluetoothService _instance = TrolleyBluetoothService._internal();
  factory TrolleyBluetoothService() => _instance;
  TrolleyBluetoothService._internal();

  Stream<List<fbp.ScanResult>> get scanResults => fbp.FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => fbp.FlutterBluePlus.isScanning;

  Future<void> startScan() async {
    if (await fbp.FlutterBluePlus.isSupported == false) {
      return;
    }
    await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  Future<void> stopScan() async {
    await fbp.FlutterBluePlus.stopScan();
  }

  Future<void> connect(fbp.BluetoothDevice device) async {
    await device.connect(license: fbp.License.free);
  }

  Future<void> disconnect(fbp.BluetoothDevice device) async {
    await device.disconnect();
  }

  Stream<fbp.BluetoothConnectionState> connectionState(fbp.BluetoothDevice device) {
    return device.connectionState;
  }

  Future<List<fbp.BluetoothService>> discoverServices(fbp.BluetoothDevice device) async {
    return await device.discoverServices();
  }
}
