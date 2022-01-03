import 'package:artbooking/types/cloud_function_error.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CheckUrlsOpResp {
  final bool success;
  final String illustrationId;
  final CloudFunctionError? error;
  final PartialUser? user;

  CheckUrlsOpResp({
    required this.success,
    required this.illustrationId,
    this.error,
    this.user,
  });

  factory CheckUrlsOpResp.empty() {
    return CheckUrlsOpResp(
      success: false,
      illustrationId: '',
      error: CloudFunctionError.empty(),
      user: PartialUser.empty(),
    );
  }

  factory CheckUrlsOpResp.fromException(FirebaseFunctionsException exception) {
    return CheckUrlsOpResp(
      success: false,
      illustrationId: '',
      error: CloudFunctionError.fromException(exception),
      user: PartialUser(),
    );
  }

  factory CheckUrlsOpResp.fromJSON(Map<String, dynamic> data) {
    return CheckUrlsOpResp(
      success: data['success'] ?? false,
      illustrationId: data['illustrationId'] ?? '',
      error: CloudFunctionError.fromJSON(data['error']),
      user: PartialUser.fromJSON(data['user']),
    );
  }

  factory CheckUrlsOpResp.fromMessage(String message) {
    return CheckUrlsOpResp(
      success: false,
      illustrationId: '',
      error: CloudFunctionError.fromMessage(message),
      user: PartialUser(),
    );
  }
}
