import 'dart:convert';
import '../models/product_model.dart';

class QRService {
  /// Parse QR code data and extract productId and ownerId 
  static Map<String, String?>? getFullQRData(String qrRawData) {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(qrRawData);
      return {
        'productId': jsonData['productId']?.toString(),
        'ownerId': jsonData['ownerId']?.toString(),
      };
    } catch (e) {
      // Legacy support for raw ID
      if (qrRawData.length < 50 && !qrRawData.contains('{')) {
        return {'productId': qrRawData.trim(), 'ownerId': null};
      }
      return null;
    }
  }

  static String? getProductIdFromQR(String qrRawData) {
    return getFullQRData(qrRawData)?['productId'];
  }

  /// Generate minimalist QR data string for a product with owner association
  static String generateQRData(ProductModel product) {
    final qrData = {
      'productId': product.productId,
      'ownerId': product.ownerId,
    };
    return jsonEncode(qrData);
  }

  /// Validate if QR data is valid
  static bool isValidQRData(String qrData) {
    final data = getFullQRData(qrData);
    return data != null && data['productId'] != null;
  }

  /// Legacy support for parsing full data if present
  static ProductModel? parseQRData(String qrRawData) {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(qrRawData);
      return ProductModel.fromQRData(jsonData);
    } catch (e) {
      return null;
    }
  }
}
