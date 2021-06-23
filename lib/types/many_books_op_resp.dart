import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/processed_book.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ManyBooksOpResp {
  bool hasErrors;
  final int? successCount;
  final List<ProcessedBook> books;
  final String message;
  final CloudFuncError? error;
  final PartialUser? user;

  ManyBooksOpResp({
    this.books = const [],
    this.hasErrors = false,
    this.message = '',
    this.error,
    this.successCount = 0,
    this.user,
  });

  factory ManyBooksOpResp.fromException(FirebaseFunctionsException exception) {
    return ManyBooksOpResp(
      hasErrors: true,
      books: [],
      error: CloudFuncError.fromException(exception),
      user: PartialUser(),
    );
  }

  factory ManyBooksOpResp.fromJSON(Map<dynamic, dynamic> data) {
    final _user = data['user'] != null
        ? PartialUser.fromJSON(data['user'])
        : PartialUser();

    final _error = data['error'] != null
        ? CloudFuncError.fromJSON(data['error'])
        : CloudFuncError();

    final _books = <ProcessedBook>[];

    if (data['items'] != null) {
      for (Map<String, dynamic> item in data['items']) {
        _books.add(ProcessedBook.fromJSON(item));
      }
    }

    return ManyBooksOpResp(
      books: _books,
      hasErrors: data['hasErrors'] ?? true,
      successCount: data['successCount'],
      user: _user,
      error: _error,
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
}
