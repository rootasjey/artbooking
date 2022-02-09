import 'package:artbooking/globals/utilities.dart';
import 'package:artbooking/types/enums/enum_book_cover_mode.dart';

class BookCover {
  const BookCover({
    required this.mode,
    required this.link,
    required this.updatedAt,
  });

  final BookCoverMode mode;
  final String link;
  final DateTime? updatedAt;

  factory BookCover.empty() {
    return BookCover(
      mode: BookCoverMode.lastIllustrationAdded,
      link: '',
      updatedAt: DateTime.now(),
    );
  }

  factory BookCover.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return BookCover.empty();
    }

    return BookCover(
      link: data['link'],
      updatedAt: Utilities.date.fromFirestore(data['updated_at']),
      mode: parseBookCoverMode(data['mode']),
    );
  }

  static BookCoverMode parseBookCoverMode(String rawMode) {
    switch (rawMode) {
      case 'last_illustration_added':
        return BookCoverMode.lastIllustrationAdded;
      case 'chosen_illustration':
        return BookCoverMode.chosenIllustration;
      case 'custom_cover':
        return BookCoverMode.customCover;
      default:
        return BookCoverMode.lastIllustrationAdded;
    }
  }
}
