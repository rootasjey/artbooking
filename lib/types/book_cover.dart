import 'package:artbooking/types/book_auto_cover.dart';
import 'package:artbooking/types/book_custom_cover.dart';

class BookCover {
  final BookAutoCover auto;
  final BookCustomCover custom;

  BookCover({
    required this.auto,
    required this.custom,
  });

  factory BookCover.empty() {
    return BookCover(
      auto: BookAutoCover.empty(),
      custom: BookCustomCover.empty(),
    );
  }

  factory BookCover.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return BookCover.empty();
    }

    return BookCover(
      auto: BookAutoCover.fromJSON(data['auto']),
      custom: BookCustomCover.fromJSON(data['custom']),
    );
  }
}
