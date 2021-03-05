import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class SingleBookOpResp {
  bool success;
  final String bookId;
  final String message;
  final CloudFuncError error;
  final PartialUser user;

  SingleBookOpResp({
    this.bookId = '',
    this.success = true,
    this.message = '',
    this.error,
    this.user,
  });

  factory SingleBookOpResp.empty({bool success = false}) {
    return SingleBookOpResp(
      success: success,
      bookId: '',
      error: CloudFuncError(),
      user: PartialUser(),
    );
  }

  factory SingleBookOpResp.fromException(FirebaseFunctionsException exception) {
    return SingleBookOpResp(
      success: false,
      bookId: '',
      error: CloudFuncError.fromException(exception),
      user: PartialUser(),
    );
  }

  factory SingleBookOpResp.fromJSON(Map<dynamic, dynamic> data) {
    final _user = data['user'] != null
        ? PartialUser.fromJSON(data['user'])
        : PartialUser();

    final _error = data['error'] != null
        ? CloudFuncError.fromJSON(data['error'])
        : CloudFuncError();

    return SingleBookOpResp(
      bookId: data['bookId'],
      success: data['success'] ?? true,
      user: _user,
      error: _error,
    );
  }

  factory SingleBookOpResp.fromMessage(String message) {
    return SingleBookOpResp(
      success: false,
      bookId: '',
      error: CloudFuncError.fromMessage(message),
      user: PartialUser(),
    );
  }
}
