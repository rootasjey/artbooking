import 'package:artbooking/types/cloud_functions/cloud_functions_error.dart';
import 'package:artbooking/types/cloud_functions/minimal_object_id.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Cloud function response after performing an action on an illustration.
class IllustrationResponse {
  IllustrationResponse({
    required this.illustration,
    required this.success,
    this.message = '',
    required this.error,
    required this.user,
  });

  /// True if the operation was compelted successfully.
  final bool success;

  /// Target object.
  final MinimalObjectId illustration;

  /// Server message.
  final String message;

  /// Cloud functions error if any.
  final CloudFunctionsError error;

  /// User who ask for the operation.
  final PartialUser user;

  factory IllustrationResponse.empty({bool success = false}) {
    return IllustrationResponse(
      success: success,
      illustration: MinimalObjectId.empty(),
      error: CloudFunctionsError.empty(),
      user: PartialUser.empty(),
    );
  }

  factory IllustrationResponse.fromException(
      FirebaseFunctionsException exception) {
    return IllustrationResponse(
      success: false,
      illustration: MinimalObjectId.empty(),
      error: CloudFunctionsError.fromException(exception),
      user: PartialUser(),
    );
  }

  factory IllustrationResponse.fromJSON(Map<dynamic, dynamic>? data) {
    if (data == null) {
      return IllustrationResponse.empty();
    }

    return IllustrationResponse(
      illustration: MinimalObjectId.fromJSON(data['illustration']),
      success: data['success'] ?? true,
      user: PartialUser.fromJSON(data['user']),
      error: CloudFunctionsError.fromJSON(data['error']),
    );
  }

  factory IllustrationResponse.fromMessage(String message) {
    return IllustrationResponse(
      success: false,
      illustration: MinimalObjectId.empty(),
      error: CloudFunctionsError.fromMessage(message),
      user: PartialUser(),
    );
  }
}
