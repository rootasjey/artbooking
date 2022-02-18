import 'package:artbooking/types/cloud_functions/cloud_functions_error.dart';
import 'package:artbooking/types/cloud_functions/illustration_operation.dart';
import 'package:artbooking/types/user/partial_user.dart';
import 'package:cloud_functions/cloud_functions.dart';

class IllustrationsResponse {
  IllustrationsResponse({
    this.illustrations = const [],
    this.hasErrors = false,
    this.message = "",
    this.error,
    this.successCount = 0,
    this.user,
  });

  /// True if one of operations has failed.
  bool hasErrors;

  /// Ampunt of successful operations.
  final int successCount;

  /// Target illustrations.
  final List<IllustrationOperation> illustrations;

  /// Server message.
  final String message;

  /// Cloud functions error if any.
  final CloudFunctionsError? error;

  /// User who ask for the operation.
  final PartialUser? user;

  factory IllustrationsResponse.fromException(
    FirebaseFunctionsException exception,
  ) {
    return IllustrationsResponse(
      error: CloudFunctionsError.fromException(exception),
      hasErrors: true,
      illustrations: [],
      user: PartialUser.empty(),
    );
  }

  factory IllustrationsResponse.empty() {
    return IllustrationsResponse(
      error: CloudFunctionsError.empty(),
      hasErrors: false,
      illustrations: [],
      user: PartialUser.empty(),
    );
  }

  factory IllustrationsResponse.fromJSON(Map<dynamic, dynamic>? data) {
    if (data == null) {
      return IllustrationsResponse.empty();
    }

    return IllustrationsResponse(
      illustrations: parseIllustrations(data["items"]),
      successCount: data["successCount"] ?? 0,
      hasErrors: data["hasErrors"] ?? true,
      user: PartialUser.fromJSON(data["user"]),
      error: CloudFunctionsError.fromJSON(data["error"]),
    );
  }

  factory IllustrationsResponse.fromMessage(String message) {
    return IllustrationsResponse(
      hasErrors: true,
      illustrations: [],
      error: CloudFunctionsError.fromMessage(message),
      user: PartialUser(),
    );
  }

  static List<IllustrationOperation> parseIllustrations(data) {
    final illustrations = <IllustrationOperation>[];

    if (data == null) {
      return illustrations;
    }

    for (Map<dynamic, dynamic> item in data) {
      illustrations.add(IllustrationOperation.fromJSON(item));
    }

    return illustrations;
  }
}
