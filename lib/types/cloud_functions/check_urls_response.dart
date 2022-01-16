import 'package:artbooking/types/cloud_functions/cloud_functions_error.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Cloud function response after checking some properties..
class CheckPropertiesResponse {
  CheckPropertiesResponse({
    required this.success,
    required this.illustrationId,
    this.error,
    this.user,
  });

  /// True if the operation was successfully completed.
  final bool success;

  /// Illustration's on which the check was performed.
  final String illustrationId;

  /// Cloud function error if any.
  final CloudFunctionsError? error;

  /// User who performed this operation.
  final PartialUser? user;

  factory CheckPropertiesResponse.empty() {
    return CheckPropertiesResponse(
      success: false,
      illustrationId: '',
      error: CloudFunctionsError.empty(),
      user: PartialUser.empty(),
    );
  }

  factory CheckPropertiesResponse.fromException(
      FirebaseFunctionsException exception) {
    return CheckPropertiesResponse(
      success: false,
      illustrationId: '',
      error: CloudFunctionsError.fromException(exception),
      user: PartialUser(),
    );
  }

  factory CheckPropertiesResponse.fromJSON(Map<String, dynamic> data) {
    return CheckPropertiesResponse(
      success: data['success'] ?? false,
      illustrationId: data['illustrationId'] ?? '',
      error: CloudFunctionsError.fromJSON(data['error']),
      user: PartialUser.fromJSON(data['user']),
    );
  }

  factory CheckPropertiesResponse.fromMessage(String message) {
    return CheckPropertiesResponse(
      success: false,
      illustrationId: '',
      error: CloudFunctionsError.fromMessage(message),
      user: PartialUser(),
    );
  }
}
