import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/minimal_book_resp.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class OneBookOpResp {
  final MinimalBookResp book;
  final CloudFuncError error;
  final String message;
  final bool success;
  final PartialUser user;

  OneBookOpResp({
    required this.book,
    required this.error,
    this.message = '',
    this.success = false,
    required this.user,
  });

  factory OneBookOpResp.empty({bool success = false}) {
    return OneBookOpResp(
      book: MinimalBookResp.empty(),
      error: CloudFuncError.empty(),
      success: success,
      user: PartialUser.empty(),
    );
  }

  factory OneBookOpResp.fromException(FirebaseFunctionsException exception) {
    return OneBookOpResp(
      book: MinimalBookResp.empty(),
      error: CloudFuncError.fromException(exception),
      success: false,
      user: PartialUser.empty(),
    );
  }

  factory OneBookOpResp.fromJSON(Map<dynamic, dynamic> data) {
    return OneBookOpResp(
      book: MinimalBookResp.fromJSON(data['book']),
      success: data['success'] ?? true,
      user: PartialUser.fromJSON(data['user']),
      error: CloudFuncError.fromJSON(data['error']),
    );
  }

  factory OneBookOpResp.fromMessage(String message) {
    return OneBookOpResp(
      success: false,
      book: MinimalBookResp.empty(),
      error: CloudFuncError.fromMessage(message),
      user: PartialUser(),
    );
  }
}
