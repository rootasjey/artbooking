import 'package:artbooking/types/cloud_functions/cloud_functions_error.dart';
import 'package:artbooking/types/user/partial_user.dart';

class CloudFunctionsResponse {
  bool success;
  final CloudFunctionsError? error;
  final PartialUser? user;

  CloudFunctionsResponse({
    this.success = true,
    this.error,
    this.user,
  });

  factory CloudFunctionsResponse.fromJSON(Map<dynamic, dynamic> data) {
    return CloudFunctionsResponse(
      success: data['success'] ?? true,
      user: PartialUser.fromJSON(data['user']),
      error: CloudFunctionsError.fromJSON(data['error']),
    );
  }
}
