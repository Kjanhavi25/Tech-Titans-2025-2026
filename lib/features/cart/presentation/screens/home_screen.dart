import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/product_provider.dart';
import '../../../../providers/iot_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../../services/connectivity_service.dart';
import '../../../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Setup Bluetooth product detection
      final iotProvider = context.read<IotProvider>();
      iotProvider.onProductDetected = (product) {
        context.read<CartProvider>().addToCart(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.productName} added via Bluetooth Trolley'),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      };
    });
  }

  void _showBluetoothDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<IotProvider>(
        builder: (context, iotProvider, _) {
          return AlertDialog(
            title: const Text('Connect Smart Trolley'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Column(
                children: [
                  if (iotProvider.isScanning || iotProvider.isConnecting)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LinearProgressIndicator(
                        color: iotProvider.isConnecting ? Colors.orange : null,
                      ),
                    ),
                  if (iotProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        iotProvider.errorMessage!,
                        style: const TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                  Expanded(
                    child: iotProvider.scanResults.isEmpty
                        ? const Center(child: Text('No devices found'))
                        : ListView.builder(
                            itemCount: iotProvider.scanResults.length,
                            itemBuilder: (context, index) {
                              final result = iotProvider.scanResults[index];
                              final device = result.device;
                              final name = device.platformName.isNotEmpty 
                                  ? device.platformName 
                                  : (result.advertisementData.advName.isNotEmpty 
                                      ? result.advertisementData.advName 
                                      : 'Unknown Device');
                              
                              return ListTile(
                                leading: const Icon(Icons.bluetooth),
                                title: Text(name),
                                subtitle: Text(device.remoteId.toString()),
                                trailing: ElevatedButton(
                                  onPressed: () async {
                                    await iotProvider.connect(device);
                                    if (iotProvider.connectionState == BluetoothConnectionState.connected && context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text('Connect'),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              FilledButton(
                onPressed: iotProvider.isScanning 
                    ? null 
                    : () => iotProvider.startScan(),
                child: Text(iotProvider.isScanning ? 'Scanning...' : 'Start Scan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTerminalDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Consumer<IotProvider>(
        builder: (context, iotProvider, _) {
          return AlertDialog(
            backgroundColor: const Color(0xFF141414), // Smoother dark background
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bluetooth Serial Terminal', 
                  style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.greenAccent),
                      onPressed: () => iotProvider.clearLogs(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.greenAccent),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              height: 500,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: iotProvider.logs.isEmpty
                          ? const Center(child: Text('Waiting for data...', style: TextStyle(color: Colors.white54)))
                          : ListView.builder(
                              itemCount: iotProvider.logs.length,
                              itemBuilder: (context, index) {
                                final log = iotProvider.logs[index];
                                bool isRX = log.contains('RX:');
                                bool isTX = log.contains('TX:');
                                Color logColor = isRX ? Colors.greenAccent : (isTX ? Colors.blueAccent : Colors.orangeAccent);
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  child: Text(
                                    log,
                                    style: TextStyle(color: logColor, fontFamily: 'Courier', fontSize: 13),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                          decoration: InputDecoration(
                            hintText: 'Enter command...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            fillColor: Colors.grey[900],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.greenAccent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.greenAccent, width: 0.5),
                            ),
                          ),
                          onSubmitted: (value) async {
                            if (value.trim().isNotEmpty) {
                              await iotProvider.sendData(value.trim());
                              textController.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () async {
                            final val = textController.text.trim();
                            if (val.isNotEmpty) {
                              await iotProvider.sendData(val);
                              textController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actionsPadding: EdgeInsets.zero,
            actions: [
              if (kIsWeb)
                TextButton(
                  onPressed: () {
                    iotProvider.simulateDetection("P001");
                  },
                  child: const Text('PROD 1', style: TextStyle(color: Colors.cyan)),
                ),
               if (kIsWeb)
                TextButton(
                  onPressed: () {
                    iotProvider.simulateDetection("P002");
                  },
                  child: const Text('PROD 2', style: TextStyle(color: Colors.orange)),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Trolley'),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.of(context).pushNamed('/cart');
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<CartProvider>(
                  builder: (context, cartProvider, _) {
                    if (cartProvider.cartCount == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cartProvider.cartCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('My Orders'),
                onTap: () {
                  Navigator.of(context).pushNamed('/orders');
                },
              ),
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () {
                  context.read<AuthProvider>().logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Consumer<IotProvider>(
        builder: (context, iot, _) {
          if (iot.connectionState != BluetoothConnectionState.connected) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _showTerminalDialog(context),
            icon: const Icon(Icons.terminal_rounded),
            label: const Text('Terminal'),
            backgroundColor: Colors.black87,
          );
        },
      ),
      body: Column(
        children: [
          // Offline Banner
          Consumer<ConnectivityService>(
            builder: (context, connectivity, _) {
              if (connectivity.isConnected) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                color: AppTheme.errorColor,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'No internet connection',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              );
            },
          ),
          // Main UI
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Welcome Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_basket_outlined,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to Smart Store',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Scan the QR code on physical products to add them to your smart trolley.',
                    style: TextStyle(color: AppTheme.lightText, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  
                  // Main Action: QR Scan
                  SizedBox(
                    width: double.infinity,
                    height: 80,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/qr-scanner');
                      },
                      icon: const Icon(Icons.qr_code_scanner, size: 32),
                      label: const Text(
                        'START SCANNING',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        elevation: 4,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const SizedBox(height: 20),
                  
                  // Secondary Action: Connect Trolley
                  Consumer<IotProvider>(
                    builder: (context, iotProvider, _) {
                      final isConnected = iotProvider.connectionState == BluetoothConnectionState.connected;
                      return SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showBluetoothDialog(context);
                          },
                          icon: Icon(
                            isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                            size: 24,
                          ),
                          label: Text(
                            isConnected ? 'TROLLEY CONNECTED' : 'CONNECT SMART TROLLEY',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isConnected ? AppTheme.successColor : AppTheme.primaryColor,
                              width: 2,
                            ),
                            foregroundColor: isConnected ? AppTheme.successColor : AppTheme.primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Tips
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: const Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: AppTheme.warningColor),
                            SizedBox(width: 12),
                            Text(
                              'Shopping Tip',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Keep your device within range of the Smart Trolley for automatic weighing and verification.',
                          style: TextStyle(color: AppTheme.lightText, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
