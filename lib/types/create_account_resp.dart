import 'package:artbooking/types/cloud_func_error.dart';
import 'package:artbooking/types/user/partial_user.dart';

class CreateAccountResp {
  bool success;
  final String message;
  final CloudFuncError? error;
  final PartialUser? user;

  CreateAccountResp({
    this.success = true,
    this.message = '',
    this.error,
    this.user,
  });

  factory CreateAccountResp.empty() {
    return CreateAccountResp(
      success: false,
      user: PartialUser.empty(),
      error: CloudFuncError.empty(),
    );
  }

  factory CreateAccountResp.fromJSON(Map<dynamic, dynamic> data) {
    return CreateAccountResp(
      success: data['success'] ?? true,
      user: PartialUser.fromJSON(data['user']),
      error: CloudFuncError.fromJSON(data['error']),
    );
  }
}
