import 'package:artbooking/types/cloud_functions/minimal_object_id.dart';

/// An operation on an illustration.
/// It can be adding this illustration to another data structure for example.
class IllustrationOperation {
  IllustrationOperation({
    required this.illustration,
    this.success = false,
  });

  /// Target object.
  final MinimalObjectId illustration;

  /// True if the operation was successful.
  final bool success;

  factory IllustrationOperation.empty() {
    return IllustrationOperation(
      illustration: MinimalObjectId.empty(),
      success: true,
    );
  }

  factory IllustrationOperation.fromJSON(
    Map<dynamic, dynamic>? data,
  ) {
    if (data == null) {
      return IllustrationOperation.empty();
    }

    return IllustrationOperation(
      illustration: MinimalObjectId.fromJSON(data['illustration']),
      success: data['success'] ?? false,
    );
  }
}
