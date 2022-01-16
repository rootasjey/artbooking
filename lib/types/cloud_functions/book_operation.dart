import 'package:artbooking/types/cloud_functions/minimal_object_id.dart';

/// An operation on a book.
/// Part of [BooksResponse]
class BookOperation {
  /// Create an instance of an operation on a book.
  BookOperation({
    required this.book,
    this.success = false,
  });

  final MinimalObjectId book;
  final bool success;

  factory BookOperation.empty() {
    return BookOperation(
      book: MinimalObjectId.empty(),
      success: false,
    );
  }

  factory BookOperation.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return BookOperation.empty();
    }

    return BookOperation(
      book: MinimalObjectId.fromJSON(data['book']),
      success: data['success'] ?? false,
    );
  }
}
