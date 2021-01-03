import 'package:artbooking/types/author.dart';
import 'package:artbooking/types/illustration/license.dart';

class BookIllustration {
  /// Image's author.
  final Author author;

  /// Illustration's style (e.g. pointillism, realism) — Limited to 5.
  final List<String> categories;

  /// When this specific document (illustration inside this book) was created.
  final DateTime createdAt;

  /// Firesotre id.
  final String id;

  /// Specifies how this illustration can be used.
  final IllustrationLicense license;

  BookIllustration(
    this.author,
    this.categories,
    this.createdAt,
    this.id,
    this.license,
  );
}
