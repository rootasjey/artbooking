import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class OneIllusOpResp {
  bool success;
  final String? illustrationId;
  final String message;
  final CloudFuncError? error;
  final PartialUser? user;

  OneIllusOpResp({
    this.illustrationId = '',
    this.success = true,
    this.message = '',
    this.error,
    this.user,
  });

  factory OneIllusOpResp.empty({bool success = false}) {
    return OneIllusOpResp(
      success: success,
      illustrationId: '',
      error: CloudFuncError(),
      user: PartialUser(),
    );
  }

  factory OneIllusOpResp.fromException(FirebaseFunctionsException exception) {
    return OneIllusOpResp(
      success: false,
      illustrationId: '',
      error: CloudFuncError.fromException(exception),
      user: PartialUser(),
    );
  }

  factory OneIllusOpResp.fromJSON(Map<dynamic, dynamic> data) {
    final _user = data['user'] != null
        ? PartialUser.fromJSON(data['user'])
        : PartialUser();

    final _error = data['error'] != null
        ? CloudFuncError.fromJSON(data['error'])
        : CloudFuncError();

    return OneIllusOpResp(
      illustrationId: data['illustrationId'],
      success: data['success'] ?? true,
      user: _user,
      error: _error,
    );
  }

  factory OneIllusOpResp.fromMessage(String message) {
    return OneIllusOpResp(
      success: false,
      illustrationId: '',
      error: CloudFuncError.fromMessage(message),
      user: PartialUser(),
    );
  }
}
