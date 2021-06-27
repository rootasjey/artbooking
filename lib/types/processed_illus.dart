import 'package:artbooking/types/minimal_illustration_resp.dart';

class ProcessedIllustration {
  final MinimalIllustrationResp illustration;
  final bool success;

  ProcessedIllustration({
    required this.illustration,
    this.success = false,
  });

  factory ProcessedIllustration.empty() {
    return ProcessedIllustration(
      illustration: MinimalIllustrationResp.empty(),
      success: true,
    );
  }

  factory ProcessedIllustration.fromJSON(Map<dynamic, dynamic>? data) {
    if (data == null) {
      return ProcessedIllustration.empty();
    }

    return ProcessedIllustration(
      illustration: MinimalIllustrationResp.fromJSON(data['illustration']),
      success: data['success'] ?? false,
    );
  }
}
