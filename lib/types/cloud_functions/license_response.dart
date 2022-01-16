import 'package:artbooking/types/cloud_functions/minimal_object_id.dart';

/// Cloud function response after performing an action on a license.
class LicenseResponse {
  const LicenseResponse({
    required this.success,
    required this.license,
  });

  /// True if the operation was successful.
  final bool success;

  /// Target license.
  final MinimalObjectId license;

  factory LicenseResponse.empty() {
    return LicenseResponse(
      success: false,
      license: MinimalObjectId.empty(),
    );
  }

  factory LicenseResponse.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return LicenseResponse.empty();
    }

    return LicenseResponse(
      success: data['success'] ?? false,
      license: MinimalObjectId.fromJSON(data['license']),
    );
  }
}
