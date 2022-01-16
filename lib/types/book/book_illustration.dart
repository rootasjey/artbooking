import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/book/v_scale_factor.dart';

class BookIllustration {
  /// Illustration's id.
  final String id;

  /// When this illustration was added to the parent book.
  final DateTime createdAt;

  /// Defines this illustration's side inside this book.
  VScaleFactor vScaleFactor;

  BookIllustration({
    required this.createdAt,
    required this.id,
    required this.vScaleFactor,
  });

  factory BookIllustration.fromJSON(Map<String, dynamic> data) {
    return BookIllustration(
      createdAt: Utilities.date.fromFirestore(data['createdAt']),
      id: data['id'],
      vScaleFactor: VScaleFactor.fromJSON(data['vScaleFactor']),
    );
  }
}
