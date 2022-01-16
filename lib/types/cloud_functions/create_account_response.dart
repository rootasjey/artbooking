import 'package:artbooking/types/cloud_functions/cloud_functions_error.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Cloud function response after creating an account.
class CreateAccountResponse {
  CreateAccountResponse({
    this.success = true,
    this.message = '',
    this.error,
    this.user,
    this.userAuth,
  });

  /// True if the operation was successful.
  bool success;

  /// Server merssage.
  final String message;

  /// Cloud function error if any.
  final CloudFunctionsError? error;

  /// Newly created user.
  final PartialUser? user;

  /// Authenticated user.
  firebase_auth.User? userAuth;

  factory CreateAccountResponse.empty() {
    return CreateAccountResponse(
      success: false,
      user: PartialUser.empty(),
      error: CloudFunctionsError.empty(),
    );
  }

  factory CreateAccountResponse.fromJSON(Map<dynamic, dynamic> data) {
    return CreateAccountResponse(
      success: data['success'] ?? true,
      user: PartialUser.fromJSON(data['user']),
      error: CloudFunctionsError.fromJSON(data['error']),
    );
  }
}
