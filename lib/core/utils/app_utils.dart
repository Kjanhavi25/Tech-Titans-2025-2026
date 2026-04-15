import 'package:intl/intl.dart';

class AppUtils {
  /// Format currency
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format currency short variant
  static String formatCurrencyShort(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}k';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  /// Format date
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format date time
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  /// Format time
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Validate email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  /// Validate phone number
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    return phoneRegex.hasMatch(phone);
  }

  /// Get order status label
  static String getOrderStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  /// Get payment status label
  static String getPaymentStatusLabel(String status) {
    switch (status) {
      case 'unpaid':
        return 'Unpaid';
      case 'paid':
        return 'Paid';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  /// Generate unique ID
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Calculate discount percentage
  static double calculateDiscount(double original, double discounted) {
    if (original == 0) return 0;
    return ((original - discounted) / original) * 100;
  }

  /// Format weight
  static String formatWeight(double? weight) {
    if (weight == null) return '0 kg';
    if (weight < 1000) {
      return '${weight.toStringAsFixed(0)} g';
    } else {
      return '${(weight / 1000).toStringAsFixed(2)} kg';
    }
  }
}
