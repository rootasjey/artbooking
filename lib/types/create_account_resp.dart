import 'package:artbooking/types/cloud_function_error.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class CreateAccountResp {
  bool success;
  final String message;
  final CloudFunctionError? error;
  final PartialUser? user;
  firebase_auth.User? userAuth;

  CreateAccountResp({
    this.success = true,
    this.message = '',
    this.error,
    this.user,
    this.userAuth,
  });

  factory CreateAccountResp.empty() {
    return CreateAccountResp(
      success: false,
      user: PartialUser.empty(),
      error: CloudFunctionError.empty(),
    );
  }

  factory CreateAccountResp.fromJSON(Map<dynamic, dynamic> data) {
    return CreateAccountResp(
      success: data['success'] ?? true,
      user: PartialUser.fromJSON(data['user']),
      error: CloudFunctionError.fromJSON(data['error']),
    );
  }
}
