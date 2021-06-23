import 'package:artbooking/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper for date and time conversions.
class DateHelper {
  /// Parse a date from Firestore.
  /// The raw value can be a int, Timestamp or a Map.
  /// Return a valida date and the currect date if it fails to parse ra‹ value.
  static DateTime fromFirestore(dynamic data) {
    DateTime date = DateTime.now();

    if (data == null) {
      return date;
    }

    try {
      if (data is int) {
        date = DateTime.fromMillisecondsSinceEpoch(data);
      } else if (data is Timestamp) {
        date = data.toDate();
      } else if (data is String) {
        date = DateTime.parse(data);
      } else if (data != null && data['_seconds'] != null) {
        date = DateTime.fromMillisecondsSinceEpoch(data['_seconds'] * 1000);
      }
    } catch (error) {
      appLogger.e(error);
    }

    return date;
  }
}
