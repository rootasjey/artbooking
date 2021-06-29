import 'package:artbooking/types/minimal_illustration_resp.dart';

/// An operation on an illustration.
/// It can be adding this illustration to another data structure for example.
class IllustrationOp {
  final MinimalIllustrationResp illustration;
  final bool success;

  IllustrationOp({
    required this.illustration,
    this.success = false,
  });

  factory IllustrationOp.empty() {
    return IllustrationOp(
      illustration: MinimalIllustrationResp.empty(),
      success: true,
    );
  }

  factory IllustrationOp.fromJSON(Map<dynamic, dynamic>? data) {
    if (data == null) {
      return IllustrationOp.empty();
    }

    return IllustrationOp(
      illustration: MinimalIllustrationResp.fromJSON(data['illustration']),
      success: data['success'] ?? false,
    );
  }
}
