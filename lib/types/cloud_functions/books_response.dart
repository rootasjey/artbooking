import 'package:artbooking/types/cloud_functions/cloud_functions_error.dart';
import 'package:artbooking/types/cloud_functions/book_operation.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Cloud function response after performing an action on multiple books.
class BooksResponse {
  BooksResponse({
    this.books = const [],
    required this.error,
    this.hasErrors = false,
    this.message = '',
    this.successCount = 0,
    required this.user,
  });

  /// True if the operation has failed.
  final bool hasErrors;

  /// Number of successful operations.
  final int successCount;

  /// Operations were perform on this list of books.
  final List<BookOperation> books;

  /// Server message.
  final String message;

  /// Cloud function error if any.
  final CloudFunctionsError error;

  /// Current user authenticated who performed operations.
  final PartialUser user;

  factory BooksResponse.fromException(FirebaseFunctionsException exception) {
    return BooksResponse(
      books: [],
      error: CloudFunctionsError.fromException(exception),
      hasErrors: true,
      message: '',
      successCount: 0,
      user: PartialUser(),
    );
  }

  factory BooksResponse.fromJSON(Map<dynamic, dynamic> data) {
    return BooksResponse(
      books: parseBooks(data['items']),
      hasErrors: data['hasErrors'] ?? true,
      successCount: data['successCount'],
      user: PartialUser.fromJSON(data['user']),
      error: CloudFunctionsError.fromJSON(data['error']),
    );
  }

  factory BooksResponse.fromMessage(String message) {
    return BooksResponse(
      hasErrors: true,
      books: [],
      error: CloudFunctionsError.fromMessage(message),
      user: PartialUser(),
    );
  }

  static List<BookOperation> parseBooks(data) {
    final books = <BookOperation>[];

    if (data['items'] == null) {
      return books;
    }

    for (Map<String, dynamic> item in data) {
      books.add(BookOperation.fromJSON(item));
    }

    return books;
  }
}
