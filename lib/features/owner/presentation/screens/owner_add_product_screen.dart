import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/product_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/product_provider.dart';

class OwnerAddProductScreen extends StatefulWidget {
  final ProductModel? product;
  const OwnerAddProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<OwnerAddProductScreen> createState() => _OwnerAddProductScreenState();
}

class _OwnerAddProductScreenState extends State<OwnerAddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _weightController;
  late TextEditingController _descriptionController;
  late TextEditingController _stockController;

  String _selectedCategory = 'General';
  String? _generatedQRData;
  bool _qrGenerated = false;

  static const List<String> _categories = [
    'General',
    'Fruits & Vegetables',
    'Dairy & Eggs',
    'Bakery',
    'Beverages',
    'Snacks',
    'Frozen Foods',
    'Meat & Seafood',
    'Household',
    'Personal Care',
    'Baby Products',
    'Health & Wellness',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _idController = TextEditingController(
        text: p?.productId ?? const Uuid().v4().substring(0, 8).toUpperCase());
    _nameController = TextEditingController(text: p?.productName ?? '');
    _priceController =
        TextEditingController(text: p?.price.toString() ?? '');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _weightController =
        TextEditingController(text: p?.weight?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: p?.description ?? '');
    _stockController =
        TextEditingController(text: p?.quantity.toString() ?? '0');
    _selectedCategory = p?.category ?? 'General';

    // If editing, pre-generate the QR from existing data
    if (p != null) {
      _generatedQRData = _buildQRData();
      _qrGenerated = true;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  String _buildQRData() {
    final id = _idController.text.trim();
    if (id.isEmpty) return "";
    
    final authProvider = context.read<AuthProvider>();
    
    // Create a minimal JSON with both productId and ownerId for isolation support
    return jsonEncode({
      'productId': id,
      'ownerId': widget.product?.ownerId ?? authProvider.currentUser?.uid ?? 'UNKNOWN',
    });
  }

  void _generateQR() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _generatedQRData = _buildQRData();
        _qrGenerated = true;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();
    final productProvider = context.read<ProductProvider>();

    final currentUid = authProvider.currentUser?.uid;
    if (currentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error: User not authenticated'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final product = ProductModel(
      productId: _idController.text.trim(),
      productName: _nameController.text.trim(),
      price: double.parse(_priceController.text),
      imageUrl: _imageUrlController.text.trim(),
      weight: _weightController.text.isEmpty
          ? null
          : double.tryParse(_weightController.text),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      quantity: int.tryParse(_stockController.text) ?? 0,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: widget.product?.isActive ?? true,
      ownerId: widget.product?.ownerId ?? currentUid,
      createdBy: widget.product?.createdBy ?? authProvider.currentUser?.name,
    );

    ProductModel productToSave = product;
    
    bool success;
    if (widget.product == null) {
      success = await productProvider.addProduct(productToSave);
    } else {
      success = await productProvider.updateProduct(productToSave);
    }

    if (!mounted) return;
    if (success) {
      // Auto-generate QR on save if not yet generated
      if (!_qrGenerated) {
        setState(() {
          _generatedQRData = _buildQRData();
          _qrGenerated = true;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.product == null
            ? '✅ Product added with QR code!'
            : '✅ Product updated!'),
        backgroundColor: AppTheme.successColor,
      ));
      // Show QR dialog before popping
      await _showQRDialog();
      if (mounted) Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(productProvider.errorMessage ?? 'Failed to save'),
        backgroundColor: AppTheme.errorColor,
      ));
    }
  }

  Future<void> _showQRDialog() async {
    if (_generatedQRData == null) return;
    await showDialog(
      context: context,
      builder: (_) => _QRViewDialog(
        qrData: _generatedQRData!,
        productName: _nameController.text.trim(),
        productId: _idController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        title: Text(
          widget.product == null ? 'Add New Product' : 'Edit Product',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── PRODUCT INFO CARD ──
              _FormCard(
                title: 'Product Information',
                icon: Icons.inventory_2_rounded,
                children: [
                  // Product ID (auto-generated, read-only for new)
                  Row(
                    children: [
                      Expanded(
                        child: _StyledField(
                          controller: _idController,
                          label: 'Product ID',
                          hint: 'Auto-generated',
                          icon: Icons.qr_code_rounded,
                          enabled: widget.product == null,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      if (widget.product == null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Regenerate ID',
                          icon: const Icon(Icons.refresh_rounded,
                              color: Color(0xFF7C3AED)),
                          onPressed: () {
                            setState(() {
                              _idController.text = const Uuid()
                                  .v4()
                                  .substring(0, 8)
                                  .toUpperCase();
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  _StyledField(
                    controller: _nameController,
                    label: 'Product Name',
                    hint: 'e.g. Organic Apples 1kg',
                    icon: Icons.label_rounded,
                    validator: (v) =>
                        v?.isEmpty ?? true ? 'Product name is required' : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _StyledField(
                          controller: _priceController,
                          label: 'Price (₹)',
                          hint: '0.00',
                          icon: Icons.currency_rupee_rounded,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Required';
                            if (double.tryParse(v!) == null)
                              return 'Invalid price';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StyledField(
                          controller: _stockController,
                          label: 'Stock Qty',
                          hint: '0',
                          icon: Icons.numbers_rounded,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Required';
                            if (int.tryParse(v!) == null)
                              return 'Invalid number';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _StyledField(
                    controller: _weightController,
                    label: 'Weight (grams) — optional',
                    hint: 'e.g. 500',
                    icon: Icons.scale_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── CATEGORY ──
              _FormCard(
                title: 'Category',
                icon: Icons.category_rounded,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF7C3AED), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── IMAGE & DESCRIPTION ──
              _FormCard(
                title: 'Details',
                icon: Icons.description_rounded,
                children: [
                  _StyledField(
                    controller: _imageUrlController,
                    label: 'Image URL',
                    hint: 'https://example.com/image.jpg',
                    icon: Icons.image_rounded,
                  ),
                  const SizedBox(height: 14),
                  _StyledField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Product description...',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── QR PREVIEW ──
              _FormCard(
                title: 'QR Code Preview',
                icon: Icons.qr_code_2_rounded,
                children: [
                  if (_qrGenerated && _generatedQRData != null) ...[
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFF7C3AED)
                                      .withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: QrImageView(
                              data: _generatedQRData!,
                              version: QrVersions.auto,
                              size: 180,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _nameController.text,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${_idController.text}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _showQRDialog,
                            icon: const Icon(Icons.fullscreen_rounded),
                            label: const Text('View Full QR'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF7C3AED),
                              side: const BorderSide(
                                  color: Color(0xFF7C3AED)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF7C3AED).withOpacity(0.2),
                            style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.qr_code_2_rounded,
                              size: 48, color: Color(0xFF7C3AED)),
                          const SizedBox(height: 8),
                          const Text(
                            'QR code will be generated\nwhen you save the product',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _generateQR,
                            icon: const Icon(Icons.qr_code_rounded),
                            label: const Text('Preview QR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C3AED),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // ── SAVE BUTTON ──
              Consumer<ProductProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _saveProduct,
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        provider.isLoading
                            ? 'Saving...'
                            : (widget.product == null
                                ? 'Add Product & Generate QR'
                                : 'Update Product'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF7C3AED).withOpacity(0.4),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── QR FULL VIEW DIALOG ──────────────────────────────────────────────────────

class _QRViewDialog extends StatelessWidget {
  final String qrData;
  final String productName;
  final String productId;
  final double price;

  const _QRViewDialog({
    required this.qrData,
    required this.productName,
    required this.productId,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Product QR Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFF7C3AED).withOpacity(0.2)),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                productName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'ID: $productId • ₹${price.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                'Scan this QR with the Smart Trolley app',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: qrData));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('QR data copied!')),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7C3AED),
                        side: const BorderSide(color: Color(0xFF7C3AED)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── REUSABLE FORM WIDGETS ────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _FormCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF6366F1), size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;

  const _StyledField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF7C3AED), size: 20),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
