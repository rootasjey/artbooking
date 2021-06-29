import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/book_op.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ManyBooksOpResp {
  final bool hasErrors;
  final int successCount;
  final List<BookOp> books;
  final String message;
  final CloudFuncError error;
  final PartialUser user;

  ManyBooksOpResp({
    this.books = const [],
    required this.error,
    this.hasErrors = false,
    this.message = '',
    this.successCount = 0,
    required this.user,
  });

  factory ManyBooksOpResp.fromException(FirebaseFunctionsException exception) {
    return ManyBooksOpResp(
      books: [],
      error: CloudFuncError.fromException(exception),
      hasErrors: true,
      message: '',
      successCount: 0,
      user: PartialUser(),
    );
  }

  factory ManyBooksOpResp.fromJSON(Map<dynamic, dynamic> data) {
    return ManyBooksOpResp(
      books: parseBooks(data['items']),
      hasErrors: data['hasErrors'] ?? true,
      successCount: data['successCount'],
      user: PartialUser.fromJSON(data['user']),
      error: CloudFuncError.fromJSON(data['error']),
    );
  }

  factory ManyBooksOpResp.fromMessage(String message) {
    return ManyBooksOpResp(
      hasErrors: true,
      books: [],
      error: CloudFuncError.fromMessage(message),
      user: PartialUser(),
    );
  }

  static List<BookOp> parseBooks(data) {
    final books = <BookOp>[];

    if (data['items'] == null) {
      return books;
    }

    for (Map<String, dynamic> item in data) {
      books.add(BookOp.fromJSON(item));
    }

    return books;
  }
}
