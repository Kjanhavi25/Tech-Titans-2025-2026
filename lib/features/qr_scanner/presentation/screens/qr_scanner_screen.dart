import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../models/product_model.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/product_provider.dart';
import '../../../../services/qr_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController controller;
  bool _isProcessing = false;
  bool _isAddedInThisSession = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleScannedQRCode(String code) async {
    final now = DateTime.now();
    
    // Cooldown logic for the SAME code to prevent rapid-fire scans
    if (code == _lastScannedCode && _lastScanTime != null) {
      if (now.difference(_lastScanTime!) < const Duration(milliseconds: 2000)) {
        return; 
      }
    }
    
    // If a popup is already open, and we scan a DIFFERENT product, we should close the old one
    if (_isProcessing && code != _lastScannedCode) {
      Navigator.of(context).pop();
    }
    
    _isProcessing = true;
    _isAddedInThisSession = false; // Fresh session for this specific scan
    _lastScannedCode = code;
    _lastScanTime = now;

    try {
      // Extract Product and Owner IDs
      final qrData = QRService.getFullQRData(code);
      String? productId = qrData?['productId'];
      String? ownerId = qrData?['ownerId'];
      
      if (productId == null) {
        _showErrorSnackbar('Invalid QR code');
        await Future.delayed(const Duration(seconds: 1));
        _isProcessing = false;
        return;
      }

      final productProvider = context.read<ProductProvider>();
      ProductModel? product = await productProvider.getProduct(productId, ownerId);

      if (product == null) {
        _showErrorSnackbar('Product not found in this store');
        await Future.delayed(const Duration(seconds: 1));
        _isProcessing = false;
        return;
      }

      // Show Action Sheet
      _showProductActionSheet(product);
      
    } catch (e) {
      _showErrorSnackbar('Error: $e');
      _isProcessing = false;
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  void _showProductActionSheet(ProductModel product) {
    // Remove controller.stop() to allow "D-mart style" continuous scanning
    // controller.stop();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Product Info
                Text(
                  product.productName,
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                Text(
                  AppUtils.formatCurrency(product.price),
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Action Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.5,
                  children: [
                    // ADD (1) - Only once per scan session
                    ElevatedButton.icon(
                      onPressed: _isAddedInThisSession ? null : () async {
                        final success = await context.read<CartProvider>().addToCart(product);
                        if (success && mounted) {
                          setModalState(() {
                            _isAddedInThisSession = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Product Added!'), backgroundColor: AppTheme.successColor, duration: Duration(milliseconds: 800)),
                          );
                        }
                      },
                      icon: Icon(_isAddedInThisSession ? Icons.check : Icons.add),
                      label: Text(_isAddedInThisSession ? 'ADDED' : 'ADD'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                    ),
                    
                    // REMOVE - Decrease quantity one-by-one
                    Builder(
                      builder: (context) {
                        final cartProvider = context.watch<CartProvider>();
                        final isInCart = cartProvider.cartItems.any((i) => i.productId == product.productId);
                        return ElevatedButton.icon(
                          onPressed: !isInCart ? null : () async {
                            final item = cartProvider.cartItems.firstWhere(
                              (i) => i.productId == product.productId,
                            );
                            await cartProvider.decreaseQuantity(item);
                            if (mounted) {
                              final stillInCart = cartProvider.cartItems.any((i) => i.productId == product.productId);
                              if (!stillInCart) {
                                setModalState(() {
                                  _isAddedInThisSession = false; 
                                });
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Quantity Decreased'), backgroundColor: Colors.orange, duration: Duration(milliseconds: 800)),
                              );
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                          label: const Text('REMOVE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                            disabledBackgroundColor: Colors.grey[200],
                            disabledForegroundColor: Colors.grey,
                          ),
                        );
                      }
                    ),
                    
                    // UPDATE (3) - Mandantory Sync/Confirmation Signal
                    Builder(
                      builder: (context) {
                        return ElevatedButton.icon(
                          onPressed: () {
                            context.read<CartProvider>().sendUpdateSignal();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Trolley Updated!'), backgroundColor: AppTheme.primaryColor, duration: Duration(milliseconds: 800)),
                              );
                            }
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('UPDATE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.warningColor,
                          ),
                        );
                      }
                    ),
                    
                    // CHECKOUT (4)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<CartProvider>().sendCheckoutSignal();
                        Navigator.pop(context); // Close scanner
                        Navigator.pushNamed(context, '/cart'); // Go to cart
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('CHECKOUT'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                    ),
                  ],
                ),
                
                if (_isAddedInThisSession)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Scan again to add another ${product.productName}',
                      style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                
                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _resumeScanner();
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('SCAN ANOTHER PRODUCT'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryColor),
                      foregroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
      ),
    ).then((_) {
      if (_isProcessing) {
        _resumeScanner();
      }
    });
  }

  void _resumeScanner() {
    _isProcessing = false;
    _lastScannedCode = null;
    _lastScanTime = null;
    // controller.start(); // Already running
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Scanner'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleScannedQRCode(barcode.rawValue!);
                }
              }
            },
          ),
          
          // Improved Scanner Overlay (Guaranteed clear hole)
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Visual Corners for the frame
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                onPressed: () => controller.toggleTorch(),
                icon: const Icon(Icons.flashlight_on, size: 40, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
