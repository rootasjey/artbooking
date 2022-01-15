import 'package:artbooking/types/cloud_functions/minimal_object_id.dart';

class CloudFunctionsLicenseResponse {
  const CloudFunctionsLicenseResponse({
    required this.success,
    required this.license,
  });

  final bool success;
  final MinimalObjectId license;

  factory CloudFunctionsLicenseResponse.empty() {
    return CloudFunctionsLicenseResponse(
      success: false,
      license: MinimalObjectId.empty(),
    );
  }

  factory CloudFunctionsLicenseResponse.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return CloudFunctionsLicenseResponse.empty();
    }

    return CloudFunctionsLicenseResponse(
      success: data['success'] ?? false,
      license: MinimalObjectId.fromJson(data['license']),
    );
  }
}
