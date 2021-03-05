import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class SingleIllusOpResp {
  bool success;
  final String illustrationId;
  final String message;
  final CloudFuncError error;
  final PartialUser user;

  SingleIllusOpResp({
    this.illustrationId = '',
    this.success = true,
    this.message = '',
    this.error,
    this.user,
  });

  factory SingleIllusOpResp.empty({bool success = false}) {
    return SingleIllusOpResp(
      success: success,
      illustrationId: '',
      error: CloudFuncError(),
      user: PartialUser(),
    );
  }

  factory SingleIllusOpResp.fromException(
      FirebaseFunctionsException exception) {
    return SingleIllusOpResp(
      success: false,
      illustrationId: '',
      error: CloudFuncError.fromException(exception),
      user: PartialUser(),
    );
  }

  factory SingleIllusOpResp.fromJSON(Map<dynamic, dynamic> data) {
    final _user = data['user'] != null
        ? PartialUser.fromJSON(data['user'])
        : PartialUser();

    final _error = data['error'] != null
        ? CloudFuncError.fromJSON(data['error'])
        : CloudFuncError();

    return SingleIllusOpResp(
      illustrationId: data['illustrationId'],
      success: data['success'] ?? true,
      user: _user,
      error: _error,
    );
  }

  factory SingleIllusOpResp.fromMessage(String message) {
    return SingleIllusOpResp(
      success: false,
      illustrationId: '',
      error: CloudFuncError.fromMessage(message),
      user: PartialUser(),
    );
  }
}
