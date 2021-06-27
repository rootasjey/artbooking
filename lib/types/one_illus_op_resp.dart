import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class OneIllusOpResp {
  final bool success;
  final String illustrationId;
  final String message;
  final CloudFuncError error;
  final PartialUser user;

  OneIllusOpResp({
    required this.illustrationId,
    required this.success,
    this.message = '',
    required this.error,
    required this.user,
  });

  factory OneIllusOpResp.empty({bool success = false}) {
    return OneIllusOpResp(
      success: success,
      illustrationId: '',
      error: CloudFuncError.empty(),
      user: PartialUser.empty(),
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
    return OneIllusOpResp(
      illustrationId: data['illustrationId'],
      success: data['success'] ?? true,
      user: PartialUser.fromJSON(data['user']),
      error: CloudFuncError.fromJSON(data['error']),
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
