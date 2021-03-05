import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/processed_book.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class MultipleBooksOpResp {
  bool hasErrors;
  final int successCount;
  final List<ProcessedBook> books;
  final String message;
  final CloudFuncError error;
  final PartialUser user;

  MultipleBooksOpResp({
    this.books = const [],
    this.hasErrors = false,
    this.message = '',
    this.error,
    this.successCount = 0,
    this.user,
  });

  factory MultipleBooksOpResp.fromException(
      FirebaseFunctionsException exception) {
    return MultipleBooksOpResp(
      hasErrors: true,
      books: [],
      error: CloudFuncError.fromException(exception),
      user: PartialUser(),
    );
  }

  factory MultipleBooksOpResp.fromJSON(Map<dynamic, dynamic> data) {
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

    return MultipleBooksOpResp(
      books: _books,
      hasErrors: data['hasErrors'] ?? true,
      successCount: data['successCount'],
      user: _user,
      error: _error,
    );
  }

  factory MultipleBooksOpResp.fromMessage(String message) {
    return MultipleBooksOpResp(
      hasErrors: true,
      books: [],
      error: CloudFuncError.fromMessage(message),
      user: PartialUser(),
    );
  }
}
