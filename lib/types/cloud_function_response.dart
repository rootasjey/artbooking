import 'package:artbooking/types/cloud_function_error.dart';
import 'package:artbooking/types/user/partial_user.dart';

class CloudFunctionResponse {
  bool success;
  final CloudFunctionError? error;
  final PartialUser? user;

  CloudFunctionResponse({
    this.success = true,
    this.error,
    this.user,
  });

  factory CloudFunctionResponse.fromJSON(Map<dynamic, dynamic> data) {
    return CloudFunctionResponse(
      success: data['success'] ?? true,
      user: PartialUser.fromJSON(data['user']),
      error: CloudFunctionError.fromJSON(data['error']),
    );
  }
}
