import 'package:artbooking/types/minimal_book_resp.dart';

/// An operation on a book.
/// It can be adding a book to another data structure for example.
class BookOp {
  final MinimalBookResp book;
  final bool success;

  /// Create an instance of an operation on a book.
  BookOp({
    required this.book,
    this.success = false,
  });

  factory BookOp.empty() {
    return BookOp(
      book: MinimalBookResp.empty(),
      success: false,
    );
  }

  factory BookOp.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return BookOp.empty();
    }

    return BookOp(
      book: MinimalBookResp.fromJSON(data['book']),
      success: data['success'] ?? false,
    );
  }
}
