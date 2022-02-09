import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/scale_factor.dart';

class BookIllustration {
  const BookIllustration({
    required this.createdAt,
    required this.id,
    required this.scaleFactor,
  });

  /// Illustration's id.
  final String id;

  /// When this illustration was added to the parent book.
  final DateTime createdAt;

  /// Defines this illustration's side inside this book.
  final ScaleFactor scaleFactor;

  factory BookIllustration.fromJSON(Map<String, dynamic> data) {
    return BookIllustration(
      createdAt: Utilities.date.fromFirestore(data['created_at']),
      id: data['id'],
      scaleFactor: ScaleFactor.fromJSON(data['scale_factor']),
    );
  }
}
