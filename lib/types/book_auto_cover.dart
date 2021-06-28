import 'package:artbooking/utils/date_helper.dart';

class BookAutoCover {
  final String id;
  final String url;
  final DateTime? updatedAt;

  BookAutoCover({
    required this.id,
    required this.url,
    this.updatedAt,
  });

  factory BookAutoCover.empty() {
    return BookAutoCover(
      id: '',
      url: '',
    );
  }

  factory BookAutoCover.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return BookAutoCover.empty();
    }

    return BookAutoCover(
      id: data['id'] ?? '',
      url: data['url'] ?? '',
      updatedAt: DateHelper.fromFirestore(data['updatedAt']),
    );
  }
}
