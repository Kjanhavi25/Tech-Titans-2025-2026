class AppConstants {
  // Firebase — Project: smart-trolly-12f28
  static const String firebaseProjectId = 'smart-trolly-12f28';
  static const String firebaseStorageBucket = 'smart-trolly-12f28.firebasestorage.app';

  // Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String cartsCollection = 'carts';
  static const String ordersCollection = 'orders';

  // Error Messages
  static const String errorNoInternet = 'No internet connection';
  static const String errorServerError = 'Server error occurred';
  static const String errorUnauthorized = 'Unauthorized access';
  static const String errorInvalidInput = 'Invalid input';
  static const String errorUnknown = 'Unknown error occurred';

  // Success Messages
  static const String successLoginSuccess = 'Login successful';
  static const String successSignupSuccess = 'Signup successful';
  static const String successProductAdded = 'Product added successfully';
  static const String successProductUpdated = 'Product updated successfully';
  static const String successProductDeleted = 'Product deleted successfully';
  static const String successOrderCreated = 'Order created successfully';
  static const String successOrderUpdated = 'Order updated successfully';
  static const String successPaymentSuccess = 'Payment successful';

  // Default Values
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const int defaultTimeout = 30;

  // QR Scanner
  static const String invalidQRCode = 'Invalid QR code';
  static const String qrCodeScanned = 'QR code scanned successfully';

  // Payment
  static const String paymentQRCode = 'UPI://pay?pa=merchant@upi&pn=SmartTrolley';

  // Roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
}
