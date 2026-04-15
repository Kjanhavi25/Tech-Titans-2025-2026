import 'package:flutter_test/flutter_test.dart';
import 'package:smart_trolly/core/utils/app_utils.dart';
import 'package:smart_trolly/models/product_model.dart';
import 'package:smart_trolly/models/cart_item_model.dart';
import 'package:smart_trolly/models/order_model.dart';
import 'package:smart_trolly/services/qr_service.dart';

void main() {
  // ──────────────────────────────────────────────
  // AppUtils Tests
  // ──────────────────────────────────────────────
  group('AppUtils', () {
    test('formatCurrency formats Indian Rupees correctly', () {
      expect(AppUtils.formatCurrency(100.0), contains('₹'));
      expect(AppUtils.formatCurrency(0.0), contains('₹'));
    });

    test('isValidEmail accepts valid emails', () {
      expect(AppUtils.isValidEmail('test@example.com'), isTrue);
      expect(AppUtils.isValidEmail('user.name+tag@domain.co.in'), isTrue);
    });

    test('isValidEmail rejects invalid emails', () {
      expect(AppUtils.isValidEmail('notanemail'), isFalse);
      expect(AppUtils.isValidEmail('missing@domain'), isFalse);
      expect(AppUtils.isValidEmail(''), isFalse);
    });

    test('isValidPassword requires at least 8 characters', () {
      expect(AppUtils.isValidPassword('1234567'), isFalse);
      expect(AppUtils.isValidPassword('12345678'), isTrue);
      expect(AppUtils.isValidPassword('strongPassword!'), isTrue);
    });

    test('isValidPhoneNumber requires 10 digits', () {
      expect(AppUtils.isValidPhoneNumber('9876543210'), isTrue);
      expect(AppUtils.isValidPhoneNumber('98765'), isFalse);
      expect(AppUtils.isValidPhoneNumber('abcdefghij'), isFalse);
    });

    test('formatWeight formats grams and kilograms', () {
      expect(AppUtils.formatWeight(500), equals('500 g'));
      expect(AppUtils.formatWeight(1500), equals('1.50 kg'));
      expect(AppUtils.formatWeight(null), equals('0 kg'));
    });
  });

  // ──────────────────────────────────────────────
  // ProductModel Tests
  // ──────────────────────────────────────────────
  group('ProductModel', () {
    final product = ProductModel(
      productId: 'prod_001',
      productName: 'Apple',
      price: 50.0,
      imageUrl: '',
      category: 'Fruits',
      weight: 200,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    );

    test('fromQRData parses correctly', () {
      final qrMap = {
        'productId': 'prod_001',
        'productName': 'Apple',
        'price': 50.0,
        'category': 'Fruits',
      };
      final fromQR = ProductModel.fromQRData(qrMap);
      expect(fromQR.productId, equals('prod_001'));
      expect(fromQR.price, equals(50.0));
    });

    test('copyWith preserves original values when not overriding', () {
      final copy = product.copyWith(price: 75.0);
      expect(copy.price, equals(75.0));
      expect(copy.productName, equals('Apple'));
      expect(copy.productId, equals('prod_001'));
    });
  });

  // ──────────────────────────────────────────────
  // CartItemModel Tests
  // ──────────────────────────────────────────────
  group('CartItemModel', () {
    final product = ProductModel(
      productId: 'prod_001',
      productName: 'Apple',
      price: 50.0,
      imageUrl: '',
      category: 'Fruits',
      weight: 200,
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    );

    test('fromProduct creates cart item with quantity 1', () {
      final cartItem = CartItemModel.fromProduct(product, 'user_123');
      expect(cartItem.quantity, equals(1));
      expect(cartItem.userId, equals('user_123'));
      expect(cartItem.price, equals(50.0));
    });

    test('totalPrice is price × quantity', () {
      final cartItem = CartItemModel.fromProduct(product, 'user_123');
      final updated = cartItem.copyWith(quantity: 3);
      expect(updated.totalPrice, equals(150.0));
    });
  });

  // ──────────────────────────────────────────────
  // OrderModel Tests
  // ──────────────────────────────────────────────
  group('OrderModel', () {
    test('itemCount returns correct count', () {
      final order = OrderModel(
        orderId: 'ord_001',
        userId: 'user_123',
        items: [
          OrderItemModel(
              productId: 'p1', productName: 'Apple', price: 50, quantity: 2),
          OrderItemModel(
              productId: 'p2', productName: 'Mango', price: 80, quantity: 1),
        ],
        total: 180.0,
        createdAt: DateTime(2025),
      );
      expect(order.itemCount, equals(2));
    });

    test('OrderItemModel totalPrice is price × quantity', () {
      final item = OrderItemModel(
        productId: 'p1',
        productName: 'Apple',
        price: 50.0,
        quantity: 3,
      );
      expect(item.totalPrice, equals(150.0));
    });
  });

  // ──────────────────────────────────────────────
  // QRService Tests
  // ──────────────────────────────────────────────
  group('QRService', () {
    test('isValidQRData returns true for valid JSON with required fields', () {
      const valid =
          '{"productId":"p1","productName":"Apple","price":50,"category":"Fruits"}';
      expect(QRService.isValidQRData(valid), isTrue);
    });

    test('isValidQRData returns false for missing productId field', () {
      const missing = '{"productName":"Apple","price":50}';
      expect(QRService.isValidQRData(missing), isFalse);
    });

    test('isValidQRData returns true for short non-JSON string (raw ID)', () {
      expect(QRService.isValidQRData('raw-product-id-123'), isTrue);
    });

    test('parseQRData returns ProductModel for valid JSON', () {
      const valid =
          '{"productId":"p1","productName":"Apple","price":50.0,"category":"Fruits"}';
      final product = QRService.parseQRData(valid);
      expect(product, isNotNull);
      expect(product!.productName, equals('Apple'));
      expect(product.price, equals(50.0));
    });

    test('parseQRData returns null for invalid JSON', () {
      expect(QRService.parseQRData('garbage'), isNull);
    });

    test('generateQRData produces parseable JSON', () {
      final product = ProductModel(
        productId: 'p1',
        productName: 'Apple',
        price: 50.0,
        imageUrl: '',
        category: 'Fruits',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      final qrString = QRService.generateQRData(product);
      final parsed = QRService.parseQRData(qrString);
      expect(parsed, isNotNull);
      expect(parsed!.productId, equals('p1'));
    });
  });
}
