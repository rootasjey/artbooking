import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class OneBookOpResp {
  bool success;
  final String bookId;
  final String message;
  final CloudFuncError error;
  final PartialUser user;

  OneBookOpResp({
    this.bookId = '',
    this.success = true,
    this.message = '',
    this.error,
    this.user,
  });

  factory OneBookOpResp.empty({bool success = false}) {
    return OneBookOpResp(
      success: success,
      bookId: '',
      error: CloudFuncError(),
      user: PartialUser(),
    );
  }

  factory OneBookOpResp.fromException(FirebaseFunctionsException exception) {
    return OneBookOpResp(
      success: false,
      bookId: '',
      error: CloudFuncError.fromException(exception),
      user: PartialUser(),
    );
  }

  factory OneBookOpResp.fromJSON(Map<dynamic, dynamic> data) {
    final _user = data['user'] != null
        ? PartialUser.fromJSON(data['user'])
        : PartialUser();

    final _error = data['error'] != null
        ? CloudFuncError.fromJSON(data['error'])
        : CloudFuncError();

    return OneBookOpResp(
      bookId: data['bookId'],
      success: data['success'] ?? true,
      user: _user,
      error: _error,
    );
  }

  factory OneBookOpResp.fromMessage(String message) {
    return OneBookOpResp(
      success: false,
      bookId: '',
      error: CloudFuncError.fromMessage(message),
      user: PartialUser(),
    );
  }
}
