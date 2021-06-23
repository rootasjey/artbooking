import 'package:artbooking/types/book_auto_cover.dart';
import 'package:artbooking/types/book_custom_cover.dart';

class BookCover {
  final BookAutoCover? auto;
  final BookCustomCover? custom;

  BookCover({
    this.auto,
    this.custom,
  });

  factory BookCover.fromJSON(Map<String, dynamic> data) {
    return BookCover(
      auto: BookAutoCover.fromJSON(data['auto']),
      custom: BookCustomCover.fromJSON(data['custom']),
    );
  }
}
