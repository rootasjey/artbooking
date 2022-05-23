import 'package:artbooking/types/cloud_functions/minimal_object_id.dart';

/// Cloud function response after performing an action on a license.
class PostResponse {
  const PostResponse({
    required this.success,
    required this.license,
  });

  /// True if the operation was successful.
  final bool success;

  /// Target license.
  final MinimalObjectId license;

  factory PostResponse.empty() {
    return PostResponse(
      success: false,
      license: MinimalObjectId.empty(),
    );
  }

  factory PostResponse.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return PostResponse.empty();
    }

    return PostResponse(
      success: data['success'] ?? false,
      license: MinimalObjectId.fromJSON(data['license']),
    );
  }
}
