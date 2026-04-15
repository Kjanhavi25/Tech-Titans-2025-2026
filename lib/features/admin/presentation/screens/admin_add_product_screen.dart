import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/product_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/product_provider.dart';

class AdminAddProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AdminAddProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _weightController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.product?.productId ?? '');
    _nameController = TextEditingController(text: widget.product?.productName ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _imageUrlController =
        TextEditingController(text: widget.product?.imageUrl ?? '');
    _weightController = TextEditingController(
        text: widget.product?.weight?.toString() ?? '');
    _categoryController =
        TextEditingController(text: widget.product?.category ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _quantityController =
        TextEditingController(text: widget.product?.quantity.toString() ?? '0');
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _weightController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'Product ID'),
                enabled: widget.product == null,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Product ID is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Price is required';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Invalid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (grams)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Quantity is required';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Invalid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Consumer<ProductProvider>(
                builder: (context, productProvider, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: productProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final product = ProductModel(
                                  productId: _idController.text.trim(),
                                  productName: _nameController.text.trim(),
                                  price: double.parse(_priceController.text),
                                  imageUrl: _imageUrlController.text.trim(),
                                  weight: _weightController.text.isEmpty
                                      ? null
                                      : double.parse(_weightController.text),
                                  category: _categoryController.text.trim(),
                                  description: _descriptionController.text.trim(),
                                  quantity: int.tryParse(_quantityController.text) ?? 0,
                                  createdAt: widget.product?.createdAt ??
                                      DateTime.now(),
                                  updatedAt: DateTime.now(),
                                  ownerId: widget.product?.ownerId ?? 'ADMIN',
                                );

                                bool success;
                                if (widget.product == null) {
                                  success = await productProvider
                                      .addProduct(product);
                                } else {
                                  success = await productProvider
                                      .updateProduct(product);
                                }

                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        widget.product == null
                                            ? 'Product added successfully'
                                            : 'Product updated successfully',
                                      ),
                                      backgroundColor:
                                          AppTheme.successColor,
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        productProvider.errorMessage ??
                                            'Failed to save product',
                                      ),
                                      backgroundColor:
                                          AppTheme.errorColor,
                                    ),
                                  );
                                }
                              }
                            },
                      child: productProvider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.product == null
                                  ? 'Add Product'
                                  : 'Update Product',
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
